module homebrew

import ruby

// Translated from Homebrew/brew `description_cache_store.rb`.
pub struct DescriptionFormula {
pub:
	full_name   string
	description ruby.Value
}

pub struct DescriptionRename {
pub:
	old_name string
	new_name string
}

pub struct DescriptionReport {
pub:
	empty             bool
	formula_added     []string
	formula_modified  []string
	formula_deleted   []string
	formula_renamings []DescriptionRename
	cask_added        []string
	cask_modified     []string
	cask_deleted      []string
}

pub type DescriptionFormulaLoader = fn (string) !DescriptionFormula

pub struct DescriptionCacheStore {
pub mut:
	database CacheStoreDatabase
}

pub fn new_description_cache_store(database CacheStoreDatabase) DescriptionCacheStore {
	return DescriptionCacheStore{
		database: database
	}
}

pub fn (mut store DescriptionCacheStore) update(formula_name string,
	description ruby.Value) {
	store.database.set(formula_name, description)
}

pub fn (mut store DescriptionCacheStore) delete(formula_name string) {
	store.database.delete(formula_name)
}

pub fn (mut store DescriptionCacheStore) populate_if_empty(eval_all bool,
	formulae []DescriptionFormula) {
	if !eval_all || !store.database.empty() {
		return
	}
	for formula in formulae {
		store.update(formula.full_name, formula.description)
	}
}

pub fn (mut store DescriptionCacheStore) update_from_formula_names(formula_names []string,
	trust_configured bool, all_formulae []DescriptionFormula, loader DescriptionFormulaLoader) {
	if !trust_configured {
		store.database.clear()
		return
	}
	if store.database.empty() {
		store.populate_if_empty(trust_configured, all_formulae)
		return
	}
	for name in formula_names {
		formula := loader(name) or {
			store.delete(name)
			continue
		}
		store.update(name, formula.description)
	}
}

pub fn (mut store DescriptionCacheStore) delete_from_formula_names(formula_names []string) {
	if store.database.empty() {
		return
	}
	for name in formula_names {
		store.delete(name)
	}
}

pub fn (mut store DescriptionCacheStore) update_from_report(report DescriptionReport,
	trust_configured bool, all_formulae []DescriptionFormula, loader DescriptionFormulaLoader) {
	if !trust_configured {
		store.database.clear()
		return
	}
	if store.database.empty() {
		store.populate_if_empty(trust_configured, all_formulae)
		return
	}
	if report.empty {
		return
	}
	mut alterations := report.formula_added.clone()
	alterations << report.formula_modified
	mut deletions := report.formula_deleted.clone()
	for rename in report.formula_renamings {
		alterations << rename.new_name
		deletions << rename.old_name
	}
	store.update_from_formula_names(alterations, trust_configured, all_formulae, loader)
	store.delete_from_formula_names(deletions)
}

pub fn (mut store DescriptionCacheStore) select(predicate CacheStorePredicate) map[string]ruby.Value {
	return store.database.select(predicate)
}
