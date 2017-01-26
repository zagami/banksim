task :default => [:run]

desc "run Specrunner"
task :test do
	`open SpecRunner.html`
end

task :coffee do
	system("coffee -cbw .")
end

desc "generate coffeetags"
task :coffeetags do
	`coffeetags -f tags src/*.coffee`
end
