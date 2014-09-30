module Render.Utils where

import String as S
import Text
import Game

helpMessage = "←/→ to turn left/right, SHIFT + ←/→ to fine tune direction, \n" ++
  "ENTER to lock angle to wind, SPACE to tack/jibe, S to cast a spell"

startCountdownMessage = "press C to start countdown (60s)"

colors =
  { seaBlue = rgb 10 105 148
  , sand = rgb 239 210 121
  , gateMark = orange
  , gateLine = orange
  }

fullScreenMessage : String -> Form
fullScreenMessage msg = msg
  |> S.toUpper
  |> toText
  |> Text.height 60
  |> Text.color white
  |> centered
  |> toForm
  |> alpha 0.3

baseText : String -> Text
baseText s = s
  |> toText
  |> Text.height 15
  |> typeface ["Inconsolata", "monospace"]

triangle : Float -> Bool -> Path
triangle s isUpward =
  if isUpward then
    polygon [(0,0),(-s,-s),(s,-s)]
  else
    polygon [(0,0),(-s,s),(s,s)]

fixedLength : Int -> String -> String
fixedLength l txt =
  if S.length txt < l then
    S.padRight l ' ' txt
  else
    S.left (l - 3) txt ++ "..."

formatCountdown : Time -> String
formatCountdown c =
  let cs = c |> inSeconds |> ceiling
      m = cs // 60
      s = cs `rem` 60
  in  "Start in " ++ (show m) ++ "' " ++ (show s) ++ "\"..."

gameTitle : Game.GameState -> String
gameTitle {countdown,opponents} = case countdown of
  Just c ->
    if c > 0 then formatCountdown c else "Started"
  Nothing ->
    "(" ++ show (1 + length opponents) ++ ") Waiting..."