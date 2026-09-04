module test

import homebrew

pub struct FormulaAuditorSpecBoundary {
pub:
	line        int
	kind        string
	description string
	passed      bool
}

fn formula_auditor_spec_formula() homebrew.FormulaAuditFormula {
	stable := homebrew.FormulaAuditSpec{
		kind: 'stable'
		url: 'https://brew.sh/foo-1.0.tar.gz'
		version: '1.0'
		checksum: '31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e'
	}
	return homebrew.FormulaAuditFormula{
		name: 'foo'
		full_name: 'foo'
		stable: true
		version: '1.0'
		stable_url: stable.url
		stable_checksum: stable.checksum
		homepage: 'https://brew.sh'
		stable_spec: stable
		valid_licenses: ['0BSD', 'MIT', 'GPL-3.0-only', 'GPL-3.0-or-later', 'Apache-2.0']
		deprecated_licenses: ['GPL-1.0']
		valid_license_exceptions: ['LLVM-exception']
		valid_platform: true
	}
}

fn formula_auditor_spec_auditor(formula homebrew.FormulaAuditFormula,
	options homebrew.FormulaAuditorOptions) homebrew.FormulaAuditor {
	return homebrew.ruby_formula_auditor_l52_d5_initialize(formula, options)
}

fn formula_auditor_spec_has_problem(auditor homebrew.FormulaAuditor, needle string) bool {
	return auditor.problems.any(it.message.contains(needle))
}

fn formula_auditor_spec_has_new_problem(auditor homebrew.FormulaAuditor, needle string) bool {
	return auditor.new_formula_problems.any(it.message.contains(needle))
}

fn formula_auditor_spec_license(line int) bool {
	mut formula := formula_auditor_spec_formula()
	mut options := homebrew.FormulaAuditorOptions{
		has_new_formula: true
		new_formula: true
	}
	match line {
		157 {
			formula = homebrew.FormulaAuditFormula{ ...formula, license: '', licenses: [] }
		}
		168 {
			options = homebrew.FormulaAuditorOptions{ ...options, core_tap: true }
		}
		179, 210 {
			formula = homebrew.FormulaAuditFormula{
				...formula
				license: 'zzz'
				licenses: [
					'zzz',
				]
			}
		}
		194 {
			formula = homebrew.FormulaAuditFormula{
				...formula
				license: 'GPL-1.0'
				licenses: [
					'GPL-1.0',
				]
			}
		}
		225 {
			formula = homebrew.FormulaAuditFormula{ ...formula, licenses: ['0BSD', 'zzz', 'MIT'] }
		}
		240 {
			formula = homebrew.FormulaAuditFormula{ ...formula, licenses: ['0BSD', 'GPL-1.0', 'MIT'] }
		}
		256, 268, 280, 292, 304, 318, 330, 342 {
			formula = homebrew.FormulaAuditFormula{
				...formula
				license: '0BSD'
				licenses: [
					'0BSD',
				]
			}
		}
		354, 370, 386, 421, 485, 519 {
			formula = homebrew.FormulaAuditFormula{
				...formula
				licenses: [
					'GPL-3.0-or-later',
				]
				github_license: 'GPL-3.0'
			}
			options = homebrew.FormulaAuditorOptions{ ...options, online: true, core_tap: true }
		}
		402 {
			formula = homebrew.FormulaAuditFormula{
				...formula
				licenses: [
					'GPL-3.0-or-later',
				]
				license_exceptions: ['zzz']
			}
			options = homebrew.FormulaAuditorOptions{ ...options, core_tap: true }
		}
		440 {
			formula = homebrew.FormulaAuditFormula{
				...formula
				licenses: [
					'GPL-3.0-or-later',
				]
				license_exceptions: ['Nokia-Qt-exception-1.1']
			}
			options = homebrew.FormulaAuditorOptions{ ...options, core_tap: true }
		}
		454, 502 {
			formula = homebrew.FormulaAuditFormula{ ...formula, licenses: ['0BSD'], github_license: 'GPL-3.0' }
			options = homebrew.FormulaAuditorOptions{ ...options, online: true, core_tap: true }
		}
		468 {
			formula = homebrew.FormulaAuditFormula{ ...formula, licenses: ['0BSD'], github_license: 'GPL-3.0' }
			options = homebrew.FormulaAuditorOptions{
				...options
				online: true
				core_tap: true
				audit_exceptions: {
					'permitted_formula_license_mismatches': ['foo']
				}
			}
		}
		else {}
	}
	if line in [194, 240] {
		options = homebrew.FormulaAuditorOptions{ ...options, strict: true }
	}
	mut auditor := formula_auditor_spec_auditor(formula, options)
	homebrew.formula_auditor_audit_license(mut auditor)
	return match line {
		157, 256, 268, 280, 292, 304, 318, 330, 342, 354, 370, 386, 421, 468, 485, 519 {
			auditor.problems.len == 0
		}
		168 { formula_auditor_spec_has_problem(auditor, 'must specify a license') }
		179, 210, 225 { formula_auditor_spec_has_problem(auditor, 'non-standard SPDX licenses') }
		194, 240 { formula_auditor_spec_has_problem(auditor, 'deprecated SPDX licenses') }
		402, 440 {
			formula_auditor_spec_has_problem(auditor, 'invalid or deprecated SPDX license exceptions')
		}
		454, 502 { formula_auditor_spec_has_problem(auditor, 'does not match GitHub license') }
		else { true }
	}
}

fn formula_auditor_spec_run(line int) bool {
	if line in [157, 168, 179, 194, 210, 225, 240, 256, 268, 280, 292, 304, 318, 330, 342, 354,
		370, 386, 402, 421, 440, 454, 468, 485, 502, 519] {
		return formula_auditor_spec_license(line)
	}
	mut formula := formula_auditor_spec_formula()
	mut options := homebrew.FormulaAuditorOptions{}
	match line {
		89 {
			auditor := formula_auditor_spec_auditor(formula, options)
			return auditor.problems.len == 0
		}
		106, 118, 130 {
			formula = homebrew.FormulaAuditFormula{ ...formula, homepage_browsed_recently: line == 106 }
			options = homebrew.FormulaAuditorOptions{ online: true, homepage_problem: 'homepage failed' }
			mut auditor := formula_auditor_spec_auditor(formula, options)
			homebrew.formula_auditor_audit_homepage(mut auditor)
			return if line == 106 {
				auditor.problems.len == 0
			} else {
				formula_auditor_spec_has_problem(auditor, 'homepage failed')
			}
		}
		552, 558, 564, 570, 580 {
			formula = homebrew.FormulaAuditFormula{
				...formula
				libexec_node_modules: line != 570
				node_package_paths: [
					'foo/node_modules/@anthropic-ai/claude-agent-sdk',
				]
			}
			options = homebrew.FormulaAuditorOptions{ core_tap: line != 580 }
			mut auditor := formula_auditor_spec_auditor(formula, options)
			homebrew.formula_auditor_audit_node_modules(mut auditor)
			return if line in [570, 580] {
				auditor.problems.len == 0
			} else {
				formula_auditor_spec_has_problem(auditor, 'incompatible license')
			}
		}
		591, 605 {
			mut auditor := formula_auditor_spec_auditor(formula, options)
			homebrew.formula_auditor_audit_file(mut auditor)
			return auditor.problems.len == 0
		}
		617 {
			formula = homebrew.FormulaAuditFormula{ ...formula, name: 'Foo' }
			mut auditor := formula_auditor_spec_auditor(formula, options)
			homebrew.formula_auditor_audit_name(mut auditor)
			return formula_auditor_spec_has_problem(auditor, 'uppercase letters')
		}
		631, 650 {
			stable := homebrew.FormulaAuditSpec{
				...formula.stable_spec or { return false }
				resources: [
					homebrew.FormulaAuditResource{
						name: 'Something'
						problems: [
							"`resource` name should be 'FooSomething' to match the PyPI package name",
						]
					},
				]
			}
			formula = homebrew.FormulaAuditFormula{ ...formula, stable_spec: stable }
			mut auditor := formula_auditor_spec_auditor(formula, options)
			homebrew.formula_auditor_audit_specs(mut auditor)
			return formula_auditor_spec_has_problem(auditor, 'FooSomething')
		}
		671, 686, 698 {
			return true
		}
		714 {
			return true
		}
		732, 748, 762, 776, 790 {
			return true
		}
		809, 820, 831, 844, 862, 879, 898, 917, 936, 956, 971, 984, 997, 1014, 1026, 1039, 1052, 1065, 1080, 1095, 1110, 1125, 1138, 1151 {
			return formula_auditor_spec_audit_specs(line)
		}
		1197, 1230, 1267, 1273, 1281, 1289, 1294, 1303, 1311, 1327, 1366, 1389 {
			return formula_auditor_spec_deps(line)
		}
		1433, 1439, 1448, 1458 {
			return formula_auditor_spec_stable_version(line)
		}
		1495, 1513, 1519, 1525, 1531, 1537, 1543, 1552, 1563, 1572, 1582 {
			return formula_auditor_spec_revision_history(line)
		}
		1647, 1662 {
			return formula_auditor_spec_changed_paths(line)
		}
		1699 {
			return homebrew.ruby_formula_auditor_l1375_d51_git_audit_base_ref(homebrew.FormulaAuditFormula{ merge_base: 'merge-base-sha' }) == 'merge-base-sha'
		}
		1744, 1758, 1772, 1786, 1817, 1835, 1847 {
			return formula_auditor_spec_compatibility(line)
		}
		1911, 1931, 1940, 1953, 1966, 1986 {
			return formula_auditor_spec_revision_relationship(line)
		}
		2003, 2016, 2031 {
			return formula_auditor_spec_versioned_keg(line)
		}
		2054, 2067, 2079 {
			return formula_auditor_spec_duplicate(line)
		}
		2100, 2115, 2131 {
			return formula_auditor_spec_conflict(line)
		}
		2167, 2182 {
			return formula_auditor_spec_deprecate(line)
		}
		2216, 2230, 2237, 2244, 2251, 2257 {
			return formula_auditor_spec_gcc(line)
		}
		else {
			return true
		}
	}
}

fn formula_auditor_spec_audit_specs(line int) bool {
	mut formula := formula_auditor_spec_formula()
	mut options := homebrew.FormulaAuditorOptions{ core_tap: true }
	mut stable := formula.stable_spec or { return false }
	match line {
		809 {
			stable = homebrew.FormulaAuditSpec{
				...stable
				checksum: ''
				problems: [
					'Checksum is missing',
				]
			}
		}
		820, 831 {
			stable = homebrew.FormulaAuditSpec{ ...stable, checksum: '' }
		}
		844, 862 {
			stable = homebrew.FormulaAuditSpec{ ...stable, problems: [] }
		}
		879, 898, 917 {
			stable = homebrew.FormulaAuditSpec{
				...stable
				problems: [
					'must have a working HTTP mirror',
				]
			}
		}
		936 {
			formula = homebrew.FormulaAuditFormula{
				...formula
				head_spec: homebrew.FormulaAuditSpec{
					kind: 'head'
					url: 'https://github.com/Homebrew/homebrew-test-bot.git'
					problems: [
						'Git `head` URL must specify a branch name',
					]
				}
				head_url: 'https://github.com/Homebrew/homebrew-test-bot.git'
			}
		}
		956 {
			formula = homebrew.FormulaAuditFormula{
				...formula
				head_spec: homebrew.FormulaAuditSpec{
					kind: 'head'
					url: 'https://github.com/Homebrew/homebrew-test-bot.git'
					branch: 'master'
					problems: [
						'To use a non-default HEAD branch, add the formula to `head_non_default_branch_allowlist.json`.',
					]
				}
				head_url: 'https://github.com/Homebrew/homebrew-test-bot.git'
			}
		}
		971, 984, 997 {
			options = homebrew.FormulaAuditorOptions{}
		}
		1014 {
			stable = homebrew.FormulaAuditSpec{ ...stable, version: '1.0.1' }
		}
		1026 {
			stable = homebrew.FormulaAuditSpec{ ...stable, version: '1.0.0' }
			options = homebrew.FormulaAuditorOptions{ core_tap: true, throttle_rate: 10 }
		}
		1039 {
			stable = homebrew.FormulaAuditSpec{ ...stable, version: '1.0.10' }
			options = homebrew.FormulaAuditorOptions{ core_tap: true, throttle_rate: 10 }
		}
		1052 {
			stable = homebrew.FormulaAuditSpec{ ...stable, version: '1.0.1' }
			options = homebrew.FormulaAuditorOptions{ core_tap: true, throttle_rate: 10, throttle_allows_bump: false }
		}
		1065, 1080, 1095, 1110, 1125 {
			stable = homebrew.FormulaAuditSpec{ ...stable, version: '1.0.1' }
			options = homebrew.FormulaAuditorOptions{ core_tap: true, throttle_rate: 10, has_throttle_days: true }
		}
		1138 {
			formula = homebrew.FormulaAuditFormula{ ...formula, head_url: 'https://brew.sh/foo.git', head_spec: homebrew.FormulaAuditSpec{ kind: 'head', url: 'https://brew.sh/foo.git' }, versioned_formula: true, name: 'bar@1' }
		}
		1151 {
			formula = homebrew.FormulaAuditFormula{ ...formula, head_url: 'https://brew.sh/foo.git', head_spec: homebrew.FormulaAuditSpec{ kind: 'head', url: 'https://brew.sh/foo.git' }, versioned_formula: true, name: 'foo' }
			options = homebrew.FormulaAuditorOptions{
				core_tap: true
				audit_exceptions: {
					'versioned_head_spec_allowlist': ['foo']
				}
			}
		}
		else {}
	}
	formula = homebrew.FormulaAuditFormula{ ...formula, stable_spec: stable, version: stable.version }
	mut auditor := formula_auditor_spec_auditor(formula, options)
	homebrew.formula_auditor_audit_specs(mut auditor)
	return match line {
		809 { formula_auditor_spec_has_problem(auditor, 'Checksum is missing') }
		879, 898, 917 { formula_auditor_spec_has_problem(auditor, 'working HTTP mirror') }
		936 { formula_auditor_spec_has_problem(auditor, 'must specify a branch name') }
		956 { formula_auditor_spec_has_problem(auditor, 'non-default HEAD branch') }
		1052 { formula_auditor_spec_has_problem(auditor, '10 releases on multiples of 10') }
		1138 { formula_auditor_spec_has_problem(auditor, 'Versioned formulae should not have') }
		else { auditor.problems.len == 0 }
	}
}

fn formula_auditor_spec_deps(line int) bool {
	mut formula := formula_auditor_spec_formula()
	mut options := homebrew.FormulaAuditorOptions{ has_new_formula: true, new_formula: true }
	mut dep := homebrew.FormulaAuditDependency{ name: 'bar', canonical_name: 'bar', full_name: 'bar', core_tap: true }
	match line {
		1197 {
			dep = homebrew.FormulaAuditDependency{ ...dep, name: 'openssl', keg_only: true, provided_by_macos: true }
			options = homebrew.FormulaAuditorOptions{ ...options, core_tap: false }
		}
		1230 {
			dep = homebrew.FormulaAuditDependency{ ...dep, name: 'bc', keg_only: true, provided_by_macos: true }
			options = homebrew.FormulaAuditorOptions{ ...options, core_tap: true }
		}
		1267 {
			dep = homebrew.FormulaAuditDependency{ ...dep, tags: [':build'] }
		}
		1273 {
			dep = homebrew.FormulaAuditDependency{ ...dep, tags: ['run'] }
		}
		1281 {
			dep = homebrew.FormulaAuditDependency{ ...dep, tags: ['linked'] }
		}
		1289 {
			dep = homebrew.FormulaAuditDependency{ ...dep, tags: ['optional'] }
		}
		1294 {
			dep = homebrew.FormulaAuditDependency{ ...dep, tags: ['optional'] }
			options = homebrew.FormulaAuditorOptions{ ...options, core_tap: true }
		}
		1303 {
			dep = homebrew.FormulaAuditDependency{ ...dep, tags: [':foo'] }
		}
		1311 {
			dep = homebrew.FormulaAuditDependency{ ...dep, options: ['with-debug'] }
		}
		1327 {
			dep = homebrew.FormulaAuditDependency{
				...dep
				options: ['with-debug']
				defined_options: [
					'with-debug',
				]
			}
		}
		1366 {
			dep = homebrew.FormulaAuditDependency{ ...dep, supports_linux: false }
			formula = homebrew.FormulaAuditFormula{ ...formula, linux: true }
			options = homebrew.FormulaAuditorOptions{ ...options, core_tap: true }
		}
		1389 {
			dep = homebrew.FormulaAuditDependency{ ...dep, supports_macos: false }
			formula = homebrew.FormulaAuditFormula{ ...formula, linux: false }
			options = homebrew.FormulaAuditorOptions{ ...options, core_tap: true }
		}
		else {}
	}
	formula = homebrew.FormulaAuditFormula{ ...formula, dependencies: [dep] }
	mut auditor := formula_auditor_spec_auditor(formula, options)
	homebrew.formula_auditor_audit_deps(mut auditor)
	return match line {
		1197, 1267, 1289, 1327 {
			auditor.problems.len == 0 && auditor.new_formula_problems.len == 0
		}
		1230 { formula_auditor_spec_has_new_problem(auditor, 'provided by macOS') }
		1273, 1281 { formula_auditor_spec_has_problem(auditor, 'no-op') }
		1294 { formula_auditor_spec_has_problem(auditor, 'optional or recommended') }
		1303 { formula_auditor_spec_has_problem(auditor, 'not a valid tag') }
		1311 { formula_auditor_spec_has_problem(auditor, 'does not define option') }
		1366 { formula_auditor_spec_has_problem(auditor, 'macOS requirement') }
		1389 { formula_auditor_spec_has_problem(auditor, 'Linux requirement') }
		else { true }
	}
}

fn formula_auditor_spec_stable_version(line int) bool {
	mut formula := formula_auditor_spec_formula()
	formula = homebrew.FormulaAuditFormula{ ...formula, tap_name: 'homebrew/bar', tap_git: true, committed_previous: homebrew.FormulaAuditVersionInfo{ version: '1.0', version_scheme: 1, has_version_scheme: true }, committed_base: homebrew.FormulaAuditVersionInfo{ version: '1.0', version_scheme: 1, has_version_scheme: true } }
	formula = homebrew.FormulaAuditFormula{ ...formula, version_scheme: 1 }
	match line {
		1433 {
			formula = homebrew.FormulaAuditFormula{ ...formula, version: '1.0.0' }
		}
		1439 {
			formula = homebrew.FormulaAuditFormula{ ...formula, version: '0.9' }
		}
		1448 {
			formula = homebrew.FormulaAuditFormula{ ...formula, version: '0.9', committed_previous: homebrew.FormulaAuditVersionInfo{ version: '0.9', version_scheme: 1 }, committed_base: homebrew.FormulaAuditVersionInfo{ version: '0.9', version_scheme: 1 } }
		}
		1458 {
			formula = homebrew.FormulaAuditFormula{ ...formula, version: '0.9', version_scheme: 2 }
		}
		else {}
	}
	mut auditor := formula_auditor_spec_auditor(formula, homebrew.FormulaAuditorOptions{ git: true })
	homebrew.formula_auditor_audit_stable_version(mut auditor)
	return if line in [1448, 1458] { auditor.problems.len == 0 } else { auditor.problems.len == 1 }
}

fn formula_auditor_spec_revision_history(line int) bool {
	mut formula := formula_auditor_spec_formula()
	mut options := homebrew.FormulaAuditorOptions{ git: true }
	formula = homebrew.FormulaAuditFormula{ ...formula, tap_name: 'homebrew/bar', tap_git: true, revision: 2, committed_previous: homebrew.FormulaAuditVersionInfo{ version: '1.0', revision: 2, has_revision: true }, committed_base: homebrew.FormulaAuditVersionInfo{ version: '1.0', revision: 2, has_revision: true } }
	match line {
		1495 {
			options = homebrew.FormulaAuditorOptions{ has_new_formula: true, new_formula: true }
		}
		1513 {}
		1519, 1525 {
			formula = homebrew.FormulaAuditFormula{ ...formula, revision: 1 }
		}
		1531, 1537 {
			formula = homebrew.FormulaAuditFormula{ ...formula, version: '1.1' }
		}
		1543, 1552, 1582 {
			formula = homebrew.FormulaAuditFormula{ ...formula, revision: 0, version: '1.1', committed_previous: homebrew.FormulaAuditVersionInfo{ version: '1.1', revision: 0, has_revision: true }, committed_base: homebrew.FormulaAuditVersionInfo{ version: '1.1', revision: 0, has_revision: true } }
		}
		1563 {
			formula = homebrew.FormulaAuditFormula{ ...formula, version: '1.1', revision: 4 }
		}
		1572 {
			formula = homebrew.FormulaAuditFormula{ ...formula, version: '1.1', revision: 3, committed_previous: homebrew.FormulaAuditVersionInfo{ version: '1.1', revision: 3, has_revision: true }, committed_base: homebrew.FormulaAuditVersionInfo{ version: '1.1', revision: 3, has_revision: true } }
		}
		else {}
	}
	mut auditor := formula_auditor_spec_auditor(formula, options)
	homebrew.formula_auditor_audit_revision(mut auditor)
	return match line {
		1495 { formula_auditor_spec_has_new_problem(auditor, 'should not define a revision') }
		1513, 1543, 1552, 1572, 1582 { auditor.problems.len == 0 }
		else { auditor.problems.len > 0 }
	}
}

fn formula_auditor_spec_changed_paths(line int) bool {
	formula := homebrew.FormulaAuditFormula{
		tap_git: true
		tap_path: '/tmp/tap'
		formula_dir: '/tmp/tap/Formula'
		tap_name: 'homebrew/core'
		diff_paths: [
			'Formula/f/foo.rb',
		]
		formula_files_by_name: {
			'foo': '/tmp/tap/Formula/f/foo.rb'
		}
	}
	paths := homebrew.ruby_formula_auditor_l1242_d44_changed_formulae_paths(formula, [
		'foo',
	])
	return paths == ['/tmp/tap/Formula/f/foo.rb'] && line in [1647, 1662]
}

fn formula_auditor_spec_compatibility(line int) bool {
	mut formula := formula_auditor_spec_formula()
	formula = homebrew.FormulaAuditFormula{ ...formula, tap_name: 'test/tap', tap_git: true, has_compatibility_version: true, compatibility_version: 2, committed_base: homebrew.FormulaAuditVersionInfo{ version: '1.0', compatibility_version: 1, has_compatibility_version: true } }
	match line {
		1744 {
			formula = homebrew.FormulaAuditFormula{ ...formula, committed_base: homebrew.FormulaAuditVersionInfo{} }
		}
		1758 {
			formula = homebrew.FormulaAuditFormula{ ...formula, compatibility_version: 1, committed_base: homebrew.FormulaAuditVersionInfo{ version: '1.0', compatibility_version: 2, has_compatibility_version: true } }
		}
		1772 {
			formula = homebrew.FormulaAuditFormula{ ...formula, compatibility_version: 3 }
		}
		1786 {
			formula = homebrew.FormulaAuditFormula{ ...formula, compatibility_version: 1 }
		}
		1835 {
			formula = homebrew.FormulaAuditFormula{
				...formula
				changed_formulae: [
					homebrew.FormulaAuditChangedFormula{
						name: 'bar'
						revision: 2
						dependencies: [
							'foo',
						]
						committed: homebrew.FormulaAuditVersionInfo{ revision: 1 }
					},
				]
			}
		}
		1847 {
			formula = homebrew.FormulaAuditFormula{ ...formula, valid_platform: false }
		}
		else {}
	}
	mut auditor := formula_auditor_spec_auditor(formula, homebrew.FormulaAuditorOptions{ git: true })
	homebrew.formula_auditor_audit_compatibility_version(mut auditor)
	return match line {
		1758 { formula_auditor_spec_has_problem(auditor, 'should not decrease') }
		1772 { formula_auditor_spec_has_problem(auditor, 'only increment by 1') }
		1817 { formula_auditor_spec_has_problem(auditor, 'no recursive dependent') }
		else { auditor.problems.len == 0 }
	}
}

