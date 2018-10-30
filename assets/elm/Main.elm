module Main exposing (main)

import Browser
import Html exposing (Html, button, div, h1, input, label, li, p, table, td, text, th, tr, ul)
import Html.Attributes exposing (for, id)
import Html.Events exposing (onClick, onInput)
import Time exposing (now)


type alias Model =
    { count : Int
    , books : List Book
    , time : String
    , pages : Int
    , newBook : Book
    , timerStatus : TimerStatus
    , bookPanelStatus : BookPanelStatus
    , seconds : Int
    }


type alias Book =
    { title : String
    , author : String
    , pages : Int
    , entries : List Entry
    , status : Status
    }


initBook =
    Book "" "" 0 [] Closed


type Status
    = Open
    | Closed


type BookPanelStatus
    = BookPanelOpen
    | BookPanelClosed


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
    , newBook = initBook
    , timerStatus = Stopped
    , bookPanelStatus = BookPanelClosed
    , seconds = 0
    }


init flags =
    ( initialModel, Cmd.none )


type Msg
    = UpdateEntryTime String
    | UpdateEntryPages String
    | UpdateBookTitle String
    | UpdateBookAuthor String
    | UpdateBookPages String
    | SaveBook
    | OpenEntryPanel String
    | ToggleBookPanel
    | StartTimer
    | StopTimer
    | SaveEntry String
    | Tick Time.Posix
    | AddBook


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    (case msg of
        ToggleBookPanel ->
            { model
                | bookPanelStatus =
                    case model.bookPanelStatus of
                        BookPanelOpen ->
                            BookPanelClosed

                        BookPanelClosed ->
                            BookPanelOpen
            }

        SaveEntry title ->
            { model | books = model |> updateBooks title }
                |> stopTimer

        OpenEntryPanel title ->
            { model | books = model.books |> openBook title }

        UpdateEntryTime time ->
            { model | time = time }

        StartTimer ->
            model |> startTimer

        StopTimer ->
            model |> stopTimer

        UpdateEntryPages pages ->
            { model
                | pages =
                    pages
                        |> String.toInt
                        |> Maybe.withDefault 0
            }

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

        UpdateBookTitle title ->
            let
                newBook =
                    model.newBook
            in
                { model | newBook = { newBook | title = title } }

        UpdateBookAuthor author ->
            let
                newBook =
                    model.newBook
            in
                { model | newBook = { newBook | author = author } }

        UpdateBookPages pages ->
            let
                newBook =
                    model.newBook
            in
                { model | newBook = { newBook | pages = pages |> String.toInt |> Maybe.withDefault 0 } }

        SaveBook ->
            { model | books = addBook model.newBook.title model.newBook.author :: model.books }
    )
        |> (\x -> ( x, Cmd.none ))


startTimer model =
    { model | timerStatus = Running }


stopTimer model =
    { model | timerStatus = Stopped }


addBook title author =
    Book title author 0 [] Closed


updateBooks : String -> Model -> List Book
updateBooks title model =
    model.books
        |> List.map
            (\book ->
                (if book.title == title then
                    { book
                        | entries =
                            List.append
                                book.entries
                                [ createEntry model ]
                    }
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
        [ h1 [] [ text "Book Buddy" ]
        , renderTable model.books
        , renderEntryPanel model
        , div [] [ model.seconds |> String.fromInt |> text ]
        , button [ onClick ToggleBookPanel ] [ text "Add a book" ]
        , renderBookPanel model.bookPanelStatus
        ]


renderTable books =
    renderTableHeader
        :: renderRows books
        |> table []


renderTableHeader =
    tr
        []
        [ th [] [ text "Title" ]
        , th [] [ text "Author" ]
        ]


renderRows books =
    books |> List.map (\book -> book |> renderCells |> tr [])


renderCells book =
    [ td [] [ text book.title ]
    , td [] [ text book.author ]
    , td [] [ book.pages |> String.fromInt |> text ]
    , td [] [ renderEntries book.entries ]
    , td []
        [ button [ onClick (OpenEntryPanel book.title) ] [ text "log some time" ]
        ]
    ]


renderEntries entries =
    entries
        |> List.map (\entry -> li [] [ renderEntry entry ])
        |> ul []


renderEntry entry =
    p []
        [ Html.span [] [ entry.time |> String.fromInt |> text ]
        , Html.span [] [ text " | " ]
        , Html.span [] [ entry.pages |> String.fromInt |> text ]
        ]


createEntry model =
    Entry model.seconds model.pages


renderBookPanel status =
    case status of
        BookPanelClosed ->
            div [] []

        BookPanelOpen ->
            div []
                [ p []
                    [ label [ for "new-book-title" ] [ text "Title" ]
                    , input [ id "new-book-title", onInput UpdateBookTitle ] []
                    ]
                , p []
                    [ label [ for "new-book-author" ] [ text "Author" ]
                    , input [ id "new-book-author", onInput UpdateBookAuthor ] []
                    ]
                , p []
                    [ label [ for "new-book-pages" ] [ text "Number of Pages" ]
                    , input [ id "new-book-author", onInput UpdateBookPages ] []
                    ]
                , button [ onClick SaveBook ] [ text "save" ]
                ]


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
                [ p []
                    [ label [ for "entry-pages" ] [ text "Number of Pages" ]
                    , input [ id "entry-pages", onInput UpdateEntryPages ] []
                    ]
                , p []
                    [ label [ for "entry-time" ] [ text "Time (Seconds" ]
                    , input [ id "entry-time" ] [ model.seconds |> String.fromInt |> text ]
                    ]
                , button [ onClick StartTimer ] [ text "start timer" ]
                , button [ onClick StopTimer ] [ text "stop timer" ]
                , button [ onClick (SaveEntry title) ] [ text "save" ]
                ]


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
