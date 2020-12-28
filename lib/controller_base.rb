require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req, @res = req, res
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    check_double_render!

    res['location'] = url
    res.status = 302
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    check_double_render!

    res.content_type = content_type
    res.write( content )
    @already_built_response = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    template = ERB.new( 
      File.read( full_template_path( template_name ) )
    )
    render_content( template.result( binding ), 'text/html' )
  end

  # method exposing a `Session` object
  def session
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end

  private

  def full_template_path( template_name )
    base_path = File.dirname( __FILE__ ).chomp( '/lib' )
    rel_path = "views/#{self.class.name.underscore}/#{template_name}.html.erb"
    File.join( base_path, rel_path )
  end

  def check_double_render!
    raise 'DoubleRenderError!' if already_built_response?
  end
end

