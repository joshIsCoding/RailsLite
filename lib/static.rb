class Static
  PUBLIC_PATH = '/public'
  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new( env )
    if req.path.starts_with?( PUBLIC_PATH )
      serve_asset( req.path )
    else
      @app.call( env )
    end
  end

  def full_path( file_path )
    File.absolute_path( file_path, PUBLIC_PATH )
  end
end
