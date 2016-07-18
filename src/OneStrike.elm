module OneStrike exposing (..)

import Html.App

import Types exposing (..)

import View exposing (view)
import Model exposing (init)
import Update exposing (update)
import Subscriptions exposing (subscriptions)

main = Html.App.program(
  { view = view
  , init = init
  , update = update
  , subscriptions = subscriptions
  })
