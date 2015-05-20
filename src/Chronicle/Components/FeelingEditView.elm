module Chronicle.Components.FeelingEditView where

import Result exposing (toMaybe)
import Maybe exposing (withDefault)
import Signal exposing (Address, message)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as HE

import Util.Bootstrap as B
import Chronicle.Data.Feeling exposing (Feeling, parseHow, How(..))
import Chronicle.Controller as Controller
import Chronicle.Components.FeelingEdit as FeelingEdit

view : Address Controller.Action -> FeelingEdit.Model -> Html
view address {editType, formValue} =
  let
    formElements = [ StringInput address updateHow' "How am I feeling?" (toString formValue.how)
                   , StringInput address FeelingEdit.UpdateWhat "What is the feeling?" formValue.what
                   , StringInput address FeelingEdit.UpdateTrigger "What triggered it?" formValue.trigger
                   ]
    msgButton = FeelingEdit.Save |> Controller.FeelingEdit
    buttonLabel = case editType of
      FeelingEdit.AddNew -> "Add"
      FeelingEdit.EditExisting -> "Save"
  in
    -- TODO: a select element (not input) for "how" field
    -- TODO: a textarea for notes
    div [ class "form-group" ]
    (List.map viewFormInput formElements ++
    [ button [ class "btn btn-primary"
             , HE.onClick address msgButton ] [ text buttonLabel ]
    ])

parseHowWithDefault : How -> String -> How
parseHowWithDefault default string =
  parseHow string
  |> toMaybe
  |> withDefault default

-- Form abstraction

type FormInput
  = StringInput (Address Controller.Action) (String -> FeelingEdit.Action) String String

viewFormInput : FormInput -> Html
viewFormInput fi =
  case fi of
    (StringInput address toAction placeHolder value) ->
      input' address toAction value placeHolder

input' : Address Controller.Action
      -> (String -> FeelingEdit.Action)
      -> String
      -> String
      -> Html
input' address action currentValue placeHolder =
  let
    msg = action >> Controller.FeelingEdit >> message address
  in
    input [ class "form-control"
          , placeholder placeHolder
          , value currentValue
          , HE.on "input" HE.targetValue msg] []

updateHow' : String -> FeelingEdit.Action
updateHow' =
  parseHowWithDefault Meh >> FeelingEdit.UpdateHow
