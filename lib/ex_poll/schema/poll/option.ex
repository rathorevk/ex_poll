defmodule ExPoll.Schema.Poll.Option do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  embedded_schema do
    field :text, :string
    field :vote_count, :integer, default: 0

    ## belongs_to :poll, ExPoll.Schema.Poll
    field :poll_id, :binary_id
  end

  @spec changeset(option :: %__MODULE__{}, attrs :: map()) :: Ecto.Changeset.t()
  def changeset(option, attrs \\ %{}) do
    option
    |> cast(attrs, [:text, :vote_count, :poll_id])
    |> validate_required([:text, :vote_count, :poll_id])
  end

  @spec apply(Ecto.Changeset.t(), atom()) :: map()
  def apply(changeset, action) do
    apply_action!(changeset, action)
  end
end
