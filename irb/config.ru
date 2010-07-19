require 'appengine-rack'
AppEngine::Rack.configure_app(
    :application => "irb",
    :precompilation_enabled => true,
    :version => "1")
run lambda { ::Rack::Response.new("Hello").finish }
