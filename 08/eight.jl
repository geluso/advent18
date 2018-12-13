# A header, which is always exactly two numbers:
# The quantity of child nodes.
# The quantity of metadata entries.
# Zero or more child nodes (as specified in the header).
# One or more metadata entries (as specified in the header).

struct Tree
  root
end

struct TreeNode
  children
  metadata
end

function process_license(license, metadata)
  if length(license) == 0
    return []
  end

  children = []
  while length(children) > 0
    num_children, num_meta = license[1:2]
    num_children, num_meta = parse(Int, num_children), parse(Int, num_meta)

    rest_license, metadata = license[3:end-num_meta], license[end - num_meta + 1:end]
  end
  
  return TreeNode(children, metadata)
end

function main()
  open(ARGS[1]) do file
    line = readline(file)
    cells = split(line, " ")
    println(cells)
    
    root = process_node(children, metadata)

    println(children)
    println(metadata)
  end
end

main()
