module bundle

import brew_runtime

// Translated from Homebrew/brew `bundle/dsl.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :type` at line 16.
pub fn ruby_dsl_l16_d1_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type', ...args)
}

// Ruby attr_reader `attr_reader :name` at line 19.
pub fn ruby_dsl_l19_d2_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby attr_reader `attr_reader :options` at line 22.
pub fn ruby_dsl_l22_d3_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('options', ...args)
}

// Ruby method `initialize(type, name, options = {})` at line 25.
pub fn ruby_dsl_l25_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `to_s` at line 32.
pub fn ruby_dsl_l32_d5_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby attr_reader `attr_reader :entries` at line 38.
pub fn ruby_dsl_l38_d6_entries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('entries', ...args)
}

// Ruby attr_reader `attr_reader :cask_arguments` at line 41.
pub fn ruby_dsl_l41_d7_cask_arguments(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_arguments', ...args)
}

// Ruby attr_reader `attr_reader :input` at line 44.
pub fn ruby_dsl_l44_d8_input(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('input', ...args)
}

// Ruby method `initialize(path)` at line 47.
pub fn ruby_dsl_l47_d9_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `process` at line 66.
pub fn ruby_dsl_l66_d10_process(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('process', ...args)
}

// Ruby method `cask_args(args)` at line 71.
pub fn ruby_dsl_l71_d11_cask_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_args', ...args)
}

// Ruby method `brew(name, options = {})` at line 76.
pub fn ruby_dsl_l76_d12_brew(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('brew', ...args)
}

// Ruby method `cask(name, options = {})` at line 84.
pub fn ruby_dsl_l84_d13_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby method `tap(name, clone_target = nil, options = {}, **keyword_options)` at line 100.
pub fn ruby_dsl_l100_d14_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap', ...args)
}

// Ruby method `validate_type!(value, type, description)` at line 110.
pub fn ruby_dsl_l110_d15_validate_type(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('validate_type!', ...args)
}

// Ruby method `self.sanitize_brew_name(name)` at line 120.
pub fn ruby_dsl_l120_d16_self_sanitize_brew_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.sanitize_brew_name', ...args)
}

// Ruby method `self.sanitize_tap_name(name)` at line 140.
pub fn ruby_dsl_l140_d17_self_sanitize_tap_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.sanitize_tap_name', ...args)
}

// Ruby method `self.sanitize_cask_name(name)` at line 150.
pub fn ruby_dsl_l150_d18_self_sanitize_cask_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.sanitize_cask_name', ...args)
}

// Ruby method `method_missing(method_name, *args, **options, &block)` at line 159.
pub fn ruby_dsl_l159_d19_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('method_missing', ...args)
}

