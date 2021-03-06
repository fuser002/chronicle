module Chronicle.View where

import Signal exposing (Address)
import Html exposing (..)

import Util.Bootstrap as B
import Chronicle.Model as Model
import Chronicle.Controller as Controller
import Chronicle.Components.SearchView as SearchView
import Chronicle.Components.MomentListGroupedView as MomentListGroupedView
import Chronicle.UI.EditorView as EditorView


view : Address Controller.Action -> Model.Model -> Html
view address model =
  let
    model' = Model.transformModel model
  in
    B.fluidContainer
    [ B.pageHeader ["table-" ++ model.tableName] <| "Chronicle : " ++ model.tableName
    , viewInput address model
    , MomentListGroupedView.view address model'.momentList
    ]


viewInput : Address Controller.Action -> Model.Model -> Html
viewInput address model =
  let
    header  = text "Search & Add"
    content = div []
                [ SearchView.view  address
                , hr [] []
                , EditorView.view  address Controller.MomentEditor model.addMoment
                ]
  in
    B.panel' (Just B.Primary) header content
