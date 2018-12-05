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


# for pair in partition(records, 2)
open(ARGS[1]) do file
  println("start")
  line = strip(readline(file)) 
  println(line)
  println(length(line))
  line = reverse(line)
  println(line)
  println(length(line))

  last = ListNode(line[1], nothing, nothing)
  for letter in line[2:end]
    node = ListNode(letter, last, nothing)
    last.prev = node
    last = node
  end
  list = LinkedList(last)

  println(myprint(list.root))
  println(length(myprint(list.root)))

  current = list.root
  while current != nothing && current.next != nothing
    #println("current: ", current.data)
    if is_reactive(list.root, list.root.next)
      list.root.next.next.prev = nothing
      list.root = list.root.next.next
      current = list.root
      #println("front reacted!")
      #println(myprint(list.root))
      #println()
    elseif is_reactive(current.prev, current)
      current.next.prev = current.prev.prev
      current = current.prev.prev
      current.next = current.next.next.next
      #println("prev reacted!")
      #println(myprint(list.root))
      #println()
    elseif is_reactive(current, current.next)
      if current.next.next != nothing
        current.next.next.prev = current.prev
      end
      current = current.prev
      current.next = current.next.next.next
      #println("curr reacted!")
      #println(myprint(list.root))
      #println()
    else
      current = current.next
      #println("no reaction")
      #println(myprint(list.root))
      #println()
    end
  end

  println(myprint(list.root))
  println(length(myprint(list.root)))
end

