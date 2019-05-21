# controllers/search_controller.ex

defmodule PhxHttpWeb.SearchController do
#
# Public functions
#
#   find/2
#     Generate data for the Search (find) page.
#   show/2
#     Generate data for the Search Results (show) page.
#
# Private functions
#
#   get_id_sets/1
#     Get a list of MapSets (of ID numbers) matching the input tags.
#   get_queries/2
#     Return a list of query tuples.
#   get_tag_sets/2
#     Save the new tag set in the session; return all tag sets.
#   retrieve/3
#     Retrieve the requested data, based on the query.
#   structure/1
#     Sort and chunk the results for display.

  @moduledoc """
  This module contains controller actions (etc) for searching the "Areas/..."
  portion of the `toml_map`.
  """

  use Common.Types
  use PhxHttp.Types
  use PhxHttpWeb, :controller

  import Common, only: [ base_26: 1, get_run_mode: 0, ii: 2 ]
  import PhxHttpWeb.SearchMunger, only: [ munge: 1 ]

  # Public functions

  @doc """
  This function generates data for the Search (find) page.
  """

  @spec find(Plug.Conn.t(), any) :: Plug.Conn.t() #W

  def find(conn, _params) do
    tag_info        = InfoToml.get_tag_info()
    sess_tag_sets   = get_session(conn, :tag_sets) || %{}

    conn
    |> base_assigns(:search_f, "PA Search")
    |> assign(:sess_tag_sets,   sess_tag_sets)
    |> assign(:tag_info,        tag_info)
    |> render("find.html")
  end

  @doc """
  This function generates data for the Search Results (show) page.
  """

  @spec show(Plug.Conn.t(), any) :: Plug.Conn.t() #W

  def show(conn, params) do
    {tags_d, specs_r}   = params |> munge()

    {conn, tag_sets}    = get_tag_sets(conn, tags_d)

    cur_set     = get_session(conn, :cur_set)
    id_sets_d   = get_id_sets(tags_d)
    path_map    = [:index, :key_by_id_num] |> InfoToml.get_part()
    queries_r   = get_queries(specs_r, tag_sets)

    inter_fn    = fn items, acc -> MapSet.intersection(acc, items) end
    union_fn    = fn items, acc -> MapSet.union(       acc, items) end

    map_fn  = fn {set_op, _set_id, tags_r} ->
      id_sets   = get_id_sets(tags_r)
      case set_op do
        "all"   -> Enum.reduce(id_sets, inter_fn)
        "any"   -> Enum.reduce(id_sets, union_fn)
      end
    end

    id_sets_r  = queries_r  # [ { "all", "a", [ "type:value", ... ] } ]
    |> Enum.map(map_fn)     # [ #MapSet<[1002, 1234]>, ... ]

    id_sets_m   = id_sets_d ++ id_sets_r
    results_i   = retrieve(id_sets_m, path_map, inter_fn)
    results_u   = retrieve(id_sets_m, path_map, union_fn)

    if false && get_run_mode() == :dev do #K TG
      IO.puts("")
      ii(cur_set,                 "cur_set")

      pm_fn = fn x -> String.ends_with?(x, "/main.toml") end
      path_map
      |> Map.values
      |> Enum.reject(pm_fn)
      |> ii("path_map")

      ii(queries_r,               "queries_r")
      unless Enum.empty?(results_u) do
        ii(hd(results_u),           "hd(results_u)")
      end
      ii(specs_r,                 "specs_r")
      ii(tags_d,                  "tags_d")
      IO.puts("")
      ii(Enum.count(id_sets_d),   "# of defined sets")
      ii(Enum.count(id_sets_r),   "# of reused sets")
      ii(Enum.count(id_sets_m),   "# of merged sets")
      ii(Enum.count(results_i),   "size of 'all' results")
      ii(Enum.count(results_u),   "size of 'any' results")
    end

    conn
    |> base_assigns(:search_r, "PA Search")
    |> assign(:cur_set,     cur_set)
    |> assign(:queries_r,   queries_r)
    |> assign(:results_i,   structure(results_i))
    |> assign(:results_u,   structure(results_u))
    |> assign(:tags_d,      tags_d)
    |> render("show.html")
  end

  # Private Functions

  @spec get_id_sets( [ String.t ] ) :: [ MapSet.t(integer) ] #W

  defp get_id_sets(tag_set) do
  #
  # Get a list of MapSets (of ID numbers) matching the input tags.

    map_fn    = fn val ->
      [:index, :id_nums_by_tag, val ] |>  InfoToml.get_part()
    end

    tag_set |> Enum.map(map_fn)
  end

  @spec get_queries( [ {s, s} ], map ) :: [ { s, s, [s] } ] when s: String.t #W

  defp get_queries(reused, new_sets) do
  #
  # Return a list of tuples, containing a set operation ("all", "any"),
  # the name of a saved query (eg, "a"), and a tag set (eg, ["foo:bar"].

    map_fn = fn {inp_sel, inp_name} ->
      { inp_sel, inp_name, new_sets[inp_name] } end

    reused                        # [ {"all", "a"}, {"any", "b"} ]
    |> Enum.map(map_fn)           # [ {"all", "a", [ "...", ... ] }, ... ]
  end

  @spec get_tag_sets(Plug.Conn.t(), tag_set) :: {Plug.Conn.t(), tag_sets} #W

  defp get_tag_sets(conn, new_set) do
  #
  # Save the new tag set in the session; return all tag sets.

    old_sets  = get_session(conn, :tag_sets) || %{}
    old_vals  = Map.values(old_sets)
    set_cnt   = Enum.count(old_sets)

    {conn, tag_sets}  = if Enum.empty?(new_set) ||
                           Enum.member?(old_vals, new_set) do
      {conn, old_sets}
    else
      cur_set   = base_26(set_cnt+1)
      tag_sets  = Map.put(old_sets, cur_set, new_set)

      conn      = conn
      |> put_session(:cur_set,  cur_set)
      |> put_session(:tag_sets, tag_sets)

      {conn, tag_sets}
    end

    if get_run_mode() == :dev do #K TG
