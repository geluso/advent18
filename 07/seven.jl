ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
TIME_PER_JOB = 60
MAX_WORKERS = 5

mutable struct Task
  time_spent
  time_required
  task
end

function is_complete(task::Task)
  println("is_complete: ", task.time_spent, "/", task.time_required)
  return task.time_spent == task.time_required
end

function get_cost(task)
  global TIME_PER_JOB, ALPHABET
  return TIME_PER_JOB + findfirst(string(task), ALPHABET)[1]
end

function main()
  hierarchy = Dict()
  relies_on = Dict()
  all = Set()

  open(ARGS[1]) do file
    for line in eachline(file)
      first = line[6]
      next = line[37]

      push!(all, first, next)

      list = get(relies_on, next, [])
      relies_on[next] = list
      push!(list, first)

      list = get(hierarchy, first, [])
      hierarchy[first] = list
      push!(list, next)
    end
  end

  left = sort(collect(all))
  complete = []

  index = 1
  while length(left) > 0
    item = left[index]
    index += 1

    prereqs = get(relies_on, item, [])
    prereqs = filter(el -> !(el in complete), prereqs)

    if length(prereqs) == 0
      print(item)
      filter!(el -> el != item, left)
      push!(complete, item)
      index = 1
    end
  end
  println()

  println(complete)

  for letter in ALPHABET
    list = get(relies_on, letter, [])
    relies_on[letter] = list
    println(typeof(letter), " ", letter, " relies on ", list)
  end
  println()

  seconds_spent = 0

  todo = split(string(complete), "")
  has_begun = Dict()
  working = []
  complete = []

  while length(complete) < 26
    println("working:", length(working))
    println("complete:", length(complete), " ", join(complete,""))

    searching = true
    index = 1
    while searching
      if length(working) == MAX_WORKERS
        searching = false
      elseif index > length(todo)
        searching = false
      elseif index > length(ALPHABET)
        searching = false
      else
        task = ALPHABET[index]
        index += 1

        is_task_working = get(has_begun, task, false) 
        is_task_complete = task in complete
        if !is_task_working && !is_task_complete
          prereqs = get(relies_on, task, [])
          complete_prereqs = filter(el -> el in complete, prereqs)
          println(typeof(task), " ", task, " prereqs: ", prereqs, complete_prereqs)
          
          if length(prereqs) == length(complete_prereqs)
            cost = get_cost(task)
            task = Task(0, cost, task)
            println("assigned ", task, " @ ", cost)

            has_begun[task.task] = true
            push!(working, task)
            filter!(el -> el != task, todo)
          end
        end
      end
    end

    for task in working
      task.time_spent += 1
      if is_complete(task)
        println("completed ", task)
        push!(complete, task.task)
        filter!(el -> el != task, working)
        searching = true
      end
    end

    seconds_spent += 1
  end
  println("total time: ", seconds_spent)
end

main()
