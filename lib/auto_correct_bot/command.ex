defmodule Command do
	@callback run({Nostrum.Struct.Message, }) :: :ok | :error
	@callback help({Nostrum.Struct.Message, }) :: :ok | :error
end
