defmodule AutoCorrectBot.Client do
	use Nostrum.Consumer

	alias CommandHandler
	alias Nostrum.Api

	def start_link do
		if (reg_commands() == true), do: IO.puts "Successfully registered commands."

		Consumer.start_link(__MODULE__)
	end

	def reg_commands do
		commands = for file <- File.ls!("./lib/commands"), into: %{} do
			name = String.replace_suffix(file, ".ex", "")
			{name, String.to_existing_atom("Elixir.Command.#{String.capitalize(name)}")}
		end
		{:ok, command_list} = Agent.start_link(fn -> commands end)
		command_list |> Process.register(:command_list)
	rescue
		e -> "Could not register commands: #{e}"
	end

	def handle_event({:MESSAGE_CREATE, message, _ws_state}) do
		with {:ok, name, args} <- CommandHandler.parse(message),
		do: CommandHandler.run_command(name, args, message)

		# Make spelling corrections
		if (!message.author.bot) do
			case WordHandler.correct_spelling(message.content) do
				{:corrections, words} -> Task.start(fn -> Api.create_message(message.channel_id, Enum.map(words, fn {w, _index} -> "*" <> w end) |> Enum.join(", ")) end)
				_ -> nil
			end
		end

		# I'm dad!
		filteredMsg = String.replace(message.content, ["'", " a", " A"], "", global: false)
		if (String.starts_with?(String.downcase(filteredMsg), "im ")), do: Api.create_message(message.channel_id, "Hi #{String.slice(filteredMsg, 3..String.length(filteredMsg))}, I'm dad!")
	end

	def handle_event({:READY, data, _ws_state}) do
		IO.puts("Logged in under user #{data.user.username}##{data.user.discriminator}")
		Api.update_status(:dnd, "the Elixir brew", 3)
	end

	# Default event handler
	def handle_event(event) do
		IO.puts("Unhandled event: #{elem event, 0}")
		:noop
	end
end
