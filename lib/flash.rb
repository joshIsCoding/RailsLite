require 'json'

class Flash
  attr_reader :current, :future

  COOKIE_NAME = '_rails_lite_app_flash'

  def initialize( req )
    @current = extract_flash_cookie( req )
    @future = {}
  end

  def []=( key, val )
    @future[key.to_s] = val
  end

  def now
    @current
  end

  def []( key )
    future.merge( current )[key.to_s]
  end

  def store_flash( res )
    res.set_cookie( COOKIE_NAME, { path: '/', value: future.to_json } )
  end

  private

  def extract_flash_cookie( req )
    req.cookies[COOKIE_NAME] ? JSON.parse( req.cookies[COOKIE_NAME] ) : {}
  end
end
