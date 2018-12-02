defmodule AdventOfCode2018.Day1 do
  def part1 do
    frequency_changes() |> Enum.sum() |> IO.puts()
  end

  def part2 do
    curr_frequency = 0
    seen_frequencies = MapSet.new()

    frequency_changes()
    |> Stream.cycle()
    |> Enum.reduce_while({curr_frequency, seen_frequencies}, &new_frequency?/2)
    |> IO.puts()
  end

  defp frequency_changes do
    "day1.input"
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
  end

  defp new_frequency?(frequency_change, {curr_frequency, seen_frequencies}) do
    new_frequency = curr_frequency + frequency_change

    if MapSet.member?(seen_frequencies, new_frequency) do
      {:halt, new_frequency}
    else
      {:cont, {new_frequency, MapSet.put(seen_frequencies, new_frequency)}}
    end
  end
end
