defmodule AdventOfCode2018.Day2 do
  def part1 do
    {box_id_repeats_2, box_id_repeats_3} =
      input()
      |> Stream.map(&letter_repeats/1)
      |> Enum.reduce({0, 0}, &sum_repeat_counts/2)

    IO.puts(box_id_repeats_2 * box_id_repeats_3)
  end

  def part2 do
    boxids = Stream.map(input(), &String.trim/1)

    for boxid_1 <- boxids,
        boxid_2 <- boxids,
        boxid_1 < boxid_2,
        diff = String.myers_difference(boxid_1, boxid_2),
        one_char_diff?(diff) do
      diff |> Keyword.get_values(:eq) |> IO.puts()
    end
  end

  defp input, do: File.stream!("day2.input")

  # Returns a pair indicating how many letters in the input word repeat
  # _twice_ and how many repeat _thrice._
  defp letter_repeats(word) do
    counts =
      word
      |> String.to_charlist()
      |> Enum.reduce(%{}, &increment_char_count/2)
      |> Map.values()

    {2 in counts, 3 in counts}
  end

  defp sum_repeat_counts({repeats_twice, repeats_thrice}, {sum_2_repeats, sum_3_repeats}) do
    {
      sum_2_repeats + boolean_to_int(repeats_twice),
      sum_3_repeats + boolean_to_int(repeats_thrice)
    }
  end

  # Check that one character was inserted and one removed (anywhere) in
  # the diff.

  defp one_char_diff?(eq: _string, del: <<_char1>>, ins: <<_char2>>), do: true
  defp one_char_diff?(del: <<_char1>>, ins: <<_char2>>, eq: _string), do: true
  defp one_char_diff?(eq: _string1, del: <<_char1>>, ins: <<_char2>>, eq: _string2), do: true
  defp one_char_diff?(_else), do: false

  defp increment_char_count(char, char_map) do
    Map.update(char_map, char, 1, &(&1 + 1))
  end

  defp boolean_to_int(true), do: 1
  defp boolean_to_int(false), do: 0
end
