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

  function tick(points)
    dots = Dict()
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

    for xx in minx:maxx
      for yy in miny:maxy
        key = string(xx, ",", yy)
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
    readline(stdin)
  end
end

