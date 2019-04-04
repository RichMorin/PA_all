defmodule InfoToml.IexFun do

  @moduledoc """
  This module contains convenience functions for use in IEx.
  """

  # Create some module aliases, for convenience.

  alias InfoToml.{
    Application, CheckItem, CheckTree, Common, IndexTree, LoadTree,
    Parser, Reffer, Schemer, Server, Tagger
  }

  # Fake out the compiler to eliminate "unused alias" warnings.
  
  _fake_alias_usage = [
    Application, CheckItem, CheckTree, Common, IndexTree, LoadTree,
    Parser, Reffer, Schemer, Server, Tagger
  ]

end