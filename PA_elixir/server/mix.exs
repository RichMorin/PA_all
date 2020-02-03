# server/mix.exs

defmodule Server.MixProject do

  use Mix.Project

  # Public functions

  def project() do
    src_add   = "PA_elixir/server/"
    src_url   = "https://github.com/RichMorin/PA_all"
    src_ref   = "master"
    src_patt  = "#{ src_url }/blob/#{ src_ref }/" <>
                "#{ src_add }%{path}#L%{line}"

    # See https://stackoverflow.com/questions/51261633

    dialyzer  = [
      plt_add_deps:   :apps_direct,
      plt_add_apps:   ~w(earmark ex_unit floki httpoison mix plug toml)a,
    ]

    [
      apps_path:              "apps",
      deps:                   deps(),
      start_permanent:        Mix.env() == :prod,
      version:                "0.0.0 (prototype)",

      # Dialyzer
      dialyzer:               dialyzer,

      # Docs
      name:                   "Pete's Alley",
      source_url:             src_url,
      homepage_url:           "http://pa.cfcl.com",

      docs: [
        source_url_pattern:   src_patt,
#       main:                 "?",
#       logo:                 "path/to/logo.png",
        extras:               ["README.md"]
      ],

      preferred_cli_env: [
        coveralls:            :test,
        "coveralls.detail":   :test,
        "coveralls.post":     :test,
        "coveralls.html":     :test
      ],

      preferred_cli_env: [
        coveralls:            :test,
        "coveralls.detail":   :test,
        "coveralls.post":     :test,
        "coveralls.html":     :test
      ],

      test_coverage:          [ tool: ExCoveralls ],
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.

  defp deps() do
    [
      { :credo,               "~> 1.1.5",
          only:               [:dev, :test],
          runtime:            false
      },

#     { :dialyxir,            "~> 1.0.0-rc.6",
      { :dialyxir,            github: "jeremyjh/dialyxir",
          only:               [:dev],
          runtime:            false
      },

      { :doctor,              "~> 0.8" },

      { :erlex,
          github:             "asummers/erlex",
          only:               [:dev],
          override:           true,
          runtime:            false
      },

      { :ex_doc,              "~> 0.20.2",
          only:               [:dev]
      },

      { :excoveralls,           "~> 0.12.0",
          only:               [:test],
          runtime:            false
      },

      { :inch_ex,             "~> 2.0",
          only:               [:dev, :test]
      },

#     { :dialyxir,            github: "jeremyjh/dialyxir",
#     { :doctor,    github: "akoutmos/doctor", only: [:dev, :test] },
#     { :inch_ex,   github: "rrrene/inch_ex",  only: [:dev, :test] },
    ]
  end
end
