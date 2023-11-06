defmodule ExPoll.Schema.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  embedded_schema do
    field :username, :string
  end

  @spec changeset(option :: %__MODULE__{}, attrs :: map()) :: Ecto.Changeset.t()
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:username])
    |> validate_required([:username])
  end

  @spec apply(Ecto.Changeset.t(), atom()) :: map()
  def apply(changeset, action) do
    apply_action!(changeset, action)
  end
end
