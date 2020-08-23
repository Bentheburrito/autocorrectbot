defmodule Command.Ping do
	@behaviour Command
	alias Nostrum.Api

	@impl Command
	def run({message, _args}) do
		Api.create_message(message.channel_id, "Pong!")
	end

	@impl Command
	def help({message, _args}) do
		Api.create_message(message.channel_id, "!ping")
	end
end
