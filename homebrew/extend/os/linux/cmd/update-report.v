module cmd

// Translated from Homebrew/brew `extend/os/linux/cmd/update-report.rb`.
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
