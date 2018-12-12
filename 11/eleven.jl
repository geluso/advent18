SERIAL_NUMBER = 18
SERIAL_NUMBER = 42
SERIAL_NUMBER = 4151

function power_level(xx, yy)
  if xx > 300 || yy > 300
    return 0
  end

  rack_id = xx + 10
  power = rack_id * yy 
  power += SERIAL_NUMBER
  power *= rack_id
  if power < 100
    power = 0
  else
    power = Int(floor(power / 100)) % 10
  end

  power -= 5
end

function square(xx, yy, size)
  # size 1 selects a 1x1 square
  size -= 1

  if (xx + size) > 300 || (yy + size) > 300
    return 0
  end

  total = 0
  for dx in 0:size
    for dy in 0:size
      total += power_level(xx + dx, yy + dy)
    end
  end
  return total
end

function main()
  best = 0
  best_xx, best_yy = 1, 1
  best_size = 1

  for size in 1:300
    println()
    println("size: ", size)
    for xx in 1:300
      for yy in 1:300
        power = square(xx, yy, size)
        if power > best
          best = power
          best_xx, best_yy = xx, yy
          best_size = size
          println(best_xx, ",", best_yy, " ", power, " size: ", size)
        end
      end
    end
  end
end

main()
