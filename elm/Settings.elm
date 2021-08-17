module Settings exposing (..)

import Browser
import Element exposing (..)
import Html exposing (Html)



-- TODO https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/Element.Input


type Msg
    = ChangeX


type Model
    = Data Float


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
    ( Data 0.0, Cmd.none )


view : a -> Html Msg
view model =
    layout [] (text "TODO")


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
