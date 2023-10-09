defmodule Regno.ServiceCommand do
  @regno_script_path "../regno/regno.sh"

  def start(pid) do
    run_cmd(pid, "bash", [@regno_script_path, "start"])
  end

  def stop(pid) do
    run_cmd(pid, "bash", [@regno_script_path, "stop"])
  end

  def help(pid) do
    run_cmd(pid, "bash", [@regno_script_path, "-h"])
  end

  defp run_cmd(pid, cmd, args) do
    bash = System.find_executable("bash")
    port = Port.open({:spawn_executable, bash}, [:stderr_to_stdout, :binary, :line, :exit_status, args: args])
    IO.puts("Running cmd #{cmd} with pid: #{inspect(pid)}, port: #{inspect(port)}")
    stream_output(pid, port)
  end

  defp stream_output(pid, port) do
    receive do
      {^port, {:data, {:eol, data}}} ->
        send(pid, {:cmd_output, self(), data})
        stream_output(pid, port)
      {^port, {:exit_status, status}} ->
        status
    end
  end
end
