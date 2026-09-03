module homebrew

import brew_runtime

// Translated from Homebrew/brew `macos_runner_spec.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct MacOSRunnerSpec {
pub:
	name             string
	runner           string
	timeout          int
	cleanup          bool
	testing_formulae []string
}

pub fn macos_runner_spec_to_map(spec MacOSRunnerSpec) map[string]brew_runtime.Value {
	return {
		'name':             brew_runtime.string_value(spec.name)
		'runner':           brew_runtime.string_value(spec.runner)
		'timeout':          brew_runtime.int_value(i64(spec.timeout))
		'cleanup':          brew_runtime.bool_value(spec.cleanup)
		'testing_formulae': brew_runtime.string_value(spec.testing_formulae.join(','))
	}
}

// Ruby method `to_h` at line 20.
pub fn ruby_macos_runner_spec_l20_d1_to_h(spec MacOSRunnerSpec) map[string]brew_runtime.Value {
	return macos_runner_spec_to_map(spec)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: class MacOSRunnerSpec < T::Struct
// 5:   const :name, String
// 6:   const :runner, String
// 7:   const :timeout, Integer
// 8:   const :cleanup, T::Boolean
// 9:   prop  :testing_formulae, T::Array[String], default: []
// 10:
// 11:   sig {
// 12:     returns({
// 13:       name:             String,
// 14:       runner:           String,
// 15:       timeout:          Integer,
// 16:       cleanup:          T::Boolean,
// 17:       testing_formulae: String,
// 18:     })
// 19:   }
// 20:   def to_h
// 21:     {
// 22:       name:,
// 23:       runner:,
// 24:       timeout:,
// 25:       cleanup:,
// 26:       testing_formulae: testing_formulae.join(","),
// 27:     }
// 28:   end
// 29: end
