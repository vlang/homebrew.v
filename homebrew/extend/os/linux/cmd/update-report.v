module cmd

import ruby

// Translated from Homebrew/brew `extend/os/linux/cmd/update-report.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct UpdateReportDependency {
pub:
	name  string
	build bool
	test  bool
}

pub struct UpdateReportFormula {
pub:
	name         string
	core_tap     bool
	dependencies []UpdateReportDependency
	unavailable  bool
pub mut:
	version_scheme int
	tab_writes     int
}

@[heap]
pub struct UpdateReportState {
pub mut:
	gcc_rpaths_fixed bool
	formulas         []UpdateReportFormula
	settings_writes  int
}

pub fn update_report_no_changes_message() string {
	return 'No changes to formulae.'
}

pub fn (mut state UpdateReportState) migrate_gcc_dependents_if_needed() {
	if state.gcc_rpaths_fixed {
		return
	}
	for mut formula in state.formulas {
		if !formula.core_tap || formula.unavailable {
			continue
		}
		has_runtime_gcc := formula.dependencies.any(it.name == 'gcc' && !it.build && !it.test)
		if !has_runtime_gcc {
			continue
		}
		formula.version_scheme = -1
		formula.tab_writes++
	}
	state.gcc_rpaths_fixed = true
	state.settings_writes++
}

fn update_report_state_value(state &UpdateReportState) ruby.Value {
	return ruby.structured_value('Homebrew::UpdateReportState', '', {
		'update_report_state_address': u64(voidptr(state)).str()
	})
}

fn update_report_state_from_value(value ruby.Value) &UpdateReportState {
	address := value.attributes['update_report_state_address'] or {
		panic('invalid update report state')
	}
	return unsafe { &UpdateReportState(voidptr(address.u64())) }
}

pub fn update_report_state_boundary(state &UpdateReportState) ruby.Value {
	return update_report_state_value(state)
}

// Ruby method `no_changes_message` at line 8.
pub fn ruby_update_report_l8_d1_no_changes_message(args ...ruby.Value) ruby.Value {
	_ = args
	return ruby.string_value(update_report_no_changes_message())
}

// Ruby method `migrate_gcc_dependents_if_needed` at line 13.
pub fn ruby_update_report_l13_d2_migrate_gcc_dependents_if_needed(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'update report state is required')
	}
	mut state := update_report_state_from_value(args[0])
	state.migrate_gcc_dependents_if_needed()
	return ruby.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module_function
// 6:
// 7:   sig { returns(String) }
// 8:   def no_changes_message
// 9:     "No changes to formulae."
// 10:   end
// 11:
// 12:   sig { void }
// 13:   def migrate_gcc_dependents_if_needed
// 14:     return if Settings.read("gcc-rpaths.fixed") == "true"
// 15:
// 16:     Formula.installed.each do |formula|
// 17:       next unless formula.tap&.core_tap?
// 18:
// 19:       recursive_runtime_dependencies = Dependency.expand(
// 20:         formula,
// 21:         cache_key: "update-report",
// 22:       ) do |_, dependency|
// 23:         next Dependable::PRUNE if dependency.build? || dependency.test?
// 24:       end
// 25:       next unless recursive_runtime_dependencies.map(&:name).include? "gcc"
// 26:
// 27:       keg = formula.installed_kegs.fetch(-1)
// 28:       tab = keg.tab
// 29:       # Force reinstallation upon `brew upgrade` to fix the bottle RPATH.
// 30:       tab.source["versions"]["version_scheme"] = -1
// 31:       tab.write
// 32:     rescue TapFormulaUnavailableError
// 33:       nil
// 34:     end
// 35:
// 36:     Settings.write "gcc-rpaths.fixed", true
// 37:   end
// 38: end
