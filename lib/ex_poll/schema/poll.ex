defmodule ExPoll.Schema.Poll do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, []}
  embedded_schema do
    field :text, :string

    # belongs_to :creator, ExPoll.Schema.User
    field :creator_id, :binary_id

    embeds_many :options, ExPoll.Schema.Poll.Option
  end

  @spec changeset(option :: %__MODULE__{}, attrs :: map()) :: Ecto.Changeset.t()
  def changeset(poll, attrs \\ %{}) do
    poll
    |> cast(attrs, [:text, :creator_id])
    |> validate_required([:text, :creator_id])
  end

  @spec apply(Ecto.Changeset.t(), atom()) :: map()
  def apply(changeset, action) do
    apply_action!(changeset, action)
  end
end
