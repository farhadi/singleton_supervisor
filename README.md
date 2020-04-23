# SingletonSupervisor

Singleton supervisor within an erlang cluster

## Installation

The package can be installed by adding `singleton_supervisor` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:singleton_supervisor, "~> 0.2.0"}
  ]
end
```

## Usage

SingletonSupervisor can be added as a child to a supervision tree but should not be used as the top level application supervisor:

```elixir
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
```

SingletonSupervisor by default uses `{:global, SingletonSupervisor}` as process name and if you
want to use another name make sure you use a distributed registry that takes care of killing
duplicate instances.

SingletonSupervisor can also be used as a module-based supervisor:

```elixir
defmodule MyApp.SingletonSupervisor do
  use Supervisor

  def start_link(init_arg) do
    SingletonSupervisor.start_link(__MODULE__, init_arg, name: {:global, __MODULE__})
  end

  def init(_init_arg) do
    children = [
      # Children of SingletonSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
```