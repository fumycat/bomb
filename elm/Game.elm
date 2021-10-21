port module Game exposing (..)

import Browser
import Browser.Events
import Html exposing (Html, a, div, img)
import Html.Attributes exposing (attribute, class, src)
import Json.Decode as Decode exposing (Decoder, andThen, decodeString, fail, field, string)
import Json.Encode as Encode


type Msg
    = Fingerprint String
      -- | CheckFingerprint
    | WebSocket String
    | KeyPress String
    | Ignore


type Event
    = CheckFingerprint String
    | Register String
    | Start
    | Typed String
    | Submit


type WatchedKey
    = AlphaKey String
    | ClearKey
    | EnterKey
    | IgnoreKey


type alias TestTypeForAndThen =
    { text : String }


type alias Model =
    { fp : String
    , game_id : String
    , in_field : String
    }


port fingerprint : (String -> msg) -> Sub msg


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
            ( model, Cmd.none )

        KeyPress s ->
            ( { model | in_field = model.in_field ++ s }, sendMessage (eventEncoder <| Typed model.in_field) )

        Ignore ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ fingerprint Fingerprint
        , messageReceiver WebSocket
        , Browser.Events.onKeyDown keyDecoder
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
                    Encode.object [ ( "start", Encode.string "TODO opts?" ) ]

                Typed string ->
                    Encode.object [ ( "typed", Encode.string string ) ]

                Submit ->
                    Encode.object [ ( "submit", Encode.string "?" ) ]
    in
    Encode.encode 0 value


decodeServerJson : String -> Maybe TestTypeForAndThen
decodeServerJson json_msg =
    case decodeString serverEventDecoder json_msg of
        Ok v ->
            Just v

        Err error ->
            Nothing


serverEventDecoder : Decoder TestTypeForAndThen
serverEventDecoder =
    field "event" string
        |> andThen serverEventHelp


serverEventHelp : String -> Decoder TestTypeForAndThen
serverEventHelp str =
    case str of
        "typed" ->
            Decode.map TestTypeForAndThen (field "text" string)

        _ ->
            fail ""


keyDecoder : Decode.Decoder Msg
keyDecoder =
    Decode.map toKey (Decode.field "key" Decode.string)


toKey : String -> Msg
toKey string =
    case string of
        "a" ->
            KeyPress string

        _ ->
            Ignore
