module artifact

import ruby
import os

// Translated from Homebrew/brew `cask/artifact/installer.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct InstallerArtifact {
pub:
	cask           ruby.Value
	path           string
	arguments      map[string]ruby.Value
	manual_install bool
}

fn installer_nil() ruby.Value {
	return ruby.Value{ type_name: 'NilClass', repr: 'nil' }
}

fn installer_script(arguments ruby.Value) !(string, map[string]ruby.Value) {
	mut values := if arguments.type_name == 'String' {
		{
			'executable': arguments
		}
	} else if arguments.type_name == 'Hash' {
		arguments.map_data.clone()
	} else {
		return error('Unsupported arguments type ${arguments.type_name}')
	}
	for key, _ in values {
		if key !in ['args', 'input', 'executable', 'must_succeed', 'sudo', 'print_stdout',
			'print_stderr'] {
			values.delete(key)
		}
	}
	executable := values['executable'] or { installer_nil() }
	values.delete('executable')
	mut defaults := {
		'must_succeed': ruby.bool_value(true)
		'sudo':         ruby.bool_value(false)
	}
	for key, value in values {
		defaults[key] = value
	}
	defaults['print_stdout'] = ruby.bool_value(true)
	return executable.as_string(), defaults
}

pub fn new_installer_artifact(cask ruby.Value, supplied map[string]ruby.Value) !InstallerArtifact {
	if supplied.len == 0 {
		return error("'installer' stanza requires an argument.")
	}
	mut values := supplied.clone()
	if script := values['script'] {
		if script.type_name != 'Hash' {
			if 'executable' in values {
				return error("'installer' stanza gave arguments for both :script and :executable.")
			}
			mut script_values := values.clone()
			script_values['executable'] = script
			script_values.delete('script')
			values = {
				'script': ruby.map_value(script_values)
			}
		}
	}
	if values.len != 1 {
		return error("invalid 'installer' stanza: Only one of [:manual, :script] is permitted.")
	}
	for key, _ in values {
		if key !in ['manual', 'script'] {
			return error("unknown keyword: '${key}'")
		}
	}
	if manual := values['manual'] {
		return InstallerArtifact{ cask: cask, path: manual.as_string(), manual_install: true }
	}
	path, arguments := installer_script(values['script'] or { installer_nil() })!
	if path == '' {
		return error('installer missing executable')
	}
	return InstallerArtifact{ cask: cask, path: path, arguments: arguments }
}

pub fn installer_artifact_value(installer InstallerArtifact) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::Artifact::Installer'
		repr: installer.path
		map_data: {
			'cask':           installer.cask
			'path':           ruby.object_value('Pathname', installer.path)
			'args':           ruby.map_value(installer.arguments)
			'manual_install': ruby.bool_value(installer.manual_install)
		}
		attributes: {
			'dsl_key': 'installer'
		}
	}
}

pub fn installer_artifact_from_value(value ruby.Value) !InstallerArtifact {
	if value.type_name != 'Cask::Artifact::Installer' {
		return error('expected Cask::Artifact::Installer, got ${value.type_name}')
	}
	return InstallerArtifact{
		cask: value.map_data['cask'] or { ruby.object_value('Cask', '') }
		path: (value.map_data['path'] or { ruby.string_value(value.repr) }).as_string()
		arguments: (value.map_data['args'] or { ruby.map_value({}) }).map_data.clone()
		manual_install: (value.map_data['manual_install'] or { ruby.bool_value(false) }).as_bool() or { false }
	}
}

