# info_toml/access_data.ex

defmodule InfoToml.AccessData do
#
# Public functions
#
#   get_item/1
#     Return the data structure for an item, given its key.
#   get_item_tuples/1
#     Return a list of item tuples, given a base string for the key.
#   get_map/0
#     Return the entire `toml_map` data structure.
#   get_part/1
#     Return a specified portion of `toml_map`.
#   get_toml/1
#     Return the TOML source code, given its key.
#   put_item/2
#     Update an item in toml_map, given its key and value.

  @moduledoc """
  This module implements part of the external access API (eg, `get_keys/1`)
  for the OTP server.  Specifically, it contains functions to return or
  store data.
  """

  @me InfoToml.Server

  use Common.Types

  import Common, warn: false, only: [ ii: 2, keyss: 1, ssw: 2 ]
  import InfoToml.Common, only: [get_file_abs: 1]

  # Public functions

  @doc """
  Return the data structure for an item, given its key (eg, "_text/about.toml").
  """

  @spec get_item(String.t) :: item_map | nil

  def get_item(item_key), do: [:items, item_key] |> get_part()

  @doc """
  Return a list of item tuples (`{key, title, precis}`),
  given a base string (eg, "Areas/Catalog/Hardware/") for the key.
  """

  @spec get_item_tuples(s) :: { s, s, s } when s: String.t

  def get_item_tuples(key_base) do

    filter_fn   = fn item_key ->
    #
    # Return true if the item key starts with the provided key base.

      is_binary(item_key) && ssw(item_key, key_base)
    end

    map_fn     = fn toml_map ->
    #
    # Generate a sorted list of matching item tuples.

      tuple_fn  = fn item_key, acc ->
      #
      # Generate a list of item tuples.

        precis  = get_in(toml_map, [:items, item_key, :about, :precis])
        title   = get_in(toml_map, [:items, item_key, :meta,  :title])
        tuple   = {item_key, title, precis}
        [ tuple | acc ]
      end

      toml_map.items                  # map containing item data
      |> keyss()                      # sorted list of item keys
      |> Enum.filter(filter_fn)       # keys with the specified base
      |> Enum.reduce([], tuple_fn)    # [ {item_key, title, precis}, ... ]
    end

    Agent.get(@me, map_fn)
  end

  @doc """
  Return the entire `toml_map` data structure (mostly for testing).
  """

  @spec get_map() :: toml_map

  def get_map() do
    Agent.get(@me, &(&1) )
  end

  @doc """
  Return a specified portion of `toml_map`.  If `gi_list` is empty,
  return all of `toml_map`.
  """

  @spec get_part( [ atom | String.t ] ) :: any

  def get_part([]), do: get_map()

  def get_part(gi_list) do

    get_fn = fn toml_map -> get_in(toml_map, gi_list) end
    #
    # Return the specified portion of the TOML map.

    Agent.get(@me, get_fn)
  end

  @doc """
  Return the TOML source code, given its key (eg, "_text/about.toml").
  """

  @spec get_toml(s) :: s when s: String.t #W

  def get_toml(item_key) do
    gi_path   = [:meta, :file_rel]

    file_rel  = item_key      # "_text/about.toml"
    |> get_item()             # %{about: %{...}, ...}
    |> get_in(gi_path)        # "/.../_text/about.toml"

    if file_rel do
      file_abs = get_file_abs(file_rel)

      case File.read(file_abs) do
        {:ok, body}       -> body
        {:error, _reason} -> nil
      end
    else
      nil
    end
  end

  @doc """
  Update an item in toml_map, given its key (eg, "_text/about.toml") and value.
  """

  @spec put_item(s, map) :: atom when s: String.t

  def put_item(key, item), do: put_part(item, [:items, key])

  @doc """
  Replace a specified portion of `toml_map`.  If `key_list` is nil,
  replace `toml_map` entirely.
  """

  @spec put_part(any, [ map_key ] | nil) :: atom

  def put_part(new_val, key_list \\ nil) do

    update_fn = fn toml_map ->
    #
    # Replace the specified portion of the TOML map.

      if key_list == nil do
        new_val
      else
        put_in(toml_map, key_list, new_val)
      end
    end

    Agent.update(@me, update_fn)
  end

end
