ENV['RDOCOPT'] = "-S -f html -T hanna"

require "rubygems"
require 'rake'

require File.dirname(__FILE__) << "/lib/authlogic_rpx/version"

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "authlogic_rpx"
    gem.version = AuthlogicRpx::Version::STRING
    gem.summary = %Q{Authlogic plug-in for RPX support}
    gem.description = %Q{Authlogic extension/plugin that provides RPX (rpxnow.com) authentication support}
    gem.email = "gallagher.paul@gmail.com"
    gem.homepage = "http://github.com/tardate/authlogic_rpx"
    gem.authors = [ "Paul Gallagher / tardate <gallagher.paul@gmail.com>" ]
    gem.add_dependency "authlogic", "= 2.1.6"
    gem.add_dependency "rpx_now", "= 0.6.23"
    gem.add_development_dependency "test-unit", ">= 2.1.1"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'

namespace :test do
  Rake::TestTask.new(:units) do |t|
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
end

task :test do
  Rake::Task['test:no_mapping'].invoke
  Rake::Task['test:internal_mapping'].invoke
end

task :default => :test