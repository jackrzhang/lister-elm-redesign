module App.Entries.Connector exposing (..)

import Html exposing (Html)

import State.Types exposing (..)
import State.Control.Types exposing (Filter(..))
import State.Entries.Types as Entries exposing (Entry)
import App.Entries.View exposing (..)


connector : Model -> Html Msg
connector model =
    view (connect model)


connect : Model -> Interface
connect model =
    { filteredList = filteredList model.control.filter model.entries.list
    }


-- MODEL -> INTERFACE

filteredList : Filter -> List Entry -> List Entry
filteredList filter list =
    case filter of
        All ->
            list

        Active ->
            List.filter (\entry -> entry.complete == False) list

        Complete ->
            List.filter (\entry -> entry.complete == True) list


-- MSG -> INTERFACE
