# info_toml/common.ex

defmodule InfoToml.Common do
#
# Public functions
#
#   exp_prefix/1
#     Expand prefixes (e.g., `cat_har|`, `ext_wp|`).
#   get_area_name/1
#     Get the name of an Area, given a key in it.
#   get_file_abs/1
#     Convert a relative TOML file path into an absolute path.
#   get_map_key/1
#     Convert a relative TOML file path into a map key.
#   get_tree_abs/0
#     Calculate the absolute path to PA_toml.
#
# Private functions
#
#   exp_map/0
#     Retrieves a map of prefix expansions.

  @moduledoc """
  This module contains general purpose functions and macros.
  """

  import Common, only: [ ii: 2 ]

  # Public functions

  @doc """
  Expand prefixes (e.g., `"cat_har|"`, `"ext_wp|"`), as used in our TOML.

      iex> exp_prefix("ext_gh|foo/bar")
      "https://github.com/foo/bar"

      iex> exp_prefix("cat_har|Anova_PC")
      "Areas/Catalog/Hardware/Anova_PC"

      iex> exp_prefix("[Anova PC](cat_har|Anova_PC)")
      "[Anova PC](Areas/Catalog/Hardware/Anova_PC)"
  """

  @spec exp_prefix(st) :: st
    when st: String.t

  def exp_prefix(inp_str) do
  #
  # Traverse a list of expansion tuples, replacing prefixes in `inp_str`.

    exp_list  = exp_map() |> Map.to_list()
    prefix_fn = fn {inp, out}, acc ->
    #
    # Expand all uses of a prefix in the input string.

      String.replace(acc, "#{ inp }|", out)
    end

    Enum.reduce(exp_list, inp_str, prefix_fn)
  end

  @doc """
  Get the name of an Area, given a key in it.
  """

  @spec get_area_name(st) :: st
    when st: String.t

  def get_area_name(key) do
    pattern   = ~r{ ^ .* / ( \w+ ) / [^/]+ $ }x
    String.replace(key, pattern, "\\1")
  end

  @doc """
  Convert a relative TOML file path into an absolute path.

      iex> fa = get_file_abs("foo")
      iex> fa =~ ~r{ ^ / .* / PA_all .* / PA_toml / foo $ }x
      true
  """

  @spec get_file_abs(st) :: st
    when st: String.t

  def get_file_abs(file_rel), do: "#{ get_tree_abs() }/#{ file_rel }"

  @doc """
  Convert a relative TOML file path into a map key, removing any
  alphabetical sharding directories (e.g., `"/A_/"`).
  """

  @spec get_map_key(st) :: st
    when st: String.t

  def get_map_key(file_rel) do
    pattern   = ~r{/[0-9A-Za-z]+_/}
    Regex.replace(pattern, file_rel, "/")
  end

  @doc """
  Get the absolute file path for the TOML tree.
  
      iex> tree_abs = get_tree_abs()
      iex> tree_abs =~ ~r{ ^ / .* / PA_all .* / PA_toml $ }x
      true
  """

  @spec get_tree_abs() :: String.t

  def get_tree_abs() do
  #
  # Calculate and return the absolute path to PA_toml.
  #
  # Note: This function must precede the get_file_abs/0 definition!

    offset    = String.duplicate("/..", 7)
    tree_rel  = "#{ __ENV__.file }#{ offset }/PA_toml"
    Path.expand(tree_rel)
  end

  # Private functions

  @spec exp_map() :: %{ atom => String.t }

  defp exp_map(), do: [:prefix] |> InfoToml.get_part()
  #
  # Return a map of prefix expansions.

end
