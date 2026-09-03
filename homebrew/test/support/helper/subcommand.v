module helper

import brew_runtime
import homebrew.cmd

// Translated from Homebrew/brew `test/support/helper/subcommand.rb`.
// The original source is retained below until every stub has a typed V body.
const subcommand_known_predicates = 'all?|cargo?|casks?|check?|cleanup?|no_cleanup_brew?|no_cleanup_cargo?|no_cleanup_cask?|no_cleanup_flatpak?|no_cleanup_go?|no_cleanup_krew?|no_cleanup_mas?|no_cleanup_npm?|no_cleanup_tap?|no_cleanup_uv?|no_cleanup_vscode?|no_cleanup_winget?|describe?|no_describe?|no_dump_brew?|no_dump_cargo?|no_dump_cask?|no_dump_flatpak?|no_dump_go?|no_dump_krew?|no_dump_mas?|no_dump_npm?|no_dump_tap?|no_dump_uv?|no_dump_vscode?|no_dump_winget?|flatpak?|force?|formulae?|global?|go?|install?|krew?|mas?|no_cargo?|no_casks?|no_flatpak?|no_formulae?|no_go?|no_krew?|no_mas?|no_npm?|no_restart?|no_secrets?|no_taps?|no_upgrade?|no_uv?|no_vscode?|no_winget?|npm?|quiet?|services?|taps?|upgrade?|uv?|verbose?|vscode?|winget?|zap?'

@[heap]
pub struct SubcommandArgs {
pub:
	named      []string
	subcommand ?string
	options    map[string]brew_runtime.Value
}

pub fn new_subcommand_args(subcommand ?string, named []string,
	options map[string]brew_runtime.Value) &SubcommandArgs {
	return &SubcommandArgs{
		named: named.clone()
		subcommand: subcommand
		options: options.clone()
	}
}

pub fn (args &SubcommandArgs) invoke(name string, arguments []brew_runtime.Value) !brew_runtime.Value {
	method_name := name.trim_string_left(':')
	if arguments.len == 0 {
		if method_name in args.options {
			return args.options[method_name]
		}
		if method_name in subcommand_known_predicates.split('|') {
			return brew_runtime.bool_value(false)
		}
	}
	return error("undefined method '${method_name}' for Test::Helper::Subcommand::Args")
}

pub fn (args &SubcommandArgs) responds_to(name string) bool {
	method_name := name.trim_string_left(':')
	return method_name in args.options || method_name in subcommand_known_predicates.split('|')
}

pub fn args_for_subcommand(subcommand ?string, named []string,
	options map[string]brew_runtime.Value) &SubcommandArgs {
	return new_subcommand_args(subcommand, named, options)
}

pub fn bundle_subcommand_context(subcommand string, global bool, file ?string, no_upgrade bool,
	verbose bool, force bool, ask bool, jobs int, zap bool, no_type_args bool) cmd.BundleSubcommandContext {
	return cmd.BundleSubcommandContext{
		subcommand: subcommand
		global: global
		file: file
		no_upgrade: no_upgrade
		verbose: verbose
		force: force
		ask: ask
		jobs: jobs
		zap: zap
		no_type_args: no_type_args
	}
}

fn subcommand_args_value(args &SubcommandArgs) brew_runtime.Value {
	return brew_runtime.structured_value('Test::Helper::Subcommand::Args', '', {
		'subcommand_args_address': u64(voidptr(args)).str()
	})
}

fn subcommand_args_from_value(value brew_runtime.Value) &SubcommandArgs {
	address := value.attributes['subcommand_args_address'] or { panic('invalid Subcommand::Args') }
	return unsafe { &SubcommandArgs(voidptr(address.u64())) }
}

pub fn subcommand_args_boundary(args &SubcommandArgs) brew_runtime.Value {
	return subcommand_args_value(args)
}

fn bundle_subcommand_context_value(context cmd.BundleSubcommandContext) brew_runtime.Value {
	return brew_runtime.map_value({
		'subcommand':   brew_runtime.string_value(context.subcommand)
		'global':       brew_runtime.bool_value(context.global)
		'file':         if file := context.file {
			brew_runtime.string_value(file)
		} else {
			brew_runtime.object_value('NilClass', 'nil')
		}
		'no_upgrade':   brew_runtime.bool_value(context.no_upgrade)
		'verbose':      brew_runtime.bool_value(context.verbose)
		'force':        brew_runtime.bool_value(context.force)
		'ask':          brew_runtime.bool_value(context.ask)
		'jobs':         brew_runtime.int_value(context.jobs)
		'zap':          brew_runtime.bool_value(context.zap)
		'no_type_args': brew_runtime.bool_value(context.no_type_args)
	})
}

