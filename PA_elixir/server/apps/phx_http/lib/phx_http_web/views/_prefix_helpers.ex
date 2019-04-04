# views/_prefix_helpers.ex

defmodule PhxHttpWeb.PrefixHelpers do
#
# Private Macros
#
#   exp_map() do
#     Generates a Map of prefix expansions from `_config/prefix.toml`.
#
# Public functions
#
#   exp_prefix/1
#     Expand prefixes (e.g., `cat_har|`, `ext_wp|`).

  @moduledoc """
  Handle expansion of prefix strings.
  """

  use Phoenix.HTML
  use PhxHttp.Types
  use InfoToml, :common
  use InfoToml.Types

  import Common

  # Private Macros

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

  # Public Functions

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

end