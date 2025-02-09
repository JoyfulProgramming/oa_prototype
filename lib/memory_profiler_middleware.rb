require 'memory_profiler'

class MemoryProfilerMiddleware
  def initialize(app)
    @app = app
    @logger = SemanticLogger['MemoryProfiler']
  end

  def call(env)
    response = nil
    report = MemoryProfiler.report do
      response = @app.call(env)
    end

    @logger.info(
      message: "Memory Profile Summary",
      total_allocated: report.total_allocated,
      total_retained: report.total_retained
    )
    response
  end
end