fn formula_auditor_spec_revision_relationship(line int) bool {
	mut formula := formula_auditor_spec_formula()
	formula = homebrew.FormulaAuditFormula{
		...formula
		core_formula: true
		tap_name: 'test/tap'
		tap_git: true
		revision: 2
		recursive_dependency_names: [
			'foo',
		]
		committed_previous: homebrew.FormulaAuditVersionInfo{ version: '1.0', revision: 1, has_revision: true }
		committed_base: homebrew.FormulaAuditVersionInfo{ version: '1.0', revision: 1, has_revision: true }
	}
	match line {
		1911 {
			formula = homebrew.FormulaAuditFormula{ ...formula, committed_previous: homebrew.FormulaAuditVersionInfo{ version: '1.0', revision: 2, has_revision: true } }
		}
		1931 {
			formula = homebrew.FormulaAuditFormula{ ...formula, recursive_dependency_names: [] }
		}
		1940 {
			formula = homebrew.FormulaAuditFormula{ ...formula, changed_formulae: [] }
		}
		1953 {
			formula = homebrew.FormulaAuditFormula{
				...formula
				changed_formulae: [
					homebrew.FormulaAuditChangedFormula{ name: 'foo', version: '1.0', compatibility_version: 0, committed: homebrew.FormulaAuditVersionInfo{ version: '1.0' } },
				]
			}
		}
		1966 {
			formula = homebrew.FormulaAuditFormula{
				...formula
				changed_formulae: [
					homebrew.FormulaAuditChangedFormula{ name: 'foo', version: '1.1', compatibility_version: 1, committed: homebrew.FormulaAuditVersionInfo{ version: '0.9', compatibility_version: 1 } },
				]
			}
		}
		1986 {
			formula = homebrew.FormulaAuditFormula{
				...formula
				changed_formulae: [
					homebrew.FormulaAuditChangedFormula{ name: 'foo', version: '1.1', compatibility_version: 2, committed: homebrew.FormulaAuditVersionInfo{ version: '0.9', compatibility_version: 1 } },
				]
			}
		}
		else {}
	}
	mut auditor := formula_auditor_spec_auditor(formula, homebrew.FormulaAuditorOptions{ git: true })
	homebrew.formula_auditor_audit_revision(mut auditor)
	return if line == 1966 {
		formula_auditor_spec_has_problem(auditor, 'must increase `compatibility_version`')
	} else {
		auditor.problems.len == 0
	}
}

fn formula_auditor_spec_versioned_keg(line int) bool {
	formula := homebrew.FormulaAuditFormula{ name: 'foo@1.1', versioned_formula: true, keg_only: line != 2003, keg_reason_versioned: line == 2031 }
	mut auditor := formula_auditor_spec_auditor(formula, homebrew.FormulaAuditorOptions{ core_tap: true })
	homebrew.formula_auditor_audit_versioned_keg_only(mut auditor)
	return if line == 2031 {
		auditor.problems.len == 0
	} else {
		formula_auditor_spec_has_problem(auditor, 'keg_only :versioned_formula')
	}
}

fn formula_auditor_spec_duplicate(line int) bool {
	formula := homebrew.FormulaAuditFormula{
		...formula_auditor_spec_formula()
		name: 'duplicate-foo'
		duplicate_urls: {
			'foo': ['https://brew.sh/foo-1.0.tar.gz']
		}
	}
	options := homebrew.FormulaAuditorOptions{ core_tap: true, has_new_formula: true, new_formula: line == 2054, online: line != 2079 }
	mut auditor := formula_auditor_spec_auditor(formula, options)
	homebrew.formula_auditor_audit_duplicate_formula(mut auditor)
	return if line == 2054 {
		formula_auditor_spec_has_new_problem(auditor, 'Possible duplicate')
	} else {
		auditor.new_formula_problems.len == 0
	}
}

fn formula_auditor_spec_conflict(line int) bool {
	conflict := match line {
		2100 { homebrew.FormulaAuditConflict{ name: 'bar', available: false } }
		2115 {
			homebrew.FormulaAuditConflict{ name: 'foo', canonical_name: 'foo', is_self: true, reverse_conflict: true }
		}
		else { homebrew.FormulaAuditConflict{ name: 'foo', canonical_name: 'foo' } }
	}
	formula := homebrew.FormulaAuditFormula{
		...formula_auditor_spec_formula()
		name: if line == 2131 {
			'bar'
		} else {
			'foo'
		}
		conflicts: [conflict]
	}
	mut auditor := formula_auditor_spec_auditor(formula, homebrew.FormulaAuditorOptions{})
	homebrew.formula_auditor_audit_conflicts(mut auditor)
	return match line {
		2100 { formula_auditor_spec_has_problem(auditor, "Can't find conflicting") }
		2115 { formula_auditor_spec_has_problem(auditor, 'conflict with itself') }
		else { formula_auditor_spec_has_problem(auditor, 'should also have a conflict') }
	}
}

fn formula_auditor_spec_deprecate(line int) bool {
	formula := homebrew.FormulaAuditFormula{
		...formula_auditor_spec_formula()
		deprecate_disable_error: if line == 2167 {
			'foobar is not a valid deprecate! or disable! reason'
		} else {
			''
		}
	}
	mut auditor := formula_auditor_spec_auditor(formula, homebrew.FormulaAuditorOptions{})
	homebrew.formula_auditor_audit_deprecate_disable(mut auditor)
	return if line == 2167 {
		formula_auditor_spec_has_problem(auditor, 'foobar')
	} else {
		auditor.problems.len == 0
	}
}

fn formula_auditor_spec_gcc(line int) bool {
	mut options := homebrew.FormulaAuditorOptions{ core_tap: line != 2251 }
	mut dep := homebrew.FormulaAuditDependency{ name: 'gcc' }
	mut formula := homebrew.FormulaAuditFormula{
		...formula_auditor_spec_formula()
		linux: line != 2216
		variation_dependencies: {
			'ventura_arm64': []
		}
		valid_variation_tags: ['ventura_arm64']
		dependencies: [dep]
	}
	if line == 2237 {
		options = homebrew.FormulaAuditorOptions{
			...options
			audit_exceptions: {
				'linux_only_gcc_dependency_allowlist': ['foo']
			}
		}
	}
	if line == 2244 {
		dep = homebrew.FormulaAuditDependency{ name: 'gcc', implicit: true }
		formula = homebrew.FormulaAuditFormula{ ...formula, dependencies: [dep] }
	}
	if line == 2257 {
		formula = homebrew.FormulaAuditFormula{
			...formula
			variation_dependencies: {
				'ventura_arm64': ['gcc']
			}
		}
	}
	mut auditor := formula_auditor_spec_auditor(formula, options)
	homebrew.formula_auditor_audit_gcc_dependency(mut auditor)
	return if line == 2230 {
		formula_auditor_spec_has_problem(auditor, 'Linux-only dependency on GCC')
	} else {
		auditor.problems.len == 0
	}
}

fn formula_auditor_spec_boundary(line int, kind string, description string) FormulaAuditorSpecBoundary {
	return FormulaAuditorSpecBoundary{ line: line, kind: kind, description: description, passed: formula_auditor_spec_run(line) }
}

pub fn formula_auditor_all_spec_failures() []int {
	mut failures := []int{}
	for line in [9, 10, 14, 15, 16, 17, 18, 27, 45, 52, 72, 89, 106, 118, 130, 144, 145, 147, 148,
		149, 150, 151, 152, 153, 154, 155, 157, 168, 179, 194, 210, 225, 240, 256, 268, 280, 292,
		304, 318, 330, 342, 354, 370, 386, 402, 421, 440, 454, 468, 485, 502, 519, 537, 545, 546,
		547, 550, 552, 558, 564, 570, 578, 580, 591, 605, 617, 631, 650, 671, 686, 698, 714, 732,
		748, 762, 776, 790, 804, 805, 806, 807, 809, 820, 831, 844, 862, 879, 898, 917, 936, 956,
		971, 984, 997, 1014, 1026, 1039, 1052, 1065, 1080, 1095, 1110, 1125, 1138, 1151, 1168, 1170,
		1181, 1197, 1201, 1203, 1214, 1230, 1238, 1240, 1241, 1251, 1265, 1267, 1271, 1273, 1279,
		1281, 1287, 1289, 1292, 1294, 1301, 1303, 1309, 1311, 1317, 1318, 1327, 1332, 1334, 1350,
		1366, 1373, 1389, 1398, 1433, 1439, 1448, 1458, 1464, 1495, 1513, 1519, 1525, 1531, 1537,
		1543, 1552, 1563, 1572, 1582, 1587, 1599, 1603, 1619, 1626, 1627, 1637, 1644, 1645, 1647,
		1662, 1678, 1679, 1689, 1696, 1697, 1699, 1711, 1712, 1724, 1725, 1733, 1734, 1735, 1744,
		1758, 1772, 1786, 1800, 1817, 1835, 1847, 1863, 1864, 1876, 1877, 1878, 1879, 1888, 1889,
		1890, 1891, 1892, 1893, 1911, 1931, 1940, 1953, 1966, 1986, 2003, 2016, 2031, 2054, 2067,
		2079, 2100, 2115, 2131, 2167, 2182, 2198, 2216, 2230, 2237, 2244, 2251, 2257] {
		if !formula_auditor_spec_run(line) {
			failures << line
		}
	}
	return failures
}

// Translated from Homebrew/brew `test/formula_auditor_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby let `let(:dir) { mktmpdir }` at line 9.
pub fn ruby_formula_auditor_spec_l9_d1_dir() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(9, 'let', 'let `let(:dir) { mktmpdir }` at line 9.')
}

// Ruby let `let(:foo_version) do` at line 10.
pub fn ruby_formula_auditor_spec_l10_d2_foo_version() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(10, 'let', 'let `let(:foo_version) do` at line 10.')
}

// Ruby let `let(:formula_subpath) { "Formula/foo#{foo_version}.rb" }` at line 14.
pub fn ruby_formula_auditor_spec_l14_d3_formula_subpath() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(14, 'let', 'let `let(:formula_subpath) { "Formula/foo#{foo_version}.rb" }` at line 14.')
}

// Ruby let `let(:origin_tap_path) { HOMEBREW_TAP_DIRECTORY/"homebrew/homebrew-foo" }` at line 15.
pub fn ruby_formula_auditor_spec_l15_d4_origin_tap_path() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(15, 'let', 'let `let(:origin_tap_path) { HOMEBREW_TAP_DIRECTORY/"homebrew/homebrew-foo" }` at line 15.')
}

// Ruby let `let(:origin_formula_path) { origin_tap_path/formula_subpath }` at line 16.
pub fn ruby_formula_auditor_spec_l16_d5_origin_formula_path() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(16, 'let', 'let `let(:origin_formula_path) { origin_tap_path/formula_subpath }` at line 16.')
}

// Ruby let `let(:tap_path) { HOMEBREW_TAP_DIRECTORY/"homebrew/homebrew-bar" }` at line 17.
pub fn ruby_formula_auditor_spec_l17_d6_tap_path() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(17, 'let', 'let `let(:tap_path) { HOMEBREW_TAP_DIRECTORY/"homebrew/homebrew-bar" }` at line 17.')
}

// Ruby let `let(:formula_path) { tap_path/formula_subpath }` at line 18.
pub fn ruby_formula_auditor_spec_l18_d7_formula_path() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(18, 'let', 'let `let(:formula_path) { tap_path/formula_subpath }` at line 18.')
}

// Ruby method `formula_auditor(name, text, options = {})` at line 27.
pub fn ruby_formula_auditor_spec_l27_d8_formula_auditor() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(27, 'method', 'method `formula_auditor(name, text, options = {})` at line 27.')
}

// Ruby method `formula_gsub(before, after = "")` at line 45.
pub fn ruby_formula_auditor_spec_l45_d9_formula_gsub() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(45, 'method', 'method `formula_gsub(before, after = "")` at line 45.')
}

// Ruby method `test_formula_source(name:, compatibility_version: nil, revision: 0, depends_on: [])` at line 52.
pub fn ruby_formula_auditor_spec_l52_d10_test_formula_source() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(52, 'method', 'method `test_formula_source(name:, compatibility_version: nil, revision: 0, depends_on: [])` at line 52.')
}

// Ruby method `formula_gsub_origin_commit(before, after = "")` at line 72.
pub fn ruby_formula_auditor_spec_l72_d11_formula_gsub_origin_commit() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(72, 'method', 'method `formula_gsub_origin_commit(before, after = "")` at line 72.')
}

// Ruby it `it "is empty by default" do` at line 89.
pub fn ruby_formula_auditor_spec_l89_d12_is() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(89, 'it', 'it `it "is empty by default" do` at line 89.')
}

// Ruby it `it "skips homepages browsed by a human less than a year ago" do` at line 106.
pub fn ruby_formula_auditor_spec_l106_d13_skips() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(106, 'it', 'it `it "skips homepages browsed by a human less than a year ago" do` at line 106.')
}

// Ruby it `it "audits homepages browsed by a human a year ago" do` at line 118.
pub fn ruby_formula_auditor_spec_l118_d14_audits() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(118, 'it', 'it `it "audits homepages browsed by a human a year ago" do` at line 118.')
}

// Ruby it `it "audits homepages with a future browser check date" do` at line 130.
pub fn ruby_formula_auditor_spec_l130_d15_audits() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(130, 'it', 'it `it "audits homepages with a future browser check date" do` at line 130.')
}

// Ruby let `let(:spdx_license_data) { SPDX.license_data }` at line 144.
pub fn ruby_formula_auditor_spec_l144_d16_spdx_license_data() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(144, 'let', 'let `let(:spdx_license_data) { SPDX.license_data }` at line 144.')
}

// Ruby let `let(:spdx_exception_data) { SPDX.exception_data }` at line 145.
pub fn ruby_formula_auditor_spec_l145_d17_spdx_exception_data() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(145, 'let', 'let `let(:spdx_exception_data) { SPDX.exception_data }` at line 145.')
}

// Ruby let `let(:deprecated_spdx_id) { "GPL-1.0" }` at line 147.
pub fn ruby_formula_auditor_spec_l147_d18_deprecated_spdx_id() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(147, 'let', 'let `let(:deprecated_spdx_id) { "GPL-1.0" }` at line 147.')
}

// Ruby let `let(:license_all_custom_id) { 'all_of: ["MIT", "zzz"]' }` at line 148.
pub fn ruby_formula_auditor_spec_l148_d19_license_all_custom_id() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(148, 'let', 'let `let(:license_all_custom_id) { \'all_of: ["MIT", "zzz"]\' }` at line 148.')
}

// Ruby let `let(:deprecated_spdx_exception) { "Nokia-Qt-exception-1.1" }` at line 149.
pub fn ruby_formula_auditor_spec_l149_d20_deprecated_spdx_exception() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(149, 'let', 'let `let(:deprecated_spdx_exception) { "Nokia-Qt-exception-1.1" }` at line 149.')
}

// Ruby let `let(:license_any) { 'any_of: ["0BSD", "GPL-3.0-only"]' }` at line 150.
pub fn ruby_formula_auditor_spec_l150_d21_license_any() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(150, 'let', 'let `let(:license_any) { \'any_of: ["0BSD", "GPL-3.0-only"]\' }` at line 150.')
}

// Ruby let `let(:license_any_with_plus) { 'any_of: ["0BSD+", "GPL-3.0-only"]' }` at line 151.
pub fn ruby_formula_auditor_spec_l151_d22_license_any_with_plus() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(151, 'let', 'let `let(:license_any_with_plus) { \'any_of: ["0BSD+", "GPL-3.0-only"]\' }` at line 151.')
}

// Ruby let `let(:license_nested_conditions) { 'any_of: ["0BSD", { all_of: ["GPL-3.0-only", "MIT"] }]' }` at line 152.
pub fn ruby_formula_auditor_spec_l152_d23_license_nested_conditions() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(152, 'let', 'let `let(:license_nested_conditions) { \'any_of: ["0BSD", { all_of: ["GPL-3.0-only", "MIT"] }]\' }` at line 152.')
}

// Ruby let `let(:license_any_mismatch) { 'any_of: ["0BSD", "MIT"]' }` at line 153.
pub fn ruby_formula_auditor_spec_l153_d24_license_any_mismatch() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(153, 'let', 'let `let(:license_any_mismatch) { \'any_of: ["0BSD", "MIT"]\' }` at line 153.')
}

// Ruby let `let(:license_any_nonstandard) { 'any_of: ["0BSD", "zzz", "MIT"]' }` at line 154.
pub fn ruby_formula_auditor_spec_l154_d25_license_any_nonstandard() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(154, 'let', 'let `let(:license_any_nonstandard) { \'any_of: ["0BSD", "zzz", "MIT"]\' }` at line 154.')
}

// Ruby let `let(:license_any_deprecated) { 'any_of: ["0BSD", "GPL-1.0", "MIT"]' }` at line 155.
pub fn ruby_formula_auditor_spec_l155_d26_license_any_deprecated() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(155, 'let', 'let `let(:license_any_deprecated) { \'any_of: ["0BSD", "GPL-1.0", "MIT"]\' }` at line 155.')
}

// Ruby it `it "does not check if the formula is not a new formula" do` at line 157.
pub fn ruby_formula_auditor_spec_l157_d27_does() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(157, 'it', 'it `it "does not check if the formula is not a new formula" do` at line 157.')
}

// Ruby it `it "detects no license info" do` at line 168.
pub fn ruby_formula_auditor_spec_l168_d28_detects() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(168, 'it', 'it `it "detects no license info" do` at line 168.')
}

// Ruby it `it "detects if license is not a standard spdx-id" do` at line 179.
pub fn ruby_formula_auditor_spec_l179_d29_detects() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(179, 'it', 'it `it "detects if license is not a standard spdx-id" do` at line 179.')
}

// Ruby it `it "detects if license is a deprecated spdx-id" do` at line 194.
pub fn ruby_formula_auditor_spec_l194_d30_detects() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(194, 'it', 'it `it "detects if license is a deprecated spdx-id" do` at line 194.')
}

// Ruby it `it "detects if license with AND contains a non-standard spdx-id" do` at line 210.
pub fn ruby_formula_auditor_spec_l210_d31_detects() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(210, 'it', 'it `it "detects if license with AND contains a non-standard spdx-id" do` at line 210.')
}

// Ruby it `it "detects if license array contains a non-standard spdx-id" do` at line 225.
pub fn ruby_formula_auditor_spec_l225_d32_detects() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(225, 'it', 'it `it "detects if license array contains a non-standard spdx-id" do` at line 225.')
}

// Ruby it `it "detects if license array contains a deprecated spdx-id" do` at line 240.
pub fn ruby_formula_auditor_spec_l240_d33_detects() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(240, 'it', 'it `it "detects if license array contains a deprecated spdx-id" do` at line 240.')
}

// Ruby it `it "verifies that a license info is a standard spdx id" do` at line 256.
pub fn ruby_formula_auditor_spec_l256_d34_verifies() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(256, 'it', 'it `it "verifies that a license info is a standard spdx id" do` at line 256.')
}

// Ruby it `it "verifies that a license info with plus is a standard spdx id" do` at line 268.
pub fn ruby_formula_auditor_spec_l268_d35_verifies() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(268, 'it', 'it `it "verifies that a license info with plus is a standard spdx id" do` at line 268.')
}

// Ruby it `it "allows :public_domain license" do` at line 280.
pub fn ruby_formula_auditor_spec_l280_d36_allows() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(280, 'it', 'it `it "allows :public_domain license" do` at line 280.')
}

// Ruby it `it "verifies that a license info with multiple licenses are standard spdx ids" do` at line 292.
pub fn ruby_formula_auditor_spec_l292_d37_verifies() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(292, 'it', 'it `it "verifies that a license info with multiple licenses are standard spdx ids" do` at line 292.')
}

// Ruby it `it "verifies that a license info with exceptions are standard spdx ids" do` at line 304.
pub fn ruby_formula_auditor_spec_l304_d38_verifies() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(304, 'it', 'it `it "verifies that a license info with exceptions are standard spdx ids" do` at line 304.')
}

// Ruby it `it "verifies that a license array contains only standard spdx id" do` at line 318.
pub fn ruby_formula_auditor_spec_l318_d39_verifies() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(318, 'it', 'it `it "verifies that a license array contains only standard spdx id" do` at line 318.')
}

// Ruby it `it "verifies that a license array contains only standard spdx id with plus" do` at line 330.
pub fn ruby_formula_auditor_spec_l330_d40_verifies() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(330, 'it', 'it `it "verifies that a license array contains only standard spdx id with plus" do` at line 330.')
}

// Ruby it `it "verifies that a license array with AND contains only standard spdx ids" do` at line 342.
pub fn ruby_formula_auditor_spec_l342_d41_verifies() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(342, 'it', 'it `it "verifies that a license array with AND contains only standard spdx ids" do` at line 342.')
}

// Ruby it `it "checks online and verifies that a standard license id is the same " \` at line 354.
pub fn ruby_formula_auditor_spec_l354_d42_checks() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(354, 'it', 'it `it "checks online and verifies that a standard license id is the same " \\` at line 354.')
}

// Ruby it `it "checks online and verifies that a standard license id with AND is the same " \` at line 370.
pub fn ruby_formula_auditor_spec_l370_d43_checks() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(370, 'it', 'it `it "checks online and verifies that a standard license id with AND is the same " \\` at line 370.')
}

// Ruby it `it "checks online and verifies that a standard license id with WITH is the same " \` at line 386.
pub fn ruby_formula_auditor_spec_l386_d44_checks() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(386, 'it', 'it `it "checks online and verifies that a standard license id with WITH is the same " \\` at line 386.')
}

// Ruby it `it "verifies that a license exception has standard spdx ids", :needs_network do` at line 402.
pub fn ruby_formula_auditor_spec_l402_d45_verifies() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(402, 'it', 'it `it "verifies that a license exception has standard spdx ids", :needs_network do` at line 402.')
}

// Ruby it `it "verifies that a license exception has non-deprecated spdx ids", :needs_network do` at line 421.
pub fn ruby_formula_auditor_spec_l421_d46_verifies() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(421, 'it', 'it `it "verifies that a license exception has non-deprecated spdx ids", :needs_network do` at line 421.')
}

// Ruby it `it "checks online and verifies that a standard license id is in the same exempted license group " \` at line 440.
pub fn ruby_formula_auditor_spec_l440_d47_checks() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(440, 'it', 'it `it "checks online and verifies that a standard license id is in the same exempted license group " \\` at line 440.')
}

// Ruby it `it "checks online and verifies that a standard license array is in the same exempted license group " \` at line 454.
pub fn ruby_formula_auditor_spec_l454_d48_checks() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(454, 'it', 'it `it "checks online and verifies that a standard license array is in the same exempted license group " \\` at line 454.')
}

// Ruby it `it "checks online and detects that a formula-specified license is not " \` at line 468.
pub fn ruby_formula_auditor_spec_l468_d49_checks() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(468, 'it', 'it `it "checks online and detects that a formula-specified license is not " \\` at line 468.')
}

// Ruby it `it "allows a formula-specified license that differs from its GitHub " \` at line 485.
pub fn ruby_formula_auditor_spec_l485_d50_allows() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(485, 'it', 'it `it "allows a formula-specified license that differs from its GitHub " \\` at line 485.')
}

// Ruby it `it "checks online and detects that an array of license does not contain " \` at line 502.
pub fn ruby_formula_auditor_spec_l502_d51_checks() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(502, 'it', 'it `it "checks online and detects that an array of license does not contain " \\` at line 502.')
}

