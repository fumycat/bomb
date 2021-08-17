module Index exposing (main)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Input as Input
import Html exposing (Html)
import Time


type Msg
    = CreateRoom
    | Shift Time.Posix


type Info
    = Loading
    | Done Int


type alias Model =
    { info : Info
    , color_angle : Float
    }


colorShiftSpeed : Float
colorShiftSpeed =
    pi / 100


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
    ( Model Loading 0.0, loadInfo )


loadInfo : Cmd Msg
loadInfo =
    Cmd.none


view : Model -> Html Msg
view model =
    let
        gradient_options =
            { angle = model.color_angle
            , steps =
                [ rgb 0.992 0.796 0.945
                , rgb 0.902 0.871 0.914
                ]
            }
    in
    layout [ Background.gradient gradient_options, width fill ]
        (column [ centerY, width fill, padding 24 ]
            [ row [centerX] [ el [] (text "Hi") ]
            , row [centerX, paddingXY 0 40]
                [ el []
                    (Input.button
                        [ Background.color (rgb 0.9 0.9 0.7), padding 32 ]
                        { onPress = Nothing, label = text "Click me" }
                    )
                ]
            ]
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CreateRoom ->
            ( model, Cmd.none )

        Shift _ ->
            ( { model | color_angle = model.color_angle + colorShiftSpeed }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 100 Shift