pub fn (installer InstallerArtifact) install_request(homebrew_prefix string, environment_path string) ruby.Value {
	staged := (installer.cask.map_data['staged_path'] or { ruby.string_value('') }).as_string()
	if installer.manual_install {
		return ruby.Value{ type_name: 'ManualInstallerNotice', repr: 'Cask ${installer.cask.as_string()} only provides a manual installer. To run it and complete the installation:\n  open ${os.join_path(staged, installer.path)}\n' }
	}
	executable := if os.is_abs_path(installer.path) {
		installer.path
	} else {
		os.join_path(staged, installer.path)
	}
	mut options := installer.arguments.clone()
	options['env'] = ruby.map_value({
		'PATH': ruby.string_value('${homebrew_prefix}/bin:${homebrew_prefix}/sbin:${environment_path}')
	})
	sudo := (installer.arguments['sudo'] or { ruby.bool_value(false) }).as_bool() or { false }
	options['reset_uid'] = ruby.bool_value(!sudo)
	return ruby.Value{
		type_name: 'SystemCommand::Request'
		repr: executable
		map_data: {
			'executable': ruby.string_value(executable)
			'options':    ruby.map_value(options)
		}
	}
}

// Ruby method `install_phase(command: SystemCommand, **_options)` at line 17.
pub fn ruby_installer_l17_d1_install_phase(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'install_phase requires a receiver')
	}
	installer := installer_artifact_from_value(args[0]) or { return ruby.object_value('TypeError', err.msg()) }
	options := if args.len > 1 && args[1].type_name == 'Hash' {
		args[1].map_data
	} else {
		map[string]ruby.Value{}
	}
	return installer.install_request((options['homebrew_prefix'] or { ruby.string_value('/opt/homebrew') }).as_string(), (options['path'] or { ruby.string_value('') }).as_string())
}

// Ruby method `self.from_args(cask, **args)` at line 40.
pub fn ruby_installer_l40_d2_self_from_args(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('CaskInvalidError', "'installer' stanza requires an argument.")
	}
	values := if args[1].type_name == 'Hash' {
		args[1].map_data
	} else {
		map[string]ruby.Value{}
	}
	installer := new_installer_artifact(args[0], values) or { return ruby.object_value('CaskInvalidError', err.msg()) }
	return installer_artifact_value(installer)
}

// Ruby attr_reader `attr_reader :path` at line 65.
pub fn ruby_installer_l65_d3_path(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'path requires a receiver')
	}
	installer := installer_artifact_from_value(args[0]) or { return ruby.object_value('TypeError', err.msg()) }
	return ruby.object_value('Pathname', installer.path)
}

// Ruby attr_reader `attr_reader :args` at line 68.
pub fn ruby_installer_l68_d4_args(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'args requires a receiver')
	}
	installer := installer_artifact_from_value(args[0]) or { return ruby.object_value('TypeError', err.msg()) }
	return ruby.map_value(installer.arguments)
}

// Ruby attr_reader `attr_reader :manual_install` at line 71.
pub fn ruby_installer_l71_d5_manual_install(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'manual_install requires a receiver')
	}
	installer := installer_artifact_from_value(args[0]) or { return ruby.object_value('TypeError', err.msg()) }
	return ruby.bool_value(installer.manual_install)
}

// Ruby method `initialize(cask, **args)` at line 74.
pub fn ruby_installer_l74_d6_initialize(args ...ruby.Value) ruby.Value {
	return ruby_installer_l40_d2_self_from_args(...args)
}

// Ruby method `summarize = path.to_s` at line 94.
pub fn ruby_installer_l94_d7_summarize(args ...ruby.Value) ruby.Value {
	return ruby_installer_l65_d3_path(...args)
}

// Ruby method `to_h` at line 97.
pub fn ruby_installer_l97_d8_to_h(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'to_h requires a receiver')
	}
	installer := installer_artifact_from_value(args[0]) or { return ruby.object_value('TypeError', err.msg()) }
	mut values := {
		'path': ruby.object_value('Pathname', installer.path)
	}
	if !installer.manual_install {
		values['args'] = ruby.map_value(installer.arguments)
	}
	return ruby.map_value(values)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/abstract_artifact"
