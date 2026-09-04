module artifact

import ruby
import os

// Translated from Homebrew/brew `cask/artifact/relocated.rb`.
const relocated_alt_name_attribute = 'com.apple.metadata:kMDItemAlternateNames'

pub enum RelocatedPlatform {
	macos
	linux
}

pub struct RelocatedArtifact {
pub:
	cask          ruby.Value
	source_string string
	target_string string
	base_dir      string
	home          string
}

pub struct RelocatedFile {
pub:
	path               string
	basename           string
	real_path          string
	writable           bool = true
	real_path_writable bool = true
}

pub struct RelocatedCommand {
pub:
	executable   string
	args         []string
	print_stderr bool = true
	sudo         bool
	must_succeed bool
}

pub struct RelocatedCommandResult {
pub:
	stdout string
}

pub struct RelocatedMetadataResult {
pub:
	no_op           bool
	alternate_names string
	commands        []RelocatedCommand
	last_result     RelocatedCommandResult
}

pub type RelocatedCommandRunner = fn (RelocatedCommand) !RelocatedCommandResult

fn relocated_nil() ruby.Value {
	return ruby.Value{
		type_name: 'NilClass'
		repr: 'nil'
	}
}

fn relocated_cask_string(cask ruby.Value, key string) string {
	if value := cask.map_data[key] {
		return value.as_string()
	}
	return cask.attributes[key] or { '' }
}

fn relocated_url_only_path(cask ruby.Value) string {
	if direct := cask.map_data['url_only_path'] {
		return direct.as_string()
	}
	if direct := cask.attributes['url_only_path'] {
		return direct
	}
	url := cask.map_data['url'] or { return '' }
	if direct := url.map_data['only_path'] {
		return direct.as_string()
	}
	if options := url.map_data['options'] {
		if direct := options.map_data['only_path'] {
			return direct.as_string()
		}
	}
	return url.attributes['only_path'] or { '' }
}

fn relocated_target_base_dir(cask ruby.Value) string {
	dirmethod := relocated_cask_string(cask, 'dirmethod')
	if dirmethod != '' {
		if direct := cask.map_data[dirmethod] {
			return direct.as_string()
		}
		if config := cask.map_data['config'] {
			if direct := config.map_data[dirmethod] {
				return direct.as_string()
			}
			if direct := config.attributes[dirmethod] {
				return direct
			}
		}
	}
	if direct := cask.map_data['base_dir'] {
		return direct.as_string()
	}
	return cask.attributes['base_dir'] or { '' }
}

fn relocated_home(cask ruby.Value) string {
	home := relocated_cask_string(cask, 'home')
	return if home == '' { os.home_dir() } else { home }
}

pub fn new_relocated_artifact_with_context(cask ruby.Value, source string, target string,
	base_dir string, home string) RelocatedArtifact {
	return RelocatedArtifact{
		cask: cask
		source_string: source
		target_string: target
		base_dir: base_dir
		home: if home == '' { os.home_dir() } else { home }
	}
}

pub fn new_relocated_artifact(cask ruby.Value, source string,
	target string) RelocatedArtifact {
	return new_relocated_artifact_with_context(cask, source, target, relocated_target_base_dir(cask), relocated_home(cask))
}

pub fn resolve_relocated_target(target string, base_dir string, home string) string {
	if os.is_abs_path(target) {
		return target
	}
	first_component := target.split(os.path_separator)[0]
	if first_component == '~' {
		if target == '~' {
			return home
		}
		return os.join_path(home, target[2..])
	}
	if base_dir != '' {
		return os.join_path(base_dir, target)
	}
	return target
}

fn relocated_path_join(base string, child string) string {
	return if os.is_abs_path(child) { child } else { os.join_path(base, child) }
}

pub fn (artifact RelocatedArtifact) source() string {
	mut base_path := relocated_cask_string(artifact.cask, 'staged_path')
	only_path := relocated_url_only_path(artifact.cask)
	if only_path.trim_space() != '' {
		base_path = relocated_path_join(base_path, only_path)
	}
	return relocated_path_join(base_path, artifact.source_string)
}

pub fn (artifact RelocatedArtifact) target() string {
	target := if artifact.target_string == '' {
		os.file_name(artifact.source())
	} else {
		artifact.target_string
	}
	return resolve_relocated_target(target, artifact.base_dir, artifact.home)
}

pub fn (artifact RelocatedArtifact) to_args() []ruby.Value {
	mut values := [ruby.string_value(artifact.source_string)]
	if artifact.target_string != '' {
		values << ruby.map_value({
			'target': ruby.string_value(artifact.target_string)
		})
	}
	return values
}

pub fn (artifact RelocatedArtifact) summarize() string {
	if artifact.target_string == '' {
		return artifact.source_string
	}
	return '${artifact.source_string} -> ${artifact.target_string}'
}

