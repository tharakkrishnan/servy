defmodule Servy.Parser do
@moduledoc """
functions that help in parsing the request
"""
alias Servy.Conv
 @doc """
  parse the request
  """

  def parse(request) do
    [ top, params ] = String.split(request, "\n\n")
    [ request_line | _ ] = String.split(top, "\n")
    [ method, path, _ ] = String.split(request_line, " ")
    params = parse_params(params)

    %Conv{ method: method, path: path, params: params }
  end

  def parse_params(params) do
    params |> String.trim |> URI.decode_query
  end
end
