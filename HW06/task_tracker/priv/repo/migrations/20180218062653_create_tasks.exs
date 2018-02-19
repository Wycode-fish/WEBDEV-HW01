defmodule TaskTracker.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :title, :string, null: false
      add :description, :text, null: false
      add :start_time, :integer, null: false
      add :end_time, :integer, default: 0
      add :is_finish, :boolean, default: false
      add :assignee_id, references(:users, on_delete: :delete_all), null: false
      add :creator_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:tasks, [:assignee_id])
    create index(:tasks, [:creator_id])
  end
end
