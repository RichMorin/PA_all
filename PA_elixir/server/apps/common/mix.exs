# common/mix.exs

defmodule Common.MixProject do

  use Mix.Project

  # Public functions

  @spec project() :: [key: atom]

  def project() do
#   IO.puts "Common.MixProject.project: Mix.env() == #{ Mix.env() }" #T

    if !System.get_env("mix_env") do
      System.put_env("mix_env", "#{ Mix.env() }") #K
    end

    [
      app:                :common,
      version:            "0.1.0",

      build_path:         "../../_build",
      config_path:        "../../config/config.exs",
      deps_path:          "../../deps",
      lockfile:           "../../mix.lock",

      elixir:             "~> 1.9",
      start_permanent:    Mix.env() == :prod,
      deps:               deps(),
    ]
  end

  # Run "mix help compile.app" to learn about applications.

  @spec application() :: [key: atom]

  def application() do
    [
#     mod: { Common.Application, [] },
#     extra_applications:     [:logger],
    ]
  end

  # Run "mix help deps" to learn about dependencies.

  @spec deps() :: [ tuple ]

  defp deps() do
    [
      { :dialyxir,            "~> 1.0.0-rc.6",
        only: [:dev], runtime: false },
      { :ex_doc,              "~> 0.20.2",
        only: :dev },
    ]
  end
end
