module homebrew

import ruby

// Translated from Homebrew/brew `linux_runner_spec.rb`.
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

pub fn linux_runner_spec_to_map(spec LinuxRunnerSpec) map[string]ruby.Value {
	mut result := {
		'name':             ruby.string_value(spec.name)
		'runner':           ruby.string_value(spec.runner)
		'timeout':          ruby.int_value(i64(spec.timeout))
		'cleanup':          ruby.bool_value(spec.cleanup)
		'testing_formulae': ruby.string_value(spec.testing_formulae.join(','))
	}
	if container := spec.container {
		result['container'] = ruby.structured_value('Container', container.image, {
			'image':   container.image
			'options': container.options
		})
	}
	if spec.workdir != '' {
		result['workdir'] = ruby.string_value(spec.workdir)
	}
	return result
}
