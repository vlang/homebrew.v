module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/dispatch-build-bottle.rb`.
// The original source is retained below until every stub has a typed V body.

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

pub fn dispatch_build_bottle_input_boundary(input &DispatchBuildBottleInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::DispatchBuildBottle::Input', '', {
		'dispatch_build_bottle_input_address': u64(voidptr(input)).str()
	})
}

fn dispatch_build_bottle_input_from_value(value brew_runtime.Value) &DispatchBuildBottleInput {
	address := value.attributes['dispatch_build_bottle_input_address'] or {
		panic('invalid DispatchBuildBottle input')
	}
	return unsafe { &DispatchBuildBottleInput(voidptr(address.u64())) }
}

fn dispatch_build_bottle_inputs_value(inputs DispatchBuildBottleInputs) brew_runtime.Value {
	mut values := {
		'runner':  brew_runtime.string_value(inputs.runner)
		'formula': brew_runtime.string_value(inputs.formula)
		'upload':  brew_runtime.bool_value(inputs.upload)
	}
	if inputs.has_timeout {
		values['timeout'] = brew_runtime.string_value(inputs.timeout)
	}
	if inputs.has_issue {
		values['issue'] = brew_runtime.string_value(inputs.issue)
	}
	return brew_runtime.map_value(values)
}

fn dispatch_build_bottle_workflow_value(dispatch DispatchBuildBottleWorkflow) brew_runtime.Value {
	return brew_runtime.map_value({
		'user':     brew_runtime.string_value(dispatch.user)
		'repo':     brew_runtime.string_value(dispatch.repo)
		'workflow': brew_runtime.string_value(dispatch.workflow)
		'ref':      brew_runtime.string_value(dispatch.ref)
		'inputs':   dispatch_build_bottle_inputs_value(dispatch.inputs)
	})
}

fn dispatch_build_bottle_result_value(result DispatchBuildBottleResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'tap':        brew_runtime.string_value(result.tap)
		'runners':    brew_runtime.string_array_value(result.runners)
		'messages':   brew_runtime.string_array_value(result.messages)
		'dispatches': brew_runtime.array_value(result.dispatches.map(dispatch_build_bottle_workflow_value(it)))
	})
}

// Ruby method `run` at line 43.
pub fn ruby_dispatch_build_bottle_l43_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'command input is required')
	}
	options := dispatch_build_bottle_input_from_value(args[0]).options
	return dispatch_build_bottle_result_value(run_dispatch_build_bottle(options) or {
		error_type := if options.formulae.len == 0 {
			'Homebrew::CLI::MinNamedArgumentsError'
		} else if options.linux && options.linux_self_hosted {
			'UsageError'
		} else if err.msg().starts_with('Must specify') {
			'UsageError'
		} else if err.msg().starts_with('unknown or unsupported macOS version:') {
			'MacOSVersion::Error'
		} else {
			'Error'
		}
		return brew_runtime.object_value(error_type, err.msg())
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "tap"
// 6: require "utils/bottles"
// 7: require "utils/github"
// 8:
// 9: module Homebrew
// 10:   module DevCmd
// 11:     class DispatchBuildBottle < AbstractCommand
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Build bottles for these formulae with GitHub Actions.
// 15:         EOS
// 16:         flag   "--tap=",
// 17:                description: "Target tap repository (default: `homebrew/core`)."
// 18:         flag   "--timeout=",
// 19:                description: "Build timeout (in minutes, default: 60)."
// 20:         flag   "--issue=",
// 21:                description: "If specified, post a comment to this issue number if the job fails."
// 22:         comma_array "--macos",
// 23:                     description: "macOS version (or comma-separated list of versions) the bottle should be built for."
// 24:         flag   "--workflow=",
// 25:                description: "Dispatch specified workflow (default: `dispatch-build-bottle.yml`)."
// 26:         switch "--upload",
// 27:                description: "Upload built bottles."
// 28:         switch "--linux",
// 29:                description: "Dispatch bottle for Linux x86_64 (using GitHub runners)."
// 30:         switch "--linux-arm64",
// 31:                description: "Dispatch bottle for Linux arm64 (using GitHub runners)."
// 32:         switch "--linux-self-hosted",
// 33:                description: "Dispatch bottle for Linux x86_64 (using self-hosted runner)."
// 34:
// 35:         conflicts "--linux", "--linux-self-hosted"
// 36:
// 37:         named_args :formula, min: 1
// 38:
// 39:         hide_from_man_page!
// 40:       end
// 41:
// 42:       sig { override.void }
// 43:       def run
// 44:         tap = Tap.fetch(args.tap || CoreTap.instance.name)
// 45:         user, repo = tap.full_name.split("/")
// 46:         raise "Unexpected tap name: #{tap.full_name}" if user.nil? || repo.nil?
// 47:
// 48:         ref = "main"
// 49:         workflow = args.workflow || "dispatch-build-bottle.yml"
// 50:
// 51:         runners = []
// 52:
// 53:         if (macos = args.macos&.compact_blank) && macos.present?
// 54:           runners += macos.map do |element|
// 55:             # We accept runner name syntax (11-arm64) or bottle syntax (arm64_big_sur)
// 56:             os, arch = element.then do |s|
// 57:               tag = Utils::Bottles::Tag.from_symbol(s.to_sym)
// 58:               [tag.to_macos_version, tag.arch]
// 59:             rescue ArgumentError, MacOSVersion::Error
// 60:               os, arch = s.split("-", 2)
// 61:               [MacOSVersion.new(os), arch&.to_sym]
// 62:             end
// 63:
// 64:             if arch.present? && arch != :x86_64
// 65:               "#{os}-#{arch}"
// 66:             else
// 67:               os.to_s
// 68:             end
// 69:           end
// 70:         end
// 71:
// 72:         if args.linux?
// 73:           runners << "ubuntu-latest"
// 74:         elsif args.linux_self_hosted?
// 75:           runners << "linux-self-hosted-1"
// 76:         end
// 77:
// 78:         runners << OS::LINUX_CI_ARM_RUNNER if args.linux_arm64?
// 79:
// 80:         if runners.empty?
// 81:           raise UsageError, "Must specify `--macos`, `--linux`, `--linux-arm64`, or `--linux-self-hosted` option."
// 82:         end
// 83:
// 84:         args.named.to_resolved_formulae.each do |formula|
// 85:           # Required inputs
// 86:           inputs = {
// 87:             runner:  runners.join(","),
// 88:             formula: formula.name,
// 89:           }
// 90:
// 91:           # Optional inputs
// 92:           # These cannot be passed as nil to GitHub API
// 93:           inputs[:timeout] = args.timeout if args.timeout
// 94:           inputs[:issue] = args.issue if args.issue
// 95:           inputs[:upload] = args.upload?
// 96:
// 97:           ohai "Dispatching #{tap} bottling request of formula \"#{formula.name}\" for #{runners.join(", ")}"
// 98:           GitHub.workflow_dispatch_event(user, repo, workflow, ref, **inputs)
// 99:         end
// 100:       end
// 101:     end
// 102:   end
// 103: end
