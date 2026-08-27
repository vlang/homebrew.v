module homebrew

import brew_runtime

// Translated from Homebrew/brew `cask_artifact.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :name` at line 21.
pub fn ruby_cask_artifact_l21_d1_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby attr_reader `attr_reader :token` at line 24.
pub fn ruby_cask_artifact_l24_d2_token(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('token', ...args)
}

// Ruby attr_reader `attr_reader :version` at line 27.
pub fn ruby_cask_artifact_l27_d3_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby attr_reader `attr_reader :staged_path` at line 30.
pub fn ruby_cask_artifact_l30_d4_staged_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('staged_path', ...args)
}

// Ruby attr_reader `attr_reader :caskroom_path` at line 33.
pub fn ruby_cask_artifact_l33_d5_caskroom_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('caskroom_path', ...args)
}

// Ruby attr_reader `attr_reader :home` at line 36.
pub fn ruby_cask_artifact_l36_d6_home(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('home', ...args)
}

// Ruby attr_reader `attr_reader :config` at line 39.
pub fn ruby_cask_artifact_l39_d7_config(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('config', ...args)
}

// Ruby method `initialize(context)` at line 42.
pub fn ruby_cask_artifact_l42_d8_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `to_s = token` at line 53.
pub fn ruby_cask_artifact_l53_d9_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: raise "#{__FILE__} must not be loaded via `require`." if $PROGRAM_NAME != __FILE__
// 5:
// 6: old_trap = trap("INT") { exit! 130 }
// 7:
// 8: require_relative "global"
// 9:
// 10: require "json"
// 11: require "cask/config"
// 12: require "extend/ENV"
// 13: require "install_steps"
// 14: require "utils/fork"
// 15: require "utils/shell_completion"
// 16:
// 17: module Cask
// 18:   # Minimal cask state needed to resolve structured install-step paths and tokens.
// 19:   class InstallStepsContext
// 20:     sig { returns(T.any(String, T::Array[String])) }
// 21:     attr_reader :name
// 22:
// 23:     sig { returns(String) }
// 24:     attr_reader :token
// 25:
// 26:     sig { returns(String) }
// 27:     attr_reader :version
// 28:
// 29:     sig { returns(Pathname) }
// 30:     attr_reader :staged_path
// 31:
// 32:     sig { returns(Pathname) }
// 33:     attr_reader :caskroom_path
// 34:
// 35:     sig { returns(Pathname) }
// 36:     attr_reader :home
// 37:
// 38:     sig { returns(Config) }
// 39:     attr_reader :config
// 40:
// 41:     sig { params(context: T::Hash[String, T.untyped]).void }
// 42:     def initialize(context)
// 43:       @name = T.let(context.fetch("name"), T.any(String, T::Array[String]))
// 44:       @token = T.let(context.fetch("token"), String)
// 45:       @version = T.let(context.fetch("version"), String)
// 46:       @staged_path = T.let(Pathname(context.fetch("staged_path")), Pathname)
// 47:       @caskroom_path = T.let(Pathname(context.fetch("caskroom_path")), Pathname)
// 48:       @home = T.let(Pathname(context.fetch("home")), Pathname)
// 49:       @config = T.let(Config.from_json(context.fetch("config"), ignore_invalid_keys: true), Config)
// 50:     end
// 51:
// 52:     sig { returns(String) }
// 53:     def to_s = token
// 54:   end
// 55: end
// 56:
// 57: begin
// 58:   error_pipe = Utils.forked_child_error_pipe
// 59:
// 60:   trap("INT", old_trap)
// 61:
// 62:   # Match formula post-install isolation inside the sandboxed child. The
// 63:   # original cask context is supplied in JSON and never needs a `.rb` file.
// 64:   ENV["TMPDIR"] = HOMEBREW_TEMP.to_s
// 65:   ENV["TEMP"] = HOMEBREW_TEMP.to_s
// 66:   ENV["TMP"] = HOMEBREW_TEMP.to_s
// 67:   ENV.delete("HOMEBREW_PATH")
// 68:   ENV["PATH"] = PATH.new(ORIGINAL_PATHS).to_s
// 69:   ENV.clear_sensitive_environment!
// 70:   ENV.activate_extensions!
// 71:   Pathname.activate_extensions!
// 72:
// 73:   payload = T.cast(JSON.parse(Pathname(ARGV.fetch(0)).read), T::Hash[String, T.untyped])
// 74:   case payload.fetch("action")
// 75:   when "install_steps"
// 76:     context = Cask::InstallStepsContext.new(payload.fetch("context"))
// 77:     steps = payload.fetch("steps")
// 78:     phase = payload.fetch("phase").to_sym
// 79:     Homebrew::InstallSteps::Runner.new(context:).run(steps, phase:)
// 80:   when "generated_completions"
// 81:     errors = []
// 82:     payload.fetch("completions").each do |completion|
// 83:       commands = completion.fetch("commands")
// 84:       output_path = Pathname(completion.fetch("output_path"))
// 85:       output_path.dirname.mkpath
// 86:       output_path.write(
// 87:         Utils::ShellCompletion.generate_completion_output(
// 88:           commands, completion["shell_parameter"], completion.fetch("env")
// 89:         ),
// 90:       )
// 91:     rescue => e
// 92:       errors << "Failed to generate #{completion.fetch("shell")} completions from #{commands.fetch(0)}: #{e}"
// 93:     end
// 94:     raise errors.join("\n") unless errors.empty?
// 95:   else
// 96:     raise ArgumentError, "unknown sandboxed cask action: #{payload.fetch("action")}"
// 97:   end
// 98:
// 99: # Handle all possible exceptions.
// 100: rescue Exception => e # rubocop:disable Lint/RescueException
// 101:   Utils.report_forked_child_error(error_pipe, e)
// 102:   exit! 1
// 103: end
