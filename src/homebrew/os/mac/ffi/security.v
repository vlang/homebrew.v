module ffi

import brew_runtime

// Translated from Homebrew/brew `os/mac/ffi/security.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.retained_pointer(&block)` at line 33.
pub fn ruby_security_l33_d1_self_retained_pointer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.retained_pointer', ...args)
}

// Ruby method `self.static_code(path)` at line 45.
pub fn ruby_security_l45_d2_self_static_code(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.static_code', ...args)
}

// Ruby method `self.designated_requirement(path)` at line 66.
pub fn ruby_security_l66_d3_self_designated_requirement(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.designated_requirement', ...args)
}

// Ruby method `self.requirement_match(path, requirement)` at line 106.
pub fn ruby_security_l106_d4_self_requirement_match(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.requirement_match', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os/mac/ffi/core_foundation"
// 5: require "os/mac/ffi/objective_c"
// 6:
// 7: module OS
// 8:   module Mac
// 9:     module FFI
// 10:       # Security.framework code-signing wrapper.
// 11:       module Security
// 12:         extend NativeLibrary
// 13:
// 14:         use_library "/System/Library/Frameworks/Security.framework/Versions/A/Security"
// 15:
// 16:         FUNCTION_ARGUMENT_TYPES = T.let(
// 17:           [Fiddle::TYPE_VOIDP, Fiddle::TYPE_UINT32_T, Fiddle::TYPE_VOIDP].freeze,
// 18:           T::Array[Integer],
// 19:         )
// 20:
// 21:         # Validate every architecture, nested code and strict bundle structure.
// 22:         # https://developer.apple.com/documentation/security/static-code-validation-flags
// 23:         VALIDATION_FLAGS = T.let(((1 << 0) | (1 << 3) | (1 << 4)).freeze, Integer)
// 24:
// 25:         # https://developer.apple.com/documentation/security/errseccsreqfailed
// 26:         REQUIREMENT_FAILED_STATUS = -67050
// 27:
// 28:         sig {
// 29:           params(
// 30:             block: T.proc.params(result: Fiddle::Pointer).returns(Integer),
// 31:           ).returns(T.nilable(Fiddle::Pointer))
// 32:         }
// 33:         private_class_method def self.retained_pointer(&block)
// 34:           result = Fiddle::Pointer.malloc(Fiddle::SIZEOF_VOIDP, Fiddle::RUBY_FREE)
// 35:           result[0, Fiddle::SIZEOF_VOIDP] = [0].pack("J")
// 36:           return unless yield(result).zero?
// 37:
// 38:           pointer = result.ptr
// 39:           return if pointer.null?
// 40:
// 41:           CoreFoundation.autorelease(pointer)
// 42:         end
// 43:
// 44:         sig { params(path: String).returns(T.nilable(Fiddle::Pointer)) }
// 45:         private_class_method def self.static_code(path)
// 46:           path_string = CoreFoundation.string_create(File.expand_path(path))
// 47:           return if path_string.null?
// 48:
// 49:           path_url = CoreFoundation.url_create_with_file_system_path(path_string)
// 50:           return if path_url.null?
// 51:
// 52:           retained_pointer do |result|
// 53:             # https://developer.apple.com/documentation/security/secstaticcodecreatewithpath%28_%3A_%3A_%3A%29
// 54:             function(
// 55:               "SecStaticCodeCreateWithPath",
// 56:               FUNCTION_ARGUMENT_TYPES,
// 57:               Fiddle::TYPE_INT,
// 58:             ).call(path_url, 0, result)
// 59:           end
// 60:         end
// 61:
// 62:         # A designated requirement is macOS's durable identity for recognising
// 63:         # successive versions of the same signed code.
// 64:         # https://developer.apple.com/documentation/security/applying-code-requirements
// 65:         sig { params(path: String).returns(T.nilable(String)) }
// 66:         def self.designated_requirement(path)
// 67:           code = static_code(path)
// 68:           return if code.nil?
// 69:
// 70:           requirement = retained_pointer do |result|
// 71:             # https://developer.apple.com/documentation/security/seccodecopydesignatedrequirement%28_%3A_%3A_%3A%29
// 72:             function(
// 73:               "SecCodeCopyDesignatedRequirement",
// 74:               FUNCTION_ARGUMENT_TYPES,
// 75:               Fiddle::TYPE_INT,
// 76:             ).call(code, 0, result)
// 77:           end
// 78:           return if requirement.nil?
// 79:
// 80:           # Validate sealed content against its own identity before trusting it.
// 81:           # https://developer.apple.com/documentation/security/secstaticcodecheckvalidity%28_%3A_%3A_%3A%29
// 82:           return unless function(
// 83:             "SecStaticCodeCheckValidity",
// 84:             FUNCTION_ARGUMENT_TYPES,
// 85:             Fiddle::TYPE_INT,
// 86:           ).call(code, VALIDATION_FLAGS, requirement).zero?
// 87:
// 88:           requirement_string = retained_pointer do |result|
// 89:             function(
// 90:               "SecRequirementCopyString",
// 91:               FUNCTION_ARGUMENT_TYPES,
// 92:               Fiddle::TYPE_INT,
// 93:             ).call(requirement, 0, result)
// 94:           end
// 95:           return if requirement_string.nil?
// 96:
// 97:           ObjectiveC.message_send(
// 98:             requirement_string,
// 99:             "UTF8String",
// 100:             [],
// 101:             Fiddle::TYPE_VOIDP,
// 102:           ).to_s
// 103:         end
// 104:
// 105:         sig { params(path: String, requirement: String).returns(T.nilable(T::Boolean)) }
// 106:         def self.requirement_match(path, requirement)
// 107:           code = static_code(path)
// 108:           return if code.nil?
// 109:
// 110:           requirement_string = CoreFoundation.string_create(requirement)
// 111:           return if requirement_string.null?
// 112:
// 113:           compiled_requirement = retained_pointer do |result|
// 114:             # https://developer.apple.com/documentation/security/1394522-secrequirementcreatewithstring
// 115:             function(
// 116:               "SecRequirementCreateWithString",
// 117:               FUNCTION_ARGUMENT_TYPES,
// 118:               Fiddle::TYPE_INT,
// 119:             ).call(requirement_string, 0, result)
// 120:           end
// 121:           return if compiled_requirement.nil?
// 122:
// 123:           status = function(
// 124:             "SecStaticCodeCheckValidity",
// 125:             FUNCTION_ARGUMENT_TYPES,
// 126:             Fiddle::TYPE_INT,
// 127:           ).call(code, VALIDATION_FLAGS, compiled_requirement)
// 128:           return true if status.zero?
// 129:
// 130:           false if status == REQUIREMENT_FAILED_STATUS
// 131:         end
// 132:       end
// 133:     end
// 134:   end
// 135: end
