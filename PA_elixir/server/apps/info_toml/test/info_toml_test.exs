# info_toml_test.exs

defmodule InfoTomlTest do

  use ExUnit.Case

  import InfoToml

# doctest InfoToml
  doctest InfoToml.AccessData
  doctest InfoToml.AccessKeys
# doctest InfoToml.Application
  doctest InfoToml.CheckItem
  doctest InfoToml.CheckTree
  doctest InfoToml.Common
  doctest InfoToml.Emitter
  doctest InfoToml.IndexTree
  doctest InfoToml.KeyVal
  doctest InfoToml.LoadFile
  doctest InfoToml.LoadTree
  doctest InfoToml.Parser
  doctest InfoToml.Reffer
  doctest InfoToml.Schemer
  doctest InfoToml.Server
  doctest InfoToml.Tagger
  doctest InfoToml.Trees
end
