# phx_http_web/views/_key_helpers.ex

defmodule PhxHttpWeb.KeyHelpers do
#
# Public functions
#
#   get_precis/1
#     Get the "precis" string for this key.
#   key_area/1
#     Generate a `toml_map` key for an area.
#   key_item/1
#     Generate a `toml_map` key for an item.
#   url_area/1
#     Generate a URL for an area.
#   url_item/1
#     Generate a URL for an item.

  @moduledoc """
  Handle tasks related to `toml_map` keys.
  """

  use Phoenix.HTML
  use PhxHttp.Types
  use InfoToml.Types

  import InfoToml, only: [get_item: 1]

  # Public functions

  @doc """
  Get the "precis" string for this area key fragment
  (or nil if the generated key isn't found).

      iex> get_precis("foo")
      nil

      iex> get_precis("Catalog/Hardware")
      "contains information on hardware (e.g., computers, tools)"
  """

  @spec get_precis(s) :: s when s: String.t #W

  def get_precis(key_frag) do
    key_frag
    |> key_area()
    |> get_item()
    |> get_in( [:about, :precis] )
  end

  @doc """
  Generate a `toml_map` key for an area.

    iex> key_area("Catalog/Hardware")
    "Areas/Catalog/Hardware/_area.toml"
  """

  @spec key_area(s) :: s when s: String.t #W

  def key_area(body), do: "Areas/#{ body }/_area.toml"

  @doc """
  Generate a `toml_map` key for an item.

    iex> key_item("Catalog/Hardware/Anova_PC")
    "Areas/Catalog/Hardware/Anova_PC/main.toml"
  """

  @spec key_item(s) :: s when s: String.t #W

  def key_item(body), do: "Areas/#{ body }/main.toml"

  @doc """
  Generate a URL for an area.

    iex> url_area("Catalog/Hardware/Anova_PC")
    "/area?key=Areas/Catalog/Hardware/Anova_PC/_area.toml"
  """

  @spec url_area(s) :: s when s: String.t #W

  def url_area(body), do: "/area?key=#{ key_area(body) }"

  @doc """
  Generate a URL for an item.

    iex> url_item("Catalog/Hardware/Anova_PC")
    "/item?key=Areas/Catalog/Hardware/Anova_PC/main.toml"
  """

  @spec url_item(s) :: s when s: String.t #W

  def url_item(body), do: "/item?key=#{ key_item(body) }"

end