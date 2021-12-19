port module Game exposing (..)

import Browser
import Dict exposing (Dict)
import Html exposing (Html, a, div, img, text)
import Html.Attributes exposing (attribute, class, id, src)
import Json.Decode as Decode exposing (Decoder, andThen, decodeString, fail, field, string)
import Json.Encode as Encode


type GameState
    = Prepare
    | Transition
    | PlayerTurn
    | GameEnd


type Msg
    = Fingerprint String
    | WebSocket String
    | KeyPress String


type Event
    = CheckFingerprint String
    | Register String
    | Start
    | BufferChanged String
    | Submit


type ServerEvent
    = PlayerTyping String String
    | PlayerJoin String


type PlayerStatus
    = Admin
    | Normal
    | Alive
    | Dead
    | Disconnected
    | Spectator


type alias Player =
    { name : String
    , icon : String
    , lives : Int
    , buffer : String
    , status : PlayerStatus
    , self : Bool
    }


type alias Model =
    { fp : String
    , buffer : String
    , players : Dict Int Player
    , state : GameState
    }


port fingerprint : (String -> msg) -> Sub msg


port keyEvents : (String -> msg) -> Sub msg


port sendMessage : String -> Cmd msg


port messageReceiver : (String -> msg) -> Sub msg


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : () -> ( Model, Cmd Msg )
init () =
    let
        tmpPlayersForTest =
            Dict.fromList
                [ ( 1
                  , Player "Kekis"
                        "https://assets.codepen.io/2017/17_05_a_amur_leopard_25.jpg"
                        2
                        "long text test test test test test test"
                        Admin
                        True
                  )
                , ( 2
                  , Player "Dora"
                        "https://assets.codepen.io/2017/17_05_a_amur_leopard_25.jpg"
                        2
                        ""
                        Normal
                        False
                  )
                , ( 3
                  , Player "long long long name test test test"
                        "https://assets.codepen.io/2017/17_05_a_amur_leopard_25.jpg"
                        2
                        "s"
                        Normal
                        False
                  )
                ]
    in
    ( Model "undefined" "" tmpPlayersForTest Prepare, Cmd.none )


view : Model -> Html Msg
view model =
    viewField model


viewField : Model -> Html Msg
viewField model =
    let
        c =
            String.fromInt (Dict.size model.players)

        atrs =
            String.join " ;" [ "--tan: 0.41", " --m: " ++ c ]

        ps =
            List.map viewPlayer (Dict.toList model.players)
    in
    div [ class "container", attribute "style" atrs ]
        [ div [ class "player" ]
            (a [] [ img [ src "bomb.svg", id "bomb" ] [] ] :: ps)
        ]


viewPlayer : ( Int, Player ) -> Html Msg
viewPlayer ( i, player ) =
    div [ class "player", attribute "style" ("--i: " ++ String.fromInt i) ]
        [ div [ class "player-name" ]
            [ text player.name ]
        , a []
            [ img [ src player.icon ] [] ]
        , div [ class "player-text" ]
            [ text player.buffer ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Fingerprint f_string ->
            ( { model | fp = f_string }, sendMessage (eventEncoder (CheckFingerprint f_string) model.fp) )

        WebSocket ws_message ->
            serverUpdate model ws_message

        KeyPress s ->
            keyUpdate model s


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ fingerprint Fingerprint
        , messageReceiver WebSocket
        , keyEvents KeyPress
        ]


eventEncoder : Event -> String -> String
eventEncoder event fp =
    let
        value =
            case event of
                CheckFingerprint cfp ->
                    Encode.object [ ( "check", Encode.string cfp ) ]

                Register username ->
                    Encode.object [ ( "register", Encode.string username ), ( "fp", Encode.string fp ) ]

                Start ->
                    Encode.object [ ( "start", Encode.null ), ( "fp", Encode.string fp ) ]

                BufferChanged s ->
                    Encode.object [ ( "buff", Encode.string s ), ( "fp", Encode.string fp ) ]

                Submit ->
                    Encode.object [ ( "submit", Encode.null ), ( "fp", Encode.string fp ) ]
    in
    Encode.encode 0 value


serverEventDecoder : Decoder ServerEvent
serverEventDecoder =
    field "event" string
        |> andThen serverEventHelp


serverEventHelp : String -> Decoder ServerEvent
serverEventHelp str =
    case str of
        "typed" ->
            Decode.map2 PlayerTyping
                (field "from" string)
                (field "text" string)

        "join" ->
            Decode.map PlayerJoin
                (field "who" string)

        _ ->
            fail "TODO maybe add error message?"


keyUpdate : Model -> String -> ( Model, Cmd Msg )
keyUpdate model key =
    case key of
        "Enter" ->
            ( model, sendMessage (eventEncoder Submit model.fp) )

        "Tab" ->
            ( { model | buffer = "" }, sendMessage (eventEncoder (BufferChanged "") model.fp) )

        "Backspace" ->
            let
                new_buffer =
                    String.dropRight 1 model.buffer
            in
            ( { model | buffer = new_buffer }, sendMessage (eventEncoder (BufferChanged new_buffer) model.fp) )

        _ ->
            let
                new_buffer =
                    if String.length key == 1 then
                        model.buffer ++ key

                    else
                        model.buffer
            in
            ( { model | buffer = new_buffer }, sendMessage (eventEncoder (BufferChanged new_buffer) model.fp) )


serverUpdate : Model -> String -> ( Model, Cmd Msg )
serverUpdate model json_msg =
    case decodeString serverEventDecoder json_msg of
        Ok (PlayerTyping who what) ->
            ( model, Cmd.none )

        Ok (PlayerJoin who) ->
            ( model, Cmd.none )

        Err _ ->
            ( model, Cmd.none )
