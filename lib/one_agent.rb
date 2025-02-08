ENV['ONESDK_LOGGING_DESTINATION'] = 'stdout'
ENV['ONESDK_LOGGING_LEVEL'] = 'DEBUG'

require 'ffi'

class OneAgent
  extend FFI::Library
  ffi_lib '/sdk/lib/linux-x86_64/libonesdk_shared.so'

  typedef :uint64, :onesdk_handle_t
  typedef :onesdk_handle_t, :onesdk_tracer_handle_t
  typedef :onesdk_handle_t, :onesdk_webapplicationinfo_handle_t
  typedef :size_t, :onesdk_size_t
  typedef :int32, :onesdk_ccsid_t

  attach_function :onesdk_initialize, [], :int
  def self._initialize
    onesdk_initialize
  end

  attach_function :onesdk_shutdown, [], :int
  def self.shutdown
    onesdk_shutdown
  end

  attach_function :onesdk_stub_get_agent_load_info, [:pointer, :pointer], :void
  def self.stub_get_agent_load_info
    agent_found = FFI::MemoryPointer.new(:int)
    agent_compatible = FFI::MemoryPointer.new(:int)
    onesdk_stub_get_agent_load_info(agent_found, agent_compatible)
    [agent_found.read_int, agent_compatible.read_int]
  end

  attach_function :onesdk_stub_set_logging_level, [:int], :void
  def self.stub_set_logging_level(level)
    onesdk_stub_set_logging_level(level)
  end

  attach_function :onesdk_webapplicationinfo_create_p, [SDKString.by_ref, SDKString.by_ref, SDKString.by_ref], :onesdk_webapplicationinfo_handle_t
  def self.web_application_info_create(name, unique_name, context_root)
    onesdk_webapplicationinfo_create_p(sdk_asciistr(name), sdk_asciistr(unique_name), sdk_asciistr(context_root))
  end

  attach_function :onesdk_incomingwebrequesttracer_create_p, [:onesdk_webapplicationinfo_handle_t, SDKString.by_ref, SDKString.by_ref], :onesdk_tracer_handle_t
  def self.incoming_web_request_tracer_create(web_application_info_handle, path, method)
    onesdk_incomingwebrequesttracer_create_p(web_application_info_handle, sdk_asciistr(path), sdk_asciistr(method))
  end

  attach_function :onesdk_incomingwebrequesttracer_set_remote_address_p, [:onesdk_tracer_handle_t, SDKString.by_ref], :void
  def self.incoming_web_request_tracer_set_remote_address(tracer_handle, remote_address)
    onesdk_incomingwebrequesttracer_set_remote_address_p(tracer_handle, sdk_asciistr(remote_address))
  end

  attach_function :onesdk_incomingwebrequesttracer_add_request_headers_p, [:onesdk_tracer_handle_t, SDKString.by_ref, SDKString.by_ref, :onesdk_size_t], :void
  def self.incoming_web_request_tracer_add_request_headers(tracer_handle, name, value, count)
    onesdk_incomingwebrequesttracer_add_request_headers_p(tracer_handle, sdk_asciistr(name), sdk_asciistr(value), count)
  end

  attach_function :onesdk_incomingwebrequesttracer_add_response_headers_p, [:onesdk_tracer_handle_t, SDKString.by_ref, SDKString.by_ref, :onesdk_size_t], :void
  def self.incoming_web_request_tracer_add_response_headers(tracer_handle, name, value, count)
    onesdk_incomingwebrequesttracer_add_response_headers_p(tracer_handle, sdk_asciistr(name), sdk_asciistr(value), count)
  end

  attach_function :onesdk_incomingwebrequesttracer_set_status_code, [:onesdk_tracer_handle_t, :int], :void
  def self.incoming_web_request_tracer_set_status_code(tracer_handle, status_code)
    onesdk_incomingwebrequesttracer_set_status_code(tracer_handle, status_code)
  end

  attach_function :onesdk_tracer_start, [:onesdk_tracer_handle_t], :void
  def self.tracer_start(tracer_handle)
    onesdk_tracer_start(tracer_handle)
  end

  attach_function :onesdk_tracer_end, [:onesdk_tracer_handle_t], :void
  def self.tracer_end(tracer_handle)
    onesdk_tracer_end(tracer_handle)
  end

  def self.sdk_asciistr(str)
    SDKString.ascii_str(str)
  end
end

