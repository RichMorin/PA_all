# info_toml/load_file.ex

defmodule InfoToml.LoadFile do
#
# Public functions
#
#   do_file/3
#     Process (eg, load, check) a TOML file.
#
# Private functions
#
#   do_file_1/4
#     Bail out if `Parser.parse/2` returned `nil`.
#   do_file_2/5
#     Bail out if `CheckItem.check/3` returned `false`.

  @moduledoc """
  This module handles loading of data from a TOML file, including
  loading and checking against the schema.
  """

  import Common.Tracing, only: [ii: 2], warn: false
  import InfoToml.Common, only: [get_file_abs: 1, get_map_key: 1]

  alias InfoToml.{CheckItem, Parser}
  alias InfoToml.Types, as: ITT

  # Public functions

  @doc """
  Process (e.g., load, check) a TOML file.

  Note: This function is only exposed as public to enable testing. 
  """

  @spec do_file(st, ITT.id_num, ITT.schema_map) :: {st, ITT.item_maybe}
    when st: String.t

  def do_file(file_rel, id_num, schema_map) do
 
    file_rel
    |> get_file_abs()
    |> Parser.parse(:atoms!)  # require atom predefinition
    |> do_file_1(file_rel, id_num, schema_map)
  end

  # Private functions

  @spec do_file_1(im, st, ITT.id_num, ITT.schema_map) :: {st, im}
    when im: ITT.item_maybe, st: String.t

  defp do_file_1(file_data, file_rel, _, _) when file_data == %{} do
    {file_rel, nil}
  end
  #
  # Bail out if `Parser.parse/2` returned an empty Map.

  defp do_file_1(file_data, file_rel, id_num, schema_map) do
  #
  # Unless the key starts with "_", check `file_data` against `schema`.

    file_key  = get_map_key(file_rel)
    file_stat = file_data |> CheckItem.check(file_key, schema_map)

    do_file_2(file_data, file_key, file_rel, file_stat, id_num)
  end

  @spec do_file_2(im, st, st, boolean, ITT.id_num) :: {st, im}
    when im: ITT.item_maybe, st: String.t

  defp do_file_2(_, _, file_rel, _file_stat = false, _) do
  #
  # Bail out if `CheckItem.check/3` returned `false`.

    {file_rel, nil}
  end

  defp do_file_2(file_data, file_key, file_rel, _file_stat, id_num) do
  #
  # Otherwise, return the harvested (and slightly augmented) data.

    file_abs           = get_file_abs(file_rel)
    {:ok, file_stat}   = File.stat(file_abs, time: :posix)

    # The code below gets the date and time of the file's most recent commit.
    # Unfortunately, it takes an annoying amount of time to do so...
    #
    #  arg_list      = ~w(log -1 --pretty=%ci) ++ [file_abs]
    #  {cmd_out, 0}  = System.cmd("git", arg_list)
    #  date_time     = String.trim(cmd_out)

    patt_item   = ~r{ / [^/]+ / ( main | make | s_\w+ ) \. toml $ }x
    patt_misc   = ~r{ / [^/]+ \. toml $ }x

    directories   = file_key
    |> String.replace(patt_item, "")
    |> String.replace(patt_misc, "")
    |> String.split("/")
    |> Enum.join(", ")

    file_data   = if get_in(file_data, [:meta, :tags]) do
      file_data
    else
      put_in(file_data, [:meta, :tags], %{})
    end

    tag_map     = file_data |> get_in([:meta, :tags])

    tag_map     = if file_key != "_schemas/main.toml" do #!K
      reduce_fn   = fn {inp_key, inp_val}, acc ->
        tmp_val   = String.replace(inp_val, ~r{\w+\|}, "")
        Map.put(acc, inp_key, tmp_val)
      end

      ref_map   = ( get_in(file_data, [:meta, :refs]) || %{} )
      |> Enum.reduce(%{}, reduce_fn)

      Map.merge(tag_map, ref_map)
    else
      tag_map
    end

    file_data   = file_data
    |> put_in([:meta, :file_key],             file_key)
    |> put_in([:meta, :file_rel],             file_rel)
    |> put_in([:meta, :file_time],            file_stat.mtime)
    |> put_in([:meta, :id_num],               id_num)
    |> put_in([:meta, :tags],                 tag_map)
    |> put_in([:meta, :tags, :directories],   directories)

    { file_rel, file_data }
  end

end
