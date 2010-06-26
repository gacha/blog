require 'appengine-rack'
require 'blog'

AppEngine::Rack.configure_app(          
  :application => "jruby-testing",           
  :precompilation_enabled => true,
  :version => "1"
)

run Sinatra::Application