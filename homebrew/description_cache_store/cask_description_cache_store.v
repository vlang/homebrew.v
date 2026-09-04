module description_cache_store

import ruby
import homebrew

// Translated from Homebrew/brew `description_cache_store/cask_description_cache_store.rb`.
pub struct CaskDescription {
pub:
	full_name   string
	names       []string
	description ?string
}

pub type CaskDescriptionLoader = fn (string) !CaskDescription

fn cask_description_value(cask CaskDescription) ruby.Value {
	description := if value := cask.description {
		ruby.string_value(value)
	} else {
		ruby.Value{ type_name: 'NilClass' }
	}
	return ruby.array_value([
		ruby.string_value(cask.names.join(', ')),
		description,
	])
}

pub fn populate_cask_descriptions_if_empty(mut store homebrew.DescriptionCacheStore,
	eval_all bool, casks []CaskDescription) {
	if !eval_all || !store.database.empty() {
		return
	}
	for cask in casks {
		store.update(cask.full_name, cask_description_value(cask))
	}
}

pub fn update_from_cask_tokens(mut store homebrew.DescriptionCacheStore, tokens []string,
	trust_configured bool, all_casks []CaskDescription, loader CaskDescriptionLoader) {
	if !trust_configured {
		store.database.clear()
		return
	}
	if store.database.empty() {
		populate_cask_descriptions_if_empty(mut store, trust_configured, all_casks)
		return
	}
	for token in tokens {
		cask := loader(token) or {
			store.delete(token)
			continue
		}
		store.update(cask.full_name, cask_description_value(cask))
	}
}

pub fn update_cask_descriptions_from_report(mut store homebrew.DescriptionCacheStore,
	report homebrew.DescriptionReport, trust_configured bool, all_casks []CaskDescription,
	loader CaskDescriptionLoader) {
	if !trust_configured {
		store.database.clear()
		return
	}
	if store.database.empty() {
		populate_cask_descriptions_if_empty(mut store, trust_configured, all_casks)
		return
	}
	if report.empty {
		return
	}
	mut alterations := report.cask_added.clone()
	alterations << report.cask_modified
	update_from_cask_tokens(mut store, alterations, trust_configured, all_casks, loader)
	store.delete_from_formula_names(report.cask_deleted)
}
