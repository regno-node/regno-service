defmodule RegnoWeb.ServiceManagerView do
  use RegnoWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, assign(socket, output: "")}
  end

  def handle_event("run_regno_start", _value, socket) do
    IO.puts("Received run_regno_start")
    Task.async(fn -> Regno.ServiceManager.start(self()) end)
    {:noreply, socket}
  end

  def handle_event("run_regno_stop", _value, socket) do
    IO.puts("Received run_regno_stop")
    Task.async(fn -> Regno.ServiceManager.stop(self()) end)
    {:noreply, socket}
  end

  def handle_event("run_regno_sync", _value, socket) do
    IO.puts("Received run_regno_sync")
    Task.async(fn -> Regno.ServiceManager.sync(self()) end)
    {:noreply, socket}
  end

  def handle_info({:service_manager_output, line}, socket) do
    IO.puts("Received output: #{line}")
    {:noreply, update(socket, :output, fn output -> "#{output}\n#{line}" end)}
  end

  def handle_info({_ref, result}, socket) do
    IO.puts("ServiceManagerView task result: #{inspect(result)}")
    {:noreply, update(socket, :output, fn output -> "#{output}\n#{elem(result, 0)}" end)}
  end

  def handle_info({:DOWN, ref, _, _, reason}, state) do
    IO.puts "ServiceManagerView task #{inspect(ref)} finished with reason #{inspect(reason)}"
    {:noreply, state}
  end

  def render(assigns) do
    ~H"""
    <div>
      <h2 class="font-bold text-lg mb-3 mt-10">Services</h2>
      <button phx-click="run_regno_start">Start all</button>
      <button phx-click="run_regno_stop">Stop all</button>
      <button phx-click="run_regno_sync">Sync services</button>
      <div id="terminal" class="terminal-window" phx-hook="TerminalScroll">
        <pre><%= @output %></pre>
      </div>
    </div>
    """
  end
end