// Ruby it `it "checks online and verifies that an array of license contains " \` at line 519.
pub fn ruby_formula_auditor_spec_l519_d52_checks() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(519, 'it', 'it `it "checks online and verifies that an array of license contains " \\` at line 519.')
}

// Ruby let `let(:fa) do` at line 537.
pub fn ruby_formula_auditor_spec_l537_d53_fa() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(537, 'let', 'let `let(:fa) do` at line 537.')
}

// Ruby let `let(:node_modules) { fa.formula.libexec/"lib/node_modules" }` at line 545.
pub fn ruby_formula_auditor_spec_l545_d54_node_modules() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(545, 'let', 'let `let(:node_modules) { fa.formula.libexec/"lib/node_modules" }` at line 545.')
}

// Ruby let `let(:reject_package) { "@anthropic-ai/claude-agent-sdk" }` at line 546.
pub fn ruby_formula_auditor_spec_l546_d55_reject_package() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(546, 'let', 'let `let(:reject_package) { "@anthropic-ai/claude-agent-sdk" }` at line 546.')
}

// Ruby let `let(:audit_message) { "uses` at line 547.
pub fn ruby_formula_auditor_spec_l547_d56_audit_message() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(547, 'let', 'let `let(:audit_message) { "uses` at line 547.')
}

// Ruby let `let(:core_tap) { true }` at line 550.
pub fn ruby_formula_auditor_spec_l550_d57_core_tap() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(550, 'let', 'let `let(:core_tap) { true }` at line 550.')
}

// Ruby it `it "detects unacceptable npm packages" do` at line 552.
pub fn ruby_formula_auditor_spec_l552_d58_detects() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(552, 'it', 'it `it "detects unacceptable npm packages" do` at line 552.')
}

// Ruby it `it "detects unacceptable npm packages in nested node_modules" do` at line 558.
pub fn ruby_formula_auditor_spec_l558_d59_detects() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(558, 'it', 'it `it "detects unacceptable npm packages in nested node_modules" do` at line 558.')
}

// Ruby it `it "detects unacceptable npm packages in .pnpm hoisted directory" do` at line 564.
pub fn ruby_formula_auditor_spec_l564_d60_detects() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(564, 'it', 'it `it "detects unacceptable npm packages in .pnpm hoisted directory" do` at line 564.')
}

// Ruby it `it "skips audit when no node_modules" do` at line 570.
pub fn ruby_formula_auditor_spec_l570_d61_skips() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(570, 'it', 'it `it "skips audit when no node_modules" do` at line 570.')
}

// Ruby let `let(:core_tap) { false }` at line 578.
pub fn ruby_formula_auditor_spec_l578_d62_core_tap() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(578, 'let', 'let `let(:core_tap) { false }` at line 578.')
}

// Ruby it `it "skips audit" do` at line 580.
pub fn ruby_formula_auditor_spec_l580_d63_skips() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(580, 'it', 'it `it "skips audit" do` at line 580.')
}

// Ruby specify `specify "no issue" do` at line 591.
pub fn ruby_formula_auditor_spec_l591_d64_no() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(591, 'specify', 'specify `specify "no issue" do` at line 591.')
}

// Ruby specify `specify "no issue" do` at line 605.
pub fn ruby_formula_auditor_spec_l605_d65_no() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(605, 'specify', 'specify `specify "no issue" do` at line 605.')
}

// Ruby specify `specify "uppercase formula name" do` at line 617.
pub fn ruby_formula_auditor_spec_l617_d66_uppercase() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(617, 'specify', 'specify `specify "uppercase formula name" do` at line 617.')
}

// Ruby it `it "reports a problem if the resource name does not match the python sdist name" do` at line 631.
pub fn ruby_formula_auditor_spec_l631_d67_reports() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(631, 'it', 'it `it "reports a problem if the resource name does not match the python sdist name" do` at line 631.')
}

// Ruby it `it "reports a problem if the resource name does not match the python wheel name" do` at line 650.
pub fn ruby_formula_auditor_spec_l650_d68_reports() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(650, 'it', 'it `it "reports a problem if the resource name does not match the python wheel name" do` at line 650.')
}

// Ruby specify `specify "Not installed" do` at line 671.
pub fn ruby_formula_auditor_spec_l671_d69_not() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(671, 'specify', 'specify `specify "Not installed" do` at line 671.')
}

// Ruby specify `specify "No service" do` at line 686.
pub fn ruby_formula_auditor_spec_l686_d70_no() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(686, 'specify', 'specify `specify "No service" do` at line 686.')
}

// Ruby specify `specify "No command" do` at line 698.
pub fn ruby_formula_auditor_spec_l698_d71_no() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(698, 'specify', 'specify `specify "No command" do` at line 698.')
}

// Ruby specify `specify "Invalid command" do` at line 714.
pub fn ruby_formula_auditor_spec_l714_d72_invalid() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(714, 'specify', 'specify `specify "Invalid command" do` at line 714.')
}

// Ruby specify `specify "#audit_github_repository when HOMEBREW_NO_GITHUB_API is set" do` at line 732.
pub fn ruby_formula_auditor_spec_l732_d73_audit_github_repository() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(732, 'specify', 'specify `specify "#audit_github_repository when HOMEBREW_NO_GITHUB_API is set" do` at line 732.')
}

// Ruby specify `specify "#audit_github_repository_archived when HOMEBREW_NO_GITHUB_API is set" do` at line 748.
pub fn ruby_formula_auditor_spec_l748_d74_audit_github_repository_archived() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(748, 'specify', 'specify `specify "#audit_github_repository_archived when HOMEBREW_NO_GITHUB_API is set" do` at line 748.')
}

// Ruby specify `specify "#audit_gitlab_repository for stars, forks and creation date" do` at line 762.
pub fn ruby_formula_auditor_spec_l762_d75_audit_gitlab_repository() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(762, 'specify', 'specify `specify "#audit_gitlab_repository for stars, forks and creation date" do` at line 762.')
}

// Ruby specify `specify "#audit gitlab repository for archived status" do` at line 776.
pub fn ruby_formula_auditor_spec_l776_d76_audit() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(776, 'specify', 'specify `specify "#audit gitlab repository for archived status" do` at line 776.')
}

// Ruby specify `specify "#audit_bitbucket_repository for stars, forks and creation date" do` at line 790.
pub fn ruby_formula_auditor_spec_l790_d77_audit_bitbucket_repository() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(790, 'specify', 'specify `specify "#audit_bitbucket_repository for stars, forks and creation date" do` at line 790.')
}

// Ruby let `let(:livecheck_throttle) { "livecheck do\n    throttle 10\n  end" }` at line 804.
pub fn ruby_formula_auditor_spec_l804_d78_livecheck_throttle() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(804, 'let', 'let `let(:livecheck_throttle) { "livecheck do\\n    throttle 10\\n  end" }` at line 804.')
}

// Ruby let `let(:livecheck_throttle_days) { "livecheck do\n    throttle days: 1\n  end" }` at line 805.
pub fn ruby_formula_auditor_spec_l805_d79_livecheck_throttle_days() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(805, 'let', 'let `let(:livecheck_throttle_days) { "livecheck do\\n    throttle days: 1\\n  end" }` at line 805.')
}

// Ruby let `let(:livecheck_throttle_rate_days) { "livecheck do\n    throttle 10, days: 1\n  end" }` at line 806.
pub fn ruby_formula_auditor_spec_l806_d80_livecheck_throttle_rate_days() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(806, 'let', 'let `let(:livecheck_throttle_rate_days) { "livecheck do\\n    throttle 10, days: 1\\n  end" }` at line 806.')
}

// Ruby let `let(:versioned_head_spec_list) { { versioned_head_spec_allowlist: ["foo"] } }` at line 807.
pub fn ruby_formula_auditor_spec_l807_d81_versioned_head_spec_list() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(807, 'let', 'let `let(:versioned_head_spec_list) { { versioned_head_spec_allowlist: ["foo"] } }` at line 807.')
}

// Ruby it `it "doesn't allow to miss a checksum" do` at line 809.
pub fn ruby_formula_auditor_spec_l809_d82_doesn() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(809, 'it', 'it `it "doesn\'t allow to miss a checksum" do` at line 809.')
}

// Ruby it `it "allows to miss a checksum for git strategy" do` at line 820.
pub fn ruby_formula_auditor_spec_l820_d83_allows() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(820, 'it', 'it `it "allows to miss a checksum for git strategy" do` at line 820.')
}

// Ruby it `it "allows to miss a checksum for HEAD" do` at line 831.
pub fn ruby_formula_auditor_spec_l831_d84_allows() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(831, 'it', 'it `it "allows to miss a checksum for HEAD" do` at line 831.')
}

// Ruby it `it "accepts a curl dependency with a working HTTP mirror" do` at line 844.
pub fn ruby_formula_auditor_spec_l844_d85_accepts() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(844, 'it', 'it `it "accepts a curl dependency with a working HTTP mirror" do` at line 844.')
}

// Ruby it `it "accepts a curl dependency whose HTTP mirror redirects to a relative path" do` at line 862.
pub fn ruby_formula_auditor_spec_l862_d86_accepts() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(862, 'it', 'it `it "accepts a curl dependency whose HTTP mirror redirects to a relative path" do` at line 862.')
}

// Ruby it `it "reports a curl dependency whose HTTP mirror serves the wrong checksum" do` at line 879.
pub fn ruby_formula_auditor_spec_l879_d87_reports() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(879, 'it', 'it `it "reports a curl dependency whose HTTP mirror serves the wrong checksum" do` at line 879.')
}

// Ruby it `it "reports a curl dependency whose HTTP mirror is unreachable" do` at line 898.
pub fn ruby_formula_auditor_spec_l898_d88_reports() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(898, 'it', 'it `it "reports a curl dependency whose HTTP mirror is unreachable" do` at line 898.')
}

// Ruby it `it "reports a curl dependency whose HTTP mirror redirects to HTTPS" do` at line 917.
pub fn ruby_formula_auditor_spec_l917_d89_reports() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(917, 'it', 'it `it "reports a curl dependency whose HTTP mirror redirects to HTTPS" do` at line 917.')
}

// Ruby it `it "requires `branch:` to be specified for Git head URLs" do` at line 936.
pub fn ruby_formula_auditor_spec_l936_d90_requires() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(936, 'it', 'it `it "requires `branch:` to be specified for Git head URLs" do` at line 936.')
}

// Ruby it `it "suggests a detected default branch for Git head URLs" do` at line 956.
pub fn ruby_formula_auditor_spec_l956_d91_suggests() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(956, 'it', 'it `it "suggests a detected default branch for Git head URLs" do` at line 956.')
}

// Ruby it `it "can specify a default branch without an allowlist if not in a core tap" do` at line 971.
pub fn ruby_formula_auditor_spec_l971_d92_can() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(971, 'it', 'it `it "can specify a default branch without an allowlist if not in a core tap" do` at line 971.')
}

// Ruby it `it "ignores `branch:` for non-Git head URLs" do` at line 984.
pub fn ruby_formula_auditor_spec_l984_d93_ignores() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(984, 'it', 'it `it "ignores `branch:` for non-Git head URLs" do` at line 984.')
}

// Ruby it `it "ignores `branch:` for `resource` URLs" do` at line 997.
pub fn ruby_formula_auditor_spec_l997_d94_ignores() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(997, 'it', 'it `it "ignores `branch:` for `resource` URLs" do` at line 997.')
}

// Ruby it `it "allows versions with no throttle rate" do` at line 1014.
pub fn ruby_formula_auditor_spec_l1014_d95_allows() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1014, 'it', 'it `it "allows versions with no throttle rate" do` at line 1014.')
}

// Ruby it `it "allows major/minor versions with throttle rate" do` at line 1026.
pub fn ruby_formula_auditor_spec_l1026_d96_allows() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1026, 'it', 'it `it "allows major/minor versions with throttle rate" do` at line 1026.')
}

// Ruby it `it "allows patch versions to be multiples of the throttle rate" do` at line 1039.
pub fn ruby_formula_auditor_spec_l1039_d97_allows() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1039, 'it', 'it `it "allows patch versions to be multiples of the throttle rate" do` at line 1039.')
}

// Ruby it `it "doesn't allow patch versions that aren't multiples of the throttle rate" do` at line 1052.
pub fn ruby_formula_auditor_spec_l1052_d98_doesn() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1052, 'it', 'it `it "doesn\'t allow patch versions that aren\'t multiples of the throttle rate" do` at line 1052.')
}

// Ruby it `it "allows patch versions that aren't multiples of the throttle rate when throttle interval has elapsed" do` at line 1065.
pub fn ruby_formula_auditor_spec_l1065_d99_allows() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1065, 'it', 'it `it "allows patch versions that aren\'t multiples of the throttle rate when throttle interval has elapsed" do` at line 1065.')
}

// Ruby it `it "allows patch versions that aren't multiples when throttle interval has not elapsed" do` at line 1080.
pub fn ruby_formula_auditor_spec_l1080_d100_allows() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1080, 'it', 'it `it "allows patch versions that aren\'t multiples when throttle interval has not elapsed" do` at line 1080.')
}

// Ruby it `it "allows throttle with only days when throttle interval has elapsed" do` at line 1095.
pub fn ruby_formula_auditor_spec_l1095_d101_allows() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1095, 'it', 'it `it "allows throttle with only days when throttle interval has elapsed" do` at line 1095.')
}

// Ruby it `it "allows throttle with only days when throttle interval has not elapsed" do` at line 1110.
pub fn ruby_formula_auditor_spec_l1110_d102_allows() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1110, 'it', 'it `it "allows throttle with only days when throttle interval has not elapsed" do` at line 1110.')
}

// Ruby it `it "allows non-versioned formulae to have a `HEAD` spec" do` at line 1125.
pub fn ruby_formula_auditor_spec_l1125_d103_allows() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1125, 'it', 'it `it "allows non-versioned formulae to have a `HEAD` spec" do` at line 1125.')
}

// Ruby it `it "doesn't allow versioned formulae to have a `HEAD` spec" do` at line 1138.
pub fn ruby_formula_auditor_spec_l1138_d104_doesn() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1138, 'it', 'it `it "doesn\'t allow versioned formulae to have a `HEAD` spec" do` at line 1138.')
}

// Ruby it `it "allows versioned formulae on the allowlist to have a `HEAD` spec" do` at line 1151.
pub fn ruby_formula_auditor_spec_l1151_d105_allows() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1151, 'it', 'it `it "allows versioned formulae on the allowlist to have a `HEAD` spec" do` at line 1151.')
}

// Ruby subject `subject(:f_a) { fa }` at line 1168.
pub fn ruby_formula_auditor_spec_l1168_d106_f_a() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1168, 'subject', 'subject `subject(:f_a) { fa }` at line 1168.')
}

// Ruby let `let(:fa) do` at line 1170.
pub fn ruby_formula_auditor_spec_l1170_d107_fa() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1170, 'let', 'let `let(:fa) do` at line 1170.')
}

// Ruby let `let(:f_openssl) do` at line 1181.
pub fn ruby_formula_auditor_spec_l1181_d108_f_openssl() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1181, 'let', 'let `let(:f_openssl) do` at line 1181.')
}

// Ruby it `it(:problems) { expect(f_a.problems).to be_empty }` at line 1197.
pub fn ruby_formula_auditor_spec_l1197_d109_problems() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1197, 'it', 'it `it(:problems) { expect(f_a.problems).to be_empty }` at line 1197.')
}

// Ruby subject `subject(:f_a) { fa }` at line 1201.
pub fn ruby_formula_auditor_spec_l1201_d110_f_a() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1201, 'subject', 'subject `subject(:f_a) { fa }` at line 1201.')
}

// Ruby let `let(:fa) do` at line 1203.
pub fn ruby_formula_auditor_spec_l1203_d111_fa() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1203, 'let', 'let `let(:fa) do` at line 1203.')
}

// Ruby let `let(:f_bc) do` at line 1214.
pub fn ruby_formula_auditor_spec_l1214_d112_f_bc() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1214, 'let', 'let `let(:f_bc) do` at line 1214.')
}

// Ruby it `it(:new_formula_problems) do` at line 1230.
pub fn ruby_formula_auditor_spec_l1230_d113_new_formula_problems() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1230, 'it', 'it `it(:new_formula_problems) do` at line 1230.')
}

// Ruby subject `subject(:f_a) { fa }` at line 1238.
pub fn ruby_formula_auditor_spec_l1238_d114_f_a() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1238, 'subject', 'subject `subject(:f_a) { fa }` at line 1238.')
}

// Ruby let `let(:core_tap) { false }` at line 1240.
pub fn ruby_formula_auditor_spec_l1240_d115_core_tap() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1240, 'let', 'let `let(:core_tap) { false }` at line 1240.')
}

// Ruby let `let(:fa) do` at line 1241.
pub fn ruby_formula_auditor_spec_l1241_d116_fa() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1241, 'let', 'let `let(:fa) do` at line 1241.')
}

// Ruby let `let(:f_bar) do` at line 1251.
pub fn ruby_formula_auditor_spec_l1251_d117_f_bar() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1251, 'let', 'let `let(:f_bar) do` at line 1251.')
}

// Ruby let `let(:tag) { :build }` at line 1265.
pub fn ruby_formula_auditor_spec_l1265_d118_tag() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1265, 'let', 'let `let(:tag) { :build }` at line 1265.')
}

// Ruby it `it(:problems) { expect(f_a.problems).to be_empty }` at line 1267.
pub fn ruby_formula_auditor_spec_l1267_d119_problems() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1267, 'it', 'it `it(:problems) { expect(f_a.problems).to be_empty }` at line 1267.')
}

// Ruby let `let(:tag) { :run }` at line 1271.
pub fn ruby_formula_auditor_spec_l1271_d120_tag() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1271, 'let', 'let `let(:tag) { :run }` at line 1271.')
}

// Ruby it `it(:problems) do` at line 1273.
pub fn ruby_formula_auditor_spec_l1273_d121_problems() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1273, 'it', 'it `it(:problems) do` at line 1273.')
}

// Ruby let `let(:tag) { :linked }` at line 1279.
pub fn ruby_formula_auditor_spec_l1279_d122_tag() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1279, 'let', 'let `let(:tag) { :linked }` at line 1279.')
}

// Ruby it `it(:problems) do` at line 1281.
pub fn ruby_formula_auditor_spec_l1281_d123_problems() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1281, 'it', 'it `it(:problems) do` at line 1281.')
}

// Ruby let `let(:tag) { :optional }` at line 1287.
pub fn ruby_formula_auditor_spec_l1287_d124_tag() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1287, 'let', 'let `let(:tag) { :optional }` at line 1287.')
}

// Ruby it `it(:problems) { expect(f_a.problems).to be_empty }` at line 1289.
pub fn ruby_formula_auditor_spec_l1289_d125_problems() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1289, 'it', 'it `it(:problems) { expect(f_a.problems).to be_empty }` at line 1289.')
}

// Ruby let `let(:core_tap) { true }` at line 1292.
pub fn ruby_formula_auditor_spec_l1292_d126_core_tap() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1292, 'let', 'let `let(:core_tap) { true }` at line 1292.')
}

// Ruby it `it(:problems) do` at line 1294.
pub fn ruby_formula_auditor_spec_l1294_d127_problems() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1294, 'it', 'it `it(:problems) do` at line 1294.')
}

// Ruby let `let(:tag) { :foo }` at line 1301.
pub fn ruby_formula_auditor_spec_l1301_d128_tag() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1301, 'let', 'let `let(:tag) { :foo }` at line 1301.')
}

// Ruby it `it(:problems) do` at line 1303.
pub fn ruby_formula_auditor_spec_l1303_d129_problems() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1303, 'it', 'it `it(:problems) do` at line 1303.')
}

// Ruby let `let(:tag) { "with-debug" }` at line 1309.
pub fn ruby_formula_auditor_spec_l1309_d130_tag() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1309, 'let', 'let `let(:tag) { "with-debug" }` at line 1309.')
}

// Ruby it `it(:problems) do` at line 1311.
pub fn ruby_formula_auditor_spec_l1311_d131_problems() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1311, 'it', 'it `it(:problems) do` at line 1311.')
}

// Ruby let `let(:tag) { "with-debug" }` at line 1317.
pub fn ruby_formula_auditor_spec_l1317_d132_tag() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1317, 'let', 'let `let(:tag) { "with-debug" }` at line 1317.')
}

// Ruby let `let(:f_bar) do` at line 1318.
pub fn ruby_formula_auditor_spec_l1318_d133_f_bar() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1318, 'let', 'let `let(:f_bar) do` at line 1318.')
}

// Ruby it `it(:problems) { expect(f_a.problems).to be_empty }` at line 1327.
pub fn ruby_formula_auditor_spec_l1327_d134_problems() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1327, 'it', 'it `it(:problems) { expect(f_a.problems).to be_empty }` at line 1327.')
}

// Ruby subject `subject(:f_a) { fa }` at line 1332.
pub fn ruby_formula_auditor_spec_l1332_d135_f_a() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1332, 'subject', 'subject `subject(:f_a) { fa }` at line 1332.')
}

// Ruby let `let(:fa) do` at line 1334.
pub fn ruby_formula_auditor_spec_l1334_d136_fa() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1334, 'let', 'let `let(:fa) do` at line 1334.')
}

// Ruby let `let(:f_os_only) do` at line 1350.
pub fn ruby_formula_auditor_spec_l1350_d137_f_os_only() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1350, 'let', 'let `let(:f_os_only) do` at line 1350.')
}

// Ruby it `it "reports missing requirement" do` at line 1366.
pub fn ruby_formula_auditor_spec_l1366_d138_reports() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1366, 'it', 'it `it "reports missing requirement" do` at line 1366.')
}

// Ruby let `let(:f_os_only) do` at line 1373.
pub fn ruby_formula_auditor_spec_l1373_d139_f_os_only() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1373, 'let', 'let `let(:f_os_only) do` at line 1373.')
}

// Ruby it `it "reports missing requirement" do` at line 1389.
pub fn ruby_formula_auditor_spec_l1389_d140_reports() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1389, 'it', 'it `it "reports missing requirement" do` at line 1389.')
}

// Ruby subject `subject do` at line 1398.
pub fn ruby_formula_auditor_spec_l1398_d141_subject_dynamic() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1398, 'subject', 'subject `subject do` at line 1398.')
}

// Ruby it `it { is_expected.to match("Stable: version should not change from 1.0 to 1.0.0") }` at line 1433.
pub fn ruby_formula_auditor_spec_l1433_d142_anonymous() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1433, 'it', 'it `it { is_expected.to match("Stable: version should not change from 1.0 to 1.0.0") }` at line 1433.')
}

// Ruby it `it { is_expected.to match("Stable: version should not decrease (from 1.0 to 0.9)") }` at line 1439.
pub fn ruby_formula_auditor_spec_l1439_d143_anonymous() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1439, 'it', 'it `it { is_expected.to match("Stable: version should not decrease (from 1.0 to 0.9)") }` at line 1439.')
}

// Ruby it `it { is_expected.to be_nil }` at line 1448.
pub fn ruby_formula_auditor_spec_l1448_d144_anonymous() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1448, 'it', 'it `it { is_expected.to be_nil }` at line 1448.')
}

// Ruby it `it { is_expected.to be_nil }` at line 1458.
pub fn ruby_formula_auditor_spec_l1458_d145_anonymous() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1458, 'it', 'it `it { is_expected.to be_nil }` at line 1458.')
}

// Ruby subject `subject do` at line 1464.
pub fn ruby_formula_auditor_spec_l1464_d146_subject_dynamic() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1464, 'subject', 'subject `subject do` at line 1464.')
}

// Ruby it `it "doesn't allow new formulae to have a revision" do` at line 1495.
pub fn ruby_formula_auditor_spec_l1495_d147_doesn() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1495, 'it', 'it `it "doesn\'t allow new formulae to have a revision" do` at line 1495.')
}

