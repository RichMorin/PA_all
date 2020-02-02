# info_web/mix.exs

defmodule InfoWeb.MixProject do

  use Mix.Project

  # Public functions

  def project() do
#   IO.puts "InfoWeb.MixProject.project: Mix.env() == #{ Mix.env() }" #!T

    if !System.get_env("mix_env") do
      System.put_env("mix_env", "#{ Mix.env() }") #!K
    end

    [
      app:                :info_web,
      version:            "0.1.0",

      build_path:         "../../_build",
      config_path:        "../../config/config.exs",
      deps_path:          "../../deps",
      lockfile:           "../../mix.lock",

      elixir:             "~> 1.9",
      elixirc_paths:      elixirc_paths(Mix.env()),
      start_permanent:    Mix.env() == :prod,
      deps:               deps(),

      test_coverage:      [ tool: ExCoveralls ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.

  def application() do
    [
      mod: { InfoWeb.Application, [] },
      extra_applications:     [:logger]
    ]
  end

  # Specifies which paths to compile per environment.

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Run "mix help deps" to learn about dependencies.

  defp deps() do
    [
      # added

# Temporary redirect until Hex.pm gets a new version of Floki...
#     { :floki,               "~> 0.25" },
      { :floki, override: true,
        git: "https://github.com/RichMorin/floki.git" },

      { :httpoison,           "~> 1.5" },
      { :toml,                "~> 0.5.2" },

      # local
      { :common,              in_umbrella: true },
      { :info_toml,           in_umbrella: true },  # ???
    ]
  end
end
