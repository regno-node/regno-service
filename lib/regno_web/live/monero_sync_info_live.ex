defmodule RegnoWeb.MonerodSyncInfoView do
  use RegnoWeb, :live_view
  require Logger

  def render(assigns) do
    ~H"""
    <h2 class="text-lg font-bold mb-3 mt-10">Connected peers</h2>
    <%= if assigns[:sync_info] do %>
    <div class="overflow-x-auto border-x border-t rounded-sm">
    <table class="table-auto w-full">
    <thead class="border-b">
    <tr class="bg-gray-100 dark:bg-slate-700">
      <th class="text-left p-4 font-medium">Peer ID</th>
      <th class="text-left p-4 font-medium">Host:port</th>
      <th class="text-left p-4 font-medium">Block height</th>
      <th class="text-left p-4 font-medium">Incoming?</th>
      <th class="text-left p-4 font-medium">Live time</th>
      <th class="text-left p-4 font-medium">Send idle time</th>
      <th class="text-left p-4 font-medium">Recv idle time</th>
    </tr>
    </thead>
    <tbody>
      <%= for peer <- @sync_info["peers"] do %>
        <tr class="border-b hover:bg-gray-50 dark:hover:bg-zinc-700">
          <td class="p-3"><%= peer["info"]["peer_id"] %></td>
          <td class="p-3"><%= peer["info"]["address"] %></td>
          <td class="p-3"><%= peer["info"]["height"] %></td>
          <td class="p-3"><%= peer["info"]["incoming"] %></td>
          <td class="p-3"><%= peer["info"]["live_time"] %></td>
          <td class="p-3"><%= peer["info"]["send_idle_time"] %></td>
          <td class="p-3"><%= peer["info"]["recv_idle_time"] %></td>
        </tr>
      <% end %>
    </tbody>
    </table>
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

    Logger.info("MonerodSyncInfoView: mount")

    case get_sync_info() do
      {:ok, sync_info} ->
        {:ok, assign(socket, :sync_info, sync_info)}

      {:error, reason} ->
        {:ok, put_flash(socket, :error, reason)}
    end
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 5000)
    Logger.info("MonerodSyncInfoView: handle_info")

    case get_sync_info() do
      {:ok, sync_info} ->
        {:noreply, assign(socket, :sync_info, sync_info)}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, reason)}
    end
  end

  def get_sync_info() do
    case Monero.Daemon.sync_info() |> Monero.request() do
      {:ok, infos} ->
        {:ok, infos}

      {:error, reason} ->
        error = "Failed to get sync_info: #{reason}"
        Logger.error(error)
        {:error, error}
    end
  end
end
