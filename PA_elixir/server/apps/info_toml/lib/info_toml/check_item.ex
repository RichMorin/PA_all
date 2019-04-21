defmodule InfoToml.CheckItem do
#
# Public functions
#
#   check/3
#     Check for bogus, extra, or missing map elements.
#
# Private functions
#
#   check_allowed/3
#     Check whether the map keys in `inp_map` are present in its schema.
#   check_publish/3
#     Check whether "publish" is present in `meta.actions`.
#   check_refs_ok/2
#     Check whether any ref is missing a prefix string.
#   check_required/3
#     Check whether all of the required map keys) are present.
#   check_values/2
#     Check the values (ie, leaf nodes) for problems.
#   check_values_h/3
#     Recurse through an item, checking values.
#   get_schema/2
#     Select the appropriate schema.
#   leaf_paths/[13]
#     Get a list of access paths for the leaf nodes of a tree of maps.
#   leaf_paths_h/2
#     Recursive helpers for leaf_paths/3

  @moduledoc """
  This module checks maps that were loaded from a TOML file.
  """

  use Common,   :common
  use InfoToml, :common
  use InfoToml.Types

  @doc """
  Check for problems with Map elements.  For example, an item might:
  
  - use a key that is not present in the relevant schema
  - have no `publish` value in `meta.actions`
  - omit a key that is required by the relevant schema
  - have a value that fails some validity check
  """
  @spec check(item_map, String.t, schemas) :: boolean

  def check(inp_map, file_key, schemas) do
    allowed   = check_allowed( inp_map, file_key, schemas)
    publish   = check_publish( inp_map, file_key, schemas)
    refs_ok   = check_refs_ok( inp_map, file_key)
    required  = check_required(inp_map, file_key, schemas)
    values    = check_values(  inp_map, file_key)

    allowed && publish && refs_ok && required && values
  end

