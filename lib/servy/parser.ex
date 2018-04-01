defmodule Servy.Parser do
@moduledoc """
functions that help in parsing the request
"""

 @doc """
  parse the request
  """
  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first
      |> String.split(" ")

    %{method: method,
      path: path,
      resp_body: "",
      status: nil}
  end
end
