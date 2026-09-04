module artifact

import ruby
import os

// Translated from Homebrew/brew `cask/artifact/symlinked.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `self.link_type_english_name` at line 11.
pub fn ruby_symlinked_l11_d1_self_link_type_english_name(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(symlinked_link_type_english_name())
}

// Ruby method `self.english_description` at line 16.
pub fn ruby_symlinked_l16_d2_self_english_description(args ...ruby.Value) ruby.Value {
	if args.len > 0 {
		artifact := symlinked_artifact_from_value(args[0]) or {
			return ruby.string_value('Artifact Symlinks')
		}
		return ruby.string_value(symlinked_english_description(artifact))
	}
	return ruby.string_value('Artifact Symlinks')
}

// Ruby method `install_phase(force: false, adopt: false, command: SystemCommand, **options)` at line 28.
pub fn ruby_symlinked_l28_d3_install_phase(args ...ruby.Value) ruby.Value {
	artifact := symlinked_adapter_artifact(args) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	options := if args.len > 1 {
		symlinked_install_options_from_value(args[1])
	} else {
		SymlinkedInstallOptions{}
	}
	return symlinked_operation_to_value(install_symlinked_artifact(artifact, options))
}

// Ruby method `uninstall_phase(command: SystemCommand, **_options)` at line 38.
pub fn ruby_symlinked_l38_d4_uninstall_phase(args ...ruby.Value) ruby.Value {
	artifact := symlinked_adapter_artifact(args) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	return symlinked_operation_to_value(unlink_symlinked_artifact(artifact))
}

// Ruby method `summarize_installed` at line 43.
pub fn ruby_symlinked_l43_d5_summarize_installed(args ...ruby.Value) ruby.Value {
	artifact := symlinked_adapter_artifact(args) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	return ruby.string_value(summarize_installed_symlink(artifact))
}

// Ruby method `link(force: false, adopt: false, command: SystemCommand, **_options)` at line 67.
pub fn ruby_symlinked_l67_d6_link(args ...ruby.Value) ruby.Value {
	return ruby_symlinked_l28_d3_install_phase(...args)
}

// Ruby method `unlink(command: SystemCommand)` at line 98.
pub fn ruby_symlinked_l98_d7_unlink(args ...ruby.Value) ruby.Value {
	return ruby_symlinked_l38_d4_uninstall_phase(...args)
}

// Ruby method `create_filesystem_link(command)` at line 112.
pub fn ruby_symlinked_l112_d8_create_filesystem_link(args ...ruby.Value) ruby.Value {
	artifact := symlinked_adapter_artifact(args) or {
		return ruby.object_value('ArgumentError', err.msg())
	}
	options := if args.len > 1 {
		symlinked_install_options_from_value(args[1])
	} else {
		SymlinkedInstallOptions{}
	}
	mut result := SymlinkedOperationResult{}
	create_artifact_filesystem_link_with_command(artifact, options, default_artifact_command_runner, mut result)
	return symlinked_operation_to_value(result)
}

// Ruby method `target_links_to_source?` at line 120.
pub fn ruby_symlinked_l120_d9_target_links_to_source(args ...ruby.Value) ruby.Value {
	artifact := symlinked_adapter_artifact(args) or { return ruby.bool_value(false) }
	return ruby.bool_value(symlink_target_links_to_source(artifact))
}

