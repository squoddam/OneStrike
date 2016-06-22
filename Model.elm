module Model exposing (init)

import Types exposing (..)

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
