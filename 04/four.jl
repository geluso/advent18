using Dates
using IterTools

struct Record
  datetime::DateTime
  info
end

struct ShiftRecord
  guard_id::Int
end

struct SleepRecord
  is_sleeping::Bool
end

function timestamp_to_datetime(date, time)
  # pick off leading and trailing brackets
  date = date[2:end]
  time = time[1:end - 1]

  year, month, day = split(date, "-")
  hour, minute = split(time, ":")

  vars = [year, month, day, hour, minute]
  strToInt = str -> parse(Int, str)
  year, month, day, hour, minute = map(strToInt, vars)

  return DateTime(year, month, day, hour, minute)
end

function process_line(line)
  cells = split(line, " ")

  date, time = cells
  stamp = timestamp_to_datetime(date, time)
  info = nothing

  if length(cells) == 4
    _, _, status = cells
    info = SleepRecord(status == "falls")
  else
    _, _, _, id = cells
    id = parse(Int, id[2:end])
    info = ShiftRecord(id)
  end

  record = Record(stamp, info)
  return record
end

function tally_sleeping_times(records)
  tally = Dict()

  last_time = records[1].datetime
  last_guard = records[1].info.guard_id
  last_sleeping = false

  for record in records
    next_time = record.datetime

    # assume the sleeping state and guard state don't change
    next_sleeping = last_sleeping
    next_guard = last_guard

    if typeof(record.info) == ShiftRecord
      next_guard = record.info.guard_id
    elseif typeof(record.info) == SleepRecord
      next_sleeping = record.info.is_sleeping
    end

    # guard woke up
    if last_sleeping && !next_sleeping
      slept = Dates.value(Dates.Minute(next_time - last_time))
      total = get(tally, last_guard, 0)
      total += slept
      tally[last_guard] = total
    end
    
    last_time = next_time
    last_guard = next_guard
    last_sleeping = next_sleeping
  end
  return tally
end

function extract_sleep_records(id, records)
  sleeps = []
  current_guard = records[1].info.guard_id

  for record in records
    if current_guard == id && typeof(record.info) == SleepRecord
      push!(sleeps, record)
    elseif typeof(record.info) == ShiftRecord
      current_guard = record.info.guard_id
    end
  end

  return sleeps
end

function tally_minutes(records)
  minutes = Dict()

  for pair in partition(records, 2)
    sleep, wake = pair
    sleep = Dates.value(Dates.Minute(sleep.datetime))
    wake = Dates.value(Dates.Minute(wake.datetime)) - 1

    for minute in sleep:wake
      count = get(minutes, minute, 0)
      count += 1
      minutes[minute] = count
    end
  end

  return findmax(minutes)[2]
end

open(ARGS[1]) do file
  records = map(process_line, eachline(file))
  sort!(records, by=record -> record.datetime)

  tally = tally_sleeping_times(records)
  total, id = findmax(tally)

  println("id: ", id)
  println("total: ", total)

  sleep_records = extract_sleep_records(id, records)
  most_common_minute = tally_minutes(sleep_records)

  println("most common minute: ", most_common_minute)
  println("multiplied: ", id * most_common_minute)
end

