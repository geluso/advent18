function diff(word1, word2)
  diff = 0
  for i = 1:length(word1)
    if word1[i] != word2[i]
      diff += 1
    end
    if diff > 1
      return false
    end
  end
  return true
end

open("input") do file
  words = []

  for word in eachline(file)
    push!(words, word)
  end

  # compare all words to each other
  for word1 in words
    for word2 in words
      if diff(word1, word2)
        println(word1)
        println(word2)
        exit()
      end
    end
  end
end

