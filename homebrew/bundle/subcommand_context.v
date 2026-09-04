module bundle

import ruby

// Translated from Homebrew/brew `bundle/subcommand_context.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct SubcommandContextArgs {
pub:
	predicates map[string]bool
}

pub struct SubcommandContextExtension {
pub:
	type_name                     string
	predicate_method              string
	dump_disable_predicate_method string
	disable_predicate_method      string
}

pub struct SubcommandTypeContext {
pub:
	no_type_args bool
	extensions   []SubcommandContextExtension
}

fn subcommand_predicate(args SubcommandContextArgs, method string) bool {
	return args.predicates[method]
}

pub fn subcommand_extension_selected(args SubcommandContextArgs,
	extension SubcommandContextExtension) bool {
	return subcommand_predicate(args, extension.predicate_method)
}

pub fn subcommand_extension_dump_disabled(args SubcommandContextArgs,
	extension SubcommandContextExtension) bool {
	return subcommand_predicate(args, extension.dump_disable_predicate_method)
		|| subcommand_predicate(args, 'no_dump_${extension.type_name}?')
}

pub fn subcommand_extension_disabled(args SubcommandContextArgs,
	extension SubcommandContextExtension) bool {
	return subcommand_predicate(args, extension.disable_predicate_method)
		|| subcommand_predicate(args, 'no_cleanup_${extension.type_name}?')
}

pub fn subcommand_type_disabled(args SubcommandContextArgs, disabled_methods []string) bool {
	for method in disabled_methods {
		if subcommand_predicate(args, method) {
			return true
		}
	}
	return false
}

pub fn subcommand_type_selected(args SubcommandContextArgs, context SubcommandTypeContext,
	predicate_method string, disabled_predicate_method string, env_disabled_predicate_method string,
	all bool) bool {
	return !subcommand_type_disabled(args, [disabled_predicate_method, env_disabled_predicate_method])
		&& (subcommand_predicate(args, predicate_method) || all || context.no_type_args)
}

pub fn subcommand_core_type_options(args SubcommandContextArgs, context SubcommandTypeContext,
	prefix string, all bool) map[string]bool {
	return {
		'formulae': subcommand_type_selected(args, context, 'formulae?', 'no_formulae?', 'no_${prefix}_brew?', all)
		'casks':    subcommand_type_selected(args, context, 'casks?', 'no_casks?', 'no_${prefix}_cask?', all)
		'taps':     subcommand_type_selected(args, context, 'taps?', 'no_taps?', 'no_${prefix}_tap?', all)
	}
}

pub fn subcommand_selected_types(args SubcommandContextArgs,
	context SubcommandTypeContext) []string {
	mut selected := []string{}
	if subcommand_predicate(args, 'formulae?') {
		selected << 'brew'
	}
	if subcommand_predicate(args, 'casks?') {
		selected << 'cask'
	}
	if subcommand_predicate(args, 'taps?') {
		selected << 'tap'
	}
	for extension in context.extensions {
		if subcommand_extension_selected(args, extension) && extension.type_name !in selected {
			selected << extension.type_name
		}
	}
	if context.no_type_args {
		selected << 'none'
	}
	return selected
}

fn subcommand_context_args_from_value(value ruby.Value) SubcommandContextArgs {
	mut predicates := map[string]bool{}
	if value.type_name == 'Hash' {
		for method, selected in value.map_data {
			predicates[method] = selected.as_bool() or { false }
		}
	} else {
		for entry in value.attributes['predicates'].split(',') {
			if entry != '' {
				predicates[entry] = true
			}
		}
	}
	return SubcommandContextArgs{ predicates: predicates }
}

