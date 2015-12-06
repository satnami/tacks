module Screens.Home.View where

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)

import Models exposing (..)
import Routes exposing (..)

import Screens.Home.Types exposing (..)
import Screens.Home.Updates exposing (addr)
import Screens.Utils exposing (..)


view : Player -> Screen -> Html
view player screen =
  div
    [ class "container home" ]
    [ intro
    , welcomeForm player screen.handle
    , liveTracks player screen.liveStatus
    ]

intro : Html
intro =
  fullWidth
    [ h1 [ ] [ text "Sailing tactics from the sofa" ]
    , p [ ] [ text "Tracks is a free regatta simulation game. Engage yourself in a realtime multiplayer race or attempt to break your best time to climb the rankings."]
    ]

welcomeForm : Player -> String -> Html
welcomeForm player handle =
  if player.guest then
    setHandleBlock handle
  else
    div [ ] [ ]

setHandleBlock : String -> Html
setHandleBlock handle =
  div [ class "form-set-handle row" ]
    [ div [ class "col-md-4 "]
      [ div [ class "input-group" ]
        [ textInput
          [ placeholder "Got a nickname?"
          , value handle
          , onInput addr SetHandle
          , onEnter addr SubmitHandle
          ]
        , span [ class "input-group-btn" ]
          [ button
            [ class "btn btn-primary"
            , onClick addr SubmitHandle
            ]
            [ text "submit" ]
          ]
        ]
      ]
    , div [ class "col-md-8" ] [ linkTo Login [ class "btn btn-default" ] [ text "or log in"] ]
  ]


liveTracks : Player -> LiveStatus -> Html
liveTracks player {liveTracks} =
  div [ class "live-tracks" ]
    [ div [ class "row" ] (List.map liveTrackBlock liveTracks)
    , if isAdmin player then createTrackBlock else div [] []
    ]

liveTrackBlock : LiveTrack -> Html
liveTrackBlock ({track, creator, players} as lt) =
  div [ class "col-md-4" ]
    [ div [ class "live-track" ]
      [ h3 [ class "name" ] [ linkTo (PlayTrack track.id) [ ] [ text track.name ] ]
      -- , span [ class "creator"] [ text <| "by " ++ Maybe.withDefault "?" creator.handle ]
      , playersList players
      ]
    ]

playersList : List Player -> Html
playersList players =
  ul [ class "list-unstyled track-players" ] (List.map playerItem players)

playerItem : Player -> Html
playerItem player =
  li [ class "player" ] [ playerWithAvatar player ]

createTrackBlock : Html
createTrackBlock =
  p [ class "" ]
    [ a [ onClick addr CreateTrack
        , class "btn btn-primary" ]
      [ text "Create track" ]
    ]

