Gem::Specification.new do |s|
  s.name = %q{termtter}
  s.version = "0.7.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["bubblegum", "hakobe", "hitode909", "jugyo", "koichiro", "mattn", "motemen", "Sixeight", "ujihisa", "yanbe"]
  s.date = %q{2009-01-09}
  s.default_executable = %q{termtter}
  s.description = %q{Termtter is a terminal based Twitter client}
  s.email = ["jugyo.org@gmail.com"]
  s.executables = ["termtter"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "bin/termtter", "lib/filter/en2ja.rb", "lib/filter/english.rb", "lib/filter/expand-tinyurl.rb", "lib/filter/fib.rb", "lib/filter/reverse.rb", "lib/filter/yhara.rb", "lib/plugin/bomb.rb", "lib/plugin/confirm.rb", "lib/plugin/english.rb", "lib/plugin/erb.rb", "lib/plugin/favorite.rb", "lib/plugin/fib.rb", "lib/plugin/filter.rb", "lib/plugin/follow.rb", "lib/plugin/group.rb", "lib/plugin/growl.rb", "lib/plugin/history.rb", "lib/plugin/keyword.rb", "lib/plugin/log.rb", "lib/plugin/notify-send.rb", "lib/plugin/plugin.rb", "lib/plugin/quicklook.rb", "lib/plugin/reload.rb", "lib/plugin/say.rb", "lib/plugin/shell.rb", "lib/plugin/sl.rb", "lib/plugin/spam.rb", "lib/plugin/standard_plugins.rb", "lib/plugin/stdout.rb", "lib/plugin/translation.rb", "lib/plugin/uri-open.rb", "lib/plugin/yhara.rb", "lib/termtter.rb", "run_termtter.rb", "test/friends_timeline.json", "test/search.json", "test/test_termtter.rb"]
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
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<configatron>, [">= 0"])
      s.add_runtime_dependency(%q<highline>, [">= 0"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<configatron>, [">= 0"])
      s.add_dependency(%q<highline>, [">= 0"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<configatron>, [">= 0"])
    s.add_dependency(%q<highline>, [">= 0"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
