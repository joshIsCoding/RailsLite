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
    method = html_options[:method]&.to_s&.downcase || 'post'
    if %w[ get post ].include?( method )
      emu_method = ''
    else
      emu_method = emu_method_input( method )
      method = 'post'
    end

    <<~HTML
      <form method="#{method}" action="#{path}" class="#{html_options[:class]}">#{emu_method}
        <input type="submit" value="#{name}"/>
      </form>
    HTML
  end

  private

  def emu_method_input( method )
    "\n<input type=\"hidden\" name=\"_method\" value=\"#{method}\" />"
  end
end