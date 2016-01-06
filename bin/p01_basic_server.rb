require 'rack'
require 'json'
require 'byebug'
require 'erb'

# app = Proc.new do
#   # [status, headers, body]
#   [200, {}, ["hello world!"]]
# end

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  res['Content-Type'] = 'text/html'
  res['body'] = req.path.to_s
  res.write(res['body'])
  res.finish
end

Rack::Server.start({
  app: app,
  Port: 3000
})
