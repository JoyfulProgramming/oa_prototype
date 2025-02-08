require_relative '../lib/one_agent'

App.configure do |config|
  config.telemetry_client = OneAgent
  config.tracer = Tracer.new(config.telemetry_client)
end
