module Chronicle.Components.MomentEdit where

import Date
import Task
import Task exposing (Task, andThen)
import Debug exposing (log)
import Result exposing (toMaybe)

import Date
import Http
import Focus
import Focus exposing ((=>))

import Chronicle.Database as Database
import Chronicle.Data.Moment exposing (Moment, How, parseHow)
import Chronicle.Data.Moment as Moment

type alias Model =
  { editType : EditType
  , formValue : Moment
  , error : String  -- Idealy this should be a Map from field to error
  }

type EditType
    = AddNew
    | EditExisting Int

initialModel : Model
initialModel = { editType=AddNew, formValue=Moment.default, error="" }

-- Actions

type Action
  = UpdateHow String
  | UpdateWhat String
  | UpdateTrigger String
  | UpdateNotes String
  | Save
  | EditThis Moment

-- Update

update : Action -> Model -> (Model, Maybe Request)
update action model =
  case action of
    Save ->
      case model.editType of
        AddNew          ->
          (initialModel, Just <| PostgrestInsert model.formValue)
        EditExisting id ->
          (initialModel, Just <| PostgrestUpdate model.formValue id)
    EditThis moment ->
      justModel <| { initialModel | editType <- EditExisting moment.id
                                  , formValue <- moment
                                  }
    UpdateHow howString ->
      case parseHow howString |> toMaybe of
        Nothing  -> justModel <| { model | error <- "Invalid value for how" }
        Just h   -> justModel <| Focus.set (formValue => how) h model
    UpdateWhat w ->
      justModel <| Focus.set (formValue => what) w model
    UpdateTrigger t ->
      justModel <| Focus.set (formValue => trigger) t model
    UpdateNotes t ->
      justModel <| Focus.set (formValue => notes) t model

formValue = Focus.create .formValue (\f r -> { r | formValue <- f r.formValue })
how       = Focus.create .how       (\f r -> { r | how       <- f r.how })
what      = Focus.create .what      (\f r -> { r | what      <- f r.what })
trigger   = Focus.create .trigger   (\f r -> { r | trigger   <- f r.trigger })
notes     = Focus.create .notes     (\f r -> { r | notes     <- f r.notes })

justModel : Model -> (Model, Maybe Request)
justModel model =
  (model, Nothing)

-- Request

type Request
  = PostgrestInsert Moment
  | PostgrestUpdate Moment Int

-- Tasks

run : Request -> Task Http.Error String
run r =
  case r of
    PostgrestInsert moment ->
      Database.insert moment
    PostgrestUpdate moment id ->
      Database.update moment id
