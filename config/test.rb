require_relative '../lib/in_memory_agent'

App.configure do |config|
  config.telemetry_client = InMemoryAgent.new
  config.tracer = Tracer.new(config.telemetry_client)
end
