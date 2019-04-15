defmodule Benchmark do
  def run(config) do
    events = generate_events(config.events)
    install_handlers(config.handlers, events)
    {counter, tasks} = start_tasks(config.processes, events)
    IO.puts("Started #{length(tasks)} tasks. Running..")
    Process.sleep(config.duration * 1000)
    stop_tasks(tasks)
    :counters.get(counter, 1)
  end

  defp generate_events(count) do
    for i <- 1..count do
      [:benchmark, :"#{i}"]
    end
  end

  defp install_handlers(count, events) do
    for i <- 1..count do
      :telemetry.attach_many(i, events, &__handle_event__/4, nil)
    end
  end

  defp start_tasks(count, events) do
      counter = :counters.new(1, [:write_concurrency])
    tasks = for {_, event} <- Enum.zip(1..count, events) do
      fun = fn -> :telemetry.execute(event, %{}, %{}) end
      spawn_link(fn -> execute_task(fun, counter) end)
    end
    {counter, tasks}
  end


  defp stop_tasks(tasks) do
    for task <- tasks do
      Process.unlink(task)
      Process.exit(task, :kill)
    end
  end

  defp execute_task(fun, counter) do
    fun.()
    :counters.add(counter, 1, 1)
    execute_task(fun, counter)
  end

  defp __handle_event__(_, _, _, _) do
    :ok
  end
end

{config, _, _} =
  OptionParser.parse(
    System.argv(),
    strict: [
      processes: :integer,
      handlers: :integer,
      events: :integer,
      duration: :integer
    ],
    aliases: [p: :processes, h: :handlers, e: :events, d: :duration]
  )

config =
  Map.merge(
    %{
      processes: 1000,
      handlers: 1,
      events: 1,
      duration: 60
    },
    Map.new(config)
  )

IO.puts("Starting benchmark with config #{inspect(config)}")
result = Benchmark.run(config)
IO.puts("Done. Number of iterations: #{result}")
