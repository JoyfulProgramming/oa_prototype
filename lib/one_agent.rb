ENV['ONESDK_LOGGING_DESTINATION'] = 'stdout'
ENV['ONESDK_LOGGING_LEVEL'] = 'DEBUG'
# ENV['DT_SOCKET'] = '/mnt/host_root/var/lib/docker/volumes/app/_data/var/lib/dynatrace/oneagent/agent/unix/socket'
# ENV['LD_PRELOAD'] = '/mnt/host_root/var/lib/docker/volumes/app/_data/opt/agent/processagent/lib64/liboneagentproc.so'

puts "Current Process ID: #{Process.pid}"
puts "Current Process User: #{Process.uid}"

# Debug environment
puts "\nEnvironment Variables:"
%w[DT_SOCKET LD_PRELOAD LD_LIBRARY_PATH].each do |var|
  puts "#{var}: #{ENV[var]}"
end

require 'ffi'

class OneAgent
  extend FFI::Library
  ffi_lib '/sdk/lib/linux-x86_64/libonesdk_shared.so'
  attach_function :onesdk_initialize, [], :int
  attach_function :onesdk_shutdown, [], :int
  attach_function :onesdk_stub_get_agent_load_info, [:pointer, :pointer], :void
  attach_function :onesdk_agent_set_warning_callback, [:pointer], :void
  attach_function :onesdk_agent_set_verbose_callback, [:pointer], :void
  attach_function :onesdk_stub_set_logging_level, [:int], :void
end

callback = FFI::Function.new(:void, [:string]) do |message|
  puts "OneAgent callback received: #{message}"
end
OneAgent.onesdk_agent_set_warning_callback(callback)
OneAgent.onesdk_agent_set_verbose_callback(callback)
OneAgent.onesdk_stub_set_logging_level(1)

puts result = OneAgent.onesdk_initialize
puts "Initialization result: #{result}"

agent_found = FFI::MemoryPointer.new(:int)
agent_compatible = FFI::MemoryPointer.new(:int)

OneAgent.onesdk_stub_get_agent_load_info(agent_found, agent_compatible)

puts "Agent found: #{agent_found.read_int != 0}"
puts "Agent compatible: #{agent_compatible.read_int != 0}"
