
defmodule Servy.Utils do

  require Logger
  alias Servy.Conv

  def log(conv), do: IO.inspect conv

  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(%Conv{} = conv), do: conv

  def track( %Conv{ status: 404, path: path} = conv) do
    Logger.warn "Path #{path} not found!"
    conv
  end

  def track(%Conv{} = conv), do: conv

end
