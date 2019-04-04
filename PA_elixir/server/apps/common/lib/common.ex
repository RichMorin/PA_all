defmodule Common do

  @moduledoc """
  This module defines the external API for the Common component.  Each
  "function" actually delegates to a public function in `common/*.ex`.
  """

  # Define the public interface.

  alias Common.{Maps,Strings,Tracing,Zoo}

  @doc """
  Naive pluralizer: add an "s" to the end of `string` if `n` is 1.
  ([`...Strings.add_s/2`](Common.Strings.html#add_s/2))
  """
  defdelegate add_s(n, string),       to: Strings

  @doc """
  Generate an alphabetic ID string, using base-26 arithmetic.
  ([`...Strings.base_26/1`](Common.Strings.html#base_26/1))
  """
  defdelegate base_26(n),             to: Strings

  @doc """
  Generate an alphabetic ID string, using base-26 arithmetic.
  ([`...Strings.base_26/2`](Common.Strings.html#base_26/2))
  """
  defdelegate base_26(n, letters),    to: Strings

  @doc """
  Get the absolute file path for the base directory.
  ([`...Zoo.get_tree_base/0`](Common.Zoo.html#get_tree_base/0))
  """
  defdelegate get_tree_base(),        to: Zoo

  @doc """
  Wrap `IO.inspect/2`, making it less painful to use.
  ([`...Tracing.ii/2`](Common.Tracing.html#ii/2))
  """
  defdelegate ii(thing, label),       to: Tracing

  @doc """
  Get the keys to a Map and return them in sorted order.
  ([`...Maps.keyss/1`](Common.Maps.html#keyss/1))
  """
  defdelegate keyss(map),             to: Maps

  @doc """
  Is this our sort of Map tree?
  ([`...Maps.our_tree/1`](Common.Maps.html#our_tree/1))
  """
  defdelegate our_tree(map),          to: Maps

  @doc """
  Is this our sort of Map tree?
  ([`...Maps.our_tree/2`](Common.Maps.html#our_tree/2))
  """
  defdelegate our_tree(map, strict),  to: Maps

  @doc """
  Get an Atom indicating the current run mode.
  ([`...Zoo.run_mode/0`](Common.Zoo.html#run_mode/0))
  """
  defdelegate run_mode(),             to: Zoo

  @doc """
  Split a comma-delimited string into a list of trimmed strings.
  ([`...Strings.str_list/1`](Common.Strings.html#str_list/1))
  """
  defdelegate str_list(in_str),       to: Strings

  @doc """
  Get an Atom indicating the data type of the argument.
  ([`...Zoo.type_of/1`](Common.Zoo.html#type_of/1))
  """
  defdelegate type_of(thing),         to: Zoo


  @doc "Set up infrastructure for code sharing."
  def common do
    quote do
      import Common
    end
  end

  @doc "Dispatch to the appropriate module (e.g., `use Common, :common`)."
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def get_calls(), do: Mix.Tasks.Xref.calls #D

end