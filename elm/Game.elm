port module Game exposing (..)

-- import Element exposing (..)

import Browser
import Html exposing (Html, div, input, text)
import Html.Attributes exposing (placeholder, value)
import Html.Events exposing (onInput)
import Json.Encode as Encode
import Settings exposing (Model)


type Msg
    = Fingerprint String
      -- | CheckFingerprint
    | WebSocket String
    | Change String


type Event
    = CheckFingerprint String
    | Register String
    | Start
    | Typed String
    | Submit


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
    -- layout [] (text model.fp)
    div []
        [ input [ placeholder "Text to reverse", value model.in_field, onInput Change ] []
        , div [] [ text model.in_field ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Fingerprint f_string ->
            ( { model | fp = f_string }, sendMessage (eventEncoder <| CheckFingerprint f_string) )

        WebSocket ws_message ->
            ( model, Cmd.none )

        Change newContent ->
            ( { model | in_field = newContent }, sendMessage (eventEncoder <| Typed newContent) )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ fingerprint Fingerprint, messageReceiver WebSocket ]


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
