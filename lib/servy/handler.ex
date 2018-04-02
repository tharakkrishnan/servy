defmodule Servy.Handler do
  @moduledoc """
  Handles requests-
    parses, logs, rewrites, routes and then responds to requests
  """
  import Servy.Parser, only: [parse: 1]
  import Servy.Utils, only: [log: 1, track: 1, rewrite_path: 1]
  alias Servy.Conv
  @pages_path Path.expand("pages", File.cwd!())

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

  def route(%Conv{ method: "POST", path: "/bears" } = conv) do
    %{conv | status: 201, resp_body: "Added #{conv.params["type"]} bear named #{conv.params["name"]}."}
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
    IO.puts(@pages_path)

    file_path = Path.join(@pages_path, "about.html")

    case File.read(file_path) do
      {:ok, content} ->
        %{conv | status: 200, resp_body: content}

      {:error, :enoent} ->
        %{conv | status: 404, resp_body: "File not found!"}

      {:error, reason} ->
        %{conv | status: 500, resp_body: "File error #{reason}"}
    end
  end

  def route(%Conv{method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{method: "GET", path: "/bears"} = conv) do
    %{conv | status: 200, resp_body: "Teddy, Smokey, Paddington"}
  end

  def route(%Conv{method: "GET", path: "/bears/" <> id} = conv) do
    %{conv | status: 200, resp_body: "bears " <> id}
  end

  def route(%Conv{path: path} = conv) do
    %{conv | status: 404, resp_body: "No #{path} found!"}
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.response_full(conv)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end
end

defmodule Servy.Requests do
  alias Servy.Handler
  def format_get_request(resource) do
    """
    GET /#{resource} HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*

    """
  end

  def get_resource(resource) do
    resource
    |> format_get_request
    |> Handler.handle()
    |> IO.puts()
  end

  def format_post_request(resource, params) do
    """
    POST /#{resource} HTTP/1.1
    Host: example.com
    User-Agent: ExampleBrowser/1.0
    Accept: */*
    Content-Type: application/x-www-form-urlencoded
    Content-Length: 21

    #{params}
    """
  end

  def post_resource(resource, params) do
    resource
    |> format_post_request(params)
    |> Handler.handle()
    |> IO.puts()
  end
end

Enum.each(["wildthings", "bears", "bears/1", "bigfoot", "about"], fn x -> Servy.Requests.get_resource(x) end)

Enum.each([%{ resource: "bears", params: "name=Baloo&type=Brown" }], fn x -> Servy.Requests.post_resource(x.resource, x.params) end)
