require_relative '../lib/in_memory_agent'

App.configure do |config|
  config.telemetry_client = InMemoryAgent.new
end
