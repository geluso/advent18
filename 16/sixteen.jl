import Base.string

struct Coord
  row
  col
end

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

function get_tile(world, row, col, targets)
  key_ = key(row, col)

  target = get(targets, key_, nothing)
  if target != nothing
    return '@'
  end

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

get_tile(world, row, col) = get_tile(world, row, col, Dict())

function string(world::World, targets)
  output = ""
  for row in 1:world.max_row
    line = ""
    for col in 1:world.max_col
      tile = get_tile(world, row, col, targets)
      line = string(line, tile)
    end
    output = string(output, line, "\n")
  end
  return strip(output)
end

string(world::World) = string(world, Dict())

function add_target(world, targets, row, col)
  if get_tile(world, row, col) == '.'
    targets[key(row,col)] = true
  end
end

function get_targets(world, race)
  targets = Dict()
  for actor in values(world.actors)
    if actor.race == race
      add_target(world, targets, actor.row - 1, actor.col)
      add_target(world, targets, actor.row, actor.col - 1)
      add_target(world, targets, actor.row, actor.col + 1)
      add_target(world, targets, actor.row + 1, actor.col)
    end
  end

  return targets
end

function elf_targets(world)
  return get_targets(world, 'E')
end

function goblin_targets(world)
  return get_targets(world, 'G')
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
    ticks = 0
    while moved
      moved = tick(world)
      targets = nothing
      if ticks % 2 == 0
        targets = elf_targets(world)
      else
        targets = goblin_targets(world)
      end

      println(string(world, targets))
      println()
      readline(stdin)

      ticks += 1
    end
  end
end

main()
