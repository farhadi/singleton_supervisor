defmodule SingletonSupervisor.Placeholder do
  @moduledoc false
  use GenServer

  def start_link(supervisor_pid) do
    GenServer.start_link(__MODULE__, supervisor_pid)
  end

  def init(supervisor_pid) do
    ref = Process.monitor(supervisor_pid)
    {:ok, {ref, supervisor_pid}}
  end

  def handle_info({:DOWN, ref, :process, pid, _reason}, state = {ref, pid}) do
    {:stop, :normal, state}
  end
end
