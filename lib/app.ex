defmodule Mtest.App do
  use Application

  def start(_type, _args) do
    {:ok, _pid} = Mtest.Sender.start_link([])
    # {:ok, _pid} = Mtest.Sender.start_link([])
    {:ok, _pid} = Mtest.Receiver.start_link(:membership)
    {:ok, _pid} = Mtest.Receiver.start_link([])
    # {:ok, _pid} = Mtest.Receiver.start_link([])
    children = []
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
