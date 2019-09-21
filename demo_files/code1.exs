defmodule MyModule do
  @moduledoc """
  This is a doc description.
  """

  ### Public API
  def start_link do
    :gen_server.start_link({:local, :mymod}, __MODULE__, [], [])
  end
end

defrecord Genius, first_name: "Albert", last_name: "Einstein" do
  def name record do # huh ?
    "#{record.first_name} #{record.last_name}"
  end
end
