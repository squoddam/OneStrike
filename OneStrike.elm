module OneStrike exposing (..)

import Html
import Html.App
import Html.Attributes as Attr
import Collage exposing (..)
import Element
import Time
import Color exposing (red)
import Debug

import Mouse
import Keyboard

main = Html.App.program({
  view = view,
  init = init,
  update = update,
  subscriptions = subscriptions
  })

-- MODEL

type alias Player =
  { x : Int
  , y : Int
  , s : Int
  }

type alias Model =
  { player : Player
  , mouse: Mouse.Position
  , keysDown : List Keyboard.KeyCode
  }

init : (Model, Cmd Msg)
init = (Model  (Player 0 0 5) {x = 0, y = 0} [], Cmd.none)

-- UPDATE

type Msg
  = MouseMove Mouse.Position
  | KeyDown Keyboard.KeyCode
  | KeyUp Keyboard.KeyCode
  | Tick Time.Time

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MouseMove pos ->
      {model | mouse = pos} ! []

    KeyDown key ->
      {model | keysDown = addKey key model.keysDown} ! []

    KeyUp key ->
      {model | keysDown = removeKey key model.keysDown} ! []

    Tick _->
      applyChanges model ! []


addKey : Keyboard.KeyCode -> List Keyboard.KeyCode -> List Keyboard.KeyCode
addKey key keysDown =
  if List.member key keysDown
    then keysDown
    else key :: keysDown

removeKey : Keyboard.KeyCode -> List Keyboard.KeyCode -> List Keyboard.KeyCode
removeKey key keysDown =
  List.filter (\k -> k /= key) keysDown

applyChanges : Model -> Model
applyChanges model =
  let
    player = model.player
    mOfKD x = List.member x model.keysDown
  in
    { model
    | player =
      { player
      | y =
          List.foldl
            (\key y ->
              case key of
                87 ->
                  y + model.player.s

                83 ->
                  y - model.player.s

                _->
                  y
            ) player.y model.keysDown
      , x =
          List.foldl
            (\key x ->
              case key of
                68 ->
                  x + model.player.s

                65 ->
                  x - model.player.s

                _->
                  x
            ) player.x model.keysDown
      }
    }



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
      move (
      toFloat  model.player.x,
      toFloat  model.player.y
      )
      <| playerView <| relativeMousePosition model.mouse
      ]
  ]

-- movePlayer : List Int -> Form -> Form
-- movePlayer (x,y) player =
--

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
  Sub.batch
  [ Mouse.moves MouseMove
  , Keyboard.downs KeyDown
  , Keyboard.ups KeyUp
  , Time.every (20 * Time.millisecond) Tick
  ]
