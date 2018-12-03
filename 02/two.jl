open("input") do file
  twos = 0
  threes = 0

  for line in eachline(file)
    sorted = join(sort(split(line, "")))
    println(line)

    is2 = false
    is3 = false

    max = length(sorted)
    i = 1
    while i < max
      c1 = get(sorted, i, "")
      c2 = get(sorted, i + 1, "")
      c3 = get(sorted, i + 2, "")
      c4 = get(sorted, i + 3, "")
      println(c1, c2, c3, c4)

      if c1 == c2 && c2 == c3 && c3 == c4
        # there's more than three characters in a row
        # so skip forward until a new character appears
        i += 1
        while sorted[i] == c1 && i < max
          i += 1
        end
      elseif !is3 && c1 == c2 && c2 == c3
        threes += 1
        is3 = true
        i += 3
      elseif !is2 && c1 == c2
        twos += 1
        is2 = true
        i += 2
      else
        i += 1
      end
    end
    println()
  end

  println("twos:", twos)
  println("threes:", threes)
  println("mult:", twos * threes)
end

