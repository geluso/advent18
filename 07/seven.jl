function main()
  hierarchy = Dict()
  relies_on = Dict()
  all = Set()

  open(ARGS[1]) do file
    for line in eachline(file)
      first = line[6]
      next = line[37]

      push!(all, first, next)

      list = get(relies_on, next, [])
      relies_on[next] = list
      push!(list, first)

      list = get(hierarchy, first, [])
      hierarchy[first] = list
      push!(list, next)
    end
  end

  left = sort(collect(all))
  complete = []

  index = 1
  while length(left) > 0
    item = left[index]
    index += 1

    prereqs = get(relies_on, item, [])
    filter!(el -> !(el in complete), prereqs)

    if length(prereqs) == 0
      print(item)
      filter!(el -> el != item, left)
      push!(complete, item)
      index = 1
    end
  end
  println()
end

main()
