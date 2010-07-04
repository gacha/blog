# from http://snippets.dzone.com/posts/show/7455#related
def linkify( text )
  s = text.to_s
  s.gsub!( Regexp.new( '(^|[\n ])([\w]+?://[\w]+[^ \"\n\r\t<]*)', Regexp::MULTILINE | Regexp::IGNORECASE ), '\1<a href="\2">\2</a>' )
  s.gsub!( Regexp.new( '(^|[\n ])((www)\.[^ \"\t\n\r<]*)', Regexp::MULTILINE | Regexp::IGNORECASE ), '\1<a href="http://\2">\2</a>' )
  s.gsub!( Regexp.new( '(^|[\n ])((ftp)\.[^ \"\t\n\r<]*)', Regexp::MULTILINE | Regexp::IGNORECASE ), '\1<a href="ftp://\2">\2</a>' )
  s.gsub!( Regexp.new( '(^|[\n ])([a-z0-9&\-_\.]+?)@([\w\-]+\.([\w\-\.]+\.)*[\w]+)', Regexp::IGNORECASE ), '\1<a href="mailto:\2@\3">\2@\3</a>' )
  s
end