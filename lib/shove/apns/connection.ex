defmodule Shove.APNS.Connection do
  use GenServer
  require Logger

  alias Shove.APNS.Notification

  def start(options \\ []) do
    config = Application.get_all_env(:shove)[:apns]
    state = %{
      config: config,
      push_socket: nil,
      feedback_socket: nil,
      options: options
    }

    :ssl.start()

    {:ok, pid} = GenServer.start_link(__MODULE__, state)

    GenServer.call(pid, :connect_push)

    {:ok, pid}
  end

  def close_push(pid) do
    GenServer.call(pid, :close_push)
    {:ok, pid}
  end

  def write(pid, bin) do
    GenServer.call(pid, {:write, bin})
    {:ok, pid}
  end

  def handle_info({:ssl_closed, socket}, %{push_socket: socket} = state) do
    Logger.info("[APNS] Lost push connection")
    {:stop, :normal, state}
  end

  def handle_info({:ssl_closed, socket}, %{feedback_socket: socket} = state) do
  end

  def handle_call(:connect_push, _from, %{config: config} = state) do
    host = to_char_list(config[:push_host])
    port = config[:push_port]

    Logger.info("[APNS] Connecting to #{host}:#{port}")

    socket =
      case :ssl.connect(host, port, ssl_options(config), config[:timeout]) do
        {:ok, socket} ->
          Logger.info("[APNS] Connected")
          socket
        {:error, reason} ->
          Logger.info("[APNS] Failed (#{inspect reason})")
          nil
      end

    {:reply, :ok, %{state | push_socket: socket}}
  end

  def handle_call(:close_push, _from, %{push_socket: push_socket} = state) do
    :ssl.close(push_socket)

    {:reply, :ok, %{state | push_socket: nil}}
  end

  def handle_call({:write, bin}, _from, %{push_socket: push_socket} = state) do
    Logger.debug("[APNS] Writing data for #{inspect push_socket}")

    :ssl.send(push_socket, bin)

    {:reply, :ok, state}
  end

  def terminate(reason, %{push_socket: nil}) do
  end

  def terminate(reason, %{push_socket: push_socket} = state) do
    :ssl.close(push_socket)
  end

  defp ssl_options(config) do
    [certfile: config[:certfile], reuse_sessions: false, mode: :binary]
  end
end
