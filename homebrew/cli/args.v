module cli

import ruby

// Translated from Homebrew/brew `cli/args.rb`.
// The original source is retained below until every stub has a typed V body.

// ArgValueKind preserves the Ruby argument table's switch, scalar flag and
// comma-array values without falling back to an untyped boundary.
pub enum ArgValueKind {
	unset
	switch_value
	flag_value
	comma_array
}

pub struct ArgValue {
pub:
	kind    ArgValueKind
	enabled bool
	text    string
	items   []string
}

pub struct ArgsContext {
pub:
	debug   bool
	quiet   bool
	verbose bool
}

pub struct ArgsOsArch {
pub:
	os   string
	arch string
}

@[heap]
pub struct Args {
pub mut:
	options_only      []string
	flags_only        []string
	remaining         []string
	named             NamedArgs
	values            map[string]ArgValue
	processed_options []ProcessedOption
	cask_options      bool
	without_api       bool
	cli_args_cache    []string
	cli_args_loaded   bool
	current_os        string
	current_arch      string
}

pub fn new_args() &Args {
	return &Args{
		named: new_named_args([])
	}
}

pub fn (args Args) no_named() bool {
	return args.named.empty()
}

pub fn (args Args) has(name string) bool {
	value := args.values[option_to_name(name)] or { return false }
	return match value.kind {
		.switch_value { value.enabled }
		.flag_value { value.text.len > 0 }
		.comma_array { value.items.len > 0 }
		.unset { false }
	}
}

pub fn (args Args) switch_value(name string) ?bool {
	value := args.values[option_to_name(name)] or { return none }
	if value.kind != .switch_value {
		return none
	}
	return value.enabled
}

pub fn (args Args) flag_value(name string) ?string {
	value := args.values[option_to_name(name)] or { return none }
	if value.kind != .flag_value {
		return none
	}
	return value.text
}

pub fn (args Args) comma_array_value(name string) ?[]string {
	value := args.values[option_to_name(name)] or { return none }
	if value.kind != .comma_array {
		return none
	}
	return value.items.clone()
}

// value implements Args#value: only a long flag in --name=value form is
// returned, matching the flags_only lookup in the Ruby source.
pub fn (args Args) value(name string) ?string {
	prefix := '--${name}='
	for flag in args.flags_only {
		if flag.starts_with(prefix) {
			return flag[prefix.len..]
		}
	}
	return none
}

pub fn (args Args) only_formula_or_cask() ?string {
	formula := args.has('formula')
	cask := args.has('cask')
	if formula && !cask {
		return 'formula'
	}
	if cask && !formula {
		return 'cask'
	}
	return none
}

pub fn (mut args Args) freeze_remaining_args(remaining []string) {
	args.remaining = remaining.clone()
}

pub fn (mut args Args) freeze_named_args(named []string, cask_options bool, without_api bool) {
	args.cask_options = cask_options
	args.without_api = without_api
	args.named = new_named_args_with_config(named, NamedArgsConfig{
		parent: NamedArgsParent{
			package_type: args.only_formula_or_cask() or { '' }
			options_only: args.options_only.clone()
		}
		override_spec: if args.has('HEAD') { 'head' } else { '' }
		force_bottle: args.has('force_bottle')
		flags: args.flags_only.clone()
		cask_options: cask_options
		without_api: without_api
	})
}

fn args_table_name(name string) string {
	return option_to_name(name.trim_right('?'))
}

pub fn (mut args Args) set_arg(name string, value ArgValue) {
	args.values[args_table_name(name)] = value
	args.cli_args_loaded = false
}

pub fn (args Args) tap_value() ?ArgValue {
	return args.values['tap']
}

pub fn (mut args Args) freeze_processed_options(options []ProcessedOption) {
	args.processed_options << options
	args.cli_args_loaded = false
	rendered := args.cli_args()
	args.options_only = rendered.filter(it.starts_with('-'))
	args.flags_only = rendered.filter(it.starts_with('--'))
}

