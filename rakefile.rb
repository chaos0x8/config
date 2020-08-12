gem 'rake-builder', '~> 2.0', '>= 2.0.8'

require 'rake-builder'
require 'rake/testtask'

Rake::TestTask.new { |t|
  t.test_files = FileList['test/Test*.rb']
}

task(default: :test)
