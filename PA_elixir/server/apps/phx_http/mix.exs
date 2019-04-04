defmodule PhxHttp.MixProject do
  use Mix.Project

  def project do
#   IO.puts "PhxHttp.MixProject.project: Mix.env() == #{ Mix.env() }" #T

    if !System.get_env("mix_env") do
      System.put_env("mix_env", "#{ Mix.env() }") #K
    end

    [
      app:                :phx_http,
      version:            "0.1.0",

      build_path:         "../../_build",
      config_path:        "../../config/config.exs",
      deps_path:          "../../deps",
      lockfile:           "../../mix.lock",

      elixir:             "~> 1.8",
      elixirc_paths:      elixirc_paths(Mix.env()), #?
      compilers:          [:phoenix, :gettext] ++ Mix.compilers(), #?
      start_permanent:    Mix.env() == :prod,
      deps:               deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.

  def application do
    [
      mod:                    {PhxHttp.Application, []},
      extra_applications:     [:logger, :runtime_tools],
    ]
  end

  # Specifies which paths to compile per environment.

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.

  defp deps do
    [ # default
      { :phoenix,              "~> 1.4.0" },
      { :phoenix_pubsub,       "~> 1.1" },
      { :phoenix_html,         "~> 2.11" },
      { :phoenix_live_reload,  "~> 1.2", only: :dev },
      { :gettext,              "~> 0.11" },
      { :jason,                "~> 1.0" },
      { :plug_cowboy,          "~> 2.0" },

      # added
      { :dialyxir,             "~> 1.0.0-rc.4",
        only: [:dev], runtime: false },

      { :earmark,              "~> 1.3.2" },

# Temporary redirect until Hex.pm gets a new version of Earmark...
#     { :earmark, override: true,
#         git: "https://github.com/pragdave/earmark.git" },

      { :ex_doc,               "~> 0.19", only: :dev },

      # local
      { :common,               in_umbrella: true },
      { :info_files,           in_umbrella: true },
      { :info_toml,            in_umbrella: true },
      { :info_web,             in_umbrella: true },
    ]
  end
end
