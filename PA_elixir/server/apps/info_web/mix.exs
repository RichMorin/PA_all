defmodule InfoWeb.MixProject do
  use Mix.Project

  @spec project() :: [key: atom]

  def project() do
#   IO.puts "InfoWeb.MixProject.project: Mix.env() == #{ Mix.env() }" #T

    if !System.get_env("mix_env") do
      System.put_env("mix_env", "#{ Mix.env() }") #K
    end

    [
      app:                :info_web,
      version:            "0.1.0",

      build_path:         "../../_build",
      config_path:        "../../config/config.exs",
      deps_path:          "../../deps",
      lockfile:           "../../mix.lock",

      elixir:             "~> 1.8",
      elixirc_paths:      elixirc_paths(Mix.env()),
      start_permanent:    Mix.env() == :prod,
      deps:               deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.

  @spec application() :: [key: atom]

  def application() do
    [
      mod: { InfoWeb.Application, [] },
      extra_applications:     [:logger]
    ]
  end

  # Specifies which paths to compile per environment.

  @spec elixirc_paths(any) :: [ String.t ]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Run "mix help deps" to learn about dependencies.

  @spec deps() :: [ tuple ]

  defp deps() do
    [ # added
      { :dialyxir,            "~> 1.0.0-rc.4",
        only: [:dev], runtime: false },
      { :ex_doc,              "~> 0.19", only: :dev },
      { :floki,               "~> 0.20.4" },
      { :httpoison,           "~> 1.5" },
      { :toml,                "~> 0.5.2" },

      # local
      { :common,              in_umbrella: true },
      { :info_toml,           in_umbrella: true },  # ???
    ]
  end
end
