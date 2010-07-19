xml.instruct!
xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml.channel do
    xml.title "Gacha's webs"
    xml.description "Par web aplikāciju izstrādi, par brīvā laika pavadīšanu"
    xml.link "http://gacha.id.lv/"

    for article in @articles
      xml.item do
        xml.title article.title
        xml.description markdown_to_html(article.body)
        xml.pubDate article.create_date.rfc822
        xml.link article.url
      end
    end
  end
end