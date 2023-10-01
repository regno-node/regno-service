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
    <tr class="bg-gray-100 dark:bg-slate-700 text-left">
      <th phx-click={JS.push("sort", value: %{sort_key: "peer_id"})} class="cursor-pointer p-3 hover:text-orange-500">Peer ID</th>
      <th phx-click={JS.push("sort", value: %{sort_key: "address"})} class="cursor-pointer p-3 hover:text-orange-500">Host:port</th>
      <th phx-click={JS.push("sort", value: %{sort_key: "height"})} class="cursor-pointer p-3 hover:text-orange-500">Block height</th>
      <th phx-click={JS.push("sort", value: %{sort_key: "incoming"})} class="cursor-pointer p-3 hover:text-orange-500">Incoming?</th>
      <th phx-click={JS.push("sort", value: %{sort_key: "live_time"})} class="cursor-pointer p-3 text-right hover:text-orange-500">Live time</th>
      <th phx-click={JS.push("sort", value: %{sort_key: "send_idle_time"})} class="cursor-pointer p-3 text-right hover:text-orange-500">Send idle time</th>
      <th phx-click={JS.push("sort", value: %{sort_key: "recv_idle_time"})} class="cursor-pointer p-3 text-right hover:text-orange-500">Recv idle time</th>
    </tr>
    </thead>
    <tbody class="text-left">
      <%= for peer <- @connections do %>
        <tr class="border-b hover:bg-gray-50 dark:hover:bg-zinc-700">
          <td class="p-3"><%= peer["peer_id"] %></td>
          <td class="p-3"><%= peer["address"] %></td>
          <td class="p-3"><%= peer["height"] %></td>
          <td class="p-3"><%= peer["incoming"] %></td>
          <td class="p-3 text-right"><%= peer["live_time"] %></td>
          <td class="p-3 text-right"><%= peer["send_idle_time"] %></td>
          <td class="p-3 text-right"><%= peer["recv_idle_time"] %></td>
        </tr>
      <% end %>
    </tbody>
    </table>
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

    {:ok,
     socket
     |> assign(:sort_key, "live_time")
     |> assign(:sort_dir, :desc)}
  end

  def handle_info({:request_update}, socket) do
    Task.async(fn -> get_connections() end)
    {:noreply, socket}
  end

  def handle_info({:DOWN, ref, _, _, reason}, state) do
    Logger.info("MonerodSyncInfo update task finished with reason #{inspect(reason)}")
    Process.send_after(self(), {:request_update}, 5000)
    {:noreply, state}
  end

  def handle_info({ref, {:ok, %{"connections" => connections}}}, socket) do
    {:noreply, assign(socket, :connections, sort_connections(connections, socket.assigns.sort_key, socket.assigns.sort_dir))}
  end

  def sort_connections(connections, sort_key, sort_dir) do
    Enum.sort_by(
      connections,
      fn peer -> peer[sort_key] end,
      sort_dir
    )
  end

  def handle_info({ref, {:ok, _}}, socket) do
    {:noreply, assign(socket, :connections, [])}
  end

  def handle_info({ref, {:error, reason}}, socket) do
    {:noreply, put_flash(socket, :error, reason)}
  end

  def handle_info({:error, reason}, socket) do
    error = "Failed to get connections: #{reason}"
    Logger.error(error)
    {:noreply, put_flash(socket, :error, error)}
  end

  def get_connections() do
    Monero.Daemon.get_connections() |> Monero.request()
  end

  def handle_event("sort", %{"sort_key" => value}, socket) do
    if socket.assigns.sort_key == value do
      new_sort_dir = toggle_sort_dir(socket.assigns.sort_dir)
      {:noreply,
        socket
        |> assign(:sort_dir, new_sort_dir)
        |> assign(:connections, sort_connections(socket.assigns.connections, socket.assigns.sort_key, new_sort_dir))
      }
    else
      {:noreply,
       socket
       |> assign(:sort_key, value)
       |> assign(:sort_dir, :desc)
       |> assign(:connections, sort_connections(socket.assigns.connections, value, :desc))
      }
    end
  end

  def toggle_sort_dir(:desc), do: :asc
  def toggle_sort_dir(:asc), do: :desc
end
