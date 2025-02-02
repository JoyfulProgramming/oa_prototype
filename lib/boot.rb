require 'dry/configurable'
require 'sinatra'

require_relative 'app.rb'
require_relative "../config/#{App.env}.rb"
require_relative '../config/initializers/telemetry_client.rb'

require_relative 'web.rb'
