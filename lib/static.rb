class Static
  PUBLIC_PATH = '/public'

  attr_reader :full_path, :path

  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new( env )

    if static_asset_request?( req )
      set_path( req.path )
      build_asset_response
    else
      @app.call( env )
    end
  end

  def build_asset_response
    if File.exist?( full_path )
      serve_asset
    else
      Rack::Response.new(
        "No such file found: #{path}", 404, {'Content-Type' => 'text/html'}
      ).finish
    end

  end

  def serve_asset
    res = Rack::Response.new
    res.write( File.read( full_path ) )
    res['Content-Type'] = Rack::Mime.mime_type( extract_ext )
    res.finish
  end

  def static_asset_request?( req )
    req.path.start_with?( PUBLIC_PATH )
  end

  private

  def extract_ext
    path[/\.\w+$/]
  end

  def set_path( path )
    @path = path
    @full_path = File.absolute_path( ".#{path}" )
  end
end
