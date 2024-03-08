defmodule Mtest.Receiver do
  use GenServer

  require Logger

  # 224.0.0.0 - 239.255.255.255
  @multicast_addr {{227, 1, 1, 1}, 12345}

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl true
  def init(args) do
    Logger.info("#{inspect(self())} Starting receiver")

    Process.send_after(self(), :print_cnt, 1000)

    opts =
      if args == :membership do
        Logger.info("Adding membership")
        [add_membership: {{227, 1, 1, 1}, {0, 0, 0, 0}}]
      else
        Logger.info("Not adding membership")
        [add_membership: {{227, 1, 1, 2}, {0, 0, 0, 0}}]

        # []
      end

    opts = [reuseport: true] ++ opts

    # use reuseport to be able to spawn multiple receivers
    # {:ok, socket} = :gen_udp.open(12345, reuseaddr: true, reuseport: true)
    {:ok, socket} =
      :gen_udp.open(
        12345,
        opts
        # multicast_loop: false,
        # reuseport: true
        # add_membership: {{227, 1, 1, 1}, {0, 0, 0, 0}}
        # add_membership: {{227, 1, 1, 2}, {0, 0, 0, 0}}
      )

    {:ok, %{socket: socket, cnt: 0}}
  end

  @impl true
  def handle_info(:print_cnt, state) do
    Process.send_after(self(), :print_cnt, 1000)
    Logger.info("#{inspect(self())} Received: #{state.cnt}")
    {:noreply, state}
  end

  @impl true
  def handle_info(_msg, state) do
    # :gen_udp.send(state.socket, @multicast_addr, <<4, 3, 2, 1, 0>>)
    {:noreply, %{state | cnt: state.cnt + 1}}
  end
end
