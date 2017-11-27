defmodule Tesla.Adapter.Shared do
  @moduledoc false

  def capture_query_params(%Tesla.Env{method: :get} = env) do
    if String.contains?(env.url, "?") do
      query_params =
        (env.url |> URI.parse()).query |> URI.decode_query() #|> Map.to_list()
        # query_params = for {key, val} <- query_params, into: [], do: {String.to_atom(key), val}

      %{env | query: query_params}
    else
      env
    end
  end
  def capture_query_params(env), do: env

  def stream_to_fun(stream) do
    reductor = fn(item, _acc) -> {:suspend, item} end
    {_, _, fun} = Enumerable.reduce(stream, {:suspend, nil}, reductor)

    fun
  end

  def next_chunk(fun), do: parse_chunk fun.({:cont, nil})

  defp parse_chunk({:suspended, item, fun}), do: {:ok, item, fun}
  defp parse_chunk(_),                       do: :eof
end
