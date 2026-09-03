module ffi

import brew_runtime

pub fn core_foundation_autorelease(pointer NativePointer) NativePointer {
	if pointer.is_null() {
		return pointer
	}
	return NativePointer{ ...pointer, free_symbol: 'CFRelease', properties: pointer.properties.clone() }
}

pub fn core_foundation_constant(name string, dereference bool) NativePointer {
	base := stable_pointer_address('CoreFoundation:${name}')
	return NativePointer{
		address: if dereference { base ^ u64(0x9e3779b97f4a7c15) } else { base }
		value: name
		properties: map[string]string{}
	}
}

pub fn core_foundation_string_create(value string, encoding string) NativePointer {
	cf_encoding := match encoding {
		'UTF-8' { '0x08000100' }
		'US-ASCII' { '0x0600' }
		'ASCII-8BIT', 'ISO-8859-1' { '0x0201' }
		else { '0x08000100' }
	}
	return core_foundation_autorelease(NativePointer{
		address: stable_pointer_address('CFString:${cf_encoding}:${value}')
		value: value
		properties: {
			'encoding': cf_encoding
		}
	})
}

pub fn core_foundation_dictionary_create(values map[u64]NativePointer) NativePointer {
	mut properties := map[string]string{}
	for key, value in values {
		properties[key.str()] = value.address.str()
	}
	return core_foundation_autorelease(NativePointer{
		address: stable_pointer_address('CFDictionary:${properties.str()}')
		value: 'dictionary'
		properties: properties
	})
}

pub fn core_foundation_url_create(path NativePointer) NativePointer {
	if path.is_null() {
		return NativePointer{}
	}
	return core_foundation_autorelease(NativePointer{
		address: stable_pointer_address('CFURL:${path.value}')
		value: path.value
		properties: {
			'path_style': 'POSIX'
			'directory':  'false'
		}
	})
}

pub fn core_foundation_url_set_property(mut url NativePointer, key NativePointer,
	value NativePointer) bool {
	if url.is_null() || key.is_null() {
		return false
	}
	url.properties[key.value] = value.value
	return true
}

// Translated from Homebrew/brew `os/mac/ffi/core_foundation.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.autorelease(ptr)` at line 16.
pub fn ruby_core_foundation_l16_d1_self_autorelease(args ...brew_runtime.Value) brew_runtime.Value {
	pointer := NativePointer{ address: (args[0].attributes['address'] or { '0' }).u64(), value: args[0].as_string(), properties: map[string]string{} }
	return native_pointer_value(core_foundation_autorelease(pointer))
}

// Ruby method `self.type_dictionary_key_call_backs = constant("kCFTypeDictionaryKeyCallBacks")` at line 28.
pub fn ruby_core_foundation_l28_d2_self_type_dictionary_key_call_backs(args ...brew_runtime.Value) brew_runtime.Value {
	return native_pointer_value(core_foundation_constant('kCFTypeDictionaryKeyCallBacks', false))
}

// Ruby method `self.type_dictionary_value_call_backs = constant("kCFTypeDictionaryValueCallBacks")` at line 33.
pub fn ruby_core_foundation_l33_d3_self_type_dictionary_value_call_backs(args ...brew_runtime.Value) brew_runtime.Value {
	return native_pointer_value(core_foundation_constant('kCFTypeDictionaryValueCallBacks', false))
}

// Ruby method `self.url_quarantine_properties_key = constant("kCFURLQuarantinePropertiesKey", dereference: true)` at line 38.
pub fn ruby_core_foundation_l38_d4_self_url_quarantine_properties_key(args ...brew_runtime.Value) brew_runtime.Value {
	return native_pointer_value(core_foundation_constant('kCFURLQuarantinePropertiesKey', true))
}

// Ruby method `self.string_create(string)` at line 43.
pub fn ruby_core_foundation_l43_d5_self_string_create(args ...brew_runtime.Value) brew_runtime.Value {
	encoding := if args.len > 1 { args[1].as_string() } else { 'UTF-8' }
	return native_pointer_value(core_foundation_string_create(args[0].as_string(), encoding))
}

