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
  is_asleep::Bool
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

open(ARGS[1]) do file
  records = map(process_line, eachline(file))
  sort!(records, by=record -> record.datetime)

  for record in records
    println(record)
  end
end

