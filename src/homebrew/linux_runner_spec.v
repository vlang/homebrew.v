module homebrew

import brew_runtime

// Translated from Homebrew/brew `linux_runner_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `to_h` at line 14.
pub fn ruby_linux_runner_spec_l14_d1_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_h', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class LinuxRunnerSpec < T::Struct
// 5:   const :name, String
// 6:   const :runner, String
// 7:   const :container, T.nilable({ image: String, options: String })
// 8:   const :workdir, T.nilable(String)
// 9:   const :timeout, Integer
// 10:   const :cleanup, T::Boolean
// 11:   prop  :testing_formulae, T::Array[String], default: []
// 12:
// 13:   sig { returns(T::Hash[Symbol, T.untyped]) }
// 14:   def to_h
// 15:     {
// 16:       name:,
// 17:       runner:,
// 18:       container:,
// 19:       workdir:,
// 20:       timeout:,
// 21:       cleanup:,
// 22:       testing_formulae: testing_formulae.join(","),
// 23:     }.compact
// 24:   end
// 25: end
