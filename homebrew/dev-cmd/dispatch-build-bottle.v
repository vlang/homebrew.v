module dev_cmd

import ruby

// Translated from Homebrew/brew `dev-cmd/dispatch-build-bottle.rb`.

pub struct DispatchBuildBottleOptions {
pub:
	tap_full_name       string = 'homebrew/core'
	timeout             string
	issue               string
	macos               []string
	workflow            string = 'dispatch-build-bottle.yml'
	upload              bool
	linux               bool
	linux_arm64         bool
	linux_self_hosted   bool
	linux_ci_arm_runner string = 'ubuntu-24.04-arm'
	formulae            []string
}

pub struct DispatchBuildBottleInputs {
pub:
	runner      string
	formula     string
	timeout     string
	has_timeout bool
	issue       string
	has_issue   bool
	upload      bool
}

pub struct DispatchBuildBottleWorkflow {
pub:
	user     string
	repo     string
	workflow string
	ref      string
	inputs   DispatchBuildBottleInputs
}

pub struct DispatchBuildBottleResult {
pub:
	tap        string
	runners    []string
	messages   []string
	dispatches []DispatchBuildBottleWorkflow
}

@[heap]
pub struct DispatchBuildBottleInput {
pub:
	options DispatchBuildBottleOptions
}

const dispatch_build_bottle_macos_versions = {
	'golden_gate': '27'
	'tahoe':       '26'
	'sequoia':     '15'
	'sonoma':      '14'
	'ventura':     '13'
	'monterey':    '12'
	'big_sur':     '11'
	'catalina':    '10.15'
}

const dispatch_build_bottle_architectures = ['x86_64', 'i386', 'ppc64le', 'ppc64', 'ppc970', 'ppc7450',
	'ppc7400', 'ppc32', 'ppc', 'arm64', 'aarch64']

fn dispatch_build_bottle_valid_tag_symbol(value string) bool {
	if value == '' {
		return false
	}
	for character in value {
		if !(character.is_alnum() || character in [`_`, `.`]) {
			return false
		}
	}
	return true
}

fn dispatch_build_bottle_macos_version(value string) bool {
	parts := value.split('.')
	if parts.len == 0 || parts.len > 3 || parts[0].len < 2 {
		return false
	}
	for part in parts {
		if part.len == 0 {
			return false
		}
		for byte in part.bytes() {
			if byte < `0` || byte > `9` {
				return false
			}
		}
	}
	return true
}

// normalize_dispatch_build_bottle_runner accepts the two source syntaxes:
// bottle tags such as `arm64_big_sur` and runner names such as `11-arm64`.
pub fn normalize_dispatch_build_bottle_runner(element string) !string {
	if dispatch_build_bottle_valid_tag_symbol(element) {
		mut system := element
		mut arch := 'x86_64'
		for candidate in dispatch_build_bottle_architectures {
			prefix := '${candidate}_'
			if element.starts_with(prefix) && element.len > prefix.len {
				arch = candidate
				system = element[prefix.len..]
				break
			}
		}
		if os := dispatch_build_bottle_macos_versions[system] {
			return if arch != 'x86_64' { '${os}-${arch}' } else { os }
		}
	}

	separator := element.index('-') or { -1 }
	os := if separator >= 0 { element[..separator] } else { element }
	arch := if separator >= 0 { element[separator + 1..] } else { '' }
	if !dispatch_build_bottle_macos_version(os) {
		return error('unknown or unsupported macOS version: "${os}"')
	}
	return if arch != '' && arch != 'x86_64' { '${os}-${arch}' } else { os }
}

fn dispatch_build_bottle_tap_parts(full_name string) !(string, string) {
	parts := full_name.split('/')
	mut retained := parts.len
	// Ruby String#split drops trailing empty fields.
	for retained > 0 && parts[retained - 1] == '' {
		retained--
	}
	if retained < 2 {
		return error('Unexpected tap name: ${full_name}')
	}
	return parts[0], parts[1]
}

