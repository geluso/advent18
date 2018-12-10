mutable struct Point
  px
  py
  vx
  vy
end

open(ARGS[1]) do file
  points = []

  minx, miny, maxx, maxy = 0, 0, 0, 0
  for line in eachline(file)
    pos, vel = split(line, "> v")
    pos = split(pos, "position=<")[2]
    vel = split(split(vel, "elocity=<")[2], ">")[1]

    px, py = split(pos, ",")
    vx, vy = split(vel, ",")

    px, py = parse(Int, px), parse(Int, py)
    vx, vy = parse(Int, vx), parse(Int, vy)
    pp = Point(px, py, vx, vy)
    push!(points, pp)

    minx = minimum([minx, px])
    miny = minimum([miny py])
    maxx = maximum([maxx, px])
    maxy = maximum([maxy, py])

    println(px, " ", py, " ", vx, " ", vy)
  end

  println("min: ", minx, " ", miny)
  println("max: ", maxx, " ", maxy)

  n = -1

  function tick(points)
    n = n + 1
    dots = Dict()
    minx, miny = points[1].px, points[1].py
    maxx, maxy = points[1].px, points[1].py
    for point in points
      key = string(point.px, ",", point.py)
      dots[key] = true
      point.px = point.px + point.vx
      point.py = point.py + point.vy

      minx = minimum([minx, point.px])
      miny = minimum([miny point.py])
      maxx = maximum([maxx, point.px])
      maxy = maximum([maxy, point.py])
    end

    dx = maxx - minx
    dy = maxy - miny
    score = dx + dy
    println(n, " ", score)

    is_drawing = false
    if score > 100
      return
    end
    readline(stdin)

    for xx in 0:(maxx - minx)
      for yy in 0:(maxy - miny)
        key = string(minx + xx, ",", miny + yy)
        if get(dots, key, false)
          print("#")
        else
          print(" ")
        end
      end
      println()
    end
  end

  while true
    tick(points)
  end
end