pub fn (args Args) build_from_source_formulae() ![]string {
	if !args.has('build_from_source') && !args.has('HEAD') && !args.has('build_bottle') {
		return []
	}
	formulae := args.named.to_formulae()!
	return formulae.map(if it.full_name != '' { it.full_name } else { it.name })
}

pub fn (args Args) include_test_formulae() ![]string {
	if !args.has('include_test') {
		return []
	}
	formulae := args.named.to_formulae()!
	return formulae.map(if it.full_name != '' { it.full_name } else { it.name })
}

pub fn (args Args) context() ArgsContext {
	return ArgsContext{
		debug: args.has('debug')
		quiet: args.has('quiet')
		verbose: args.has('verbose')
	}
}

fn native_args_os() string {
	$if linux {
		return 'linux'
	} $else {
		return 'macos'
	}
}

fn native_args_arch() string {
	$if arm64 {
		return 'arm'
	} $else {
		return 'intel'
	}
}

fn valid_args_os_arch(os_name string, arch string) bool {
	if arch != 'arm' || os_name == 'linux' || os_name == 'macos' {
		return true
	}
	return os_name in ['big_sur', 'monterey', 'ventura', 'sonoma', 'sequoia', 'tahoe', 'golden_gate']
}

pub fn (args Args) os_arch_combinations() []ArgsOsArch {
	all_platforms := args.has('all_platforms')
	os_value := if all_platforms { 'all' } else { args.flag_value('os') or { '' } }
	arch_value := if all_platforms { 'all' } else { args.flag_value('arch') or { '' } }
	current_os := if args.current_os != '' { args.current_os } else { native_args_os() }
	current_arch := if args.current_arch != '' { args.current_arch } else { native_args_arch() }
	oses := if os_value == 'all' {
		['golden_gate', 'tahoe', 'sequoia', 'sonoma', 'ventura', 'monterey', 'big_sur', 'catalina',
			'linux']
	} else if os_value != '' {
		[os_value]
	} else {
		[current_os]
	}
	arches := if arch_value == 'all' {
		['intel', 'arm']
	} else if arch_value != '' {
		[arch_value]
	} else {
		[current_arch]
	}
	filter_invalid := os_value == 'all' || arch_value == 'all'
	mut combinations := []ArgsOsArch{}
	for os_name in oses {
		for arch in arches {
			if !filter_invalid || valid_args_os_arch(os_name, arch) {
				combinations << ArgsOsArch{
					os: os_name
					arch: arch
				}
			}
		}
	}
	return combinations
}

pub fn (mut args Args) cli_args() []string {
	if args.cli_args_loaded {
		return args.cli_args_cache.clone()
	}
	mut rendered := []string{}
	for processed in args.processed_options {
		option := if processed.long != '' { processed.long } else { processed.short }
		if option == '' {
			continue
		}
		value := args.values[args_table_name(option)] or { continue }
		match value.kind {
			.switch_value {
				if value.enabled {
					rendered << option
				}
			}
			.flag_value {
				rendered << '${option}=${value.text}'
			}
			.comma_array {
				rendered << '${option}=${value.items.join(',')}'
			}
			.unset {}
		}
	}
	args.cli_args_cache = rendered.clone()
	args.cli_args_loaded = true
	return rendered
}

fn args_nil_value() ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

pub fn args_boundary(args &Args) ruby.Value {
	return ruby.structured_value('Homebrew::CLI::Args', args.options_only.str(), {
		'args_address': u64(voidptr(args)).str()
	})
}

fn args_from_boundary(value ruby.Value) &Args {
	address := value.attributes['args_address'] or { panic('invalid Homebrew::CLI::Args boundary') }
	return unsafe { &Args(voidptr(address.u64())) }
}

fn args_receiver(values []ruby.Value) (&Args, int) {
	if values.len > 0 && 'args_address' in values[0].attributes {
		return args_from_boundary(values[0]), 1
	}
	return new_args(), 0
}

fn named_args_boundary(named NamedArgs) ruby.Value {
	return ruby.Value{
		type_name: 'Homebrew::CLI::NamedArgs'
		repr: named.values.str()
		string_array_data: named.values.clone()
		attributes: {
			'cask_options':  named.cask_options.str()
			'without_api':   named.without_api.str()
			'force_bottle':  named.force_bottle.str()
			'override_spec': named.override_spec
		}
	}
}

