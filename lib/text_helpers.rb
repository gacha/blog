require 'maruku'

# stolen from Rails
BRACKETS = { ']' => '[', ')' => '(', '}' => '{' }
AUTO_LINK_RE = %r{ ( https?:// | www\. ) [^\s<]+ }x

def auto_link_urls(text, link_attributes = {})
  text.gsub(AUTO_LINK_RE) do
    href = $&
    punctuation = ''
    left, right = $`, $'
    # detect already linked URLs and URLs in the middle of a tag
    if left =~ /<[^>]+$/ && right =~ /^[^>]*>/
      # do not change string; URL is already linked
      href
    else
      # don't include trailing punctuation character as part of the URL
      if href.sub!(/[^\w\/-]$/, '') and punctuation = $& and opening = BRACKETS[punctuation]
        if href.scan(opening).size > href.scan(punctuation).size
          href << punctuation
          punctuation = ''
        end
      end

      link_text = block_given?? yield(href) : href
      href = 'http://' + href unless href =~ %r{^[a-z]+://}i

      "<a #{link_attributes.merge('href' => href).map{|k,v| "#{k}=\"#{v}\"" }.join(" ")}>#{h(link_text)+punctuation}</a>"
    end
  end
end

def truncate text, options={}
  if text
    options = {:length=>30,:omission=>'...'}.merge(options)
    l = options[:length] - options[:omission].length
    (text.length > options[:length] ? text[0..l] + options[:omission] : text).to_s
  end
end

def to_slug str
  str.to_s.gsub(/\s/,'-').downcase.gsub(/./){|s| {
      'ā'=>'a','č'=>'c','ē'=>'e','ģ'=>'g','ī'=>'i','ķ'=>'k','ļ'=>'l','ņ'=>'n','š'=>'s','ū'=>'u','ž'=>'z',
      'Ā'=>'A','Č'=>'c','Ē'=>'E','Ģ'=>'G','Ī'=>'I','Ķ'=>'K','Ļ'=>'L','Ņ'=>'N','Š'=>'S','Ū'=>'U','Ž'=>'Z'
    }[$&] || $& }.gsub(/[^\w\s\-]+/i,'')
end

def markdown_to_html str
  Maruku.new(str.to_s).to_html
end