pub fn (artifact RelocatedArtifact) printable_target() string {
	target := artifact.target()
	if artifact.home != '' && target == artifact.home {
		return '~/'
	}
	home_prefix := artifact.home.trim_right(os.path_separator) + os.path_separator
	if artifact.home != '' && target.starts_with(home_prefix) {
		return '~/' + target[home_prefix.len..]
	}
	return target
}

pub fn relocated_artifact_to_value(artifact RelocatedArtifact) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::Artifact::Relocated'
		repr: artifact.summarize()
		map_data: {
			'cask':          artifact.cask
			'source_string': ruby.string_value(artifact.source_string)
			'target_string': ruby.string_value(artifact.target_string)
			'base_dir':      ruby.string_value(artifact.base_dir)
			'home':          ruby.string_value(artifact.home)
		}
	}
}

pub fn relocated_artifact_from_value(value ruby.Value) !RelocatedArtifact {
	if !value.type_name.starts_with('Cask::Artifact::') && value.type_name != 'Hash' {
		return error('expected Cask::Artifact::Relocated, got ${value.type_name}')
	}
	return new_relocated_artifact_with_context(value.map_data['cask'] or {
		ruby.object_value('Cask::Cask', '')
	}, (value.map_data['source_string'] or {
		return error('Relocated source is required')
	}).as_string(), (value.map_data['target_string'] or {
		ruby.string_value('')
	}).as_string(), (value.map_data['base_dir'] or {
		ruby.string_value('')
	}).as_string(), (value.map_data['home'] or {
		ruby.string_value(os.home_dir())
	}).as_string())
}

fn relocated_normalize_alternate_names(stdout string) string {
	if stdout.starts_with('(') && stdout.ends_with(')') {
		return stdout[1..stdout.len - 1]
	}
	return stdout
}

fn relocated_metadata_commands(file RelocatedFile, altname string, existing string,
	platform RelocatedPlatform) RelocatedMetadataResult {
	basename := if file.basename == '' { os.file_name(file.path) } else { file.basename }
	if platform == .linux || altname.to_lower() == basename.to_lower() {
		return RelocatedMetadataResult{
			no_op: true
		}
	}
	real_path := if file.real_path == '' { file.path } else { file.real_path }
	mut alternate_names := relocated_normalize_alternate_names(existing)
	if alternate_names != '' {
		alternate_names += ', '
	}
	alternate_names += '"${altname}"'
	alternate_names = '(${alternate_names})'
	commands := [
		RelocatedCommand{
			executable: '/usr/bin/xattr'
			args: ['-p', relocated_alt_name_attribute, file.path]
			print_stderr: false
		},
		RelocatedCommand{
			executable: 'chmod'
			args: ['--', 'u+rw', file.path, real_path]
			sudo: !file.writable || !file.real_path_writable
			must_succeed: true
		},
		RelocatedCommand{
			executable: '/usr/bin/xattr'
			args: ['-w', relocated_alt_name_attribute, alternate_names, file.path]
			print_stderr: false
			sudo: !file.writable
			must_succeed: true
		},
	]
	return RelocatedMetadataResult{
		alternate_names: alternate_names
		commands: commands
	}
}

pub fn plan_relocated_altname_metadata(file RelocatedFile, altname string, existing string,
	platform RelocatedPlatform) RelocatedMetadataResult {
	return relocated_metadata_commands(file, altname, existing, platform)
}

pub fn add_relocated_altname_metadata(file RelocatedFile, altname string,
	platform RelocatedPlatform, runner RelocatedCommandRunner) !RelocatedMetadataResult {
	initial := relocated_metadata_commands(file, altname, '', platform)
	if initial.no_op {
		return initial
	}
	read_result := runner(initial.commands[0])!
	mut result := relocated_metadata_commands(file, altname, read_result.stdout, platform)
	_ = runner(result.commands[1])!
	result = RelocatedMetadataResult{
		...result
		last_result: runner(result.commands[2])!
	}
	return result
}

fn relocated_file_from_value(value ruby.Value) RelocatedFile {
	path := value.as_string()
	return RelocatedFile{
		path: path
		basename: (value.map_data['basename'] or { ruby.string_value(os.file_name(path)) }).as_string()
		real_path: (value.map_data['real_path'] or { ruby.string_value(path) }).as_string()
		writable: (value.map_data['writable'] or { ruby.bool_value(true) }).as_bool() or { true }
		real_path_writable: (value.map_data['real_path_writable'] or { ruby.bool_value(true) }).as_bool() or { true }
	}
}

fn relocated_metadata_value(result RelocatedMetadataResult) ruby.Value {
	return ruby.map_value({
		'no_op':           ruby.bool_value(result.no_op)
		'alternate_names': ruby.string_value(result.alternate_names)
		'commands':        ruby.array_value(result.commands.map(ruby.map_value({
			'executable':   ruby.string_value(it.executable)
			'args':         ruby.string_array_value(it.args)
			'print_stderr': ruby.bool_value(it.print_stderr)
			'sudo':         ruby.bool_value(it.sudo)
			'must_succeed': ruby.bool_value(it.must_succeed)
		})))
		'stdout':          ruby.string_value(result.last_result.stdout)
	})
}
