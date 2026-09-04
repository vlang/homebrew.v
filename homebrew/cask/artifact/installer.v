module artifact

import ruby
import os

// Translated from Homebrew/brew `cask/artifact/installer.rb`.
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
