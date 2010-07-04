require 'appengine-rack'
require 'blog'

AppEngine::Rack.configure_app(          
  :application => "jruby-testing",
  :system_properties => {
    'jruby.jit.debug' => true,
    'jruby.jit.codeCache' => '.codecache',
    'jruby.jit.threshold' => 0
  },
  :precompilation_enabled => true,
  :version => "1"
)

run Sinatra::Application