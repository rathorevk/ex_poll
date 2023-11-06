defmodule ExPollWeb.Live.Helper do
  def signing_salt do
    ExPollWeb.Endpoint.config(:live_view)[:signing_salt] ||
      raise "missing signing_salt"
  end
end
