defmodule AutoCorrectBot do
	use Application

	# Application Entry Point
	@impl true
	def start(_type, _args) do
		AutoCorrectBot.Supervisor.start_link(name: MainSupervisor)
	end
end
