module cask

import brew_runtime
import os
import time

// Translated from Homebrew/brew `cask/metadata.rb`.
// The original source is retained below until every stub has a typed V body.

pub const metadata_subdir_name = '.metadata'

pub struct CaskMetadataPath {
pub:
	present bool
	path    string
}

pub fn cask_metadata_main_container_path(caskroom_path string) string {
	return os.join_path(caskroom_path, metadata_subdir_name)
}

pub fn cask_metadata_versioned_path(version ?string, caskroom_path string) !string {
	cask_version := version or { 'unknown' }
	if cask_version == '' {
		return error('Cannot create metadata path with empty version.')
	}
	return os.join_path(cask_metadata_main_container_path(caskroom_path), cask_version)
}

pub fn cask_metadata_new_timestamp(value time.Time) string {
	utc := value.local_to_utc()
	return utc.strftime('%Y%m%d%H%M%S') + '.${utc.nanosecond / 1_000_000:03d}'
}

pub fn cask_metadata_timestamped_path(version ?string, timestamp string, create bool,
	caskroom_path string) !CaskMetadataPath {
	versioned_path := cask_metadata_versioned_path(version, caskroom_path)!
	mut selected_timestamp := timestamp
	if timestamp == ':latest' {
		if create {
			return error('Cannot create metadata path when timestamp is :latest.')
		}
		mut latest := ''
		if os.is_dir(versioned_path) {
			for entry in os.ls(versioned_path)! {
				candidate := os.join_path(versioned_path, entry)
				if candidate > latest {
					latest = candidate
				}
			}
		}
		return CaskMetadataPath{
			present: latest != ''
			path: latest
		}
	}
	if timestamp == ':now' {
		selected_timestamp = cask_metadata_new_timestamp(time.now())
	} else if timestamp.starts_with(':') {
		return error('Invalid timestamp symbol ${timestamp}. Valid symbols are :latest and :now.')
	}
	path := os.join_path(versioned_path, selected_timestamp)
	if create && !os.is_dir(path) {
		os.mkdir_all(path)!
	}
	return CaskMetadataPath{
		present: true
		path: path
	}
}

pub fn cask_metadata_leaf_subdir(leaf string, version ?string, timestamp string, create bool,
	caskroom_path string) !CaskMetadataPath {
	if create && timestamp == ':latest' {
		return error('Cannot create metadata subdir when timestamp is :latest.')
	}
	if leaf == '' {
		return error('Cannot create metadata subdir for empty leaf.')
	}
	parent := cask_metadata_timestamped_path(version, timestamp, create, caskroom_path)!
	if !parent.present {
		return CaskMetadataPath{}
	}
	subdir := os.join_path(parent.path, leaf)
	if create && !os.is_dir(subdir) {
		os.mkdir_all(subdir)!
	}
	return CaskMetadataPath{
		present: true
		path: subdir
	}
}

fn cask_metadata_optional_version(value brew_runtime.Value) ?string {
	if value.type_name in ['NilClass', 'Nil'] {
		return none
	}
	return value.as_string()
}

fn cask_metadata_timestamp_value(value brew_runtime.Value) string {
	if value.type_name == 'Symbol' {
		return ':${value.as_string().trim_left(':')}'
	}
	return value.as_string()
}

