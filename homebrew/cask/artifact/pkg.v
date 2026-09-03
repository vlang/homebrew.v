module artifact

import brew_runtime
import os

// Translated from Homebrew/brew `cask/artifact/pkg.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct PkgArtifact {
pub:
	cask           brew_runtime.Value
	path           string
	stanza_options map[string]brew_runtime.Value
}

pub fn new_pkg_artifact(cask brew_runtime.Value, path string, options map[string]brew_runtime.Value) !PkgArtifact {
	for key, _ in options {
		if key !in ['allow_untrusted', 'choices'] {
			return error("unknown keyword: '${key}'")
		}
	}
	staged := (cask.map_data['staged_path'] or { brew_runtime.string_value('') }).as_string()
	return PkgArtifact{ cask: cask, path: os.join_path(staged, path), stanza_options: options.clone() }
}

pub fn pkg_artifact_value(pkg PkgArtifact) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Cask::Artifact::Pkg'
		repr: pkg.path
		map_data: {
			'cask':           pkg.cask
			'path':           brew_runtime.object_value('Pathname', pkg.path)
			'stanza_options': brew_runtime.map_value(pkg.stanza_options)
		}
		attributes: {
			'dsl_key': 'pkg'
		}
	}
}

pub fn pkg_artifact_from_value(value brew_runtime.Value) !PkgArtifact {
	if value.type_name != 'Cask::Artifact::Pkg' {
		return error('expected Cask::Artifact::Pkg, got ${value.type_name}')
	}
	return PkgArtifact{
		cask: value.map_data['cask'] or { brew_runtime.object_value('Cask', '') }
		path: (value.map_data['path'] or { brew_runtime.string_value(value.repr) }).as_string()
		stanza_options: (value.map_data['stanza_options'] or { brew_runtime.map_value({}) }).map_data.clone()
	}
}

pub fn (pkg PkgArtifact) summarize() string {
	staged := (pkg.cask.map_data['staged_path'] or { brew_runtime.string_value('') }).as_string().trim_right('/')
	return pkg.path.trim_string_left(staged).trim_left('/')
}

pub fn (pkg PkgArtifact) installer_request(verbose bool, choices_path string, current_user string) !brew_runtime.Value {
	if !os.exists(pkg.path) {
		staged := (pkg.cask.map_data['staged_path'] or { brew_runtime.string_value('') }).as_string()
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
	if (pkg.stanza_options['allow_untrusted'] or { brew_runtime.bool_value(false) }).as_bool() or { false } {
		arguments << '-allowUntrusted'
	}
	if choices_path != '' { arguments << ['-applyChoiceChangesXML', choices_path] }
	return brew_runtime.Value{
		type_name: 'SystemCommand::Request'
		repr: '/usr/sbin/installer ${arguments.join(' ')}'
		map_data: {
			'executable':   brew_runtime.string_value('/usr/sbin/installer')
			'args':         brew_runtime.string_array_value(arguments)
			'sudo':         brew_runtime.bool_value(true)
			'sudo_as_root': brew_runtime.bool_value(true)
			'print_stdout': brew_runtime.bool_value(true)
			'env':          brew_runtime.map_value({
				'LOGNAME':  brew_runtime.string_value(current_user)
				'USER':     brew_runtime.string_value(current_user)
				'USERNAME': brew_runtime.string_value(current_user)
			})
		}
	}
}

// Ruby attr_reader `attr_reader :path` at line 13.
pub fn ruby_pkg_l13_d1_path(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'path requires a receiver')
	}
	pkg := pkg_artifact_from_value(args[0]) or { return brew_runtime.object_value('TypeError', err.msg()) }
	return brew_runtime.object_value('Pathname', pkg.path)
}

// Ruby attr_reader `attr_reader :stanza_options` at line 16.
pub fn ruby_pkg_l16_d2_stanza_options(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'stanza_options requires a receiver')
	}
	pkg := pkg_artifact_from_value(args[0]) or { return brew_runtime.object_value('TypeError', err.msg()) }
	return brew_runtime.map_value(pkg.stanza_options)
}

// Ruby method `self.from_args(cask, path, **stanza_options)` at line 19.
pub fn ruby_pkg_l19_d3_self_from_args(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'pkg requires cask and path')
	}
	options := if args.len > 2 && args[2].type_name == 'Hash' {
		args[2].map_data
	} else {
		map[string]brew_runtime.Value{}
	}
	pkg := new_pkg_artifact(args[0], args[1].as_string(), options) or { return brew_runtime.object_value('CaskInvalidError', err.msg()) }
	return pkg_artifact_value(pkg)
}

// Ruby method `initialize(cask, path, **stanza_options)` at line 26.
pub fn ruby_pkg_l26_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_pkg_l19_d3_self_from_args(...args)
}

// Ruby method `summarize` at line 33.
pub fn ruby_pkg_l33_d5_summarize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'summarize requires a receiver')
	}
	pkg := pkg_artifact_from_value(args[0]) or { return brew_runtime.object_value('TypeError', err.msg()) }
	return brew_runtime.string_value(pkg.summarize())
}

// Ruby method `install_phase(command: SystemCommand, verbose: false, **_options)` at line 44.
pub fn ruby_pkg_l44_d6_install_phase(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_pkg_l51_d7_run_installer(...args)
}

