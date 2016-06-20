module OneStrike exposing (..)

import Html
import Html.App
import Html.Attributes as Attr
import Collage exposing (..)
import Element
import Time
import Color exposing (red, black)
import Debug

import Mouse
import Keyboard

main = Html.App.program({
  view = view,
  init = init,
  update = update,
  subscriptions = subscriptions
  })

--------------------------------------------------------------------------------
---------------------------------------- MODEL ---------------------------------
--------------------------------------------------------------------------------

type alias Pointer =
  { x               : Float
  , y               : Float
  , r               : Float
  , defaultR        : Float
  , defaultDistance : Int
  , vector          : {x : Float, y : Float}
  , independent     : Bool
  }

type alias Player =
  { x       : Int
  , y       : Int
  , s       : Int
  , r       : Int
  , vector  : (Int, Int)
  }

type MouseStatus
  = Up
  | Down

type alias MouseModel =
  { pos     : Mouse.Position
  , status  : MouseStatus
  }

type alias Model =
  { player    : Player
  , pointer   : Pointer
  , mouse     : MouseModel
  , keysDown  : List Keyboard.KeyCode
  }

init : (Model, Cmd Msg)
init = (Model
          ( Player
            0
            0
            5
            20
            (0, 0)
          )
          ( Pointer
            0
            0
            2
            2
            40
            { x = 0, y = 0 }
            False
          )
          (MouseModel { x = 0, y = 0 } Up) [], Cmd.none)

--------------------------------------------------------------------------------
---------------------------------------- UPDATE --------------------------------
--------------------------------------------------------------------------------

type Msg
  = MouseMove Mouse.Position
  | MouseDown Mouse.Position
  | MouseUp Mouse.Position
  | KeyDown Keyboard.KeyCode
  | KeyUp Keyboard.KeyCode
  | Tick Time.Time

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let
    modelMouse = model.mouse
  in
    case msg of
      MouseMove pos ->
          {model | mouse = { modelMouse | pos = pos}} ! []

      MouseDown _ ->
        {model | mouse = { modelMouse | status = Down}} ! []

      MouseUp _ ->
        {model | mouse = { modelMouse | status = Up}} ! []

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
    newPlayer =
      getBorderCollision model.player (getNewVector model)
    newModelWithPlayer =
      { model
      | player = newPlayer
      }
    newPointer =
      applyChangesToPointer newModelWithPlayer
  in
    { newModelWithPlayer
    | pointer = newPointer
    }

-- POINTER

applyChangesToPointer : Model -> Pointer
applyChangesToPointer model =
  let
    player = model.player
    pointer = model.pointer
    mx = mouseCoords.x
    my = mouseCoords.y
    hyp = sqrt <| (toFloat mx)^2 + (toFloat my)^2
    vector =
      getPointerVector model hyp (mx, my)

    ind =
      (pointer.r /= pointer.defaultR)
      &&
      ((vector.x /= 0) || (vector.y /= 0))
    mouseCoords =
      mounsePositionByPlayer model.player model.mouse.pos
    pointerCoords =
      let
        proportion = (toFloat pointer.defaultDistance) / hyp
        newx = ((toFloat mx) * proportion) + (toFloat player.x)
        newy = ((toFloat my) * proportion) + (toFloat player.y)
      in
        if ind
          then
            { x = pointer.x + vector.x
            , y = pointer.y + vector.y
            }
          else
            if hyp == 0
              then { x = toFloat mx, y = toFloat (my + pointer.defaultDistance)}
              else { x = newx, y = newy }
    pointerRadius =
      case model.mouse.status of
        Up ->
          if ind
            then pointer.r - 0.1
            else pointer.r

        Down ->
          if ind
            then pointer.r - 0.1
            else pointer.r + 0.1
  in
    { pointer
    | r = pointerRadius
    , x = pointerCoords.x
    , y = pointerCoords.y
    , vector = vector
    }

getPointerVector : Model -> Float -> (Int, Int) -> {x : Float, y : Float}
getPointerVector model hyp (mx, my) =
  let
   vectorProportion = 10 / hyp
   pointer = model.pointer
  in
    case model.mouse.status of
      Up ->
        if pointer.r /= pointer.defaultR
          then
          if (pointer.vector.x == 0) && (pointer.vector.y == 0)
            then
              { x = (toFloat mx) * vectorProportion
              , y = (toFloat my) * vectorProportion
              }
            else
              getPointerBorderCollision pointer pointer.vector
          else { x = 0, y = 0 }
      Down ->
        if pointer.r /= pointer.defaultR
          then getPointerBorderCollision pointer pointer.vector
          else { x = 0, y = 0 }

getPointerBorderCollision : Pointer -> {x : Float, y : Float} -> {x : Float, y : Float}
getPointerBorderCollision pointer vector =
  let
    {x, y} = pointer
    newXVector =
      if ((x + pointer.r) + vector.x > 250) || ((x - pointer.r) + vector.x < -250)
        then -vector.x
        else vector.x
    newYVector =
      if ((y + pointer.r) + vector.y > 250) || ((y - pointer.r) + vector.y < -250)
        then -vector.y
        else vector.y
  in
    {x = newXVector, y = newYVector}

mousePositionByCenter : Mouse.Position -> Mouse.Position
mousePositionByCenter pos =
  { x = pos.x - 250
  , y = 250 - pos.y
  }

mounsePositionByPlayer : Player -> Mouse.Position -> Mouse.Position
mounsePositionByPlayer player mousePos =
  let
    posByCenter = mousePositionByCenter mousePos
  in
    { x = posByCenter.x - player.x
    , y = posByCenter.y - player.y
    }

-- PLAYER

getNewVector : Model -> (Int, Int)
getNewVector model =
  let
    playerModel = model.player
    speed = playerModel.s
  in
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

--------------------------------------------------------------------------------
-------------------------------------- VIEW ------------------------------------
--------------------------------------------------------------------------------

view : Model -> Html.Html Msg
view model =
  let
    relMPos = mousePositionByCenter model.mouse.pos
  in
    Html.div
    [
      Attr.style [("cursor", "none"), ("border", "1px solid black"), ("display", "inline-block")]
    ]
    [
      Element.toHtml
        <| collage 500 500
          [ playerView model.player
          , pointerView model.pointer
          , move  ( toFloat relMPos.x
                  , toFloat relMPos.y
                  )
            <| filled black
            <| circle 2
          , toForm
            <| Element.show ("x: " ++ (toString model.pointer.r))
          ]
    ]

playerView : Player -> Form
playerView player =
  move  ( toFloat  player.x
        , toFloat  player.y
        )
  <| outlined defaultLine (circle (toFloat player.r))

pointerView : Pointer -> Form
pointerView pointer =
  move (pointer.x, pointer.y)
  <| filled red (circle pointer.r)
--------------------------------------------------------------------------------
--------------------------- SUBSCRIPTIONS --------------------------------------
--------------------------------------------------------------------------------

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
  [ Mouse.moves MouseMove
  , Mouse.downs MouseDown
  , Mouse.ups MouseUp
  , Keyboard.downs KeyDown
  , Keyboard.ups KeyUp
  , Time.every (17 * Time.millisecond) Tick
  ]
