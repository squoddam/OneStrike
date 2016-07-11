module Model exposing (..)

import Types exposing (..)

playerInit : Player
playerInit =
   Player
    0
    0
    5
    20
    (0, 0)

pointerInit : Pointer
pointerInit =
  Pointer
    0
    0
    2
    2
    40
    { x = 0, y = 0 }
    False

init : (Model, Cmd Msg)
init = (Model
          0
          playerInit
          pointerInit
          (MouseModel { x = 0, y = 0 } Up) [], Cmd.none)
