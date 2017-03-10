defmodule ScBot.Mixfile do
  use Mix.Project

  def project do
    [
      app: :sc_bot,
      version: "0.0.1",
      elixir: ">= 1.1.0-dev",
      #escript: escript,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps
   ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      applications: [:logger, :httpoison, :poison, :gproc, :postgrex, :mysqlex],
      mod: {ScBot, []}
    ]
  end

  #def escript do
  #    [main_module: ScBot.CLI]
  #end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:httpoison, "~> 0.10.0"},
      {:poison, "~> 1.3"},
      {:gproc, "0.3.1"},
      {:postgrex, ">= 0.9.1"},
      {:mysqlex, github: "tjheeta/mysqlex"},
      {:html_sanitize_ex, "~> 1.0.0"}
    ]
  end
end