// Ruby method `self.dictionary_create(hash)` at line 76.
pub fn ruby_core_foundation_l76_d6_self_dictionary_create(args ...brew_runtime.Value) brew_runtime.Value {
	mut values := map[u64]NativePointer{}
	for key, value in args[0].map_data {
		values[key.u64()] = NativePointer{
			address: (value.attributes['address'] or { '0' }).u64()
			value: value.as_string()
			properties: map[string]string{}
		}
	}
	return native_pointer_value(core_foundation_dictionary_create(values))
}

// Ruby method `self.url_create_with_file_system_path(path)` at line 103.
pub fn ruby_core_foundation_l103_d7_self_url_create_with_file_system_path(args ...brew_runtime.Value) brew_runtime.Value {
	path := NativePointer{ address: (args[0].attributes['address'] or { '0' }).u64(), value: args[0].as_string(), properties: map[string]string{} }
	return native_pointer_value(core_foundation_url_create(path))
}

// Ruby method `self.url_set_resource_property_for_key(url, key, value)` at line 116.
pub fn ruby_core_foundation_l116_d8_self_url_set_resource_property_for_key(args ...brew_runtime.Value) brew_runtime.Value {
	mut url := NativePointer{ address: (args[0].attributes['address'] or { '0' }).u64(), value: args[0].as_string(), properties: map[string]string{} }
	key := NativePointer{ address: (args[1].attributes['address'] or { '0' }).u64(), value: args[1].as_string(), properties: map[string]string{} }
	value := NativePointer{ address: (args[2].attributes['address'] or { '0' }).u64(), value: args[2].as_string(), properties: map[string]string{} }
	return brew_runtime.bool_value(core_foundation_url_set_property(mut url, key, value))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/mac/ffi/native_library"
// 5:
// 6: module OS
// 7:   module Mac
// 8:     module FFI
// 9:       # CoreFoundation.framework wrapper
// 10:       module CoreFoundation
// 11:         extend NativeLibrary
// 12:
// 13:         use_library "/System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation"
// 14:
// 15:         sig { params(ptr: Fiddle::Pointer).returns(Fiddle::Pointer) }
// 16:         def self.autorelease(ptr)
// 17:           return ptr if ptr.null?
// 18:
// 19:           # CoreFoundation/CFBase.h:
// 20:           #   void CFRelease(CFTypeRef cf);
// 21:           ptr.free = function("CFRelease", [Fiddle::TYPE_VOIDP], Fiddle::TYPE_VOID)
// 22:           ptr
// 23:         end
// 24:
// 25:         # CoreFoundation/CFDictionary.h:
// 26:         #   extern const CFDictionaryKeyCallBacks kCFTypeDictionaryKeyCallBacks;
// 27:         sig { returns(Fiddle::Pointer) }
// 28:         def self.type_dictionary_key_call_backs = constant("kCFTypeDictionaryKeyCallBacks")
// 29:
// 30:         # CoreFoundation/CFDictionary.h:
// 31:         #   extern const CFDictionaryValueCallBacks kCFTypeDictionaryValueCallBacks
// 32:         sig { returns(Fiddle::Pointer) }
// 33:         def self.type_dictionary_value_call_backs = constant("kCFTypeDictionaryValueCallBacks")
// 34:
// 35:         # CoreFoundation/CFURL.h:
// 36:         #   extern const CFStringRef kCFURLQuarantinePropertiesKey;
// 37:         sig { returns(Fiddle::Pointer) }
// 38:         def self.url_quarantine_properties_key = constant("kCFURLQuarantinePropertiesKey", dereference: true)
// 39:
// 40:         # CoreFoundation/CFString.h:
// 41:         #   CFStringRef CFStringCreateWithCString(CFAllocatorRef alloc, const char *cStr, CFStringEncoding encoding);
// 42:         sig { params(string: String).returns(Fiddle::Pointer) }
// 43:         def self.string_create(string)
// 44:           cf_encoding = case string.encoding
// 45:           when Encoding::UTF_8
// 46:             0x08000100 # kCFStringEncodingUTF8
// 47:           when Encoding::US_ASCII
// 48:             0x0600 # kCFStringEncodingASCII
// 49:           when Encoding::ASCII_8BIT, Encoding::ISO8859_1
// 50:             # ASCII-8BIT could be anything, so just use Latin-1
// 51:             0x0201 # kCFStringEncodingISOLatin1
// 52:           else
// 53:             # Try convert to UTF-8 and move on
// 54:             string = string.encode(Encoding::UTF_8)
// 55:             0x08000100
// 56:           end
// 57:
// 58:           autorelease(
// 59:             function(
// 60:               "CFStringCreateWithCString",
// 61:               [Fiddle::TYPE_VOIDP, Fiddle::TYPE_CONST_STRING, Fiddle::TYPE_UINT32_T],
// 62:               Fiddle::TYPE_VOIDP,
// 63:             ).call(nil, string, cf_encoding),
// 64:           )
// 65:         end
// 66:
// 67:         # CoreFoundation/CFDictionary.h:
// 68:         #   CFDictionaryRef CFDictionaryCreate(
// 69:         #     CFAllocatorRef allocator,
// 70:         #     const void **keys,
// 71:         #     const void **values,
// 72:         #     CFIndex numValues,
// 73:         #     const CFDictionaryKeyCallBacks *keyCallBacks,
// 74:         #     const CFDictionaryValueCallBacks *valueCallBacks);
// 75:         sig { params(hash: T::Hash[Fiddle::Pointer, Fiddle::Pointer]).returns(Fiddle::Pointer) }
// 76:         def self.dictionary_create(hash)
// 77:           size = Fiddle::SIZEOF_VOIDP * hash.size
// 78:           Fiddle::Pointer.malloc(size, Fiddle::RUBY_FREE) do |keys|
// 79:             Fiddle::Pointer.malloc(size, Fiddle::RUBY_FREE) do |values|
// 80:               # Convert array of pointers to continous stream of pointers in the C buffer
// 81:               keys[0, size] = hash.keys.pack("J*")
// 82:               values[0, size] = hash.values.pack("J*")
// 83:               return autorelease(
// 84:                 function(
// 85:                   "CFDictionaryCreate",
// 86:                   [
// 87:                     Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP,
// 88:                     Fiddle::TYPE_LONG, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP
// 89:                   ],
// 90:                   Fiddle::TYPE_VOIDP,
// 91:                 ).call(
// 92:                   nil, keys, values, hash.size, type_dictionary_key_call_backs, type_dictionary_value_call_backs
// 93:                 ),
// 94:               )
// 95:             end
// 96:           end
// 97:         end
// 98:
// 99:         # CoreFoundation/CFURL.h:
// 100:         #   CFURLRef CFURLCreateWithFileSystemPath(CFAllocatorRef allocator,
// 101:         #     CFStringRef filePath, CFURLPathStyle pathStyle, Boolean isDirectory);
// 102:         sig { params(path: Fiddle::Pointer).returns(Fiddle::Pointer) }
// 103:         def self.url_create_with_file_system_path(path)
// 104:           autorelease(
// 105:             function(
// 106:               "CFURLCreateWithFileSystemPath",
// 107:               [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_LONG, Fiddle::TYPE_BOOL],
// 108:               Fiddle::TYPE_VOIDP,
// 109:             ).call(nil, path, 0, false),
// 110:           )
// 111:         end
// 112:
// 113:         # CoreFoundation/CFURL.h:
// 114:         #   Boolean CFURLSetResourcePropertyForKey(CFURLRef url, CFStringRef key, CFTypeRef value, CFErrorRef *error);
// 115:         sig { params(url: Fiddle::Pointer, key: Fiddle::Pointer, value: Fiddle::Pointer).returns(T::Boolean) }
// 116:         def self.url_set_resource_property_for_key(url, key, value)
// 117:           function(
// 118:             "CFURLSetResourcePropertyForKey",
// 119:             [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP],
// 120:             Fiddle::TYPE_BOOL,
// 121:           ).call(url, key, value, nil)
// 122:         end
// 123:       end
// 124:     end
// 125:   end
// 126: end
