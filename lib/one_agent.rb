ENV['ONESDK_LOGGING_DESTINATION'] = 'stdout'
ENV['ONESDK_LOGGING_LEVEL'] = 'DEBUG'

require 'ffi'

class OneAgent
  extend FFI::Library
  ffi_lib '/sdk/lib/linux-x86_64/libonesdk_shared.so'
  attach_function :onesdk_initialize, [], :int
  attach_function :onesdk_shutdown, [], :int
  attach_function :onesdk_stub_get_agent_load_info, [:pointer, :pointer], :void
  attach_function :onesdk_stub_set_logging_level, [:int], :void

  typedef :uint64, :onesdk_handle_t
  typedef :onesdk_handle_t, :onesdk_tracer_handle_t
  typedef :onesdk_handle_t, :onesdk_webapplicationinfo_handle_t

  attach_function :onesdk_webapplicationinfo_create_p, [:pointer, :pointer, :pointer], :onesdk_webapplicationinfo_handle_t

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

  class OnesdkString < FFI::Struct
    layout :data, :pointer,
           :byte_length, :size_t,
           :ccsid, :int32
  end

  def self.create_web_application_info(name:, unique_name:, context_root:)
    name_struct = OnesdkString.new
    unique_name_struct = OnesdkString.new
    context_root_struct = OnesdkString.new
    
    [name_struct, unique_name_struct, context_root_struct].zip([name, unique_name, context_root]) do |struct, str|
      str_ptr = FFI::MemoryPointer.from_string(str)
      struct[:data] = str_ptr
      struct[:byte_length] = str.bytesize
      struct[:ccsid] = 0  # Assuming UTF-8 encoding (0 is typically ASCII/UTF-8)
    end
    
    handle = onesdk_webapplicationinfo_create_p(
      name_struct.pointer,
      unique_name_struct.pointer,
      context_root_struct.pointer
    )
    handle
  end

  def trace(env)
    puts "Tracing: #{env}"
  end
end
