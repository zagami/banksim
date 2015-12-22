task :default => [:run]

today = Time.now

desc "make diagram of source code"
task :diagram do
	`wavi --dot /src generated/diagram.dot`
	`dot -Tpng generated/diagram.dot > generated/diagram.png`
end

desc "run Specrunner"
task :test do
	`open SpecRunner.html`
end

desc "run Simulator"
task :run do
	`open index.html`
end

desc "generate coffeetags"
task :coffeetags do
	`coffeetags -f tags src/*.coffee`
end


desc "Printing the time"
task :time do
  puts today.to_s
  puts `ls -al`
end

