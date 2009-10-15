# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{authlogic_rpx}
  s.version = "1.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paul Gallagher / tardate"]
  s.date = %q{2009-10-15}
  s.description = %q{Authlogic extension/plugin that provides RPX (rpxnow.com) authentication support}
  s.email = %q{gallagher.paul@gmail.com}
  s.extra_rdoc_files = ["CHANGELOG.rdoc", "README.rdoc", "lib/authlogic_rpx.rb", "lib/authlogic_rpx/acts_as_authentic.rb", "lib/authlogic_rpx/helper.rb", "lib/authlogic_rpx/session.rb", "lib/authlogic_rpx/version.rb"]
  s.files = ["CHANGELOG.rdoc", "MIT-LICENSE", "Manifest", "README.rdoc", "Rakefile", "authlogic_rpx.gemspec", "init.rb", "lib/authlogic_rpx.rb", "lib/authlogic_rpx/acts_as_authentic.rb", "lib/authlogic_rpx/helper.rb", "lib/authlogic_rpx/session.rb", "lib/authlogic_rpx/version.rb", "rails/init.rb", "test/acts_as_authentic_test.rb", "test/fixtures/users.yml", "test/libs/rails_trickery.rb", "test/libs/user.rb", "test/libs/user_session.rb", "test/session_test.rb", "test/test_helper.rb"]
  s.homepage = %q{http://github.com/tardate/authlogic_rpx}
  s.post_install_message = %q{}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Authlogic_rpx", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{authlogic_rpx}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Authlogic plug-in for RPX support}
  s.test_files = ["test/acts_as_authentic_test.rb", "test/session_test.rb", "test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<authlogic>, [">= 2.1.1"])
      s.add_runtime_dependency(%q<rpx_now>, [">= 0.6.6"])
    else
      s.add_dependency(%q<authlogic>, [">= 2.1.1"])
      s.add_dependency(%q<rpx_now>, [">= 0.6.6"])
    end
  else
    s.add_dependency(%q<authlogic>, [">= 2.1.1"])
    s.add_dependency(%q<rpx_now>, [">= 0.6.6"])
  end
end
