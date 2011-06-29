$: << File.join(File.dirname(__FILE__), '..', 'lib')
$: << File.dirname(__FILE__)

ENV['RACK_ENV'] ||= 'test'

require 'rspec'
require 'rack/test'

require File.dirname(__FILE__) + '/../door'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

