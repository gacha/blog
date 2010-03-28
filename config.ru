require 'appengine-rack'
AppEngine::Rack.configure_app(          
    :application => "jruby-testing",           
    :precompilation_enabled => true,
    :version => "1")

require 'blog'
run Sinatra::Application
