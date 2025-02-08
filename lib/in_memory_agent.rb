class InMemoryAgent
  attr_reader :events

  def initialize
    @events = []
    @traces = []
    @web_application_info = {}
    @logging_level = nil
  end

  def _initialize
    clear!
    0 # Simulate successful initialization
  end

  def stub_get_agent_load_info
    [1, 1] # Simulate success
  end

  def clear!
    @events = []
    @traces = []
    @web_application_info = {}
    @logging_level = nil
  end

  def latest_trace
    @traces.last || raise('No trace found')
  end

  def stub_set_logging_level(level)
    @logging_level = level
  end

  def web_application_info_create(name, unique_name, context_root)
    id = SecureRandom.uuid
    @web_application_info = @web_application_info.merge(
      id => {
        id:,
        name:,
        unique_name:,
        context_root:
      }
    )
    id
  end

  def incoming_web_request_tracer_create(web_application_info_id, path, method)
    id = SecureRandom.uuid
    @traces << {
      id: id,
      path:,
      method:,
      application_info: @web_application_info.fetch(web_application_info_id)
    }
    id
  end

  def find_trace_by_id!(id)
    @traces.find { |trace| trace[:id] == id } || raise('Trace not found')
  end

  def incoming_web_request_tracer_set_remote_address(tracer_id, remote_address)
    trace = find_trace_by_id!(tracer_id)
    trace[:remote_address] = remote_address
    nil
  end

  def incoming_web_request_tracer_add_request_headers(tracer_id, name, value, count)
    trace = find_trace_by_id!(tracer_id)
    trace[:request_headers] ||= []
    trace[:request_headers] << { name => value }
    nil
  end

  def incoming_web_request_tracer_set_status_code(tracer_id, status_code)
    trace = find_trace_by_id!(tracer_id)
    trace[:status_code] = status_code
    nil
  end

  def tracer_start(tracer_id)
    trace = find_trace_by_id!(tracer_id)
    trace[:start_time] = Time.now
    nil
  end

  def tracer_end(tracer_id)
    trace = find_trace_by_id!(tracer_id)
    trace[:end_time] = Time.now
    nil
  end

  def traces
    @traces
  end

  def web_application_info
    @web_application_info
  end
end
