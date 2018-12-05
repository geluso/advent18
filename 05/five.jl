using IterTools

mutable struct ListNode
  data
  next
  prev
end

mutable struct LinkedList
  root::ListNode
end

function myprint(node)
  if node == nothing
    return ""
  else
    return string(node.data, myprint(node.next))
  end
end

function is_reactive(n1, n2)
  if n1 == nothing || n2 == nothing
    return false
  end
  #println(n1.data, " ", n2.data)

  uppers = "QWERTYUIOPASDFGHJKLZXCVBNM"
  downers = "qwertyuiopasdfghjklzxcvbnm"

  c1 = n1.data
  c2 = n2.data

  if uppercase(c1) != uppercase(c2)
    return false
  elseif c1 in uppers && c2 in uppers || c1 in downers && c2 in downers
    return false
  else
    return true
  end
end

function build_linked_polymer(line)
  # reverse the line (this was from before doubly-linking
  line = reverse(line)

  last = ListNode(line[1], nothing, nothing)
  for letter in line[2:end]
    node = ListNode(letter, last, nothing)
    last.prev = node
    last = node
  end
  list = LinkedList(last)
end

function react_polymer!(list)
  current = list.root
  while current != nothing && current.next != nothing
    if is_reactive(list.root, list.root.next)
      list.root.next.next.prev = nothing
      list.root = list.root.next.next
      current = list.root
    elseif is_reactive(current.prev, current)
      current.next.prev = current.prev.prev
      current = current.prev.prev
      current.next = current.next.next.next
    elseif is_reactive(current, current.next)
      if current.next.next != nothing
        current.next.next.prev = current.prev
      end
      current = current.prev
      current.next = current.next.next.next
    else
      current = current.next
    end
  end
  return list
end

function remove_polymer(line, letter)
  isNotLetter = c -> c != uppercase(letter) && c != lowercase(letter)
  return filter(isNotLetter, line)
end

open(ARGS[1]) do file
  line = strip(readline(file)) 
  best = nothing

  alpha = "qwertyuiopasdfghjklzxcvbnm"
  for letter in alpha
    curated_line = remove_polymer(line, letter)

    list = build_linked_polymer(curated_line)
    processed = react_polymer!(list)
    score = length(myprint(processed.root))
    if best == nothing || score < best
      best = score
      println("better: ", best)
    end
  end
  println("best: ", best)
end

