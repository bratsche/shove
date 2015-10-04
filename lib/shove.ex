defmodule Shove do
  use Application

  alias Shove.APNS.Notification

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    apns_pool_options = [
      name: {:local, :apns_pool},
      worker_module: Shove.APNS.Worker,
      size: 5,
      max_overflow: 15
    ]

    children = [
      :poolboy.child_spec(:apns_pool, apns_pool_options, []),
      worker(Shove.APNS.Counter, [])
    ]

    opts = [strategy: :one_for_one, name: Shove.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def notify_apns(%Notification{} = notification) do
    :poolboy.transaction(:apns_pool, fn(pid) -> GenServer.call(pid, {:send_notification, notification}) end)
  end

  def notify_apns(options) when is_map(options) do
    notification = struct(Notification, options)

    notify_apns(notification)
  end

  def notify_apns(keywords) when is_list(keywords) do
    notification = struct(Notification, keywords)

    notify_apns(notification)
  end

  def notify_apns(notifications) when is_list(notifications) do
    :poolboy.transaction(:apns_pool, fn(pid) -> GenServer.call(pid, {:send_notification_list, notifications}) end)
  end
end
