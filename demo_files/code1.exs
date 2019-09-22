Enum.each(1..10, fn(x) ->
  IO.puts "#{x}: hello, world!"
  :timer.sleep(100)
end)
