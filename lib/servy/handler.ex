defmodule  Servy.Handler do
  @moduledoc """
  Handles requests-
    parses, logs, rewrites, routes and then responds to requests
  """
  import Servy.Parser, only: [parse: 1]
  import Servy.Utils, only: [log: 1, track: 1, rewrite_path: 1]

  @pages_path Path.expand("pages", File.cwd!)

  @doc """
  main handler for our server
  """
  def handle(request) do

    request
    |> parse
    |> log
    |> rewrite_path
    |> route
    |> track
    |> format_response

  end

  def route(%{ method: "GET", path: "/about" } = conv) do
    IO.puts @pages_path

    file_path = Path.join(@pages_path, "about.html")
    case File.read(file_path) do
      {:ok, content} ->
         %{ conv | status: 200, resp_body: content }
      {:error, :enoent} ->
        %{ conv | status: 404, resp_body: "File not found!" }
      {:error, reason} ->
        %{ conv | status: 500, resp_body: "File error #{reason}" }
    end
  end

  def route(%{ method: "GET", path: "/wildthings" } = conv) do
    %{ conv | status: 200, resp_body: "Bears, Lions, Tigers" }
  end

  def route(%{ method: "GET", path: "/bears" } = conv) do
    %{ conv | status: 200, resp_body: "Teddy, Smokey, Paddington" }
  end

  def route(%{ method: "GET", path: "/bears/" <> id } = conv) do
    %{ conv | status: 200, resp_body: "bears " <> id }
  end

  def route(%{ path: path } = conv) do
    %{ conv | status: 404, resp_body: "No #{path} found!" }
  end


  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
  end


  def format_request(resource) do
    """
    GET /#{resource} HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*
    """
  end

  def get_resource(resource) do
    resource
    |> format_request
    |> Servy.Handler.handle
    |> IO.puts
  end
end

Enum.each(["wildthings", "bears", "bears/1", "bigfoot", "about"], fn(x) -> Servy.Handler.get_resource(x) end)

