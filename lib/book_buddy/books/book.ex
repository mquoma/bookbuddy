defmodule BookBuddy.Books.Book do
  use Ecto.Schema
  import Ecto.Changeset


  schema "books" do
    field :name, :string
    field :pages, :integer
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:name, :title, :pages])
    |> validate_required([:name, :title, :pages])
  end
end
