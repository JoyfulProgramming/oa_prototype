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
end
