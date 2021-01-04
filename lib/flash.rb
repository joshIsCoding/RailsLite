require 'json'

class Flash
  attr_reader :stored, :current

  COOKIE_NAME = '_rails_lite_app_flash'

  def initialize( req )
    @stored = extract_flash_cookie( req )
    @current = {}
  end

  def []=( key, val )

  end

  def now
  end

  def []( key )
  end

  def store_flash( res )
  end

  private

  def extract_flash_cookie
  end

end
