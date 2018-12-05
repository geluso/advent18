using IterTools

struct Claim
  id::Int
  xx::Int
  yy::Int
  width::Int
  height::Int
end

function claim_x_coords(claim::Claim)
  x0 = claim.xx
  xf = x0 + claim.width - 1
  return x0:xf
end

function claim_y_coords(claim::Claim)
  y0 = claim.yy
  yf = y0 + claim.height - 1
  return y0:yf
end

function claim_coords(claim)
  xi = claim_x_coords(claim)
  yi = claim_y_coords(claim)
  return Iterators.product(xi, yi)
end

struct Area
  allocations::Dict
  reverse_lookups::Dict
  untainted_claims::Set
  tainted_claims::Set
end

function getcoord(area::Area, xx::Int, yy::Int)
  key = string(xx, ",", yy)
  allocation = get(area.allocations, key, 0)
  return allocation
end

function taint_claim_id(area::Area, id::Int)
  push!(area.tainted_claims, id)
  if id in area.untainted_claims
    pop!(area.untainted_claims, id)
  end
end


function setclaim(area::Area, claim::Claim)
  for coord in claim_coords(claim)
    xx, yy = coord
    key = string(xx, ",", yy)
    allocation = getcoord(area, xx, yy)

    if allocation == 0 && !(claim.id in area.tainted_claims)
      push!(area.untainted_claims, claim.id)
    else
      # taint this claim
      taint_claim_id(area, claim.id)

      # mark all contested claims as tainted
      claims = get(area.reverse_lookups, key, Set())
      for claim_id in claims
        taint_claim_id(area, claim_id)
      end
    end

    reverse_lookups = get(area.reverse_lookups, key, Set())
    push!(reverse_lookups, claim.id)
    area.reverse_lookups[key] = reverse_lookups

    area.allocations[key] = allocation + 1
  end
end


open(ARGS[1]) do file
  area = Area(Dict(), Dict(), Set(), Set())
  claims = []

  for line in eachline(file)
    # line is: #1 @ 1,3: 4x4
    id, _, coord, dimen = split(line, " ")

    id = split(id, "#")[2]
    xx, yy = split(coord, ",")
    yy = split(yy, ":")[1]
    width, height = split(dimen, "x")

    strToInt = str -> parse(Int, str)
    vars = [id, xx, yy, width, height]
    id, xx, yy, width, height = map(strToInt, vars)

    claim = Claim(id, xx, yy, width, height)
    push!(claims, claim)
    setclaim(area, claim)
  end

  total_contested = 0
  for allocation in values(area.allocations)
    if allocation > 1
      total_contested += 1
    end
  end

  println("contested area: ", total_contested)
  println("uncontested claim id: ", pop!(area.untainted_claims))
end

