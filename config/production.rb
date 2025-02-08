require_relative '../lib/one_agent/sdk_string.rb'
require_relative '../lib/one_agent.rb'

App.configure do |config|
  config.telemetry_client = OneAgent
  config.tracer = Tracer.new(config.telemetry_client)
end
