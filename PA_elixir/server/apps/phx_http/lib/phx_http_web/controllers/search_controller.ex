# controllers/search_controller.ex

defmodule PhxHttpWeb.SearchController do
#
# Public functions
#
#   clear_form/2
#     Generate data for the Clear Searches (form) page.
#   clear_post/2
#     Do any requested clearing, then redirect back to the Search page.
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
#   munge/1
#     Filter params, shard by form section, then rework the results.
#   munge_filter/1
#     Discard extraneous and meaningless params, then shard by type.
#   munge_map_d/1
#     Map the "defined" parameters into a list of tags, then sort it.
#   munge_map_r/1
#     Map the "reused" parameters into a list of specifications.
#   retrieve/3
#     Retrieve the requested data, based on the query.
#   structure/1
#     Sort and chunk the results for display.

  @moduledoc """
  This module contains controller actions (etc) for searching the "Areas/..."
  portion of the `toml_map`.
  """

  use PhxHttp.Types
  use PhxHttpWeb, :controller
  use InfoToml, :common
  use InfoToml.Types

  import Common

  @doc """
  This function generates data for the Clear Searches page, where the user
  fills in a form.
  """

  @spec clear_form(Plug.Conn.t(), any) :: Plug.Conn.t()

  def clear_form(conn, _params) do
    sess_tag_sets   = get_session(conn, :tag_sets) || []

    conn
    |> assign(:item,            nil)
    |> assign(:key,             nil)
    |> assign(:page_type,       :search_c)
    |> assign(:sess_tag_sets,   sess_tag_sets)
    |> assign(:title,           "PA Search")
    |> render("clear.html")
  end

  @doc """
  This function does any requested clearing of queries, then redirects back
  to the Search page.
  """

  @spec clear_post(Plug.Conn.t(), any) :: Plug.Conn.t()

  def clear_post(conn, params) do
    map_fn      = fn {key, _val} -> key end

    reject_fn_1 = fn {key, val} ->
      String.starts_with?(key, "_") || val == "n"
    end

    remove  = params
    |> Enum.reject(reject_fn_1)   # [ {"a", "y"}, ... ]
    |> Enum.map(map_fn)           # [ "a", ... ]

    reject_fn_2 = fn {key, _val} -> Enum.member?(remove, key) end

    tag_sets    = conn
    |> get_session(:tag_sets)
    |> Enum.reject(reject_fn_2)
    |> Enum.into(%{})

    conn        = put_session(conn, :tag_sets, tag_sets) #D
    redirect(conn, to: "/search/find")
  end

  @doc """
  This function generates data for the Search (find) page.
  """

  @spec find(Plug.Conn.t(), any) :: Plug.Conn.t()

  def find(conn, _params) do
    tag_info        = InfoToml.get_tag_info()
    sess_tag_sets   = get_session(conn, :tag_sets) || %{}

    conn
    |> assign(:item,            nil)
    |> assign(:key,             nil)
    |> assign(:page_type,       :search_f)
    |> assign(:sess_tag_sets,   sess_tag_sets)
    |> assign(:tag_info,        tag_info)
    |> assign(:title,           "PA Search")
    |> render("find.html")
  end

  @doc """
  This function generates data for the Search Results (show) page.
  """

  @spec show(Plug.Conn.t(), any) :: Plug.Conn.t()

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

    if false && run_mode() == :dev do #K TG
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
    |> assign(:cur_set,     cur_set)
    |> assign(:item,        nil)
    |> assign(:key,         nil)
    |> assign(:page_type,   :search_r)
    |> assign(:queries_r,   queries_r)
    |> assign(:results_i,   structure(results_i))
    |> assign(:results_u,   structure(results_u))
    |> assign(:tags_d,      tags_d)
    |> assign(:title,       "PA Search")
    |> render("show.html")
  end

  # Private Functions

  @spec get_id_sets( [ String.t ] ) :: [ MapSet.t(integer) ]

  defp get_id_sets(tag_set) do
  #
  # Get a list of MapSets (of ID numbers) matching the input tags.

    map_fn    = fn val ->
      [:index, :id_nums_by_tag, val ] |>  InfoToml.get_part()
    end

    tag_set |> Enum.map(map_fn)
  end

  @spec get_queries( [ {s, s} ], map ) :: [ { s, s, [s] } ] when s: String.t

  defp get_queries(reused, new_sets) do
  #
  # Return a list of tuples, containing a set operation ("all", "any"),
  # the name of a saved query (eg, "a"), and a tag set (eg, ["foo:bar"].

    map_fn = fn {inp_sel, inp_name} ->
      { inp_sel, inp_name, new_sets[inp_name] } end

    reused                        # [ {"all", "a"}, {"any", "b"} ]
    |> Enum.map(map_fn)           # [ {"all", "a", [ "...", ... ] }, ... ]
  end

  @spec get_tag_sets(Plug.Conn.t(), tag_set) :: {Plug.Conn.t(), tag_sets}

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

    if run_mode() == :dev do #K TG
#     ii(new_set,  "new_set")
      ii(tag_sets, "tag_sets")
    end

    {conn, tag_sets}
  end

  @spec munge( [ {s, s} ] ) :: { [s], [ {s,s} ]} when s: String.t

  defp munge(params) do
  #
  # Filter params, shard by form section, then rework the structures
  # into defined tags (tags_d) and reuse specifications (specs_r).

    {params_d, params_r}  = munge_filter(params)

    tags_d    = params_d |> munge_map_d()
    specs_r   = params_r |> munge_map_r()

    {tags_d, specs_r}
#   |> ii("munged")
  end

  @spec munge_filter( [ {s, s} ] ) :: {s_pairs, s_pairs} when s: String.t

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

    my_params   = params    |> Enum.reject(reject_fn)

    params_d    = my_params
    |> Enum.filter(filter_fn_d)   # [ {"f_authors__...", "d:y:f_authors:..."} ]

    params_r    = my_params
    |> Enum.filter(filter_fn_r)   # [ {"r_a", "r:any"} ]

    {params_d, params_r}
  end

  @spec munge_map_d(s_pairs) :: [ String.t ]

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

  @spec munge_map_r(s_pairs) :: s_pairs

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

  @spec retrieve(id_sets, any, id_reduce) :: [ tuple ] #K

  # Retrieve the requested data, based on the query.
  
  defp retrieve(_id_sets = [], _path_map, _reduce_fn), do: []
  #
  # Nothing to see here; move along...

  defp retrieve(id_sets, path_map, reduce_fn) do
  #
  # Convert id_sets (a list of MapSets) to a single MapSet, using
  # reduce_fn to get the intersection or union, then flatten the result. 

    map_fn    = fn id -> InfoToml.get_items(path_map[id]) end

    id_sets                       # [ #MapSet<[1011]>, #MapSet<[1078]> ]                   
    |> Enum.reduce(reduce_fn)     # #MapSet<[1011, 1078]>
    |> MapSet.to_list()           # [ 1011, 1078 ]
    |> Enum.map(map_fn)           # [ [ { "...", "...", "..." }, ... ], ... ]
    |> List.flatten()             # [ { "...", "...", "..." }, ... ]
  end

  @spec structure( [ tuple ] ) :: [ [ tuple ] ] #K

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
