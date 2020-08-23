defmodule AutoCorrectBot.MixProject do
  	use Mix.Project

	def project do
		[
			app: :auto_correct_bot,
			version: "0.1.0",
			elixir: "~> 1.9",
			start_permanent: Mix.env() == :prod,
			deps: deps()
		]
	end

	# Run "mix help compile.app" to learn about applications.
	def application do
		[
			extra_applications: [:logger],
			env: [tisane_token: nil],
			mod: {AutoCorrectBot, []}
		]
	end

	# Run "mix help deps" to learn about dependencies.
	defp deps do
		[
			{:ecto_sql, "~> 3.0"},
			{:postgrex, ">= 0.0.0"},
			{:nostrum, "~> 0.4"},
			{:jason, "~> 1.2"},
			{:httpoison, "~> 1.6"}
		]
	end
end
