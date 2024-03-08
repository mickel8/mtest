defmodule Mtest.Sender do
  use GenServer

  require Logger

  # 224.0.0.0 - 239.255.255.255
  @multicast_addr {{227, 1, 1, 1}, 12345}
  @multicast_addr2 {{227, 1, 1, 2}, 12345}
  # @multicast_addr {{192, 168, 83, 24}, 12345}

  def start_link(args) do
    Logger.info("Starting sender")
    GenServer.start_link(__MODULE__, args)
  end

  @impl true
  def init(_args) do
    Process.send_after(self(), :send_multicast, 1000)

    {:ok, socket} = :gen_udp.open(12345, reuseport: true)

    {:ok, %{socket: socket, cnt: 0}}
  end

  @impl true
  def handle_info(:send_multicast, state) do
    Process.send_after(self(), :send_multicast, 1000)
    cnt = 1

    Enum.each(0..(cnt - 1), fn _ ->
      :ok = :gen_udp.send(state.socket, @multicast_addr, <<0, 1, 2, 3, 4>>)
      :ok = :gen_udp.send(state.socket, @multicast_addr2, <<0, 1, 2, 3, 4>>)
    end)

    state = %{state | cnt: state.cnt + 2 * cnt}
    Logger.info("Sent: #{state.cnt}")
    {:noreply, state}
  end

  @impl true
  def handle_info(msg, state) do
    Logger.info("#{inspect(self())} #{inspect(msg)}")
    {:noreply, state}
  end
end
