defmodule CommandHandler do

	def run_command(name, args, message) do
		case Agent.get(:command_list, fn list -> Map.get(list, name) end) do
			nil -> nil
			command_module -> Task.start fn -> command_module.run({message, args}) end
		end
	end

	def parse(message) do
		if String.starts_with?(message.content, ["!", "$", "<@!381287303504723969>"]) do
			[name | args] = extract_components(message.content)
			{:ok, name, args}
		else
			:notacommand
		end
	end

	# Extracts the command name and args into a list, where the head is the command name.
	defp extract_components(content) do
		content |> String.replace(["!", "$", "<@!381287303504723969>"], "", global: false) |> String.split()
	end
end
