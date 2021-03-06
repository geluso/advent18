import Base.string

struct Coord
  row
  col
end

mutable struct Cart
  coord
  facing
  id
  turns
end

# access to the coords around center
struct RelativeCoords
  center
  top
  bot
  left
  right
end

# access to characters in world around center
struct RelativeWorld
  center
  top
  bot
  left
  right
end

Cart(coord, facing, id) = Cart(coord, facing, id, 0)

function main()
  CARTS = "<>^v"

  LEFT_TURNS = Dict()
  LEFT_TURNS['^'] = '<'
  LEFT_TURNS['<'] = 'v'
  LEFT_TURNS['v'] = '>'
  LEFT_TURNS['>'] = '^'

  RIGHT_TURNS = Dict()
  RIGHT_TURNS['^'] = '>'
  RIGHT_TURNS['>'] = 'v'
  RIGHT_TURNS['v'] = '<'
  RIGHT_TURNS['<'] = '^'


  function key(row::Int, col::Int)
    return string(row, ",", col)
  end

  function key(coord::Coord)
    return key(coord.row, coord.col)
  end

  function key(cart::Cart)
    return key(cart.coord)
  end

  function turn_cart(cart)
    turns = ["left", "straight", "right"]
    turn_to_take = turns[cart.turns % length(turns) + 1]
    cart.turns += 1

    if turn_to_take == "left"
      turn_left(cart)
    elseif turn_to_take == "right"
      turn_right(cart)
    end
  end

  function turn_left(cart)
    cart.facing = get(LEFT_TURNS, cart.facing, cart.facing)
  end

  function turn_right(cart)
    cart.facing = get(RIGHT_TURNS, cart.facing, cart.facing)
  end

  function relative_dir(center::Coord)
    top = Coord(center.row - 1, center.col)
    bot = Coord(center.row + 1, center.col)
    left = Coord(center.row, center.col - 1)
    right = Coord(center.row, center.col + 1)
    return RelativeCoords(center, top, bot, left, right)
  end

  function relative_rail(center::Coord)
    rel_dirs = relative_dir(center)

    center = show_carts_and_rails(center)
    top = show_carts_and_rails(rel_dirs.top)
    bot = show_carts_and_rails(rel_dirs.bot)
    left = show_carts_and_rails(rel_dirs.left)
    right = show_carts_and_rails(rel_dirs.right)

    return RelativeWorld(center, top, bot, left, right)
  end

  function show_rails(kk::String)
    return get(rails, kk, ' ')
  end

  function show_carts_and_rails(kk::String)
    cart = get(carts, kk, nothing)
    if cart == nothing
      return show_rails(kk)
    else
      return cart.facing
    end
  end

  function show_carts_and_rails(coord::Coord)
    return show_carts_and_rails(key(coord))
  end

  function print_grid(lookup_func, coord=nothing)
    row_range = 0:max_row
    col_range = 0:max_col
    if coord != nothing
      row_range = (coord.row - 4:coord.row + 4)
      col_range = (coord.col - 4:coord.col + 4)
    end


    for row in row_range
      line = ""
      for col in col_range
        kk = key(row, col)
        cc = lookup_func(kk)
        line = string(line, cc)
      end
      println(line)
    end

    println()
  end

  print_grid() = print_grid(show_rails)

  function patch_rail(spots)
    for spot in spots
      row, col = spot.row, spot.col
      top = get(rails, key(spot.row - 1, spot.col), ' ')
      bot = get(rails, key(spot.row + 1, spot.col), ' ')
      left = get(rails, key(spot.row, spot.col - 1), ' ')
      right = get(rails, key(spot.row, spot.col + 1), ' ')

      incoming_left = left in "-\\/+"
      incoming_right = right in "-\\/+"
      incoming_top = top in "|\\/+"
      incoming_bot = bot in "|\\/+"

      if incoming_top && incoming_bot && incoming_left && incoming_right
        rails[key(row, col)] = '+'
      elseif incoming_top && incoming_bot
        rails[key(row, col)] = '|'
      elseif incoming_left && incoming_right
        rails[key(row, col)] = '-'
      end
    end
  end

  function collide(cart, other)
    d1 = delete!(carts, key(cart))
    d2 = delete!(carts, key(other))
    println("collision! ", "coord: ", cart, " other: ", other)

    push!(dead_carts, cart)
    push!(dead_carts, other)

    println(length(carts))
    if length(carts) == 1
      println(carts)
      exit()
    end
  end

  function move_up(cart, forced=false)
    around = relative_rail(cart.coord)
    if around.top in CARTS
      collide(cart, get(carts, key(relative_dir(cart.coord).top), nothing))
    elseif around.center == '\\' && !forced
      cart.facing = '<'
      move_left(cart, true)
    elseif around.center == '/' && !forced
      cart.facing = '>'
      move_right(cart, true)
    elseif around.top in "|/\\+"
      cart.coord = Coord(cart.coord.row - 1, cart.coord.col)
    else
      print_grid(show_carts_and_rails, cart.coord)
      println("ERROR up ", around, " ", forced, " id: ", cart.id, " cart: ", cart)
      exit()
    end
  end

  function move_down(cart, forced=false)
    around = relative_rail(cart.coord)
    if around.bot in CARTS
      collide(cart, get(carts, key(relative_dir(cart.coord).bot), nothing))
    elseif around.center == '/' && !forced
      cart.facing = '<'
      move_left(cart, true)
    elseif around.center == '\\' && !forced
      cart.facing = '>'
      move_right(cart, true)
    elseif around.bot in "|/\\+"
      cart.coord = Coord(cart.coord.row + 1, cart.coord.col)
    else
      print_grid(show_carts_and_rails, cart.coord)
      println("ERROR up ", around, " ", forced, " id: ", cart.id, " cart: ", cart)
      exit()
    end
  end

  function move_left(cart, forced=false)
    around = relative_rail(cart.coord)
    if around.left in CARTS
      collide(cart, get(carts, key(relative_dir(cart.coord).left), nothing))
      collide(cart.coord, relative_dir(cart.coord).bot)
    elseif around.center == '\\' && !forced
      cart.facing = '^'
      move_up(cart, true)
    elseif around.center == '/' && !forced
      cart.facing = 'v'
      move_down(cart, true)
    elseif around.left in "-\\/+"
      cart.coord = Coord(cart.coord.row, cart.coord.col - 1)
    else
      print_grid(show_carts_and_rails, cart.coord)
      println("ERROR up ", around, " ", forced, " id: ", cart.id, " cart: ", cart)
      exit()
    end
  end

  function move_right(cart, forced=false)
    around = relative_rail(cart.coord)
    if around.right in CARTS
      collide(cart, get(carts, key(relative_dir(cart.coord).right), nothing))
    elseif around.center == '/' && !forced
      cart.facing = '^'
      move_up(cart, true)
    elseif around.center == '\\' && !forced
      cart.facing = 'v'
      move_down(cart, true)
    elseif around.right in "-\\/+"
      cart.coord = Coord(cart.coord.row, cart.coord.col + 1)
    else
      print_grid(show_carts_and_rails, cart.coord)
      println("ERROR up ", around, " ", forced, " id: ", cart.id, " cart: ", cart)
      exit()
    end
  end

  function move_cart(cart)
    if get(carts, key(cart), nothing) == nothing
      return
    end

    delete!(carts, key(cart))

    around = relative_rail(cart.coord)
    if around.center == '+'
      turn_cart(cart)
    end

    if cart.facing == '^'
      move_up(cart)
    elseif cart.facing == 'v'
      move_down(cart)
    elseif cart.facing == '<'
      move_left(cart)
    elseif cart.facing == '>'
      move_right(cart)
    end

    if !(cart in dead_carts)
      carts[key(cart)] = cart
    end
  end

  function is_cart_less(cart1::Cart, cart2::Cart)
    return isless(cart1.coord.row, cart2.coord.row) || isless(cart1.coord.col, cart2.coord.col)
  end

  function tick()
    ordered_carts = sort(collect(values(carts)), lt=is_cart_less)
    for cart in ordered_carts
      move_cart(cart)
    end
  end

  rails = Dict()
  carts = Dict()
  dead_carts = Set()
  max_row = 0
  max_col = 0
  patch_spots = []

  id = 0
  open(ARGS[1]) do file
    row = 0
    for line in eachline(file)
      col = 0
      for letter in line
        kk = key(row, col)
        if letter in CARTS
          coord = Coord(row, col)
          cart = Cart(coord, letter, id, 0)
          id += 1

          push!(patch_spots, coord)
          carts[key(cart)] = cart
        else
          rails[kk] = letter
        end

        max_col = maximum([max_col, col])
        col += 1
      end

      max_row = maximum([max_row, row])
      row += 1
    end
  end

  patch_rail(patch_spots)

  #print_grid(show_rails)
  #print_grid(show_carts_and_rails)

  while true
    tick()
  end
end

main()
