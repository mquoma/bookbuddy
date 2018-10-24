module Main exposing (main)

import Browser
import Html exposing (Html, button, div, text)
import Html.Attributes
import Html.Events exposing (onClick, onInput)
import Time exposing (now)


type alias Model =
    { count : Int
    , books : List Book
    , time : String
    , pages : Int
    , timerStatus : TimerStatus
    , seconds : Int
    }


type alias Book =
    { title : String
    , author : String
    , pages : Int
    , entries : List Entry
    , status : Status
    }


type Status
    = Open
    | Closed


type TimerStatus
    = Running
    | Stopped


type alias Entry =
    { time : Int
    , pages : Int
    }


initialModel : Model
initialModel =
    { count = 0
    , books =
        [ Book "Harry Potter" "JK Rowling" 500 [] Closed
        , Book "The Stand" "Stephen King" 680 [] Closed
        ]
    , time = ""
    , pages = 0
    , timerStatus = Stopped
    , seconds = 0
    }


init flags =
    ( initialModel, Cmd.none )


type Msg
    = UpdateEntryTime String
    | UpdateEntryPages String
    | OpenEntryPanel String
    | StartTimer
    | StopTimer
    | Log String
    | Tick Time.Posix
    | AddBook


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    (case msg of
        Log title ->
            { model | books = model |> updateBook title }

        OpenEntryPanel title ->
            { model | books = model.books |> openBook title }

        UpdateEntryTime time ->
            { model | time = time }

        StartTimer ->
            { model | timerStatus = Running }

        StopTimer ->
            { model | timerStatus = Stopped }

        UpdateEntryPages pages ->
            { model | pages = pages |> String.toInt |> Maybe.withDefault 0 }

        Tick time ->
            { model
                | seconds =
                    case model.timerStatus of
                        Running ->
                            model.seconds + 1

                        _ ->
                            model.seconds
            }

        AddBook ->
            model
    )
        |> (\x -> ( x, Cmd.none ))


updateBook : String -> Model -> List Book
updateBook title model =
    model.books
        |> List.map
            (\book ->
                (if book.title == title then
                    { book | entries = List.append book.entries [ createEntry model ] }
                 else
                    book
                )
                    |> closeEntryPanel
            )


closeEntryPanel : Book -> Book
closeEntryPanel book =
    { book | status = Closed }


openBook title books =
    books
        |> List.map
            (\book ->
                if book.title == title then
                    { book | status = Open }
                else
                    { book | status = Closed }
            )


view : Model -> Html Msg
view model =
    div []
        [ Html.h1 [] [ text "Book Buddy" ]
        , renderTable model.books
        , renderEntryPanel model
        , Html.h4 [] [ model.seconds |> String.fromInt |> text ]
        , Html.button [ onClick AddBook ] [ text "Add a book" ]
        ]


renderTable books =
    books
        |> renderRows
        |> Html.table []


renderRows books =
    books |> List.map (\book -> book |> renderCells |> Html.tr [])


renderCells book =
    [ Html.td [] [ text book.title ]
    , Html.td [] [ text book.author ]
    , Html.td [] [ book.pages |> String.fromInt |> text ]
    , Html.td [] [ renderEntries book.entries ]
    , Html.td []
        [ Html.button [ onClick (OpenEntryPanel book.title) ] [ text "log some time" ]
        ]
    ]


renderEntries entries =
    entries
        |> List.map (\entry -> Html.li [] [ renderEntry entry ])
        |> Html.ul []


renderEntry entry =
    Html.tr []
        [ Html.td [] [ entry.time |> String.fromInt |> text ]
        , Html.td [] [ entry.pages |> String.fromInt |> text ]
        ]
        |> List.singleton
        |> Html.table []


createEntry model =
    Entry model.seconds model.pages


renderEntryPanel model =
    let
        title =
            model.books
                |> List.filter (\book -> book.status == Open)
                |> List.head
                |> Maybe.map .title
                |> Maybe.withDefault ""
    in
        if title == "" then
            div [] []
        else
            div []
                [ Html.label [] []
                , Html.input [ onInput UpdateEntryPages ] []
                , Html.input [ Html.Attributes.id "entry-time" ] [ model.seconds |> String.fromInt |> text ]
                , Html.button [ onClick StartTimer ] [ text "start timer" ]
                , Html.button [ onClick StopTimer ] [ text "stop timer" ]
                , Html.button [ onClick (Log title) ] [ text "commit" ]
                ]


renderBookPanel =
    div [] []


document model =
    { title = "Book Buddy"
    , body = [ view model ]
    }


subscriptions model =
    Time.every 1000 Tick


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = document
        , update = update
        , subscriptions = subscriptions
        }
