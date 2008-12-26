Gem::Specification.new do |s|
  s.name = %q{termtter}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["jugyo"]
  s.date = %q{2008-12-26}
  s.default_executable = %q{termtter}
  s.description = %q{Termtter is a terminal based Twitter client}
  s.email = ["jugyo.org@gmail.com"]
  s.executables = ["termtter"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "bin/termtter", "lib/termtter.rb", "lib/termtter/stdout.rb", "lib/termtter/notify-send.rb", "test/test_termtter.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/jugyo/termtter}
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{termtter}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Termtter is a terminal based Twitter client}
  s.test_files = ["test/test_termtter.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
      s.add_runtime_dependency(%q<configatron>, [">= 0"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<nokogiri>, [">= 0"])
      s.add_dependency(%q<configatron>, [">= 0"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<nokogiri>, [">= 0"])
    s.add_dependency(%q<configatron>, [">= 0"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
