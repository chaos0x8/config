gem 'rake-builder', '~> 3.2', '>= 3.2.6'

require 'rake-builder'
require 'rake/testtask'

Rake::TestTask.new { |t|
  t.test_files = FileList['test/Test*.rb']
}

desc '= test'
task(default: :test)

namespaces = Dir[File.join('rakelib', '*.rake')].collect { |x| File.basename(x).chomp('.rake') }
desc "Installs #{namespaces.join(', ')} configurations"
task(install: namespaces.collect { |x| "#{x}:install" })
