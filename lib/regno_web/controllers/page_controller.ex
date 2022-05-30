defmodule RegnoWeb.PageController do
  use RegnoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