fn cask_metadata_path_value(result CaskMetadataPath) brew_runtime.Value {
	return if result.present {
		brew_runtime.object_value('Pathname', result.path)
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby method `metadata_main_container_path(caskroom_path: self.caskroom_path)` at line 18.
pub fn ruby_metadata_l18_d1_metadata_main_container_path(args ...brew_runtime.Value) brew_runtime.Value {
	caskroom_path := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.object_value('Pathname', cask_metadata_main_container_path(caskroom_path))
}

// Ruby method `metadata_versioned_path(version: self.version, caskroom_path: self.caskroom_path)` at line 23.
pub fn ruby_metadata_l23_d2_metadata_versioned_path(args ...brew_runtime.Value) brew_runtime.Value {
	version := if args.len > 0 { cask_metadata_optional_version(args[0]) } else { ?string(none) }
	caskroom_path := if args.len > 1 { args[1].as_string() } else { '' }
	path := cask_metadata_versioned_path(version, caskroom_path) or {
		return brew_runtime.object_value('CaskError', err.msg())
	}
	return brew_runtime.object_value('Pathname', path)
}

// Ruby method `metadata_timestamped_path(version: self.version, timestamp: :latest, create: false,` at line 39.
pub fn ruby_metadata_l39_d3_metadata_timestamped_path(args ...brew_runtime.Value) brew_runtime.Value {
	version := if args.len > 0 { cask_metadata_optional_version(args[0]) } else { ?string(none) }
	timestamp := if args.len > 1 { cask_metadata_timestamp_value(args[1]) } else { ':latest' }
	create := if args.len > 2 { args[2].as_bool() or { false } } else { false }
	caskroom_path := if args.len > 3 { args[3].as_string() } else { '' }
	result := cask_metadata_timestamped_path(version, timestamp, create, caskroom_path) or {
		return brew_runtime.object_value('CaskError', err.msg())
	}
	return cask_metadata_path_value(result)
}

// Ruby method `metadata_subdir(leaf, version: self.version, timestamp: :latest, create: false,` at line 71.
pub fn ruby_metadata_l71_d4_metadata_subdir(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('CaskError', 'Cannot create metadata subdir for empty leaf.')
	}
	version := if args.len > 1 { cask_metadata_optional_version(args[1]) } else { ?string(none) }
	timestamp := if args.len > 2 { cask_metadata_timestamp_value(args[2]) } else { ':latest' }
	create := if args.len > 3 { args[3].as_bool() or { false } } else { false }
	caskroom_path := if args.len > 4 { args[4].as_string() } else { '' }
	result := cask_metadata_leaf_subdir(args[0].as_string(), version, timestamp, create, caskroom_path) or { return brew_runtime.object_value('CaskError', err.msg()) }
	return cask_metadata_path_value(result)
}

// Ruby method `new_timestamp(time = Time.now)` at line 94.
pub fn ruby_metadata_l94_d5_new_timestamp(args ...brew_runtime.Value) brew_runtime.Value {
	value := if args.len > 0 {
		time.unix(args[0].as_int() or { 0 })
	} else {
		time.now()
	}
	return brew_runtime.string_value(cask_metadata_new_timestamp(value))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5:
// 6: module Cask
// 7:   # Helper module for reading and writing cask metadata.
// 8:   module Metadata
// 9:     extend T::Helpers
// 10:     include ::Utils::Output::Mixin
// 11:
// 12:     METADATA_SUBDIR = ".metadata"
// 13:     TIMESTAMP_FORMAT = "%Y%m%d%H%M%S.%L"
// 14:
// 15:     requires_ancestor { Cask }
// 16:
// 17:     sig { params(caskroom_path: Pathname).returns(Pathname) }
// 18:     def metadata_main_container_path(caskroom_path: self.caskroom_path)
// 19:       caskroom_path.join(METADATA_SUBDIR)
// 20:     end
// 21:
// 22:     sig { params(version: T.nilable(T.any(DSL::Version, String)), caskroom_path: Pathname).returns(Pathname) }
// 23:     def metadata_versioned_path(version: self.version, caskroom_path: self.caskroom_path)
// 24:       cask_version = (version || :unknown).to_s
// 25:
// 26:       raise CaskError, "Cannot create metadata path with empty version." if cask_version.empty?
// 27:
// 28:       metadata_main_container_path(caskroom_path:).join(cask_version)
// 29:     end
// 30:
// 31:     sig {
// 32:       params(
// 33:         version:       T.nilable(T.any(DSL::Version, String)),
// 34:         timestamp:     T.any(Symbol, String),
// 35:         create:        T::Boolean,
// 36:         caskroom_path: Pathname,
// 37:       ).returns(T.nilable(Pathname))
// 38:     }
// 39:     def metadata_timestamped_path(version: self.version, timestamp: :latest, create: false,
// 40:                                   caskroom_path: self.caskroom_path)
// 41:       case timestamp
// 42:       when :latest
// 43:         raise CaskError, "Cannot create metadata path when timestamp is :latest." if create
// 44:
// 45:         return Pathname.glob(metadata_versioned_path(version:, caskroom_path:).join("*")).max
// 46:       when :now
// 47:         timestamp = new_timestamp
// 48:       when Symbol
// 49:         raise CaskError, "Invalid timestamp symbol :#{timestamp}. Valid symbols are :latest and :now."
// 50:       end
// 51:
// 52:       path = metadata_versioned_path(version:, caskroom_path:).join(timestamp)
// 53:
// 54:       if create && !path.directory?
// 55:         odebug "Creating metadata directory: #{path}"
// 56:         path.mkpath
// 57:       end
// 58:
// 59:       path
// 60:     end
// 61:
// 62:     sig {
// 63:       params(
// 64:         leaf:          String,
// 65:         version:       T.nilable(T.any(DSL::Version, String)),
// 66:         timestamp:     T.any(Symbol, String),
// 67:         create:        T::Boolean,
// 68:         caskroom_path: Pathname,
// 69:       ).returns(T.nilable(Pathname))
// 70:     }
// 71:     def metadata_subdir(leaf, version: self.version, timestamp: :latest, create: false,
// 72:                         caskroom_path: self.caskroom_path)
// 73:       raise CaskError, "Cannot create metadata subdir when timestamp is :latest." if create && timestamp == :latest
// 74:       raise CaskError, "Cannot create metadata subdir for empty leaf." if !leaf.respond_to?(:empty?) || leaf.empty?
// 75:
// 76:       parent = metadata_timestamped_path(version:, timestamp:, create:,
// 77:                                          caskroom_path:)
// 78:
// 79:       return if parent.nil?
// 80:
// 81:       subdir = parent.join(leaf)
// 82:
// 83:       if create && !subdir.directory?
// 84:         odebug "Creating metadata subdirectory: #{subdir}"
// 85:         subdir.mkpath
// 86:       end
// 87:
// 88:       subdir
// 89:     end
// 90:
// 91:     private
// 92:
// 93:     sig { params(time: Time).returns(String) }
// 94:     def new_timestamp(time = Time.now)
// 95:       time.utc.strftime(TIMESTAMP_FORMAT)
// 96:     end
// 97:   end
// 98: end
