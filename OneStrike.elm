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
  , r : Int
  , vector: (Int, Int)
  }

type alias Model =
  { player : Player
  , mouse: Mouse.Position
  , keysDown : List Keyboard.KeyCode
  }

init : (Model, Cmd Msg)
init = (Model  (Player 0 0 5 20 (0, 0)) {x = 0, y = 0} [], Cmd.none)

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
    speed = model.player.s
    newVector =
      List.foldl
        (\key (vx, vy) ->
          case key of
            87 ->
              (vx, vy + speed)

            83 ->
              (vx, vy - speed)

            68 ->
              (vx + speed, vy)

            65 ->
              (vx - speed, vy)

            _->
              (vx, vy)
        ) (0, 0) model.keysDown
  in
    { model
    | player =
      getBorderCollision model.player newVector
    }

getBorderCollision : Player -> (Int, Int) -> Player
getBorderCollision player (vx, vy) =
  let
    x = player.x
    y = player.y
    r = player.r
    newX =
      let
        finalX = x + vx
      in
        if finalX > 250 - r
          then 250 - r
          else
            if finalX < -250 + r
              then -250 + r
              else finalX
    newY = let
      finalY = y + vy
    in
      if finalY > 250 - r
        then 250 - r
        else
          if finalY < -250 + r
            then -250 + r
            else finalY
  in
    { player
    | x = newX
    , y = newY
    }

getCoordinate : (number, number, number, number) -> number
getCoordinate (coor, speed, rad, border) =
  let
    finalC = coor + speed
  in
    if finalC + rad > border
      then border - rad
      else finalC

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
      <| playerView <| (relativeMousePosition model.mouse, model.player.r)
      ]
  ]

-- movePlayer : List Int -> Form -> Form
-- movePlayer (x,y) player =
--

playerView : (Mouse.Position, Int) -> Form
playerView (pos, r) =
  group
  [ outlined defaultLine (circle (toFloat r))
  , movePointer pos <| filled red <| circle 2
  ]

movePointer : Mouse.Position -> Form -> Form
movePointer {x, y} someForm =
  let
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
  , Time.every (17 * Time.millisecond) Tick
  ]
