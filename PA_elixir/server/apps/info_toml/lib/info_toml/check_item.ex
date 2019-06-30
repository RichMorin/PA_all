# info_toml/check_item.ex

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
#     Check whether all of the required map keys are present.
#   check_values/2
#     Check the values (ie, leaf nodes) for problems.
#   check_values_h/3
#     Recurse through an item, checking values.

  @moduledoc """
  This module checks maps that were loaded from a TOML file.
  """

  use Common.Types

  import Common,
    only: [ csv_split: 1, get_http_port: 0, leaf_paths: 1, ssw: 2 ]

  import InfoToml.Schemer, only: [ get_schema: 2 ]

  # Public functions

  @doc """
  Check for problems with map elements.  For example, an item might:
  
  - use a key that is not present in the relevant schema
  - have no `publish` value in `meta.actions`
  - omit a key that is required by the relevant schema
  - have a value that fails some validity check
  """
  @spec check(item_map, String.t, schema_map) :: boolean

  def check(inp_map, file_key, schema_map) do
    allowed   = check_allowed( inp_map, file_key, schema_map)
    publish   = check_publish( inp_map, file_key, schema_map)
    refs_ok   = check_refs_ok( inp_map, file_key)
    required  = check_required(inp_map, file_key, schema_map)
    values    = check_values(  inp_map, file_key)

    allowed && publish && refs_ok && required && values
  end

# Private functions

  @spec check_allowed(item_map, String.t, schema_map) :: boolean

  defp check_allowed(inp_map, file_key, schema_map) do
  #
  # Check whether all of the map keys in inp_map are present in the relevant
  # schema (eg, main, make, text, type, zoo).
  #
  # We do this by generating a list of all leaf paths used in inp_map,
  # then removing all of them that are present in the schema.  Undefined keys
  # (i.e., bogons) indicate a problem in the input map.

    schema     = get_schema(schema_map, file_key)

    filter_fn  = fn path -> get_in(schema, path) == nil end
    #
    # Return true if the path is not defined in the schema.

    bogons  = inp_map           # %{ meta: %{...}, ...}
    |> leaf_paths()             # [ [ :meta, :actions ], ... ]
    |> Enum.filter(filter_fn)   # [ :meta, :bar ], ... ]

    if Enum.empty?(bogons) do
      true
    else
      IO.puts "\nIgnored: #{ file_key }"
      IO.puts "Because: extra keys - " <> inspect bogons
      false
    end
  end

  @spec check_publish(item_map, String.t, schema_map) :: boolean

  defp check_publish(inp_map, file_key, _schema_map) do
  #
  # Check whether we should publish this item.  The logic is a bit arcane:
  #
  # - We always publish "_schemas/main.toml".
  # - We always publish files other than ".../main.toml".
  # - Otherwise, the "publish" flag must be present in `meta.actions`.
  # - The "draft" flag must NOT be present if we're running on PORT 64000.

    http_port   = get_http_port()
    main_file   = String.ends_with?(file_key, "/main.toml")

    actions     = inp_map             # %{ meta: %{...}, ... }
    |> get_in([:meta, :actions])      # "publish, build"
    |> to_string()                    # handle nil, if need be
    |> csv_split()                    # [ "publish", "build" ]

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
  # Check whether any meta.ref value has a major syntax problem.
  # ToDo:  Check ref prefixes against `InfoToml.Common.exp_map/0`.

    gi_path     = [ :meta, :refs ]
    refs_map    = get_in(inp_map, gi_path)

    filter_fn   = fn field ->
    #
    # Return true if the field has invalid syntax.

      pattern   = ~r{ ^ [a-z_]+ [|] [A-Za-z0-9_]+ $ }x
      !String.match?(field, pattern)
    end

    reject_fn   = fn {_type, ref_str} ->
    #
    # Return true if any field has invalid syntax.

      ref_str
      |> csv_split()
      |> Enum.filter(filter_fn)
      |> Enum.empty?()
    end

    cond do
      ssw(file_key, "_schemas/") -> true

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

  @spec check_required(map, String.t, schema_map) :: boolean

  defp check_required(inp_map, file_key, schema_map) do
  #
  # Check whether all of the required map keys (from the schema) are present.
  # We do this by generating a list of required map keys, then attempting to
  # find them in the target file.  Undefined keys (i.e., bogons) indicate a
  # problem in the input map.

    schema    = get_schema(schema_map, file_key)

    filter_fn   = fn path_str ->
    #
    # Return true if the path string is not defined in the input map.

      gi_path   = path_str              # "meta.actions"
      |> String.split(".")              # [ "meta", "actions" ]
      |> Enum.map(&String.to_atom/1)    # [ :meta, :actions ]

      get_in(inp_map, gi_path) == nil
    end

    bogons  = schema[:_required]        # "foo, meta, meta.actions, ..."
    |> csv_split()                      # [ "foo", "meta", "meta.actions", ...]
    |> Enum.filter(filter_fn)           # [ "foo", ...]

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
  # Check the values (i.e., leaf nodes) of inp_map for problems.

    checks_fn   = fn
    #
    # Return a tuple based on the specified check_id (e.g., 1).

      1, gi_path, str ->
        if str =~ ~r{ ^ \s* $ }x,
          do: { "warning: blank string",        gi_path }

      2, gi_path, str ->
        if str =~ ~r{ \? \? }x,
          do: { "error: string contains '??'",  gi_path }
    end

    err_chk_fn  = fn { message, _gi_path}, acc ->
    #
    # Return true if an error was detected.

      ssw(message, "error:") && acc
    end

    check_fn    = fn inp, gi_rev ->
    #
    # Perform a set of checks on item values; return a list of error tuples.

      gi_path   = Enum.reverse(gi_rev)

      for check_id <- [1, 2] do
        checks_fn.(check_id, gi_path, inp)
      end
      |> Enum.filter( &(&1) )
    end

    result = check_values_h(inp_map, check_fn, [])

    if result != [] do
      IO.puts "\n#{ file_key }"
      IO.inspect(result, label: :result)
    end

    Enum.reduce(result, true, err_chk_fn)
  end

  @spec check_values_h(map|s, (s, list -> any), list) ::
    [tuple] when s: String.t

  defp check_values_h(inp_val, check_fn, gi_rev) do
  #
  # Recurse through an item (i.e., a tree of maps).  Check each value, using
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

end
