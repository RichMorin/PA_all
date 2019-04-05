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

  use Common,   :common
  use InfoToml, :common
  use InfoToml.Types

  @doc """
  Do some global sanity checks on a `toml_map` candidate.
  """
  
# @spec check_all(toml_map) :: {atom, [ String.t ] }
  @spec check_all(map) :: {atom, [ String.t ] }

  def check_all(toml_map) do
    results   = %{}
    results   = Map.put(results, :check_id_str, check_id_str(toml_map) )

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
  
# @spec check_id_str(toml_map) :: {atom, String.t }
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

end
