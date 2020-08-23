defmodule WordHandler do

	@spec correct_spelling(String.t()) :: {:corrections, list({String.t(), integer()})} | :none
	@doc """
	POST content to Tisane's API and returns a list of spelling corrections (if any), will return `nil` if a string is not passed.
	"""
	def correct_spelling(content) when is_bitstring(content) do
		content = String.replace(content, ~r/[.,!?\s]+/, " ") # Remove punctuation (Tisane separates each result by sentences)

		# check word in api or library
		res = HTTPoison.post!("https://api.tisane.ai/parse",
			"{\"language\":\"en\", \"content\":\"#{content}\", \"settings\":{\"parses\": true,\"subscope\": true,\"abuse\": false,\"sentiment\": false,\"entities\": false,\"topics\": false,\"deterministic\": false}}",
			[{"Ocp-Apim-Subscription-Key", Application.fetch_env!(:auto_correct_bot, :tisane_token)}])

		corrected_content =
			with {:ok, body} <- Jason.decode(res.body), # Might want to move this into a case
				list <- Map.get(body, "sentence_list", []),
				%{} = returned <- Enum.at(list, 0, []),
				do: (Map.get(returned, "corrected_text") || Map.get(returned, "text", content)) |> String.split()

		IO.inspect String.split(content)
		IO.inspect corrected_content

		if length(corrected_content) > 0 do
			corrections = Enum.reduce_while(0..length(corrected_content) - 1, [], &(
				if (String.downcase(Enum.at(String.split(content), &1)) != String.downcase(Enum.at(corrected_content, &1))),
				do: {:cont, [{Enum.at(corrected_content, &1), &1} | &2]},
				else: {:cont, &2}
			))
			if (length(corrections) > 0), do: {:corrections, corrections}, else: :none
		end
	end
	def correct_spelling(_), do: nil
end

# corrected_content =
# 	with {:ok, body} <- Jason.decode(res.body), # Might want to move this into a case
# 		list <- Map.get(body, "sentence_list", []),
# 		do: Enum.reduce(list, [], &(&2 ++ ((Map.get(&1, "corrected_text") || Map.get(&1, "text")) |> String.split())))

# Time test between two methods:
# {time_in_microseconds, ret_val} = :timer.tc(fn -> (for sentence <- list, length(list) > 0, into: [], do: ((Map.get(sentence, "corrected_text") || Map.get(sentence, "text")) |> String.split)) |> List.flatten() end)
# {time_in_microseconds, ret_val} = :timer.tc(fn -> Enum.reduce(list, [], &(&2 ++ ((Map.get(&1, "corrected_text") || Map.get(&1, "text")) |> String.split))) end)