fn subcommand_extension_from_value(value ruby.Value) SubcommandContextExtension {
	type_name := value.attributes['type']
	return SubcommandContextExtension{
		type_name: type_name
		predicate_method: if value.attributes['predicate_method'] != '' {
			value.attributes['predicate_method']
		} else {
			'${type_name}?'
		}
		dump_disable_predicate_method: if value.attributes['dump_disable_predicate_method'] != '' {
			value.attributes['dump_disable_predicate_method']
		} else {
			'no_${type_name}?'
		}
		disable_predicate_method: if value.attributes['disable_predicate_method'] != '' {
			value.attributes['disable_predicate_method']
		} else {
			'no_${type_name}?'
		}
	}
}

fn subcommand_type_context_from_value(value ruby.Value) SubcommandTypeContext {
	mut extensions := []SubcommandContextExtension{}
	for extension_value in value.array_data {
		extensions << subcommand_extension_from_value(extension_value)
	}
	return SubcommandTypeContext{
		no_type_args: value.attributes['no_type_args'] == 'true'
		extensions: extensions
	}
}

fn subcommand_bool_map_value(values map[string]bool) ruby.Value {
	mut result := map[string]ruby.Value{}
	for name, value in values {
		result[name] = ruby.bool_value(value)
	}
	return ruby.map_value(result)
}

// Ruby method `extension_selected?(args, extension)` at line 24.
pub fn ruby_subcommand_context_l24_d1_extension_selected(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(subcommand_extension_selected(subcommand_context_args_from_value(args[0]), subcommand_extension_from_value(args[1])))
}

// Ruby method `extension_dump_disabled?(args, extension)` at line 29.
pub fn ruby_subcommand_context_l29_d2_extension_dump_disabled(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(subcommand_extension_dump_disabled(subcommand_context_args_from_value(args[0]), subcommand_extension_from_value(args[1])))
}

// Ruby method `extension_disabled?(args, extension)` at line 35.
pub fn ruby_subcommand_context_l35_d3_extension_disabled(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.bool_value(false)
	}
	return ruby.bool_value(subcommand_extension_disabled(subcommand_context_args_from_value(args[0]), subcommand_extension_from_value(args[1])))
}

// Ruby method `core_type_options(args, prefix, all: false)` at line 44.
pub fn ruby_subcommand_context_l44_d4_core_type_options(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return subcommand_bool_map_value(map[string]bool{})
	}
	context := if args.len > 3 {
		subcommand_type_context_from_value(args[3])
	} else {
		SubcommandTypeContext{}
	}
	return subcommand_bool_map_value(subcommand_core_type_options(subcommand_context_args_from_value(args[0]), context, args[1].as_string(), args.len > 2 && (args[2].as_bool() or { false })))
}

// Ruby method `selected_types(args)` at line 53.
pub fn ruby_subcommand_context_l53_d5_selected_types(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_array_value([])
	}
	context := if args.len > 1 {
		subcommand_type_context_from_value(args[1])
	} else {
		SubcommandTypeContext{}
	}
	return ruby.string_array_value(subcommand_selected_types(subcommand_context_args_from_value(args[0]), context))
}

// Ruby method `type_selected?(args, predicate_method, disabled_predicate_method, env_disabled_predicate_method,` at line 73.
pub fn ruby_subcommand_context_l73_d6_type_selected(args ...ruby.Value) ruby.Value {
	if args.len < 4 {
		return ruby.bool_value(false)
	}
	context := if args.len > 5 {
		subcommand_type_context_from_value(args[5])
	} else {
		SubcommandTypeContext{}
	}
	return ruby.bool_value(subcommand_type_selected(subcommand_context_args_from_value(args[0]), context, args[1].as_string(), args[2].as_string(), args[3].as_string(), args.len > 4 && (args[4].as_bool() or { false })))
}

// Ruby method `type_disabled?(args, *disabled_methods)` at line 80.
pub fn ruby_subcommand_context_l80_d7_type_disabled(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.bool_value(false)
	}
	mut methods := []string{}
	for value in args[1..] {
		if value.type_name == 'Array' {
			methods << value.as_string_array() or { [] }
		} else {
			methods << value.as_string()
		}
	}
	return ruby.bool_value(subcommand_type_disabled(subcommand_context_args_from_value(args[0]), methods))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "bundle/extensions/extension"
