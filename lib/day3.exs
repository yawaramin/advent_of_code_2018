defmodule AdventOfCode2018.Day3 do
  @moduledoc """
  In this module all references to 'inches' mean 'square inches'.
  """

  @claim_regex ~r/^#\d+ @ (\d+),(\d+): (\d+)x(\d+)$/

  # 109785
  def part1, do: overlapping_claimed_inches() |> MapSet.size() |> IO.puts()

  # 504
  def part2 do
    overlapping_claimed_inches = overlapping_claimed_inches()

    not_overlapping? = fn claim ->
      claim |> claim_inches |> MapSet.disjoint?(overlapping_claimed_inches)
    end

    input() |> Enum.find(not_overlapping?) |> IO.puts()
  end

  defp overlapping_claimed_inches do
    {_all_claimed_inches, result} =
      input()
      |> Stream.map(&claim_inches/1)
      |> Enum.reduce({MapSet.new(), MapSet.new()}, &process_claim/2)

    result
  end

  defp input, do: "day3.input" |> File.stream!() |> Stream.map(&String.trim/1)

  defp claim_inches(claim) do
    [_claim, left_inches, top_inches, width, height] = Regex.run(@claim_regex, claim)

    left_inch = String.to_integer(left_inches) + 1
    top_inch = String.to_integer(top_inches) + 1
    width = String.to_integer(width)
    height = String.to_integer(height)

    for x <- left_inch..(left_inch + width - 1),
        y <- top_inch..(top_inch + height - 1),
        into: MapSet.new() do
      {x, y}
    end
  end

  defp process_claim(claim_inches, {all_claimed_inches, overlapping_claimed_inches}) do
    {
      # Add a new claim's inches to the current set of all claimed inches
      MapSet.union(all_claimed_inches, claim_inches),

      # Check if any of the new claim's inches have been claimed before
      # and if so add them to the current set of all _overlapping_
      # claimed inches
      claim_inches
      |> MapSet.intersection(all_claimed_inches)
      |> MapSet.union(overlapping_claimed_inches)
    }
  end
end

# AdventOfCode2018.Day3.part1()
AdventOfCode2018.Day3.part2()
