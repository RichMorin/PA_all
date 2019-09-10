# common/zoo.ex

defmodule Common.Zoo do
#
# Public functions
#
#   chk_local/1
#     Determine whether the user is local, based on the IP address.
#   get_http_port/0
#     Get a string indicating the current HTTP PORT.
#   get_rel_path/2
#     Convert an absolute file path into a relative path.
#   get_run_mode/0
#     Get an atom indicating the current run mode.
#   get_tree_base/0
#     Get the absolute file path for the base directory.
#   type_of/1
#     Get an atom indicating the data type of the argument.

  @moduledoc """
  This module contains miscellaneous functions for common use.
  """

  import Common, warn: false, only: [ii: 2]

  # Public functions

  @doc """
  Determine whether the user is local, based on the IP address.
  Returns true if the user is on localhost or the LAN.
  """
  
  @spec chk_local(Plug.Conn.t) :: boolean

  def chk_local(conn) do
    case conn.remote_ip do
      { 127,   0, 0, 1 }  -> true   # localhost
      { 192, 168, 1, 1 }  -> false  # LAN access to cfcl.com, for testing
      { 192, 168, 1, _ }  -> true   # LAN access to fido.local
      _                   -> false  # WAN access
    end
  end

  @doc """
  Get a string indicating the current HTTP PORT.
  """

  @spec get_http_port() :: String.t

  def get_http_port() do #!K
    System.get_env("PORT") || "4000"
  end

  @doc """
  Convert an absolute file path into a relative path.

      iex> s1 = "/a/b"
      iex> s2 = "/a/b/c/d"
      iex> get_rel_path(s1, s2)
      "c/d"
  """

  @spec get_rel_path(s, s) :: s when s: String.t

  def get_rel_path(tree_abs, file_abs) do

    base_len  = byte_size(tree_abs) + 1
    trim_len  = byte_size(file_abs) - base_len

    file_abs |> binary_part(base_len, trim_len)
  end

  @doc """
  Get an atom indicating the current run mode.

  We normally pick this up from the `mix_env` (Unix) environment variable,
  defaulting to `:dev` if it isn't set.  Each Mix project's `mix.exs` file
  should set this at the start of the `project` function, as:
  
      if !System.get_env("mix_env") do
        System.put_env("mix_env", "#{ Mix.env() }") #!K
      end
  """

  @spec get_run_mode() :: atom

  def get_run_mode() do #!K
    ( System.get_env("mix_env") || "dev")
    |> String.to_atom()
#   |> IO.inspect(label: "get_run_mode")
  end

  @doc """
  Get the absolute file path for the base directory (eg, `.../PA_all`).
  """

  @spec get_tree_base() :: String.t

  def get_tree_base() do

    offset      = String.duplicate("/..", 7)
    base_rel    = "#{ __ENV__.file }#{ offset }"

    Path.expand(base_rel)
#   |> ii("tree_base") #!T
  end

  @doc """
  Get an atom indicating the data type of the argument.
  
  The clauses below define a (partial) set of type-checking functions.
  The returned values are as specific as possible.  So, for example,
  `false` produces `:boolean`, rather than `:atom`.

  ## Atoms and Booleans
  
      iex> type_of(:foo)
      :atom
      iex> type_of(false)
      :boolean
      iex> type_of(true)
      :boolean
      iex> type_of(nil)
      :nil

  ## Bitstrings and Binaries

      iex> type_of("bar")
      :binary
      iex> type_of(<<1::3>>)
      :bitstring

  ## Functions

      iex> foo_fn = fn -> "foo" end
      iex> type_of(foo_fn)
      :function

  ## Lists, Charlists, and Keyword Lists

      iex> type_of('foo')
      :list

      iex> type_of( [] )
      :list

      iex(1)> foo_list = [a: 1, b: 2]
      iex(2)> is_list(foo_list)
      true

  ## Numbers, Floats, and Integers

      iex> type_of(42.0)
      :float
      iex> type_of(4.2e+1)
      :float
      iex> type_of(42/1)
      :float
      iex> type_of(1/42)
      :float

      iex> type_of(42)
      :integer
      iex> type_of(0b1010)
      :integer
      iex> type_of(0o042)
      :integer
      iex> type_of(0x42)
      :integer

  ## Maps, Structs, and Tuples

      iex> type_of( %{} )
      :map

      iex> foo_struct = defmodule Foo
      iex>   do defstruct name: "John", age: 27
      iex> end
      iex> type_of(foo_struct)
      :tuple

      iex> type_of( {} )
      :tuple

  ## Pids and Ports

      iex> foo_pid = spawn fn -> 1 + 2 end
      iex> type_of(foo_pid)
      :pid

      iex> foo_port = Port.open({:spawn, "cat"}, [:binary])
      iex> type_of(foo_port)
      :port
  """

  @spec type_of(any) :: atom
  # Yep, this function really can handle any data type.

  # The order of the following clauses is both critical and a bit picky.
  # Specifically, it defines a simple taxonomy of Elixir types.
 
  def type_of(x) when is_binary(x),     do: :binary
  def type_of(x) when is_bitstring(x),  do: :bitstring

  def type_of(x) when is_nil(x),        do: :nil
  def type_of(x) when is_boolean(x),    do: :boolean
  def type_of(x) when is_atom(x),       do: :atom

  def type_of(x) when is_list(x),       do: :list
  def type_of(x) when is_map(x),        do: :map
  def type_of(x) when is_tuple(x),      do: :tuple    # (including struct)

  def type_of(x) when is_float(x),      do: :float
  def type_of(x) when is_integer(x),    do: :integer
  def type_of(x) when is_number(x),     do: :number

  def type_of(x) when is_function(x),   do: :function

  def type_of(x) when is_pid(x),        do: :pid

  def type_of(x) when is_port(x),       do: :port

  def type_of(_),                       do: :other    # eg, reference
end