# Private functions

  @spec check_allowed(item_map, String.t, schemas) :: boolean

  defp check_allowed(inp_map, file_key, schemas) do
  #
  # Check whether all of the map keys in inp_map are present in the relevant
  # schema (eg, main, make, text, type, zoo).
  #
  # We do this by generating a list of all leaf paths used in inp_map,
  # then removing all of them that are present in the schema.  Extra keys
  # (ie, bogons) indicate a problem in the input map.

    schema    = get_schema(schemas, file_key)
    bogon_fn  = fn path -> get_in(schema, path) == nil end

    bogons  = inp_map           # %{ meta: %{...}, ...}
    |> leaf_paths()             # [ [ :meta, :actions ], ... ]
    |> Enum.filter(bogon_fn)    # [ :meta, :bar ], ... ]

    if Enum.empty?(bogons) do
      true
    else
      IO.puts "\nIgnored: #{ file_key }"
      IO.puts "Because: extra keys - " <> inspect bogons
      false
    end
  end

  @spec check_publish(item_map, String.t, schemas) :: boolean

  defp check_publish(inp_map, file_key, _schemas) do
  #
  # Check whether we should publish this item.  The logic is a bit arcane:
  #
  # - We always publish "_schemas/main.toml".
  # - We always publish files other than ".../main.toml".
  # - Otherwise, the "publish" flag must be present in `meta.actions`.
  # - The "draft" flag must NOT be present if we're running on PORT 64000.

    http_port   = System.get_env("PORT") || "4000"
    main_file   = String.ends_with?(file_key, "/main.toml")

    actions     = inp_map             # %{ meta: %{...}, ... }
    |> get_in([:meta, :actions])      # "publish, build"
    |> to_string()                    # handle nil, if need be
    |> str_list()                     # [ "publish", "build" ]

    has_draft   = Enum.member?(actions, "draft")
    has_publish = Enum.member?(actions, "publish")
    publish     = has_publish || (has_draft && http_port == "4000")

    if file_key == "_schemas/main.toml" || !main_file || publish do
      true
    else
      IO.puts "\nIgnored: #{ file_key }"
      IO.puts "Because: item does not qualify for publication"
      false
    end
  end

  @spec check_refs_ok(map, String.t) :: boolean

  defp check_refs_ok(inp_map, file_key) do
  #
  # Check whether any ref has a major syntax problem.
  # ToDo:  Check ref prefixes against `InfoToml.Common.exp_map/0`.

    gi_path     = [ :meta, :refs ]
    refs_map    = get_in(inp_map, gi_path)

    filter_fn   = fn field ->             # Retain invalid fields.
      pattern   = ~r{ ^ [a-z_]+ [|] [A-Za-z0-9_]+ $ }x

      !String.match?(field, pattern)
    end

    reject_fn   = fn {_type, ref_str} ->  # Retain invalid entries.
      ref_str
      |> str_list()
      |> Enum.filter(filter_fn)
      |> Enum.empty?()
    end

    cond do
      String.starts_with?(file_key, "_schemas/") -> true

      refs_map ->
        bogons  = refs_map |> Enum.reject(reject_fn)

        if Enum.empty?(bogons) do
          true
        else
          IO.puts "\nIgnored: #{ file_key }"
          IO.puts "Because: incomplete ref(s) - " <> inspect bogons
          false
        end

      true -> true
    end
  end

  @spec check_required(map, String.t, map) :: boolean

  defp check_required(inp_map, file_key, schemas) do
  #
  # Check whether all of the required map keys (from the schema) are present.
  # We do this by generating a list of required map keys, then attempting to
  # find them in the target file.  Missing keys (ie, bogons) indicate a
  # problem in the input map.

    schema    = get_schema(schemas, file_key)

    bogon_fn  = fn path_str ->
      gi_path   = path_str              # "meta.actions"
      |> String.split(".")              # [ "meta", "actions" ]
      |> Enum.map(&String.to_atom/1)    # [ :meta, :actions ]

      get_in(inp_map, gi_path) == nil
    end

    bogons  = schema[:_required]        # "meta, meta.actions, ..."
    |> str_list()                       # [ "meta", "meta.actions", ...]
    |> Enum.filter(bogon_fn)            # [ "meta", "meta.actions", ...]

    if Enum.empty?(bogons) do
      true
    else
      IO.puts "\nIgnored: #{ file_key }"
      IO.puts "Because: missing keys - " <> inspect bogons
      false
    end
  end

  @spec check_values(item_map, String.t) :: boolean

  defp check_values(inp_map, file_key) do
  #
  # Check the values (ie, leaf nodes) for problems.

    checks_fn   = fn
      1, gi, str ->
        if str =~ ~r{ ^ \s* $ }x, do: { "warning: blank string",        gi }
      2, gi, str ->
        if str =~ ~r{ \? \? }x,   do: { "error: string contains '??'",  gi }
    end

    check_ids   = [ 1, 2 ]

    reduce_fn   = fn { message, _gi_path}, acc ->
      String.starts_with?(message, "error:") && acc
    end

    reject_fn   = fn x -> x == nil end

    check_fn    = fn inp, gi_rev ->
      gi_path   = Enum.reverse(gi_rev)

      for check_id <- check_ids do
        checks_fn.(check_id, gi_path, inp)
      end
      |> Enum.reject(reject_fn)
    end

    result = check_values_h(inp_map, check_fn, [])

    if result != [] do
      IO.puts "\n#{ file_key }"
      IO.inspect result
    end

    Enum.reduce(result, true, reduce_fn)
  end

  @spec check_values_h(map|s, (s, list -> any), list) ::
    list when s: String.t #K

  defp check_values_h(inp_val, check_fn, gi_rev) do
  #
  # Recurse through an item (ie, a tree of Maps).  Check each value, using
  # check_fn.  Return a list of nastygram tuples.

    if is_map(inp_val) do
      for {key, val} <- inp_val do
        check_values_h(val, check_fn, [key | gi_rev] ) #R
      end
    else
      check_fn.(inp_val, gi_rev)
    end
    |> List.flatten()
  end

  @spec get_schema(map, s) :: map when s: String.t

  defp get_schema(schemas, file_key) do
  #
  # Work around file system naming vagaries to select the appropriate schema.

    schema_key = cond do
      file_key =~ ~r{ ^ .* / text \. \w+ \. toml $ }x ->  "_schemas/text.toml"
      file_key =~ ~r{ _text / \w+ \. toml $ }x        ->  "_schemas/text.toml"
      file_key =~ ~r{ / _area \. toml $ }x            ->  "_schemas/area.toml"
      true    ->  String.replace(file_key, ~r{ ^ .+ / }x, "_schemas/")
    end

    schemas[schema_key]
  end

  # Get a list of data structure access paths, as used in `get_in/2`, for
  # the leaf nodes of a tree of maps.  The code below was adapted slightly
  # from a reply by Peer Reynders (peerreynders) to a help request on the
  # Elixir Forum: `https://elixirforum.com/t/17715`.

  @spec leaf_paths(item_map)       :: l when l: list

  defp leaf_paths(tree), do: leaf_paths(tree, [], [])

  @spec leaf_paths(item_map, l, l) :: l when l: list

  defp leaf_paths(tree, parent_path, paths) do
    {_, paths} = Enum.reduce(tree, {parent_path, paths}, &leaf_paths_h/2)
    paths
  end

# @spec leaf_paths_h({atom, any}, {item_path, item_paths}) :: [ item_part ]

  defp leaf_paths_h({key, value}, {parent_path, paths}) when is_map(value), do:
    {parent_path, leaf_paths(value, [ key | parent_path ], paths) }

  defp leaf_paths_h({key, _value}, {parent_path, paths}), do:
    {parent_path, [ :lists.reverse( [ key | parent_path ] ) | paths ] }

end
