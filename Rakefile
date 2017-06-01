task :default => [:run]

desc "run Specrunner"
task :test do
  `open ./spec/SpecRunner.html`
end

task :coffee do
	`coffee -cbw .`
end

desc "generate coffeetags"
task :tags do
  `coffeetags -f ./src/tags src/*.coffee`
end
