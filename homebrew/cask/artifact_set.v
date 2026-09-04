module cask

import ruby

// Translated from Homebrew/brew `cask/artifact_set.rb`.
pub type ArtifactVisitor = fn (ruby.Value)

pub struct ArtifactSet {
pub:
	items []ruby.Value
}

pub fn new_artifact_set(items []ruby.Value) ArtifactSet {
	return ArtifactSet{
		items: items.clone()
	}
}

fn artifact_sort_rank(item ruby.Value) int {
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

pub fn (set ArtifactSet) to_array() []ruby.Value {
	mut sorted := []ruby.Value{}
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

pub fn artifact_set_value(set ArtifactSet) ruby.Value {
	return ruby.Value{
		type_name: 'Cask::ArtifactSet'
		repr: set.items.map(it.repr).str()
		map_data: {
			'items': ruby.array_value(set.items)
		}
	}
}

pub fn artifact_set_from_value(value ruby.Value) !ArtifactSet {
	if value.type_name == 'Array' {
		return new_artifact_set(value.as_array()!)
	}
	if value.type_name != 'Cask::ArtifactSet' {
		return error('expected Cask::ArtifactSet, got ${value.type_name}')
	}
	items := value.map_data['items'] or { ruby.array_value([]) }
	return new_artifact_set(items.as_array()!)
}
