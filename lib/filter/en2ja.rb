plugin 'translation'

Termtter::Client.add_filter do |statuses|
  statuses.each do |s|
    if s.english?
      s.text = translate(s.text, 'en|ja')
    end
  end
end
