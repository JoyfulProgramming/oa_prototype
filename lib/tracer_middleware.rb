class TracerMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    App.telemetry_client.trace(name: 'WebShopProduction', unique_name: 'CheckoutService', context_root: '/') do
      @app.call(env)
    end
  end

  private

  attr_reader :telemetry_client
end
