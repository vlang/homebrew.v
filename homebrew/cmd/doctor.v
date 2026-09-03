module cmd

import x.json2

// Translated from Homebrew/brew `cmd/doctor.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `run` at line 35.
pub fn ruby_doctor_l35_d1_run(checks []DoctorCheck, options DoctorOptions) DoctorResult {
	return run_doctor(checks, options)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "diagnostic"
// 6: require "diagnostic/finding"
// 7: require "cask/caskroom"
// 8: require "json"
// 9:
// 10: module Homebrew
// 11:   module Cmd
// 12:     class Doctor < AbstractCommand
// 13:       cmd_args do
// 14:         description <<~EOS
// 15:           Check your system for potential problems. Will exit with a non-zero status
// 16:           if any potential problems are found.
// 17:
// 18:           Please note that these warnings are just used to help the Homebrew maintainers
// 19:           with debugging if you file an issue. If everything you use Homebrew for
// 20:           is working fine: please don't worry or file an issue; just ignore this.
// 21:         EOS
// 22:         switch "--list-checks",
// 23:                description: "List all audit methods, which can be run individually " \
// 24:                             "if provided as arguments."
// 25:         switch "--json",
// 26:                description: "Print a JSON representation.",
// 27:                hidden:      true
// 28:         switch "-D", "--audit-debug",
// 29:                description: "Enable debugging and profiling of audit methods."
// 30:
// 31:         named_args :diagnostic_check
// 32:       end
// 33:
// 34:       sig { override.void }
// 35:       def run
// 36:         Homebrew.inject_dump_stats!(Diagnostic::Checks, /^check_*/) if args.audit_debug?
// 37:
// 38:         checks = Diagnostic::Checks.new(verbose: args.verbose?)
// 39:
// 40:         if args.list_checks?
// 41:           puts checks.all
// 42:           return
// 43:         end
// 44:
// 45:         if args.no_named?
// 46:           slow_checks = %w[
// 47:             check_for_broken_symlinks
// 48:             check_missing_deps
// 49:           ]
// 50:           methods = (checks.all - slow_checks) + slow_checks
// 51:           methods -= checks.cask_checks unless Cask::Caskroom.any_casks_installed?
// 52:         else
// 53:           methods = args.named
// 54:         end
// 55:
// 56:         finding_collection = []
// 57:         first_warning = T.let(true, T::Boolean)
// 58:         methods.each do |method|
// 59:           $stderr.puts Formatter.headline("Checking #{method}", color: :magenta) if args.debug?
// 60:           unless checks.respond_to?(method)
// 61:             ofail "No check available by the name: #{method}"
// 62:             next
// 63:           end
// 64:
// 65:           finding         = checks.public_send(method)
// 66:           method_findings = T.let(Array(finding).compact, T::Array[T.any(Diagnostic::Finding, String)])
// 67:           next if method_findings.empty?
// 68:
// 69:           finding_collection.concat(method_findings.compact)
// 70:           Homebrew.failed = true
// 71:           next if args.json?
// 72:
// 73:           if first_warning && !args.quiet?
// 74:             $stderr.puts <<~EOS
// 75:               #{Tty.bold}Please note that these warnings are just used to help the Homebrew maintainers
// 76:               with debugging if you file an issue. If everything you use Homebrew for is
// 77:               working fine: please don't worry or file an issue; just ignore this. Thanks!#{Tty.reset}
// 78:             EOS
// 79:           end
// 80:
// 81:           $stderr.puts
// 82:           opoo method_findings.each(&:to_s).join("\n")
// 83:           first_warning = false
// 84:         end
// 85:
// 86:         # TODO: Remove string filtering when all diagnostics are Finding objects
// 87:         finding_maps = finding_collection.grep_v(String).map(&:to_h)
// 88:         tier = (finding_maps.max_by { |f| f[:tier] } || {}).fetch(:tier, 1)
// 89:         if args.json?
// 90:           puts JSON.pretty_generate({ tier:, findings: finding_maps }).gsub(/\[\n\n\s*\]/, "[]")
// 91:
// 92:           return
// 93:         end
// 94:
// 95:         return if args.quiet?
// 96:
// 97:         if Homebrew.failed?
// 98:           puts Diagnostic::Finding.support_tier_message(tier:)
// 99:         else
// 100:           puts "Your system is ready to brew."
// 101:         end
// 102:       end
// 103:     end
// 104:   end
// 105: end
