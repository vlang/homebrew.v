module artifact

import ruby
import os

// Translated from Homebrew/brew `cask/artifact/pkg.rb`.
pub struct PkgArtifact {
pub:
	cask           ruby.Value
	path           string
	stanza_options map[string]ruby.Value
}

pub fn new_pkg_artifact(cask ruby.Value, path string, options map[string]ruby.Value) !PkgArtifact {
	for key, _ in options {
		if key !in ['allow_untrusted', 'choices'] {
			return error("unknown keyword: '${key}'")
		}
	}
	staged := (cask.map_data['staged_path'] or { ruby.string_value('') }).as_string()
	return PkgArtifact{ cask: cask, path: os.join_path(staged, path), stanza_options: options.clone() }
}

pub fn pkg_artifact_value(pkg PkgArtifact) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::Artifact::Pkg'
		repr: pkg.path
		map_data: {
			'cask':           pkg.cask
			'path':           ruby.object_value('Pathname', pkg.path)
			'stanza_options': ruby.map_value(pkg.stanza_options)
		}
		attributes: {
			'dsl_key': 'pkg'
		}
	}
}

pub fn pkg_artifact_from_value(value ruby.Value) !PkgArtifact {
	if value.type_name != 'Cask::Artifact::Pkg' {
		return error('expected Cask::Artifact::Pkg, got ${value.type_name}')
	}
	return PkgArtifact{
		cask: value.map_data['cask'] or { ruby.object_value('Cask', '') }
		path: (value.map_data['path'] or { ruby.string_value(value.repr) }).as_string()
		stanza_options: (value.map_data['stanza_options'] or { ruby.map_value({}) }).map_data.clone()
	}
}

pub fn (pkg PkgArtifact) summarize() string {
	staged := (pkg.cask.map_data['staged_path'] or { ruby.string_value('') }).as_string().trim_right('/')
	return pkg.path.trim_string_left(staged).trim_left('/')
}

pub fn (pkg PkgArtifact) installer_request(verbose bool, choices_path string, current_user string) !ruby.Value {
	if !os.exists(pkg.path) {
		staged := (pkg.cask.map_data['staged_path'] or { ruby.string_value('') }).as_string()
		mut alternatives := os.glob(os.join_path(staged, '**', '*.pkg')) or { []string{} }
		alternatives.sort()
		mut message := "Could not find PKG source file '${pkg.summarize()}'"
		if alternatives.len > 0 {
			message += ', found ' + alternatives.map("'" + it.trim_string_left(staged).trim_left('/') + "'").join(', ') + ' instead'
		}
		return error(message + '.')
	}
	mut arguments := ['-pkg', pkg.path, '-target', '/']
	if verbose { arguments << '-verboseR' }
	if (pkg.stanza_options['allow_untrusted'] or { ruby.bool_value(false) }).as_bool() or { false } {
		arguments << '-allowUntrusted'
	}
	if choices_path != '' { arguments << ['-applyChoiceChangesXML', choices_path] }
	return ruby.Value{
		type_name: 'SystemCommand::Request'
		repr: '/usr/sbin/installer ${arguments.join(' ')}'
		map_data: {
			'executable':   ruby.string_value('/usr/sbin/installer')
			'args':         ruby.string_array_value(arguments)
			'sudo':         ruby.bool_value(true)
			'sudo_as_root': ruby.bool_value(true)
			'print_stdout': ruby.bool_value(true)
			'env':          ruby.map_value({
				'LOGNAME':  ruby.string_value(current_user)
				'USER':     ruby.string_value(current_user)
				'USERNAME': ruby.string_value(current_user)
			})
		}
	}
}
