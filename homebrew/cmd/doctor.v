module cmd

import x.json2

// Translated from Homebrew/brew `cmd/doctor.rb`.
pub const doctor_slow_checks = ['check_for_broken_symlinks', 'check_missing_deps']

pub struct DoctorFinding {
pub:
	message    string
	tier       int = 1
	structured bool = true
}

pub struct DoctorCheck {
pub:
	name     string
	cask     bool
	findings []DoctorFinding
}

pub struct DoctorOptions {
pub:
	named               []string
	list_checks         bool
	json                bool
	audit_debug         bool
	debug               bool
	quiet               bool
	verbose             bool
	any_casks_installed bool
}

pub struct DoctorResult {
pub:
	stdout         string
	stderr         string
	failed         bool
	tier           int = 1
	methods        []string
	findings       []DoctorFinding
	stats_injected bool
}

pub struct DoctorFormulaDependencyState {
pub:
	full_name            string
	missing_dependencies []string
}

pub struct DoctorCaskDependencyState {
pub:
	full_name        string
	runtime_casks    []string
	runtime_formulae []string
}

pub struct DoctorInstalledFormulaState {
pub:
	name       string
	trusted    bool
	load_error ?string
}

pub struct DoctorInstalledCaskState {
pub:
	token      string
	deprecated bool
	disabled   bool
	caveats    string
}

fn doctor_check_names(checks []DoctorCheck) []string {
	return checks.map(it.name)
}

pub fn doctor_ordered_methods(checks []DoctorCheck, options DoctorOptions) []string {
	if options.named.len > 0 {
		return options.named.clone()
	}
	all := doctor_check_names(checks)
	mut methods := all.filter(it !in doctor_slow_checks)
	for slow in doctor_slow_checks {
		if slow in all {
			methods << slow
		}
	}
	if !options.any_casks_installed {
		cask_checks := checks.filter(it.cask).map(it.name)
		methods = methods.filter(it !in cask_checks)
	}
	return methods
}

fn doctor_support_tier_message(tier int) string {
	return 'Your system is supported at Homebrew support tier ${tier}.'
}

fn doctor_json(findings []DoctorFinding, tier int) string {
	structured := findings.filter(it.structured)
	if structured.len == 0 {
		return '{\n  "tier": ${tier},\n  "findings": []\n}\n'
	}
	mut rendered := []string{}
	for finding in structured {
		rendered << '    {\n      "message": ${json2.encode(finding.message)},\n      "tier": ${finding.tier}\n    }'
	}
	return '{\n  "tier": ${tier},\n  "findings": [\n${rendered.join(',\n')}\n  ]\n}\n'
}

pub fn run_doctor(checks []DoctorCheck, options DoctorOptions) DoctorResult {
	all := doctor_check_names(checks)
	if options.list_checks {
		return DoctorResult{
			stdout: if all.len > 0 { '${all.join('\n')}\n' } else { '' }
			methods: all
			stats_injected: options.audit_debug
		}
	}
	methods := doctor_ordered_methods(checks, options)
	mut stderr_lines := []string{}
	mut findings := []DoctorFinding{}
	mut first_warning := true
	for method in methods {
		if options.debug {
			stderr_lines << 'Checking ${method}'
		}
		check := checks.filter(it.name == method)
		if check.len == 0 {
			stderr_lines << 'Error: No check available by the name: ${method}'
			continue
		}
		method_findings := check[0].findings.filter(it.message != '')
		if method_findings.len == 0 {
			continue
		}
		findings << method_findings
		if options.json {
			continue
		}
		if first_warning && !options.quiet {
			stderr_lines << "Please note that these warnings are just used to help the Homebrew maintainers\nwith debugging if you file an issue. If everything you use Homebrew for is\nworking fine: please don't worry or file an issue; just ignore this. Thanks!"
		}
		stderr_lines << ''
		stderr_lines << 'Warning: ${method_findings.map(it.message).join('\n')}'
		first_warning = false
	}
	mut tier := 1
	for finding in findings {
		if finding.structured && finding.tier > tier {
			tier = finding.tier
		}
	}
	failed := findings.len > 0
	mut stdout := ''
	if options.json {
		stdout = doctor_json(findings, tier)
	} else if !options.quiet {
		stdout = if failed {
			'${doctor_support_tier_message(tier)}\n'
		} else {
			'Your system is ready to brew.\n'
		}
	}
	return DoctorResult{
		stdout: stdout
		stderr: if stderr_lines.len > 0 { '${stderr_lines.join('\n')}\n' } else { '' }
		failed: failed
		tier: tier
		methods: methods
		findings: findings
		stats_injected: options.audit_debug
	}
}

pub fn doctor_missing_deps_finding(formulae []DoctorFormulaDependencyState,
	casks []DoctorCaskDependencyState) ?DoctorFinding {
	mut dependencies := []string{}
	for formula in formulae {
		for dependency in formula.missing_dependencies {
			if dependency != '' && dependency !in dependencies {
				dependencies << dependency
			}
		}
	}
	for cask in casks {
		mut runtime_dependencies := cask.runtime_casks.clone()
		runtime_dependencies << cask.runtime_formulae
		for dependency in runtime_dependencies {
			if dependency != '' && dependency !in dependencies {
				dependencies << dependency
			}
		}
	}
	if dependencies.len == 0 {
		return none
	}
	dependencies.sort()
	return DoctorFinding{
		message: 'Some installed formulae or casks are missing dependencies.\n\n  brew install ${dependencies.join(' ')}\n\nRun `brew missing` for more details.'
		tier: 2
	}
}

pub fn doctor_unreadable_installed_formula(formulae []DoctorInstalledFormulaState) ?DoctorFinding {
	mut errors := []string{}
	for formula in formulae {
		if !formula.trusted {
			continue
		}
		if message := formula.load_error {
			errors << '${formula.name}: ${message}'
		}
	}
	if errors.len == 0 {
		return none
	}
	return DoctorFinding{
		message: errors.join('\n')
		tier: 2
	}
}

pub fn doctor_cask_deprecated_disabled(casks []DoctorInstalledCaskState) []DoctorFinding {
	mut findings := []DoctorFinding{}
	for cask in casks {
		if cask.disabled {
			findings << DoctorFinding{
				message: 'Cask ${cask.token} is disabled.'
				tier: 2
			}
		} else if cask.deprecated {
			findings << DoctorFinding{
				message: 'Cask ${cask.token} is deprecated.'
			}
		}
	}
	return findings
}