pub fn run_dispatch_build_bottle(options DispatchBuildBottleOptions) !DispatchBuildBottleResult {
	if options.formulae.len == 0 {
		return error('at least 1 named argument is required')
	}
	if options.linux && options.linux_self_hosted {
		return error('`--linux` and `--linux-self-hosted` are mutually exclusive')
	}

	user, repo := dispatch_build_bottle_tap_parts(options.tap_full_name)!
	mut runners := []string{}
	for element in options.macos {
		// ActiveSupport's compact_blank removes nil and whitespace-only entries.
		if element.trim_space() == '' {
			continue
		}
		runners << normalize_dispatch_build_bottle_runner(element)!
	}
	if options.linux {
		runners << 'ubuntu-latest'
	} else if options.linux_self_hosted {
		runners << 'linux-self-hosted-1'
	}
	if options.linux_arm64 {
		runners << options.linux_ci_arm_runner
	}
	if runners.len == 0 {
		return error('Must specify `--macos`, `--linux`, `--linux-arm64`, or `--linux-self-hosted` option.')
	}

	workflow := if options.workflow == '' { 'dispatch-build-bottle.yml' } else { options.workflow }
	mut messages := []string{cap: options.formulae.len}
	mut dispatches := []DispatchBuildBottleWorkflow{cap: options.formulae.len}
	for formula in options.formulae {
		messages << 'Dispatching ${options.tap_full_name} bottling request of formula "${formula}" for ${runners.join(', ')}'
		dispatches << DispatchBuildBottleWorkflow{
			user: user
			repo: repo
			workflow: workflow
			ref: 'main'
			inputs: DispatchBuildBottleInputs{
				runner: runners.join(',')
				formula: formula
				timeout: options.timeout
				has_timeout: options.timeout != ''
				issue: options.issue
				has_issue: options.issue != ''
				upload: options.upload
			}
		}
	}
	return DispatchBuildBottleResult{
		tap: options.tap_full_name
		runners: runners
		messages: messages
		dispatches: dispatches
	}
}

pub fn dispatch_build_bottle_input_boundary(input &DispatchBuildBottleInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::DispatchBuildBottle::Input', '', {
		'dispatch_build_bottle_input_address': u64(voidptr(input)).str()
	})
}

fn dispatch_build_bottle_input_from_value(value ruby.Value) &DispatchBuildBottleInput {
	address := value.attributes['dispatch_build_bottle_input_address'] or {
		panic('invalid DispatchBuildBottle input')
	}
	return unsafe { &DispatchBuildBottleInput(voidptr(address.u64())) }
}

fn dispatch_build_bottle_inputs_value(inputs DispatchBuildBottleInputs) ruby.Value {
	mut values := {
		'runner':  ruby.string_value(inputs.runner)
		'formula': ruby.string_value(inputs.formula)
		'upload':  ruby.bool_value(inputs.upload)
	}
	if inputs.has_timeout {
		values['timeout'] = ruby.string_value(inputs.timeout)
	}
	if inputs.has_issue {
		values['issue'] = ruby.string_value(inputs.issue)
	}
	return ruby.map_value(values)
}

fn dispatch_build_bottle_workflow_value(dispatch DispatchBuildBottleWorkflow) ruby.Value {
	return ruby.map_value({
		'user':     ruby.string_value(dispatch.user)
		'repo':     ruby.string_value(dispatch.repo)
		'workflow': ruby.string_value(dispatch.workflow)
		'ref':      ruby.string_value(dispatch.ref)
		'inputs':   dispatch_build_bottle_inputs_value(dispatch.inputs)
	})
}

fn dispatch_build_bottle_result_value(result DispatchBuildBottleResult) ruby.Value {
	return ruby.map_value({
		'tap':        ruby.string_value(result.tap)
		'runners':    ruby.string_array_value(result.runners)
		'messages':   ruby.string_array_value(result.messages)
		'dispatches': ruby.array_value(result.dispatches.map(dispatch_build_bottle_workflow_value(it)))
	})
}
