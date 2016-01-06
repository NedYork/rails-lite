require 'json'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  attr_accessor :cookie_hash

  def initialize(req)
    cookie_string = req.cookies['_rails_lite_app']
    @cookie_hash = (cookie_string ? JSON.parse(cookie_string) : {})
  end

  def [](key)
    @cookie_hash[key]
  end

  def []=(key, val)
    @cookie_hash[key] = val
    store_session(Rack::Response.new)
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.set_cookie('_rails_lite_app', { path: '/', value: @cookie_hash.to_json })
  end
end
