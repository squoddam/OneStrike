module OneStrike exposing (..)

import Html
import Html.App

main = Html.App.beginnerProgram({view = view, model = init, update = update})

-- MODEL

type alias Model = Int

init : Model
init = 0

-- UPDATE

type Msg = NoOp

update : Msg -> Model -> Model
update msg model =
  case msg of
    NoOp -> model

-- VIEW

view : Model -> Html.Html Msg
view model =
  Html.div []
    [
      Html.text "FUCKYOU"
    ]
