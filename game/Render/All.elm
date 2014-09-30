module Render.All where

import Core (..)
import Geo (..)
import Game (..)
import String
import Text

import Render.Utils (..)
import Render.Race (..)
import Render.Controls (..)
import Render.Dashboard (..)

renderAll : (Int,Int) -> GameState -> Element
renderAll (w,h) gameState =
  let dims = floatify (w,h)
      (w',h') = dims
      relativeForms = renderRace gameState
      absoluteForms = renderControls gameState dims
      dashboard = renderDashboard gameState (w,h)
      bg = rect w' h' |> filled colors.seaBlue
  in  layers [collage w h [bg, group [relativeForms, absoluteForms]], dashboard]