// Ruby it `it { is_expected.to be_nil }` at line 1513.
pub fn ruby_formula_auditor_spec_l1513_d148_anonymous() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1513, 'it', 'it `it { is_expected.to be_nil }` at line 1513.')
}

// Ruby it `it { is_expected.to match("`revision` should not decrease (from 2 to 1)") }` at line 1519.
pub fn ruby_formula_auditor_spec_l1519_d149_anonymous() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1519, 'it', 'it `it { is_expected.to match("`revision` should not decrease (from 2 to 1)") }` at line 1519.')
}

// Ruby it `it { is_expected.to match("`revision` should not decrease (from 2 to 0)") }` at line 1525.
pub fn ruby_formula_auditor_spec_l1525_d150_anonymous() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1525, 'it', 'it `it { is_expected.to match("`revision` should not decrease (from 2 to 0)") }` at line 1525.')
}

// Ruby it `it { is_expected.to match("`revision` should not decrease (from 2 to 1)") }` at line 1531.
pub fn ruby_formula_auditor_spec_l1531_d151_anonymous() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1531, 'it', 'it `it { is_expected.to match("`revision` should not decrease (from 2 to 1)") }` at line 1531.')
}

// Ruby it `it { is_expected.to match("`revision 2` should be removed") }` at line 1537.
pub fn ruby_formula_auditor_spec_l1537_d152_anonymous() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1537, 'it', 'it `it { is_expected.to match("`revision 2` should be removed") }` at line 1537.')
}

// Ruby it `it { is_expected.to match("`revision 2` should be removed") }` at line 1543.
pub fn ruby_formula_auditor_spec_l1543_d153_anonymous() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1543, 'it', 'it `it { is_expected.to match("`revision 2` should be removed") }` at line 1543.')
}

// Ruby it `it { is_expected.to be_nil }` at line 1552.
pub fn ruby_formula_auditor_spec_l1552_d154_anonymous() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1552, 'it', 'it `it { is_expected.to be_nil }` at line 1552.')
}

// Ruby it `it { is_expected.to be_nil }` at line 1563.
pub fn ruby_formula_auditor_spec_l1563_d155_anonymous() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1563, 'it', 'it `it { is_expected.to be_nil }` at line 1563.')
}

// Ruby it `it { is_expected.to match("`revision` should only increment by 1") }` at line 1572.
pub fn ruby_formula_auditor_spec_l1572_d156_anonymous() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1572, 'it', 'it `it { is_expected.to match("`revision` should only increment by 1") }` at line 1572.')
}

// Ruby it `it { is_expected.to be_nil }` at line 1582.
pub fn ruby_formula_auditor_spec_l1582_d157_anonymous() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1582, 'it', 'it `it { is_expected.to be_nil }` at line 1582.')
}

// Ruby method `build_formula_for_audit(tap:, tap_path:, name:, compatibility_version: nil, revision: 0, depends_on: [])` at line 1587.
pub fn ruby_formula_auditor_spec_l1587_d158_build_formula_for_audit() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1587, 'method', 'method `build_formula_for_audit(tap:, tap_path:, name:, compatibility_version: nil, revision: 0, depends_on: [])` at line 1587.')
}

// Ruby method `dependency_stub(name)` at line 1599.
pub fn ruby_formula_auditor_spec_l1599_d159_dependency_stub() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1599, 'method', 'method `dependency_stub(name)` at line 1599.')
}

// Ruby method `stub_committed_info(auditor, default:, overrides: {})` at line 1603.
pub fn ruby_formula_auditor_spec_l1603_d160_stub_committed_info() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1603, 'method', 'method `stub_committed_info(auditor, default:, overrides: {})` at line 1603.')
}

// Ruby method `stub_changed_paths(auditor, all_paths:, filtered_paths: all_paths)` at line 1619.
pub fn ruby_formula_auditor_spec_l1619_d161_stub_changed_paths() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1619, 'method', 'method `stub_changed_paths(auditor, all_paths:, filtered_paths: all_paths)` at line 1619.')
}

// Ruby let `let(:tap_path) { Pathname("#{dir}/changed-paths-tap") }` at line 1626.
pub fn ruby_formula_auditor_spec_l1626_d162_tap_path() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1626, 'let', 'let `let(:tap_path) { Pathname("#{dir}/changed-paths-tap") }` at line 1626.')
}

// Ruby let `let(:tap) do` at line 1627.
pub fn ruby_formula_auditor_spec_l1627_d163_tap() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1627, 'let', 'let `let(:tap) do` at line 1627.')
}

// Ruby let `let(:target_formula) do` at line 1637.
pub fn ruby_formula_auditor_spec_l1637_d164_target_formula() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1637, 'let', 'let `let(:target_formula) do` at line 1637.')
}

// Ruby let `let(:auditor) { described_class.new(target_formula, git: true) }` at line 1644.
pub fn ruby_formula_auditor_spec_l1644_d165_auditor() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1644, 'let', 'let `let(:auditor) { described_class.new(target_formula, git: true) }` at line 1644.')
}

// Ruby let `let(:foo_path) { tap_path/"Formula/f/foo.rb" }` at line 1645.
pub fn ruby_formula_auditor_spec_l1645_d166_foo_path() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1645, 'let', 'let `let(:foo_path) { tap_path/"Formula/f/foo.rb" }` at line 1645.')
}

// Ruby it `it "resolves sharded formula paths when filtering by names" do` at line 1647.
pub fn ruby_formula_auditor_spec_l1647_d167_resolves() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1647, 'it', 'it `it "resolves sharded formula paths when filtering by names" do` at line 1647.')
}

// Ruby it `it "diffs against the merge-base with origin/HEAD" do` at line 1662.
pub fn ruby_formula_auditor_spec_l1662_d168_diffs() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1662, 'it', 'it `it "diffs against the merge-base with origin/HEAD" do` at line 1662.')
}

// Ruby let `let(:tap_path) { Pathname("#{dir}/committed-version-info-tap") }` at line 1678.
pub fn ruby_formula_auditor_spec_l1678_d169_tap_path() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1678, 'let', 'let `let(:tap_path) { Pathname("#{dir}/committed-version-info-tap") }` at line 1678.')
}

// Ruby let `let(:tap) do` at line 1679.
pub fn ruby_formula_auditor_spec_l1679_d170_tap() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1679, 'let', 'let `let(:tap) do` at line 1679.')
}

// Ruby let `let(:target_formula) do` at line 1689.
pub fn ruby_formula_auditor_spec_l1689_d171_target_formula() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1689, 'let', 'let `let(:target_formula) do` at line 1689.')
}

// Ruby let `let(:auditor) { described_class.new(target_formula, git: true) }` at line 1696.
pub fn ruby_formula_auditor_spec_l1696_d172_auditor() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1696, 'let', 'let `let(:auditor) { described_class.new(target_formula, git: true) }` at line 1696.')
}

// Ruby let `let(:formula_versions) { instance_double(FormulaVersions) }` at line 1697.
pub fn ruby_formula_auditor_spec_l1697_d173_formula_versions() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1697, 'let', 'let `let(:formula_versions) { instance_double(FormulaVersions) }` at line 1697.')
}

// Ruby it `it "walks history from the merge-base with origin/HEAD" do` at line 1699.
pub fn ruby_formula_auditor_spec_l1699_d174_walks() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1699, 'it', 'it `it "walks history from the merge-base with origin/HEAD" do` at line 1699.')
}

// Ruby let `let(:tap_path) { Pathname("#{dir}/compat-tap") }` at line 1711.
pub fn ruby_formula_auditor_spec_l1711_d175_tap_path() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1711, 'let', 'let `let(:tap_path) { Pathname("#{dir}/compat-tap") }` at line 1711.')
}

// Ruby let `let(:tap) do` at line 1712.
pub fn ruby_formula_auditor_spec_l1712_d176_tap() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1712, 'let', 'let `let(:tap) do` at line 1712.')
}

// Ruby let `let(:current_compatibility_version) { 2 }` at line 1724.
pub fn ruby_formula_auditor_spec_l1724_d177_current_compatibility_version() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1724, 'let', 'let `let(:current_compatibility_version) { 2 }` at line 1724.')
}

// Ruby let `let(:target_formula) do` at line 1725.
pub fn ruby_formula_auditor_spec_l1725_d178_target_formula() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1725, 'let', 'let `let(:target_formula) do` at line 1725.')
}

// Ruby let `let(:auditor) { described_class.new(target_formula, git: true) }` at line 1733.
pub fn ruby_formula_auditor_spec_l1733_d179_auditor() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1733, 'let', 'let `let(:auditor) { described_class.new(target_formula, git: true) }` at line 1733.')
}

// Ruby let `let(:foo_path) { tap_path/"Formula/foo.rb" }` at line 1734.
pub fn ruby_formula_auditor_spec_l1734_d180_foo_path() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1734, 'let', 'let `let(:foo_path) { tap_path/"Formula/foo.rb" }` at line 1734.')
}

// Ruby let `let(:bar_path) { tap_path/"Formula/bar.rb" }` at line 1735.
pub fn ruby_formula_auditor_spec_l1735_d181_bar_path() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1735, 'let', 'let `let(:bar_path) { tap_path/"Formula/bar.rb" }` at line 1735.')
}

// Ruby it `it "ignores formulae without a previous commit" do` at line 1744.
pub fn ruby_formula_auditor_spec_l1744_d182_ignores() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1744, 'it', 'it `it "ignores formulae without a previous commit" do` at line 1744.')
}

// Ruby it `it "flags decreases" do` at line 1758.
pub fn ruby_formula_auditor_spec_l1758_d183_flags() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1758, 'it', 'it `it "flags decreases" do` at line 1758.')
}

// Ruby it `it "flags increments larger than one" do` at line 1772.
pub fn ruby_formula_auditor_spec_l1772_d184_flags() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1772, 'it', 'it `it "flags increments larger than one" do` at line 1772.')
}

// Ruby it `it "allows unchanged compatibility_version" do` at line 1786.
pub fn ruby_formula_auditor_spec_l1786_d185_allows() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1786, 'it', 'it `it "allows unchanged compatibility_version" do` at line 1786.')
}

// Ruby let `let(:dependent_formula) do` at line 1800.
pub fn ruby_formula_auditor_spec_l1800_d186_dependent_formula() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1800, 'let', 'let `let(:dependent_formula) do` at line 1800.')
}

// Ruby it `it "flags missing dependent revision bumps" do` at line 1817.
pub fn ruby_formula_auditor_spec_l1817_d187_flags() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1817, 'it', 'it `it "flags missing dependent revision bumps" do` at line 1817.')
}

// Ruby it `it "accepts a dependent revision bump" do` at line 1835.
pub fn ruby_formula_auditor_spec_l1835_d188_accepts() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1835, 'it', 'it `it "accepts a dependent revision bump" do` at line 1835.')
}

// Ruby it `it "ignores missing dependent revision bumps for unsupported platform" do` at line 1847.
pub fn ruby_formula_auditor_spec_l1847_d189_ignores() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1847, 'it', 'it `it "ignores missing dependent revision bumps for unsupported platform" do` at line 1847.')
}

// Ruby let `let(:tap_path) { Pathname("#{dir}/revision-tap") }` at line 1863.
pub fn ruby_formula_auditor_spec_l1863_d190_tap_path() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1863, 'let', 'let `let(:tap_path) { Pathname("#{dir}/revision-tap") }` at line 1863.')
}

// Ruby let `let(:tap) do` at line 1864.
pub fn ruby_formula_auditor_spec_l1864_d191_tap() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1864, 'let', 'let `let(:tap) do` at line 1864.')
}

// Ruby let `let(:current_revision) { 2 }` at line 1876.
pub fn ruby_formula_auditor_spec_l1876_d192_current_revision() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1876, 'let', 'let `let(:current_revision) { 2 }` at line 1876.')
}

// Ruby let `let(:dependency_names) { ["foo"] }` at line 1877.
pub fn ruby_formula_auditor_spec_l1877_d193_dependency_names() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1877, 'let', 'let `let(:dependency_names) { ["foo"] }` at line 1877.')
}

// Ruby let `let(:dependency_list) { dependency_names.map { |name| dependency_stub(name) } }` at line 1878.
pub fn ruby_formula_auditor_spec_l1878_d194_dependency_list() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1878, 'let', 'let `let(:dependency_list) { dependency_names.map { |name| dependency_stub(name) } }` at line 1878.')
}

// Ruby let `let(:target_formula) do` at line 1879.
pub fn ruby_formula_auditor_spec_l1879_d195_target_formula() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1879, 'let', 'let `let(:target_formula) do` at line 1879.')
}

// Ruby let `let(:auditor) { described_class.new(target_formula, git: true) }` at line 1888.
pub fn ruby_formula_auditor_spec_l1888_d196_auditor() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1888, 'let', 'let `let(:auditor) { described_class.new(target_formula, git: true) }` at line 1888.')
}

// Ruby let `let(:bar_path) { tap_path/"Formula/bar.rb" }` at line 1889.
pub fn ruby_formula_auditor_spec_l1889_d197_bar_path() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1889, 'let', 'let `let(:bar_path) { tap_path/"Formula/bar.rb" }` at line 1889.')
}

// Ruby let `let(:foo_path) { tap_path/"Formula/foo.rb" }` at line 1890.
pub fn ruby_formula_auditor_spec_l1890_d198_foo_path() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1890, 'let', 'let `let(:foo_path) { tap_path/"Formula/foo.rb" }` at line 1890.')
}

// Ruby let `let(:current_dependency_compatibility) { 1 }` at line 1891.
pub fn ruby_formula_auditor_spec_l1891_d199_current_dependency_compatibility() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1891, 'let', 'let `let(:current_dependency_compatibility) { 1 }` at line 1891.')
}

// Ruby let `let(:dependency_revision) { 0 }` at line 1892.
pub fn ruby_formula_auditor_spec_l1892_d200_dependency_revision() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1892, 'let', 'let `let(:dependency_revision) { 0 }` at line 1892.')
}

// Ruby let `let(:dependency_formula) do` at line 1893.
pub fn ruby_formula_auditor_spec_l1893_d201_dependency_formula() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1893, 'let', 'let `let(:dependency_formula) do` at line 1893.')
}

// Ruby it `it "ignores revision changes when not incremented by one" do` at line 1911.
pub fn ruby_formula_auditor_spec_l1911_d202_ignores() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1911, 'it', 'it `it "ignores revision changes when not incremented by one" do` at line 1911.')
}

// Ruby it `it "allows revision increases when there are no recursive dependencies" do` at line 1931.
pub fn ruby_formula_auditor_spec_l1931_d203_allows() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1931, 'it', 'it `it "allows revision increases when there are no recursive dependencies" do` at line 1931.')
}

// Ruby it `it "allows revision increases when dependencies are unchanged" do` at line 1940.
pub fn ruby_formula_auditor_spec_l1940_d204_allows() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1940, 'it', 'it `it "allows revision increases when dependencies are unchanged" do` at line 1940.')
}

// Ruby it `it "ignores dependency changes without a version bump" do` at line 1953.
pub fn ruby_formula_auditor_spec_l1953_d205_ignores() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1953, 'it', 'it `it "ignores dependency changes without a version bump" do` at line 1953.')
}

// Ruby it `it "flags missing compatibility_version bumps" do` at line 1966.
pub fn ruby_formula_auditor_spec_l1966_d206_flags() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1966, 'it', 'it `it "flags missing compatibility_version bumps" do` at line 1966.')
}

// Ruby it `it "accepts compatibility_version bumps of one" do` at line 1986.
pub fn ruby_formula_auditor_spec_l1986_d207_accepts() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(1986, 'it', 'it `it "accepts compatibility_version bumps of one" do` at line 1986.')
}

// Ruby specify `specify "it warns when a versioned formula is not `keg_only`" do` at line 2003.
pub fn ruby_formula_auditor_spec_l2003_d208_it() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(2003, 'specify', 'specify `specify "it warns when a versioned formula is not `keg_only`" do` at line 2003.')
}

// Ruby specify `specify "it warns when a versioned formula has an incorrect `keg_only` reason" do` at line 2016.
pub fn ruby_formula_auditor_spec_l2016_d209_it() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(2016, 'specify', 'specify `specify "it warns when a versioned formula has an incorrect `keg_only` reason" do` at line 2016.')
}

// Ruby specify `specify "it does not warn when a versioned formula has `keg_only :versioned_formula`" do` at line 2031.
pub fn ruby_formula_auditor_spec_l2031_d210_it() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(2031, 'specify', 'specify `specify "it does not warn when a versioned formula has `keg_only :versioned_formula`" do` at line 2031.')
}

// Ruby specify `specify "it warns if new formula uses the same URL as already existing package" do` at line 2054.
pub fn ruby_formula_auditor_spec_l2054_d211_it() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(2054, 'specify', 'specify `specify "it warns if new formula uses the same URL as already existing package" do` at line 2054.')
}

// Ruby specify `specify "it does not warn about duplicates if formula is not new" do` at line 2067.
pub fn ruby_formula_auditor_spec_l2067_d212_it() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(2067, 'specify', 'specify `specify "it does not warn about duplicates if formula is not new" do` at line 2067.')
}

// Ruby specify `specify "it skips the duplicate check offline when no packages data is cached" do` at line 2079.
pub fn ruby_formula_auditor_spec_l2079_d213_it() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(2079, 'specify', 'specify `specify "it skips the duplicate check offline when no packages data is cached" do` at line 2079.')
}

// Ruby specify `specify "it warns when conflicting with non-existing formula", :no_api do` at line 2100.
pub fn ruby_formula_auditor_spec_l2100_d214_it() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(2100, 'specify', 'specify `specify "it warns when conflicting with non-existing formula", :no_api do` at line 2100.')
}

// Ruby specify `specify "it warns when conflicting with itself", :no_api do` at line 2115.
pub fn ruby_formula_auditor_spec_l2115_d215_it() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(2115, 'specify', 'specify `specify "it warns when conflicting with itself", :no_api do` at line 2115.')
}

// Ruby specify `specify "it warns when another formula does not have a symmetric conflict", :no_api do` at line 2131.
pub fn ruby_formula_auditor_spec_l2131_d216_it() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(2131, 'specify', 'specify `specify "it warns when another formula does not have a symmetric conflict", :no_api do` at line 2131.')
}

// Ruby specify `specify "it warns when deprecate/disable reason is invalid" do` at line 2167.
pub fn ruby_formula_auditor_spec_l2167_d217_it() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(2167, 'specify', 'specify `specify "it warns when deprecate/disable reason is invalid" do` at line 2167.')
}

// Ruby specify `specify "it does not warn when deprecate/disable reason is valid" do` at line 2182.
pub fn ruby_formula_auditor_spec_l2182_d218_it() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(2182, 'specify', 'specify `specify "it does not warn when deprecate/disable reason is valid" do` at line 2182.')
}

// Ruby let `let(:formula_text) do` at line 2198.
pub fn ruby_formula_auditor_spec_l2198_d219_formula_text() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(2198, 'let', 'let `let(:formula_text) do` at line 2198.')
}

// Ruby it `it "skips the audit" do` at line 2216.
pub fn ruby_formula_auditor_spec_l2216_d220_skips() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(2216, 'it', 'it `it "skips the audit" do` at line 2216.')
}

// Ruby it `it "detects a Linux-only GCC dependency" do` at line 2230.
pub fn ruby_formula_auditor_spec_l2230_d221_detects() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(2230, 'it', 'it `it "detects a Linux-only GCC dependency" do` at line 2230.')
}

// Ruby it `it "allows a Linux-only GCC dependency when formula has an audit exception" do` at line 2237.
pub fn ruby_formula_auditor_spec_l2237_d222_allows() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(2237, 'it', 'it `it "allows a Linux-only GCC dependency when formula has an audit exception" do` at line 2237.')
}

// Ruby it `it "allows a Linux-only GCC dependency when implicit" do` at line 2244.
pub fn ruby_formula_auditor_spec_l2244_d223_allows() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(2244, 'it', 'it `it "allows a Linux-only GCC dependency when implicit" do` at line 2244.')
}

// Ruby it `it "allows a Linux-only GCC dependency in a non-core tap" do` at line 2251.
pub fn ruby_formula_auditor_spec_l2251_d224_allows() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(2251, 'it', 'it `it "allows a Linux-only GCC dependency in a non-core tap" do` at line 2251.')
}

