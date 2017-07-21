module State.Entries.Rest exposing (..)

import Http exposing (Error)
import Json.Decode as Decode
import Json.Encode as Encode

import State.Types exposing (..)
import State.Entries.Types as Entries exposing (Entry)


-- COMMANDS

fetchAll : Cmd Msg
fetchAll =
    Http.send fetchAllResponse getEntries

addEntry : String -> Cmd Msg
addEntry text =
    Http.send addEntryResponse (postEntry text)


-- MSG CONTAINERS

fetchAllResponse : Result Error (List Entry) -> Msg
fetchAllResponse result =
    Entries.FetchAllResponse result
        |> Entries.MsgForModel
        |> MsgForEntries


addEntryResponse : Result Error Entry -> Msg
addEntryResponse result =
    Entries.AddEntryResponse result
        |> Entries.MsgForModel
        |> MsgForEntries


-- REQUESTS

getEntries : Http.Request (List Entry)
getEntries =
    Http.get entriesUrl entriesDecoder


postEntry : String -> Http.Request Entry
postEntry text =
     Http.post entriesUrl (Http.jsonBody (entryEncoder text False)) entryDecoder



-- RESOURCES

entriesUrl : String
entriesUrl =
    "/api/entries"


entryUrl : Int -> String
entryUrl id =
    String.join "/" [ entriesUrl, toString id ]


-- DECODERS

entriesDecoder : Decode.Decoder (List Entry)
entriesDecoder =
    Decode.list entryDecoder


entryDecoder : Decode.Decoder Entry
entryDecoder =
    Decode.map3 Entry
        (Decode.field "id" Decode.int)
        (Decode.field "text" Decode.string)
        (Decode.field "complete" Decode.bool)


-- ENCODERS

entryEncoder : String -> Bool -> Encode.Value
entryEncoder text complete =
    Encode.object
        [ ( "text", Encode.string text )
        , ( "complete", Encode.bool complete )
        ]

