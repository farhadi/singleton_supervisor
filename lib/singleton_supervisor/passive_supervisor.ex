defmodule SingletonSupervisor.PassiveSupervisor do
  use GenServer

  def start_link(active_supervisor) do
    GenServer.start_link(__MODULE__, active_supervisor)
  end

  def init(active_supervisor) do
    Process.monitor(active_supervisor)
    {:ok, active_supervisor}
  end

  def handle_info({:DOWN, _ref, :process, active_supervisor, _reason}, active_supervisor) do
    {:stop, :normal, active_supervisor}
  end
end
