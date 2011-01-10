require 'bundler/setup'
Bundler::GemHelper.install_tasks

for file in Dir['tasks/*.rake']
  load file
end

desc "remove all build artifacts"
task :clean do
  sh "rm -rf pkg/"
end
