class TracerMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    App.telemetry_client.setup
    handle = App.telemetry_client.create_web_application_info(name: 'WebShopProduction', unique_name: 'CheckoutService', context_root: '/')
    throw handle
    @app.call(env)
  end

  private

  attr_reader :telemetry_client
end
