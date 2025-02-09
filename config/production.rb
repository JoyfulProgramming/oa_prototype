require_relative '../lib/one_agent/sdk_string.rb'
require_relative '../lib/one_agent.rb'

App.configure do |config|
  config.telemetry_client = OneAgent
  config.tracer = Tracer.new(config.telemetry_client)
end

SemanticLogger.default_level = :info
SemanticLogger.add_appender(
  appender: :http,
  url: "https://#{ENV.fetch('DYNATRACE_ENV_ID')}.live.dynatrace.com/api/v2/logs/ingest",
  header: {"Authorization" => "Api-Token #{ENV.fetch('DYNATRACE_API_TOKEN')}"},
  formatter: FlatJsonFormatter.new
)
