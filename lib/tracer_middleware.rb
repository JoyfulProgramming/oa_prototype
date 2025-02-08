class TracerMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    App.tracer.trace(name: 'destroyallai.com:80', unique_name: 'destroyallai.com:80', context_root: '/', env: env) do
      @app.call(env)
    end
  end

  private

  attr_reader :tracer
end
