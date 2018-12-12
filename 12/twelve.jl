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
  println(index)
  println(result)
  println()
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

  generations = 50000000000
  generations = 20
  for index in 1:generations
    if index % 100000 == 0
      println(index)
    end
    next = Dict()
    minn = minimum(row)[1] - 4
    maxx = maximum(row)[1] + 4
    for index in minn:maxx
      llcrr = get_llcrr(row, index)
      next[index] = get(transitions, llcrr, ".")
    end
    row = next

    #println(index, " ", minn, " ", maxx)
    #print_row(row)
  end

  total = 0
  for kv in row
    position, char = kv
    if char == '#' || char == "#"
      total += position
    end
  end
  println(total)
end
