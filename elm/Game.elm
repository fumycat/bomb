port module Game exposing (..)

import Browser
import Element exposing (..)
import Html exposing (Html)
import Json.Encode as Encode
import Settings exposing (Model)


type Msg
    = Fingerprint String
      -- | CheckFingerprint
    | WebSocket String


type Event
    = CheckFingerprint String
    | Register String
    | Start


type alias Model =
    { fp : String
    , game_id : String
    }


port updateUrl : String -> Cmd msg


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
    ( Model "loading..." "-> TODO ->", updateUrl randomGame )


view : Model -> Html Msg
view model =
    layout [] (text model.fp)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Fingerprint f_string ->
            ( { model | fp = f_string }, sendMessage (eventEncoder <| CheckFingerprint f_string) )

        WebSocket ws_message ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ fingerprint Fingerprint, messageReceiver WebSocket ]


randomGame : String
randomGame =
    "AsDfg"


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
    in
    Encode.encode 0 value
