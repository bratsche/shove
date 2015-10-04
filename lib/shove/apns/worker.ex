defmodule Shove.APNS.Worker do
  use GenServer

  alias Shove.APNS.Notification
  alias Shove.APNS.Connection
  alias Shove.APNS.Serializer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(_state) do
    {:ok, nil}
  end

  def handle_call({:send_notification, %Notification{} = notification}, _from, nil = state) do
    {:ok, conn} = Connection.start(self())

    send_notification(conn, notification)

    {:reply, :ok, conn}
  end

  def handle_call({:send_notification, %Notification{} = notification}, _from, conn) when is_pid(conn) do
    send_notification(conn, notification)

    {:reply, :ok, conn}
  end

  def handle_call({:send_notification_list, notifications}, _from, nil = state) when is_list(notifications) do
    {:ok, conn} = Connection.start(self())

    send_notification_list(state, notifications)

    {:reply, :ok, conn}
  end

  def handle_call(notifications, _from, conn) when is_list(notifications) when is_pid(conn) do
    send_notification_list(conn, notifications)

    {:reply, :ok, conn}
  end

  defp send_notification(conn, %Notification{} = notification) when is_pid(conn) do
    bin = Serializer.serialize(notification)
    Connection.write(conn, bin)
  end

  defp send_notification_list(conn, list) when is_pid(conn) when is_list(list) do
    bin = Serializer.serialize(list)
    Connection.write(bin)
  end
end
