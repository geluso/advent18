freqs = Dict()
freq = 0

while true
  println("freq", freq)
  open("./input.txt") do file
    for line in eachline(file)
      value = parse(Int, line)
      global freq += value
      if get(freqs, freq, false)
          println("dupe", freq)
          exit()
      end
      freqs[freq] = true
    end
  end
end