#     ii(new_set,  "new_set")
      ii(tag_sets, "tag_sets")
    end

    {conn, tag_sets}
  end

  @spec retrieve(id_sets, any, id_reduce) :: [ tuple ] #K #W

  # Retrieve the requested data, based on the query.
  
  defp retrieve(_id_sets = [], _path_map, _reduce_fn), do: []
  #
  # Nothing to see here; move along...

  defp retrieve(id_sets, path_map, reduce_fn) do
  #
  # Convert id_sets (a list of MapSets) to a single MapSet, using
  # reduce_fn to get the intersection or union, then flatten the result. 

    map_fn    = fn id -> InfoToml.get_item_tuples(path_map[id]) end

    id_sets                       # [ #MapSet<[1011]>, #MapSet<[1078]> ]                   
    |> Enum.reduce(reduce_fn)     # #MapSet<[1011, 1078]>
    |> MapSet.to_list()           # [ 1011, 1078 ]
    |> Enum.map(map_fn)           # [ [ { "...", "...", "..." }, ... ], ... ]
    |> List.flatten()             # [ { "...", "...", "..." }, ... ]
  end

  @spec structure( [ tuple ] ) :: [ [ tuple ] ] #K #W

  defp structure(results) do
  #
  # Sort and chunk the results for display.

    pattern   = ~r{ / \w+ / \w+ \. toml $ }x
    base_fn   = fn path -> String.replace(path, pattern, "") end

    chunk_fn  = fn {path, _title, _precis} -> base_fn.(path) end
      
    sort_fn   = fn {path, title, _precis} ->
      "#{ base_fn.(path) } #{ String.downcase(title) }"
    end

    results
    |> Enum.sort_by(sort_fn)      # [ { "...", "...", "..." }, ... ]
    |> Enum.chunk_by(chunk_fn)    # [ [ { "...", "...", "..." }, ... ], ... ]
  end

end
