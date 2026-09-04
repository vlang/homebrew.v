module cmd

import ruby

// Translated from Homebrew/brew `cmd/home.rb`.
pub enum HomeItemKind {
	formula
	cask
}

pub struct HomeItem {
pub:
	kind             HomeItemKind
	name             string
	homepage         string
	inferred_as_cask bool
	source_path      string
}

pub struct HomeCommandPlan {
pub:
	messages  []string
	warnings  []string
	homepages []string
}

pub fn home_item_name(item HomeItem) string {
	return match item.kind {
		.formula { 'Formula ${item.name}' }
		.cask { 'Cask ${item.name}' }
	}
}

pub fn plan_home_command(homebrew_www string, items []HomeItem) HomeCommandPlan {
	if items.len == 0 {
		return HomeCommandPlan{
			homepages: [homebrew_www]
		}
	}
	mut messages := []string{}
	mut warnings := []string{}
	mut homepages := []string{}
	for item in items {
		messages << 'Opening homepage for ${home_item_name(item)}'
		if item.inferred_as_cask && item.source_path != '' {
			warnings << 'Treating ${item.source_path} as a cask'
		}
		homepages << item.homepage
	}
	return HomeCommandPlan{
		messages: messages
		warnings: warnings
		homepages: homepages
	}
}

pub fn home_item_value(item HomeItem) ruby.Value {
	return ruby.structured_value(if item.kind == .formula { 'Formula' } else { 'Cask' }, item.name, {
		'name':             item.name
		'homepage':         item.homepage
		'kind':             item.kind.str()
		'inferred_as_cask': item.inferred_as_cask.str()
		'source_path':      item.source_path
	})
}

fn home_item_from_value(value ruby.Value) HomeItem {
	kind := if (value.attribute('kind') or { value.type_name.to_lower() }) == 'cask' {
		HomeItemKind.cask
	} else {
		HomeItemKind.formula
	}
	return HomeItem{
		kind: kind
		name: value.attribute('name') or { value.as_string() }
		homepage: value.attribute('homepage') or { '' }
		inferred_as_cask: (value.attribute('inferred_as_cask') or { 'false' }) == 'true'
		source_path: value.attribute('source_path') or { '' }
	}
}

pub fn home_command_plan_value(plan HomeCommandPlan) ruby.Value {
	return ruby.Value{
		type_name: 'HomeCommandPlan'
		repr: plan.homepages.join(' ')
		map_data: {
			'messages':  ruby.string_array_value(plan.messages)
			'warnings':  ruby.string_array_value(plan.warnings)
			'homepages': ruby.string_array_value(plan.homepages)
		}
	}
}
