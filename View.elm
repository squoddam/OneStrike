module View exposing (view)

import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Collage exposing (Form, collage, move, filled, outlined, defaultLine, circle)
import Element exposing (toHtml, show)
import Color exposing (red, black)

-- MY MODULES

import Types exposing (Model, Msg, Player, Pointer)
import Utils exposing (mousePositionByCenter)

view : Model -> Html Msg
view model =
  let
    relMPos = mousePositionByCenter model.mouse.pos
  in
    div
    [
      style [("cursor", "none"), ("border", "1px solid black"), ("display", "inline-block")]
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
          -- , toForm
          --   <| Element.show ("x: " ++ (toString model.pointer.r))
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
