defmodule ExPoll.Schema.Poll.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  embedded_schema do
    # belongs_to :user, ExPoll.Schema.User
    field :user_id, :binary_id

    # belongs_to :poll, ExPoll.Schema.Poll
    field :poll_id, :binary_id

    # belongs_to :option, ExPoll.Schema.Poll.Option
    field :option_id, :binary_id
  end

  @spec changeset(option :: %__MODULE__{}, attrs :: map()) :: Ecto.Changeset.t()
  def changeset(vote, attrs \\ %{}) do
    vote
    |> cast(attrs, [:user_id, :poll_id, :option_id])
    |> validate_required([:user_id, :poll_id, :option_id])
  end

  @spec apply(Ecto.Changeset.t(), atom()) :: map()
  def apply(changeset, action) do
    apply_action!(changeset, action)
  end
end
