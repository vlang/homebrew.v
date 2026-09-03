module dsl

import brew_runtime
import os

// Translated from Homebrew/brew `cask/dsl/rename.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CaskRename {
pub:
	from string
	to   string
}

pub fn new_cask_rename(from string, to string) CaskRename {
	return CaskRename{
		from: from
		to: to
	}
}

pub fn (rename CaskRename) perform(staged_path string) ! {
	if !os.exists(staged_path) {
		return
	}
	mut matches := if rename.from.contains('*') {
		os.glob(os.join_path(staged_path, rename.from)) or { []string{} }
	} else {
		candidate := os.join_path(staged_path, rename.from)
		if os.exists(candidate) { [candidate] } else { []string{} }
	}
	if matches.len == 0 {
		return
	}
	matches.sort()
	source := matches[0]
	target := os.join_path(staged_path, rename.to)
	os.mkdir_all(os.dir(target))!
	if os.exists(source) {
		os.mv(source, target)!
	}
}

pub fn cask_rename_value(rename CaskRename) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Cask::DSL::Rename'
		repr: '{:from=>"${rename.from}", :to=>"${rename.to}"}'
		map_data: {
			'from': brew_runtime.string_value(rename.from)
			'to':   brew_runtime.string_value(rename.to)
		}
		attributes: {
			'from': rename.from
			'to':   rename.to
		}
	}
}

pub fn cask_rename_from_value(value brew_runtime.Value) !CaskRename {
	if value.type_name != 'Cask::DSL::Rename' && value.type_name != 'Hash' {
		return error('expected Cask::DSL::Rename, got ${value.type_name}')
	}
	return CaskRename{
		from: if raw := value.map_data['from'] {
			raw.as_string()} else {
			value.attributes['from'] or { '' }}
		to: if raw := value.map_data['to'] {
			raw.as_string()} else {
			value.attributes['to'] or { '' }}
	}
}

fn cask_rename_receiver(args []brew_runtime.Value) ?CaskRename {
	if args.len == 0 {
		return none
	}
	return cask_rename_from_value(args[0]) or { return none }
}

// Ruby attr_reader `attr_reader :from, :to` at line 9.
pub fn ruby_rename_l9_d1_from(args ...brew_runtime.Value) brew_runtime.Value {
	rename := cask_rename_receiver(args) or { return brew_runtime.Value{ type_name: 'NilClass' } }
	return brew_runtime.string_value(rename.from)
}

// Ruby attr_reader `attr_reader :from, :to` at line 9.
pub fn ruby_rename_l9_d2_to(args ...brew_runtime.Value) brew_runtime.Value {
	rename := cask_rename_receiver(args) or { return brew_runtime.Value{ type_name: 'NilClass' } }
	return brew_runtime.string_value(rename.to)
}

// Ruby method `initialize(from, to)` at line 12.
pub fn ruby_rename_l12_d3_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'Rename.new requires from and to')
	}
	return cask_rename_value(new_cask_rename(args[0].as_string(), args[1].as_string()))
}

// Ruby method `perform_rename(staged_path)` at line 18.
pub fn ruby_rename_l18_d4_perform_rename(args ...brew_runtime.Value) brew_runtime.Value {
	rename := cask_rename_receiver(args) or {
		return brew_runtime.object_value('ArgumentError', 'Rename#perform_rename requires a receiver')
	}
	if args.len < 2 {
		return brew_runtime.object_value('ArgumentError', 'Rename#perform_rename requires staged_path')
	}
	rename.perform(args[1].as_string()) or { return brew_runtime.object_value('SystemCallError', err.msg()) }
	return brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }
}

// Ruby method `pairs` at line 44.
pub fn ruby_rename_l44_d5_pairs(args ...brew_runtime.Value) brew_runtime.Value {
	rename := cask_rename_receiver(args) or { return brew_runtime.map_value({}) }
	return brew_runtime.map_value({
		'from': brew_runtime.string_value(rename.from)
		'to':   brew_runtime.string_value(rename.to)
	})
}

// Ruby method `to_s = pairs.inspect` at line 49.
pub fn ruby_rename_l49_d6_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	rename := cask_rename_receiver(args) or { return brew_runtime.string_value('{}') }
	return brew_runtime.string_value(cask_rename_value(rename).repr)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Cask
// 5:   class DSL
// 6:     # Class corresponding to the `rename` stanza.
// 7:     class Rename
// 8:       sig { returns(String) }
// 9:       attr_reader :from, :to
// 10:
// 11:       sig { params(from: String, to: String).void }
// 12:       def initialize(from, to)
// 13:         @from = from
// 14:         @to = to
// 15:       end
// 16:
// 17:       sig { params(staged_path: Pathname).void }
// 18:       def perform_rename(staged_path)
// 19:         return unless staged_path.exist?
// 20:
// 21:         # Find files matching the glob pattern
// 22:         matching_files = if @from.include?("*")
// 23:           staged_path.glob(@from)
// 24:         else
// 25:           [staged_path.join(@from)].select(&:exist?)
// 26:         end
// 27:
// 28:         return if matching_files.empty?
// 29:
// 30:         # Rename the first matching file to the target path
// 31:         source_file = matching_files.first
// 32:         return if source_file.nil?
// 33:
// 34:         target_file = staged_path.join(@to)
// 35:
// 36:         # Ensure target directory exists
// 37:         target_file.dirname.mkpath
// 38:
// 39:         # Perform the rename
// 40:         source_file.rename(target_file.to_s) if source_file.exist?
// 41:       end
// 42:
// 43:       sig { returns(T::Hash[Symbol, String]) }
// 44:       def pairs
// 45:         { from:, to: }
// 46:       end
// 47:
// 48:       sig { returns(String) }
// 49:       def to_s = pairs.inspect
// 50:     end
// 51:   end
// 52: end
