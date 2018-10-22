defmodule BookBuddy.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :name, :string
      add :title, :string
      add :pages, :integer

      timestamps()
    end

  end
end
