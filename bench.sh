#!/bin/bash

MIX_ENV=prod
OUTPUT="${1}"

schedulers=4
events=1
handlers=1

echo "" >"${OUTPUT}"
echo "schedulers: $schedulers" >>"${OUTPUT}"
echo "events: $events" >>"${OUTPUT}"
echo "handlers: $handlers" >>"${OUTPUT}"
echo "" >>"${OUTPUT}"
echo "processes,iterations" >>"${OUTPUT}"

for processes in {1..8}; do
  RESULT=$(elixir --erl "+S $schedulers:$schedulers" -S mix bench_v3 -p $processes -e $events -h $handlers | tail -n 1)
  echo "$processes,${RESULT}" >>"${OUTPUT}"
done
