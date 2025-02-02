class TracerMiddleware
  def initialize(app)
    @app = app
    @telemetry_client = App.telemetry_client
  end

  def call(env)
    throw telemetry_client.create_web_application_info(name: 'example.com', unique_name: 'MyWebApplication', context_root: '/my-web-app/')
    @app.call(env)
  end

  private

  attr_reader :telemetry_client
end
