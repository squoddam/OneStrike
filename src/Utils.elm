module Utils exposing (..)

import Mouse exposing (Position)
import Keyboard exposing (KeyCode)
import Debug exposing (log)

import Types exposing (..)
import Model exposing (playerInit)

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
    newModelWithoutCorrections =
      { newModelWithPlayer
      | pointer = newPointer
      }

  in
    getCorrectedModel newModelWithoutCorrections

-- POINTER

applyChangesToPointer : Model -> Pointer
applyChangesToPointer model =
  let
    pointer = model.pointer
    vector =
      getPointerVector model

    ind =
      (pointer.r /= pointer.defaultR)
      &&
      ((vector.x /= 0) || (vector.y /= 0))
    mouseCoords =
      mounsePositionByPlayer model.player model.mouse.pos
    pointerCoords =
      getPointerCoords model vector ind
    pointerRadius =
      getPointerRadius pointer.r model.mouse.status ind
  in
    { pointer
    | r = pointerRadius
    , x = pointerCoords.x
    , y = pointerCoords.y
    , vector = vector
    }

getPointerRadius : Float -> MouseStatus -> Bool -> Float
getPointerRadius r status isIndepenedent =
  case status of
    Up ->
      if isIndepenedent
        then r - 0.1
        else r

    Down ->
      if isIndepenedent
        then r - 0.1
        else r + 0.1

getPointerCoords : Model -> {x : Float, y : Float} -> Bool -> {x : Float, y : Float}
getPointerCoords model vector isIndependent =
  let
    pointer = model.pointer
    player = model.player
    { x, y } = mounsePositionByPlayer model.player model.mouse.pos
    hyp = (getHypothenuse (x, y))
    proportion = (toFloat pointer.defaultDistance) / hyp
    newx = ((toFloat x) * proportion) + (toFloat player.x)
    newy = ((toFloat y) * proportion) + (toFloat player.y)
  in
    if isIndependent
      then
        { x = pointer.x + vector.x
        , y = pointer.y + vector.y
        }
      else
        if hyp == 0
          then { x = toFloat x, y = toFloat (y + pointer.defaultDistance)}
          else { x = newx, y = newy }

getHypothenuse : (Int, Int) -> Float
getHypothenuse (mx, my) =
  sqrt <| (toFloat mx)^2 + (toFloat my)^2

getPointerVector : Model -> {x : Float, y : Float}
getPointerVector model =
  let
    { x, y } = mounsePositionByPlayer model.player model.mouse.pos
    vectorProportion = 10 / (getHypothenuse (x, y))
    pointer = model.pointer
  in
    case model.mouse.status of
      Up ->
        if pointer.r /= pointer.defaultR
          then
          if (pointer.vector.x == 0) && (pointer.vector.y == 0)
            then
              { x = (toFloat x) * vectorProportion
              , y = (toFloat y) * vectorProportion
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

-- after-applying corrections

getCorrectedModel : Model -> Model
getCorrectedModel model =
   let
    playerDeath = isPlayerDead model
   in
    if playerDeath
      then
        { model
        | score = model.score - 1
        , player = playerInit
        }
      else
        model

isPlayerDead : Model -> Bool
isPlayerDead model =
  let
    player = model.player
    pointer = model.pointer
    relX = (round pointer.x) - player.x
    relY = (round pointer.y) - player.y
    hyp = getHypothenuse (relX, relY)
    rSum = (toFloat player.r) + pointer.r
  in
    hyp < rSum
