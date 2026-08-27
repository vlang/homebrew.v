module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/shell_commands.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_send(node)` at line 73.
pub fn ruby_shell_commands_l73_d1_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_send', ...args)
}

// Ruby method `on_send(node)` at line 127.
pub fn ruby_shell_commands_l127_d2_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_send', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "extend/array"
// 5: require "rubocops/shared/helper_functions"
// 6: require "shellwords"
// 7:
// 8: module RuboCop
// 9:   module Cop
// 10:     module Homebrew
// 11:       # https://github.com/ruby/ruby/blob/v2_6_3/process.c#L2430-L2460
// 12:       SHELL_BUILTINS = %w[
// 13:         !
// 14:         .
// 15:         :
// 16:         break
// 17:         case
// 18:         continue
// 19:         do
// 20:         done
// 21:         elif
// 22:         else
// 23:         esac
// 24:         eval
// 25:         exec
// 26:         exit
// 27:         export
// 28:         fi
// 29:         for
// 30:         if
// 31:         in
// 32:         readonly
// 33:         return
// 34:         set
// 35:         shift
// 36:         then
// 37:         times
// 38:         trap
// 39:         unset
// 40:         until
// 41:         while
// 42:       ].freeze
// 43:       private_constant :SHELL_BUILTINS
// 44:
// 45:       # https://github.com/ruby/ruby/blob/v2_6_3/process.c#L2495
// 46:       SHELL_METACHARACTERS = %W[* ? { } [ ] < > ( ) ~ & | \\ $ ; ' ` " \n #].freeze
// 47:       private_constant :SHELL_METACHARACTERS
// 48:
// 49:       # This cop makes sure that shell command arguments are separated.
// 50:       class ShellCommands < Base
// 51:         include HelperFunctions
// 52:         extend AutoCorrector
// 53:
// 54:         MSG = "Separate `%<method>s` commands into `%<good_args>s`"
// 55:
// 56:         TARGET_METHODS = [
// 57:           [nil, :system],
// 58:           [nil, :safe_system],
// 59:           [nil, :quiet_system],
// 60:           [:Utils, :popen_read],
// 61:           [:Utils, :safe_popen_read],
// 62:           [:Utils, :popen_write],
// 63:           [:Utils, :safe_popen_write],
// 64:         ].freeze
// 65:         private_constant :TARGET_METHODS
// 66:
// 67:         RESTRICT_ON_SEND = T.let(
// 68:           TARGET_METHODS.map(&:second).uniq.freeze,
// 69:           T::Array[T.nilable(Symbol)],
// 70:         )
// 71:
// 72:         sig { params(node: RuboCop::AST::SendNode).void }
// 73:         def on_send(node)
// 74:           TARGET_METHODS.each do |target_class, target_method|
// 75:             next if node.method_name != target_method
// 76:
// 77:             target_receivers = if target_class.nil?
// 78:               [nil, s(:const, nil, :Kernel), s(:const, nil, :Homebrew)]
// 79:             else
// 80:               [s(:const, nil, target_class)]
// 81:             end
// 82:             next unless target_receivers.include?(node.receiver)
// 83:
// 84:             first_arg = node.arguments.first
// 85:             arg_count = node.arguments.count
// 86:             if first_arg&.hash_type? # popen methods allow env hash
// 87:               first_arg = node.arguments.second
// 88:               arg_count -= 1
// 89:             end
// 90:             next if first_arg.nil? || arg_count >= 2
// 91:
// 92:             first_arg_str = string_content(first_arg)
// 93:             stripped_first_arg_str = string_content(first_arg, strip_dynamic: true)
// 94:
// 95:             split_args = first_arg_str.shellsplit
// 96:             next if split_args.count <= 1
// 97:
// 98:             # Only separate when no shell metacharacters are present
// 99:             command = split_args.first
// 100:             next if SHELL_BUILTINS.any?(command)
// 101:             next if command&.include?("=")
// 102:             next if SHELL_METACHARACTERS.any? { |meta| stripped_first_arg_str.include?(meta) }
// 103:
// 104:             good_args = split_args.map { |arg| "\"#{arg}\"" }.join(", ")
// 105:             method_string = if target_class
// 106:               "#{target_class}.#{target_method}"
// 107:             else
// 108:               target_method.to_s
// 109:             end
// 110:             add_offense(first_arg, message: format(MSG, method: method_string, good_args:)) do |corrector|
// 111:               corrector.replace(first_arg.source_range, good_args)
// 112:             end
// 113:           end
// 114:         end
// 115:       end
// 116:
// 117:       # This cop disallows shell metacharacters in `exec` calls.
// 118:       class ExecShellMetacharacters < Base
// 119:         include HelperFunctions
// 120:
// 121:         MSG = "Don't use shell metacharacters in `exec`. " \
// 122:               "Implement the logic in Ruby instead, using methods like `$stdout.reopen`."
// 123:
// 124:         RESTRICT_ON_SEND = [:exec].freeze
// 125:
// 126:         sig { params(node: RuboCop::AST::SendNode).void }
// 127:         def on_send(node)
// 128:           return if node.receiver.present? && node.receiver != s(:const, nil, :Kernel)
// 129:           return if node.arguments.count != 1
// 130:
// 131:           stripped_arg_str = string_content(node.arguments.first, strip_dynamic: true)
// 132:           command = string_content(node.arguments.first).shellsplit.first
// 133:
// 134:           return if SHELL_BUILTINS.none?(command) &&
// 135:                     !command&.include?("=") &&
// 136:                     SHELL_METACHARACTERS.none? { |meta| stripped_arg_str.include?(meta) }
// 137:
// 138:           add_offense(node.arguments.first, message: MSG)
// 139:         end
// 140:       end
// 141:     end
// 142:   end
// 143: end
