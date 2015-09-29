defmodule Shove.APNS.Counter do
  @maxint32 4294967295

  def start_link do
    Agent.start_link(fn -> 0 end, name: :shovel_apns_counter)
  end

  def next do
    Agent.get_and_update(:shovel_apns_counter, fn(n) ->
      case n do
        @maxint32 -> {0, 0}
        _ -> {n + 1, n + 1}
      end
    end)
  end
end
