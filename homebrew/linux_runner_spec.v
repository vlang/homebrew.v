module homebrew

import brew_runtime

// Translated from Homebrew/brew `linux_runner_spec.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct LinuxRunnerContainer {
pub:
	image   string
	options string
}

pub struct LinuxRunnerSpec {
pub:
	name             string
	runner           string
	container        ?LinuxRunnerContainer
	workdir          string
	timeout          int
	cleanup          bool
	testing_formulae []string
}

pub fn linux_runner_spec_to_map(spec LinuxRunnerSpec) map[string]brew_runtime.Value {
	mut result := {
		'name':             brew_runtime.string_value(spec.name)
		'runner':           brew_runtime.string_value(spec.runner)
		'timeout':          brew_runtime.int_value(i64(spec.timeout))
		'cleanup':          brew_runtime.bool_value(spec.cleanup)
		'testing_formulae': brew_runtime.string_value(spec.testing_formulae.join(','))
	}
	if container := spec.container {
		result['container'] = brew_runtime.structured_value('Container', container.image, {
			'image':   container.image
			'options': container.options
		})
	}
	if spec.workdir != '' {
		result['workdir'] = brew_runtime.string_value(spec.workdir)
	}
	return result
}

// Ruby method `to_h` at line 14.
pub fn ruby_linux_runner_spec_l14_d1_to_h(spec LinuxRunnerSpec) map[string]brew_runtime.Value {
	return linux_runner_spec_to_map(spec)
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
