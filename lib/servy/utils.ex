
defmodule Servy.Utils do

  require Logger

  def log(conv), do: IO.inspect conv

  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(conv), do: conv

  def track( %{ status: 404, path: path} = conv) do
    Logger.warn "Path #{path} not found!"
    conv
  end

  def track(conv), do: conv

end