// 5: require "abstract_command"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class Bundle < Homebrew::AbstractCommand
// 10:       class SubcommandContext < T::Struct
// 11:         const :subcommand, String
// 12:         const :global, T::Boolean
// 13:         const :file, T.nilable(String)
// 14:         const :no_upgrade, T::Boolean
// 15:         const :verbose, T::Boolean
// 16:         const :force, T::Boolean
// 17:         const :ask, T::Boolean
// 18:         const :jobs, Integer
// 19:         const :zap, T::Boolean
// 20:         const :no_type_args, T::Boolean
// 21:         const :extensions, T::Array[T.class_of(Homebrew::Bundle::Extension)]
// 22:
// 23:         sig { params(args: T.untyped, extension: T.class_of(Homebrew::Bundle::Extension)).returns(T::Boolean) }
// 24:         def extension_selected?(args, extension)
// 25:           args.public_send(extension.predicate_method)
// 26:         end
// 27:
// 28:         sig { params(args: T.untyped, extension: T.class_of(Homebrew::Bundle::Extension)).returns(T::Boolean) }
// 29:         def extension_dump_disabled?(args, extension)
// 30:           args.public_send(extension.dump_disable_predicate_method) ||
// 31:             args.public_send(:"no_dump_#{extension.type}?")
// 32:         end
// 33:
// 34:         sig { params(args: T.untyped, extension: T.class_of(Homebrew::Bundle::Extension)).returns(T::Boolean) }
// 35:         def extension_disabled?(args, extension)
// 36:           args.public_send(extension.disable_predicate_method) ||
// 37:             args.public_send(:"no_cleanup_#{extension.type}?")
// 38:         end
// 39:
// 40:         sig {
// 41:           params(args: T.untyped, prefix: String, all: T::Boolean)
// 42:             .returns(T::Hash[Symbol, T::Boolean])
// 43:         }
// 44:         def core_type_options(args, prefix, all: false)
// 45:           {
// 46:             formulae: type_selected?(args, :formulae?, :no_formulae?, :"no_#{prefix}_brew?", all:),
// 47:             casks:    type_selected?(args, :casks?, :no_casks?, :"no_#{prefix}_cask?", all:),
// 48:             taps:     type_selected?(args, :taps?, :no_taps?, :"no_#{prefix}_tap?", all:),
// 49:           }
// 50:         end
// 51:
// 52:         sig { params(args: T.untyped).returns(T::Array[Symbol]) }
// 53:         def selected_types(args)
// 54:           # We intentionally omit the s from `brews`, `casks`, and `taps` for ease of handling later.
// 55:           type_hash = {
// 56:             brew: args.formulae?,
// 57:             cask: args.casks?,
// 58:             tap:  args.taps?,
// 59:           }
// 60:           extensions.each do |extension|
// 61:             type_hash[extension.type] = extension_selected?(args, extension)
// 62:           end
// 63:           type_hash[:none] = no_type_args
// 64:           type_hash.select { |_, v| v }.keys
// 65:         end
// 66:
// 67:         private
// 68:
// 69:         sig {
// 70:           params(args: T.untyped, predicate_method: Symbol, disabled_predicate_method: Symbol,
// 71:                  env_disabled_predicate_method: Symbol, all: T::Boolean).returns(T::Boolean)
// 72:         }
// 73:         def type_selected?(args, predicate_method, disabled_predicate_method, env_disabled_predicate_method,
// 74:                            all: false)
// 75:           !type_disabled?(args, disabled_predicate_method, env_disabled_predicate_method) &&
// 76:             (args.public_send(predicate_method) || all || no_type_args)
// 77:         end
// 78:
// 79:         sig { params(args: T.untyped, disabled_methods: Symbol).returns(T::Boolean) }
// 80:         def type_disabled?(args, *disabled_methods)
// 81:           disabled_methods.any? { |disabled_method| args.public_send(disabled_method) }
// 82:         end
// 83:       end
// 84:     end
// 85:   end
// 86: end