// Ruby attr_reader `attr_reader :named` at line 12.
pub fn ruby_subcommand_l12_d1_named(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(subcommand_args_from_value(args[0]).named)
}

// Ruby method `initialize(named:, **options)` at line 81.
pub fn ruby_subcommand_l81_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return subcommand_args_value(new_subcommand_args(none, [], {}))
	}
	named := args[0].as_string_array() or { [] }
	options := if args.len > 1 {
		args[1].as_map() or { map[string]brew_runtime.Value{} }
	} else {
		map[string]brew_runtime.Value{}
	}
	subcommand := if value := options['subcommand'] {
		if value.type_name == 'NilClass' { ?string(none) } else { value.as_string() }
	} else {
		?string(none)
	}
	return subcommand_args_value(new_subcommand_args(subcommand, named, options))
}

// Ruby method `method_missing(name, *args)` at line 86.
pub fn ruby_subcommand_l86_d3_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'method name is required')
	}
	result := subcommand_args_from_value(args[0]).invoke(args[1].as_string(), args[2..]) or {
		return brew_runtime.object_value('NoMethodError', err.msg())
	}
	return result
}

// Ruby method `respond_to_missing?(name, include_private = false)` at line 96.
pub fn ruby_subcommand_l96_d4_respond_to_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.bool_value(args.len > 1 && subcommand_args_from_value(args[0]).responds_to(args[1].as_string()))
}

// Ruby method `args_for_subcommand(subcommand = nil, *named, **options)` at line 108.
pub fn ruby_subcommand_l108_d5_args_for_subcommand(args ...brew_runtime.Value) brew_runtime.Value {
	subcommand := if args.len > 0 && args[0].type_name != 'NilClass' {
		?string(args[0].as_string().trim_string_left(':'))
	} else {
		none
	}
	named := if args.len > 1 { args[1].as_string_array() or { [] } } else { [] }
	options := if args.len > 2 {
		args[2].as_map() or { map[string]brew_runtime.Value{} }
	} else {
		map[string]brew_runtime.Value{}
	}
	return subcommand_args_value(args_for_subcommand(subcommand, named, options))
}

// Ruby method `bundle_subcommand_context(subcommand, global: false, file: nil, no_upgrade: false, verbose: false,` at line 127.
pub fn ruby_subcommand_l127_d6_bundle_subcommand_context(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'subcommand is required')
	}
	options := if args.len > 1 {
		args[1].as_map() or { map[string]brew_runtime.Value{} }
	} else {
		map[string]brew_runtime.Value{}
	}
	file_value := options['file'] or { brew_runtime.object_value('NilClass', 'nil') }
	context := bundle_subcommand_context(args[0].as_string().trim_string_left(':'), (options['global'] or { brew_runtime.bool_value(false) }).bool_data, if file_value.type_name == 'NilClass' {
		?string(none)
	} else {
		file_value.as_string()
	}, (options['no_upgrade'] or { brew_runtime.bool_value(false) }).bool_data, (options['verbose'] or { brew_runtime.bool_value(false) }).bool_data, (options['force'] or { brew_runtime.bool_value(false) }).bool_data, (options['ask'] or { brew_runtime.bool_value(false) }).bool_data, int((options['jobs'] or { brew_runtime.int_value(1) }).as_int() or { 1 }), (options['zap'] or { brew_runtime.bool_value(false) }).bool_data, (options['no_type_args'] or { brew_runtime.bool_value(true) }).bool_data)
	return bundle_subcommand_context_value(context)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: module Test
