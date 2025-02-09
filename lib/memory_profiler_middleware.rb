require 'memory_profiler'

class MemoryProfilerMiddleware
  def initialize(app)
    @app = app
    @logger = SemanticLogger['destroyallai.com:80']
  end

  def call(env)
    response = nil
    report = MemoryProfiler.report do
      response = @app.call(env)
    end

    @logger.info(
      event: {
        name: "http.request.received",
      },
      http: {
        path: env["PATH_INFO"],
        url: env["REQUEST_URI"],
        method: env["REQUEST_METHOD"],
        status_code: response[0],
      },
      message: "HTTP Request Received [#{env["REQUEST_METHOD"]} #{env["REQUEST_URI"]}]",
      memory: {
        total_allocated: report.total_allocated,
        total_retained: report.total_retained
      }
    )
    response
  end
end