// Ruby method `run_installer(command: SystemCommand, verbose: false)` at line 51.
pub fn ruby_pkg_l51_d7_run_installer(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'run_installer requires a receiver')
	}
	pkg := pkg_artifact_from_value(args[0]) or { return brew_runtime.object_value('TypeError', err.msg()) }
	options := if args.len > 1 && args[1].type_name == 'Hash' {
		args[1].map_data
	} else {
		map[string]brew_runtime.Value{}
	}
	verbose := (options['verbose'] or { brew_runtime.bool_value(false) }).as_bool() or { false }
	choices_path := (options['choices_path'] or { brew_runtime.string_value('') }).as_string()
	current_user := (options['current_user'] or { brew_runtime.string_value('') }).as_string()
	return pkg.installer_request(verbose, choices_path, current_user) or { brew_runtime.object_value('CaskError', err.msg()) }
}

// Ruby method `with_choices_file(&_blk)` at line 96.
pub fn ruby_pkg_l96_d8_with_choices_file(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'with_choices_file requires a receiver')
	}
	pkg := pkg_artifact_from_value(args[0]) or { return brew_runtime.object_value('TypeError', err.msg()) }
	choices := pkg.stanza_options['choices'] or { brew_runtime.map_value({}) }
	if choices.map_data.len == 0 {
		return if args.len > 1 {
			args[1]
		} else {
			brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }
		}
	}
	return brew_runtime.Value{
		type_name: 'Tempfile::Payload'
		repr: 'choices.xml'
		map_data: {
			'choices':      choices
			'block_result': if args.len > 1 {
				args[1]} else {
				brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }}
		}
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/user"
// 5: require "cask/artifact/abstract_artifact"
// 6: require "extend/hash/keys"
// 7:
// 8: module Cask
// 9:   module Artifact
// 10:     # Artifact corresponding to the `pkg` stanza.
// 11:     class Pkg < AbstractArtifact
// 12:       sig { returns(Pathname) }
// 13:       attr_reader :path
// 14:
// 15:       sig { returns(T::Hash[Symbol, T.untyped]) }
// 16:       attr_reader :stanza_options
// 17:
// 18:       sig { params(cask: Cask, path: T.any(String, Pathname), stanza_options: T.untyped).returns(T.attached_class) }
// 19:       def self.from_args(cask, path, **stanza_options)
// 20:         # odeprecated: `allow_untrusted` disables certificate verification and is being removed.
// 21:         stanza_options.assert_valid_keys(:allow_untrusted, :choices)
// 22:         new(cask, path, **stanza_options)
// 23:       end
// 24:
// 25:       sig { params(cask: Cask, path: T.any(String, Pathname), stanza_options: T.untyped).void }
// 26:       def initialize(cask, path, **stanza_options)
// 27:         super
// 28:         @path = T.let(cask.staged_path.join(path), Pathname)
// 29:         @stanza_options = stanza_options
// 30:       end
// 31:
// 32:       sig { override.returns(String) }
// 33:       def summarize
// 34:         path.relative_path_from(cask.staged_path).to_s
// 35:       end
// 36:
// 37:       sig {
// 38:         params(
// 39:           command:  T.class_of(SystemCommand),
// 40:           verbose:  T::Boolean,
// 41:           _options: T.anything,
// 42:         ).void
// 43:       }
// 44:       def install_phase(command: SystemCommand, verbose: false, **_options)
// 45:         run_installer(command:, verbose:)
// 46:       end
// 47:
// 48:       private
// 49:
// 50:       sig { params(command: T.class_of(SystemCommand), verbose: T::Boolean).void }
// 51:       def run_installer(command: SystemCommand, verbose: false)
// 52:         ohai "Running installer for #{cask} with `sudo` (which may request your password)..."
// 53:         unless path.exist?
// 54:           pkg = path.relative_path_from(cask.staged_path)
// 55:           pkgs = Pathname.glob(cask.staged_path/"**"/"*.pkg").map { |path| path.relative_path_from(cask.staged_path) }
// 56:
// 57:           message = "Could not find PKG source file '#{pkg}'"
// 58:           message += ", found #{pkgs.map { |path| "'#{path}'" }.to_sentence} instead" if pkgs.any?
// 59:           message += "."
// 60:
// 61:           raise CaskError, message
// 62:         end
// 63:
// 64:         args = [
// 65:           "-pkg",    path,
// 66:           "-target", "/"
// 67:         ]
// 68:         args << "-verboseR" if verbose
// 69:         # odeprecated: `allow_untrusted` disables certificate verification and is being removed.
// 70:         args << "-allowUntrusted" if stanza_options.fetch(:allow_untrusted, false)
// 71:         with_choices_file do |choices_path|
// 72:           args << "-applyChoiceChangesXML" << choices_path if choices_path
// 73:
// 74:           current_user_str = User.current&.to_s
// 75:           env = {
// 76:             "LOGNAME"  => current_user_str,
// 77:             "USER"     => current_user_str,
// 78:             "USERNAME" => current_user_str,
// 79:           }
// 80:
// 81:           command.run!(
// 82:             "/usr/sbin/installer",
// 83:             sudo:         true,
// 84:             sudo_as_root: true,
// 85:             args:,
// 86:             print_stdout: true,
// 87:             env:,
// 88:           )
// 89:         end
// 90:       end
// 91:
// 92:       sig {
// 93:         params(_blk: T.proc.params(choices_path: T.nilable(String)).void)
// 94:           .void
// 95:       }
// 96:       def with_choices_file(&_blk)
// 97:         choices = stanza_options.fetch(:choices, {})
// 98:         return yield nil if choices.empty?
// 99:
// 100:         require "plist"
// 101:         Tempfile.open(["choices", ".xml"]) do |file|
// 102:           file.write Plist::Emit.dump(choices)
// 103:           file.close
// 104:           yield file.path
// 105:         ensure
// 106:           file.unlink
// 107:         end
// 108:       end
// 109:     end
// 110:   end
// 111: end
