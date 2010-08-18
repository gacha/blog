module AppHelper
  def devel?
    ENV['USERNAME'] == 'gatis'
  end

  def render_menu
    content = ""
    [
      {:name => 'Sākums',   :match => /^\/$/, :href => '/'},
      {:name => 'Par mani', :match => /^\/about\/$/, :href => '/about/'},
      {:name => 'Blogs',    :match => /^\/blog\//, :href => '/blog/'},
      {:name => 'Programmēšana', :match => /^\/programming\//, :href => '/programming/'}
    ].each do |item|
      content += %^<li#{request.path =~ item[:match] ? ' class="active"' : ''}><a href="#{item[:href]}"><span>#{item[:name]}</span></a></li>^ 
    end
    "<ul>#{content}</ul>"
  end
  
  def render_body obj
    case obj.render_as
      when 'markdown'
        markdown_to_html(obj.body)
      else
        obj.body
    end
  end
end
