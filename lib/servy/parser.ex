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
    [ request_line | header_string ] = String.split(top, "\n")
    [ method, path, _ ] = String.split(request_line, " ")
    headers = parse_headers(header_string, %{})
    params = parse_params(headers["Content-Type"], params)


    %Conv{ method: method, path: path, params: params, headers: headers }
  end

  def parse_headers([head | tail], headers) do
    [k,v] = String.split(head, ": ")
    headers = Map.put(headers, k,v)
    parse_headers(tail, headers)
  end

  def parse_headers([], headers), do: headers

  def parse_params("application/x-www-form-urlencoded", params) do
    params |> String.trim |> URI.decode_query
  end
  def parse_params(_, _), do: %{}
end
