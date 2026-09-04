module artifact

import ruby
import os

// Translated from Homebrew/brew `cask/artifact/symlinked.rb`.
pub struct SymlinkedArtifact {
pub:
	source           string
	target           string
	english_name     string = 'Artifact'
	link_type_name   string = 'Symlink'
	printable_target string
	caskroom_path    string
	cellar_root      string
}

pub struct SymlinkedInstallOptions {
pub:
	force                  bool
	adopt                  bool
	target_parent_writable bool = true
}

pub struct SymlinkedOperationResult {
pub mut:
	success             bool = true
	error               string
	output              []string
	warnings            []string
	commands            []ArtifactCommand
	linked              bool
	unlinked            bool
	skipped             bool
	conflicting_formula string
}

fn symlinked_run(command ArtifactCommand, runner ArtifactCommandRunner,
	mut result SymlinkedOperationResult) bool {
	result.commands << command
	return runner(command) or {
		result.success = false
		result.error = err.msg()
		false
	}
}

pub fn symlinked_link_type_english_name() string {
	return 'Symlink'
}

pub fn symlinked_english_description(artifact SymlinkedArtifact) string {
	return '${artifact.english_name} ${artifact.link_type_name}s'
}

pub fn symlink_target_links_to_source(artifact SymlinkedArtifact) bool {
	if !os.is_link(artifact.target) {
		return false
	}
	link := os.readlink(artifact.target) or { return false }
	resolved := if link.starts_with('/') {
		link
	} else {
		os.join_path(os.dir(artifact.target), link)
	}
	return os.real_path(resolved) == os.real_path(artifact.source)
}

pub fn symlink_conflicting_formula(artifact SymlinkedArtifact) ?string {
	if !os.is_link(artifact.target) || !os.exists(artifact.target) || artifact.cellar_root == '' {
		return none
	}
	real_target := os.real_path(artifact.target)
	prefix := os.real_path(artifact.cellar_root).trim_string_right('/') + '/'
	if !real_target.starts_with(prefix) {
		return none
	}
	remainder := real_target[prefix.len..]
	formula := remainder.all_before('/')
	if formula == '' {
		return none
	}
	return formula
}

pub fn create_artifact_filesystem_link_with_command(artifact SymlinkedArtifact,
	options SymlinkedInstallOptions, runner ArtifactCommandRunner,
	mut result SymlinkedOperationResult) {
	os.mkdir_all(os.dir(artifact.target)) or {
		result.success = false
		result.error = err.msg()
		return
	}
	command := ArtifactCommand{
		executable: '/bin/ln'
		args: ['--no-dereference', '--force', '--symbolic', artifact.source, artifact.target]
		sudo: !options.target_parent_writable
	}
	if !symlinked_run(command, runner, mut result) {
		if result.error == '' {
			result.success = false
			result.error = 'Failed to create symlink ${artifact.target}.'
		}
		return
	}
	if os.is_link(artifact.target) {
		os.rm(artifact.target) or {
			result.success = false
			result.error = err.msg()
			return
		}
	}
	os.symlink(artifact.source, artifact.target) or {
		result.success = false
		result.error = err.msg()
		return
	}
	result.linked = true
}

pub fn link_symlinked_artifact_with_command(artifact SymlinkedArtifact,
	options SymlinkedInstallOptions, runner ArtifactCommandRunner) SymlinkedOperationResult {
	mut result := SymlinkedOperationResult{}
	if !os.exists(artifact.source) {
		result.success = false
		result.error = "It seems the ${artifact.link_type_name.to_lower()} source '${artifact.source}' is not there."
		return result
	}
	if os.exists(artifact.target) {
		message := "It seems there is already a ${artifact.english_name} at '${artifact.target}'"
		mut removable_cask_link := false
		if os.is_link(artifact.target) {
			real_target := os.real_path(artifact.target)
			removable_cask_link = real_target == os.real_path(artifact.source) || (artifact.caskroom_path != '' && real_target.starts_with(os.real_path(artifact.caskroom_path).trim_string_right('/') + '/'))
		}
		if (options.force || options.adopt) && removable_cask_link {
			result.warnings << '${message}; overwriting.'
			os.rm(artifact.target) or {
				result.success = false
				result.error = err.msg()
				return result
			}
		} else if symlink_target_links_to_source(artifact) {
			result.output << "${artifact.english_name} '${os.file_name(artifact.source)}' is already linked to '${artifact.target}'"
			result.skipped = true
			return result
		} else if formula := symlink_conflicting_formula(artifact) {
			result.warnings << '${message} from formula ${formula}; skipping link.'
			result.conflicting_formula = formula
			result.skipped = true
			return result
		} else {
			result.success = false
			result.error = '${message}.'
			return result
		}
	} else if os.is_link(artifact.target) {
		os.rm(artifact.target) or {
			result.success = false
			result.error = err.msg()
			return result
		}
	}
	result.output << "Linking ${artifact.english_name} '${os.file_name(artifact.source)}' to '${artifact.target}'"
	create_artifact_filesystem_link_with_command(artifact, options, runner, mut result)
	return result
}

