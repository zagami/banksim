task :default =>[:diagram]

today = Time.now

desc "make diagram of source code"
task :diagram do
	`wavi --dot . diagram.dot`
	`dot -Tpng diagram.dot > diagram.png`
end


desc "Printing the time"
task :time do
  puts today.to_s
  puts `ls -al`
end

