require 'json'

class Session
  COOKIE_NAME = '_rails_lite_app'
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    cookie_val = req.cookies[COOKIE_NAME]
    @cookie = cookie_val ? JSON.parse( cookie_val ) : {}
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.set_cookie( COOKIE_NAME, @cookie.to_json )
  end
end
