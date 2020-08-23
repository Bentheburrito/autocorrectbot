defmodule Command.Say do
	@behaviour Command
	alias Nostrum.Api

	@impl Command
	def run({message, args}) do
		case Api.delete_message(message) do
			{:error, err} -> IO.puts(err.response.message)
			_ -> nil
		end
		Api.create_message(message.channel_id, Enum.join(args, " "))
	end

	@impl Command
	def help({message, _args}) do
		Api.create_message(message.channel_id, "!say [message]")
	end
end
