require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'
require_relative './flash'
require_relative './action_view_lite/view_methods'
require_relative './action_controller_lite/parameters'

class ControllerBase
  include ViewMethods

  AUTH_COOKIE = '_csrf_token'
  AUTH_PARAM = 'authenticity_token'

  @forgery_protection = false

  attr_reader :req, :res, :params, :flash

  def self.protect_from_forgery
    @forgery_protection = true
  end

  def self.protect_from_forgery?
    @forgery_protection
  end

  # Setup the controller
  def initialize(req, res, route_params = {} )
    @req, @res= req, res
    @params = ActionControllerLite::Parameters.new( route_params.merge( req.params ) )
    @flash = ActionDispatchLite::Flash.new( req )
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
    check_authenticity_token if self.class.protect_from_forgery? && !get_request?

    send( name )
    render( name ) unless already_built_response?
  end

  def check_authenticity_token
    unless auth_tokens_match?
      raise 'Invalid authenticity token'
    end
  end

  def form_authenticity_token
    @auth_token ||= SecureRandom.hex( 16 )
    store_auth_token
    @auth_token
  end

  private

  def store_auth_token
    res.set_cookie( AUTH_COOKIE, { path: '/', value: @auth_token } )
  end

  def auth_tokens_match?
    return false if params[AUTH_PARAM].blank?

    req.cookies[AUTH_COOKIE] == params[AUTH_PARAM]
  end

  def get_request?
    req.request_method == 'GET'
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

