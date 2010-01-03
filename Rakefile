ENV['RDOCOPT'] = "-S -f html -T hanna"

require "rubygems"
require "echoe"
require File.dirname(__FILE__) << "/lib/authlogic_rpx/version"

Echoe.new("authlogic_rpx") do |p|
  p.version = AuthlogicRpx::Version::STRING
  p.url = "http://github.com/tardate/authlogic_rpx"
  p.summary = "Authlogic plug-in for RPX support"
  p.description = "Authlogic extension/plugin that provides RPX (rpxnow.com) authentication support"

  p.runtime_dependencies = ["authlogic >=2.1.1", "rpx_now >=0.6.6" ]
  p.development_dependencies = []

  p.author = "Paul Gallagher / tardate"
  p.email  = "gallagher.paul@gmail.com"

  p.install_message = ""
end


Rake::Task[:test].clear

Rake::TestTask.new(:unit) do |t|
  t.libs << "test/libs"
  t.pattern = 'test/unit/*test.rb'
  t.verbose = true
end

Rake::TestTask.new(:no_mapping) do |t|
  t.libs << "test/libs"
  t.test_files = FileList.new('test/unit/*test.rb', 'test/integration/no_mapping/*test.rb')
  t.verbose = true
end

Rake::TestTask.new(:internal_mapping) do |t|
  t.libs << "test/libs"
  t.test_files = FileList.new('test/integration/internal_mapping/*test.rb')
  t.verbose = true
end

task :test do
  Rake::Task[:no_mapping].invoke
  Rake::Task[:internal_mapping].invoke
end

task :default => :test