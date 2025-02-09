require 'dotenv/load'

require_relative '../lib/in_memory_agent'
require_relative 'flat_json_formatter'
App.configure do |config|
  config.telemetry_client = InMemoryAgent.new
  config.tracer = Tracer.new(config.telemetry_client)
end

SemanticLogger.default_level = :info
SemanticLogger.add_appender(io: $stdout, formatter: FlatJsonFormatter.new)
SemanticLogger.add_appender(
  appender: :http,
  url: "https://#{ENV.fetch('DYNATRACE_ENV_ID')}.live.dynatrace.com/api/v2/logs/ingest",
  header: {"Authorization" => "Api-Token #{ENV.fetch('DYNATRACE_API_TOKEN')}"},
  formatter: FlatJsonFormatter.new
)
