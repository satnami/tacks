module View.Race exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Date
import Date.Format as DateFormat
import Model.Shared exposing (..)
import View.Utils as Utils
import Dialog


reports : Bool -> (RaceReport -> Attribute msg) -> List RaceReport -> Html msg
reports showName clickHandler reports =
  div
    [ class "row race-reports" ]
    <| if List.isEmpty reports then
        [ div [ class "notice" ] [ text "No races yet!" ] ]
       else
        List.map (raceReportItem showName clickHandler) reports


raceReportItem : Bool -> (RaceReport -> Attribute msg) -> RaceReport -> Html msg
raceReportItem showName clickHandler report =
  let
    count =
      List.length report.runs

    runsList =
      report.runs
        |> List.take 3
        |> List.indexedMap raceReportRun
  in
    div
      [ class "col-sm-3" ]
      [ div
          [ class "race-card"
          , clickHandler report
          ]
          [ div
              [ class "race-card-header"
              ]
              [ if showName then
                  div
                    [ class "track-name"
                    , title report.trackName
                    ]
                    [ text report.trackName ]
                else
                  text ""
              ]
          , ul
              [ class "list-unstyled list-rankings" ]
              (runsList ++ (List.repeat (3 - count) emptyRun))
          , div
              [ class "race-card-footer" ]
              [ span
                  [ class "start-time" ]
                  [ text
                      (DateFormat.format
                        "%e %b. %k:%M"
                        (Date.fromTime report.startTime)
                      )
                  ]
              , if List.length report.runs > 3 then
                  span
                    [ class "see-more" ]
                    [ text ("+" ++ toString (count - 3)) ]
                else
                  text ""
              ]
          ]
      ]


raceReportRun : Int -> Run -> Html msg
raceReportRun i run =
  li
    [ class "ranking" ]
    [ span
        [ class "rank" ]
        [ text (toString (i + 1)) ]
    , span
        [ class "handle" ]
        [ text (Maybe.withDefault "anonymous" run.playerHandle)
        ]
    , span
        [ class "time" ]
        [ text (Utils.formatTimer True run.duration) ]
      -- , playerWithAvatar run.player
    ]


emptyRun : Html msg
emptyRun =
  li
    [ class "empty" ]
    [ span
        [ class "rank" ]
        [ Utils.nbsp ]
    , span
        [ class "handle" ]
        [ Utils.nbsp ]
    , span
        [ class "time" ]
        [ Utils.nbsp ]
      -- , playerWithAvatar run.player
    ]


reportDialog : RaceReport -> Dialog.Layout
reportDialog report =
  { header =
      [ Dialog.title "Race report"
      , Dialog.subtitle
          (report.trackName ++ " - " ++ Utils.formatDate report.startTime)
      ]
  , body =
      [ ul
          [ class "list-unstyled list-rankings" ]
          (List.indexedMap raceReportRun report.runs)
      ]
  , footer = []
  }
