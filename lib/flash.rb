require 'json'

module ActionDispatchLite
  COOKIE_NAME = '_rails_lite_app_flash'

  class Flash
    attr_reader :now, :future


    def initialize( req )
      @now = FlashNow.new( req )
      @future = {}
    end

    def []=( key, val )
      debugger
      @future[key.to_s] = val
    end

    def []( key )
      future[key.to_s] || now[key.to_s]
    end

    def store_flash( res )
      res.set_cookie( COOKIE_NAME, { path: '/', value: future.to_json } )
    end
  end

  def FlashNow

    def initialize( req )
      @now = extract_flash_cookie( req )
    end

    def []=( k, v )
      @now[k.to_s] = v
    end

    def []( k )
      @now[k.to_s]
    end

    private

    def extract_flash_cookie( req )
      req.cookies[COOKIE_NAME] ? JSON.parse( req.cookies[COOKIE_NAME] ) : {}
    end

  end
end
