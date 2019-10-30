defmodule SingletonSupervisor do
  @moduledoc """
  Singleton supervisor within an erlang cluster
  """

  def start_link(options) do
    {children, options} = Keyword.pop(options, :children, [])
    options = Keyword.put_new(options, :name, {:global, __MODULE__})

    with {:error, {:already_started, pid}} <- Supervisor.start_link(children, options) do
      SingletonSupervisor.PassiveSupervisor.start_link(pid)
    end
  end

  def start_link(module, init_arg, options \\ []) do
    with {:error, {:already_started, pid}} <- Supervisor.start_link(module, init_arg, options) do
      SingletonSupervisor.PassiveSupervisor.start_link(pid)
    end
  end

  def child_spec(options) do
    %{
      id: Keyword.get(options, :name, __MODULE__),
      start: {__MODULE__, :start_link, [options]},
      type: :supervisor
    }
  end
end
