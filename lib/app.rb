class App
  extend Dry::Configurable

  setting :telemetry_client, reader: true
  setting :tracer, reader: true
  def self.env
    (ENV['RACK_ENV'] || 'development').to_sym
  end
end

