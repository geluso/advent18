import Base.string

mutable struct World
  map
  actors
  max_row
  max_col
end

World() = World(Dict(), [], 0, 0)

mutable struct Actor
  race
  hp
  row
  col
end

function key(row, col)
  return string(row, ",", col)
end

function string(world::World)
  output = ""
  for row in 1:world.max_row
    line = ""
    for col in 1:world.max_col
      key_ = key(row, col)
      tile = get(world.map, key_, false)
      if tile
        tile = '.'
      else
        tile = '#'
      end
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
          push!(world.actors, actor)
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

function main()
  open(ARGS[1]) do file
    world = build_world(file)
    println(string(world))
  end
end

main()
