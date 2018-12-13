import Base.string

struct Coord
  row
  col
end

mutable struct Cart
  coord
  facing
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

Cart(coord, facing) = Cart(coord, facing, 0)

function main()
  CARS = "<>^v"

  function key(row::Int, col::Int)
    return string(row, ",", col)
  end

  function key(coord::Coord)
    return key(coord.row, coord.col)
  end

  function key(cart::Cart)
    return key(cart.coord)
  end

  function turn(cart)
    turns = ["left", "straight", "right"]
    turn_to_take = turns[cart.turns % length(turns)]
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
    return get(rails, kk, " ")
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

  function print_grid(lookup_func)
    for row in 0:max_row
      line = ""
      for col in 0:max_col
        kk = key(row, col)
        cc = lookup_func(kk)
        line = string(line, cc)
      end
      println(line)
    end
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

  function move_cart(cart)
    
  end

  function is_cart_less(cart1::Cart, cart2::Cart)
    return isless(cart1.coord.row, cart2.coord.row) || isless(cart1.coord.col, cart2.coord.col)
  end

  function tick()
    ordered_carts = sort(collect(values(carts)), lt=is_cart_less)
    for cart in carts
      move_cart(cart)
    end
  end

  rails = Dict()
  carts = Dict()
  max_row = 0
  max_col = 0
  patch_spots = []

  open(ARGS[1]) do file
    row = 0
    for line in eachline(file)
      col = 0
      for letter in line
        kk = key(row, col)
        if letter in CARS
          rails[kk] = '?'

          coord = Coord(row, col)
          cart = Cart(coord, letter, 0)

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

  print_grid(show_rails)
  patch_rail(patch_spots)

  print_grid(show_rails)
  print_grid(show_carts_and_rails)

  tick()
end

main()
