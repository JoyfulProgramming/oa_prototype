require "json"

class FlatJsonFormatter < SemanticLogger::Formatters::Raw
  def initialize(time_format: :iso_8601, time_key: :timestamp, **args)
    super(time_format: time_format, time_key: time_key, **args)
  end

  def call(log, logger)
    log = super(log, logger)
    log.merge!(log.delete(:payload) || {})
    log.to_json
  end
end