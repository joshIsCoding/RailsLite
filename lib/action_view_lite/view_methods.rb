module ViewMethods
  def link_to( link_text, href, **opts )
    <<~HTML
      <a href="#{href}" class="#{opts[:class]}">
        #{link_text}
      </a>
    HTML
  end
end