// 5: require "extend/hash/keys"
// 6:
// 7: module Cask
// 8:   module Artifact
// 9:     # Artifact corresponding to the `installer` stanza.
// 10:     class Installer < AbstractArtifact
// 11:       VALID_KEYS = T.let(Set.new([
// 12:         :manual,
// 13:         :script,
// 14:       ]).freeze, T::Set[Symbol])
// 15:
// 16:       sig { params(command: T.class_of(SystemCommand), _options: T.anything).void }
// 17:       def install_phase(command: SystemCommand, **_options)
// 18:         if manual_install
// 19:           puts <<~EOS
// 20:             Cask #{cask} only provides a manual installer. To run it and complete the installation:
// 21:               open #{cask.staged_path.join(path).to_s.shellescape}
// 22:           EOS
// 23:         else
// 24:           ohai "Running #{self.class.dsl_key} script '#{path}'"
// 25:
// 26:           executable_path = staged_path_join_executable(path)
// 27:
// 28:           command.run!(
// 29:             executable_path,
// 30:             **args,
// 31:             env:       { "PATH" => PATH.new(
// 32:               HOMEBREW_PREFIX/"bin", HOMEBREW_PREFIX/"sbin", ENV.fetch("PATH")
// 33:             ) },
// 34:             reset_uid: !args[:sudo],
// 35:           )
// 36:         end
// 37:       end
// 38:
// 39:       sig { params(cask: Cask, args: T.untyped).returns(T.attached_class) }
// 40:       def self.from_args(cask, **args)
// 41:         raise CaskInvalidError.new(cask, "'installer' stanza requires an argument.") if args.empty?
// 42:
// 43:         if args.key?(:script) && !args[:script].respond_to?(:key?)
// 44:           if args.key?(:executable)
// 45:             raise CaskInvalidError.new(cask, "'installer' stanza gave arguments for both :script and :executable.")
// 46:           end
// 47:
// 48:           args[:executable] = args[:script]
// 49:           args.delete(:script)
// 50:           args = { script: args }
// 51:         end
// 52:
// 53:         if args.keys.count != 1
// 54:           raise CaskInvalidError.new(
// 55:             cask,
// 56:             "invalid 'installer' stanza: Only one of #{VALID_KEYS.inspect} is permitted.",
// 57:           )
// 58:         end
// 59:
// 60:         args.assert_valid_keys(*VALID_KEYS)
// 61:         new(cask, **args)
// 62:       end
// 63:
// 64:       sig { returns(Pathname) }
// 65:       attr_reader :path
// 66:
// 67:       sig { returns(T::Hash[Symbol, T.untyped]) }
// 68:       attr_reader :args
// 69:
// 70:       sig { returns(T::Boolean) }
// 71:       attr_reader :manual_install
// 72:
// 73:       sig { params(cask: Cask, args: T.untyped).void }
// 74:       def initialize(cask, **args)
// 75:         super
// 76:
// 77:         if args.key?(:manual)
// 78:           @path = T.let(Pathname(args[:manual]), Pathname)
// 79:           @args = T.let({}, T::Hash[Symbol, T.untyped])
// 80:           @manual_install = T.let(true, T::Boolean)
// 81:         else
// 82:           script_path, script_args = self.class.read_script_arguments(
// 83:             args[:script], self.class.dsl_key.to_s, { must_succeed: true, sudo: false }, print_stdout: true
// 84:           )
// 85:           raise CaskInvalidError.new(cask, "#{self.class.dsl_key} missing executable") if script_path.nil?
// 86:
// 87:           @path = T.let(Pathname(script_path), Pathname)
// 88:           @args = T.let(script_args, T::Hash[Symbol, T.untyped])
// 89:           @manual_install = T.let(false, T::Boolean)
// 90:         end
// 91:       end
// 92:
// 93:       sig { override.returns(String) }
// 94:       def summarize = path.to_s
// 95:
// 96:       sig { returns(T::Hash[Symbol, T.untyped]) }
// 97:       def to_h
// 98:         { path: }.tap do |h|
// 99:           h[:args] = args unless manual_install
// 100:         end
// 101:       end
// 102:     end
// 103:   end
// 104: end
