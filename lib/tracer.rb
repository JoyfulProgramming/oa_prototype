
class Tracer
  def initialize(agent)
    @agent = agent
  end

  def setup
    @agent.stub_set_logging_level(0)
    result = @agent._initialize
    if result != 0
      raise "Failed to initialize OneAgent: #{result}"
    end

    agent_found, agent_compatible = @agent.stub_get_agent_load_info

    if agent_found == 0 && agent_compatible == 0
      puts "Agent found: #{agent_found != 0}"
      puts "Agent compatible: #{agent_compatible != 0}"
      raise "Error: Agent not found or not compatible"
    end
  end

  def trace(name:, unique_name:, context_root:, env:)
    web_application_info_handle = @agent.web_application_info_create(name, unique_name, context_root)
    tracer_handle = @agent.incoming_web_request_tracer_create(web_application_info_handle, env['PATH_INFO'], env['REQUEST_METHOD'])
    @agent.incoming_web_request_tracer_set_remote_address(tracer_handle, env['REMOTE_ADDR'])
    @agent.incoming_web_request_tracer_add_request_headers(tracer_handle, 'X-Forwarded-For', env['HTTP_X_FORWARDED_FOR'], 1)
    @agent.tracer_start(tracer_handle)
    status, headers, body = yield
    @agent.incoming_web_request_tracer_set_status_code(tracer_handle, status)
    @agent.tracer_end(tracer_handle)
    [status, headers, body]
  end

  def events
    @agent.events
  end
end

