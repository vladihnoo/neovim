local t = require('test.unit.testutil')
local ffi = t.ffi

ffi.cdef[[
  typedef struct {
    char *ptr;
    char *endptr;
    size_t size;
    size_t cap;
  } PackerBuffer;

  typedef struct {
    const char *data;
    size_t size;
  } String;

  void mpack_str(String str, PackerBuffer *packer);
  PackerBuffer packer_string_buffer(void);
]]

local lib = ffi.C
local packer = ffi.new("PackerBuffer[1]", { lib.packer_string_buffer() })

describe("MessagePack fixstr encoding", function()
  it("should verify that strings between 20 and 31 bytes are encoded as fixstr", function()
    for msg_len = 20, 31 do
      local str = string.rep("a", msg_len)
      local cstr = t.to_cstr(str)
      local str_c = ffi.new("String", { data = cstr, size = msg_len })
      packer[0].size = 0
      lib.mpack_str(str_c, packer)
      local packed = ffi.string(packer[0].ptr, packer[0].size)
      local first_byte = string.byte(packed, 1)
      local expected = 160 + msg_len
      t.eq(first_byte, expected)
    end
  end)
end)