pub fn install_symlinked_artifact(artifact SymlinkedArtifact,
	options SymlinkedInstallOptions) SymlinkedOperationResult {
	return link_symlinked_artifact_with_command(artifact, options, default_artifact_command_runner)
}

pub fn unlink_symlinked_artifact(artifact SymlinkedArtifact) SymlinkedOperationResult {
	mut result := SymlinkedOperationResult{}
	if !os.is_link(artifact.target) {
		return result
	}
	if formula := symlink_conflicting_formula(artifact) {
		result.conflicting_formula = formula
		result.skipped = true
		return result
	}
	result.output << "Unlinking ${artifact.english_name} '${artifact.target}'"
	os.rm(artifact.target) or {
		result.success = false
		result.error = err.msg()
		return result
	}
	result.unlinked = true
	return result
}

pub fn summarize_installed_symlink(artifact SymlinkedArtifact) string {
	printable := if artifact.printable_target == '' {
		artifact.target
	} else {
		artifact.printable_target
	}
	if os.is_link(artifact.target) {
		link := os.readlink(artifact.target) or { '' }
		if os.exists(artifact.target) {
			return '${printable} -> ${link}'
		}
		return 'Broken Link: ${printable} -> ${link}'
	}
	return 'Broken Link: ${printable}'
}

pub fn symlinked_artifact_to_value(artifact SymlinkedArtifact) ruby.Value {
	return ruby.map_value({
		'source':           ruby.string_value(artifact.source)
		'target':           ruby.string_value(artifact.target)
		'english_name':     ruby.string_value(artifact.english_name)
		'link_type_name':   ruby.string_value(artifact.link_type_name)
		'printable_target': ruby.string_value(artifact.printable_target)
		'caskroom_path':    ruby.string_value(artifact.caskroom_path)
		'cellar_root':      ruby.string_value(artifact.cellar_root)
	})
}

fn symlinked_artifact_from_value(value ruby.Value) !SymlinkedArtifact {
	values := value.as_map()!
	return SymlinkedArtifact{
		source: (values['source'] or { return error('Symlink source is required') }).as_string()
		target: (values['target'] or { return error('Symlink target is required') }).as_string()
		english_name: (values['english_name'] or { ruby.string_value('Artifact') }).as_string()
		link_type_name: (values['link_type_name'] or { ruby.string_value('Symlink') }).as_string()
		printable_target: (values['printable_target'] or { ruby.string_value('') }).as_string()
		caskroom_path: (values['caskroom_path'] or { ruby.string_value('') }).as_string()
		cellar_root: (values['cellar_root'] or { ruby.string_value('') }).as_string()
	}
}

pub fn symlinked_operation_to_value(result SymlinkedOperationResult) ruby.Value {
	return ruby.map_value({
		'success':             ruby.bool_value(result.success)
		'error':               ruby.string_value(result.error)
		'output':              ruby.string_array_value(result.output)
		'warnings':            ruby.string_array_value(result.warnings)
		'linked':              ruby.bool_value(result.linked)
		'unlinked':            ruby.bool_value(result.unlinked)
		'skipped':             ruby.bool_value(result.skipped)
		'conflicting_formula': ruby.string_value(result.conflicting_formula)
	})
}

fn symlinked_install_options_from_value(value ruby.Value) SymlinkedInstallOptions {
	values := value.as_map() or { return SymlinkedInstallOptions{} }
	return SymlinkedInstallOptions{
		force: value_bool(values, 'force', false)
		adopt: value_bool(values, 'adopt', false)
		target_parent_writable: value_bool(values, 'target_parent_writable', true)
	}
}

fn symlinked_adapter_artifact(args []ruby.Value) !SymlinkedArtifact {
	if args.len == 0 {
		return error('Symlinked artifact is required')
	}
	return symlinked_artifact_from_value(args[0])
}
