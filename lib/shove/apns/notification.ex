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

  def payload(%Shove.APNS.Notification{alert: alert} = notification) do
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

    aps_json = Jason.encode!(%{aps: aps})

    # If the payload is too big then re-generate it with a truncated alert
    case byte_size(aps_json) - @max_payload do
      n when n > 0 ->
        Logger.warn("[APNS] Payload exceeded limit of #{@max_payload}, truncating alert by #{n} bytes.")
        payload(%{notification | alert: String.slice(alert, 0, String.length(alert) - n)})
      _ ->
        aps_json
    end
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
