defmodule RegnoWeb.MonerodGetInfoView do
  use RegnoWeb, :live_view
  require Logger

  def render(assigns) do
    ~H"""
    <h2 class="font-bold text-lg mb-3 mt-10">Monerod info</h2>
    <%= if assigns[:get_info] do %>
      <div class="grid text-sm gap-x-10 gap-y-4 grid-flow-row-dense sm:grid-flow-col-dense lg:grid-cols-3 lg:grid-rows-3 sm:grid-cols-2 sm:grid-rows-5">
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
    <p>Waiting for monerod...</p>
    <% end %>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket) do
      send(self(), {:request_update})
    end

    Logger.info("MonerodGetInfoView: mount")
    {:ok, socket}
  end

  def handle_info({:request_update}, socket) do
    Task.async(fn -> monerod_get_info() end)
    {:noreply, socket}
  end

  def handle_info({:DOWN, ref, _, _, reason}, state) do
    Logger.info("Task finished with reason #{inspect(reason)}")
    Process.send_after(self(), {:request_update}, 5000)
    {:noreply, state}
  end

  def handle_info({ref, result}, socket) do
    Logger.info("MonerodGetInfoView: handle_info")
    case result do
      {:ok, get_info} ->
        {:noreply, assign(socket, :get_info, get_info)}
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, reason)}
    end
  end

  def monerod_get_info() do
    Monero.Daemon.get_info |> Monero.request
  end

end
