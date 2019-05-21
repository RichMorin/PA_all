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

  use Common.Types

  import Common, only: [ csv_split: 1, ii: 2 ]

  alias InfoToml.Schemer

  # Public functions

  @doc """
  Do some global sanity checks on a `toml_map` candidate.
  """
  
  @spec check_all(map) :: {atom, [ String.t ] }

  def check_all(toml_map) do
    results   = %{}
    |> Map.put(:check_id_str, check_id_str(toml_map) )
    |> Map.put(:check_refs,   check_refs(toml_map) )

    reduce_fn = fn {_checker, {status, message} }, acc ->
      {_acc_stat, acc_list} = acc

      case status do
        :ok   -> acc
        _     -> {:error, [ message | acc_list] }
      end
    end

    default   = {:ok, []}
    results |> Enum.reduce(default, reduce_fn) 
  end

  @doc """
  Check for problematic duplication of `id_str` values.
  """
  
  @spec check_id_str(map) :: {atom, String.t }

  def check_id_str(toml_map) do
    gi_path   = [ :meta, :id_str ]

    reduce_fn = fn {key, item}, acc ->   
      id_str      = get_in(item, gi_path) 
      initial     = [ key ]
      update_fn   = fn val -> [ key | val ] end

      Map.update(acc, id_str, initial, update_fn)
    end

    reject_fn1  = fn {key, _item}    ->
      force   =
#       key =~ ~r{ / Clever_Cutter / }x ||  #D uncomment to enable
        false

      by_key  =
        String.starts_with?(key, "_schemas/") ||    # "_schemas/main.toml"
        String.ends_with?(key, "/make.toml")  ||    # ".../make.toml"
        key =~ ~r{^ .+ / text \. \w+ \. toml $ }x   # ".../text.Rich_Morin.toml"

      by_key && !force
    end
      
    reject_fn2  = fn {_id_str, keys} -> Enum.count(keys) == 1 end

    sort_fn     = fn {id_str, _list} -> String.downcase(id_str) end

    dup_list    = toml_map.items
    |> Enum.reject(reject_fn1)
    |> Enum.reduce(%{}, reduce_fn)
    |> Enum.reject(reject_fn2)
    |> Enum.sort_by(sort_fn)

    if Enum.empty?(dup_list) do
      { :ok, "" }
    else
      message = "problematic duplication(s) of id_str"
      IO.puts ">>> #{ message }\n"
      ii(dup_list, "dup_list") #T
      IO.puts ""
      { :error, message }
    end
  end

  @doc """
  Check for missing reference items.
  """
  
  @spec check_refs(map) :: {atom, String.t}

  def check_refs(toml_map) do
    gi_path   = [ :meta, :refs ]
    pre_list  = Schemer.get_prefix() |> Map.to_list()

    map_fn1a    = fn ref        -> "#{ ref }/main.toml" end
    reduce_fn2  = fn key, acc   -> Map.put(acc, key, true) end 

    reduce_fn1  = fn {_key, item}, acc ->   
    #K
    # This function is almost identical to exp_prefix/1, but it uses a local
    # copy of the lookup Map in order to avoid a cyclic dependency.

      ref_map   = get_in(item, gi_path)

      map_fn1b  = fn {_type, ref_str} -> csv_split(ref_str) end

      map_fn1c  = fn inp_str ->
        reduce_fn = fn { inp, out }, acc ->
          String.replace(acc, "#{ inp }|", out)
        end

        Enum.reduce(pre_list, inp_str, reduce_fn)
      end

      if ref_map do
        want_tmp  = ref_map               # %{ foo: "a|b, ..." }
        |> Enum.map(map_fn1b)             # [ [ "a|b", "c|d", "..." ], ... ]
        |> List.flatten()                 # [ "a|b", "c|d", "..." ]
        |> Enum.map(map_fn1c)             # [ ".../b", "..." ]
        |> Enum.map(map_fn1a)             # [ ".../b/...", "..." ]
        |> Enum.reduce(%{}, reduce_fn2)   # %{ ".../b/..." => true, "..." ]

        Map.merge(acc, want_tmp)
      else
        acc
      end
    end

    filter_fn1  = fn {key, _item} -> !String.starts_with?(key, "_schemas/") end

    filter_fn2  = fn key ->
      gi_path   = [ :items, key ]

      !get_in(toml_map, gi_path)
    end

    map_fn2     = fn {key, _val} -> key end

    want_list   = toml_map.items
    |> Enum.filter(filter_fn1)
    |> Enum.reduce(%{}, reduce_fn1)
    |> Enum.map(map_fn2)
    |> Enum.filter(filter_fn2)

    if Enum.empty?(want_list) do
      { :ok, "" }
    else
      message = "unmatched reference"
      IO.puts ">>> #{ message }\n"
      ii(want_list, "want_list") #T
      IO.puts ""
      { :error, message }
    end
  end

end
