require 'dry/configurable'
require 'sinatra'
require 'semantic_logger'

require_relative 'tracer.rb'
require_relative 'app.rb'
require_relative "../config/#{App.env}.rb"
require_relative '../config/initializers/telemetry_client.rb'

require_relative 'tracer_middleware.rb'
require_relative 'memory_profiler_middleware.rb'
require_relative 'web.rb'
