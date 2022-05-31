defmodule RegnoWeb.MonerodConnectionsView do
  use RegnoWeb, :live_view
  require Logger
  alias Phoenix.LiveView.JS

  def render(assigns) do
    ~H"""
    <h2 class="text-lg font-bold mb-3 mt-10">Connected peers</h2>
    <%= if assigns[:connections] do %>
    <div class="overflow-x-auto border-x border-t rounded-sm">
    <table class="table-auto text-sm w-full">
    <thead class="border-b">
    <tr class="bg-gray-100 dark:bg-slate-700">
      <th phx-click={JS.push("sort", value: %{sort_key: "peer_id"})} class="text-left p-4 font-medium">Peer ID</th>
      <th phx-click={JS.push("sort", value: %{sort_key: "address"})} class="text-left p-4 font-medium">Host:port</th>
      <th phx-click={JS.push("sort", value: %{sort_key: "height"})} class="text-left p-4 font-medium">Block height</th>
      <th phx-click={JS.push("sort", value: %{sort_key: "incoming"})} class="text-left p-4 font-medium">Incoming?</th>
      <th phx-click={JS.push("sort", value: %{sort_key: "live_time"})} class="text-left p-4 font-medium">Live time</th>
      <th phx-click={JS.push("sort", value: %{sort_key: "send_idle_time"})} class="text-left p-4 font-medium">Send idle time</th>
      <th phx-click={JS.push("sort", value: %{sort_key: "recv_idle_time"})} class="text-left p-4 font-medium">Recv idle time</th>
    </tr>
    </thead>
    <tbody>
      <%= for peer <- @connections do %>
        <tr class="border-b hover:bg-gray-50 dark:hover:bg-zinc-700">
          <td class="p-3"><%= peer["peer_id"] %></td>
          <td class="p-3"><%= peer["address"] %></td>
          <td class="p-3"><%= peer["height"] %></td>
          <td class="p-3"><%= peer["incoming"] %></td>
          <td class="p-3"><%= peer["live_time"] %></td>
          <td class="p-3"><%= peer["send_idle_time"] %></td>
          <td class="p-3"><%= peer["recv_idle_time"] %></td>
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

    {:ok,
     socket
     |> assign(:sort_key, "live_time")
     |> assign(:sort_dir, :desc)
     |> get_connections()}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 5000)
    Logger.info("MonerodSyncInfoView: handle_info")
    {:noreply, get_connections(socket)}
  end

  def get_connections(socket) do
    case Monero.Daemon.get_connections() |> Monero.request() do
      {:ok, result} ->
        assign(
          socket,
          :connections,
          Enum.sort_by(
            result["connections"],
            fn peer -> peer[socket.assigns.sort_key] end,
            socket.assigns.sort_dir
          )
        )

      {:error, reason} ->
        error = "Failed to get connections: #{reason}"
        Logger.error(error)
        put_flash(socket, :error, reason)
    end
  end

  def handle_event("sort", %{"sort_key" => value}, socket) do
    if socket.assigns.sort_key == value do
      Logger.info("sort dir")
      {:noreply,
       socket
       |> assign(:sort_dir, toggle_sort_dir(socket.assigns.sort_dir))
       |> get_connections()
       }
    else
      {:noreply,
       socket
       |> assign(:sort_key, value)
       |> get_connections()}
    end
  end

  def toggle_sort_dir(:desc), do: :asc
  def toggle_sort_dir(:asc), do: :desc
end
