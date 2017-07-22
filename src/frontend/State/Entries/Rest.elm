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


removeEntry : Int -> Cmd Msg
removeEntry id =
    Http.send removeEntryResponse (deleteEntry id)


toggleComplete : Entry -> Cmd Msg
toggleComplete entry =
    let updatedEntry =
        { entry | isComplete = not entry.isComplete }
    in
        Http.send toggleCompleteResponse (putEntry updatedEntry)


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


removeEntryResponse : Result Error Int -> Msg
removeEntryResponse result =
    Entries.RemoveEntryResponse result
        |> Entries.MsgForModel
        |> MsgForEntries


toggleCompleteResponse : Result Error Entry -> Msg
toggleCompleteResponse result =
    Entries.ToggleCompleteResponse result
        |> Entries.MsgForModel
        |> MsgForEntries


-- REQUESTS

getEntries : Http.Request (List Entry)
getEntries =
    Http.get entriesUrl entriesDecoder


postEntry : String -> Http.Request Entry
postEntry text =
     Http.post entriesUrl (Http.jsonBody (entryEncoder text False)) entryDecoder


deleteEntry : Int -> Http.Request Int
deleteEntry id =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = entryUrl id
        , body = Http.emptyBody
        , expect = Http.expectStringResponse (\_ -> Ok id)
        , timeout = Nothing
        , withCredentials = False
        }


putEntry : Entry -> Http.Request Entry
putEntry { id, text, isComplete } =
    Http.request
        { method = "PUT"
        , headers = []
        , url = entryUrl id
        , body = Http.jsonBody (entryEncoder text isComplete)
        , expect = Http.expectJson entryDecoder
        , timeout = Nothing
        , withCredentials = False
        }


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
        (Decode.field "isComplete" Decode.bool)


-- ENCODERS

entryEncoder : String -> Bool -> Encode.Value
entryEncoder text isComplete =
    Encode.object
        [ ( "text", Encode.string text )
        , ( "isComplete", Encode.bool isComplete )
        ]

