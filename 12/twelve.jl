function print_row(pots)
  index = ""
  result = ""
  minn = minimum(pots)[1]
  maxx = maximum(pots)[1]
  for i in minn:maxx
    if i < 0
      index = string(index, " ")
    else
      index = string(index, i % 10)
    end
    result = string(result, get(pots, i, "."))
  end
  
  return result
end

function get_llcrr(pots, index)
  l1 = get_pot(pots, index - 2)
  l2 = get_pot(pots, index - 1)
   c = get_pot(pots, index)
  r1 = get_pot(pots, index + 1)
  r2 = get_pot(pots, index + 2)
  return string(l1, l2, c, r1, r2)
end

function get_pot(pots, index)
  return get(pots, index, ".")
end

open(ARGS[1]) do file
  current = nothing
  transitions = Dict()

  index = 1
  for line in eachline(file)
    if index == 1
      current = split(line, "initial state: ")[2]
    elseif index > 2
      state, result = split(line, " => ")
      transitions[state] = result
    end
    index += 1
  end

  row = Dict()
  for index in 1:length(current)
    row[index - 1] = current[index]
  end

  seen_rows = Dict()
  zero_index = 0

  generation = 0
  max_generations = 20
  max_generations = 50000000000

  last_total = 0
  diff = 0
  found_repeat = false
  while !found_repeat
    generation += 1

    next = Dict()
    minn = minimum(row)[1] - 4
    maxx = maximum(row)[1] + 4
    for index in minn:maxx
      llcrr = get_llcrr(row, index)
      next[index] = get(transitions, llcrr, ".")
    end
    row = next

    result = print_row(row)

    start = findfirst("#", result)[1]
    finish = findlast("#", result)[1]
    trimmed = result[start:finish]
    #println(trimmed, " ", start, " ", generation)

    total = 0
    minn = minimum(row)[1]
    maxx = maximum(row)[1]
    for index in minn:maxx
      got = get(row, index, ".")
      if got == '#' || got == "#"
        total += index
      end
    end

    diff = total - last_total
    println("gen: ", generation, " total: ", total, " diff: ", total - last_total)
    last_total = total

    if get(seen_rows, trimmed, false)
      found_repeat = true
    end
    seen_rows[trimmed] = true
  end

  left = max_generations - generation
  result = last_total + diff * left
  println(result)
end
