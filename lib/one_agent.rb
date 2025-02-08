ENV['ONESDK_LOGGING_DESTINATION'] = 'stdout'
ENV['ONESDK_LOGGING_LEVEL'] = 'DEBUG'

require 'ffi'

class OneAgent

  class OnesdkString < FFI::Struct
    layout :data, :pointer,
           :byte_length, :size_t,
           :ccsid, :uint16

    # CCSID Constants matching the C SDK
    CCSID_NULL      = 0
    CCSID_ASCII     = 367
    CCSID_ISO8859_1 = 819
    CCSID_UTF8      = 1209
    CCSID_UTF16_BE  = 1201
    CCSID_UTF16_LE  = 1203
    CCSID_UTF16_NATIVE = [1].pack('S').unpack('S').first == 1 ? CCSID_UTF16_LE : CCSID_UTF16_BE

    def self.nullstr
      struct = new
      struct[:data] = nil
      struct[:byte_length] = 0
      struct[:ccsid] = CCSID_NULL
      struct
    end

    def self.from_string(str, ccsid = CCSID_ASCII)
      return nullstr if str.nil?
      
      struct = new
      # Create a memory pointer that won't be garbage collected
      str_ptr = FFI::MemoryPointer.from_string(str)
      struct[:data] = str_ptr
      struct[:byte_length] = str.bytesize
      struct[:ccsid] = ccsid
      # Store the pointer as an instance variable to prevent GC
      struct.instance_variable_set(:@str_ptr, str_ptr)
      struct
    end

    def self.ascii_str(str)
      from_string(str, CCSID_ASCII)
    end

    def self.utf8_str(str)
      from_string(str, CCSID_UTF8)
    end
  end

  extend FFI::Library
  ffi_lib '/sdk/lib/linux-x86_64/libonesdk_shared.so'
  attach_function :onesdk_initialize, [], :int
  attach_function :onesdk_shutdown, [], :int
  attach_function :onesdk_stub_get_agent_load_info, [:pointer, :pointer], :void
  attach_function :onesdk_stub_set_logging_level, [:int], :void

  typedef :uint64, :onesdk_handle_t
  typedef :onesdk_handle_t, :onesdk_tracer_handle_t
  typedef :onesdk_handle_t, :onesdk_webapplicationinfo_handle_t
  typedef :size_t, :onesdk_size_t
  typedef :int32, :onesdk_ccsid_t

  attach_function :onesdk_webapplicationinfo_create_p, [OnesdkString.by_ref, OnesdkString.by_ref, OnesdkString.by_ref], :onesdk_webapplicationinfo_handle_t

  attach_function :onesdk_incomingwebrequesttracer_create_p, [:onesdk_webapplicationinfo_handle_t, OnesdkString.by_ref, OnesdkString.by_ref], :onesdk_tracer_handle_t

  attach_function :onesdk_incomingwebrequesttracer_set_remote_address_p, [:onesdk_tracer_handle_t, OnesdkString.by_ref], :void
  attach_function :onesdk_incomingwebrequesttracer_add_request_headers_p, [:onesdk_tracer_handle_t, OnesdkString.by_ref, OnesdkString.by_ref, :onesdk_size_t], :void
  attach_function :onesdk_incomingwebrequesttracer_set_status_code, [:onesdk_tracer_handle_t, :int], :void
  attach_function :onesdk_tracer_start, [:onesdk_tracer_handle_t], :void
  attach_function :onesdk_tracer_end, [:onesdk_tracer_handle_t], :void

  def self.setup
    onesdk_stub_set_logging_level(0)
    result = onesdk_initialize
    if result != 0
      raise "Failed to initialize OneAgent: #{result}"
    end

    agent_found = FFI::MemoryPointer.new(:int)
    agent_compatible = FFI::MemoryPointer.new(:int)

    OneAgent.onesdk_stub_get_agent_load_info(agent_found, agent_compatible)

    if agent_found.read_int == 0 && agent_compatible.read_int == 0
      puts "Agent found: #{agent_found.read_int != 0}"
      puts "Agent compatible: #{agent_compatible.read_int != 0}"
      raise "Error: Agent not found or not compatible"
    end
  end

  def self.create_web_application_info(name:, unique_name:, context_root:)
    onesdk_webapplicationinfo_create_p(
      onesdk_asciistr(name),
      onesdk_asciistr(unique_name),
      onesdk_asciistr(context_root)
    )
  end

  def self.onesdk_asciistr(str)
    OnesdkString.ascii_str(str)
  end

  def self.trace(attrs)
    web_application_info_handle = create_web_application_info(
      name: attrs[:name] || "unknown",
      unique_name: attrs[:unique_name] || "unknown",
      context_root: attrs[:context_root] || "unknown"
    )

    tracer = onesdk_incomingwebrequesttracer_create_p(
        web_application_info_handle,
        onesdk_asciistr('/aaa'),
        onesdk_asciistr('GET')
    );

    # onesdk_incomingwebrequesttracer_set_remote_address_p(tracer, onesdk_asciistr("1.2.3.4:56789"));
    # onesdk_incomingwebrequesttracer_add_request_headers_p(tracer,
        # onesdk_asciistr("Connection"), onesdk_asciistr("keep-alive"));

    onesdk_tracer_start(tracer);

    response = yield

    # onesdk_incomingwebrequesttracer_add_response_headers_p(tracer,
        # onesdk_asciistr("Transfer-Encoding"), onesdk_asciistr("chunked"));
    onesdk_incomingwebrequesttracer_set_status_code(tracer, 124);

    # if attrs[:error]
      # onesdk_tracer_error_p(tracer, onesdk_asciistr("error type"), onesdk_asciistr("error message"));
    # end

    onesdk_tracer_end(tracer);
    response
  end
end
