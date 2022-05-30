defmodule RegnoWeb.MonerodGetInfoView do
  use RegnoWeb, :live_view
  require Logger

  def render(assigns) do
    ~H"""
    <h2 class="font-bold text-lg mb-3 mt-10">Monerod info</h2>
    <%= if assigns[:get_info] do %>
      <div class="grid gap-x-10 gap-y-4 grid-flow-col-dense grid-cols-3 grid-rows-3">
        <div class="flow-root hover:font-bold">
          <span>Current height:</span><span class="float-right"><%= @get_info["height"] %></span>
        </div>
        <div class="flow-root hover:font-bold">
          <span>Version:</span><span class="float-right"><%= @get_info["version"] %></span>
        </div>
        <div class="flow-root hover:font-bold">
          <span>Network:</span><span class="float-right"><%= @get_info["nettype"] %></span>
        </div>
        <%= if !@get_info["synchronized"] do %>
          <div class="flow-root hover:font-bold">
          <span>Target height:</span><span class="float-right"><%= @get_info["target_height"] %></span>
          </div>
        <% end %>
        <div class="flow-root hover:font-bold">
          <span>Synchronized:</span><span class="float-right"><%= @get_info["synchronized"] %></span>
        </div>
        <div class="flow-root hover:font-bold">
          <span>Difficulty:</span><span class="float-right"><%= @get_info["difficulty"] %></span>
        </div>
        <div class="flow-root hover:font-bold">
          <span>RPC connections:</span><span class="float-right"><%= @get_info["rpc_connections_count"] %></span>
        </div>
        <div class="flow-root hover:font-bold">
          <span>TX pool size</span><span class="float-right"><%= @get_info["tx_pool_size"] %></span>
        </div>
        <div class="flow-root hover:font-bold">
          <span>Outgoing connections: </span><span class="float-right"><%= @get_info["outgoing_connections_count"] %></span>
        </div>
        <div class="flow-root hover:font-bold">
          <span>Incoming connections:</span><span class="float-right"><%= @get_info["incoming_connections_count"] %></span>
        </div>
      </div>
    <% else %>
    <p>Waiting to connect to monerod...</p>
    <% end %>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :update, 5000)
    end

    Logger.info("MonerodGetInfoView: mount")
    case monerod_get_info() do
      {:ok, get_info} ->
        {:ok, assign(socket, :get_info, get_info)}
      {:error, reason} ->
        {:ok, put_flash(socket, :error, reason)}
    end
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 5000)
    Logger.info("MonerodGetInfoView: handle_info")
    case monerod_get_info() do
      {:ok, get_info} ->
        {:noreply, assign(socket, :get_info, get_info)}
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, reason)}
    end
  end

  def monerod_get_info() do
    case Monero.Daemon.get_info |> Monero.request do
      {:ok, info} ->
        {:ok, info}

      {:error, reason} ->
        error = "Failed to do get_info: #{reason}"
        Logger.error(error)
        {:error, error}
    end
  end
end
