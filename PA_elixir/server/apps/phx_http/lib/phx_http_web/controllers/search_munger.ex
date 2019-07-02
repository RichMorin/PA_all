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

  use PhxHttpWeb, :controller

  import Common, warn: false, only: [ ii: 2, ssw: 2 ]

  alias PhxHttp.Types, as: PT

  # Public functions

  @spec munge( [ {s, s} ] ) :: { [s], [ {s, s} ]} when s: String.t #W

  @doc """
  Filter params, shard by form section, then rework the structures
  into defined tags (`tags_d`) and reuse specifications (`specs_r`).
  """

  def munge(params) do

    type_fn   = fn tag ->
    #
    # Add a type wildcard ("_:"), if need be.

      if   String.contains?(tag, ":") do tag
      else "_:#{ tag }"
      end
    end
        
    inp_text  = (params["search_text"] || "")

    tags_t    = inp_text    # "foo:bar baz"
    |> String.split()       # [ "foo:bar", "baz" ]
    |> Enum.map(type_fn)    # [ "foo:bar", "_:baz" ]

    {params_d, params_r}  = munge_filter(params)

    tags_d    = params_d |> munge_map_d()
    tags_all  = (tags_t ++ tags_d) |> Enum.sort()
    specs_r   = params_r |> munge_map_r()

    {tags_all, specs_r}
#   |> ii("munged") #T
  end

  # Private Functions

  @spec munge_filter( [ {s, s} ] ) :: {sp, sp} when s: String.t, sp: [PT.s_pair] #W

  defp munge_filter(params) do
  #
  # Discard extraneous and meaningless params, then shard by type.

    defined_fn  = fn {_key, val} -> ssw(val, "d:") end
    #
    # Return true if this is a "defined" parameter.

    reused_fn   = fn {_key, val} -> ssw(val, "r:") end
    #
    # Return true if this is a "reused" parameter.

    noise_fn  = fn {key, val} ->
    #
    # Return true if parameter is extraneous or meaningless.

      ssw(key, "_")       ||
      ssw(val, "d:n:")    ||
      ssw(val, "r:none")
    end

    my_params   = params
    |> Enum.reject(noise_fn)

    params_d    = my_params
    |> Enum.filter(defined_fn)  # [ {"f_authors__...", "d:y:f_authors:..."} ]

    params_r    = my_params
    |> Enum.filter(reused_fn)   # [ {"r_a", "r:any"} ]

    {params_d, params_r}
  end

  @spec munge_map_d( [PT.s_pair] ) :: [ String.t ] #W

  defp munge_map_d(input) do
  #
  # Map the "defined" parameters into a list of tags, then sort it.

    tag_fn    = fn {_key, val} ->
    #
    # Retrieve the (typed) tag from the parameter value.

      trim_patt = ~r{ ^ [a-z] : [a-z]+ : }x
      String.replace(val, trim_patt, "")
    end

    input                         # [ { "...", "d:y:roles:..." }, ... ]
    |> Enum.map(tag_fn)           # [ "roles:...", ... ]
    |> Enum.sort()                # [ "roles:...", ... ] (sorted)
  end

  @spec munge_map_r(sp) :: sp when sp: [PT.s_pair] #W

  defp munge_map_r(input) do
  #
  # Map the "reused" parameters into a list of specification tuples.

    spec_fn   = fn {inp_name, inp_sel} ->
    #
    # Return a specification tuple.

      out_name = inp_name |> String.replace_prefix("r_", "")
      out_sel  = inp_sel  |> String.replace_prefix("r:", "")

      {out_sel, out_name}
    end
  
    input
    |> Enum.map(spec_fn)          # [ { "all", "a" }, ... ]
  end

end
