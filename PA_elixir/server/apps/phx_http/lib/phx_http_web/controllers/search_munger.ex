# controllers/search_munger.ex

defmodule PhxHttpWeb.SearchMunger do
#
# Public functions
#
#   munge/1
#     Filter params, shard by form section, then rework the results.
#
# Private functions
#
#   munge_filter/1
#     Discard extraneous and meaningless params, then shard by type.
#   munge_map_d/1
#     Map the "defined" parameters into a list of tags, then sort it.
#   munge_map_r/1
#     Map the "reused" parameters into a list of specifications.

  @moduledoc """
  This module contains support functions for munging the params handed back
  to the `SearchController.show/2` action.
  """

  use Common.Types
  use PhxHttp.Types
  use PhxHttpWeb, :controller

  import Common, warn: false, only: [ ii: 2 ]

  # Public functions

  @spec munge( [ {s, s} ] ) :: { [s], [ {s,s} ]} when s: String.t #W

  @doc """
  Filter params, shard by form section, then rework the structures
  into defined tags (tags_d) and reuse specifications (specs_r).
  """

  def munge(params) do

    map_fn    = fn tag ->
      if String.contains?(tag, ":") do tag
      else "_:#{ tag }"
      end
    end
        
    tags_t    = (params["search_text"] || "")
    |> String.split()
    |> Enum.map(map_fn)

    {params_d, params_r}  = munge_filter(params)

    tags_d    = params_d |> munge_map_d()
    tags_all  = (tags_t ++ tags_d) |> Enum.sort()
    specs_r   = params_r |> munge_map_r()

    {tags_all, specs_r}
#   |> ii("munged") #T
  end

  # Private Functions

  @spec munge_filter( [ {s, s} ] ) :: {sp, sp} when s: String.t, sp: [s_pair] #W

  defp munge_filter(params) do
  #
  # Discard extraneous and meaningless params, then shard by type.

    filter_fn_d = fn {_key, val} -> String.starts_with?(val, "d:") end
    filter_fn_r = fn {_key, val} -> String.starts_with?(val, "r:") end

    reject_fn = fn {key, val} ->
      String.starts_with?(key, "_")       ||
      String.starts_with?(val, "d:n:")    ||
      String.starts_with?(val, "r:none")
    end

    my_params   = params
    |> Enum.reject(reject_fn)

    params_d    = my_params
    |> Enum.filter(filter_fn_d)   # [ {"f_authors__...", "d:y:f_authors:..."} ]

    params_r    = my_params
    |> Enum.filter(filter_fn_r)   # [ {"r_a", "r:any"} ]

    {params_d, params_r}
  end

  @spec munge_map_d( [s_pair] ) :: [ String.t ] #W

  defp munge_map_d(input) do
  #
  # Map the "defined" parameters into a list of tags, then sort it.

    map_fn      = fn {_key, val} ->
      trim_patt = ~r{ ^ [a-z] : [a-z]+ : }x
      trim_fn   = fn val -> String.replace(val, trim_patt, "") end
      trim_fn.(val)
    end

    input                         # [ { "...", "..." }, ... ]
    |> Enum.map(map_fn)           # [ "roles:...", ... ]
    |> Enum.sort()                # [ "roles:...", ... ] (sorted)
  end

  @spec munge_map_r(sp) :: sp when sp: [s_pair] #W

  defp munge_map_r(input) do
  #
  # Map the "reused" parameters into a list of specifications.

    map_fn     = fn {inp_name, inp_sel} ->
      out_name = inp_name |> String.replace_prefix("r_", "")
      out_sel  = inp_sel  |> String.replace_prefix("r:", "")

      {out_sel, out_name}
    end
  
    input
    |> Enum.map(map_fn)           # [ { "all", "a" }, ... ]
  end

end
