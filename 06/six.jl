struct Claim
  xx
  yy
  index
end

function key(pp::Claim)
  return string(pp.xx, ",", pp.yy)
end

open(ARGS[1]) do file
  fresh_claims = []
  claims = Dict()

  index = 0
  minx, miny, maxx, maxy = 0, 0, 0, 0

  function init_claims()
    for line in eachline(file)
      xx, yy = split(line, ", ")
      xx, yy = parse(Int, xx), parse(Int, yy)

      claim = Claim(xx, yy, index)
      index += 1

      push!(fresh_claims, claim)
      claims[key(claim)] = claim

      minx = minimum([xx, minx])
      miny = minimum([yy, miny])
      maxx = maximum([xx, maxx])
      maxy = maximum([yy, maxy])
    end
  end

  function print_claims()
    for xx in minx:maxx
      line = ""
      for yy in miny:maxy
        key = string(xx, ",", yy)
        claim = get(claims, key, nothing)
        if claim != nothing
          line = string(line, string(claim.index))
        else
          line = string(line, " ")
        end
      end
      println(line)
    end
    println("===================================")
  end

  function neighbors(pp)
    x0 = pp.xx - 1
    xf = pp.xx + 1
    y0 = pp.yy - 1
    yf = pp.yy + 1

    x0 = maximum([minx, x0])
    xf = minimum([maxx, xf])
    y0 = maximum([miny, y0])
    yf = minimum([maxy, yf])

    top = Claim(pp.xx, y0, pp.index)
    right = Claim(xf, pp.yy, pp.index)
    bot = Claim(pp.xx, yf, pp.index)
    left = Claim(x0, pp.yy, pp.index)

    return [top, right, bot, left]
  end

  function expand(fresh_claims)
    next_fresh = []
    new_claims = Dict()

    for claim in fresh_claims
      previous_claim = get(claims, key(claim), nothing)
      if previous_claim == nothing
        claims = get(new_claims, key(claim), Dict())
        new_claims[key(claim)] = claims
        claims[claim.index] = true
      end

      top, right, bot, left = neighbors(claim)
      push!(next_fresh, top, right, bot, left)
    end

    for claims in new_claims
      println(claims)
    end
    println()

    return new_claims
  end
  
  init_claims()
  print_claims()

  iterations = 0
  while length(claims) > 0 && iterations < 10
    fresh_claims = expand(fresh_claims)
    print_claims()
    iterations += 1
  end
end