// Ruby method `conflicting_formula` at line 130.
pub fn ruby_symlinked_l130_d10_conflicting_formula(args ...ruby.Value) ruby.Value {
	artifact := symlinked_adapter_artifact(args) or {
		return ruby.object_value('NilClass', 'nil')
	}
	formula := symlink_conflicting_formula(artifact) or {
		return ruby.object_value('NilClass', 'nil')
	}
	return ruby.string_value(formula)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/artifact/relocated"
// 5:
// 6: module Cask
// 7:   module Artifact
// 8:     # Superclass for all artifacts which are installed by symlinking them to the target location.
// 9:     class Symlinked < Relocated
// 10:       sig { returns(String) }
// 11:       def self.link_type_english_name
// 12:         "Symlink"
// 13:       end
// 14:
// 15:       sig { returns(String) }
// 16:       def self.english_description
// 17:         "#{english_name} #{link_type_english_name}s"
// 18:       end
// 19:
// 20:       sig {
// 21:         params(
// 22:           force:   T::Boolean,
// 23:           adopt:   T::Boolean,
// 24:           command: T.class_of(SystemCommand),
// 25:           options: T.anything,
// 26:         ).void
// 27:       }
// 28:       def install_phase(force: false, adopt: false, command: SystemCommand, **options)
// 29:         link(force:, adopt:, command:, **options)
// 30:       end
// 31:
// 32:       sig {
// 33:         params(
// 34:           command:  T.class_of(SystemCommand),
// 35:           _options: T.anything,
// 36:         ).void
// 37:       }
// 38:       def uninstall_phase(command: SystemCommand, **_options)
// 39:         unlink(command:)
// 40:       end
// 41:
// 42:       sig { returns(String) }
// 43:       def summarize_installed
// 44:         if target.symlink? && target.exist? && target.readlink.exist?
// 45:           "#{printable_target} -> #{target.readlink} (#{target.readlink.abv})"
// 46:         else
// 47:           string = if target.symlink?
// 48:             "#{printable_target} -> #{target.readlink}"
// 49:           else
// 50:             printable_target
// 51:           end
// 52:
// 53:           Formatter.error(string, label: "Broken Link")
// 54:         end
// 55:       end
// 56:
// 57:       private
// 58:
// 59:       sig {
// 60:         overridable.params(
// 61:           force:    T::Boolean,
// 62:           adopt:    T::Boolean,
// 63:           command:  T.class_of(SystemCommand),
// 64:           _options: T.anything,
// 65:         ).void
// 66:       }
// 67:       def link(force: false, adopt: false, command: SystemCommand, **_options)
// 68:         unless source.exist?
// 69:           raise CaskError,
// 70:                 "It seems the #{self.class.link_type_english_name.downcase} " \
// 71:                 "source '#{source}' is not there."
// 72:         end
// 73:
// 74:         if target.exist?
// 75:           message = "It seems there is already #{self.class.english_article} " \
// 76:                     "#{self.class.english_name} at '#{target}'"
// 77:
// 78:           if (force || adopt) && target.symlink? &&
// 79:              (target.realpath == source.realpath || target.realpath.to_s.start_with?("#{cask.caskroom_path}/"))
// 80:             opoo "#{message}; overwriting."
// 81:             Utils.gain_permissions_remove(target, command:)
// 82:           elsif target_links_to_source?
// 83:             ohai "#{self.class.english_name} '#{source.basename}' is already linked to '#{target}'"
// 84:             return
// 85:           elsif (formula = conflicting_formula)
// 86:             opoo "#{message} from formula #{formula}; skipping link."
// 87:             return
// 88:           else
// 89:             raise CaskError, "#{message}."
// 90:           end
// 91:         end
// 92:
// 93:         ohai "Linking #{self.class.english_name} '#{source.basename}' to '#{target}'"
// 94:         create_filesystem_link(command)
// 95:       end
// 96:
// 97:       sig { params(command: T.class_of(SystemCommand)).void }
// 98:       def unlink(command: SystemCommand)
// 99:         return unless target.symlink?
// 100:
// 101:         ohai "Unlinking #{self.class.english_name} '#{target}'"
// 102:
// 103:         if (formula = conflicting_formula)
// 104:           odebug "#{target} is from formula #{formula}; skipping unlink."
// 105:           return
// 106:         end
// 107:
// 108:         Utils.gain_permissions_remove(target, command:)
// 109:       end
// 110:
// 111:       sig { params(command: T.class_of(SystemCommand)).void }
// 112:       def create_filesystem_link(command)
// 113:         Utils.gain_permissions_mkpath(target.dirname, command:)
// 114:
// 115:         command.run! "/bin/ln", args: ["--no-dereference", "--force", "--symbolic", source, target],
// 116:                                 sudo: !target.dirname.writable?
// 117:       end
// 118:
// 119:       sig { returns(T::Boolean) }
// 120:       def target_links_to_source?
// 121:         target.symlink? && target.realpath == source.realpath
// 122:       rescue => e
// 123:         odebug "Error checking whether #{target} links to #{source}: #{e}"
// 124:         false
// 125:       end
// 126:
// 127:       # Check if the target file is a symlink that originates from a formula
// 128:       # with the same name as this cask, indicating a potential conflict
// 129:       sig { returns(T.nilable(String)) }
// 130:       def conflicting_formula
// 131:         if target.symlink? && target.exist? &&
// 132:            (match = target.realpath.to_s.match(%r{^#{HOMEBREW_CELLAR}/(?<formula>[^/]+)/}o))
// 133:           match[:formula]
// 134:         end
// 135:       rescue => e
// 136:         # If we can't determine the realpath or any other error occurs,
// 137:         # don't treat it as a conflicting formula file
// 138:         odebug "Error checking for conflicting formula file: #{e}"
// 139:         nil
// 140:       end
// 141:     end
// 142:   end
// 143: end
// 144:
// 145: require "extend/os/cask/artifact/symlinked"
