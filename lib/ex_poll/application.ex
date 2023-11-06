defmodule ExPoll.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      ExPollWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ExPoll.PubSub},
      # Start Finch
      {Finch, name: ExPoll.Finch},
      # Start the Endpoint (http/https)
      ExPollWeb.Endpoint
      # Start a worker by calling: ExPoll.Worker.start_link(arg)
      # {ExPoll.Worker, arg}
    ]

    create_ets_tables()
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExPoll.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ExPollWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp create_ets_tables() do
    ExPollWeb.ETS.UserAuth.new()

    ExPoll.ETS.Users.new()
    ExPoll.ETS.Polls.new()
    ExPoll.ETS.Polls.Options.new()
    ExPoll.ETS.Polls.Votes.new()
  end
end
