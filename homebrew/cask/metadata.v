module cask

import ruby
import os
import time

// Translated from Homebrew/brew `cask/metadata.rb`.

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

fn cask_metadata_optional_version(value ruby.Value) ?string {
	if value.type_name in ['NilClass', 'Nil'] {
		return none
	}
	return value.as_string()
}

fn cask_metadata_timestamp_value(value ruby.Value) string {
	if value.type_name == 'Symbol' {
		return ':${value.as_string().trim_left(':')}'
	}
	return value.as_string()
}

fn cask_metadata_path_value(result CaskMetadataPath) ruby.Value {
	return if result.present {
		ruby.object_value('Pathname', result.path)
	} else {
		ruby.object_value('NilClass', 'nil')
	}
}
