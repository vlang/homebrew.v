module cask

import brew_runtime

// Translated from Homebrew/brew `cask/artifact_set.rb`.
// The original source is retained below until every stub has a typed V body.
pub type ArtifactVisitor = fn(brew_runtime.Value)

pub struct ArtifactSet {
pub:
	items []brew_runtime.Value
}

pub fn new_artifact_set(items []brew_runtime.Value) ArtifactSet {
	return ArtifactSet{
		items: items.clone()
	}
}

fn artifact_sort_rank(item brew_runtime.Value) int {
	key := item.attributes['dsl_key'] or {
		if item.type_name.starts_with('Cask::Artifact::') {
			match item.type_name.split('::').last() {
				'App' { 'app' }
				'Pkg' { 'pkg' }
				'Installer' { 'installer' }
				'StageOnly' { 'stage_only' }
				'PreflightBlock' { 'preflight' }
				'PostflightBlock' { 'postflight' }
				else { '' }
			}
		} else {
			''
		}
	}
	return match key {
		'preflight_steps' { 0 }
		'uninstall_preflight_steps' { 1 }
		'preflight' { 2 }
		'uninstall' { 3 }
		'generated_script' { 4 }
		'installer' { 5 }
		'pkg' { 6 }
		'app', 'app_image', 'suite', 'artifact', 'colorpicker', 'prefpane', 'qlplugin', 'mdimporter', 'dictionary', 'font', 'service', 'input_method', 'internet_plugin', 'keyboard_layout', 'audio_unit_plugin', 'vst_plugin', 'vst3_plugin', 'screen_saver', 'stage_only' {
			7
		}
		'binary', 'command_wrapper' { 8 }
		'manpage' { 9 }
		'bash_completion', 'fish_completion', 'zsh_completion' { 10 }
		'generated_completion' { 11 }
		'postflight_steps' { 12 }
		'uninstall_postflight_steps' { 13 }
		'postflight' { 14 }
		'zap' { 15 }
		else { 16 }
	}
}

pub fn (set ArtifactSet) to_array() []brew_runtime.Value {
	mut sorted := []brew_runtime.Value{}
	for item in set.items {
		mut inserted := false
		for index, existing in sorted {
			item_rank := artifact_sort_rank(item)
			existing_rank := artifact_sort_rank(existing)
			if item_rank < existing_rank || (item_rank == 16 && existing_rank == 16 && (item.repr < existing.repr || (item.repr == existing.repr && item.type_name < existing.type_name))) {
				sorted.insert(index, item)
				inserted = true
				break
			}
		}
		if !inserted { sorted << item }
	}
	return sorted
}

pub fn (set ArtifactSet) each(visitor ArtifactVisitor) ArtifactSet {
	for item in set.to_array() {
		visitor(item)
	}
	return set
}

pub fn artifact_set_value(set ArtifactSet) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Cask::ArtifactSet'
		repr: set.items.map(it.repr).str()
		map_data: {
			'items': brew_runtime.array_value(set.items)
		}
	}
}

pub fn artifact_set_from_value(value brew_runtime.Value) !ArtifactSet {
	if value.type_name == 'Array' {
		return new_artifact_set(value.as_array()!)
	}
	if value.type_name != 'Cask::ArtifactSet' {
		return error('expected Cask::ArtifactSet, got ${value.type_name}')
	}
	items := value.map_data['items'] or { brew_runtime.array_value([]) }
	return new_artifact_set(items.as_array()!)
}

// Ruby method `each(&block)` at line 12.
pub fn ruby_artifact_set_l12_d1_each(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'ArtifactSet#each requires a receiver')
	}
	set := artifact_set_from_value(args[0]) or {
		return brew_runtime.object_value('TypeError', err.msg())
	}
	if args.len == 1 {
		return brew_runtime.Value{
			type_name: 'Enumerator'
			repr: '#<Enumerator: Cask::ArtifactSet#each>'
			map_data: {
				'items': brew_runtime.array_value(set.to_array())
			}
		}
	}
	// Function values cannot cross the generic Value boundary. A block marker
	// selects the source method's return value; typed callers use ArtifactSet.each.
	return artifact_set_value(set)
}

// Ruby method `to_a` at line 20.
pub fn ruby_artifact_set_l20_d2_to_a(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'ArtifactSet#to_a requires a receiver')
	}
	set := artifact_set_from_value(args[0]) or {
		return brew_runtime.object_value('TypeError', err.msg())
	}
	return brew_runtime.array_value(set.to_array())
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Cask
// 5:   # Sorted set containing all cask artifacts.
// 6:   class ArtifactSet < ::Set
// 7:     extend T::Generic
// 8:
// 9:     Elem = type_member(:out) { { fixed: Artifact::AbstractArtifact } }
// 10:
// 11:     sig { params(block: T.nilable(T.proc.params(arg0: Elem).returns(T.untyped))).void }
// 12:     def each(&block)
// 13:       return enum_for(T.must(__method__)) { size } unless block
// 14:
// 15:       to_a.each(&block)
// 16:       self
// 17:     end
// 18:
// 19:     sig { returns(T::Array[Artifact::AbstractArtifact]) }
// 20:     def to_a
// 21:       super.sort
// 22:     end
// 23:   end
// 24: end
