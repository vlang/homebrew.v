module bundle

import brew_runtime

// Translated from Homebrew/brew `bundle/subcommand_context.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `extension_selected?(args, extension)` at line 24.
pub fn ruby_subcommand_context_l24_d1_extension_selected(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extension_selected?', ...args)
}

// Ruby method `extension_dump_disabled?(args, extension)` at line 29.
pub fn ruby_subcommand_context_l29_d2_extension_dump_disabled(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extension_dump_disabled?', ...args)
}

// Ruby method `extension_disabled?(args, extension)` at line 35.
pub fn ruby_subcommand_context_l35_d3_extension_disabled(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extension_disabled?', ...args)
}

// Ruby method `core_type_options(args, prefix, all: false)` at line 44.
pub fn ruby_subcommand_context_l44_d4_core_type_options(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('core_type_options', ...args)
}

// Ruby method `selected_types(args)` at line 53.
pub fn ruby_subcommand_context_l53_d5_selected_types(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('selected_types', ...args)
}

// Ruby method `type_selected?(args, predicate_method, disabled_predicate_method, env_disabled_predicate_method,` at line 73.
pub fn ruby_subcommand_context_l73_d6_type_selected(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type_selected?', ...args)
}

// Ruby method `type_disabled?(args, *disabled_methods)` at line 80.
pub fn ruby_subcommand_context_l80_d7_type_disabled(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('type_disabled?', ...args)
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
