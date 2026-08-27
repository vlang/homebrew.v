module cli

import brew_runtime

// Translated from Homebrew/brew `cli/args.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :options_only, :flags_only, :remaining` at line 15.
pub fn ruby_args_l15_d1_options_only(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('options_only', ...args)
}

// Ruby attr_reader `attr_reader :options_only, :flags_only, :remaining` at line 15.
pub fn ruby_args_l15_d2_flags_only(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('flags_only', ...args)
}

// Ruby attr_reader `attr_reader :options_only, :flags_only, :remaining` at line 15.
pub fn ruby_args_l15_d3_remaining(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('remaining', ...args)
}

// Ruby method `initialize` at line 18.
pub fn ruby_args_l18_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `freeze_remaining_args!(remaining_args) = @remaining.replace(remaining_args).freeze` at line 35.
pub fn ruby_args_l35_d5_freeze_remaining_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('freeze_remaining_args!', ...args)
}

// Ruby method `freeze_named_args!(named_args, cask_options:, without_api:)` at line 38.
pub fn ruby_args_l38_d6_freeze_named_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('freeze_named_args!', ...args)
}

// Ruby method `set_arg(name, value)` at line 54.
pub fn ruby_args_l54_d7_set_arg(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('set_arg', ...args)
}

// Ruby method `tap(&_blk)` at line 59.
pub fn ruby_args_l59_d8_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tap', ...args)
}

// Ruby method `freeze_processed_options!(processed_options)` at line 66.
pub fn ruby_args_l66_d9_freeze_processed_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('freeze_processed_options!', ...args)
}

// Ruby method `named` at line 78.
pub fn ruby_args_l78_d10_named(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('named', ...args)
}

// Ruby method `no_named? = named.empty?` at line 84.
pub fn ruby_args_l84_d11_no_named(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('no_named?', ...args)
}

// Ruby method `build_from_source_formulae` at line 87.
pub fn ruby_args_l87_d12_build_from_source_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_from_source_formulae', ...args)
}

// Ruby method `include_test_formulae` at line 96.
pub fn ruby_args_l96_d13_include_test_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('include_test_formulae', ...args)
}

// Ruby method `value(name)` at line 105.
pub fn ruby_args_l105_d14_value(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('value', ...args)
}

// Ruby method `context` at line 114.
pub fn ruby_args_l114_d15_context(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('context', ...args)
}

// Ruby method `only_formula_or_cask` at line 119.
pub fn ruby_args_l119_d16_only_formula_or_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('only_formula_or_cask', ...args)
}

// Ruby method `os_arch_combinations` at line 128.
pub fn ruby_args_l128_d17_os_arch_combinations(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('os_arch_combinations', ...args)
}

// Ruby method `option_to_name(option)` at line 170.
pub fn ruby_args_l170_d18_option_to_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('option_to_name', ...args)
}

