require 'rack'

app = Proc.new do |env|
  req = Rack::Request.new( env )
  res = Rack::Response.new
  res.write( "Hello world!" )
  res.finish
end

Rack::Server.start( 
  app: app,
  Port: 3000,
)