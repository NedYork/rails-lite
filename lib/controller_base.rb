require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './session'
require_relative './router.rb'
require 'byebug'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, params = {})
    @params = params
    @req = req
    @res = res
    @params.merge(@req.params)
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise 'error' if already_built_response?
    @already_built_response = true
    res.header["location"] = url
    res.status = 302
    session.store_session(res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise 'error' if already_built_response?
    @already_built_response = true
    res.body = [content]
    res['Content-Type'] = content_type
    session.store_session(res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    template_string = File.read(
      "views/#{self.class.to_s.underscore}/#{template_name}.html.erb"
    )

    render_content(
      ERB.new(template_string).result(binding),
      'text/html'
    )
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name) unless already_built_response?
    # render.send(name) unless already_built_response?
  end
end
