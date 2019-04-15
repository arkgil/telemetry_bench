defmodule Benchmark do
  def start(config) do
    events = generate_events(config.events)
    install_handlers(config.handlers, events)
    IO.puts("Installed handlers")

    Task.async(fn ->
      tasks = start_tasks(config.processes, config.iterations, events)
      sum = await_tasks(tasks)

      (System.convert_time_unit(sum, :native, :millisecond) / config.processes / config.iterations)
      |> Float.round(3)
    end)
  end

  def await(task) do
    case Task.yield(task, 5000) do
      {:ok, avg} ->
        avg

      nil ->
        :calendar.local_time()
        |> NaiveDateTime.from_erl!()
        |> NaiveDateTime.to_iso8601()
        |> IO.puts()

        await(task)
    end
  end

  defp start_tasks(count, iterations, events) do
    events = Stream.cycle(events)

    Enum.reduce_while(events, {count, []}, fn
      _event, {0, tasks} ->
        {:halt, tasks}

      event, {count, tasks} ->
        t = start_task(event, iterations)
        {:cont, {count - 1, [t | tasks]}}
    end)
  end

  defp await_tasks(tasks) do
    tasks |> Enum.map(&Task.await(&1, :infinity)) |> Enum.sum()
  end

  defp start_task(event, iterations) do
    Task.async(fn ->
      for _ <- 1..iterations, reduce: 0 do
        sum ->
          start = System.monotonic_time()
          :telemetry.execute(event, %{}, %{})
          diff = System.monotonic_time() - start
          sum + diff
      end
    end)
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
      iterations: :integer,
      events: :integer
    ],
    aliases: [p: :processes, h: :handlers, i: :iterations, e: :events]
  )

config =
  Map.merge(
    %{
      processes: 1000,
      handlers: 1,
      iterations: 10000,
      events: 1
    },
    Map.new(config)
  )

IO.puts("Starting benchmark with config #{inspect(config)}")

:observer.start()
Process.sleep(10_000)

task = Benchmark.start(config)
avg = Benchmark.await(task)

IO.puts("Done. Average execute/2 time was #{avg}ms.")
IO.gets("Press any key to exit..")
