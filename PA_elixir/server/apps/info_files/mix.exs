# info_files/mix.ex

defmodule InfoFiles.MixProject do

  use Mix.Project

  # Public functions

  def project() do
#   IO.puts "InfoFiles.MixProject.project: Mix.env() == #{ Mix.env() }" #T

    if !System.get_env("mix_env") do
      System.put_env("mix_env", "#{ Mix.env() }") #K
    end

    [
      app:                :info_files,
      version:            "0.1.0",

      build_path:         "../../_build",
      config_path:        "../../config/config.exs",
      deps_path:          "../../deps",
      lockfile:           "../../mix.lock",

      elixir:             "~> 1.9",
      start_permanent:    Mix.env() == :prod,
      deps:               deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.

  def application() do
    [
#     mod: { InfoFiles.Application, [] },
#     extra_applications:     [:logger],
    ]
  end

  # Run "mix help deps" to learn about dependencies.

  defp deps() do
    [ # added

      # local
      { :common,              in_umbrella: true },
    ]
  end
end
