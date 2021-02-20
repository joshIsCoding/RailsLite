module ViewMethods
  def link_to( link_text, href, **opts )
    <<~HTML
      <a href="#{href}" class="#{opts[:class]}">
        #{link_text}
      </a>
    HTML
  end

  def button_to( name, path, **html_options )
    html_class = html_options[:class] || 'button_to'
    method = html_options[:method] || 'post'
    <<~HTML
      <form method="#{method}" action="#{path}" class="#{html_options[:class]}">
        <input type="submit" value="#{name}"/>
      </form>
    HTML
  end
end