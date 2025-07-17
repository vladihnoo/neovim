local t = require('test.unit.testutil') 
local ffi = t.ffi 
local cimport = t.import 
local lib = cimport('./src/nvim/msgpack_rpc/packer.h')
local packer = ffi.new("PackerBuffer[1]") 

describe("MessagePack fixstr encoding",function()
  it("should verify that strings between 20 and 31 bytes are encoded as fixstr",function()
    for len = 20,31 do 
      local str = string.rep("a", len) 
      local str_c = ffi.new("String",{data = t.to_cstr(str), size = len}) 
      lib.mpack_str(str_c, packer) 
      local packed = ffi.string(packer[0].ptr, packer[0].size) 
      local first_byte = string.byte(packed,1) 

      t.eq(first_byte,0xa0+len) 
      end


    end
  end)
end) 
