defmodule SingletonSupervisor.Placeholder do
  @moduledoc false
  use GenServer

  def start_link(supervisor_pid, name) do
    GenServer.start_link(__MODULE__, {supervisor_pid, name})
  end

  def init({supervisor_pid, name}) do
    ref = Process.monitor(supervisor_pid)
    {:ok, {ref, supervisor_pid, name}}
  end

  def handle_info({:DOWN, ref, :process, pid, _reason}, state = {ref, pid, name}) do
    case whereis(name, pid) do
      nil -> {:stop, :normal, state}
      pid -> {:noreply, {Process.monitor(pid), pid, name}}
    end
  end

  defp whereis(name, old_pid) do
    with ^old_pid <- GenServer.whereis(name) do
      # It might happen that the registry is not updated and still returns the old pid,
      # so here we are busy waiting for the registry to get updated.
      # In the meantime if the scheduler doesn't switch to another process here, there will be
      # a high chance that the registry is still not updated, so here we yield control back
      # to the scheduler, giving other proesses including the registry more time to run.
      :erlang.yield()
      whereis(name, old_pid)
    end
  end
end
