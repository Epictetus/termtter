# -*- coding: utf-8 -*-

Termtter::Client.add_filter do |statuses, _|
  statuses.select {|s| /^(?:\s|(y\s)|(?:hara\s))+\s*(?:y|(?:hara))(?:\?|!|\.)?\s*$/ =~ s.text }
end

# yhara_filter.rb
#   select Yharian post only
