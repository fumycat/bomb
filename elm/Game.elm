port module Game exposing (..)

import Browser
import Html exposing (Html, a, div, img)
import Html.Attributes exposing (attribute, class, src)
import Json.Decode as Decode exposing (Decoder, andThen, decodeString, fail, field, string)
import Json.Encode as Encode


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


type alias TestTypeForAndThen =
    { text : String }


type ServerEvent
    = PlayerTyping String String
    | PlayerJoin String


type alias Model =
    { fp : String
    , game_id : String
    , buffer : String
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
    ( Model "loading..." "-> TODO ->" "", Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "container", attribute "style" "--tan: 0.41; --m: 5" ]
        [ a [] [ img [ src "https://assets.codepen.io/2017/17_05_a_amur_leopard_25.jpg" ] [] ]
        , a [ attribute "style" "--i: 1" ] [ img [ src "https://assets.codepen.io/2017/17_05_a_amur_leopard_25.jpg" ] [] ]
        , a [ attribute "style" "--i: 2" ] [ img [ src "https://assets.codepen.io/2017/17_05_a_amur_leopard_25.jpg" ] [] ]
        , a [ attribute "style" "--i: 3" ] [ img [ src "https://assets.codepen.io/2017/17_05_a_amur_leopard_25.jpg" ] [] ]
        , a [ attribute "style" "--i: 4" ] [ img [ src "https://assets.codepen.io/2017/17_05_a_amur_leopard_25.jpg" ] [] ]
        , a [ attribute "style" "--i: 5" ] [ img [ src "https://assets.codepen.io/2017/17_05_a_amur_leopard_25.jpg" ] [] ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Fingerprint f_string ->
            ( { model | fp = f_string }, sendMessage (eventEncoder <| CheckFingerprint f_string) )

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


eventEncoder : Event -> String
eventEncoder event =
    let
        value =
            case event of
                CheckFingerprint fp ->
                    Encode.object [ ( "check", Encode.string fp ) ]

                Register username ->
                    Encode.object [ ( "register", Encode.string username ) ]

                Start ->
                    Encode.object [ ( "start", Encode.null ) ]

                BufferChanged s ->
                    Encode.object [ ( "typed", Encode.string s ) ]

                Submit ->
                    Encode.object [ ( "submit", Encode.null ) ]
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



-- abc : List String
-- abc =
--     [ "а ", "б ", "в ", "г ", "д ", "е ", "ё ", "ж "
--     , "з ", "и ", "й ", "к ", "л ", "м ", "н ", "о "
--     , "п ", "р ", "с ", "т ", "у ", "ф ", "х ", "ц "
--     , "ч ", "ш ", "щ ", "ъ ", "ы ", "ь ", "э ", "ю ", "я " ]


keyUpdate : Model -> String -> ( Model, Cmd Msg )
keyUpdate model key =
    case key of
        "Enter" ->
            ( model, sendMessage (eventEncoder <| Submit) )

        "Tab" ->
            ( { model | buffer = "" }, sendMessage (eventEncoder <| BufferChanged "") )

        "Backspace" ->
            let
                new_buffer =
                    String.dropRight 1 model.buffer
            in
            ( { model | buffer = new_buffer }, sendMessage (eventEncoder <| BufferChanged new_buffer) )

        _ ->
            let
                new_buffer =
                    if String.length key == 1 then
                        model.buffer ++ key

                    else
                        model.buffer
            in
            ( { model | buffer = new_buffer }, sendMessage (eventEncoder <| BufferChanged new_buffer) )


serverUpdate : Model -> String -> ( Model, Cmd Msg )
serverUpdate model json_msg =
    case decodeString serverEventDecoder json_msg of
        Ok (PlayerTyping who what) ->
            ( model, Cmd.none )

        Ok (PlayerJoin who) ->
            ( model, Cmd.none )

        Err _ ->
            ( model, Cmd.none )
