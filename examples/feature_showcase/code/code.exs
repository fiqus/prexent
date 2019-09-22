Enum.each(1..10, fn(x) ->
  IO.puts "#{x}: hello, prexent!"
  :timer.sleep(100)
end)
