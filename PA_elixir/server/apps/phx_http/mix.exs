# phx_http/mix.exs

defmodule PhxHttp.MixProject do

  use Mix.Project

  # Public functions

  def project() do
#   IO.puts "PhxHttp.MixProject.project: Mix.env() == #{ Mix.env() }" #!T

    if !System.get_env("mix_env") do
      System.put_env("mix_env", "#{ Mix.env() }") #!K
    end

    [
      app:                :phx_http,
      version:            "0.1.0",

      build_path:         "../../_build",
      config_path:        "../../config/config.exs",
      deps_path:          "../../deps",
      lockfile:           "../../mix.lock",

      elixir:             "~> 1.9",
      elixirc_paths:      elixirc_paths(Mix.env()),
      compilers:          [:phoenix, :gettext] ++ Mix.compilers(), #?
      start_permanent:    Mix.env() == :prod,
      deps:               deps(),

      test_coverage:      [ tool: ExCoveralls ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.

  def application() do
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

  defp deps() do
    [ # default
      { :phoenix,              "~> 1.4" },
      { :phoenix_pubsub,       "~> 1.1" },

      { :phoenix_html,         "~> 2.13.3" },

# Test redirect to determine whether Dialyzer fix works for us.
#     { :phoenix_html, override: true,
#       git: "https://github.com/phoenixframework/phoenix_html.git" },

      { :phoenix_live_reload,  "~> 1.2", only: :dev },
      { :gettext,              "~> 0.16" },
      { :jason,                "~> 1.1" },
      { :plug_cowboy,          "~> 2.0" },

      # added
      { :earmark,              "~> 1.3.2" },

# Temporary redirect until Hex.pm gets a new version of Earmark...
#     { :earmark, override: true,
#       git: "https://github.com/pragdave/earmark.git" },

# Temporary redirect until Hex.pm gets a new version of Floki...
#     { :floki,               "~> 0.25" },
      { :floki, override: true,
        git: "https://github.com/RichMorin/floki.git" },

# I tried installing :modest_ex on a macOS Catalina (10.15.2) system.
# The build crashed, because the `cmake` command was missing.
# After I did a `brew install cmake` (and cleaned out the relevant deps),
# the build "succeeded" (with bazillions of warnings).
# However, `iex -S mix` then refused to start:
#
# [error] Cookie file /Local/Users/rdm/.erlang.cookie must be accessible by owner only
# [info] Application modest_ex exited:
#   ModestEx.Safe.start(:normal, []) returned an error:
#     shutdown: failed to start child: Nodex.Cnode
#    ** (EXIT) an exception was raised:
#        ** (RuntimeError) Node is not alive. Cannot connect to a cnode.
#            (nodex) lib/nodex/cnode.ex:37: Nodex.Cnode.init/1
#            (stdlib) gen_server.erl:374: :gen_server.init_it/2
#            (stdlib) gen_server.erl:342: :gen_server.init_it/6
#            (stdlib) proc_lib.erl:249: :proc_lib.init_p_do_apply/3
# ...
#
#     {:modest_ex,            "~> 1.0"},

      # local
      { :common,               in_umbrella: true },
      { :info_files,           in_umbrella: true },
      { :info_toml,            in_umbrella: true },
      { :info_web,             in_umbrella: true },
    ]
  end
end
