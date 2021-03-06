require_relative './action_dispatch_lite/path_helper'

class Route
  include ActionDispatchLite::PathHelper

  attr_reader :pattern, :http_method, :controller_class, :action_name, :path

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern, @http_method, @controller_class = pattern, http_method, controller_class
    @path = stringify_path( pattern )
    @action_name = action_name
  end

  # checks if pattern matches path and method matches request method
  def matches?(req, req_method )
    req_method == http_method.to_s.upcase && pattern.match?( req.path )
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    controller = controller_class.new( req, res, route_params( req ) )
    controller.invoke_action( action_name )
  end

  def method_name
    super( path )
  end

  private

  def route_params( req )
    pattern.match( req.path ).named_captures
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new( pattern, method, controller_class, action_name )
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  def draw(&proc)
    self.instance_eval( &proc )
    define_route_helpers
  end

  # make each of these methods that
  # when called add route
  [:get, :post, :put, :delete].each do |http_method|
    define_method( http_method ) do |pattern, controller, action|
      add_route( pattern, http_method, controller, action )
    end
  end

  # should return the route that matches this request
  def match(req)
    routes.find { |r| r.matches?( req, request_method( req ) ) }
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    route = match( req )
    if route
      route.run( req, res )
    else
      res.status = 404
      res.write( "404 - No route matching #{request_method( req )} #{req.path} was found." )
    end
  end

  private

  def request_method( req )
    req.params['_method']&.upcase || req.request_method
  end

  def define_route_helpers
    routes.each do |route|
      ControllerBase.class_eval( <<-RUBY )
        def #{route.method_name}_path
          \"#{route.path}\"
        end
      RUBY
    end
  end
end
