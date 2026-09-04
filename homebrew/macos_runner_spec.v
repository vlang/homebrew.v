module homebrew

import ruby

// Translated from Homebrew/brew `macos_runner_spec.rb`.
pub struct MacOSRunnerSpec {
pub:
	name             string
	runner           string
	timeout          int
	cleanup          bool
	testing_formulae []string
}

pub fn macos_runner_spec_to_map(spec MacOSRunnerSpec) map[string]ruby.Value {
	return {
		'name':             ruby.string_value(spec.name)
		'runner':           ruby.string_value(spec.runner)
		'timeout':          ruby.int_value(i64(spec.timeout))
		'cleanup':          ruby.bool_value(spec.cleanup)
		'testing_formulae': ruby.string_value(spec.testing_formulae.join(','))
	}
}
