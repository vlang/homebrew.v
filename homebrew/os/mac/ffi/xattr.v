module ffi

pub struct XattrStore {
pub mut:
	values map[string]map[string]string
}

pub fn xattr_error(operation string, path string, attribute ?string, errno int) IError {
	target := attribute or { path }
	return error('${operation} for ${target}: errno ${errno}')
}

pub fn list_xattrs(store &XattrStore, path string) ![]string {
	if path !in store.values {
		return []
	}
	attributes := store.values[path].clone()
	return attributes.keys()
}

pub fn get_xattr(store &XattrStore, path string, attribute string) !string {
	if path !in store.values {
		return xattr_error('getxattr', path, attribute, 1)
	}
	attributes := store.values[path].clone()
	return attributes[attribute] or { return xattr_error('getxattr', path, attribute, 1) }
}

pub fn set_xattr(mut store XattrStore, path string, attribute string, value string) ! {
	mut attributes := if path in store.values {
		store.values[path].clone()
	} else {
		map[string]string{}
	}
	attributes[attribute] = value
	store.values[path] = attributes.clone()
}

pub fn remove_xattr(mut store XattrStore, path string, attribute string) ! {
	if path !in store.values {
		return xattr_error('removexattr', path, attribute, 1)
	}
	mut attributes := store.values[path].clone()
	if attribute !in attributes {
		return xattr_error('removexattr', path, attribute, 1)
	}
	attributes.delete(attribute)
	store.values[path] = attributes.clone()
}

pub fn copy_xattrs(mut store XattrStore, source string, destination string) ! {
	destination_attributes := list_xattrs(&store, destination)!
	for attribute in destination_attributes {
		remove_xattr(mut store, destination, attribute)!
	}
	source_attributes := list_xattrs(&store, source)!
	for attribute in source_attributes {
		set_xattr(mut store, destination, attribute, get_xattr(&store, source, attribute)!)!
	}
}

// Translated from Homebrew/brew `os/mac/ffi/xattr.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.raise_xattr_error(operation, path, attribute = nil)` at line 14.
pub fn ruby_xattr_l14_d1_self_raise_xattr_error(operation string, path string,
	attribute ?string, errno int) IError {
	return xattr_error(operation, path, attribute, errno)
}

// Ruby method `self.list_xattrs(path)` at line 19.
pub fn ruby_xattr_l19_d2_self_list_xattrs(store &XattrStore, path string) ![]string {
	return list_xattrs(store, path)
}

// Ruby method `self.get_xattr(path, attribute)` at line 41.
pub fn ruby_xattr_l41_d3_self_get_xattr(store &XattrStore, path string,
	attribute string) !string {
	return get_xattr(store, path, attribute)
}

// Ruby method `self.set_xattr(path, attribute, value)` at line 69.
pub fn ruby_xattr_l69_d4_self_set_xattr(mut store XattrStore, path string, attribute string,
	value string) ! {
	set_xattr(mut store, path, attribute, value)!
}

// Ruby method `self.remove_xattr(path, attribute)` at line 82.
pub fn ruby_xattr_l82_d5_self_remove_xattr(mut store XattrStore, path string,
	attribute string) ! {
	remove_xattr(mut store, path, attribute)!
}

