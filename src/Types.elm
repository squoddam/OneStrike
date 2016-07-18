module Types exposing (..)

import Mouse
import Keyboard
import Time

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
  { score     : Int
  , player    : Player
  , pointer   : Pointer
  , mouse     : MouseModel
  , keysDown  : List Keyboard.KeyCode
  }

type Msg
  = MouseMove Mouse.Position
  | MouseDown Mouse.Position
  | MouseUp Mouse.Position
  | KeyDown Keyboard.KeyCode
  | KeyUp Keyboard.KeyCode
  | Tick Time.Time
