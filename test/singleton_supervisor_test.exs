defmodule SingletonSupervisorTest do
  use ExUnit.Case

  defmodule MySingleSupervisor do
    use Supervisor

    def start_link(init_arg) do
      SingletonSupervisor.start_link(__MODULE__, init_arg)
    end

    def init(_init_arg) do
      children = []
      Supervisor.init(children, strategy: :one_for_one)
    end
  end

  test "only one instance of a SingletonSupervisor starts and when it stops its placeholders will also stop" do
    options = [children: [], strategy: :one_for_one]
    {:ok, supervisor} = SingletonSupervisor.start_link(options)
    {:ok, placeholder1} = SingletonSupervisor.start_link(options)
    {:ok, placeholder2} = SingletonSupervisor.start_link(options)

    assert {:state, {:global, SingletonSupervisor}, _, _, _, _, _, _, _, _, _} =
             :sys.get_state(supervisor)

    assert {_ref, ^supervisor, {:global, SingletonSupervisor}} = :sys.get_state(placeholder1)
    assert {_ref, ^supervisor, {:global, SingletonSupervisor}} = :sys.get_state(placeholder2)

    ref1 = Process.monitor(placeholder1)
    ref2 = Process.monitor(placeholder2)

    Supervisor.stop(supervisor)

    assert_receive {:DOWN, ^ref1, :process, placeholder1, :normal}
    assert_receive {:DOWN, ^ref2, :process, placeholder2, :normal}
  end

  test "multiple SingletonSupervisors with different names" do
    {:ok, supervisor1} =
      SingletonSupervisor.start_link(
        children: [],
        strategy: :one_for_one,
        name: {:global, SingletonSupervisor1}
      )

    {:ok, supervisor2} =
      SingletonSupervisor.start_link(
        children: [],
        strategy: :one_for_one,
        name: {:global, SingletonSupervisor2}
      )

    assert {:state, {:global, SingletonSupervisor1}, _, _, _, _, _, _, _, _, _} =
             :sys.get_state(supervisor1)

    assert {:state, {:global, SingletonSupervisor2}, _, _, _, _, _, _, _, _, _} =
             :sys.get_state(supervisor2)
  end

  test "module-based SingletonSupervisor" do
    assert {:ok, supervisor} = MySingleSupervisor.start_link([])
    assert {:ok, placeholder} = MySingleSupervisor.start_link([])

    assert {:state, {:global, MySingleSupervisor}, _, _, _, _, _, _, _, _, _} =
             :sys.get_state(supervisor)

    assert {_ref, ^supervisor, {:global, MySingleSupervisor}} = :sys.get_state(placeholder)
  end

  test "start SingletonSupervisor under a supervisor" do
    {:ok, supervisor1} =
      Supervisor.start_link([{SingletonSupervisor, children: [], strategy: :one_for_one}],
        strategy: :one_for_one
      )

    {:ok, supervisor2} =
      Supervisor.start_link([{SingletonSupervisor, children: [], strategy: :one_for_one}],
        strategy: :one_for_one
      )

    assert [{SingletonSupervisor, supervisor, :supervisor, [SingletonSupervisor]}] =
             Supervisor.which_children(supervisor1)

    assert [{SingletonSupervisor, placeholder, :supervisor, [SingletonSupervisor]}] =
             Supervisor.which_children(supervisor2)

    assert {:state, {:global, SingletonSupervisor}, _, _, _, _, _, _, _, _, _} =
             :sys.get_state(supervisor)

    assert {_ref, ^supervisor, {:global, SingletonSupervisor}} = :sys.get_state(placeholder)
  end
end
