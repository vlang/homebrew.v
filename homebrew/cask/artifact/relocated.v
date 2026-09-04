module artifact

import ruby
import os

// Translated from Homebrew/brew `cask/artifact/relocated.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `self.from_args(cask, source_string, target_hash = nil)` at line 18.
pub fn ruby_relocated_l18_d1_self_from_args(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'relocated artifact requires cask and source')
	}
	mut target := ''
	if args.len > 2 && args[2].type_name != 'NilClass' {
		if args[2].type_name != 'Hash' {
			return ruby.object_value('CaskInvalidError', args[0].as_string())
		}
		for key, _ in args[2].map_data {
			if key != 'target' {
				return ruby.object_value('CaskInvalidError', "invalid key: '${key}'")
			}
		}
		target = (args[2].map_data['target'] or { ruby.string_value('') }).as_string()
	}
	return relocated_artifact_to_value(new_relocated_artifact(args[0], args[1].as_string(), target))
}

// Ruby method `resolve_target(target, base_dir: config.public_send(self.class.dirmethod))` at line 31.
pub fn ruby_relocated_l31_d2_resolve_target(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'resolve_target requires a receiver and target')
	}
	artifact := relocated_artifact_from_value(args[0]) or {
		return ruby.object_value('TypeError', err.msg())
	}
	base_dir := if args.len > 2 { args[2].as_string() } else { artifact.base_dir }
	return ruby.object_value('Pathname', resolve_relocated_target(args[1].as_string(), base_dir, artifact.home))
}

// Ruby method `initialize(cask, source, **target_hash)` at line 46.
pub fn ruby_relocated_l46_d3_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('ArgumentError', 'relocated artifact requires cask and source')
	}
	mut target := ''
	if args.len > 2 {
		if args[2].type_name != 'Hash' {
			return ruby.object_value('TypeError', 'target keywords must be a Hash')
		}
		target = (args[2].map_data['target'] or { ruby.string_value('') }).as_string()
	}
	return relocated_artifact_to_value(new_relocated_artifact(args[0], args[1].as_string(), target))
}

// Ruby method `source` at line 57.
pub fn ruby_relocated_l57_d4_source(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'source requires a receiver')
	}
	artifact := relocated_artifact_from_value(args[0]) or {
		return ruby.object_value('TypeError', err.msg())
	}
	return ruby.object_value('Pathname', artifact.source())
}

// Ruby method `target` at line 66.
pub fn ruby_relocated_l66_d5_target(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'target requires a receiver')
	}
	artifact := relocated_artifact_from_value(args[0]) or {
		return ruby.object_value('TypeError', err.msg())
	}
	return ruby.object_value('Pathname', artifact.target())
}

// Ruby method `to_a` at line 71.
pub fn ruby_relocated_l71_d6_to_a(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'to_a requires a receiver')
	}
	artifact := relocated_artifact_from_value(args[0]) or {
		return ruby.object_value('TypeError', err.msg())
	}
	return ruby.array_value(artifact.to_args())
}

// Ruby method `summarize` at line 78.
pub fn ruby_relocated_l78_d7_summarize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'summarize requires a receiver')
	}
	artifact := relocated_artifact_from_value(args[0]) or {
		return ruby.object_value('TypeError', err.msg())
	}
	return ruby.string_value(artifact.summarize())
}

// Ruby method `add_altname_metadata(file, altname, command:)` at line 87.
pub fn ruby_relocated_l87_d8_add_altname_metadata(args ...ruby.Value) ruby.Value {
	if args.len < 3 {
		return ruby.object_value('ArgumentError', 'add_altname_metadata requires a receiver, file and altname')
	}
	options := if args.len > 3 { args[3].map_data } else { map[string]ruby.Value{} }
	platform := if (options['platform'] or { ruby.string_value('macos') }).as_string() == 'linux' {
		RelocatedPlatform.linux
	} else {
		RelocatedPlatform.macos
	}
	result := plan_relocated_altname_metadata(relocated_file_from_value(args[1]), args[2].as_string(), (options['xattr_stdout'] or { ruby.string_value('') }).as_string(), platform)
	return if result.no_op { relocated_nil() } else { relocated_metadata_value(result) }
}

