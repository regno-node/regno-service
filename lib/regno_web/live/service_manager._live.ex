defmodule RegnoWeb.ServiceManagerView do
  use RegnoWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {
      :ok,
      socket
      |> assign(output: "")
      |> assign(current_task: nil)
    }
  end

  def handle_event("run_cmd", %{"cmd" => cmd}, %{assigns: %{current_task: nil}} = socket) do
    my_pid = self()
    {:noreply, assign(socket, :current_task, Task.async(fn -> run_cmd(cmd, my_pid) end))}
  end

  def handle_event("run_cmd", _, %{assigns: %{current_task: task}} = socket) when task != nil do
    IO.puts("Cmd already running. Not starting a new one.")
    {:noreply, put_flash(socket, :error, "A command is already running.")}
  end

  defp run_cmd("regno_start", pid), do: Regno.ServiceCommand.start(pid)
  defp run_cmd("regno_stop", pid), do: Regno.ServiceCommand.stop(pid)
  defp run_cmd("regno_help", pid), do: Regno.ServiceCommand.help(pid)

  def handle_info({:cmd_output, ref, cmd_output}, %{assigns: %{current_task: %Task{pid: ref}}} = socket) do
    {:noreply, update(socket, :output, fn output -> "#{output}\n#{cmd_output}" end)}
  end

  def handle_info({ref, result}, socket) do
    IO.puts("ServiceManagerView task result: #{inspect(result)}")
    Process.demonitor(ref, [:flush])
    {:noreply, assign(socket, :current_task, nil)}
  end

  def handle_info({:DOWN, ref, _, _, reason}, socket) do
    IO.puts("ServiceManagerView task #{inspect(ref)} finished with reason #{inspect(reason)}")
    {:noreply, assign(socket, :current_task, nil)}
  end

  def render(assigns) do
    ~L"""
    <div>
      <h2 class="font-bold text-lg mb-3 mt-10">Services</h2>
      <button phx-click="run_cmd" phx-value-cmd="regno_start" <%= if @current_task != nil, do: "disabled" %> >Start all</button>
      <button phx-click="run_cmd" phx-value-cmd="regno_stop" <%= if @current_task != nil, do: "disabled" %>>Stop all</button>
      <button phx-click="run_cmd" phx-value-cmd="regno_help" <%= if @current_task != nil, do: "disabled" %>>Help</button>
      <div id="terminal" class="terminal-window" phx-hook="TerminalScroll">
        <pre><%= @output %></pre>
      </div>
    </div>
    """
  end
end