// 5:   module Helper
// 6:     module Subcommand
// 7:       extend T::Helpers
// 8:
// 9:       requires_ancestor { Kernel }
// 10:
// 11:       class Args
// 12:         attr_reader :named
// 13:
// 14:         KNOWN_PREDICATES = [
// 15:           :all?,
// 16:           :cargo?,
// 17:           :casks?,
// 18:           :check?,
// 19:           :cleanup?,
// 20:           :no_cleanup_brew?,
// 21:           :no_cleanup_cargo?,
// 22:           :no_cleanup_cask?,
// 23:           :no_cleanup_flatpak?,
// 24:           :no_cleanup_go?,
// 25:           :no_cleanup_krew?,
// 26:           :no_cleanup_mas?,
// 27:           :no_cleanup_npm?,
// 28:           :no_cleanup_tap?,
// 29:           :no_cleanup_uv?,
// 30:           :no_cleanup_vscode?,
// 31:           :no_cleanup_winget?,
// 32:           :describe?,
// 33:           :no_describe?,
// 34:           :no_dump_brew?,
// 35:           :no_dump_cargo?,
// 36:           :no_dump_cask?,
// 37:           :no_dump_flatpak?,
// 38:           :no_dump_go?,
// 39:           :no_dump_krew?,
// 40:           :no_dump_mas?,
// 41:           :no_dump_npm?,
// 42:           :no_dump_tap?,
// 43:           :no_dump_uv?,
// 44:           :no_dump_vscode?,
// 45:           :no_dump_winget?,
// 46:           :flatpak?,
// 47:           :force?,
// 48:           :formulae?,
// 49:           :global?,
// 50:           :go?,
// 51:           :install?,
// 52:           :krew?,
// 53:           :mas?,
// 54:           :no_cargo?,
// 55:           :no_casks?,
// 56:           :no_flatpak?,
// 57:           :no_formulae?,
// 58:           :no_go?,
// 59:           :no_krew?,
// 60:           :no_mas?,
// 61:           :no_npm?,
// 62:           :no_restart?,
// 63:           :no_secrets?,
// 64:           :no_taps?,
// 65:           :no_upgrade?,
// 66:           :no_uv?,
// 67:           :no_vscode?,
// 68:           :no_winget?,
// 69:           :npm?,
// 70:           :quiet?,
// 71:           :services?,
// 72:           :taps?,
// 73:           :upgrade?,
// 74:           :uv?,
// 75:           :verbose?,
// 76:           :vscode?,
// 77:           :winget?,
// 78:           :zap?,
// 79:         ].freeze
// 80:
// 81:         def initialize(named:, **options)
// 82:           @named = named
// 83:           @options = options
// 84:         end
// 85:
// 86:         def method_missing(name, *args)
// 87:           if args.empty? && @options.key?(name)
// 88:             @options.fetch(name)
// 89:           elsif args.empty? && KNOWN_PREDICATES.include?(name)
// 90:             false
// 91:           else
// 92:             super
// 93:           end
// 94:         end
// 95:
// 96:         def respond_to_missing?(name, include_private = false)
// 97:           @options.key?(name) || KNOWN_PREDICATES.include?(name) || super
// 98:         end
// 99:       end
// 100:
// 101:       sig {
// 102:         params(
// 103:           subcommand: T.nilable(T.any(String, Symbol)),
// 104:           named:      T.untyped,
// 105:           options:    T.untyped,
// 106:         ).returns(Test::Helper::Subcommand::Args)
// 107:       }
// 108:       def args_for_subcommand(subcommand = nil, *named, **options)
// 109:         Test::Helper::Subcommand::Args.new(named:, subcommand: subcommand&.to_s, **options)
// 110:       end
// 111:
// 112:       require "cmd/bundle"
// 113:       sig {
// 114:         params(
// 115:           subcommand:   T.any(String, Symbol),
// 116:           global:       T::Boolean,
// 117:           file:         T.nilable(String),
// 118:           no_upgrade:   T::Boolean,
// 119:           verbose:      T::Boolean,
// 120:           force:        T::Boolean,
// 121:           ask:          T::Boolean,
// 122:           jobs:         Integer,
// 123:           zap:          T::Boolean,
// 124:           no_type_args: T::Boolean,
// 125:         ).returns(Homebrew::Cmd::Bundle::SubcommandContext)
// 126:       }
// 127:       def bundle_subcommand_context(subcommand, global: false, file: nil, no_upgrade: false, verbose: false,
// 128:                                     force: false, ask: false, jobs: 1, zap: false, no_type_args: true)
// 129:         Homebrew::Cmd::Bundle::SubcommandContext.new(
// 130:           subcommand:   subcommand.to_s,
// 131:           global:,
// 132:           file:,
// 133:           no_upgrade:,
// 134:           verbose:,
// 135:           force:,
// 136:           ask:,
// 137:           jobs:,
// 138:           zap:,
// 139:           no_type_args:,
// 140:           extensions:   Homebrew::Bundle.extensions,
// 141:         )
// 142:       end
// 143:     end
// 144:   end
// 145: end
