require 'erb'

class ShowExceptions
  attr_reader :app
  def initialize( app )
    @app = app
  end

  def call( env )
    app.call( env )
  rescue => e
    return Rack::Response.new( 
      render_exception( e ), 500, {'Content-Type' => 'text/html'}
    )
  end

  private

  def render_exception( e )
  end

end
