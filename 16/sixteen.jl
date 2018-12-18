import Base.string

mutable struct World
  map
  actors
  max_row
  max_col
end

World() = World(Dict(), Dict(), 0, 0)

mutable struct Actor
  race
  hp
  row
  col
end

function key(row, col)
  return string(row, ",", col)
end

function get_tile(world, row, col)
  key_ = key(row, col)

  actor = get(world.actors, key_, nothing)
  if actor != nothing
    return actor.race
  end

  is_floor = get(world.map, key_, false)
  if is_floor
    return '.'
  else
    return '#'
  end
end

function string(world::World)
  output = ""
  for row in 1:world.max_row
    line = ""
    for col in 1:world.max_col
      tile = get_tile(world, row, col)
      line = string(line, tile)
    end
    output = string(output, line, "\n")
  end
  return strip(output)
end

function build_world(file)
  world = World()
  row, col = 1,1

  for line in eachline(file)
    col = 1
    for cc in line
      key_ = key(row, col)
      if cc == '#'
        world.map[key_] = false
      elseif cc in ".GE"
        world.map[key_] = true
        if cc in "GE"
          actor = Actor(cc, 200, row, col)
          world.actors[key_] = actor
        end
      end
      col += 1
    end
    row += 1
  end

  world.max_row = row
  world.max_col = col
  return world
end

function tick(world)
  moved = false
  for actor in collect(values(world.actors))
    row, col = actor.row, actor.col
    key_ = key(row, col)
    if get_tile(world, row + 1, col) == '.'
      delete!(world.actors, key_)
      actor.row += 1
      world.actors[key(row + 1, col)] = actor
      moved = true
    end
  end
  return moved
end

function main()
  open(ARGS[1]) do file
    world = build_world(file)

    println(string(world))
    println()

    moved = true
    while moved
      moved = tick(world)
      println(string(world))
      println()
      readline(stdin)
    end
  end
end

main()
