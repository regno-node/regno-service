

defmodule Regno.ServiceManager do
  @regno_script_path "../regno/regno.sh"

  def start(pid) do
    System.cmd("bash", [@regno_script_path, "start"], stderr_to_stdout: true)
  end

  def stop(pid) do
    System.cmd("bash", [@regno_script_path, "stop"], stderr_to_stdout: true)
  end

  def sync(pid) do
    System.cmd("bash", [@regno_script_path, "sync"], stderr_to_stdout: true)
  end
end
