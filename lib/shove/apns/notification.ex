defmodule Shove.APNS.Notification do
  require Logger

  defstruct [
    token: nil,
    expiration: 0,
    alert: nil,
    badge: nil,
    sound: nil,
    category: nil,
    priority: 10,
    content_available: nil
  ]

  @max_payload 2048

  def payload(%Shove.APNS.Notification{} = notification) do
    # Don't allow alerts, sounds, or badges with silent notifications or
    # Apple may throttle us.
    aps =
      if notification.content_available do
        %{'content-available': 1}
        |> add_to_aps(:category, notification.category)
      else
        %{ alert: notification.alert }
        |> add_to_aps(:badge, notification.badge)
        |> add_to_aps(:sound, notification.sound)
        |> add_to_aps(:category, notification.category)
      end

    Poison.encode!(%{aps: aps})
  end

  defp add_to_aps(aps, :'content-available' = key, value) do
    case value do
      1 ->
        if aps[:sound] == nil do
          Map.put(:sound, "")
          |> Map.put(key, value)
        else
        end
      _ -> aps
    end
  end

  defp add_to_aps(aps, key, value) do
    case value do
      nil -> aps
      _   -> Map.put(key, value)
    end
  end
end
