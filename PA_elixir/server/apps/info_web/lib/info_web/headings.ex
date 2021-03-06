# info_web/headings.ex

defmodule InfoWeb.Headings do
#
# Public functions
#
#   do_headings/2
#     Process heading tuples from the parsed page (aka HTML tree).
#
# Private functions

  @moduledoc """
  This module handles checking (etc) of headings for `InfoWeb.Internal`.
  """

  import Common.Tracing, only: [ii: 2], warn: false

  # Public functions

  @doc """
  Process heading tuples from the parsed page (aka HTML tree).
  """

  @spec do_headings(ht, String.t) :: ht
    when ht: Floki.html_tree

  def do_headings(html_tree, page_url) do

#   ii(html_tree, :html_tree) #!T
    ii(page_url,  :page_url) #!T

    selector  = "h1, h2, h3, h4, h5, h6"

    html_tree
    |> Floki.find(selector)       # [ { "h1", [], [" Pete's Alley"] }, ... ]
    |> check_headings(page_url)

    html_tree
  end

  # Private functions

  @spec check_headings(ht, String.t) :: ht
    when ht: Floki.html_tree

  defp check_headings(headings, page_url) do
  #
  # Report ordering problems with headings.
  #
  # At present, we only check for headings that go up more than one level.

    reduce_fn    = fn {tag, _attrs, body}, {prev_level, messages} ->
    #
    # Accumulate a list of diagnostic messages.

      this_level  = tag
      |> String.replace_prefix("h", "")
      |> String.to_integer()

      if false do #!G
        IO.puts ""
        ii(body,        :body)
        ii(messages,    :messages)
        ii(prev_level,  :prev_level)
        ii(tag,         :tag)
        ii(this_level,  :this_level)
      end

      messages    = if this_level > prev_level+1 do
        message   = "Heading level jump from #{ prev_level } " <>
                    "to #{ this_level }, text: '#{ body }'"

        [ message | messages ]
      else
        messages
      end

      {this_level, messages}
    end

    pattern   = ~r{^ .*/ s_\w+ \.toml $}x

    unless page_url =~ pattern do
      base_acc  = { 0, [] }

      {_level, messages}  = headings
      |> Enum.reduce(base_acc, reduce_fn)

      if !Enum.empty?(messages) do
        msg_str   = messages
        |> Enum.reverse
        |> Enum.join("\n  ")

        IO.puts "\n>>> #{ page_url }"
        IO.puts "  #{ msg_str }"
      end
    end

    headings
  end

end
