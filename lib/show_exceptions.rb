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
    ).finish
  end

  private

  def render_exception( e )
    @e = e
    template = ERB.new( File.read( rescue_template_path ) )
    template.result( binding )
  end

  def rescue_template_path
    File.join( File.dirname( __FILE__ ), 'templates/rescue.html.erb' )
  end

end
