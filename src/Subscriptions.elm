module Subscriptions exposing(subscriptions)

import Time
import Mouse
import Keyboard

import Types exposing (..)

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