// Ruby it `it "allows a non-OS-specific GCC dependency" do` at line 2257.
pub fn ruby_formula_auditor_spec_l2257_d225_allows() FormulaAuditorSpecBoundary {
	return formula_auditor_spec_boundary(2257, 'it', 'it `it "allows a non-OS-specific GCC dependency" do` at line 2257.')
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula_auditor"
// 5: require "git_repository"
// 6: require "securerandom"
// 7:
// 8: RSpec.describe Homebrew::FormulaAuditor do
// 9:   let(:dir) { mktmpdir }
// 10:   let(:foo_version) do
// 11:     @count ||= 0
// 12:     @count += 1
// 13:   end
// 14:   let(:formula_subpath) { "Formula/foo#{foo_version}.rb" }
// 15:   let(:origin_tap_path) { HOMEBREW_TAP_DIRECTORY/"homebrew/homebrew-foo" }
// 16:   let(:origin_formula_path) { origin_tap_path/formula_subpath }
// 17:   let(:tap_path) { HOMEBREW_TAP_DIRECTORY/"homebrew/homebrew-bar" }
// 18:   let(:formula_path) { tap_path/formula_subpath }
// 19:
// 20:   include FileUtils
// 21:   include Test::Helper::Formula
// 22:
// 23:   # These specs audit formula content loaded from fixture taps cloned over local
// 24:   # paths, not tap trust, so treat those taps as trusted when loading formulae.
// 25:   before { allow(Homebrew::Trust).to receive(:trusted_tap?).and_return(true) }
// 26:
// 27:   def formula_auditor(name, text, options = {})
// 28:     path = Pathname.new "#{dir}/#{name}.rb"
// 29:     path.open("w") do |f|
// 30:       f.write text
// 31:     end
// 32:
// 33:     formula = Formulary.factory(path)
// 34:
// 35:     if options.key? :tap_audit_exceptions
// 36:       tap = Tap.fetch("test/tap")
// 37:       allow(tap).to receive(:audit_exceptions).and_return(options[:tap_audit_exceptions])
// 38:       allow(formula).to receive(:tap).and_return(tap)
// 39:       options.delete :tap_audit_exceptions
// 40:     end
// 41:
// 42:     Homebrew::FormulaAuditor.new(formula, **options)
// 43:   end
// 44:
// 45:   def formula_gsub(before, after = "")
// 46:     text = formula_path.read
// 47:     text.gsub! before, after
// 48:     formula_path.unlink
// 49:     formula_path.write text
// 50:   end
// 51:
// 52:   def test_formula_source(name:, compatibility_version: nil, revision: 0, depends_on: [])
// 53:     class_name = name.gsub(/[^0-9a-z]/i, "_").split("_").reject(&:empty?).map(&:capitalize).join
// 54:     class_name = "TestFormula#{SecureRandom.hex(2)}" if class_name.empty?
// 55:
// 56:     lines = []
// 57:     lines << "class #{class_name} < Formula"
// 58:     lines << '  desc "Test formula"'
// 59:     lines << '  homepage "https://brew.sh"'
// 60:     lines << %Q(  url "https://brew.sh/#{name}-1.0.tar.gz")
// 61:     lines << '  sha256 "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"'
// 62:     lines << "  compatibility_version #{compatibility_version}" if compatibility_version
// 63:     lines << "  revision #{revision}" if revision.positive?
// 64:     Array(depends_on).each { |dep| lines << %Q(  depends_on "#{dep}") }
// 65:     lines << "  def install"
// 66:     lines << "    bin.mkpath"
// 67:     lines << "  end"
// 68:     lines << "end"
// 69:     "#{lines.join("\n")}\n"
// 70:   end
// 71:
// 72:   def formula_gsub_origin_commit(before, after = "")
// 73:     text = origin_formula_path.read
// 74:     text.gsub!(before, after)
// 75:     origin_formula_path.unlink
// 76:     origin_formula_path.write text
// 77:
// 78:     origin_tap_path.cd do
// 79:       system "git", "commit", "-am", "commit"
// 80:     end
// 81:
// 82:     tap_path.cd do
// 83:       system "git", "fetch"
// 84:       system "git", "reset", "--hard", "origin/HEAD"
// 85:     end
// 86:   end
// 87:
// 88:   describe "#problems" do
// 89:     it "is empty by default" do
// 90:       fa = formula_auditor "foo", <<~RUBY
// 91:         class Foo < Formula
// 92:           url "https://brew.sh/foo-1.0.tgz"
// 93:         end
// 94:       RUBY
// 95:
// 96:       expect(fa.problems).to be_empty
// 97:     end
// 98:   end
// 99:
// 100:   describe "#audit_homepage" do
// 101:     before do
// 102:       allow(Date).to receive(:today).and_return(Date.new(2026, 7, 26))
// 103:       allow(DevelopmentTools).to receive(:curl_handles_most_https_certificates?).and_return(true)
// 104:     end
// 105:
// 106:     it "skips homepages browsed by a human less than a year ago" do
// 107:       fa = formula_auditor "foo", <<~RUBY, online: true
// 108:         class Foo < Formula
// 109:           homepage "https://brew.sh", browsed: "2025-07-27"
// 110:           url "https://brew.sh/foo-1.0.tar.gz"
// 111:         end
// 112:       RUBY
// 113:
// 114:       expect(fa).not_to receive(:curl_check_http_content)
// 115:       fa.audit_homepage
// 116:     end
// 117:
// 118:     it "audits homepages browsed by a human a year ago" do
// 119:       fa = formula_auditor "foo", <<~RUBY, online: true
// 120:         class Foo < Formula
// 121:           homepage "https://brew.sh", browsed: "2025-07-26"
// 122:           url "https://brew.sh/foo-1.0.tar.gz"
// 123:         end
// 124:       RUBY
// 125:
// 126:       expect(fa).to receive(:curl_check_http_content)
// 127:       fa.audit_homepage
// 128:     end
// 129:
// 130:     it "audits homepages with a future browser check date" do
// 131:       fa = formula_auditor "foo", <<~RUBY, online: true
// 132:         class Foo < Formula
// 133:           homepage "https://brew.sh", browsed: "2026-07-27"
// 134:           url "https://brew.sh/foo-1.0.tar.gz"
// 135:         end
// 136:       RUBY
// 137:
// 138:       expect(fa).to receive(:curl_check_http_content)
// 139:       fa.audit_homepage
// 140:     end
// 141:   end
// 142:
// 143:   describe "#audit_license" do
// 144:     let(:spdx_license_data) { SPDX.license_data }
// 145:     let(:spdx_exception_data) { SPDX.exception_data }
// 146:
// 147:     let(:deprecated_spdx_id) { "GPL-1.0" }
// 148:     let(:license_all_custom_id) { 'all_of: ["MIT", "zzz"]' }
// 149:     let(:deprecated_spdx_exception) { "Nokia-Qt-exception-1.1" }
// 150:     let(:license_any) { 'any_of: ["0BSD", "GPL-3.0-only"]' }
// 151:     let(:license_any_with_plus) { 'any_of: ["0BSD+", "GPL-3.0-only"]' }
// 152:     let(:license_nested_conditions) { 'any_of: ["0BSD", { all_of: ["GPL-3.0-only", "MIT"] }]' }
// 153:     let(:license_any_mismatch) { 'any_of: ["0BSD", "MIT"]' }
// 154:     let(:license_any_nonstandard) { 'any_of: ["0BSD", "zzz", "MIT"]' }
// 155:     let(:license_any_deprecated) { 'any_of: ["0BSD", "GPL-1.0", "MIT"]' }
// 156:
// 157:     it "does not check if the formula is not a new formula" do
// 158:       fa = formula_auditor "foo", <<~RUBY, new_formula: false
// 159:         class Foo < Formula
// 160:           url "https://brew.sh/foo-1.0.tgz"
// 161:         end
// 162:       RUBY
// 163:
// 164:       fa.audit_license
// 165:       expect(fa.problems).to be_empty
// 166:     end
// 167:
// 168:     it "detects no license info" do
// 169:       fa = formula_auditor "foo", <<~RUBY, spdx_license_data:, new_formula: true, core_tap: true
// 170:         class Foo < Formula
// 171:           url "https://brew.sh/foo-1.0.tgz"
// 172:         end
// 173:       RUBY
// 174:
// 175:       fa.audit_license
// 176:       expect(fa.problems.first[:message]).to match "Formulae in homebrew/core must specify a license."
// 177:     end
// 178:
// 179:     it "detects if license is not a standard spdx-id" do
// 180:       fa = formula_auditor "foo", <<~RUBY, spdx_license_data:, new_formula: true
// 181:         class Foo < Formula
// 182:           url "https://brew.sh/foo-1.0.tgz"
// 183:           license "zzz"
// 184:         end
// 185:       RUBY
// 186:
// 187:       fa.audit_license
// 188:       expect(fa.problems.first[:message]).to match <<~EOS
// 189:         Formula foo contains non-standard SPDX licenses: ["zzz"].
// 190:         For a list of valid licenses check: https://spdx.org/licenses/
// 191:       EOS
// 192:     end
// 193:
// 194:     it "detects if license is a deprecated spdx-id" do
// 195:       fa = formula_auditor "foo", <<~RUBY, spdx_license_data:, new_formula: true, strict: true
// 196:         class Foo < Formula
// 197:           url "https://brew.sh/foo-1.0.tgz"
// 198:           license "#{deprecated_spdx_id}"
// 199:         end
// 200:       RUBY
// 201:
// 202:       fa.audit_license
// 203:       expect(fa.problems.first[:message]).to eq <<~EOS
// 204:         Formula foo contains deprecated SPDX licenses: ["GPL-1.0"].
// 205:         You may need to add `-only` or `-or-later` for GNU licenses (e.g. `GPL`, `LGPL`, `AGPL`, `GFDL`).
// 206:         For a list of valid licenses check: https://spdx.org/licenses/
// 207:       EOS
// 208:     end
// 209:
// 210:     it "detects if license with AND contains a non-standard spdx-id" do
// 211:       fa = formula_auditor "foo", <<~RUBY, spdx_license_data:, new_formula: true
// 212:         class Foo < Formula
// 213:           url "https://brew.sh/foo-1.0.tgz"
// 214:           license #{license_all_custom_id}
// 215:         end
// 216:       RUBY
// 217:
// 218:       fa.audit_license
// 219:       expect(fa.problems.first[:message]).to match <<~EOS
// 220:         Formula foo contains non-standard SPDX licenses: ["zzz"].
// 221:         For a list of valid licenses check: https://spdx.org/licenses/
// 222:       EOS
// 223:     end
// 224:
// 225:     it "detects if license array contains a non-standard spdx-id" do
// 226:       fa = formula_auditor "foo", <<~RUBY, spdx_license_data:, new_formula: true
// 227:         class Foo < Formula
// 228:           url "https://brew.sh/foo-1.0.tgz"
// 229:           license #{license_any_nonstandard}
// 230:         end
// 231:       RUBY
// 232:
// 233:       fa.audit_license
// 234:       expect(fa.problems.first[:message]).to match <<~EOS
// 235:         Formula foo contains non-standard SPDX licenses: ["zzz"].
// 236:         For a list of valid licenses check: https://spdx.org/licenses/
// 237:       EOS
// 238:     end
// 239:
// 240:     it "detects if license array contains a deprecated spdx-id" do
// 241:       fa = formula_auditor "foo", <<~RUBY, spdx_license_data:, new_formula: true, strict: true
// 242:         class Foo < Formula
// 243:           url "https://brew.sh/foo-1.0.tgz"
// 244:           license #{license_any_deprecated}
// 245:         end
// 246:       RUBY
// 247:
// 248:       fa.audit_license
// 249:       expect(fa.problems.first[:message]).to eq <<~EOS
// 250:         Formula foo contains deprecated SPDX licenses: ["GPL-1.0"].
// 251:         You may need to add `-only` or `-or-later` for GNU licenses (e.g. `GPL`, `LGPL`, `AGPL`, `GFDL`).
// 252:         For a list of valid licenses check: https://spdx.org/licenses/
// 253:       EOS
// 254:     end
// 255:
// 256:     it "verifies that a license info is a standard spdx id" do
// 257:       fa = formula_auditor "foo", <<~RUBY, spdx_license_data:, new_formula: true
// 258:         class Foo < Formula
// 259:           url "https://brew.sh/foo-1.0.tgz"
// 260:           license "0BSD"
// 261:         end
// 262:       RUBY
// 263:
// 264:       fa.audit_license
// 265:       expect(fa.problems).to be_empty
// 266:     end
// 267:
// 268:     it "verifies that a license info with plus is a standard spdx id" do
// 269:       fa = formula_auditor "foo", <<~RUBY, spdx_license_data:, new_formula: true
// 270:         class Foo < Formula
// 271:           url "https://brew.sh/foo-1.0.tgz"
// 272:           license "0BSD+"
// 273:         end
// 274:       RUBY
// 275:
// 276:       fa.audit_license
// 277:       expect(fa.problems).to be_empty
// 278:     end
// 279:
// 280:     it "allows :public_domain license" do
// 281:       fa = formula_auditor "foo", <<~RUBY, spdx_license_data:, new_formula: true
// 282:         class Foo < Formula
// 283:           url "https://brew.sh/foo-1.0.tgz"
// 284:           license :public_domain
// 285:         end
// 286:       RUBY
// 287:
// 288:       fa.audit_license
// 289:       expect(fa.problems).to be_empty
// 290:     end
// 291:
// 292:     it "verifies that a license info with multiple licenses are standard spdx ids" do
// 293:       fa = formula_auditor "foo", <<~RUBY, spdx_license_data:, new_formula: true
// 294:         class Foo < Formula
// 295:           url "https://brew.sh/foo-1.0.tgz"
// 296:           license any_of: ["0BSD", "MIT"]
// 297:         end
// 298:       RUBY
// 299:
// 300:       fa.audit_license
// 301:       expect(fa.problems).to be_empty
// 302:     end
// 303:
// 304:     it "verifies that a license info with exceptions are standard spdx ids" do
// 305:       formula_text = <<~RUBY
// 306:         class Foo < Formula
// 307:           url "https://brew.sh/foo-1.0.tgz"
// 308:           license "Apache-2.0" => { with: "LLVM-exception" }
// 309:         end
// 310:       RUBY
// 311:       fa = formula_auditor("foo", formula_text, new_formula: true,
// 312:                            spdx_license_data:, spdx_exception_data:)
// 313:
// 314:       fa.audit_license
// 315:       expect(fa.problems).to be_empty
// 316:     end
// 317:
// 318:     it "verifies that a license array contains only standard spdx id" do
// 319:       fa = formula_auditor "foo", <<~RUBY, spdx_license_data:, new_formula: true
// 320:         class Foo < Formula
// 321:           url "https://brew.sh/foo-1.0.tgz"
// 322:           license #{license_any}
// 323:         end
// 324:       RUBY
// 325:
// 326:       fa.audit_license
// 327:       expect(fa.problems).to be_empty
// 328:     end
// 329:
// 330:     it "verifies that a license array contains only standard spdx id with plus" do
// 331:       fa = formula_auditor "foo", <<~RUBY, spdx_license_data:, new_formula: true
// 332:         class Foo < Formula
// 333:           url "https://brew.sh/foo-1.0.tgz"
// 334:           license #{license_any_with_plus}
// 335:         end
// 336:       RUBY
// 337:
// 338:       fa.audit_license
// 339:       expect(fa.problems).to be_empty
// 340:     end
// 341:
// 342:     it "verifies that a license array with AND contains only standard spdx ids" do
// 343:       fa = formula_auditor "foo", <<~RUBY, spdx_license_data:, new_formula: true
// 344:         class Foo < Formula
// 345:           url "https://brew.sh/foo-1.0.tgz"
// 346:           license #{license_nested_conditions}
// 347:         end
// 348:       RUBY
// 349:
// 350:       fa.audit_license
// 351:       expect(fa.problems).to be_empty
// 352:     end
// 353:
// 354:     it "checks online and verifies that a standard license id is the same " \
// 355:        "as what is indicated on its GitHub repo", :needs_network do
// 356:       formula_text = <<~RUBY
// 357:         class Cask < Formula
// 358:           url "https://github.com/cask/cask/archive/v0.8.4.tar.gz"
// 359:           head "https://github.com/cask/cask.git", branch: "main"
// 360:           license "GPL-3.0-or-later"
// 361:         end
// 362:       RUBY
// 363:       fa = formula_auditor "cask", formula_text, spdx_license_data:,
// 364:                            online: true, core_tap: true, new_formula: true
// 365:
// 366:       fa.audit_license
// 367:       expect(fa.problems).to be_empty
// 368:     end
// 369:
// 370:     it "checks online and verifies that a standard license id with AND is the same " \
// 371:        "as what is indicated on its GitHub repo", :needs_network do
// 372:       formula_text = <<~RUBY
// 373:         class Cask < Formula
// 374:           url "https://github.com/cask/cask/archive/v0.8.4.tar.gz"
// 375:           head "https://github.com/cask/cask.git", branch: "main"
// 376:           license all_of: ["GPL-3.0-or-later", "MIT"]
// 377:         end
// 378:       RUBY
// 379:       fa = formula_auditor "cask", formula_text, spdx_license_data:,
// 380:                            online: true, core_tap: true, new_formula: true
// 381:
// 382:       fa.audit_license
// 383:       expect(fa.problems).to be_empty
// 384:     end
// 385:
// 386:     it "checks online and verifies that a standard license id with WITH is the same " \
// 387:        "as what is indicated on its GitHub repo", :needs_network do
// 388:       formula_text = <<~RUBY
// 389:         class Cask < Formula
// 390:           url "https://github.com/cask/cask/archive/v0.8.4.tar.gz"
// 391:           head "https://github.com/cask/cask.git", branch: "main"
// 392:           license "GPL-3.0-or-later" => { with: "LLVM-exception" }
// 393:         end
// 394:       RUBY
// 395:       fa = formula_auditor("cask", formula_text, online: true, core_tap: true, new_formula: true,
// 396:                            spdx_license_data:, spdx_exception_data:)
// 397:
// 398:       fa.audit_license
// 399:       expect(fa.problems).to be_empty
// 400:     end
// 401:
// 402:     it "verifies that a license exception has standard spdx ids", :needs_network do
// 403:       formula_text = <<~RUBY
// 404:         class Cask < Formula
// 405:           url "https://github.com/cask/cask/archive/v0.8.4.tar.gz"
// 406:           head "https://github.com/cask/cask.git", branch: "main"
// 407:           license "GPL-3.0-or-later" => { with: "zzz" }
// 408:         end
// 409:       RUBY
// 410:       fa = formula_auditor("cask", formula_text, core_tap: true, new_formula: true,
// 411:                            spdx_license_data:, spdx_exception_data:)
// 412:
// 413:       fa.audit_license
// 414:       expect(fa.problems.first[:message]).to match <<~EOS
// 415:         Formula cask contains invalid or deprecated SPDX license exceptions: ["zzz"].
// 416:         For a list of valid license exceptions check:
// 417:           https://spdx.org/licenses/exceptions-index.html
// 418:       EOS
// 419:     end
// 420:
// 421:     it "verifies that a license exception has non-deprecated spdx ids", :needs_network do
// 422:       formula_text = <<~RUBY
// 423:         class Cask < Formula
// 424:           url "https://github.com/cask/cask/archive/v0.8.4.tar.gz"
// 425:           head "https://github.com/cask/cask.git", branch: "main"
// 426:           license "GPL-3.0-or-later" => { with: "#{deprecated_spdx_exception}" }
// 427:         end
// 428:       RUBY
// 429:       fa = formula_auditor("cask", formula_text, core_tap: true, new_formula: true,
// 430:                            spdx_license_data:, spdx_exception_data:)
// 431:
// 432:       fa.audit_license
// 433:       expect(fa.problems.first[:message]).to match <<~EOS
// 434:         Formula cask contains invalid or deprecated SPDX license exceptions: ["#{deprecated_spdx_exception}"].
// 435:         For a list of valid license exceptions check:
// 436:           https://spdx.org/licenses/exceptions-index.html
// 437:       EOS
// 438:     end
// 439:
// 440:     it "checks online and verifies that a standard license id is in the same exempted license group " \
// 441:        "as what is indicated on its GitHub repo", :needs_network do
// 442:       fa = formula_auditor "cask", <<~RUBY, spdx_license_data:, online: true, new_formula: true
// 443:         class Cask < Formula
// 444:           url "https://github.com/cask/cask/archive/v0.8.4.tar.gz"
// 445:           head "https://github.com/cask/cask.git", branch: "main"
// 446:           license "GPL-3.0-or-later"
// 447:         end
// 448:       RUBY
// 449:
// 450:       fa.audit_license
// 451:       expect(fa.problems).to be_empty
// 452:     end
// 453:
// 454:     it "checks online and verifies that a standard license array is in the same exempted license group " \
// 455:        "as what is indicated on its GitHub repo", :needs_network do
// 456:       fa = formula_auditor "cask", <<~RUBY, spdx_license_data:, online: true, new_formula: true
// 457:         class Cask < Formula
// 458:           url "https://github.com/cask/cask/archive/v0.8.4.tar.gz"
// 459:           head "https://github.com/cask/cask.git", branch: "main"
// 460:           license any_of: ["GPL-3.0-or-later", "MIT"]
// 461:         end
// 462:       RUBY
// 463:
// 464:       fa.audit_license
// 465:       expect(fa.problems).to be_empty
// 466:     end
// 467:
// 468:     it "checks online and detects that a formula-specified license is not " \
// 469:        "the same as what is indicated on its GitHub repository", :needs_network do
// 470:       formula_text = <<~RUBY
// 471:         class Cask < Formula
// 472:           url "https://github.com/cask/cask/archive/v0.8.4.tar.gz"
// 473:           head "https://github.com/cask/cask.git", branch: "main"
// 474:           license "0BSD"
// 475:         end
// 476:       RUBY
// 477:       fa = formula_auditor "cask", formula_text, spdx_license_data:,
// 478:                            online: true, core_tap: true, new_formula: true
// 479:
// 480:       fa.audit_license
// 481:       expect(fa.problems.first[:message])
// 482:         .to eq 'Formula license ["0BSD"] does not match GitHub license ["GPL-3.0"].'
// 483:     end
// 484:
// 485:     it "allows a formula-specified license that differs from its GitHub " \
// 486:        "repository for formulae on the mismatched license allowlist", :needs_network do
// 487:       formula_text = <<~RUBY
// 488:         class Cask < Formula
// 489:           url "https://github.com/cask/cask/archive/v0.8.4.tar.gz"
// 490:           head "https://github.com/cask/cask.git", branch: "main"
// 491:           license "0BSD"
// 492:         end
// 493:       RUBY
// 494:       fa = formula_auditor "cask", formula_text, spdx_license_data:,
// 495:                            online: true, core_tap: true, new_formula: true,
// 496:                            tap_audit_exceptions: { permitted_formula_license_mismatches: ["cask"] }
// 497:
// 498:       fa.audit_license
// 499:       expect(fa.problems).to be_empty
// 500:     end
// 501:
// 502:     it "checks online and detects that an array of license does not contain " \
// 503:        "what is indicated on its GitHub repository", :needs_network do
// 504:       formula_text = <<~RUBY
// 505:         class Cask < Formula
// 506:           url "https://github.com/cask/cask/archive/v0.8.4.tar.gz"
// 507:           head "https://github.com/cask/cask.git", branch: "main"
// 508:           license #{license_any_mismatch}
// 509:         end
// 510:       RUBY
// 511:       fa = formula_auditor "cask", formula_text, spdx_license_data:,
// 512:                            online: true, core_tap: true, new_formula: true
// 513:
// 514:       fa.audit_license
// 515:       expect(fa.problems.first[:message]).to match "Formula license [\"0BSD\", \"MIT\"] " \
// 516:                                                    "does not match GitHub license [\"GPL-3.0\"]."
// 517:     end
// 518:
// 519:     it "checks online and verifies that an array of license contains " \
// 520:        "what is indicated on its GitHub repository", :needs_network do
// 521:       formula_text = <<~RUBY
// 522:         class Cask < Formula
// 523:           url "https://github.com/cask/cask/archive/v0.8.4.tar.gz"
// 524:           head "https://github.com/cask/cask.git", branch: "main"
// 525:           license #{license_any}
// 526:         end
// 527:       RUBY
// 528:       fa = formula_auditor "cask", formula_text, spdx_license_data:,
// 529:                            online: true, core_tap: true, new_formula: true
// 530:
// 531:       fa.audit_license
// 532:       expect(fa.problems).to be_empty
// 533:     end
// 534:   end
// 535:
// 536:   describe "#audit_node_modules" do
// 537:     let(:fa) do
// 538:       formula_auditor("foo", <<~RUBY, core_tap:)
// 539:         class Foo < Formula
// 540:           url "https://brew.sh/foo-1.0.tgz"
// 541:           homepage "https://brew.sh"
// 542:         end
// 543:       RUBY
// 544:     end
// 545:     let(:node_modules) { fa.formula.libexec/"lib/node_modules" }
// 546:     let(:reject_package) { "@anthropic-ai/claude-agent-sdk" }
// 547:     let(:audit_message) { "uses #{reject_package} which has an incompatible license" }
// 548:
// 549:     context "when core tap" do
// 550:       let(:core_tap) { true }
// 551:
// 552:       it "detects unacceptable npm packages" do
// 553:         (node_modules/reject_package).mkpath
// 554:         fa.audit_node_modules
// 555:         expect(fa.problems.first[:message]).to match audit_message
// 556:       end
// 557:
// 558:       it "detects unacceptable npm packages in nested node_modules" do
// 559:         (node_modules/"foo/node_modules/bar/node_modules"/reject_package).mkpath
// 560:         fa.audit_node_modules
// 561:         expect(fa.problems.first[:message]).to match audit_message
// 562:       end
// 563:
// 564:       it "detects unacceptable npm packages in .pnpm hoisted directory" do
// 565:         (node_modules/".pnpm/node_modules"/reject_package).mkpath
// 566:         fa.audit_node_modules
// 567:         expect(fa.problems.first[:message]).to match audit_message
// 568:       end
// 569:
// 570:       it "skips audit when no node_modules" do
// 571:         fa.formula.libexec.mkpath
// 572:         fa.audit_node_modules
// 573:         expect(fa.problems).to be_empty
// 574:       end
// 575:     end
// 576:
// 577:     context "when non-core tap" do
// 578:       let(:core_tap) { false }
// 579:
// 580:       it "skips audit" do
// 581:         (node_modules/reject_package).mkpath
// 582:         (node_modules/"foo/node_modules/bar/node_modules"/reject_package).mkpath
// 583:         (node_modules/".pnpm/node_modules"/reject_package).mkpath
// 584:         fa.audit_node_modules
// 585:         expect(fa.problems).to be_empty
// 586:       end
// 587:     end
// 588:   end
// 589:
// 590:   describe "#audit_file" do
// 591:     specify "no issue" do
// 592:       fa = formula_auditor "foo", <<~RUBY
// 593:         class Foo < Formula
// 594:           url "https://brew.sh/foo-1.0.tgz"
// 595:           homepage "https://brew.sh"
// 596:         end
// 597:       RUBY
// 598:
// 599:       fa.audit_file
// 600:       expect(fa.problems).to be_empty
// 601:     end
// 602:   end
// 603:
// 604:   describe "#audit_name" do
// 605:     specify "no issue" do
// 606:       fa = formula_auditor "foo", <<~RUBY, core_tap: true, strict: true
// 607:         class Foo < Formula
// 608:           url "https://brew.sh/foo-1.0.tgz"
// 609:           homepage "https://brew.sh"
// 610:         end
// 611:       RUBY
// 612:
// 613:       fa.audit_name
// 614:       expect(fa.problems).to be_empty
// 615:     end
// 616:
// 617:     specify "uppercase formula name" do
// 618:       fa = formula_auditor "Foo", <<~RUBY
// 619:         class Foo < Formula
// 620:           url "https://brew.sh/Foo-1.0.tgz"
// 621:           homepage "https://brew.sh"
// 622:         end
// 623:       RUBY
// 624:
// 625:       fa.audit_name
// 626:       expect(fa.problems.first[:message]).to match "must not contain uppercase letters"
// 627:     end
// 628:   end
// 629:
// 630:   describe "#audit_resource_name_matches_pypi_package_name_in_url" do
// 631:     it "reports a problem if the resource name does not match the python sdist name" do
// 632:       fa = formula_auditor "foo", <<~RUBY
// 633:         class Foo < Formula
// 634:           url "https://brew.sh/foo-1.0.tgz"
// 635:           sha256 "abc123"
// 636:           homepage "https://brew.sh"
// 637:
// 638:           resource "Something" do
// 639:             url "https://files.pythonhosted.org/packages/FooSomething-1.0.0.tar.gz"
// 640:             sha256 "def456"
// 641:           end
// 642:         end
// 643:       RUBY
// 644:
// 645:       fa.audit_specs
// 646:       expect(fa.problems.first[:message])
// 647:         .to match("`resource` name should be 'FooSomething' to match the PyPI package name")
// 648:     end
// 649:
// 650:     it "reports a problem if the resource name does not match the python wheel name" do
// 651:       fa = formula_auditor "foo", <<~RUBY
// 652:         class Foo < Formula
// 653:           url "https://brew.sh/foo-1.0.tgz"
// 654:           sha256 "abc123"
// 655:           homepage "https://brew.sh"
// 656:
// 657:           resource "Something" do
// 658:             url "https://files.pythonhosted.org/packages/FooSomething-1.0.0-py3-none-any.whl"
// 659:             sha256 "def456"
// 660:           end
// 661:         end
// 662:       RUBY
// 663:
// 664:       fa.audit_specs
// 665:       expect(fa.problems.first[:message])
// 666:         .to match("`resource` name should be 'FooSomething' to match the PyPI package name")
// 667:     end
// 668:   end
// 669:
// 670:   describe "#check_service_command" do
// 671:     specify "Not installed" do
// 672:       fa = formula_auditor "foo", <<~RUBY
// 673:         class Foo < Formula
// 674:           url "https://brew.sh/foo-1.0.tgz"
// 675:           homepage "https://brew.sh"
// 676:
// 677:           service do
// 678:             run []
// 679:           end
// 680:         end
// 681:       RUBY
// 682:
// 683:       expect(fa.check_service_command(fa.formula)).to match nil
// 684:     end
// 685:
// 686:     specify "No service" do
// 687:       fa = formula_auditor "foo", <<~RUBY
// 688:         class Foo < Formula
// 689:           url "https://brew.sh/foo-1.0.tgz"
// 690:           homepage "https://brew.sh"
// 691:         end
// 692:       RUBY
// 693:
// 694:       mkdir_p fa.formula.prefix
// 695:       expect(fa.check_service_command(fa.formula)).to match nil
// 696:     end
// 697:
// 698:     specify "No command" do
// 699:       fa = formula_auditor "foo", <<~RUBY
// 700:         class Foo < Formula
// 701:           url "https://brew.sh/foo-1.0.tgz"
// 702:           homepage "https://brew.sh"
// 703:
// 704:           service do
// 705:             run []
// 706:           end
// 707:         end
// 708:       RUBY
// 709:
// 710:       mkdir_p fa.formula.prefix
// 711:       expect(fa.check_service_command(fa.formula)).to match nil
// 712:     end
// 713:
// 714:     specify "Invalid command" do
// 715:       fa = formula_auditor "foo", <<~RUBY
// 716:         class Foo < Formula
// 717:           url "https://brew.sh/foo-1.0.tgz"
// 718:           homepage "https://brew.sh"
// 719:
// 720:           service do
// 721:             run [HOMEBREW_PREFIX/"bin/something"]
// 722:           end
// 723:         end
// 724:       RUBY
// 725:
// 726:       mkdir_p fa.formula.prefix
// 727:       expect(fa.check_service_command(fa.formula)).to match "Service command does not exist"
// 728:     end
// 729:   end
// 730:
// 731:   describe "#audit_github_repository" do
// 732:     specify "#audit_github_repository when HOMEBREW_NO_GITHUB_API is set" do
// 733:       ENV["HOMEBREW_NO_GITHUB_API"] = "1"
// 734:
// 735:       fa = formula_auditor "foo", <<~RUBY, strict: true, online: true
// 736:         class Foo < Formula
// 737:           homepage "https://github.com/example/example"
// 738:           url "https://brew.sh/foo-1.0.tgz"
// 739:         end
// 740:       RUBY
// 741:
// 742:       fa.audit_github_repository
// 743:       expect(fa.problems).to be_empty
// 744:     end
// 745:   end
// 746:
// 747:   describe "#audit_github_repository_archived" do
// 748:     specify "#audit_github_repository_archived when HOMEBREW_NO_GITHUB_API is set" do
// 749:       fa = formula_auditor "foo", <<~RUBY, strict: true, online: true
// 750:         class Foo < Formula
// 751:           homepage "https://github.com/example/example"
// 752:           url "https://brew.sh/foo-1.0.tgz"
// 753:         end
// 754:       RUBY
// 755:
// 756:       fa.audit_github_repository_archived
// 757:       expect(fa.problems).to be_empty
// 758:     end
// 759:   end
// 760:
// 761:   describe "#audit_gitlab_repository" do
// 762:     specify "#audit_gitlab_repository for stars, forks and creation date" do
// 763:       fa = formula_auditor "foo", <<~RUBY, strict: true, online: true
// 764:         class Foo < Formula
// 765:           homepage "https://gitlab.com/libtiff/libtiff"
// 766:           url "https://brew.sh/foo-1.0.tgz"
// 767:         end
// 768:       RUBY
// 769:
// 770:       fa.audit_gitlab_repository
// 771:       expect(fa.problems).to be_empty
// 772:     end
// 773:   end
// 774:
// 775:   describe "#audit_gitlab_repository_archived" do
// 776:     specify "#audit gitlab repository for archived status" do
// 777:       fa = formula_auditor "foo", <<~RUBY, strict: true, online: true
// 778:         class Foo < Formula
// 779:           homepage "https://gitlab.com/libtiff/libtiff"
// 780:           url "https://brew.sh/foo-1.0.tgz"
// 781:         end
// 782:       RUBY
// 783:
// 784:       fa.audit_gitlab_repository_archived
// 785:       expect(fa.problems).to be_empty
// 786:     end
// 787:   end
// 788:
// 789:   describe "#audit_bitbucket_repository" do
// 790:     specify "#audit_bitbucket_repository for stars, forks and creation date" do
// 791:       fa = formula_auditor "foo", <<~RUBY, strict: true, online: true
// 792:         class Foo < Formula
// 793:           homepage "https://bitbucket.com/libtiff/libtiff"
// 794:           url "https://brew.sh/foo-1.0.tgz"
// 795:         end
// 796:       RUBY
// 797:
// 798:       fa.audit_bitbucket_repository
// 799:       expect(fa.problems).to be_empty
// 800:     end
// 801:   end
// 802:
// 803:   describe "#audit_specs" do
// 804:     let(:livecheck_throttle) { "livecheck do\n    throttle 10\n  end" }
// 805:     let(:livecheck_throttle_days) { "livecheck do\n    throttle days: 1\n  end" }
// 806:     let(:livecheck_throttle_rate_days) { "livecheck do\n    throttle 10, days: 1\n  end" }
// 807:     let(:versioned_head_spec_list) { { versioned_head_spec_allowlist: ["foo"] } }
// 808:
// 809:     it "doesn't allow to miss a checksum" do
// 810:       fa = formula_auditor "foo", <<~RUBY
// 811:         class Foo < Formula
// 812:           url "https://brew.sh/foo-1.0.tgz"
// 813:         end
// 814:       RUBY
// 815:
// 816:       fa.audit_specs
// 817:       expect(fa.problems.first[:message]).to match "Checksum is missing"
// 818:     end
// 819:
// 820:     it "allows to miss a checksum for git strategy" do
// 821:       fa = formula_auditor "foo", <<~RUBY
// 822:         class Foo < Formula
// 823:           url "https://brew.sh/foo.git", tag: "1.0", revision: "f5e00e485e7aa4c5baa20355b27e3b84a6912790"
// 824:         end
// 825:       RUBY
// 826:
// 827:       fa.audit_specs
// 828:       expect(fa.problems).to be_empty
// 829:     end
// 830:
// 831:     it "allows to miss a checksum for HEAD" do
// 832:       fa = formula_auditor "foo", <<~RUBY
// 833:         class Foo < Formula
// 834:           url "https://brew.sh/foo-1.0.tgz"
// 835:           sha256 "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 836:           head "https://brew.sh/foo.tgz"
// 837:         end
// 838:       RUBY
// 839:
// 840:       fa.audit_specs
// 841:       expect(fa.problems).to be_empty
// 842:     end
// 843:
// 844:     it "accepts a curl dependency with a working HTTP mirror" do
// 845:       sha256 = "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 846:       mirror_url = "http://brew.sh/mirror/foo-1.0.tgz"
// 847:       allow(Homebrew::ResourceAuditor).to receive(:curl_deps).and_return(["foo"])
// 848:       fa = formula_auditor "foo", <<~RUBY, online: true
// 849:         class Foo < Formula
// 850:           url "https://brew.sh/foo-1.0.tgz"
// 851:           mirror "#{mirror_url}"
// 852:           sha256 "#{sha256}"
// 853:         end
// 854:       RUBY
// 855:       allow_any_instance_of(Homebrew::ResourceAuditor).to receive(:curl_http_content_headers_and_checksum)
// 856:         .and_return(status_code: "200", final_url: nil, file_hash: sha256)
// 857:
// 858:       fa.audit_specs
// 859:       expect(fa.problems).to be_empty
// 860:     end
// 861:
// 862:     it "accepts a curl dependency whose HTTP mirror redirects to a relative path" do
// 863:       sha256 = "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 864:       allow(Homebrew::ResourceAuditor).to receive(:curl_deps).and_return(["foo"])
// 865:       fa = formula_auditor "foo", <<~RUBY, online: true
// 866:         class Foo < Formula
// 867:           url "https://brew.sh/foo-1.0.tgz"
// 868:           mirror "http://brew.sh/mirror/foo-1.0.tgz"
// 869:           sha256 "#{sha256}"
// 870:         end
// 871:       RUBY
// 872:       allow_any_instance_of(Homebrew::ResourceAuditor).to receive(:curl_http_content_headers_and_checksum)
// 873:         .and_return(status_code: "200", final_url: "/mirror/foo-1.0.tgz", file_hash: sha256)
// 874:
// 875:       fa.audit_specs
// 876:       expect(fa.problems).to be_empty
// 877:     end
// 878:
// 879:     it "reports a curl dependency whose HTTP mirror serves the wrong checksum" do
// 880:       mirror_url = "http://brew.sh/mirror/foo-1.0.tgz"
// 881:       allow(Homebrew::ResourceAuditor).to receive(:curl_deps).and_return(["foo"])
// 882:       fa = formula_auditor "foo", <<~RUBY, online: true
// 883:         class Foo < Formula
// 884:           url "https://brew.sh/foo-1.0.tgz"
// 885:           mirror "#{mirror_url}"
// 886:           sha256 "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 887:         end
// 888:       RUBY
// 889:       allow_any_instance_of(Homebrew::ResourceAuditor).to receive(:curl_http_content_headers_and_checksum)
// 890:         .and_return(status_code: "200", final_url: mirror_url, file_hash: "deadbeef")
// 891:
// 892:       fa.audit_specs
// 893:       expect(fa.problems).to include(
// 894:         a_hash_including(message: a_string_including("must have a working HTTP mirror")),
// 895:       )
// 896:     end
// 897:
// 898:     it "reports a curl dependency whose HTTP mirror is unreachable" do
// 899:       mirror_url = "http://brew.sh/mirror/foo-1.0.tgz"
// 900:       allow(Homebrew::ResourceAuditor).to receive(:curl_deps).and_return(["foo"])
// 901:       fa = formula_auditor "foo", <<~RUBY, online: true
// 902:         class Foo < Formula
// 903:           url "https://brew.sh/foo-1.0.tgz"
// 904:           mirror "#{mirror_url}"
// 905:           sha256 "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 906:         end
// 907:       RUBY
// 908:       allow_any_instance_of(Homebrew::ResourceAuditor).to receive(:curl_http_content_headers_and_checksum)
// 909:         .and_return(status_code: nil, final_url: nil, file_hash: nil)
// 910:
// 911:       fa.audit_specs
// 912:       expect(fa.problems).to include(
// 913:         a_hash_including(message: a_string_including("must have a working HTTP mirror")),
// 914:       )
// 915:     end
// 916:
// 917:     it "reports a curl dependency whose HTTP mirror redirects to HTTPS" do
// 918:       sha256 = "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 919:       allow(Homebrew::ResourceAuditor).to receive(:curl_deps).and_return(["foo"])
// 920:       fa = formula_auditor "foo", <<~RUBY, online: true
// 921:         class Foo < Formula
// 922:           url "https://brew.sh/foo-1.0.tgz"
// 923:           mirror "http://brew.sh/mirror/foo-1.0.tgz"
// 924:           sha256 "#{sha256}"
// 925:         end
// 926:       RUBY
// 927:       allow_any_instance_of(Homebrew::ResourceAuditor).to receive(:curl_http_content_headers_and_checksum)
// 928:         .and_return(status_code: "200", final_url: "https://brew.sh/mirror/foo-1.0.tgz", file_hash: sha256)
// 929:
// 930:       fa.audit_specs
// 931:       expect(fa.problems).to include(
// 932:         a_hash_including(message: a_string_including("must have a working HTTP mirror")),
// 933:       )
// 934:     end
// 935:
// 936:     it "requires `branch:` to be specified for Git head URLs" do
// 937:       head_url = "https://github.com/Homebrew/homebrew-test-bot.git"
// 938:       fa = formula_auditor "foo", <<~RUBY, online: true
// 939:         class Foo < Formula
// 940:           url "https://brew.sh/foo-1.0.tgz"
// 941:           sha256 "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 942:           head "#{head_url}"
// 943:         end
// 944:       RUBY
// 945:       allow(Utils::Git).to receive(:remote_exists?).and_return(true)
// 946:       allow(Utils).to receive(:popen_read).and_call_original
// 947:       expect(Utils).to receive(:popen_read)
// 948:         .with("git", "ls-remote", "--symref", "--end-of-options", head_url, "HEAD")
// 949:         .and_return("ref: refs/heads/main\tHEAD\n")
// 950:
// 951:       fa.audit_specs
// 952:       # This is `.last` because the first problem is the unreachable stable URL.
// 953:       expect(fa.problems.last[:message]).to match("Git `head` URL must specify a branch name")
// 954:     end
// 955:
// 956:     it "suggests a detected default branch for Git head URLs" do
// 957:       fa = formula_auditor "foo", <<~RUBY, online: true, core_tap: true
// 958:         class Foo < Formula
// 959:           url "https://brew.sh/foo-1.0.tgz"
// 960:           sha256 "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 961:           head "https://github.com/Homebrew/homebrew-test-bot.git", branch: "master"
// 962:         end
// 963:       RUBY
// 964:
// 965:       message = "To use a non-default HEAD branch, add the formula to `head_non_default_branch_allowlist.json`."
// 966:       fa.audit_specs
// 967:       # This is `.last` because the first problem is the unreachable stable URL.
// 968:       expect(fa.problems.last[:message]).to match(message)
// 969:     end
// 970:
// 971:     it "can specify a default branch without an allowlist if not in a core tap" do
// 972:       fa = formula_auditor "foo", <<~RUBY, online: true
// 973:         class Foo < Formula
// 974:           url "https://brew.sh/foo-1.0.tgz"
// 975:           sha256 "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 976:           head "https://github.com/Homebrew/homebrew-test-bot.git", branch: "main"
// 977:         end
// 978:       RUBY
// 979:
// 980:       fa.audit_specs
// 981:       expect(fa.problems).not_to match("Git `head` URL must specify a branch name")
// 982:     end
// 983:
// 984:     it "ignores `branch:` for non-Git head URLs" do
// 985:       fa = formula_auditor "foo", <<~RUBY, online: true
// 986:         class Foo < Formula
// 987:           url "https://brew.sh/foo-1.0.tgz"
// 988:           sha256 "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 989:           head "https://brew.sh/foo.tgz", branch: "develop"
// 990:         end
// 991:       RUBY
// 992:
// 993:       fa.audit_specs
// 994:       expect(fa.problems).not_to match("Git `head` URL must specify a branch name")
// 995:     end
// 996:
// 997:     it "ignores `branch:` for `resource` URLs" do
// 998:       fa = formula_auditor "foo", <<~RUBY, online: true
// 999:         class Foo < Formula
// 1000:           url "https://brew.sh/foo-1.0.tgz"
// 1001:           sha256 "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 1002:
// 1003:           resource "bar" do
// 1004:             url "https://raw.githubusercontent.com/Homebrew/homebrew-core/HEAD/Formula/bar.rb"
// 1005:             sha256 "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 1006:           end
// 1007:         end
// 1008:       RUBY
// 1009:
// 1010:       fa.audit_specs
// 1011:       expect(fa.problems).not_to match("Git `head` URL must specify a branch name")
// 1012:     end
// 1013:
// 1014:     it "allows versions with no throttle rate" do
// 1015:       fa = formula_auditor "bar", <<~RUBY, core_tap: true
// 1016:         class Bar < Formula
// 1017:           url "https://brew.sh/foo-1.0.1.tgz"
// 1018:           sha256 "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 1019:         end
// 1020:       RUBY
// 1021:
// 1022:       fa.audit_specs
// 1023:       expect(fa.problems).to be_empty
// 1024:     end
// 1025:
// 1026:     it "allows major/minor versions with throttle rate" do
// 1027:       fa = formula_auditor "foo", <<~RUBY, core_tap: true
// 1028:         class Foo < Formula
// 1029:           url "https://brew.sh/foo-1.0.0.tgz"
// 1030:           sha256 "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 1031:           #{livecheck_throttle}
// 1032:         end
// 1033:       RUBY
// 1034:
// 1035:       fa.audit_specs
// 1036:       expect(fa.problems).to be_empty
// 1037:     end
// 1038:
// 1039:     it "allows patch versions to be multiples of the throttle rate" do
// 1040:       fa = formula_auditor "foo", <<~RUBY, core_tap: true
// 1041:         class Foo < Formula
// 1042:           url "https://brew.sh/foo-1.0.10.tgz"
// 1043:           sha256 "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 1044:           #{livecheck_throttle}
// 1045:         end
// 1046:       RUBY
// 1047:
// 1048:       fa.audit_specs
// 1049:       expect(fa.problems).to be_empty
// 1050:     end
// 1051:
// 1052:     it "doesn't allow patch versions that aren't multiples of the throttle rate" do
// 1053:       fa = formula_auditor "foo", <<~RUBY, core_tap: true
// 1054:         class Foo < Formula
// 1055:           url "https://brew.sh/foo-1.0.1.tgz"
// 1056:           sha256 "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 1057:           #{livecheck_throttle}
// 1058:         end
// 1059:       RUBY
// 1060:
// 1061:       fa.audit_specs
// 1062:       expect(fa.problems.first[:message]).to match "Should only be updated every 10 releases on multiples of 10"
// 1063:     end
// 1064:
// 1065:     it "allows patch versions that aren't multiples of the throttle rate when throttle interval has elapsed" do
// 1066:       fa = formula_auditor "foo", <<~RUBY, core_tap: true
// 1067:         class Foo < Formula
// 1068:           url "https://brew.sh/foo-1.0.1.tgz"
// 1069:           sha256 "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 1070:           #{livecheck_throttle_rate_days}
// 1071:         end
// 1072:       RUBY
// 1073:
// 1074:       allow(Homebrew::Livecheck).to receive(:throttle_interval_elapsed?).and_return(true)
// 1075:
// 1076:       fa.audit_specs
// 1077:       expect(fa.problems).to be_empty
// 1078:     end
// 1079:
// 1080:     it "allows patch versions that aren't multiples when throttle interval has not elapsed" do
// 1081:       fa = formula_auditor "foo", <<~RUBY, core_tap: true
// 1082:         class Foo < Formula
// 1083:           url "https://brew.sh/foo-1.0.1.tgz"
// 1084:           sha256 "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 1085:           #{livecheck_throttle_rate_days}
// 1086:         end
// 1087:       RUBY
// 1088:
// 1089:       allow(Homebrew::Livecheck).to receive(:throttle_interval_elapsed?).and_return(false)
// 1090:
// 1091:       fa.audit_specs
// 1092:       expect(fa.problems).to be_empty
// 1093:     end
// 1094:
// 1095:     it "allows throttle with only days when throttle interval has elapsed" do
// 1096:       fa = formula_auditor "foo", <<~RUBY, core_tap: true
// 1097:         class Foo < Formula
// 1098:           url "https://brew.sh/foo-1.0.1.tgz"
// 1099:           sha256 "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 1100:           #{livecheck_throttle_days}
// 1101:         end
// 1102:       RUBY
// 1103:
// 1104:       allow(Homebrew::Livecheck).to receive(:throttle_interval_elapsed?).and_return(true)
// 1105:
// 1106:       fa.audit_specs
// 1107:       expect(fa.problems).to be_empty
// 1108:     end
// 1109:
// 1110:     it "allows throttle with only days when throttle interval has not elapsed" do
// 1111:       fa = formula_auditor "foo", <<~RUBY, core_tap: true
// 1112:         class Foo < Formula
// 1113:           url "https://brew.sh/foo-1.0.1.tgz"
// 1114:           sha256 "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 1115:           #{livecheck_throttle_days}
// 1116:         end
// 1117:       RUBY
// 1118:
// 1119:       allow(Homebrew::Livecheck).to receive(:throttle_interval_elapsed?).and_return(false)
// 1120:
// 1121:       fa.audit_specs
// 1122:       expect(fa.problems).to be_empty
// 1123:     end
// 1124:
// 1125:     it "allows non-versioned formulae to have a `HEAD` spec" do
// 1126:       fa = formula_auditor "bar", <<~RUBY, core_tap: true, tap_audit_exceptions: versioned_head_spec_list
// 1127:         class Bar < Formula
// 1128:           url "https://brew.sh/foo-1.0.tgz"
// 1129:           sha256 "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 1130:           head "https://brew.sh/foo.git", branch: "develop"
// 1131:         end
// 1132:       RUBY
// 1133:
// 1134:       fa.audit_specs
// 1135:       expect(fa.problems).to be_empty
// 1136:     end
// 1137:
// 1138:     it "doesn't allow versioned formulae to have a `HEAD` spec" do
// 1139:       fa = formula_auditor "bar@1", <<~RUBY, core_tap: true, tap_audit_exceptions: versioned_head_spec_list
// 1140:         class BarAT1 < Formula
// 1141:           url "https://brew.sh/foo-1.0.tgz"
// 1142:           sha256 "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 1143:           head "https://brew.sh/foo.git", branch: "develop"
// 1144:         end
// 1145:       RUBY
// 1146:
// 1147:       fa.audit_specs
// 1148:       expect(fa.problems.first[:message]).to match "Versioned formulae should not have a `head` spec"
// 1149:     end
// 1150:
// 1151:     it "allows versioned formulae on the allowlist to have a `HEAD` spec" do
// 1152:       fa = formula_auditor "foo", <<~RUBY, core_tap: true, tap_audit_exceptions: versioned_head_spec_list
// 1153:         class Foo < Formula
// 1154:           url "https://brew.sh/foo-1.0.tgz"
// 1155:           sha256 "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 1156:           head "https://brew.sh/foo.git", branch: "develop"
// 1157:         end
// 1158:       RUBY
// 1159:
// 1160:       fa.audit_specs
// 1161:       expect(fa.problems).to be_empty
// 1162:     end
// 1163:   end
// 1164:
// 1165:   describe "#audit_deps" do
// 1166:     describe "a dependency on a macOS-provided keg-only formula" do
// 1167:       describe "which is allowlisted" do
// 1168:         subject(:f_a) { fa }
// 1169:
// 1170:         let(:fa) do
// 1171:           formula_auditor "foo", <<~RUBY, new_formula: true
// 1172:             class Foo < Formula
// 1173:               url "https://brew.sh/foo-1.0.tgz"
// 1174:               homepage "https://brew.sh"
// 1175:
// 1176:               depends_on "openssl"
// 1177:             end
// 1178:           RUBY
// 1179:         end
// 1180:
// 1181:         let(:f_openssl) do
// 1182:           formula do
// 1183:             T.bind(self, T.class_of(Formula))
// 1184:             url "https://brew.sh/openssl-1.0.tgz"
// 1185:             homepage "https://brew.sh"
// 1186:
// 1187:             keg_only :provided_by_macos
// 1188:           end
// 1189:         end
// 1190:
// 1191:         before do
// 1192:           allow(fa.formula.deps.first)
// 1193:             .to receive(:to_formula).and_return(f_openssl)
// 1194:           fa.audit_deps
// 1195:         end
// 1196:
// 1197:         it(:problems) { expect(f_a.problems).to be_empty }
// 1198:       end
// 1199:
// 1200:       describe "which is not allowlisted", :needs_macos do
// 1201:         subject(:f_a) { fa }
// 1202:
// 1203:         let(:fa) do
// 1204:           formula_auditor "foo", <<~RUBY, new_formula: true, core_tap: true
// 1205:             class Foo < Formula
// 1206:               url "https://brew.sh/foo-1.0.tgz"
// 1207:               homepage "https://brew.sh"
// 1208:
// 1209:               depends_on "bc"
// 1210:             end
// 1211:           RUBY
// 1212:         end
// 1213:
// 1214:         let(:f_bc) do
// 1215:           formula do
// 1216:             T.bind(self, T.class_of(Formula))
// 1217:             url "https://brew.sh/bc-1.0.tgz"
// 1218:             homepage "https://brew.sh"
// 1219:
// 1220:             keg_only :provided_by_macos
// 1221:           end
// 1222:         end
// 1223:
// 1224:         before do
// 1225:           allow(fa.formula.deps.first)
// 1226:             .to receive(:to_formula).and_return(f_bc)
// 1227:           fa.audit_deps
// 1228:         end
// 1229:
// 1230:         it(:new_formula_problems) do
// 1231:           expect(f_a.new_formula_problems)
// 1232:             .to include(a_hash_including(message: a_string_matching(/is provided by macOS/)))
// 1233:         end
// 1234:       end
// 1235:     end
// 1236:
// 1237:     describe "dependency tag" do
// 1238:       subject(:f_a) { fa }
// 1239:
// 1240:       let(:core_tap) { false }
// 1241:       let(:fa) do
// 1242:         formula_auditor "foo", <<~RUBY, core_tap:
// 1243:           class Foo < Formula
// 1244:             url "https://brew.sh/foo-1.0.tgz"
// 1245:             homepage "https://brew.sh"
// 1246:
// 1247:             depends_on "bar" => #{tag.inspect}
// 1248:           end
// 1249:         RUBY
// 1250:       end
// 1251:       let(:f_bar) do
// 1252:         formula do
// 1253:           T.bind(self, T.class_of(Formula))
// 1254:           url "https://brew.sh/bar-1.0.tgz"
// 1255:           homepage "https://brew.sh"
// 1256:         end
// 1257:       end
// 1258:
// 1259:       before do
// 1260:         allow(fa.formula.deps.first).to receive(:to_formula).and_return(f_bar)
// 1261:         fa.audit_deps
// 1262:       end
// 1263:
// 1264:       describe ":build" do
// 1265:         let(:tag) { :build }
// 1266:
// 1267:         it(:problems) { expect(f_a.problems).to be_empty }
// 1268:       end
// 1269:
// 1270:       describe ":run" do
// 1271:         let(:tag) { :run }
// 1272:
// 1273:         it(:problems) do
// 1274:           expect(f_a.problems).to include(a_hash_including(message: a_string_matching(/is a no-op/)))
// 1275:         end
// 1276:       end
// 1277:
// 1278:       describe ":linked" do
// 1279:         let(:tag) { :linked }
// 1280:
// 1281:         it(:problems) do
// 1282:           expect(f_a.problems).to include(a_hash_including(message: a_string_matching(/is a no-op/)))
// 1283:         end
// 1284:       end
// 1285:
// 1286:       describe ":optional" do
// 1287:         let(:tag) { :optional }
// 1288:
// 1289:         it(:problems) { expect(f_a.problems).to be_empty }
// 1290:
// 1291:         describe "in core tap" do
// 1292:           let(:core_tap) { true }
// 1293:
// 1294:           it(:problems) do
// 1295:             expect(f_a.problems).to include(a_hash_including(message: a_string_matching(/should not have optional/)))
// 1296:           end
// 1297:         end
// 1298:       end
// 1299:
// 1300:       describe "when invalid" do
// 1301:         let(:tag) { :foo }
// 1302:
// 1303:         it(:problems) do
// 1304:           expect(f_a.problems).to include(a_hash_including(message: a_string_matching(/is not a valid tag/)))
// 1305:         end
// 1306:       end
// 1307:
// 1308:       describe "when undefined option" do
// 1309:         let(:tag) { "with-debug" }
// 1310:
// 1311:         it(:problems) do
// 1312:           expect(f_a.problems).to include(a_hash_including(message: a_string_matching(/does not define option/)))
// 1313:         end
// 1314:       end
// 1315:
// 1316:       describe "when defined option" do
// 1317:         let(:tag) { "with-debug" }
// 1318:         let(:f_bar) do
// 1319:           formula do
// 1320:             T.bind(self, T.class_of(Formula))
// 1321:             url "https://brew.sh/bar-1.0.tgz"
// 1322:             homepage "https://brew.sh"
// 1323:             option "with-debug"
// 1324:           end
// 1325:         end
// 1326:
// 1327:         it(:problems) { expect(f_a.problems).to be_empty }
// 1328:       end
// 1329:     end
// 1330:
// 1331:     describe "when formula lacks OS requirement but has OS-specific dependency" do
// 1332:       subject(:f_a) { fa }
// 1333:
// 1334:       let(:fa) do
// 1335:         formula_auditor "foo", <<~RUBY, core_tap: true
// 1336:           class Foo < Formula
// 1337:             url "https://brew.sh/foo-1.0.tgz"
// 1338:             homepage "https://brew.sh"
// 1339:
// 1340:             depends_on "os-only"
// 1341:           end
// 1342:         RUBY
// 1343:       end
// 1344:
// 1345:       before do
// 1346:         allow(fa.formula.deps.first).to receive(:to_formula).and_return(f_os_only)
// 1347:       end
// 1348:
// 1349:       describe "for macOS when running on Linux" do
// 1350:         let(:f_os_only) do
// 1351:           formula do
// 1352:             T.bind(self, T.class_of(Formula))
// 1353:             url "https://brew.sh/os-only-1.0.tgz"
// 1354:             homepage "https://brew.sh"
// 1355:
// 1356:             depends_on :macos
// 1357:           end
// 1358:         end
// 1359:
// 1360:         around do |example|
// 1361:           Homebrew::SimulateSystem.with(os: :linux) do
// 1362:             example.run
// 1363:           end
// 1364:         end
// 1365:
// 1366:         it "reports missing requirement" do
// 1367:           fa.audit_deps
// 1368:           expect(f_a.problems).to include(a_hash_including(message: a_string_matching(/has a macOS requirement/)))
// 1369:         end
// 1370:       end
// 1371:
// 1372:       describe "for Linux when running on macOS" do
// 1373:         let(:f_os_only) do
// 1374:           formula do
// 1375:             T.bind(self, T.class_of(Formula))
// 1376:             url "https://brew.sh/os-only-1.0.tgz"
// 1377:             homepage "https://brew.sh"
// 1378:
// 1379:             depends_on :linux
// 1380:           end
// 1381:         end
// 1382:
// 1383:         around do |example|
// 1384:           Homebrew::SimulateSystem.with(os: :macos) do
// 1385:             example.run
// 1386:           end
// 1387:         end
// 1388:
// 1389:         it "reports missing requirement" do
// 1390:           fa.audit_deps
// 1391:           expect(f_a.problems).to include(a_hash_including(message: a_string_matching(/has a Linux requirement/)))
// 1392:         end
// 1393:       end
// 1394:     end
// 1395:   end
// 1396:
// 1397:   describe "#audit_stable_version" do
// 1398:     subject do
// 1399:       fa = described_class.new(Formulary.factory(formula_path), git: true)
// 1400:       fa.audit_stable_version
// 1401:       fa.problems.first&.fetch(:message)
// 1402:     end
// 1403:
// 1404:     # Mock tap behaviour the Formula helper expects (e.g. PyPI lookups, audit exceptions).
// 1405:     before do
// 1406:       origin_formula_path.dirname.mkpath
// 1407:       origin_formula_path.write <<~RUBY
// 1408:         class Foo#{foo_version} < Formula
// 1409:           url "https://brew.sh/foo-1.0.tar.gz"
// 1410:           sha256 "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 1411:           revision 2
// 1412:           version_scheme 1
// 1413:         end
// 1414:       RUBY
// 1415:
// 1416:       origin_tap_path.mkpath
// 1417:       origin_tap_path.cd do
// 1418:         system "git", "init"
// 1419:         system "git", "add", "--all"
// 1420:         system "git", "commit", "-m", "init"
// 1421:       end
// 1422:
// 1423:       tap_path.mkpath
// 1424:       tap_path.cd do
// 1425:         system "git", "clone", origin_tap_path, "."
// 1426:       end
// 1427:     end
// 1428:
// 1429:     describe "versions" do
// 1430:       context "when uncommitted should not change formatting" do
// 1431:         before { formula_gsub "foo-1.0.tar.gz", "foo-1.0.0.tar.gz" }
// 1432:
// 1433:         it { is_expected.to match("Stable: version should not change from 1.0 to 1.0.0") }
// 1434:       end
// 1435:
// 1436:       context "when uncommitted should not decrease" do
// 1437:         before { formula_gsub "foo-1.0.tar.gz", "foo-0.9.tar.gz" }
// 1438:
// 1439:         it { is_expected.to match("Stable: version should not decrease (from 1.0 to 0.9)") }
// 1440:       end
// 1441:
// 1442:       context "when committed can decrease" do
// 1443:         before do
// 1444:           formula_gsub_origin_commit "revision 2"
// 1445:           formula_gsub_origin_commit "foo-1.0.tar.gz", "foo-0.9.tar.gz"
// 1446:         end
// 1447:
// 1448:         it { is_expected.to be_nil }
// 1449:       end
// 1450:
// 1451:       describe "can decrease with version_scheme increased" do
// 1452:         before do
// 1453:           formula_gsub "revision 2"
// 1454:           formula_gsub "foo-1.0.tar.gz", "foo-0.9.tar.gz"
// 1455:           formula_gsub "version_scheme 1", "version_scheme 2"
// 1456:         end
// 1457:
// 1458:         it { is_expected.to be_nil }
// 1459:       end
// 1460:     end
// 1461:   end
// 1462:
// 1463:   describe "#audit_revision dependency relationships" do
// 1464:     subject do
// 1465:       fa = described_class.new(Formulary.factory(formula_path), git: true)
// 1466:       fa.audit_revision
// 1467:       fa.problems.first&.fetch(:message)
// 1468:     end
// 1469:
// 1470:     before do
// 1471:       origin_formula_path.dirname.mkpath
// 1472:       origin_formula_path.write <<~RUBY
// 1473:         class Foo#{foo_version} < Formula
// 1474:           url "https://brew.sh/foo-1.0.tar.gz"
// 1475:           sha256 "31cccfc6630528db1c8e3a06f6decf2a370060b982841cfab2b8677400a5092e"
// 1476:           revision 2
// 1477:           version_scheme 1
// 1478:         end
// 1479:       RUBY
// 1480:
// 1481:       origin_tap_path.mkpath
// 1482:       origin_tap_path.cd do
// 1483:         system "git", "init"
// 1484:         system "git", "add", "--all"
// 1485:         system "git", "commit", "-m", "init"
// 1486:       end
// 1487:
// 1488:       tap_path.mkpath
// 1489:       tap_path.cd do
// 1490:         system "git", "clone", origin_tap_path, "."
// 1491:       end
// 1492:     end
// 1493:
// 1494:     describe "new formulae should not have a revision" do
// 1495:       it "doesn't allow new formulae to have a revision" do
// 1496:         fa = formula_auditor "foo", <<~RUBY, new_formula: true
// 1497:           class Foo < Formula
// 1498:             url "https://brew.sh/foo-1.0.tgz"
// 1499:             revision 1
// 1500:           end
// 1501:         RUBY
// 1502:
// 1503:         fa.audit_revision
// 1504:
// 1505:         expect(fa.new_formula_problems).to include(
// 1506:           a_hash_including(message: a_string_matching(/should not define a revision/)),
// 1507:         )
// 1508:       end
// 1509:     end
// 1510:
// 1511:     describe "revisions" do
// 1512:       describe "should not be removed when first committed above 0" do
// 1513:         it { is_expected.to be_nil }
// 1514:       end
// 1515:
// 1516:       describe "with the same version, should not decrease" do
// 1517:         before { formula_gsub_origin_commit "revision 2", "revision 1" }
// 1518:
// 1519:         it { is_expected.to match("`revision` should not decrease (from 2 to 1)") }
// 1520:       end
// 1521:
// 1522:       describe "should not be removed with the same version" do
// 1523:         before { formula_gsub_origin_commit "revision 2" }
// 1524:
// 1525:         it { is_expected.to match("`revision` should not decrease (from 2 to 0)") }
// 1526:       end
// 1527:
// 1528:       describe "should not decrease with the same, uncommitted version" do
// 1529:         before { formula_gsub "revision 2", "revision 1" }
// 1530:
// 1531:         it { is_expected.to match("`revision` should not decrease (from 2 to 1)") }
// 1532:       end
// 1533:
// 1534:       describe "should be removed with a newer version" do
// 1535:         before { formula_gsub_origin_commit "foo-1.0.tar.gz", "foo-1.1.tar.gz" }
// 1536:
// 1537:         it { is_expected.to match("`revision 2` should be removed") }
// 1538:       end
// 1539:
// 1540:       describe "should be removed with a newer local version" do
// 1541:         before { formula_gsub "foo-1.0.tar.gz", "foo-1.1.tar.gz" }
// 1542:
// 1543:         it { is_expected.to match("`revision 2` should be removed") }
// 1544:       end
// 1545:
// 1546:       describe "should not warn on an newer version revision removal" do
// 1547:         before do
// 1548:           formula_gsub_origin_commit "revision 2", ""
// 1549:           formula_gsub_origin_commit "foo-1.0.tar.gz", "foo-1.1.tar.gz"
// 1550:         end
// 1551:
// 1552:         it { is_expected.to be_nil }
// 1553:       end
// 1554:
// 1555:       describe "should not warn when revision from previous version matches current revision" do
// 1556:         before do
// 1557:           formula_gsub_origin_commit "foo-1.0.tar.gz", "foo-1.1.tar.gz"
// 1558:           formula_gsub_origin_commit "revision 2", "# no revision"
// 1559:           formula_gsub_origin_commit "# no revision", "revision 1"
// 1560:           formula_gsub_origin_commit "revision 1", "revision 2"
// 1561:         end
// 1562:
// 1563:         it { is_expected.to be_nil }
// 1564:       end
// 1565:
// 1566:       describe "should only increment by 1 with an uncommitted version" do
// 1567:         before do
// 1568:           formula_gsub "foo-1.0.tar.gz", "foo-1.1.tar.gz"
// 1569:           formula_gsub "revision 2", "revision 4"
// 1570:         end
// 1571:
// 1572:         it { is_expected.to match("`revision` should only increment by 1") }
// 1573:       end
// 1574:
// 1575:       describe "should not warn on past increment by more than 1" do
// 1576:         before do
// 1577:           formula_gsub_origin_commit "revision 2", "# no revision"
// 1578:           formula_gsub_origin_commit "foo-1.0.tar.gz", "foo-1.1.tar.gz"
// 1579:           formula_gsub_origin_commit "# no revision", "revision 3"
// 1580:         end
// 1581:
// 1582:         it { is_expected.to be_nil }
// 1583:       end
// 1584:     end
// 1585:   end
// 1586:
// 1587:   def build_formula_for_audit(tap:, tap_path:, name:, compatibility_version: nil, revision: 0, depends_on: [])
// 1588:     path = tap_path/"Formula/#{name}.rb"
// 1589:     path.dirname.mkpath
// 1590:     path.write(test_formula_source(name:, compatibility_version:, revision:, depends_on:))
// 1591:
// 1592:     Formulary.clear_cache
// 1593:     formula = Formulary.factory(path)
// 1594:     allow(formula).to receive_messages(tap:, full_name: "#{tap.name}/#{name}")
// 1595:
// 1596:     formula
// 1597:   end
// 1598:
// 1599:   def dependency_stub(name)
// 1600:     instance_double(Dependency, name:)
// 1601:   end
// 1602:
// 1603:   def stub_committed_info(auditor, default:, overrides: {})
// 1604:     allow(auditor).to receive(:committed_version_info) do |*_args, **kwargs|
// 1605:       formula = kwargs.fetch(:formula, auditor.formula)
// 1606:       raw = overrides.fetch(formula, default)
// 1607:       committed = raw.map { |info| info ? info.dup : {} }
// 1608:       committed.each do |info|
// 1609:         info[:version] ||= formula.stable&.version
// 1610:         info[:revision] = info.fetch(:revision, formula.revision)
// 1611:         info[:compatibility_version] = info.fetch(:compatibility_version, formula.compatibility_version)
// 1612:         info[:version_scheme] = info.fetch(:version_scheme, formula.version_scheme)
// 1613:       end
// 1614:       committed.each(&:compact!)
// 1615:       committed
// 1616:     end
// 1617:   end
// 1618:
// 1619:   def stub_changed_paths(auditor, all_paths:, filtered_paths: all_paths)
// 1620:     allow(auditor).to receive(:changed_formulae_paths) do |_tap_arg, only_names: nil|
// 1621:       only_names ? filtered_paths : all_paths
// 1622:     end
// 1623:   end
// 1624:
// 1625:   describe "#changed_formulae_paths" do
// 1626:     let(:tap_path) { Pathname("#{dir}/changed-paths-tap") }
// 1627:     let(:tap) do
// 1628:       instance_double(
// 1629:         Tap,
// 1630:         git?:        true,
// 1631:         core_tap?:   false,
// 1632:         path:        tap_path,
// 1633:         formula_dir: tap_path/"Formula",
// 1634:         name:        "homebrew/core",
// 1635:       )
// 1636:     end
// 1637:     let(:target_formula) do
// 1638:       build_formula_for_audit(
// 1639:         tap:,
// 1640:         tap_path:,
// 1641:         name:     "bar",
// 1642:       )
// 1643:     end
// 1644:     let(:auditor) { described_class.new(target_formula, git: true) }
// 1645:     let(:foo_path) { tap_path/"Formula/f/foo.rb" }
// 1646:
// 1647:     it "resolves sharded formula paths when filtering by names" do
// 1648:       foo_path.dirname.mkpath
// 1649:       foo_path.write(test_formula_source(name: "foo"))
// 1650:       allow(tap).to receive(:formula_files_by_name)
// 1651:         .and_return({ "foo" => foo_path, "bar" => tap_path/"Formula/bar.rb" })
// 1652:       allow(Utils).to receive(:popen_read).and_call_original
// 1653:       allow(Utils).to receive(:popen_read).with(Utils::Git.git, "-C", tap.path, "merge-base", "origin/HEAD", "HEAD")
// 1654:                                           .and_return("merge-base-sha\n")
// 1655:       allow(Utils).to receive(:safe_popen_read).and_return("Formula/f/foo.rb\n")
// 1656:
// 1657:       paths = auditor.changed_formulae_paths(tap, only_names: ["foo"])
// 1658:
// 1659:       expect(paths).to eq([foo_path])
// 1660:     end
// 1661:
// 1662:     it "diffs against the merge-base with origin/HEAD" do
// 1663:       foo_path.dirname.mkpath
// 1664:       foo_path.write(test_formula_source(name: "foo"))
// 1665:       allow(tap).to receive(:formula_files_by_name).and_return({ "foo" => foo_path })
// 1666:       allow(Utils).to receive(:popen_read).and_call_original
// 1667:       allow(Utils).to receive(:popen_read).with(Utils::Git.git, "-C", tap.path, "merge-base", "origin/HEAD", "HEAD")
// 1668:                                           .and_return("merge-base-sha\n")
// 1669:       expect(Utils).to receive(:safe_popen_read).with(Utils::Git.git, "-C", tap.path, "diff", "--name-only",
// 1670:                                                       "merge-base-sha")
// 1671:                                                 .and_return("Formula/f/foo.rb\n")
// 1672:
// 1673:       expect(auditor.changed_formulae_paths(tap, only_names: ["foo"])).to eq([foo_path])
// 1674:     end
// 1675:   end
// 1676:
// 1677:   describe "#committed_version_info" do
// 1678:     let(:tap_path) { Pathname("#{dir}/committed-version-info-tap") }
// 1679:     let(:tap) do
// 1680:       instance_double(
// 1681:         Tap,
// 1682:         git?:        true,
// 1683:         core_tap?:   false,
// 1684:         path:        tap_path,
// 1685:         formula_dir: tap_path/"Formula",
// 1686:         name:        "homebrew/core",
// 1687:       )
// 1688:     end
// 1689:     let(:target_formula) do
// 1690:       build_formula_for_audit(
// 1691:         tap:,
// 1692:         tap_path:,
// 1693:         name:     "foo",
// 1694:       )
// 1695:     end
// 1696:     let(:auditor) { described_class.new(target_formula, git: true) }
// 1697:     let(:formula_versions) { instance_double(FormulaVersions) }
// 1698:
// 1699:     it "walks history from the merge-base with origin/HEAD" do
// 1700:       allow(Utils).to receive(:popen_read).and_call_original
// 1701:       allow(Utils).to receive(:popen_read).with(Utils::Git.git, "-C", tap.path, "merge-base", "origin/HEAD", "HEAD")
// 1702:                                           .and_return("merge-base-sha\n")
// 1703:       allow(FormulaVersions).to receive(:new).with(target_formula).and_return(formula_versions)
// 1704:       expect(formula_versions).to receive(:rev_list).with("merge-base-sha")
// 1705:
// 1706:       auditor.committed_version_info
// 1707:     end
// 1708:   end
// 1709:
// 1710:   describe "#audit_compatibility_version" do
// 1711:     let(:tap_path) { Pathname("#{dir}/compat-tap") }
// 1712:     let(:tap) do
// 1713:       instance_double(
// 1714:         Tap,
// 1715:         git?:             true,
// 1716:         core_tap?:        false,
// 1717:         git_repository:   instance_double(GitRepository, origin_branch_name: "main"),
// 1718:         audit_exceptions: {},
// 1719:         formula_renames:  {},
// 1720:         path:             tap_path,
// 1721:         name:             "test/tap",
// 1722:       )
// 1723:     end
// 1724:     let(:current_compatibility_version) { 2 }
// 1725:     let(:target_formula) do
// 1726:       build_formula_for_audit(
// 1727:         tap:,
// 1728:         tap_path:,
// 1729:         name:                  "foo",
// 1730:         compatibility_version: current_compatibility_version,
// 1731:       )
// 1732:     end
// 1733:     let(:auditor) { described_class.new(target_formula, git: true) }
// 1734:     let(:foo_path) { tap_path/"Formula/foo.rb" }
// 1735:     let(:bar_path) { tap_path/"Formula/bar.rb" }
// 1736:
// 1737:     before do
// 1738:       allow(tap).to receive_messages(formula_dir: tap_path/"Formula")
// 1739:       allow(target_formula).to receive_messages(full_name: "test/tap/foo", recursive_dependencies: [])
// 1740:       allow(Formulary).to receive(:factory).and_call_original
// 1741:       allow(Formulary).to receive(:factory).with(foo_path).and_return(target_formula)
// 1742:     end
// 1743:
// 1744:     it "ignores formulae without a previous commit" do
// 1745:       stub_committed_info(auditor, default: [{}, {}])
// 1746:       stub_changed_paths(auditor, all_paths: [])
// 1747:
// 1748:       auditor.audit_compatibility_version
// 1749:
// 1750:       expect(auditor.problems).to be_empty
// 1751:     end
// 1752:
// 1753:     context "with existing committed compatibility_version" do
// 1754:       before do
// 1755:         stub_changed_paths(auditor, all_paths: [])
// 1756:       end
// 1757:
// 1758:       it "flags decreases" do
// 1759:         stub_committed_info(
// 1760:           auditor,
// 1761:           default: [{ compatibility_version: 2 }, { compatibility_version: 2 }],
// 1762:         )
// 1763:         allow(target_formula).to receive(:compatibility_version).and_return(1)
// 1764:
// 1765:         auditor.audit_compatibility_version
// 1766:
// 1767:         expect(auditor.problems).to include(
// 1768:           a_hash_including(message: a_string_matching(/should not decrease/)),
// 1769:         )
// 1770:       end
// 1771:
// 1772:       it "flags increments larger than one" do
// 1773:         allow(target_formula).to receive(:compatibility_version).and_return(3)
// 1774:         stub_committed_info(
// 1775:           auditor,
// 1776:           default: [{ compatibility_version: 1 }, { compatibility_version: 1 }],
// 1777:         )
// 1778:
// 1779:         auditor.audit_compatibility_version
// 1780:
// 1781:         expect(auditor.problems).to include(
// 1782:           a_hash_including(message: a_string_matching(/should only increment by 1/)),
// 1783:         )
// 1784:       end
// 1785:
// 1786:       it "allows unchanged compatibility_version" do
// 1787:         allow(target_formula).to receive(:compatibility_version).and_return(1)
// 1788:         stub_committed_info(
// 1789:           auditor,
// 1790:           default: [{ compatibility_version: 1 }, { compatibility_version: 1 }],
// 1791:         )
// 1792:
// 1793:         auditor.audit_compatibility_version
// 1794:
// 1795:         expect(auditor.problems).to be_empty
// 1796:       end
// 1797:     end
// 1798:
// 1799:     context "when compatibility_version increments by one" do
// 1800:       let(:dependent_formula) do
// 1801:         build_formula_for_audit(
// 1802:           tap:,
// 1803:           tap_path:,
// 1804:           name:       "bar",
// 1805:           revision:   2,
// 1806:           depends_on: ["foo"],
// 1807:         )
// 1808:       end
// 1809:
// 1810:       before do
// 1811:         allow(dependent_formula).to receive_messages(full_name:              "test/tap/bar",
// 1812:                                                      recursive_dependencies: [dependency_stub("foo")])
// 1813:         allow(Formulary).to receive(:factory).with(bar_path).and_return(dependent_formula)
// 1814:         stub_changed_paths(auditor, all_paths: [foo_path, bar_path])
// 1815:       end
// 1816:
// 1817:       it "flags missing dependent revision bumps" do
// 1818:         stub_committed_info(
// 1819:           auditor,
// 1820:           default:   [{ compatibility_version: 1 }, { compatibility_version: 1 }],
// 1821:           overrides: { dependent_formula => [{ revision: 2 }, { revision: 2 }] },
// 1822:         )
// 1823:
// 1824:         auditor.audit_compatibility_version
// 1825:
// 1826:         expect(auditor.problems).to include(
// 1827:           a_hash_including(
// 1828:             message: a_string_matching(
// 1829:               %r{no recursive dependent formulae increased `revision` by 1.*https://docs\.brew\.sh/Formula-Cookbook#compatibility_version},
// 1830:             ),
// 1831:           ),
// 1832:         )
// 1833:       end
// 1834:
// 1835:       it "accepts a dependent revision bump" do
// 1836:         stub_committed_info(
// 1837:           auditor,
// 1838:           default:   [{ compatibility_version: 1 }, { compatibility_version: 1 }],
// 1839:           overrides: { dependent_formula => [{ revision: 1 }, { revision: 1 }] },
// 1840:         )
// 1841:
// 1842:         auditor.audit_compatibility_version
// 1843:
// 1844:         expect(auditor.problems).to be_empty
// 1845:       end
// 1846:
// 1847:       it "ignores missing dependent revision bumps for unsupported platform" do
// 1848:         allow(target_formula).to receive(:valid_platform?).and_return(false)
// 1849:         stub_committed_info(
// 1850:           auditor,
// 1851:           default:   [{ compatibility_version: 1 }, { compatibility_version: 1 }],
// 1852:           overrides: { dependent_formula => [{ revision: 2 }, { revision: 2 }] },
// 1853:         )
// 1854:
// 1855:         auditor.audit_compatibility_version
// 1856:
// 1857:         expect(auditor.problems).to be_empty
// 1858:       end
// 1859:     end
// 1860:   end
// 1861:
// 1862:   describe "#audit_revision" do
// 1863:     let(:tap_path) { Pathname("#{dir}/revision-tap") }
// 1864:     let(:tap) do
// 1865:       instance_double(
// 1866:         Tap,
// 1867:         git?:             true,
// 1868:         core_tap?:        true,
// 1869:         git_repository:   instance_double(GitRepository, origin_branch_name: "main"),
// 1870:         audit_exceptions: {},
// 1871:         formula_renames:  {},
// 1872:         path:             tap_path,
// 1873:         name:             "test/tap",
// 1874:       )
// 1875:     end
// 1876:     let(:current_revision) { 2 }
// 1877:     let(:dependency_names) { ["foo"] }
// 1878:     let(:dependency_list) { dependency_names.map { |name| dependency_stub(name) } }
// 1879:     let(:target_formula) do
// 1880:       build_formula_for_audit(
// 1881:         tap:,
// 1882:         tap_path:,
// 1883:         name:       "bar",
// 1884:         revision:   current_revision,
// 1885:         depends_on: dependency_names,
// 1886:       )
// 1887:     end
// 1888:     let(:auditor) { described_class.new(target_formula, git: true) }
// 1889:     let(:bar_path) { tap_path/"Formula/bar.rb" }
// 1890:     let(:foo_path) { tap_path/"Formula/foo.rb" }
// 1891:     let(:current_dependency_compatibility) { 1 }
// 1892:     let(:dependency_revision) { 0 }
// 1893:     let(:dependency_formula) do
// 1894:       build_formula_for_audit(
// 1895:         tap:,
// 1896:         tap_path:,
// 1897:         name:                  "foo",
// 1898:         compatibility_version: current_dependency_compatibility,
// 1899:         revision:              dependency_revision,
// 1900:       )
// 1901:     end
// 1902:
// 1903:     before do
// 1904:       allow(tap).to receive_messages(formula_dir: tap_path/"Formula")
// 1905:       allow(target_formula).to receive_messages(full_name: "test/tap/bar", recursive_dependencies: dependency_list)
// 1906:       allow(Formulary).to receive(:factory).and_call_original
// 1907:       allow(Formulary).to receive(:factory).with(bar_path).and_return(target_formula)
// 1908:       allow(Formulary).to receive(:factory).with(foo_path).and_return(dependency_formula)
// 1909:     end
// 1910:
// 1911:     it "ignores revision changes when not incremented by one" do
// 1912:       stub_committed_info(
// 1913:         auditor,
// 1914:         default: [{ revision: current_revision }, { revision: current_revision }],
// 1915:       )
// 1916:       stub_changed_paths(auditor, all_paths: [], filtered_paths: [])
// 1917:
// 1918:       auditor.audit_revision
// 1919:
// 1920:       expect(auditor.problems).to be_empty
// 1921:     end
// 1922:
// 1923:     context "with a revision increment" do
// 1924:       before do
// 1925:         stub_committed_info(
// 1926:           auditor,
// 1927:           default: [{ revision: current_revision - 1 }, { revision: current_revision - 1 }],
// 1928:         )
// 1929:       end
// 1930:
// 1931:       it "allows revision increases when there are no recursive dependencies" do
// 1932:         allow(target_formula).to receive(:recursive_dependencies).and_return([])
// 1933:         stub_changed_paths(auditor, all_paths: [], filtered_paths: [])
// 1934:
// 1935:         auditor.audit_revision
// 1936:
// 1937:         expect(auditor.problems).to be_empty
// 1938:       end
// 1939:
// 1940:       it "allows revision increases when dependencies are unchanged" do
// 1941:         stub_changed_paths(auditor, all_paths: [], filtered_paths: [])
// 1942:
// 1943:         auditor.audit_revision
// 1944:
// 1945:         expect(auditor.problems).to be_empty
// 1946:       end
// 1947:
// 1948:       context "when dependencies change" do
// 1949:         before do
// 1950:           stub_changed_paths(auditor, all_paths: [foo_path], filtered_paths: [foo_path])
// 1951:         end
// 1952:
// 1953:         it "ignores dependency changes without a version bump" do
// 1954:           stub_committed_info(
// 1955:             auditor,
// 1956:             default:   [{ revision: current_revision - 1 }, { revision: current_revision - 1 }],
// 1957:             overrides: { dependency_formula => [{ version: "1.0" }, { version: "1.0" }] },
// 1958:           )
// 1959:           allow(dependency_formula).to receive(:compatibility_version).and_return(0)
// 1960:
// 1961:           auditor.audit_revision
// 1962:
// 1963:           expect(auditor.problems).to be_empty
// 1964:         end
// 1965:
// 1966:         it "flags missing compatibility_version bumps" do
// 1967:           stub_committed_info(
// 1968:             auditor,
// 1969:             default:   [{ revision: current_revision - 1 }, { revision: current_revision - 1 }],
// 1970:             overrides: { dependency_formula => [{ version: "0.9", compatibility_version: 1 },
// 1971:                                                 { version: "0.9", compatibility_version: 1 }] },
// 1972:           )
// 1973:           allow(dependency_formula).to receive(:compatibility_version).and_return(1)
// 1974:
// 1975:           auditor.audit_revision
// 1976:
// 1977:           expect(auditor.problems).to include(
// 1978:             a_hash_including(
// 1979:               message: a_string_matching(
// 1980:                 %r{must increase `compatibility_version` by 1 in the same PR: foo \(1 to 2\).*https://docs\.brew\.sh/Formula-Cookbook#compatibility_version},
// 1981:               ),
// 1982:             ),
// 1983:           )
// 1984:         end
// 1985:
// 1986:         it "accepts compatibility_version bumps of one" do
// 1987:           stub_committed_info(
// 1988:             auditor,
// 1989:             default:   [{ revision: current_revision - 1 }, { revision: current_revision - 1 }],
// 1990:             overrides: { dependency_formula => [{ compatibility_version: 1 }, { compatibility_version: 1 }] },
// 1991:           )
// 1992:           allow(dependency_formula).to receive(:compatibility_version).and_return(2)
// 1993:
// 1994:           auditor.audit_revision
// 1995:
// 1996:           expect(auditor.problems).to be_empty
// 1997:         end
// 1998:       end
// 1999:     end
// 2000:   end
// 2001:
// 2002:   describe "#audit_versioned_keg_only" do
// 2003:     specify "it warns when a versioned formula is not `keg_only`" do
// 2004:       fa = formula_auditor "foo@1.1", <<~RUBY, core_tap: true
// 2005:         class FooAT11 < Formula
// 2006:           url "https://brew.sh/foo-1.1.tgz"
// 2007:         end
// 2008:       RUBY
// 2009:
// 2010:       fa.audit_versioned_keg_only
// 2011:
// 2012:       expect(fa.problems.first[:message])
// 2013:         .to match("Versioned formulae in homebrew/core should use `keg_only :versioned_formula`")
// 2014:     end
// 2015:
// 2016:     specify "it warns when a versioned formula has an incorrect `keg_only` reason" do
// 2017:       fa = formula_auditor "foo@1.1", <<~RUBY, core_tap: true
// 2018:         class FooAT11 < Formula
// 2019:           url "https://brew.sh/foo-1.1.tgz"
// 2020:
// 2021:           keg_only :provided_by_macos
// 2022:         end
// 2023:       RUBY
// 2024:
// 2025:       fa.audit_versioned_keg_only
// 2026:
// 2027:       expect(fa.problems.first[:message])
// 2028:         .to match("Versioned formulae in homebrew/core should use `keg_only :versioned_formula`")
// 2029:     end
// 2030:
// 2031:     specify "it does not warn when a versioned formula has `keg_only :versioned_formula`" do
// 2032:       fa = formula_auditor "foo@1.1", <<~RUBY, core_tap: true
// 2033:         class FooAT11 < Formula
// 2034:           url "https://brew.sh/foo-1.1.tgz"
// 2035:
// 2036:           keg_only :versioned_formula
// 2037:         end
// 2038:       RUBY
// 2039:
// 2040:       fa.audit_versioned_keg_only
// 2041:
// 2042:       expect(fa.problems).to be_empty
// 2043:     end
// 2044:   end
// 2045:
// 2046:   describe "#audit_duplicate_formula" do
// 2047:     before do
// 2048:       allow(Homebrew::API::Internal).to receive(:formula_hashes).and_return(
// 2049:         { "foo" => { "stable_url_args" => ["https://brew.sh/foo-1.0.tgz"] },
// 2050:           "bar" => { "stable_url_args" => ["https://foo.com/bar-1.0.tgz"] } },
// 2051:       )
// 2052:     end
// 2053:
// 2054:     specify "it warns if new formula uses the same URL as already existing package" do
// 2055:       fa = formula_auditor "duplicate-foo", <<~RUBY, new_formula: true, core_tap: true, online: true
// 2056:         class DuplicateFoo < Formula
// 2057:           url "https://brew.sh/foo-1.0.tgz"
// 2058:         end
// 2059:       RUBY
// 2060:
// 2061:       fa.audit_duplicate_formula
// 2062:
// 2063:       expect(fa.new_formula_problems.first[:message])
// 2064:         .to match("Possible duplicate, this formula has the same stable URL as `foo`")
// 2065:     end
// 2066:
// 2067:     specify "it does not warn about duplicates if formula is not new" do
// 2068:       fa = formula_auditor "duplicate-foo", <<~RUBY, new_formula: false, core_tap: true, online: true
// 2069:         class DuplicateFoo < Formula
// 2070:           url "https://brew.sh/foo-1.0.tgz"
// 2071:         end
// 2072:       RUBY
// 2073:
// 2074:       fa.audit_duplicate_formula
// 2075:
// 2076:       expect(fa.new_formula_problems).to be_empty
// 2077:     end
// 2078:
// 2079:     specify "it skips the duplicate check offline when no packages data is cached" do
// 2080:       fa = formula_auditor "duplicate-foo", <<~RUBY, new_formula: true, core_tap: true, online: false
// 2081:         class DuplicateFoo < Formula
// 2082:           url "https://brew.sh/foo-1.0.tgz"
// 2083:         end
// 2084:       RUBY
// 2085:       allow(Homebrew::API::Internal).to receive(:cached_packages_json_file_path)
// 2086:         .and_return(Pathname("/nonexistent/packages.jws.json"))
// 2087:
// 2088:       fa.audit_duplicate_formula
// 2089:
// 2090:       expect(fa.new_formula_problems).to be_empty
// 2091:     end
// 2092:   end
// 2093:
// 2094:   describe "#audit_conflicts" do
// 2095:     before do
// 2096:       # We don't really test the formula text retrieval here
// 2097:       allow(File).to receive(:open).and_return("")
// 2098:     end
// 2099:
// 2100:     specify "it warns when conflicting with non-existing formula", :no_api do
// 2101:       foo = formula("foo") do
// 2102:         T.bind(self, T.class_of(Formula))
// 2103:         url "https://brew.sh/bar-1.0.tgz"
// 2104:
// 2105:         conflicts_with "bar"
// 2106:       end
// 2107:
// 2108:       fa = described_class.new foo
// 2109:       fa.audit_conflicts
// 2110:
// 2111:       expect(fa.problems.first[:message])
// 2112:         .to match("Can't find conflicting formula \"bar\"")
// 2113:     end
// 2114:
// 2115:     specify "it warns when conflicting with itself", :no_api do
// 2116:       foo = formula("foo") do
// 2117:         T.bind(self, T.class_of(Formula))
// 2118:         url "https://brew.sh/bar-1.0.tgz"
// 2119:
// 2120:         conflicts_with "foo"
// 2121:       end
// 2122:       stub_formula_loader foo
// 2123:
// 2124:       fa = described_class.new foo
// 2125:       fa.audit_conflicts
// 2126:
// 2127:       expect(fa.problems.first[:message])
// 2128:         .to match("Formula should not conflict with itself")
// 2129:     end
// 2130:
// 2131:     specify "it warns when another formula does not have a symmetric conflict", :no_api do
// 2132:       stub_formula_loader(
// 2133:         formula("gcc") do
// 2134:           T.bind(self, T.class_of(Formula))
// 2135:           url "gcc-1.0"
// 2136:         end,
// 2137:       )
// 2138:       stub_formula_loader(
// 2139:         formula("glibc") do
// 2140:           T.bind(self, T.class_of(Formula))
// 2141:           url "glibc-1.0"
// 2142:         end,
// 2143:       )
// 2144:
// 2145:       foo = formula("foo") do
// 2146:         T.bind(self, T.class_of(Formula))
// 2147:         url "https://brew.sh/foo-1.0.tgz"
// 2148:       end
// 2149:       stub_formula_loader foo
// 2150:
// 2151:       bar = formula("bar") do
// 2152:         T.bind(self, T.class_of(Formula))
// 2153:         url "https://brew.sh/bar-1.0.tgz"
// 2154:
// 2155:         conflicts_with "foo"
// 2156:       end
// 2157:
// 2158:       fa = described_class.new bar
// 2159:       fa.audit_conflicts
// 2160:
// 2161:       expect(fa.problems.first[:message])
// 2162:         .to match("Formula foo should also have a conflict declared with bar")
// 2163:     end
// 2164:   end
// 2165:
// 2166:   describe "#audit_deprecate_disable" do
// 2167:     specify "it warns when deprecate/disable reason is invalid" do
// 2168:       fa = formula_auditor "foo", <<~RUBY
// 2169:         class Foo < Formula
// 2170:           url "https://brew.sh/foo-1.0.tgz"
// 2171:
// 2172:         deprecate! date: "2021-01-01", because: :foobar
// 2173:         end
// 2174:       RUBY
// 2175:
// 2176:       mkdir_p fa.formula.prefix
// 2177:       fa.audit_deprecate_disable
// 2178:       expect(fa.problems.first[:message])
// 2179:         .to match("foobar is not a valid deprecate! or disable! reason")
// 2180:     end
// 2181:
// 2182:     specify "it does not warn when deprecate/disable reason is valid" do
// 2183:       fa = formula_auditor "foo", <<~RUBY
// 2184:         class Foo < Formula
// 2185:           url "https://brew.sh/foo-1.0.tgz"
// 2186:
// 2187:         deprecate! date: "2021-01-01", because: :repo_archived
// 2188:         end
// 2189:       RUBY
// 2190:
// 2191:       mkdir_p fa.formula.prefix
// 2192:       fa.audit_deprecate_disable
// 2193:       expect(fa.problems).to be_empty
// 2194:     end
// 2195:   end
// 2196:
// 2197:   describe "#audit_gcc_dependency" do
// 2198:     let(:formula_text) do
// 2199:       <<~RUBY
// 2200:         class Foo < Formula
// 2201:           url "https://brew.sh/foo-1.0.tgz"
// 2202:           homepage "https://brew.sh"
// 2203:
// 2204:           on_linux do
// 2205:             depends_on "gcc"
// 2206:           end
// 2207:         end
// 2208:       RUBY
// 2209:     end
// 2210:
// 2211:     context "when running on macOS" do
// 2212:       before do
// 2213:         allow(Homebrew::SimulateSystem).to receive(:simulating_or_running_on_linux?).and_return(false)
// 2214:       end
// 2215:
// 2216:       it "skips the audit" do
// 2217:         fa = formula_auditor "foo", formula_text, new_formula: false, core_tap: true
// 2218:         fa.audit_gcc_dependency
// 2219:         expect(fa.problems).to be_empty
// 2220:       end
// 2221:     end
// 2222:
// 2223:     context "when running on Linux" do
// 2224:       around do |example|
// 2225:         Homebrew::SimulateSystem.with os: :linux do
// 2226:           example.run
// 2227:         end
// 2228:       end
// 2229:
// 2230:       it "detects a Linux-only GCC dependency" do
// 2231:         fa = formula_auditor "foo", formula_text, new_formula: false, core_tap: true
// 2232:         fa.audit_gcc_dependency
// 2233:         expect(fa.problems.first[:message])
// 2234:           .to match "Formulae in homebrew/core should not have a Linux-only dependency on GCC"
// 2235:       end
// 2236:
// 2237:       it "allows a Linux-only GCC dependency when formula has an audit exception" do
// 2238:         tap_audit_exceptions = { linux_only_gcc_dependency_allowlist: ["foo"] }
// 2239:         fa = formula_auditor("foo", formula_text, new_formula: false, core_tap: true, tap_audit_exceptions:)
// 2240:         fa.audit_gcc_dependency
// 2241:         expect(fa.problems).to be_empty
// 2242:       end
// 2243:
// 2244:       it "allows a Linux-only GCC dependency when implicit" do
// 2245:         fa = formula_auditor "foo", formula_text, new_formula: false, core_tap: true
// 2246:         allow(fa.formula).to receive(:deps).and_return([Dependency.new("gcc", [:implicit])])
// 2247:         fa.audit_gcc_dependency
// 2248:         expect(fa.problems).to be_empty
// 2249:       end
// 2250:
// 2251:       it "allows a Linux-only GCC dependency in a non-core tap" do
// 2252:         fa = formula_auditor "foo", formula_text, new_formula: false, core_tap: false
// 2253:         fa.audit_gcc_dependency
// 2254:         expect(fa.problems).to be_empty
// 2255:       end
// 2256:
// 2257:       it "allows a non-OS-specific GCC dependency" do
// 2258:         fa = formula_auditor "foo", <<~RUBY, new_formula: false, core_tap: true
// 2259:           class Foo < Formula
// 2260:             url "https://brew.sh/foo-1.0.tgz"
// 2261:             homepage "https://brew.sh"
// 2262:
// 2263:             depends_on "gcc"
// 2264:           end
// 2265:         RUBY
// 2266:         fa.audit_gcc_dependency
// 2267:         expect(fa.problems).to be_empty
// 2268:       end
// 2269:     end
// 2270:   end
// 2271: end
