defmodule SingletonSupervisor do
  @moduledoc ~S"""
  A singleton supervisor within an erlang cluster.

  `SingletonSupervisor` by defualt uses `{:global, SingletonSupervisor}` as name, and further
  instances with the same name will not start a supervisor but a placeholder to monitor
  the already started one.

  When a `SingletonSupervisor` or its node fails or stops, all its placeholders will also stop,
  so that the parent supervisor of placeholders will try to restart the singleton supervisor
  and one of them will takeover and others will become placeholder monitoring the globally registered one.

  `SingletonSupervisor` by defaut uses `:global` registry, but any other distributed registry can be used
  if it takes care of killing duplicate instances.

  ## Examples

  SingletonSupervisor can be added as a child to a supervision tree but should not be used as the top level application supervisor:

    defmodule MyApp.Application do
      use Application

      def start(_type, _args) do
        children = [
          {SingletonSupervisor,
           strategy: :one_for_one,
           name: {:global, MyApp.SingletonSupervisor},
           children: [
             # Children of SingletonSupervisor
           ]}
        ]

        opts = [strategy: :one_for_one, name: MyApp.Supervisor]
        Supervisor.start_link(children, opts)
      end
    end

  SingletonSupervisor can also be used as a module-based supervisor:

    defmodule MyApp.SingletonSupervisor do
      use Supervisor

      def start_link(init_arg) do
        SingletonSupervisor.start_link(__MODULE__, init_arg)
      end

      def init(_init_arg) do
        children = [
          # Children of SingletonSupervisor
        ]

        Supervisor.init(children, strategy: :one_for_one)
      end
    end
  """

  def start_link(options) do
    {children, options} = Keyword.pop(options, :children, [])
    start_link(children, options)
  end

  def start_link(children, options) when is_list(children) do
    options = Keyword.put_new(options, :name, {:global, __MODULE__})

    with {:error, {:already_started, pid}} <- Supervisor.start_link(children, options) do
      SingletonSupervisor.Placeholder.start_link(pid)
    end
  end

  def start_link(module, init_arg, options \\ []) do
    options = Keyword.put_new(options, :name, {:global, module})

    with {:error, {:already_started, pid}} <- Supervisor.start_link(module, init_arg, options) do
      SingletonSupervisor.Placeholder.start_link(pid)
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
