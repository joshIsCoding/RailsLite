require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'

class ControllerBase
  AUTH_COOKIE = '_csrf_token'
  AUTH_PARAM = 'authenticy_token'

  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {} )
    @req, @res= req, res
    @params = route_params.merge( req.params )
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    prepare_response do
      res['location'] = url
      res.status = 302
    end
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content( content, content_type )
    prepare_response do
      res.content_type = content_type
      res.write( content )
    end
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
    @session ||= Session.new( req )
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    send( name )
    render unless already_built_response?
  end

  protected

  def form_authenticity_token
    @auth_token ||= SecureRandom.hex( 16 )
    store_auth_token
    @auth_token
  end

  private

  def store_auth_token
    res.set_cookie( AUTH_COOKIE, '/', @auth_token )
  end

  def full_template_path( template_name )
    base_path = File.dirname( __FILE__ ).chomp( '/lib' )
    rel_path = "views/#{self.class.name.underscore}/#{template_name}.html.erb"
    File.join( base_path, rel_path )
  end

  def check_double_render!
    raise 'DoubleRenderError!' if already_built_response?
  end

  def prepare_response( &proc )
    check_double_render!

    proc.call

    session.store_session( res )
    @already_built_response = true
  end
end

