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
    println(record)
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

      println("slept: ", slept)
      println("total ", last_guard, ": ", total)
    end
    
    last_time = next_time
    last_guard = next_guard
    last_sleeping = next_sleeping
  end
  return tally
end

open(ARGS[1]) do file
  records = map(process_line, eachline(file))
  sort!(records, by=record -> record.datetime)

  tally = tally_sleeping_times(records)
  total, id = findmax(tally)

  println("id: ", id)
  println("total: ", total)
end

