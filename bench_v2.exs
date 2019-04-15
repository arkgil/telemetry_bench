defmodule Benchmark do
  def setup(config) do
    events = generate_events(config.events)
    install_handlers(config.handlers, events)
    events
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
      warmup: :integer,
      duration: :integer
    ],
    aliases: [p: :processes, h: :handlers, e: :events, w: :warmup, d: :duration]
  )

config =
  Map.merge(
    %{
      processes: 1000,
      handlers: 1,
      events: 1,
      warmup: 10,
      duration: 60
    },
    Map.new(config)
  )

IO.puts("Starting benchmark with config #{inspect(config)}")

[event | _] = Benchmark.setup(config)

Benchee.run(%{
  "telemetry" => fn ->
    :telemetry.execute(event, %{}, %{})
  end
  },
  warmup: config.warmup,
  time: config.duration,
  parallel: config.processes
)
