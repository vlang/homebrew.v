module cmd

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