// Ruby method `respond_to_missing?(method_name, include_private = false)` at line 186.
pub fn ruby_dsl_l186_d20_respond_to_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('respond_to_missing?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module Bundle
// 6:     EntryOptionScalar = T.type_alias { T.nilable(T.any(String, Integer, Symbol, TrueClass, FalseClass)) }
// 7:     NestedEntryOptionValue = T.type_alias { T.any(EntryOptionScalar, T::Array[String]) }
// 8:     NestedEntryOptions = T.type_alias { T::Hash[Symbol, NestedEntryOptionValue] }
// 9:     EntryOption = T.type_alias { T.any(EntryOptionScalar, T::Array[String], NestedEntryOptions) }
// 10:     EntryOptions = T.type_alias { T::Hash[Symbol, EntryOption] }
// 11:     EntryInputOptions = T.type_alias { T::Hash[Symbol, Object] }
// 12:
// 13:     class Dsl
// 14:       class Entry
// 15:         sig { returns(Symbol) }
// 16:         attr_reader :type
// 17:
// 18:         sig { returns(String) }
// 19:         attr_reader :name
// 20:
// 21:         sig { returns(Homebrew::Bundle::EntryOptions) }
// 22:         attr_reader :options
// 23:
// 24:         sig { params(type: Symbol, name: String, options: Homebrew::Bundle::EntryOptions).void }
// 25:         def initialize(type, name, options = {})
// 26:           @type = type
// 27:           @name = name
// 28:           @options = options
// 29:         end
// 30:
// 31:         sig { returns(String) }
// 32:         def to_s
// 33:           name
// 34:         end
// 35:       end
// 36:
// 37:       sig { returns(T::Array[Entry]) }
// 38:       attr_reader :entries
// 39:
// 40:       sig { returns(T::Hash[Symbol, T.untyped]) }
// 41:       attr_reader :cask_arguments
// 42:
// 43:       sig { returns(String) }
// 44:       attr_reader :input
// 45:
// 46:       sig { params(path: T.any(Pathname, StringIO)).void }
// 47:       def initialize(path)
// 48:         @path = path
// 49:         path_read = path.read
// 50:         raise "path_read is nil" unless path_read
// 51:
// 52:         @input = T.let(path_read, String)
// 53:         @entries = T.let([], T::Array[Entry])
// 54:         @cask_arguments = T.let({}, T::Hash[Symbol, T.untyped])
// 55:
// 56:         begin
// 57:           process
// 58:         # Want to catch all exceptions for e.g. syntax errors.
// 59:         rescue Exception => e # rubocop:disable Lint/RescueException
// 60:           error_msg = "Invalid Brewfile: #{e.message}"
// 61:           raise RuntimeError, error_msg, e.backtrace
// 62:         end
// 63:       end
// 64:
// 65:       sig { void }
// 66:       def process
// 67:         instance_eval(@input, @path.to_s)
// 68:       end
// 69:
// 70:       sig { params(args: T::Hash[Symbol, T.untyped]).void }
// 71:       def cask_args(args)
// 72:         @cask_arguments.merge!(args)
// 73:       end
// 74:
// 75:       sig { params(name: String, options: Homebrew::Bundle::EntryOptions).void }
// 76:       def brew(name, options = {})
// 77:         validate_type!(options, Hash, "brew options")
// 78:
// 79:         name = Homebrew::Bundle::Dsl.sanitize_brew_name(name)
// 80:         @entries << Entry.new(:brew, name, options)
// 81:       end
// 82:
// 83:       sig { params(name: String, options: Homebrew::Bundle::EntryOptions).void }
// 84:       def cask(name, options = {})
// 85:         options[:full_name] = name
// 86:         name = Homebrew::Bundle::Dsl.sanitize_cask_name(name)
// 87:         options[:args] =
// 88:           @cask_arguments.merge T.cast(options.fetch(:args, {}), T::Hash[Symbol, NestedEntryOptionValue])
// 89:         @entries << Entry.new(:cask, name, options)
// 90:       end
// 91:
// 92:       sig {
// 93:         params(
// 94:           name:            String,
// 95:           clone_target:    T.nilable(String),
// 96:           options:         Homebrew::Bundle::EntryOptions,
// 97:           keyword_options: Homebrew::Bundle::EntryOption,
// 98:         ).void
// 99:       }
// 100:       def tap(name, clone_target = nil, options = {}, **keyword_options)
// 101:         validate_type!(clone_target, String, "tap clone target") if clone_target
// 102:
// 103:         options.merge!(keyword_options)
// 104:         options[:clone_target] = clone_target
// 105:         name = Homebrew::Bundle::Dsl.sanitize_tap_name(name)
// 106:         @entries << Entry.new(:tap, name, options)
// 107:       end
// 108:
// 109:       sig { params(value: Object, type: T.any(T.class_of(Hash), T.class_of(String)), description: String).void }
// 110:       def validate_type!(value, type, description)
// 111:         raise "#{description} must be a #{type}" unless value.is_a?(type)
// 112:       end
// 113:       private :validate_type!
// 114:
// 115:       HOMEBREW_TAP_ARGS_REGEX = %r{^([\w-]+)/(homebrew-)?([\w-]+)$}
// 116:       HOMEBREW_CORE_FORMULA_REGEX = %r{^homebrew/homebrew/([\w+-.@]+)$}i
// 117:       HOMEBREW_TAP_FORMULA_REGEX = %r{^([\w-]+)/([\w-]+)/([\w+-.@]+)$}
// 118:
// 119:       sig { params(name: String).returns(String) }
// 120:       def self.sanitize_brew_name(name)
// 121:         name = name.downcase
// 122:         if name =~ HOMEBREW_CORE_FORMULA_REGEX
// 123:           sanitized_name = Regexp.last_match(1)
// 124:           raise "sanitized_name is nil" unless sanitized_name
// 125:
// 126:           sanitized_name
// 127:         elsif name =~ HOMEBREW_TAP_FORMULA_REGEX
// 128:           user = Regexp.last_match(1)
// 129:           repo = Regexp.last_match(2)
// 130:           name = Regexp.last_match(3)
// 131:           raise "repo is nil" unless repo
// 132:
// 133:           "#{user}/#{repo.sub("homebrew-", "")}/#{name}"
// 134:         else
// 135:           name
// 136:         end
// 137:       end
// 138:
// 139:       sig { params(name: String).returns(String) }
// 140:       def self.sanitize_tap_name(name)
// 141:         name = name.downcase
// 142:         if name =~ HOMEBREW_TAP_ARGS_REGEX
// 143:           "#{Regexp.last_match(1)}/#{Regexp.last_match(3)}"
// 144:         else
// 145:           name
// 146:         end
// 147:       end
// 148:
// 149:       sig { params(name: String).returns(String) }
// 150:       def self.sanitize_cask_name(name)
// 151:         require "utils"
// 152:         Utils.name_from_full_name(name).downcase
// 153:       end
// 154:
// 155:       sig {
// 156:         override.params(method_name: Symbol, args: T.untyped, options: T.untyped,
// 157:                         block: T.nilable(T.proc.void)).returns(T.untyped)
// 158:       }
// 159:       def method_missing(method_name, *args, **options, &block)
// 160:         require "bundle/extensions"
// 161:         extension = Homebrew::Bundle.extension(method_name)
// 162:         return super if extension.nil?
// 163:         raise ArgumentError, "blocks are not supported for #{method_name}" if block
// 164:
// 165:         # Extension DSL entries follow the existing Brewfile calling convention:
// 166:         # a required name plus an optional options hash, passed positionally,
// 167:         # with keywords, or both.
// 168:         unless (1..2).cover?(args.length)
// 169:           raise ArgumentError,
// 170:                 "wrong number of arguments (given #{args.length}, expected 1..2)"
// 171:         end
// 172:
// 173:         positional_options = {}
// 174:         if args.length == 2
// 175:           positional_options = args[1]
// 176:           unless positional_options.is_a? Hash
// 177:             raise ArgumentError,
// 178:                   "options(#{positional_options.inspect}) should be a Hash object"
// 179:           end
// 180:         end
// 181:
// 182:         @entries << extension.entry(args.first, positional_options.merge(options))
// 183:       end
// 184:
// 185:       sig { override.params(method_name: T.any(String, Symbol), include_private: T::Boolean).returns(T::Boolean) }
// 186:       def respond_to_missing?(method_name, include_private = false)
// 187:         require "bundle/extensions"
// 188:         !Homebrew::Bundle.extension(method_name).nil? || super
// 189:       end
// 190:     end
// 191:   end
// 192: end