// Ruby method `self.copy_xattrs(source, destination)` at line 92.
pub fn ruby_xattr_l92_d6_self_copy_xattrs(mut store XattrStore, source string,
	destination string) ! {
	copy_xattrs(mut store, source, destination)!
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
// 9:       extend NativeLibrary
// 10:
// 11:       use_library "/usr/lib/libSystem.B.dylib"
// 12:
// 13:       sig { params(operation: String, path: String, attribute: T.nilable(String)).void }
// 14:       private_class_method def self.raise_xattr_error(operation, path, attribute = nil)
// 15:         raise SystemCallError.new("#{operation} for #{attribute || path}", Fiddle.last_error)
// 16:       end
// 17:
// 18:       sig { params(path: String).returns(T::Array[String]) }
// 19:       def self.list_xattrs(path)
// 20:         names_length = function(
// 21:           "listxattr",
// 22:           [Fiddle::TYPE_CONST_STRING, Fiddle::TYPE_VOIDP, Fiddle::TYPE_SIZE_T, Fiddle::TYPE_INT],
// 23:           Fiddle::TYPE_SSIZE_T,
// 24:         ).call(path, nil, 0, 0)
// 25:         raise_xattr_error("listxattr", path) if names_length == -1
// 26:         return [] if names_length.zero?
// 27:
// 28:         Fiddle::Pointer.malloc(names_length, Fiddle::RUBY_FREE) do |names|
// 29:           read_names_length = function(
// 30:             "listxattr",
// 31:             [Fiddle::TYPE_CONST_STRING, Fiddle::TYPE_VOIDP, Fiddle::TYPE_SIZE_T, Fiddle::TYPE_INT],
// 32:             Fiddle::TYPE_SSIZE_T,
// 33:           ).call(path, names, names_length, 0)
// 34:           raise "Attributes changed during system call" if read_names_length != names_length
// 35:
// 36:           names[0, read_names_length].split("\0")
// 37:         end
// 38:       end
// 39:
// 40:       sig { params(path: String, attribute: String).returns(String) }
// 41:       def self.get_xattr(path, attribute)
// 42:         value_length = function(
// 43:           "getxattr",
// 44:           [
// 45:             Fiddle::TYPE_CONST_STRING, Fiddle::TYPE_CONST_STRING, Fiddle::TYPE_VOIDP,
// 46:             Fiddle::TYPE_SIZE_T, Fiddle::TYPE_UINT32_T, Fiddle::TYPE_INT
// 47:           ],
// 48:           Fiddle::TYPE_SSIZE_T,
// 49:         ).call(path, attribute, nil, 0, 0, 0)
// 50:         raise_xattr_error("getxattr", path, attribute) if value_length == -1
// 51:         return "" if value_length.zero?
// 52:
// 53:         Fiddle::Pointer.malloc(value_length, Fiddle::RUBY_FREE) do |value|
// 54:           read_value_length = function(
// 55:             "getxattr",
// 56:             [
// 57:               Fiddle::TYPE_CONST_STRING, Fiddle::TYPE_CONST_STRING, Fiddle::TYPE_VOIDP,
// 58:               Fiddle::TYPE_SIZE_T, Fiddle::TYPE_UINT32_T, Fiddle::TYPE_INT
// 59:             ],
// 60:             Fiddle::TYPE_SSIZE_T,
// 61:           ).call(path, attribute, value, value_length, 0, 0)
// 62:           raise "Attributes changed during system call" if read_value_length != value_length
// 63:
// 64:           value[0, read_value_length]
// 65:         end
// 66:       end
// 67:
// 68:       sig { params(path: String, attribute: String, value: String).void }
// 69:       def self.set_xattr(path, attribute, value)
// 70:         result = function(
// 71:           "setxattr",
// 72:           [
// 73:             Fiddle::TYPE_CONST_STRING, Fiddle::TYPE_CONST_STRING, Fiddle::TYPE_VOIDP,
// 74:             Fiddle::TYPE_SIZE_T, Fiddle::TYPE_UINT32_T, Fiddle::TYPE_INT
// 75:           ],
// 76:           Fiddle::TYPE_INT,
// 77:         ).call(path, attribute, value.empty? ? nil : Fiddle::Pointer[value], value.bytesize, 0, 0)
// 78:         raise_xattr_error("setxattr", path, attribute) unless result.zero?
// 79:       end
// 80:
// 81:       sig { params(path: String, attribute: String).void }
// 82:       def self.remove_xattr(path, attribute)
// 83:         result = function(
// 84:           "removexattr",
// 85:           [Fiddle::TYPE_CONST_STRING, Fiddle::TYPE_CONST_STRING, Fiddle::TYPE_INT],
// 86:           Fiddle::TYPE_INT,
// 87:         ).call(path, attribute, 0)
// 88:         raise_xattr_error("removexattr", path, attribute) unless result.zero?
// 89:       end
// 90:
// 91:       sig { params(source: String, destination: String).void }
// 92:       def self.copy_xattrs(source, destination)
// 93:         list_xattrs(destination).each { |attribute| remove_xattr(destination, attribute) }
// 94:         list_xattrs(source).each { |attribute| set_xattr(destination, attribute, get_xattr(source, attribute)) }
// 95:       end
// 96:     end
// 97:   end
// 98: end