// Ruby method `cli_args` at line 176.
pub fn ruby_args_l176_d19_cli_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cli_args', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module CLI
// 6:     class Args
// 7:       # Represents a processed option. The array elements are:
// 8:       #   0: short option name (e.g. "-d")
// 9:       #   1: long option name (e.g. "--debug")
// 10:       #   2: option description (e.g. "Print debugging information")
// 11:       #   3: whether the option is hidden
// 12:       OptionsType = T.type_alias { T::Array[[T.nilable(String), T.nilable(String), String, T::Boolean]] }
// 13:
// 14:       sig { returns(T::Array[String]) }
// 15:       attr_reader :options_only, :flags_only, :remaining
// 16:
// 17:       sig { void }
// 18:       def initialize
// 19:         require "cli/named_args"
// 20:
// 21:         @cli_args = T.let(nil, T.nilable(T::Array[String]))
// 22:         @processed_options = T.let([], OptionsType)
// 23:         @options_only = T.let([], T::Array[String])
// 24:         @flags_only = T.let([], T::Array[String])
// 25:         @cask_options = T.let(false, T::Boolean)
// 26:         @table = T.let({}, T::Hash[Symbol, T.untyped])
// 27:
// 28:         # Can set these because they will be overwritten by freeze_named_args!
// 29:         # (whereas other values below will only be overwritten if passed).
// 30:         @named = T.let(NamedArgs.new(parent: self), T.nilable(NamedArgs))
// 31:         @remaining = T.let([], T::Array[String])
// 32:       end
// 33:
// 34:       sig { params(remaining_args: T::Array[String]).void }
// 35:       def freeze_remaining_args!(remaining_args) = @remaining.replace(remaining_args).freeze
// 36:
// 37:       sig { params(named_args: T::Array[String], cask_options: T::Boolean, without_api: T::Boolean).void }
// 38:       def freeze_named_args!(named_args, cask_options:, without_api:)
// 39:         @named = T.let(
// 40:           NamedArgs.new(
// 41:             *named_args.freeze,
// 42:             cask_options:,
// 43:             flags:         flags_only,
// 44:             force_bottle:  @table[:force_bottle?] || false,
// 45:             override_spec: @table[:HEAD?] ? :head : nil,
// 46:             parent:        self,
// 47:             without_api:,
// 48:           ),
// 49:           T.nilable(NamedArgs),
// 50:         )
// 51:       end
// 52:
// 53:       sig { params(name: Symbol, value: T.untyped).void }
// 54:       def set_arg(name, value)
// 55:         @table[name] = value
// 56:       end
// 57:
// 58:       sig { override.params(_blk: T.nilable(T.proc.params(x: T.untyped).void)).returns(T.untyped) }
// 59:       def tap(&_blk)
// 60:         return super if block_given? # Object#tap
// 61:
// 62:         @table[:tap]
// 63:       end
// 64:
// 65:       sig { params(processed_options: OptionsType).void }
// 66:       def freeze_processed_options!(processed_options)
// 67:         # Reset cache values reliant on processed_options
// 68:         @cli_args = nil
// 69:
// 70:         @processed_options += processed_options
// 71:         @processed_options.freeze
// 72:
// 73:         @options_only = cli_args.select { it.start_with?("-") }.freeze
// 74:         @flags_only = cli_args.select { it.start_with?("--") }.freeze
// 75:       end
// 76:
// 77:       sig { returns(NamedArgs) }
// 78:       def named
// 79:         require "formula"
// 80:         T.must(@named)
// 81:       end
// 82:
// 83:       sig { returns(T::Boolean) }
// 84:       def no_named? = named.empty?
// 85:
// 86:       sig { returns(T::Array[String]) }
// 87:       def build_from_source_formulae
// 88:         if @table[:build_from_source?] || @table[:HEAD?] || @table[:build_bottle?]
// 89:           named.to_formulae.map(&:full_name)
// 90:         else
// 91:           []
// 92:         end
// 93:       end
// 94:
// 95:       sig { returns(T::Array[String]) }
// 96:       def include_test_formulae
// 97:         if @table[:include_test?]
// 98:           named.to_formulae.map(&:full_name)
// 99:         else
// 100:           []
// 101:         end
// 102:       end
// 103:
// 104:       sig { params(name: String).returns(T.nilable(String)) }
// 105:       def value(name)
// 106:         arg_prefix = "--#{name}="
// 107:         flag_with_value = flags_only.find { |arg| arg.start_with?(arg_prefix) }
// 108:         return unless flag_with_value
// 109:
// 110:         flag_with_value.delete_prefix(arg_prefix)
// 111:       end
// 112:
// 113:       sig { returns(Context::ContextStruct) }
// 114:       def context
// 115:         Context::ContextStruct.new(debug: debug?, quiet: quiet?, verbose: verbose?)
// 116:       end
// 117:
// 118:       sig { returns(T.nilable(Symbol)) }
// 119:       def only_formula_or_cask
// 120:         if @table[:formula?] && !@table[:cask?]
// 121:           :formula
// 122:         elsif @table[:cask?] && !@table[:formula?]
// 123:           :cask
// 124:         end
// 125:       end
// 126:
// 127:       sig { returns(T::Array[[Symbol, Symbol]]) }
// 128:       def os_arch_combinations
// 129:         skip_invalid_combinations = false
// 130:
// 131:         # `--all-platforms` is equivalent to `--os=all --arch=all`.
// 132:         all_platforms = @table[:all_platforms?]
// 133:
// 134:         os_sym = all_platforms ? :all : @table[:os]&.to_sym
// 135:         oses = case os_sym
// 136:         when nil
// 137:           [SimulateSystem.current_os]
// 138:         when :all
// 139:           skip_invalid_combinations = true
// 140:
// 141:           OnSystem::ALL_OS_OPTIONS
// 142:         else
// 143:           [os_sym]
// 144:         end
// 145:
// 146:         arch_sym = all_platforms ? :all : @table[:arch]&.to_sym
// 147:         arches = case arch_sym
// 148:         when nil
// 149:           [SimulateSystem.current_arch]
// 150:         when :all
// 151:           skip_invalid_combinations = true
// 152:           OnSystem::ARCH_OPTIONS
// 153:         else
// 154:           [arch_sym]
// 155:         end
// 156:
// 157:         oses.product(arches).select do |os, arch|
// 158:           if skip_invalid_combinations
// 159:             bottle_tag = Utils::Bottles::Tag.new(system: os, arch:)
// 160:             bottle_tag.valid_combination?
// 161:           else
// 162:             true
// 163:           end
// 164:         end
// 165:       end
// 166:
// 167:       private
// 168:
// 169:       sig { params(option: String).returns(String) }
// 170:       def option_to_name(option)
// 171:         option.sub(/\A--?/, "")
// 172:               .tr("-", "_")
// 173:       end
// 174:
// 175:       sig { returns(T::Array[String]) }
// 176:       def cli_args
// 177:         @cli_args ||= @processed_options.filter_map do |short, long|
// 178:           option = T.must(long || short)
// 179:           switch = :"#{option_to_name(option)}?"
// 180:           flag = option_to_name(option).to_sym
// 181:           if @table[switch] == true || @table[flag] == true
// 182:             option
// 183:           elsif @table[flag].instance_of? String
// 184:             "#{option}=#{@table[flag]}"
// 185:           elsif @table[flag].instance_of? Array
// 186:             "#{option}=#{@table[flag].join(",")}"
// 187:           end
// 188:         end.freeze
// 189:       end
// 190:     end
// 191:   end
// 192: end
