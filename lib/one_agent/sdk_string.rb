require 'ffi'

class OneAgent
  class SDKString < FFI::Struct
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
end 