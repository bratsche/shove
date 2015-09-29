# Binary interface and notification format
# https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/CommunicatingWIthAPS.html#//apple_ref/doc/uid/TP40008194-CH101-SW1

defmodule Shove.APNS.Serializer do
  alias Shove.APNS.Notification
  alias Shove.APNS.Counter

  def serialize(%Notification{} = notification) do
    notification
    |> build_frame
    |> build_packet
  end

  def serialize(notifications) when is_list(notifications) do
    notifications
    |> build_frame
    |> build_packet
  end

  defp build_frame(%Notification{} = notification) do
    {:ok, token} = Base.decode16(notification.token, case: :mixed)
    payload = Notification.payload(notification)
    id = Counter.next

    <<
      1::size(8),    32::size(16),                 token::binary,
      2::size(8),    byte_size(payload)::size(16), payload::binary,
      3::size(8),    4::size(16),                  id::size(32),
      4::size(8),    4::size(16),                  notification.expiration::size(32),
      5::size(8),    1::size(16),                  notification.priority::size(8)
    >>
  end

  defp build_frame(notifications, index \\ 0, binary \\ << >>) when is_list(notifications) do
    [current|remaining] = notifications

    bin = build_frame(current)

    case remaining do
      [] -> binary <> bin
      _  -> build_frame(remaining, index + 1, binary <> bin)
    end
  end

  defp build_packet(frame) do
    <<
      2                :: size(8),
      byte_size(frame) :: size(32),
      frame            :: binary
    >>
  end
end