fn arg_value_from_boundary(value ruby.Value) ArgValue {
	return match value.type_name {
		'Bool' {
			ArgValue{
				kind: .switch_value
				enabled: value.bool_data
			}
		}
		'Array' {
			ArgValue{
				kind: .comma_array
				items: value.as_string_array() or { value.array_data.map(it.as_string()) }
			}
		}
		else {
			ArgValue{
				kind: .flag_value
				text: value.as_string()
			}
		}
	}
}

fn arg_value_boundary(value ArgValue) ruby.Value {
	return match value.kind {
		.switch_value { ruby.bool_value(value.enabled) }
		.flag_value { ruby.string_value(value.text) }
		.comma_array { ruby.string_array_value(value.items) }
		.unset { args_nil_value() }
	}
}

fn processed_options_from_boundary(value ruby.Value) []ProcessedOption {
	mut options := []ProcessedOption{}
	for item in value.as_array() or { []ruby.Value{} } {
		if item.attributes.len > 0 {
			options << ProcessedOption{
				short: item.attributes['short'] or { '' }
				long: item.attributes['long'] or { '' }
				description: item.attributes['description'] or { '' }
				hidden: (item.attributes['hidden'] or { 'false' }).bool()
			}
			continue
		}
		parts := item.as_array() or { []ruby.Value{} }
		if parts.len > 0 {
			options << ProcessedOption{
				short: if parts[0].type_name == 'NilClass' { '' } else { parts[0].as_string() }
				long: if parts.len > 1 && parts[1].type_name != 'NilClass' {
					parts[1].as_string()
				} else {
					''
				}
				description: if parts.len > 2 { parts[2].as_string() } else { '' }
				hidden: if parts.len > 3 { parts[3].bool_data } else { false }
			}
		}
	}
	return options
}

// Ruby attr_reader `attr_reader :options_only, :flags_only, :remaining` at line 15.
pub fn ruby_args_l15_d1_options_only(args ...ruby.Value) ruby.Value {
	receiver, _ := args_receiver(args)
	return ruby.string_array_value(receiver.options_only)
}

// Ruby attr_reader `attr_reader :options_only, :flags_only, :remaining` at line 15.
pub fn ruby_args_l15_d2_flags_only(args ...ruby.Value) ruby.Value {
	receiver, _ := args_receiver(args)
	return ruby.string_array_value(receiver.flags_only)
}

// Ruby attr_reader `attr_reader :options_only, :flags_only, :remaining` at line 15.
pub fn ruby_args_l15_d3_remaining(args ...ruby.Value) ruby.Value {
	receiver, _ := args_receiver(args)
	return ruby.string_array_value(receiver.remaining)
}

// Ruby method `initialize` at line 18.
pub fn ruby_args_l18_d4_initialize(args ...ruby.Value) ruby.Value {
	return args_boundary(new_args())
}

// Ruby method `freeze_remaining_args!(remaining_args) = @remaining.replace(remaining_args).freeze` at line 35.
pub fn ruby_args_l35_d5_freeze_remaining_args(args ...ruby.Value) ruby.Value {
	mut receiver, offset := args_receiver(args)
	if args.len > offset {
		receiver.freeze_remaining_args(args[offset].as_string_array() or { [] })
	}
	return args_nil_value()
}

// Ruby method `freeze_named_args!(named_args, cask_options:, without_api:)` at line 38.
pub fn ruby_args_l38_d6_freeze_named_args(args ...ruby.Value) ruby.Value {
	mut receiver, offset := args_receiver(args)
	named := if args.len > offset { args[offset].as_string_array() or { [] } } else { [] }
	cask_options := if args.len > offset + 1 { args[offset + 1].bool_data } else { false }
	without_api := if args.len > offset + 2 { args[offset + 2].bool_data } else { false }
	receiver.freeze_named_args(named, cask_options, without_api)
	return args_nil_value()
}

