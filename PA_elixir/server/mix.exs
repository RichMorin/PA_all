defmodule Server.MixProject do
  use Mix.Project

  @spec project() :: list

  def project do
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

  @spec deps() :: list

  defp deps do
    []
  end
end
