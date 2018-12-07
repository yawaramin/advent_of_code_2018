defmodule AdventOfCode2018.Day4 do
  # @type log_entry {NaiveDateTime.t, String.t | :asleep | :awake}

  @first_slept {nil, 1}

  def part1(stream) do
    guard_sleeps = :ets.new(:guard_sleeps, [])

    process_entry = fn
      {%{minute: minute}, guard_id} when is_binary(guard_id) ->
        # Currently-processed guard ID and current status
        :ets.insert(guard_sleeps, {:guard_id, guard_id, :awake, minute})

      {%{minute: minute}, :asleep} ->
        [{:guard_id, guard_id, :awake, _minute}] = :ets.lookup(guard_sleeps, :guard_id)

        :ets.insert(guard_sleeps, {:guard_id, guard_id, :asleep, minute})
        :ets.update_counter(guard_sleeps, {guard_id, minute}, 1, @first_slept)
        :ets.update_counter(guard_sleeps, {guard_id, :total}, 1, @first_slept)

      {%{minute: minute}, :awake} ->
        [{:guard_id, guard_id, :asleep, fell_asleep_minute}] =
          :ets.lookup(guard_sleeps, :guard_id)

        slept_minutes = minute - fell_asleep_minute - 1

        :ets.insert(guard_sleeps, {:guard_id, guard_id, :awake, minute})
        :ets.update_counter(guard_sleeps, {guard_id, :total}, slept_minutes)

        for slept_minute <- (fell_asleep_minute + 1)..(minute - 1), slept_minutes !== 0 do
          :ets.update_counter(guard_sleeps, {guard_id, slept_minute}, 1, @first_slept)
        end
    end

    stream
    |> Stream.map(&String.replace_suffix(&1, "\n", ""))
    |> Stream.map(&parse_log_line/1)
    |> Enum.sort_by(&timestamp/1, &timestamp_compare/2)
    |> Enum.each(process_entry)

    [sleepiest_guard_id, _slept_minutes] =
      guard_sleeps
      |> :ets.match({{:"$1", :total}, :"$2"})
      |> Enum.max_by(&Enum.at(&1, 1))

    [sleepiest_minute, _days_slept] =
      guard_sleeps
      |> :ets.match({{sleepiest_guard_id, :"$1"}, :"$2"})
      |> Enum.filter(&(Enum.at(&1, 0) !== :total))
      |> Enum.max_by(&Enum.at(&1, 1))

    IO.puts(["Guard ID: ", sleepiest_guard_id, ", sleepiest minute: ", inspect(sleepiest_minute)])
  end

  def part2 do
    nil
  end

  # @spec parse_log_line(String.t) :: log_entry
  defp parse_log_line(
         <<"[", year::binary-size(4), "-", month::binary-size(2), "-", day::binary-size(2), " ",
           hour::binary-size(2), ":", minute::binary-size(2), "] ", entry::binary>>
       ) do
    {:ok, timestamp} =
      NaiveDateTime.new(
        String.to_integer(year),
        String.to_integer(month),
        String.to_integer(day),
        String.to_integer(hour),
        String.to_integer(minute),
        0
      )

    entry =
      case entry do
        "Guard #" <> guard_id -> guard_id
        "falls asleep" -> :asleep
        "wakes up" -> :awake
      end

    {timestamp, entry}
  end

  # @spec timestamp(log_entry) :: NaiveDateTime.t
  defp timestamp({result, _}), do: result

  # @spec timestamp_compare(NaiveDateTime.t, NaiveDateTime.t) :: boolean
  defp timestamp_compare(ts1, ts2) do
    case NaiveDateTime.compare(ts1, ts2) do
      :lt -> true
      :eq -> true
      :gt -> false
    end
  end
end

"day4.input" |> File.stream!() |> AdventOfCode2018.Day4.part1()