// Ruby method `set_arg(name, value)` at line 54.
pub fn ruby_args_l54_d7_set_arg(args ...ruby.Value) ruby.Value {
	mut receiver, offset := args_receiver(args)
	if args.len > offset + 1 {
		receiver.set_arg(args[offset].as_string().trim_left(':'), arg_value_from_boundary(args[offset + 1]))
	}
	return args_nil_value()
}

// Ruby method `tap(&_blk)` at line 59.
pub fn ruby_args_l59_d8_tap(args ...ruby.Value) ruby.Value {
	receiver, _ := args_receiver(args)
	value := receiver.tap_value() or { return args_nil_value() }
	return arg_value_boundary(value)
}

// Ruby method `freeze_processed_options!(processed_options)` at line 66.
pub fn ruby_args_l66_d9_freeze_processed_options(args ...ruby.Value) ruby.Value {
	mut receiver, offset := args_receiver(args)
	if args.len > offset {
		receiver.freeze_processed_options(processed_options_from_boundary(args[offset]))
	}
	return args_nil_value()
}

// Ruby method `named` at line 78.
pub fn ruby_args_l78_d10_named(args ...ruby.Value) ruby.Value {
	receiver, _ := args_receiver(args)
	return named_args_boundary(receiver.named)
}

// Ruby method `no_named? = named.empty?` at line 84.
pub fn ruby_args_l84_d11_no_named(args ...ruby.Value) ruby.Value {
	receiver, _ := args_receiver(args)
	return ruby.bool_value(receiver.no_named())
}

// Ruby method `build_from_source_formulae` at line 87.
pub fn ruby_args_l87_d12_build_from_source_formulae(args ...ruby.Value) ruby.Value {
	receiver, _ := args_receiver(args)
	return ruby.string_array_value(receiver.build_from_source_formulae() or { [] })
}

// Ruby method `include_test_formulae` at line 96.
pub fn ruby_args_l96_d13_include_test_formulae(args ...ruby.Value) ruby.Value {
	receiver, _ := args_receiver(args)
	return ruby.string_array_value(receiver.include_test_formulae() or { [] })
}

// Ruby method `value(name)` at line 105.
pub fn ruby_args_l105_d14_value(args ...ruby.Value) ruby.Value {
	receiver, offset := args_receiver(args)
	if args.len <= offset {
		return args_nil_value()
	}
	value := receiver.value(args[offset].as_string()) or { return args_nil_value() }
	return ruby.string_value(value)
}

// Ruby method `context` at line 114.
pub fn ruby_args_l114_d15_context(args ...ruby.Value) ruby.Value {
	receiver, _ := args_receiver(args)
	context := receiver.context()
	return ruby.structured_value('Homebrew::Context::ContextStruct', '', {
		'debug':   context.debug.str()
		'quiet':   context.quiet.str()
		'verbose': context.verbose.str()
	})
}

// Ruby method `only_formula_or_cask` at line 119.
pub fn ruby_args_l119_d16_only_formula_or_cask(args ...ruby.Value) ruby.Value {
	receiver, _ := args_receiver(args)
	value := receiver.only_formula_or_cask() or { return args_nil_value() }
	return ruby.object_value('Symbol', value)
}

// Ruby method `os_arch_combinations` at line 128.
pub fn ruby_args_l128_d17_os_arch_combinations(args ...ruby.Value) ruby.Value {
	receiver, _ := args_receiver(args)
	return ruby.array_value(receiver.os_arch_combinations().map(ruby.array_value([
		ruby.object_value('Symbol', it.os),
		ruby.object_value('Symbol', it.arch),
	])))
}

// Ruby method `option_to_name(option)` at line 170.
pub fn ruby_args_l170_d18_option_to_name(args ...ruby.Value) ruby.Value {
	_, offset := args_receiver(args)
	if args.len <= offset {
		return ruby.string_value('')
	}
	return ruby.string_value(option_to_name(args[offset].as_string()))
}

// Ruby method `cli_args` at line 176.
pub fn ruby_args_l176_d19_cli_args(args ...ruby.Value) ruby.Value {
	mut receiver, _ := args_receiver(args)
	return ruby.string_array_value(receiver.cli_args())
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
