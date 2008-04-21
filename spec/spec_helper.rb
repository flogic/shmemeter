$:.unshift(File.dirname(__FILE__) + '/../lib/')

require 'rubygems'
require 'mocha'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

def setup_rails_environment
  dir = File.dirname(__FILE__)
  
  ENV['RAILS_ENV'] ||= 'test'
  require "#{dir}/../../../../config/environment"

  require "#{dir}/../init.rb"
end
