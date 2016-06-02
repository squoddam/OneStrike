module OneStrike exposing (..)

import Html
import Html.App
import Html.Attributes as Attr
import Collage exposing (..)
import Element
import Time
import Color exposing (red)

import Mouse

main = Html.App.program({
  view = view,
  init = init,
  update = update,
  subscriptions = subscriptions
  })

-- MODEL

type alias Model =
  { mouse: Mouse.Position
  }

init : (Model, Cmd Msg)
init = (Model {x = 0, y = 0}, Cmd.none)

-- UPDATE

type Msg =
  MouseMove Mouse.Position

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MouseMove pos ->
      ({model | mouse = pos}, Cmd.none)

-- VIEW

view : Model -> Html.Html Msg
view model =
  Html.div
  [
    Attr.style [("cursor", "none"), ("border", "1px solid black"), ("display", "inline-block")]
  ]
  [
    Element.toHtml
      <| collage 500 500
      [
        playerView <| relativeMousePosition model.mouse
      ]
  ]

playerView : Mouse.Position -> Form
playerView pos =
  group
  [ outlined defaultLine (circle 20)
  , movePointer pos <| filled red <| circle 2
  ]

movePointer : Mouse.Position -> Form -> Form
movePointer {x, y} someForm =
  let
    -- x = (toFloat x)
    -- y = (toFloat y)
    hyp = sqrt <| (toFloat x)^2 + (toFloat y)^2
    proportion = 30 / hyp
    newx = (toFloat x) * proportion
    newy = (toFloat y) * proportion
  in
    move (newx, newy) someForm

relativeMousePosition : Mouse.Position -> Mouse.Position
relativeMousePosition {x, y} =
  { x = x - 250
  , y = 250 - y
  }
-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Mouse.moves MouseMove
