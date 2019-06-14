# server/mix.exs

defmodule Server.MixProject do

  use Mix.Project

  # Public functions

  @spec project() :: [key: atom]

  def project() do
    [
      apps_path:          "apps",
      start_permanent:    Mix.env() == :prod,
      deps:               deps()
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.

  @spec deps() :: [ tuple ]

  defp deps() do
    [
      { :doctor,              "~> 0.6.0" },
#     { :doctor,    github: "akoutmos/doctor", only: [:dev, :test] },
      { :inch_ex,   github: "rrrene/inch_ex",  only: [:dev, :test] },
    ]
  end
end
