# info_toml/access_keys.ex

defmodule InfoToml.AccessKeys do
#
# Public functions
#
#   get_area_key/1
#     Return the most relevant area key, given a bogus item key.
#   get_area_names/0
#     Return a list of Area names: [ "Catalog", ... ]
#   get_area_names/1
#     Return a list of Area (really, Section) names.
#   get_keys/1
#     Return a sorted and trimmed list of item keys.
#   keys_by_tag/1
#     Return a list of item keys, given a tag value.

  @moduledoc """
  This module implements part of the external access API (e.g., `get_keys/1`)
  for the OTP server.  Specifically, it contains functions to return keys,
  names, etc.
  """

  @me InfoToml.Server

  import Common, warn: false, only: [ ii: 2, keyss: 1, ssw: 2 ]

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

  @spec get_area_key(st) :: st
    when st: String.t

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
  Return a list of Area names, e.g.: `[ "Catalog", ... ]`.
  """

  @spec get_area_names() :: [String.t, ...]

  def get_area_names() do #!K - unused

    abridge_fn  = fn key ->
    #
    # Remove all leading path elements.

      key |> String.replace(~r{ ^ .* / }x, "")
    end

    reject_fn = fn key ->
    #
    # Reject any name that starts with an underscore or ends in `.toml`.

      key =~ ~r{ ^ _ }x ||
      key =~ ~r{ \. toml $ }x
    end

    InfoToml.get_keys(2)
    |> Enum.reject(reject_fn)
    |> Enum.map(abridge_fn)
  end

  @doc """
  Return a list of Area (really, Section) names.
  Given `"Content"`, returns `[ "HowTos", ... ]`.
  """

  @spec get_area_names(st) :: [st, ...]
    when st: String.t

  def get_area_names(area) do #!K - unused
  #
  # Given "Content", returns [ "HowTos", ... ]

    test_str  = "Areas/#{ area }"

    abridge_fn  = fn key ->
    #
    # Remove all leading path elements.

      key |> String.replace(~r{ ^ .* / }x, "")
    end

    filter_fn = fn key ->
    #
    # Return true if the key starts with `test_str` and doesn't end with `.toml`.

      ssw(key, test_str) && !( key =~ ~r{ \. toml $ }x )
    end

    InfoToml.get_keys(3)
    |> Enum.filter(filter_fn)
    |> Enum.map(abridge_fn)
  end

  @doc """
  Return a sorted list of item keys, trimmed to a specified number of levels.
  For example:

      1 => ["Catalog"]
      2 => ["Catalog", "Content"]
      3 => ["Catalog", "Content", "_schemas"]
      4 => ["Catalog", "Content", "_schemas", "_text"]
  """

  @spec get_keys(integer) :: [String.t, ...]

  def get_keys(levels) do
    max_ndx = levels - 1

    abridge_fn = fn key ->
    #
    # Discard trailing nodes.

      key
      |> String.split("/")
      |> Enum.slice(0..max_ndx)
      |> Enum.join("/")
    end

    get_fn = fn toml_map ->
    #
    # Retrieve a sorted list of deduplicated, abridged keys.

      toml_map.items
      |> keyss()
      |> Enum.map(abridge_fn)
      |> Enum.dedup()
    end

    Agent.get(@me, get_fn)
  end

  @doc """
  Return a list of item keys, given a tag value (possibly containing
  a tag name prefix).
  """

  @spec keys_by_tag(st) :: [st]
    when st: String.t

  def keys_by_tag(tag_val) do

    get_fn  = fn toml_map ->
    #
    # Retrieve a list of key strings by tag value.

      map_fn  = fn id_num ->
      #
      # Retrieve a list of key strings by ID number.

        gi_path   = [:index, :key_by_id_num, id_num]

        toml_map
        |> get_in(gi_path)      # ["Catalog/...", ...]
      end

      gi_path   = [:index, :id_nums_by_tag, tag_val]

      map_set   = get_in(toml_map, gi_path)

      if map_set do
        map_set                   # #MapSet<[1024, 1042, ...]>
        |> MapSet.to_list()       # [1024, 1042, ...]
        |> Enum.map(map_fn)       # ["Catalog/...", ...]
      else
        [] #!K Passing back an empty array isn't a big win over crashing...
      end
    end

    Agent.get(@me, get_fn)
  end

end