// Ruby method `printable_target` at line 116.
pub fn ruby_relocated_l116_d9_printable_target(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'printable_target requires a receiver')
	}
	artifact := relocated_artifact_from_value(args[0]) or {
		return ruby.object_value('TypeError', err.msg())
	}
	return ruby.string_value(artifact.printable_target())
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
// 9:     # Superclass for all artifacts which have a source and a target location.
// 10:     class Relocated < AbstractArtifact
// 11:       sig {
// 12:         overridable.params(
// 13:           cask:          Cask,
// 14:           source_string: T.any(String, Pathname),
// 15:           target_hash:   T.untyped,
// 16:         ).returns(T.attached_class)
// 17:       }
// 18:       def self.from_args(cask, source_string, target_hash = nil)
// 19:         if target_hash
// 20:           raise CaskInvalidError, cask unless target_hash.respond_to?(:keys)
// 21:
// 22:           target_hash.assert_valid_keys(:target)
// 23:         end
// 24:
// 25:         target_hash ||= {}
// 26:
// 27:         new(cask, source_string, **target_hash)
// 28:       end
// 29:
// 30:       sig { overridable.params(target: T.any(String, Pathname), base_dir: T.nilable(Pathname)).returns(Pathname) }
// 31:       def resolve_target(target, base_dir: config.public_send(self.class.dirmethod))
// 32:         target = Pathname(target)
// 33:
// 34:         if target.relative?
// 35:           return target.expand_path if target.descend.first.to_s == "~"
// 36:           return base_dir/target if base_dir
// 37:         end
// 38:
// 39:         target
// 40:       end
// 41:
// 42:       sig {
// 43:         params(cask: Cask, source: T.any(String, Pathname), target_hash: T.any(String, Pathname))
// 44:           .void
// 45:       }
// 46:       def initialize(cask, source, **target_hash)
// 47:         super
// 48:
// 49:         target = target_hash[:target]
// 50:         @source = T.let(nil, T.nilable(Pathname))
// 51:         @source_string = T.let(source.to_s, String)
// 52:         @target = T.let(nil, T.nilable(Pathname))
// 53:         @target_string = T.let(target.to_s, String)
// 54:       end
// 55:
// 56:       sig { returns(Pathname) }
// 57:       def source
// 58:         @source ||= begin
// 59:           base_path = cask.staged_path
// 60:           base_path = base_path.join(T.must(cask.url).only_path) if cask.url&.only_path.present?
// 61:           base_path.join(@source_string)
// 62:         end
// 63:       end
// 64:
// 65:       sig { returns(Pathname) }
// 66:       def target
// 67:         @target ||= resolve_target(@target_string.presence || source.basename)
// 68:       end
// 69:
// 70:       sig { returns(T::Array[T.anything]) }
// 71:       def to_a
// 72:         [@source_string].tap do |ary|
// 73:           ary << { target: @target_string } unless @target_string.empty?
// 74:         end
// 75:       end
// 76:
// 77:       sig { override.returns(String) }
// 78:       def summarize
// 79:         target_string = @target_string.empty? ? "" : " -> #{@target_string}"
// 80:         "#{@source_string}#{target_string}"
// 81:       end
// 82:
// 83:       # Try to make the asset searchable under the target name. Spotlight
// 84:       # respects this attribute for many filetypes, but ignores it for App
// 85:       # bundles. Alfred 2.2 respects it even for App bundles.
// 86:       sig { params(file: Pathname, altname: Pathname, command: T.class_of(SystemCommand)).returns(T.nilable(SystemCommand::Result)) }
// 87:       def add_altname_metadata(file, altname, command:)
// 88:         return if altname.to_s.casecmp(file.basename.to_s)&.zero?
// 89:
// 90:         odebug "Adding #{ALT_NAME_ATTRIBUTE} metadata"
// 91:         altnames = command.run("/usr/bin/xattr",
// 92:                                args:         ["-p", ALT_NAME_ATTRIBUTE, file],
// 93:                                print_stderr: false).stdout.sub(/\A\((.*)\)\Z/, '\1')
// 94:         odebug "Existing metadata is: #{altnames}"
// 95:         altnames.concat(", ") unless altnames.empty?
// 96:         altnames.concat(%Q("#{altname}"))
// 97:         altnames = "(#{altnames})"
// 98:
// 99:         # Some packages are shipped as u=rx (e.g. Bitcoin Core)
// 100:         command.run!("chmod",
// 101:                      args: ["--", "u+rw", file, file.realpath],
// 102:                      sudo: !file.writable? || !file.realpath.writable?)
// 103:
// 104:         command.run!("/usr/bin/xattr",
// 105:                      args:         ["-w", ALT_NAME_ATTRIBUTE, altnames, file],
// 106:                      print_stderr: false,
// 107:                      sudo:         !file.writable?)
// 108:       end
// 109:
// 110:       private
// 111:
// 112:       ALT_NAME_ATTRIBUTE = "com.apple.metadata:kMDItemAlternateNames"
// 113:       private_constant :ALT_NAME_ATTRIBUTE
// 114:
// 115:       sig { returns(String) }
// 116:       def printable_target
// 117:         target.to_s.sub(/^#{Dir.home}(#{File::SEPARATOR}|$)/, "~/")
// 118:       end
// 119:     end
// 120:   end
// 121: end
// 122:
// 123: require "extend/os/cask/artifact/relocated"
