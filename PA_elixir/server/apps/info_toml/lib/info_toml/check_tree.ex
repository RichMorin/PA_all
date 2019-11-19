# info_toml/check_tree.ex

defmodule InfoToml.CheckTree do
#
# Public functions
#
#   check_all/1
#     Do some global sanity checks on a `toml_map` candidate.
#   check_id_str/1
#     Check for problematic duplication of `id_str` values.

  @moduledoc """
  This module runs tests on a prospective toml_map.
  """

  import Common, only: [ csv_split: 1, ii: 2, sort_by_elem: 3, ssw: 2 ]

  alias InfoToml.Schemer
  alias InfoToml.Types, as: ITT

  # Public functions

  @doc """
  Do some global sanity checks on a `toml_map` candidate.
  """
  
  @spec check_all(map) :: {atom, [String.t, ...]}

  def check_all(toml_map) do
    results   = %{}
    |> Map.put(:check_id_str, check_id_str(toml_map) )
    |> Map.put(:check_refs,   check_refs(toml_map) )

    err_acc_fn  = fn {_checker, {status, message} }, acc ->
    #
    # Return either the default (:ok) tuple or an error tuple containing
    # a list of error messages.

      {_acc_stat, acc_list} = acc

      case status do
        :ok   -> acc
        _     -> {:error, [ message | acc_list] }
      end
    end

    default   = {:ok, []}
    results |> Enum.reduce(default, err_acc_fn) 
  end

  @doc """
  Check for problematic duplication of `id_str` values.
  """
  
  @spec check_id_str(ITT.toml_map) :: {atom, String.t}

  def check_id_str(toml_map) do

    reduce_fn = fn {key, item}, acc ->
    #
    # Accumulate a map containing lists of item keys, indexed by ID strings.
 
      gi_path     = [ :meta, :id_str ]
      id_str      = get_in(item, gi_path) 
      initial     = [ key ]

      update_fn   = fn curr_val -> [ key | curr_val ] end
      #
      # Add the new item key to the current map value.

      Map.update(acc, id_str, initial, update_fn)
    end

    reject_fn   = fn {key, _item} ->
    #
    # Return true for make, review, schema, and slide files.

      force   =
#       key =~ ~r{ / Clever_Cutter / }x ||  #!D uncomment to enable
        false

      by_key  =
        ssw(key, "_schemas/") ||                    # "_schemas/main.toml"
        String.ends_with?(key, "/make.toml")  ||    # ".../make.toml"
        key =~ ~r{^ .+ / s_[^.]+ \. toml $ }x  ||   # ".../s_*.toml"
        key =~ ~r{^ .+ / text \. \w+ \. toml $ }x   # ".../text.Rich_Morin.toml"

      by_key && !force
    end
      
    filter_fn   = fn {_id_str, keys} -> Enum.count(keys) > 1 end
    #
    # Return true if the id_str has been used more than once.

    dup_list    = toml_map.items    # Get all items in the TOML map.
    |> Enum.reject(reject_fn)       # Reject some ancillary files.
    |> Enum.reduce(%{}, reduce_fn)  # Build a map of id_str usage.
    |> Enum.filter(filter_fn)       # Retain cases of duplicate usage. 
    |> sort_by_elem(0, :dc)         # Sort results by their ID strings.

    if Enum.empty?(dup_list) do
      { :ok, "" }
    else
      message = "problematic duplication(s) of id_str"
      IO.puts ">>> #{ message }\n"
      ii(dup_list, "dup_list") #!T
      IO.puts ""
      { :error, message }
    end
  end

  @doc """
  Check for missing reference items.
  """
  
  @spec check_refs(ITT.toml_map) :: {atom, String.t}

  def check_refs(toml_map) do
  #
  #!K This function uses a local copy of the lookup list (pre_list)
  # in order to avoid a cyclic dependency with exp_prefix/1.

    pre_list  = Schemer.get_prefix() |> Map.to_list()

    wanted_fn = fn {_key, item}, acc ->   
    #
    # Accumulate a list of "wanted" item keys.

      fields_fn   = fn {_type, ref_str} -> csv_split(ref_str) end
      #
      # Return a list of fields from the reference string.

      prefix_fn_h  = fn { inp, out }, acc ->
      #
      # Expand a single prefix in the input string.

        String.replace(acc, "#{ inp }|", out)
      end

      prefix_fn   = fn inp_str ->
      #
      # Expand all prefix usage in the input string.

        pre_list |> Enum.reduce(inp_str, prefix_fn_h)
      end

      suffix_fn   = fn ref -> "#{ ref }/main.toml" end
      #
      # Add a file name suffix, converting the reference to an item key string.

      gi_path   = [ :meta, :refs ]
      ref_map   = get_in(item, gi_path)

      if ref_map do
        item_keys  = ref_map          # %{ foo: "a|b, ..." }
        |> Enum.map(fields_fn)        # [ [ "a|b", "c|d", ... ], ... ]
        |> List.flatten()             # [ "a|b", "c|d", ... ]
        |> Enum.map(prefix_fn)        # [ ".../b", ... ]
        |> Enum.map(suffix_fn)        # [ ".../b/main.toml", ... ]

        acc ++ item_keys
      else
        acc
      end
    end

    defined_fn  = fn key ->
    #
    # True if this item is defined in the TOML map.

      gi_path   = [ :items, key ]
      get_in(toml_map, gi_path)
    end

    schema_fn   = fn {key, _item} -> ssw(key, "_schemas/") end
    #
    # True if this item is a schema.

    undef_list  = toml_map.items      # Get all items in the TOML map.
    |> Enum.reject(schema_fn)         # Discard the schema files.
    |> Enum.reduce([], wanted_fn)     # Get a list of "wanted" item keys.
    |> Enum.uniq()                    # Discard duplicate keys.
    |> Enum.reject(defined_fn)        # Discard defined keys.

    if Enum.empty?(undef_list) do
      { :ok, "" }
    else
      message = "reference to undefined item"
      IO.puts ">>> #{ message }\n"
      ii(undef_list, :undef_list) #!T
      IO.puts ""
      { :error, message }
    end
  end

end
