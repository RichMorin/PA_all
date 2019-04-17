defmodule InfoToml.Common do
#
# Macros
#
#   exp_map/0 do
#     Generates a Map of prefix expansions from `_config/prefix.toml`.
#   get_tree_abs/0
#     Calculate the absolute path to PA_toml.
#
# Public functions
#
#   exp_prefix/1
#     Expand prefixes (e.g., `cat_har|`, `ext_wp|`).
#   get_area_key/1
#     Return the most relevant area key, given a bogus item key.
#   get_file_abs/1
#     Convert a relative TOML file path into an absolute path.

  @moduledoc """
  This module contains general purpose functions and macros.
  """

  use InfoToml.Types

  # Macros

  @spec exp_map() :: %{ atom => String.t }

  defmacrop exp_map() do
  #
  # Generates a Map of prefix expansions from `_config/prefix.toml`.

    quote do
      "_config/prefix.toml"
      |> get_file_abs                     # "/.../_config/prefix.toml"
      |> InfoToml.Parser.parse(:atoms)    # %{ meta: %{...}, ... }
      |> Map.get(:prefix)                 # %{ ext_wp: "...", ... }
    end
  end

  # Public functions

  @doc """
  This function handles redirects for unrecognized item keys in a graceful
  manner.  (It is only made public to allow testing.)

  Because we are able to inspect our internal URLs for validity, we should
  not be generating URLs that contain invalid keys.  However, there are at
  least two scenarios in which an invalid key might be used:

  - A key has been changed and an obsolete URL is being used.
  - The user has tried to edit a URL, guessing at the ID.

  This function examines the item key and generates an area key for the most
  specific level it can find.
  
      iex> get_area_key("XYZ/main.toml")
      "Areas/_area.toml"

      iex> get_area_key("Areas/X/Y/Z/main.toml")
      "Areas/_area.toml"

      iex> get_area_key("Areas/Catalog/Y/Z/main.toml")
      "Areas/Catalog/_area.toml"

      iex> get_area_key("Areas/Catalog/Groups/Z/main.toml")
      "Areas/Catalog/Groups/_area.toml"
  """

  @spec get_area_key(s) :: s when s: String.t

  def get_area_key(key) do

    pattern   = ~r{ ^ Areas / ([^/]+) / ([^/]+) / [^/]+ / [^/]+ $ }x
    matches   = Regex.run(pattern, key, capture: :all_but_first)
    key_1     = "Areas/_area.toml"

    if matches do
      tmp_3   = Enum.join(matches, "/")
      key_3   = "Areas/#{ tmp_3       }/_area.toml"
      key_2   = "Areas/#{ hd(matches) }/_area.toml"

      cond do
        InfoToml.get_item(key_3)  -> key_3    # Areas/Foo/Bar
        InfoToml.get_item(key_2)  -> key_2    # Areas/Foo
        true                      -> key_1    # Areas
      end
    else
      key_1
    end
  end

  @doc """
  Get the absolute file path for the TOML tree.
  
      iex> ta = get_tree_abs()
      iex> ta =~ ~r{ ^ / .* / PA_all / PA_toml $ }x
      true
  """

  @spec get_tree_abs() :: String.t

  defmacro get_tree_abs() do
  #
  # Calculate the absolute path to PA_toml, then generate a hard-coded
  # function to return it.
  #
  # Note: This defmacro must precede the get_file_abs/0 definition!

    offset    = String.duplicate("/..", 7)
    tree_rel  = "#{ __ENV__.file }#{ offset }/PA_toml"
    Path.expand(tree_rel)
  end

  # Public functions

  @doc """
  Expand prefixes (e.g., `cat_har|`, `ext_wp|`), as used in our TOML.

    iex> exp_prefix("ext_gh|foo/bar")
    "https://github.com/foo/bar"

    iex> exp_prefix("cat_har|Anova_PC")
    "Areas/Catalog/Hardware/Anova_PC"

    iex> exp_prefix("[Anova PC](cat_har|Anova_PC)")
    "[Anova PC](Areas/Catalog/Hardware/Anova_PC)"
  """

  @spec exp_prefix(s) :: s when s: String.t

  def exp_prefix(inp_str) do
  #
  # Traverse a list of expansion tuples, replacing prefixes in inp_str.

    exp_list  = exp_map() |> Map.to_list()

    reduce_fn = fn { inp, out }, acc ->
      String.replace(acc, "#{ inp }|", out)
    end

    Enum.reduce(exp_list, inp_str, reduce_fn)
  end

  @doc """
  Convert a relative TOML file path into an absolute path.

      iex> fa = get_file_abs("foo")
      iex> fa =~ ~r{ ^ / .* / PA_all / PA_toml / foo $ }x
      true
  """

  @spec get_file_abs(s) :: s when s: String.t

  def get_file_abs(file_rel), do: "#{ get_tree_abs() }/#{ file_rel }"

end
