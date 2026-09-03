module homebrew

import os

// Translated from Homebrew/brew `formula_auditor.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct FormulaAuditProblem {
pub:
	message   string
	location  string
	corrected bool
}

pub struct FormulaAuditStyleOffense {
pub:
	cop_name  string
	message   string
	location  string
	corrected bool
}

pub struct FormulaAuditResource {
pub:
	name     string
	using    string
	problems []string
}

pub struct FormulaAuditSpec {
pub:
	kind          string
	url           string
	version       string
	checksum      string
	using         string
	branch        string
	resources     []FormulaAuditResource
	patches       []string
	problems      []string
	release_error string
}

pub struct FormulaAuditDependency {
pub:
	name                     string
	canonical_name           string
	full_name                string
	oldnames                 []string
	options                  []string
	defined_options          []string
	recommended_requirements []string
	optional_requirements    []string
	tags                     []string
	uses_from_macos          bool
	available                bool = true
	ambiguous                bool
	cross_tap_missing        bool
	has_tap                  bool = true
	core_tap                 bool
	deprecated               bool
	disabled                 bool
	supports_linux           bool = true
	supports_macos           bool = true
	keg_only                 bool
	provided_by_macos        bool
	keg_reason_applicable    bool = true
	implicit                 bool
}

pub struct FormulaAuditConflict {
pub:
	name                   string
	available              bool = true
	ambiguous              bool
	cross_tap_missing      bool
	same_tap               bool = true
	canonical_name         string
	is_self                bool
	declared_through_alias bool
	reverse_conflict       bool
	reverse_alias_name     string
	reverse_canonical_name string
}

pub struct FormulaAuditRepoData {
pub:
	archived    bool
	archived_at string
	warning     string
}

pub struct FormulaAuditSyncedFormula {
pub:
	name    string
	version string
}

pub struct FormulaAuditChangedFormula {
pub:
	name                  string
	path                  string
	version               string
	revision              int
	compatibility_version int
	dependencies          []string
	committed             FormulaAuditVersionInfo
}

pub struct FormulaAuditVersionInfo {
pub:
	url                       string
	version                   string
	checksum                  string
	revision                  int
	has_revision              bool
	version_scheme            int
	has_version_scheme        bool
	compatibility_version     int
	has_compatibility_version bool
}

pub struct FormulaAuditHistoryEntry {
pub:
	info FormulaAuditVersionInfo
}

pub struct FormulaAuditFormula {
pub:
	name                       string
	full_name                  string
	path                       string
	expected_path              string
	tap_name                   string
	tap_path                   string
	tap_alias_dir              string
	tap_repository             string
	tap_git                    bool
	core_formula               bool
	versioned_formula          bool
	stable                     bool
	disabled                   bool
	deprecated                 bool
	deprecation_reason         string
	version                    string
	stable_url                 string
	stable_checksum            string
	head_url                   string
	homepage                   string
	homepage_browsed_recently  bool
	license                    string
	licenses                   []string
	license_exceptions         []string
	valid_licenses             []string
	deprecated_licenses        []string
	valid_license_exceptions   []string
	github_license             string
	github_tag                 string
	aliases                    []string
	all_core_aliases           []string
	versioned_formula_names    []string
	formula_renames            map[string]string
	core_names                 []string
	cask_tokens                []string
	disallowed_name_reason     string
	synced_versions            []FormulaAuditSyncedFormula
	dependencies               []FormulaAuditDependency
	has_linux_requirement      bool
	depends_on_macos_top_level bool
	depends_on_linux_top_level bool
	runtime_formula_names      []string
	conflicts                  []FormulaAuditConflict
	requirements_recommended   bool
	requirements_optional      bool
	node_package_paths         []string
	libexec_node_modules       bool
	bottle_defined             bool
	keg_only                   bool
	keg_reason_versioned       bool
	keg_reason_by_macos        bool
	relicensed_version         string
	prefix_directory           bool
	empty_installation         bool
	revision                   int
	version_scheme             int
	compatibility_version      int
	has_compatibility_version  bool
	valid_platform             bool = true
	recursive_dependency_names []string
	bin_names                  []string
	text                       string
	tap_migration              bool
	deprecate_disable_error    string
	stable_spec                ?FormulaAuditSpec
	head_spec                  ?FormulaAuditSpec
	duplicate_urls             map[string][]string
	eol                        bool
	eol_from                   string
	github_repo                FormulaAuditRepoData
	gitlab_repo                FormulaAuditRepoData
	forgejo_repo               FormulaAuditRepoData
	bitbucket_repo             FormulaAuditRepoData
	linux                      bool
	linux_glibc_ci_version     string
	linux_glibc_next_version   string
	variation_dependencies     map[string][]string
	valid_variation_tags       []string
	changed_formulae           []FormulaAuditChangedFormula
	committed_previous         FormulaAuditVersionInfo
	committed_base             FormulaAuditVersionInfo
	merge_base                 string
	diff_paths                 []string
	formula_dir                string
	formula_files_by_name      map[string]string
}

pub struct FormulaAuditorOptions {
pub:
	new_formula            bool
	has_new_formula        bool
	strict                 bool
	online                 bool
	git                    bool
	display_cop_names      bool
	only                   []string
	except                 []string
	style_offenses         []FormulaAuditStyleOffense
	core_tap               bool
	tap_audit              bool
	tap_audit_staging      bool
	staging_formula        string
	audit_exceptions       map[string][]string
	audit_exception_values map[string]string
	self_submission_owners []string
	homepage_problem       string
	development_curl_ok    bool = true
	github_runner          bool
	github_self_hosted     bool
	throttle_rate          int
	throttle_days          int
	has_throttle_days      bool
	throttle_allows_bump   bool = true
}

pub struct FormulaAuditor {
pub:
	formula               FormulaAuditFormula
	text                  string
	versioned_formula     bool
	new_formula           bool
	new_formula_inclusive bool
	core_tap              bool
	options               FormulaAuditorOptions
pub mut:
	problems             []FormulaAuditProblem
	new_formula_problems []FormulaAuditProblem
}

fn formula_audit_contains(values []string, value string) bool {
	return value in values
}

fn formula_audit_starts_with_any(value string, prefixes []string) bool {
	for prefix in prefixes {
		if value.starts_with(prefix) {
			return true
		}
	}
	return false
}

fn formula_audit_exception(auditor FormulaAuditor, category string, values ...string) bool {
	allowed := auditor.options.audit_exceptions[category] or { return false }
	for value in values {
		if value in allowed {
			return true
		}
	}
	return false
}

fn formula_audit_version_parts(version string) []int {
	mut parts := []int{}
	mut digits := ''
	for character in version {
		if character.is_digit() {
			digits += character.ascii_str()
		} else if digits != '' {
			parts << digits.int()
			digits = ''
		}
	}
	if digits != '' {
		parts << digits.int()
	}
	return parts
}

fn formula_audit_compare_versions(left string, right string) int {
	lp := formula_audit_version_parts(left)
	rp := formula_audit_version_parts(right)
	length := if lp.len > rp.len { lp.len } else { rp.len }
	for index in 0 .. length {
		l := if index < lp.len { lp[index] } else { 0 }
		r := if index < rp.len { rp[index] } else { 0 }
		if l < r {
			return -1
		}
		if l > r {
			return 1
		}
	}
	return 0
}

fn formula_audit_major(version string) string {
	parts := formula_audit_version_parts(version)
	return if parts.len > 0 { parts[0].str() } else { '' }
}

fn formula_audit_major_minor(version string) string {
	parts := formula_audit_version_parts(version)
	if parts.len == 0 {
		return ''
	}
	return if parts.len == 1 { parts[0].str() } else { '${parts[0]}.${parts[1]}' }
}

fn formula_audit_repo_from_url(url string, host string) ?(string, string) {
	needle := '://${host}/'
	start := url.index(needle) or { return none }
	rest := url[start + needle.len..]
	parts := rest.split('/')
	if parts.len < 2 || parts[0] == '' || parts[1] == '' {
		return none
	}
	return parts[0], parts[1].trim_string_right('.git')
}

fn formula_audit_problem(mut auditor FormulaAuditor, message string) {
	auditor.problems << FormulaAuditProblem{ message: message }
}

fn formula_audit_new_problem(mut auditor FormulaAuditor, message string) {
	auditor.new_formula_problems << FormulaAuditProblem{ message: message }
}

// Ruby attr_reader `attr_reader :formula` at line 24.
pub fn ruby_formula_auditor_l24_d1_formula(auditor FormulaAuditor) FormulaAuditFormula {
	return auditor.formula
}

// Ruby attr_reader `attr_reader :text` at line 27.
pub fn ruby_formula_auditor_l27_d2_text(auditor FormulaAuditor) string {
	return auditor.text
}

// Ruby attr_reader `attr_reader :problems` at line 30.
pub fn ruby_formula_auditor_l30_d3_problems(auditor FormulaAuditor) []FormulaAuditProblem {
	return auditor.problems.clone()
}

// Ruby attr_reader `attr_reader :new_formula_problems` at line 33.
pub fn ruby_formula_auditor_l33_d4_new_formula_problems(auditor FormulaAuditor) []FormulaAuditProblem {
	return auditor.new_formula_problems.clone()
}

// Ruby method `initialize(formula, new_formula: nil, strict: nil, online: nil, git: nil, display_cop_names: nil, only: nil,` at line 52.
pub fn ruby_formula_auditor_l52_d5_initialize(formula FormulaAuditFormula, options FormulaAuditorOptions) FormulaAuditor {
	return FormulaAuditor{
		formula: formula
		text: formula.text
		versioned_formula: formula.versioned_formula
		new_formula_inclusive: options.has_new_formula && options.new_formula
		new_formula: options.has_new_formula && options.new_formula && !formula.versioned_formula
		core_tap: formula.core_formula || options.core_tap
		options: options
	}
}

// Ruby method `audit_style` at line 80.
pub fn ruby_formula_auditor_l80_d6_audit_style(mut auditor FormulaAuditor) {
	for offense in auditor.options.style_offenses {
		prefix := if auditor.options.display_cop_names { '${offense.cop_name}: ' } else { '' }
		auditor.problems << FormulaAuditProblem{
			message: '${prefix}${offense.message}'
			location: offense.location
			corrected: offense.corrected
		}
	}
}

// Ruby method `audit_file` at line 92.
pub fn ruby_formula_auditor_l92_d7_audit_file(mut auditor FormulaAuditor) {
	f := auditor.formula
	if f.core_formula && auditor.versioned_formula {
		unversioned_name := f.name.all_before('@')
		if unversioned_name in f.formula_renames {
			return
		}
		unversioned_path := f.path.replace('@${f.name.all_after('@')}.rb', '.rb')
		if !os.exists(unversioned_path) {
			formula_audit_problem(mut auditor, '${f.name} is versioned but no ${unversioned_name} formula exists')
		}
	} else if f.stable && !auditor.versioned_formula && f.versioned_formula_names.len > 0 {
		mut versioned_aliases := f.aliases.filter(it.contains('@'))
		unversioned_aliases := f.aliases.filter(!it.contains('@'))
		last_alias_version := f.versioned_formula_names.last().all_after('@')
		major := formula_audit_major(f.version)
		major_minor := formula_audit_major_minor(f.version)
		alias_name := if last_alias_version.split('.').len == 1 {
			'${f.name}@${major}'
		} else {
			'${f.name}@${major_minor}'
		}
		mut valid_main := ['${f.name}@${major}', '${f.name}@${major_minor}']
		if valid_main.len == 2 && valid_main[0] == valid_main[1] {
			valid_main = valid_main[..1].clone()
		}
		mut valid_other := []string{}
		for name in unversioned_aliases {
			for candidate in ['${name}@${major}', '${name}@${major_minor}'] {
				if candidate !in valid_other { valid_other << candidate }
			}
		}
		if !auditor.core_tap && f.tap_name != '' {
			versioned_aliases = versioned_aliases.map('${f.tap_name}/${it}')
			valid_main = valid_main.map('${f.tap_name}/${it}')
			valid_other = valid_other.map('${f.tap_name}/${it}')
		}
		valid := versioned_aliases.filter(it in valid_main)
		invalid := versioned_aliases.filter(it !in valid_main && it !in valid_other)
		if valid.len == 0 && alias_name != f.versioned_formula_names[0] {
			if f.tap_name != '' {
				relative_path := f.path.replace(f.tap_path, '..')
				formula_audit_problem(mut auditor, 'Formula has other versions so create a versioned alias:\n  cd ${f.tap_alias_dir}\n  ln -s ${relative_path} ${alias_name}\n')
			} else {
				formula_audit_problem(mut auditor, "Formula has other versions so create an alias named '${alias_name}'.")
			}
		}
		if invalid.len > 0 {
			formula_audit_problem(mut auditor, 'Formula has invalid versioned aliases:\n  ${invalid.join('\n  ')}\n')
		}
	}
	if f.core_formula && f.expected_path != '' && f.path != f.expected_path {
		formula_audit_problem(mut auditor, 'Formula is in wrong path:\n  Expected: ${f.expected_path}\n    Actual: ${f.path}\n')
	}
}

// Ruby method `self.aliases` at line 176.
pub fn ruby_formula_auditor_l176_d8_self_aliases(formula_aliases []string, tap_aliases []string) []string {
	mut aliases := formula_aliases.clone()
	aliases << tap_aliases
	return aliases
}

// Ruby method `audit_synced_versions_formulae` at line 182.
pub fn ruby_formula_auditor_l182_d9_audit_synced_versions_formulae(mut auditor FormulaAuditor) {
	for synced in auditor.formula.synced_versions {
		if synced.name != auditor.formula.name && synced.version != auditor.formula.version {
			formula_audit_problem(mut auditor, 'Version of ${synced.name} (${synced.version}) should match version of ${auditor.formula.name} (${auditor.formula.version})')
		}
	}
}

// Ruby method `audit_name` at line 204.
pub fn ruby_formula_auditor_l204_d10_audit_name(mut auditor FormulaAuditor) {
	name := auditor.formula.name
	mut errors := []string{}
	if name != name.to_lower() { errors << 'uppercase letters' }
	if name.contains(' ') { errors << 'spaces' }
	if errors.len > 0 {
		formula_audit_problem(mut auditor, "Formula name '${name}' must not contain ${errors.join(' or ')}.")
	}
	if !auditor.core_tap || !auditor.options.strict {
		return
	}
	if auditor.formula.disallowed_name_reason != '' {
		formula_audit_problem(mut auditor, "'${name}' is not allowed in homebrew/core.")
	}
	if name in auditor.formula.all_core_aliases {
		formula_audit_problem(mut auditor, 'Formula name conflicts with existing aliases in homebrew/core.')
		return
	}
	if oldname := auditor.formula.formula_renames[name] {
		formula_audit_problem(mut auditor, "'${name}' is reserved as the old name of ${oldname} in homebrew/core.")
		return
	}
	if name in auditor.formula.cask_tokens {
		formula_audit_problem(mut auditor, "Formula name conflicts with an existing Homebrew/cask cask's token.")
		return
	}
	if !auditor.formula.core_formula && name in auditor.formula.core_names {
		formula_audit_problem(mut auditor, 'Formula name conflicts with an existing formula in homebrew/core.')
	}
}

// Ruby method `audit_license` at line 267.
pub fn ruby_formula_auditor_l267_d11_audit_license(mut auditor FormulaAuditor) {
	f := auditor.formula
	if f.license != '' || f.licenses.len > 0 {
		licenses := if f.licenses.len > 0 { f.licenses.clone() } else { [f.license] }
		incompatible_exact := ['Aladdin', 'CPOL-1.02', 'gSOAP-1.3b', 'JSON', 'MS-LPL', 'OPL-1.0']
		prefixes := ['BUSL', 'CC-BY-NC', 'Elastic', 'SSPL']
		incompatible := licenses.filter(it in incompatible_exact || formula_audit_starts_with_any(it, prefixes))
		if incompatible.len > 0 && auditor.core_tap {
			formula_audit_problem(mut auditor, 'Formula ${f.name} contains incompatible licenses: ${incompatible}.\nFormulae in homebrew/core must either use a Debian Free Software Guidelines license\nor be released into the public domain: https://docs.brew.sh/Licence-Guidelines\n')
		}
		nonstandard := licenses.filter(f.valid_licenses.len > 0 && it !in f.valid_licenses && it != 'public_domain' && !it.ends_with('+'))
		if nonstandard.len > 0 {
			formula_audit_problem(mut auditor, 'Formula ${f.name} contains non-standard SPDX licenses: ${nonstandard}.\nFor a list of valid licenses check: https://spdx.org/licenses/\n')
		}
		if auditor.options.strict || auditor.core_tap {
			deprecated := licenses.filter(it in f.deprecated_licenses)
			if deprecated.len > 0 {
				formula_audit_problem(mut auditor, 'Formula ${f.name} contains deprecated SPDX licenses: ${deprecated}.\nYou may need to add `-only` or `-or-later` for GNU licenses (e.g. `GPL`, `LGPL`, `AGPL`, `GFDL`).\nFor a list of valid licenses check: https://spdx.org/licenses/\n')
			}
		}
		invalid_exceptions := f.license_exceptions.filter(it !in f.valid_license_exceptions)
		if invalid_exceptions.len > 0 {
			formula_audit_problem(mut auditor, 'Formula ${f.name} contains invalid or deprecated SPDX license exceptions: ${invalid_exceptions}.\nFor a list of valid license exceptions check:\n  https://spdx.org/licenses/exceptions-index.html\n')
		}
		if !auditor.options.online || f.github_license == '' {
			return
		}
		if f.github_license in licenses || f.github_license == 'NOASSERTION' {
			return
		}
		permitted := {
			'AGPL-3.0': ['AGPL-3.0-only', 'AGPL-3.0-or-later']
			'GPL-2.0':  ['GPL-2.0-only', 'GPL-2.0-or-later']
			'GPL-3.0':  ['GPL-3.0-only', 'GPL-3.0-or-later']
			'LGPL-2.1': ['LGPL-2.1-only', 'LGPL-2.1-or-later']
			'LGPL-3.0': ['LGPL-3.0-only', 'LGPL-3.0-or-later']
		}
		if group := permitted[f.github_license] {
			if group.any(it in licenses) {
				return
			}
		}
		if formula_audit_exception(auditor, 'permitted_formula_license_mismatches', f.name) {
			return
		}
		formula_audit_problem(mut auditor, 'Formula license ${licenses} does not match GitHub license ["${f.github_license}"].')
	} else if auditor.core_tap && !f.disabled {
		formula_audit_problem(mut auditor, 'Formulae in homebrew/core must specify a license.')
	}
}

// Ruby method `audit_deps` at line 339.
pub fn ruby_formula_auditor_l339_d12_audit_deps(mut auditor FormulaAuditor) {
	f := auditor.formula
	for dep in f.dependencies {
		if dep.cross_tap_missing {
			continue
		}
		if dep.ambiguous {
			formula_audit_problem(mut auditor, "Ambiguous dependency '${dep.name}'.")
			continue
		}
		if !dep.available {
			formula_audit_problem(mut auditor, "Can't find dependency '${dep.name}'.")
			continue
		}
		short_name := dep.name.all_after_last('/')
		if short_name in dep.oldnames {
			formula_audit_problem(mut auditor, "Dependency '${dep.name}' was renamed; use new name '${dep.canonical_name}'.")
		}
		if auditor.core_tap && auditor.new_formula && !dep.uses_from_macos && dep.keg_only && dep.provided_by_macos && dep.keg_reason_applicable && !f.has_linux_requirement && !formula_audit_exception(auditor, 'provided_by_macos_depends_on_allowlist', dep.name) {
			formula_audit_new_problem(mut auditor, "Dependency '${dep.name}' is provided by macOS; please replace 'depends_on' with 'uses_from_macos'.")
		}
		for option in dep.options {
			if auditor.core_tap {
				continue
			}
			if option in dep.defined_options {
				continue
			}
			if option.starts_with('with-') && option.trim_string_left('with-') in dep.recommended_requirements {
				continue
			}
			if option.starts_with('without-') && option.trim_string_left('without-') in dep.optional_requirements {
				continue
			}
			formula_audit_problem(mut auditor, 'Dependency \'${dep.name}\' does not define option: "${option}"')
		}
		if auditor.new_formula && dep.name == 'git' {
			formula_audit_problem(mut auditor, "Don't use 'git' as a dependency (it's always available)")
		}
		for tag in dep.tags {
			if tag in ['run', 'linked'] {
				formula_audit_problem(mut auditor, "Dependency '${dep.name}' is marked as :${tag}. Remove :${tag}; it is a no-op.")
			} else if tag.starts_with(':') && tag.trim_string_left(':') !in ['build', 'test',
				'optional', 'recommended', 'implicit'] {
				formula_audit_problem(mut auditor, "Dependency '${dep.name}' is marked as ${tag} which is not a valid tag.")
			}
		}
		if !auditor.core_tap {
			continue
		}
		if !dep.has_tap {
			formula_audit_problem(mut auditor, "Dependency '${dep.name}' does not exist in any tap.\n")
		} else if !dep.core_tap {
			formula_audit_problem(mut auditor, "Dependency '${dep.name}' is not in homebrew/core. Formulae in homebrew/core\nshould not have dependencies in external taps.\n")
		}
		if dep.deprecated && !f.deprecated && !f.disabled {
			formula_audit_problem(mut auditor, "Dependency '${dep.name}' is deprecated but has un-deprecated dependents. Either\nun-deprecate '${dep.name}' or deprecate it and all of its dependents.\n")
		}
		if dep.disabled && !f.disabled {
			formula_audit_problem(mut auditor, "Dependency '${dep.name}' is disabled but has un-disabled dependents. Either\nun-disable '${dep.name}' or disable it and all of its dependents.\n")
		}
		mut os_requirement := ''
		if f.linux && !dep.supports_linux && !f.depends_on_macos_top_level {
			os_requirement = 'macOS'
		}
		if !f.linux && !dep.supports_macos && !f.depends_on_linux_top_level {
			os_requirement = 'Linux'
		}
		if os_requirement != '' {
			formula_audit_problem(mut auditor, "Dependency '${dep.name}' has a ${os_requirement} requirement. Either move the\ndependency inside an `on_${os_requirement.to_lower()}` block or add `depends_on :${os_requirement.to_lower()}`.\n")
		}
		if dep.name in f.all_core_aliases && !dep.uses_from_macos && (dep.name != 'pkg-config' || auditor.core_tap) {
			canonical := if dep.full_name != '' { dep.full_name } else { dep.canonical_name }
			formula_audit_problem(mut auditor, "Dependency '${dep.name}' is an alias; use the canonical name '${canonical}'.")
		}
		if 'recommended' in dep.tags || 'optional' in dep.tags || ':recommended' in dep.tags || ':optional' in dep.tags {
			formula_audit_problem(mut auditor, 'Formulae in homebrew/core should not have optional or recommended dependencies')
		}
	}
	if auditor.core_tap && (f.requirements_recommended || f.requirements_optional) {
		formula_audit_problem(mut auditor, 'Formulae in homebrew/core should not have optional or recommended requirements')
	}
	if !auditor.core_tap || f.linux || formula_audit_exception(auditor, 'versioned_dependencies_conflicts_allowlist', f.name) {
		return
	}
	mut seen := map[string][]string{}
	mut conflicts := []string{}
	for name in f.runtime_formula_names {
		base := name.all_before('@')
		if auditor.options.tap_audit_staging && base == auditor.options.staging_formula {
			continue
		}
		if formula_audit_exception(auditor, 'versioned_formula_dependent_conflicts_allowlist', name, base) {
			continue
		}
		mut versions := seen[base] or { []string{} }
		if name !in versions { versions << name }
		seen[base] = versions
		if versions.len >= 2 {
			for item in versions {
				if item !in conflicts { conflicts << item }
			}
		}
	}
	if conflicts.len == 0 || f.disabled {
		return
	}
	if f.deprecated && f.deprecation_reason != 'versioned_formula' {
		return
	}
	formula_audit_problem(mut auditor, '${f.full_name} contains conflicting version recursive dependencies:\n  ${conflicts.join(', ')}\nView these with `brew deps --tree ${f.full_name}`.\n')
}

// Ruby method `audit_node_modules` at line 517.
pub fn ruby_formula_auditor_l517_d13_audit_node_modules(mut auditor FormulaAuditor) {
	if !auditor.core_tap || !auditor.formula.libexec_node_modules {
		return
	}
	for package in ['@anthropic-ai/claude-agent-sdk', '@github/copilot'] {
		if auditor.formula.node_package_paths.any(it.ends_with('/${package}') || it == package) {
			formula_audit_problem(mut auditor, 'Formula ${auditor.formula.name} uses ${package} which has an incompatible license.\nAll installed npm dependencies must satisfy https://docs.brew.sh/Licence-Guidelines\n')
		}
	}
}

// Ruby method `audit_conflicts` at line 540.
pub fn ruby_formula_auditor_l540_d14_audit_conflicts(mut auditor FormulaAuditor) {
	for conflict in auditor.formula.conflicts {
		if conflict.cross_tap_missing {
			continue
		}
		if conflict.ambiguous {
			formula_audit_problem(mut auditor, 'Ambiguous conflicting formula "${conflict.name}".')
			continue
		}
		if !conflict.available {
			formula_audit_problem(mut auditor, 'Can\'t find conflicting formula "${conflict.name}".')
			continue
		}
		if !conflict.same_tap {
			continue
		}
		if conflict.is_self {
			formula_audit_problem(mut auditor, 'Formula should not conflict with itself')
		}
		if conflict.declared_through_alias {
			formula_audit_problem(mut auditor, "Formula conflict should be declared using canonical name (${conflict.canonical_name}) instead of '${conflict.name}'")
		}
		if conflict.reverse_alias_name != '' {
			formula_audit_problem(mut auditor, "Formula ${conflict.canonical_name} conflict should be declared using canonical name (${conflict.reverse_canonical_name}) instead of '${conflict.reverse_alias_name}'")
		}
		if !conflict.reverse_conflict {
			formula_audit_problem(mut auditor, 'Formula ${conflict.canonical_name} should also have a conflict declared with ${auditor.formula.name}')
		}
	}
}

// Ruby method `audit_gcc_dependency` at line 578.
pub fn ruby_formula_auditor_l578_d15_audit_gcc_dependency(mut auditor FormulaAuditor) {
	if !auditor.core_tap || !auditor.formula.linux || !ruby_formula_auditor_l1348_d50_linux_only_gcc_dep(auditor.formula) {
		return
	}
	if formula_audit_exception(auditor, 'linux_only_gcc_dependency_allowlist', auditor.formula.name) {
		return
	}
	formula_audit_problem(mut auditor, 'Formulae in homebrew/core should not have a Linux-only dependency on GCC.')
}

// Ruby method `audit_glibc` at line 590.
pub fn ruby_formula_auditor_l590_d16_audit_glibc(mut auditor FormulaAuditor) {
	f := auditor.formula
	if !auditor.core_tap || f.name != 'glibc' || f.version in [
		f.linux_glibc_ci_version,
		f.linux_glibc_next_version,
	] {
		return
	}
	formula_audit_problem(mut auditor, 'The glibc version must be ${f.linux_glibc_ci_version}, as needed by our CI on Linux. The glibc formula is for users who have a system glibc with a lower version, which allows them to use our Linux bottles, which were compiled against system glibc on CI.')
}

// Ruby method `audit_relicensed_formulae` at line 602.
pub fn ruby_formula_auditor_l602_d17_audit_relicensed_formulae(mut auditor FormulaAuditor) {
	f := auditor.formula
	if !auditor.core_tap || f.relicensed_version == '' || formula_audit_compare_versions(f.version, f.relicensed_version) < 0 {
		return
	}
	formula_audit_problem(mut auditor, '${f.name} was relicensed to a non-open-source license from version ${f.relicensed_version}. It must not be upgraded to version ${f.relicensed_version} or newer.')
}

// Ruby method `audit_versioned_keg_only` at line 614.
pub fn ruby_formula_auditor_l614_d18_audit_versioned_keg_only(mut auditor FormulaAuditor) {
	f := auditor.formula
	if !auditor.versioned_formula || !auditor.core_tap {
		return
	}
	if f.keg_only && (f.keg_reason_versioned || ((f.name.starts_with('openssl') || f.name.starts_with('libressl')) && f.keg_reason_by_macos)) {
		return
	}
	if formula_audit_exception(auditor, 'versioned_keg_only_allowlist', f.name) {
		return
	}
	formula_audit_problem(mut auditor, 'Versioned formulae in homebrew/core should use `keg_only :versioned_formula`')
}

// Ruby method `audit_homepage` at line 629.
pub fn ruby_formula_auditor_l629_d19_audit_homepage(mut auditor FormulaAuditor) {
	f := auditor.formula
	if f.homepage == '' || f.homepage_browsed_recently || !auditor.options.online {
		return
	}
	if formula_audit_exception(auditor, 'cert_error_allowlist', f.name, f.homepage) || !auditor.options.development_curl_ok {
		return
	}
	if (f.homepage.starts_with('https://www.gnu.org/') || f.homepage.starts_with('http://www.gnu.org/') || f.homepage.starts_with('https://www.nongnu.org/') || f.homepage.starts_with('http://www.nongnu.org/')) && auditor.options.github_runner && !auditor.options.github_self_hosted {
		return
	}
	if auditor.options.homepage_problem != '' {
		formula_audit_problem(mut auditor, auditor.options.homepage_problem)
	}
}

// Ruby method `audit_duplicate_formula` at line 665.
pub fn ruby_formula_auditor_l665_d20_audit_duplicate_formula(mut auditor FormulaAuditor) {
	if !auditor.core_tap || !auditor.new_formula || auditor.formula.stable_url == '' {
		return
	}
	for name, urls in auditor.formula.duplicate_urls {
		if name != auditor.formula.name && auditor.formula.stable_url in urls {
			formula_audit_new_problem(mut auditor, 'Possible duplicate, this formula has the same stable URL as `${name}`')
			return
		}
	}
}

// Ruby method `audit_bottle_spec` at line 686.
pub fn ruby_formula_auditor_l686_d21_audit_bottle_spec(mut auditor FormulaAuditor) {
	if auditor.new_formula_inclusive && auditor.core_tap && auditor.formula.bottle_defined {
		formula_audit_new_problem(mut auditor, 'New formulae in homebrew/core should not have a `bottle do` block')
	}
}

// Ruby method `audit_eol` at line 697.
pub fn ruby_formula_auditor_l697_d22_audit_eol(mut auditor FormulaAuditor) {
	f := auditor.formula
	if !auditor.options.online || !auditor.core_tap || f.deprecated || f.disabled || !f.eol {
		return
	}
	name := if f.versioned_formula { f.name.all_before('@') } else { f.name }
	if formula_audit_exception(auditor, 'eol_date_blocklist', name) {
		return
	}
	mut message := 'Product is EOL'
	if f.eol_from != '' {
		message += ' since ${f.eol_from}'
	}
	message += ', see https://endoflife.date/${name}'
	formula_audit_problem(mut auditor, message)
}

// Ruby method `audit_wayback_url` at line 727.
pub fn ruby_formula_auditor_l727_d23_audit_wayback_url(mut auditor FormulaAuditor) {
	f := auditor.formula
	if !auditor.core_tap || f.deprecated || f.disabled {
		return
	}
	prefix := 'Formula with a Internet Archive Wayback Machine'
	if f.stable_url.starts_with('https://web.archive.org') || f.stable_url.starts_with('http://web.archive.org') {
		formula_audit_problem(mut auditor, '${prefix} `url` should be deprecated with `:repo_removed`')
	}
	if f.homepage.starts_with('https://web.archive.org') || f.homepage.starts_with('http://web.archive.org') {
		formula_audit_problem(mut auditor, '${prefix} `homepage` should find an alternative `homepage` or be deprecated.')
	}
	if f.head_url.starts_with('https://web.archive.org') || f.head_url.starts_with('http://web.archive.org') {
		formula_audit_problem(mut auditor, 'Remove Internet Archive Wayback Machine `head` URL')
	}
}

// Ruby method `audit_github_repository_archived` at line 750.
pub fn ruby_formula_auditor_l750_d24_audit_github_repository_archived(mut auditor FormulaAuditor) {
	if auditor.formula.deprecated || auditor.formula.disabled || !auditor.options.online {
		return
	}
	if _, _ := ruby_formula_auditor_l838_d31_get_repo_data(auditor, 'github.com') {
		if auditor.formula.github_repo.archived {
			formula_audit_problem(mut auditor, 'GitHub repository is archived')
		}
	}
}

// Ruby method `audit_gitlab_repository_archived` at line 763.
pub fn ruby_formula_auditor_l763_d25_audit_gitlab_repository_archived(mut auditor FormulaAuditor) {
	if auditor.formula.deprecated || auditor.formula.disabled || !auditor.options.online {
		return
	}
	if _, _ := ruby_formula_auditor_l838_d31_get_repo_data(auditor, 'gitlab.com') {
		if auditor.formula.gitlab_repo.archived {
			formula_audit_problem(mut auditor, 'GitLab repository is archived')
		}
	}
}

// Ruby method `audit_forgejo_repository_archived` at line 776.
pub fn ruby_formula_auditor_l776_d26_audit_forgejo_repository_archived(mut auditor FormulaAuditor) {
	if auditor.formula.deprecated || auditor.formula.disabled || !auditor.options.online {
		return
	}
	if _, _ := ruby_formula_auditor_l838_d31_get_repo_data(auditor, 'codeberg.org') {
		data := auditor.formula.forgejo_repo
		if data.archived {
			formula_audit_problem(mut auditor, 'Forgejo repository is archived since ${data.archived_at}')
		}
	}
}

// Ruby method `audit_github_repository` at line 789.
pub fn ruby_formula_auditor_l789_d27_audit_github_repository(mut auditor FormulaAuditor) {
	if !auditor.new_formula {
		return
	}
	if owner, _ := ruby_formula_auditor_l838_d31_get_repo_data(auditor, 'github.com') {
		_ = ruby_formula_auditor_l1336_d48_self_submission(owner, auditor.options.self_submission_owners)
		if auditor.formula.github_repo.warning != '' {
			formula_audit_new_problem(mut auditor, auditor.formula.github_repo.warning)
		}
	}
}

// Ruby method `audit_gitlab_repository` at line 802.
pub fn ruby_formula_auditor_l802_d28_audit_gitlab_repository(mut auditor FormulaAuditor) {
	if !auditor.new_formula {
		return
	}
	if owner, _ := ruby_formula_auditor_l838_d31_get_repo_data(auditor, 'gitlab.com') {
		_ = ruby_formula_auditor_l1336_d48_self_submission(owner, auditor.options.self_submission_owners)
		if auditor.formula.gitlab_repo.warning != '' {
			formula_audit_new_problem(mut auditor, auditor.formula.gitlab_repo.warning)
		}
	}
}

// Ruby method `audit_bitbucket_repository` at line 814.
pub fn ruby_formula_auditor_l814_d29_audit_bitbucket_repository(mut auditor FormulaAuditor) {
	if !auditor.new_formula {
		return
	}
	if owner, _ := ruby_formula_auditor_l838_d31_get_repo_data(auditor, 'bitbucket.org') {
		_ = ruby_formula_auditor_l1336_d48_self_submission(owner, auditor.options.self_submission_owners)
		if auditor.formula.bitbucket_repo.warning != '' {
			formula_audit_new_problem(mut auditor, auditor.formula.bitbucket_repo.warning)
		}
	}
}

// Ruby method `audit_forgejo_repository` at line 826.
pub fn ruby_formula_auditor_l826_d30_audit_forgejo_repository(mut auditor FormulaAuditor) {
	if !auditor.new_formula {
		return
	}
	if owner, _ := ruby_formula_auditor_l838_d31_get_repo_data(auditor, 'codeberg.org') {
		_ = ruby_formula_auditor_l1336_d48_self_submission(owner, auditor.options.self_submission_owners)
		if auditor.formula.forgejo_repo.warning != '' {
			formula_audit_new_problem(mut auditor, auditor.formula.forgejo_repo.warning)
		}
	}
}

// Ruby method `get_repo_data(regex)` at line 838.
pub fn ruby_formula_auditor_l838_d31_get_repo_data(auditor FormulaAuditor, host string) ?(string, string) {
	if !auditor.core_tap || !auditor.options.online {
		return none
	}
	for url in [auditor.formula.stable_url, auditor.formula.homepage, auditor.formula.head_url] {
		if owner, repo := formula_audit_repo_from_url(url, host) {
			return owner, repo
		}
	}
	return none
}

// Ruby method `audit_specs` at line 853.
pub fn ruby_formula_auditor_l853_d32_audit_specs(mut auditor FormulaAuditor) {
	f := auditor.formula
	if ruby_formula_auditor_l1343_d49_head_only(f) && auditor.core_tap {
		formula_audit_problem(mut auditor, 'HEAD-only (no stable download)')
	}
	for spec in [f.stable_spec, f.head_spec] {
		actual := spec or { continue }
		label := if actual.kind.to_lower() == 'head' { 'HEAD' } else { 'Stable' }
		for message in actual.problems {
			formula_audit_problem(mut auditor, '${label}: ${message}')
		}
		for resource in actual.resources {
			if resource.name == f.name {
				formula_audit_problem(mut auditor, 'Resource name should be different from the formula name')
			}
			for message in resource.problems {
				formula_audit_problem(mut auditor, '${label} resource "${resource.name}": ${message}')
			}
		}
		if actual.patches.len > 0 && auditor.new_formula && auditor.core_tap {
			formula_audit_new_problem(mut auditor, 'Formulae should not require patches to build. Patches should be submitted and accepted upstream first.')
		}
	}
	if !auditor.core_tap {
		return
	}
	if f.head_url != '' && auditor.versioned_formula && !formula_audit_exception(auditor, 'versioned_head_spec_allowlist', f.name) {
		formula_audit_problem(mut auditor, 'Versioned formulae should not have a `head` spec')
	}
	stable := f.stable_spec or { return }
	if stable.url == '' {
		return
	}
	version := stable.version
	if !version.contains_any('0123456789') {
		formula_audit_problem(mut auditor, 'Stable: version (${version}) is set to a string without a digit')
	}
	if version.starts_with('HEAD') {
		formula_audit_problem(mut auditor, 'Stable: non-HEAD version (${version}) should not begin with `HEAD`')
	}
	if !auditor.options.has_throttle_days && auditor.options.throttle_rate > 0 && !auditor.options.throttle_allows_bump {
		rate := auditor.options.throttle_rate
		formula_audit_problem(mut auditor, 'Should only be updated every ${rate} releases on multiples of ${rate}')
	}
	url_lower := stable.url.to_lower()
	mut unstable := ''
	for marker in ['alpha', 'beta'] {
		if url_lower.contains(marker) {
			unstable = marker
			break
		}
	}
	if unstable == '' && url_lower.contains('rc') {
		unstable = 'rc'
	}
	if unstable != '' {
		prefix := version.trim_right('0123456789')
		if !formula_audit_exception(auditor, 'unstable_allowlist', f.name, prefix) && !formula_audit_exception(auditor, 'unstable_devel_allowlist', f.name, prefix) {
			formula_audit_problem(mut auditor, 'Stable: version URLs should not contain `${unstable}`')
		}
	} else if url_lower.contains('download.gnome.org/sources') || url_lower.contains('ftp.gnome.org/pub/gnome/sources') {
		minor_parts := formula_audit_version_parts(version)
		minor := if minor_parts.len > 1 { minor_parts[1] } else { 0 }
		prefix := formula_audit_major_minor(version)
		if !formula_audit_exception(auditor, 'gnome_devel_allowlist', f.name, prefix, 'all') && formula_audit_compare_versions(version, '1.0') >= 0 && formula_audit_compare_versions(version, '40.0') < 0 && minor % 2 != 0 {
			formula_audit_problem(mut auditor, 'Stable: version (${version}) is a development release')
		}
	} else if url_lower.contains('isc.org/isc/bind') {
		minor_parts := formula_audit_version_parts(version)
		if minor_parts.len > 1 && minor_parts[1] % 2 != 0 {
			formula_audit_problem(mut auditor, 'Stable: version (${version}) is a development release')
		}
	}
	if auditor.options.online && stable.release_error != '' {
		formula_audit_problem(mut auditor, stable.release_error)
	}
}

// Ruby method `audit_stable_version` at line 990.
pub fn ruby_formula_auditor_l990_d33_audit_stable_version(mut auditor FormulaAuditor) {
	f := auditor.formula
	if !auditor.options.git || f.tap_name == '' || !f.tap_git || !f.stable || f.committed_base.version == '' {
		return
	}
	base := f.committed_base.version
	if formula_audit_compare_versions(f.version, base) == 0 && f.version != base {
		formula_audit_problem(mut auditor, 'Stable: version should not change from ${base} to ${f.version}')
	} else if formula_audit_compare_versions(f.version, base) < 0 && f.version_scheme == f.committed_previous.version_scheme {
		formula_audit_problem(mut auditor, 'Stable: version should not decrease (from ${base} to ${f.version})')
	}
}

// Ruby method `audit_revision` at line 1010.
pub fn ruby_formula_auditor_l1010_d34_audit_revision(mut auditor FormulaAuditor) {
	f := auditor.formula
	if auditor.new_formula && f.revision != 0 {
		formula_audit_new_problem(mut auditor, 'New formulae should not define a revision.')
	}
	if !auditor.options.git || f.tap_name == '' || !f.tap_git || !f.stable {
		return
	}
	previous := f.committed_previous
	base := f.committed_base
	if (previous.version != base.version || f.version != base.version) && f.revision != 0 && f.revision == base.revision && f.revision == previous.revision {
		formula_audit_problem(mut auditor, '`revision ${f.revision}` should be removed')
	} else if f.version == previous.version && previous.has_revision && f.revision < previous.revision {
		formula_audit_problem(mut auditor, '`revision` should not decrease (from ${previous.revision} to ${f.revision})')
	} else if base.has_revision && f.revision > base.revision + 1 {
		formula_audit_problem(mut auditor, '`revision` should only increment by 1')
	}
	if f.revision - previous.revision != 1 || f.recursive_dependency_names.len == 0 {
		return
	}
	mut missing := []string{}
	for changed in f.changed_formulae {
		if changed.name !in f.recursive_dependency_names {
			continue
		}
		if changed.committed.version != '' && changed.version != '' && changed.version == changed.committed.version {
			continue
		}
		expected := changed.committed.compatibility_version + 1
		if changed.compatibility_version != expected {
			missing << '${changed.name} (${changed.committed.compatibility_version} to ${expected})'
		}
	}
	if missing.len > 0 && f.core_formula {
		formula_audit_problem(mut auditor, '`revision` increased but changed recursive dependencies must increase `compatibility_version` by 1 in the same PR: ${missing.join(', ')}. See https://docs.brew.sh/Formula-Cookbook#compatibility_version.')
	}
}

// Ruby method `audit_compatibility_version` at line 1074.
pub fn ruby_formula_auditor_l1074_d35_audit_compatibility_version(mut auditor FormulaAuditor) {
	f := auditor.formula
	if !auditor.options.git || f.tap_name == '' || !f.tap_git || (f.committed_base.version == '' && !f.committed_base.has_compatibility_version) {
		return
	}
	previous := f.committed_base.compatibility_version
	current := if f.has_compatibility_version { f.compatibility_version } else { previous }
	if current < previous {
		formula_audit_problem(mut auditor, '`compatibility_version` should not decrease from ${previous} to ${current}')
		return
	} else if current > previous + 1 {
		formula_audit_problem(mut auditor, '`compatibility_version` should only increment by 1')
		return
	}
	if current == previous || !f.valid_platform {
		return
	}
	for changed in f.changed_formulae {
		if changed.name == f.name || f.name !in changed.dependencies {
			continue
		}
		if changed.revision == changed.committed.revision + 1 {
			return
		}
	}
	formula_audit_problem(mut auditor, '`compatibility_version` increased from ${previous} to ${current} but no recursive dependent formulae increased `revision` by 1 in this PR. Only bump `compatibility_version` when at least one recursive dependent needs a `revision` bump. See https://docs.brew.sh/Formula-Cookbook#compatibility_version.')
}

// Ruby method `audit_version_scheme` at line 1125.
pub fn ruby_formula_auditor_l1125_d36_audit_version_scheme(mut auditor FormulaAuditor) {
	f := auditor.formula
	if !auditor.options.git || f.tap_name == '' || !f.tap_git || !f.stable || !f.committed_base.has_version_scheme {
		return
	}
	previous := f.committed_base.version_scheme
	if f.version_scheme < previous {
		formula_audit_problem(mut auditor, '`version_scheme` should not decrease (from ${previous} to ${f.version_scheme})')
	} else if f.version_scheme > previous + 1 {
		formula_audit_problem(mut auditor, '`version_scheme` should only increment by 1')
	}
}

// Ruby method `audit_unconfirmed_checksum_change` at line 1145.
pub fn ruby_formula_auditor_l1145_d37_audit_unconfirmed_checksum_change(mut auditor FormulaAuditor) {
	f := auditor.formula
	base := f.committed_base
	if !auditor.options.git || f.tap_name == '' || !f.tap_git || !f.stable {
		return
	}
	if f.version == base.version && f.stable_url == base.url && f.stable_checksum != '' && base.checksum != '' && f.stable_checksum != base.checksum {
		formula_audit_problem(mut auditor, 'stable sha256 changed without the url/version also changing; please create an issue upstream to rule out malicious circumstances and to find out why the file changed.')
	}
}

// Ruby method `audit_text` at line 1171.
pub fn ruby_formula_auditor_l1171_d38_audit_text(mut auditor FormulaAuditor) {
	mut names := [auditor.formula.name]
	mut candidates := auditor.formula.aliases.clone()
	candidates << auditor.formula.bin_names
	for name in candidates {
		if name !in names { names << name }
	}
	for name in names {
		for command in ['system', 'shell_output', 'pipe_output'] {
			for quote in ["'", '"'] {
				if auditor.text.contains('test do') && (auditor.text.contains('${command} ${quote}${name}') || auditor.text.contains('${command}(${quote}${name}')) {
					formula_audit_problem(mut auditor, 'Fully scope test `${command}` calls, e.g.: ${command} "#{bin}/${name}"')
				}
			}
		}
	}
}

// Ruby method `audit_reverse_migration` at line 1191.
pub fn ruby_formula_auditor_l1191_d39_audit_reverse_migration(mut auditor FormulaAuditor) {
	if auditor.options.strict && auditor.core_tap && auditor.formula.tap_migration {
		f := auditor.formula
		formula_audit_problem(mut auditor, '${f.name} seems to be listed in tap_migrations.json!\nPlease remove ${f.name} from present tap & tap_migrations.json\nbefore submitting it to Homebrew/homebrew-${f.tap_repository}.\n')
	}
}

// Ruby method `audit_prefix_has_contents` at line 1205.
pub fn ruby_formula_auditor_l1205_d40_audit_prefix_has_contents(mut auditor FormulaAuditor) {
	if auditor.formula.prefix_directory && auditor.formula.empty_installation {
		formula_audit_problem(mut auditor, 'The installation seems to be empty. Please ensure the prefix\nis set correctly and expected files are installed.\nThe prefix configure/make argument may be case-sensitive.\n')
	}
}

// Ruby method `audit_deprecate_disable` at line 1217.
pub fn ruby_formula_auditor_l1217_d41_audit_deprecate_disable(mut auditor FormulaAuditor) {
	if auditor.formula.deprecate_disable_error != '' {
		formula_audit_problem(mut auditor, auditor.formula.deprecate_disable_error)
	}
}

// Ruby method `problem_if_output(output)` at line 1223.
pub fn ruby_formula_auditor_l1223_d42_problem_if_output(mut auditor FormulaAuditor, output ?string) {
	if message := output { formula_audit_problem(mut auditor, message) }
}

// Ruby method `audit` at line 1228.
pub fn ruby_formula_auditor_l1228_d43_audit(mut auditor FormulaAuditor) {
	names := ['style', 'file', 'synced_versions_formulae', 'name', 'license', 'deps', 'node_modules',
		'conflicts', 'gcc_dependency', 'glibc', 'relicensed_formulae', 'versioned_keg_only',
		'homepage', 'duplicate_formula', 'bottle_spec', 'eol', 'wayback_url',
		'github_repository_archived', 'gitlab_repository_archived', 'forgejo_repository_archived',
		'github_repository', 'gitlab_repository', 'bitbucket_repository', 'forgejo_repository',
		'specs', 'stable_version', 'revision', 'compatibility_version', 'version_scheme',
		'unconfirmed_checksum_change', 'text', 'reverse_migration', 'prefix_has_contents',
		'deprecate_disable']
	for name in names {
		if auditor.options.only.len > 0 && name !in auditor.options.only {
			continue
		}
		if name in auditor.options.except {
			continue
		}
		match name {
			'style' { ruby_formula_auditor_l80_d6_audit_style(mut auditor) }
			'file' { ruby_formula_auditor_l92_d7_audit_file(mut auditor) }
			'synced_versions_formulae' {
				ruby_formula_auditor_l182_d9_audit_synced_versions_formulae(mut auditor)
			}
			'name' { ruby_formula_auditor_l204_d10_audit_name(mut auditor) }
			'license' { ruby_formula_auditor_l267_d11_audit_license(mut auditor) }
			'deps' { ruby_formula_auditor_l339_d12_audit_deps(mut auditor) }
			'node_modules' { ruby_formula_auditor_l517_d13_audit_node_modules(mut auditor) }
			'conflicts' { ruby_formula_auditor_l540_d14_audit_conflicts(mut auditor) }
			'gcc_dependency' { ruby_formula_auditor_l578_d15_audit_gcc_dependency(mut auditor) }
			'glibc' { ruby_formula_auditor_l590_d16_audit_glibc(mut auditor) }
			'relicensed_formulae' {
				ruby_formula_auditor_l602_d17_audit_relicensed_formulae(mut auditor)
			}
			'versioned_keg_only' {
				ruby_formula_auditor_l614_d18_audit_versioned_keg_only(mut auditor)
			}
			'homepage' { ruby_formula_auditor_l629_d19_audit_homepage(mut auditor) }
			'duplicate_formula' {
				ruby_formula_auditor_l665_d20_audit_duplicate_formula(mut auditor)
			}
			'bottle_spec' { ruby_formula_auditor_l686_d21_audit_bottle_spec(mut auditor) }
			'eol' { ruby_formula_auditor_l697_d22_audit_eol(mut auditor) }
			'wayback_url' { ruby_formula_auditor_l727_d23_audit_wayback_url(mut auditor) }
			'github_repository_archived' {
				ruby_formula_auditor_l750_d24_audit_github_repository_archived(mut auditor)
			}
			'gitlab_repository_archived' {
				ruby_formula_auditor_l763_d25_audit_gitlab_repository_archived(mut auditor)
			}
			'forgejo_repository_archived' {
				ruby_formula_auditor_l776_d26_audit_forgejo_repository_archived(mut auditor)
			}
			'github_repository' {
				ruby_formula_auditor_l789_d27_audit_github_repository(mut auditor)
			}
			'gitlab_repository' {
				ruby_formula_auditor_l802_d28_audit_gitlab_repository(mut auditor)
			}
			'bitbucket_repository' {
				ruby_formula_auditor_l814_d29_audit_bitbucket_repository(mut auditor)
			}
			'forgejo_repository' {
				ruby_formula_auditor_l826_d30_audit_forgejo_repository(mut auditor)
			}
			'specs' { ruby_formula_auditor_l853_d32_audit_specs(mut auditor) }
			'stable_version' { ruby_formula_auditor_l990_d33_audit_stable_version(mut auditor) }
			'revision' { ruby_formula_auditor_l1010_d34_audit_revision(mut auditor) }
			'compatibility_version' {
				ruby_formula_auditor_l1074_d35_audit_compatibility_version(mut auditor)
			}
			'version_scheme' { ruby_formula_auditor_l1125_d36_audit_version_scheme(mut auditor) }
			'unconfirmed_checksum_change' {
				ruby_formula_auditor_l1145_d37_audit_unconfirmed_checksum_change(mut auditor)
			}
			'text' { ruby_formula_auditor_l1171_d38_audit_text(mut auditor) }
			'reverse_migration' {
				ruby_formula_auditor_l1191_d39_audit_reverse_migration(mut auditor)
			}
			'prefix_has_contents' {
				ruby_formula_auditor_l1205_d40_audit_prefix_has_contents(mut auditor)
			}
			'deprecate_disable' {
				ruby_formula_auditor_l1217_d41_audit_deprecate_disable(mut auditor)
			}
			else {}
		}
	}
}

// Ruby method `changed_formulae_paths(tap, only_names: [].freeze)` at line 1242.
pub fn ruby_formula_auditor_l1242_d44_changed_formulae_paths(formula FormulaAuditFormula, only_names []string) []string {
	if !formula.tap_git {
		return []
	}
	mut changed := []string{}
	for relative in formula.diff_paths {
		if !relative.ends_with('.rb') {
			continue
		}
		absolute := os.join_path(formula.tap_path, relative)
		if !absolute.starts_with(formula.formula_dir) {
			continue
		}
		changed << absolute
	}
	if only_names.len == 0 {
		return changed
	}
	mut expected := []string{}
	for raw_name in only_names {
		name := raw_name.trim_string_left('${formula.tap_name}/').trim_string_right('.rb')
		if path := formula.formula_files_by_name[name] { expected << os.abs_path(path) }
	}
	return changed.filter(os.abs_path(it) in expected)
}

// Ruby method `committed_version_info(formula: @formula)` at line 1270.
pub fn ruby_formula_auditor_l1270_d45_committed_version_info(formula FormulaAuditFormula, history []FormulaAuditHistoryEntry, git bool) (FormulaAuditVersionInfo, FormulaAuditVersionInfo) {
	if !git || formula.tap_name == '' || !formula.tap_git || !formula.stable {
		return FormulaAuditVersionInfo{}, FormulaAuditVersionInfo{}
	}
	mut previous := FormulaAuditVersionInfo{}
	mut base := FormulaAuditVersionInfo{}
	for entry in history {
		info := entry.info
		if info.version == '' {
			continue
		}
		previous = info
		if base.url == '' {
			base = info
		}
		if info.version != formula.version || (info.has_revision && info.revision != formula.revision) {
			break
		}
	}
	return previous, base
}

// Ruby method `problem(message, location: nil, corrected: false)` at line 1326.
pub fn ruby_formula_auditor_l1326_d46_problem(mut auditor FormulaAuditor, message string, location string, corrected bool) {
	auditor.problems << FormulaAuditProblem{ message: message, location: location, corrected: corrected }
}

// Ruby method `new_formula_problem(message, location: nil, corrected: false)` at line 1331.
pub fn ruby_formula_auditor_l1331_d47_new_formula_problem(mut auditor FormulaAuditor, message string, location string, corrected bool) {
	auditor.new_formula_problems << FormulaAuditProblem{ message: message, location: location, corrected: corrected }
}

// Ruby method `self_submission?(repo_owner)` at line 1336.
pub fn ruby_formula_auditor_l1336_d48_self_submission(repo_owner string, submission_owners []string) bool {
	return repo_owner != '' && repo_owner in submission_owners
}

// Ruby method `head_only?(formula)` at line 1343.
pub fn ruby_formula_auditor_l1343_d49_head_only(formula FormulaAuditFormula) bool {
	return formula.head_url != '' && !formula.stable
}

// Ruby method `linux_only_gcc_dep?(formula)` at line 1348.
pub fn ruby_formula_auditor_l1348_d50_linux_only_gcc_dep(formula FormulaAuditFormula) bool {
	if !formula.linux {
		return false
	}
	if !formula.dependencies.any(it.name == 'gcc' && !it.implicit) {
		return false
	}
	if formula.variation_dependencies.len == 0 {
		return false
	}
	for tag in formula.valid_variation_tags {
		dependencies := formula.variation_dependencies[tag] or { return false }
		if 'gcc' in dependencies {
			return false
		}
	}
	return true
}

// Ruby method `git_audit_base_ref(tap)` at line 1375.
pub fn ruby_formula_auditor_l1375_d51_git_audit_base_ref(formula FormulaAuditFormula) string {
	return if formula.merge_base != '' { formula.merge_base } else { 'origin/HEAD' }
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "deprecate_disable"
// 5: require "formula_versions"
// 6: require "formula_name_cask_token_auditor"
// 7: require "livecheck/livecheck"
// 8: require "resource_auditor"
// 9: require "utils"
// 10: require "utils/shared_audits"
// 11: require "utils/output"
// 12: require "utils/git"
// 13: require "style"
// 14: require "tap_auditor"
// 15:
// 16: module Homebrew
// 17:   # Auditor for checking common violations in {Formula}e.
// 18:   class FormulaAuditor
// 19:     include FormulaCellarChecks
// 20:     include Utils::Curl
// 21:     include Utils::Output::Mixin
// 22:
// 23:     sig { override.returns(Formula) }
// 24:     attr_reader :formula
// 25:
// 26:     sig { returns(String) }
// 27:     attr_reader :text
// 28:
// 29:     sig { returns(T::Array[T.any(String, T::Hash[Symbol, T.untyped])]) }
// 30:     attr_reader :problems
// 31:
// 32:     sig { returns(T::Array[T.any(String, T::Hash[Symbol, T.untyped])]) }
// 33:     attr_reader :new_formula_problems
// 34:
// 35:     sig {
// 36:       params(
// 37:         formula:             Formula,
// 38:         new_formula:         T.nilable(T::Boolean),
// 39:         strict:              T.nilable(T::Boolean),
// 40:         online:              T.nilable(T::Boolean),
// 41:         git:                 T.nilable(T::Boolean),
// 42:         display_cop_names:   T.nilable(T::Boolean),
// 43:         only:                T.nilable(T::Array[String]),
// 44:         except:              T.nilable(T::Array[String]),
// 45:         style_offenses:      T.nilable(T::Array[Style::Offense]),
// 46:         core_tap:            T.nilable(T::Boolean),
// 47:         tap_audit:           T.nilable(T::Boolean),
// 48:         spdx_license_data:   T.nilable(T::Hash[String, T.untyped]),
// 49:         spdx_exception_data: T.nilable(T::Hash[String, T.untyped]),
// 50:       ).void
// 51:     }
// 52:     def initialize(formula, new_formula: nil, strict: nil, online: nil, git: nil, display_cop_names: nil, only: nil,
// 53:                    except: nil, style_offenses: nil, core_tap: nil, tap_audit: nil, spdx_license_data: nil,
// 54:                    spdx_exception_data: nil)
// 55:       @formula = formula
// 56:       @versioned_formula = T.let(formula.versioned_formula?, T::Boolean)
// 57:       @new_formula_inclusive = new_formula
// 58:       @new_formula = new_formula && !@versioned_formula
// 59:       @strict = strict
// 60:       @online = online
// 61:       @git = git
// 62:       @display_cop_names = display_cop_names
// 63:       @only = only
// 64:       @except = except
// 65:       # Accept precomputed style offense results, for efficiency
// 66:       @style_offenses = style_offenses
// 67:       # Allow the formula tap to be set as homebrew/core, for testing purposes
// 68:       @core_tap = T.let(formula.tap&.core_tap? || core_tap || false, T::Boolean)
// 69:       @problems = T.let([], T::Array[T.any(String, T::Hash[Symbol, T.untyped])])
// 70:       @new_formula_problems = T.let([], T::Array[T.any(String, T::Hash[Symbol, T.untyped])])
// 71:       @text = T.let(formula.path.open("rb", &:read), String)
// 72:       @specs = T.let(%w[stable head].filter_map { |s| formula.public_send(s) }, T::Array[SoftwareSpec])
// 73:       @spdx_license_data = spdx_license_data
// 74:       @spdx_exception_data = spdx_exception_data
// 75:       @tap_audit = tap_audit
// 76:       @committed_version_info_cache = T.let({}, T::Hash[String, T.untyped])
// 77:     end
// 78:
// 79:     sig { void }
// 80:     def audit_style
// 81:       return unless @style_offenses
// 82:
// 83:       @style_offenses.each do |offense|
// 84:         cop_name = "#{offense.cop_name}: " if @display_cop_names
// 85:         message = "#{cop_name}#{offense.message}"
// 86:
// 87:         problem message, location: offense.location, corrected: offense.corrected?
// 88:       end
// 89:     end
// 90:
// 91:     sig { void }
// 92:     def audit_file
// 93:       if formula.core_formula? && @versioned_formula
// 94:         unversioned_name = formula.name.gsub(/@.*$/, "")
// 95:
// 96:         # ignore when an unversioned formula doesn't exist after an explicit rename
// 97:         return if formula.tap!.formula_renames.key?(unversioned_name)
// 98:
// 99:         # build this ourselves as we want e.g. homebrew/core to be present
// 100:         full_name = "#{formula.tap!}/#{unversioned_name}"
// 101:
// 102:         unversioned_formula = begin
// 103:           Formulary.factory(full_name).path
// 104:         rescue FormulaUnavailableError, TapFormulaAmbiguityError
// 105:           Pathname.new formula.path.to_s.gsub(/@.*\.rb$/, ".rb")
// 106:         end
// 107:         unless unversioned_formula.exist?
// 108:           unversioned_name = unversioned_formula.basename(".rb")
// 109:           problem "#{formula} is versioned but no #{unversioned_name} formula exists"
// 110:         end
// 111:       elsif formula.stable? &&
// 112:             !@versioned_formula &&
// 113:             (versioned_formulae = formula.versioned_formulae - [formula]) &&
// 114:             versioned_formulae.present?
// 115:         versioned_aliases, unversioned_aliases = formula.aliases.partition { |a| /.@\d/.match?(a) }
// 116:         last_alias_version = versioned_formulae.map(&:name).fetch(-1).split("@").fetch(-1)
// 117:
// 118:         alias_name_major = "#{formula.name}@#{formula.version.major}"
// 119:         alias_name_major_minor = "#{formula.name}@#{formula.version.major_minor}"
// 120:         alias_name = if last_alias_version.split(".").length == 1
// 121:           alias_name_major
// 122:         else
// 123:           alias_name_major_minor
// 124:         end
// 125:         valid_main_alias_names = [alias_name_major, alias_name_major_minor].uniq
// 126:
// 127:         # Also accept versioned aliases with names of other aliases, but do not require them.
// 128:         valid_other_alias_names = unversioned_aliases.flat_map do |name|
// 129:           %W[
// 130:             #{name}@#{formula.version.major}
// 131:             #{name}@#{formula.version.major_minor}
// 132:           ].uniq
// 133:         end
// 134:
// 135:         unless @core_tap
// 136:           [versioned_aliases, valid_main_alias_names, valid_other_alias_names].each do |array|
// 137:             array.map! { |a| "#{formula.tap}/#{a}" }
// 138:           end
// 139:         end
// 140:
// 141:         valid_versioned_aliases = versioned_aliases & valid_main_alias_names
// 142:         invalid_versioned_aliases = versioned_aliases - valid_main_alias_names - valid_other_alias_names
// 143:
// 144:         latest_versioned_formula = versioned_formulae.map(&:name).first
// 145:
// 146:         if valid_versioned_aliases.empty? && alias_name != latest_versioned_formula
// 147:           if formula.tap
// 148:             problem <<~EOS
// 149:               Formula has other versions so create a versioned alias:
// 150:                 cd #{formula.tap!.alias_dir}
// 151:                 ln -s #{formula.path.to_s.gsub(formula.tap!.path.to_s, "..")} #{alias_name}
// 152:             EOS
// 153:           else
// 154:             problem "Formula has other versions so create an alias named '#{alias_name}'."
// 155:           end
// 156:         end
// 157:
// 158:         if invalid_versioned_aliases.present?
// 159:           problem <<~EOS
// 160:             Formula has invalid versioned aliases:
// 161:               #{invalid_versioned_aliases.join("\n  ")}
// 162:           EOS
// 163:         end
// 164:       end
// 165:
// 166:       return if !formula.core_formula? || formula.path == formula.tap!.new_formula_path(formula.name)
// 167:
// 168:       problem <<~EOS
// 169:         Formula is in wrong path:
// 170:           Expected: #{formula.tap!.new_formula_path(formula.name)}
// 171:             Actual: #{formula.path}
// 172:       EOS
// 173:     end
// 174:
// 175:     sig { returns(T::Array[String]) }
// 176:     def self.aliases
// 177:       # core aliases + tap alias names + tap alias full name
// 178:       @aliases ||= T.let(Formula.aliases + Formula.tap_aliases, T.nilable(T::Array[String]))
// 179:     end
// 180:
// 181:     sig { void }
// 182:     def audit_synced_versions_formulae
// 183:       return unless formula.synced_with_other_formulae?
// 184:
// 185:       name = formula.name
// 186:       version = formula.version
// 187:
// 188:       formula.tap!.synced_versions_formulae.each do |synced_version_formulae|
// 189:         next unless synced_version_formulae.include?(name)
// 190:
// 191:         synced_version_formulae.each do |synced_formula|
// 192:           next if synced_formula == name
// 193:
// 194:           if (synced_version = Formulary.factory(synced_formula).version) != version
// 195:             problem "Version of #{synced_formula} (#{synced_version}) should match version of #{name} (#{version})"
// 196:           end
// 197:         end
// 198:
// 199:         break
// 200:       end
// 201:     end
// 202:
// 203:     sig { void }
// 204:     def audit_name
// 205:       name = formula.name
// 206:
// 207:       name_auditor = Homebrew::FormulaNameCaskTokenAuditor.new(name)
// 208:       if (errors = name_auditor.errors).any?
// 209:         problem "Formula name '#{name}' must not contain #{errors.to_sentence(two_words_connector: " or ",
// 210:                                                                               last_word_connector: " or ")}."
// 211:       end
// 212:
// 213:       return unless @core_tap
// 214:       return unless @strict
// 215:
// 216:       problem "'#{name}' is not allowed in homebrew/core." if MissingFormula.disallowed_reason(name)
// 217:
// 218:       if Formula.aliases.include? name
// 219:         problem "Formula name conflicts with existing aliases in homebrew/core."
// 220:         return
// 221:       end
// 222:
// 223:       if (oldname = CoreTap.instance.formula_renames[name])
// 224:         problem "'#{name}' is reserved as the old name of #{oldname} in homebrew/core."
// 225:         return
// 226:       end
// 227:
// 228:       cask_tokens = CoreCaskTap.instance.cask_tokens.presence
// 229:       cask_tokens ||= Homebrew::API.cask_tokens
// 230:
// 231:       if cask_tokens.include?(name)
// 232:         problem "Formula name conflicts with an existing Homebrew/cask cask's token."
// 233:         return
// 234:       end
// 235:
// 236:       return if formula.core_formula?
// 237:       return unless Formula.core_names.include?(name)
// 238:
// 239:       problem "Formula name conflicts with an existing formula in homebrew/core."
// 240:     end
// 241:
// 242:     PERMITTED_LICENSE_MISMATCHES = T.let({
// 243:       "AGPL-3.0" => ["AGPL-3.0-only", "AGPL-3.0-or-later"],
// 244:       "GPL-2.0"  => ["GPL-2.0-only",  "GPL-2.0-or-later"],
// 245:       "GPL-3.0"  => ["GPL-3.0-only",  "GPL-3.0-or-later"],
// 246:       "LGPL-2.1" => ["LGPL-2.1-only", "LGPL-2.1-or-later"],
// 247:       "LGPL-3.0" => ["LGPL-3.0-only", "LGPL-3.0-or-later"],
// 248:     }.freeze, T::Hash[String, T::Array[String]])
// 249:
// 250:     # The following licenses are non-free/open based on multiple sources (e.g. Debian, Fedora, FSF, OSI, ...)
// 251:     INCOMPATIBLE_LICENSES = [
// 252:       "Aladdin",    # https://www.gnu.org/licenses/license-list.html#Aladdin
// 253:       "CPOL-1.02",  # https://www.gnu.org/licenses/license-list.html#cpol
// 254:       "gSOAP-1.3b", # https://salsa.debian.org/ellert/gsoap/-/blob/HEAD/debian/copyright
// 255:       "JSON",       # https://wiki.debian.org/DFSGLicenses#JSON_evil_license
// 256:       "MS-LPL",     # https://github.com/spdx/license-list-XML/issues/1432#issuecomment-1077680709
// 257:       "OPL-1.0",    # https://wiki.debian.org/DFSGLicenses#Open_Publication_License_.28OPL.29_v1.0
// 258:     ].freeze
// 259:     INCOMPATIBLE_LICENSE_PREFIXES = [
// 260:       "BUSL",     # https://spdx.org/licenses/BUSL-1.1.html#notes
// 261:       "CC-BY-NC", # https://people.debian.org/~bap/dfsg-faq.html#no_commercial
// 262:       "Elastic",  # https://www.elastic.co/licensing/elastic-license#Limitations
// 263:       "SSPL",     # https://fedoraproject.org/wiki/Licensing/SSPL#License_Notes
// 264:     ].freeze
// 265:
// 266:     sig { void }
// 267:     def audit_license
// 268:       if formula.license.present?
// 269:         licenses, exceptions = SPDX.parse_license_expression formula.license
// 270:
// 271:         incompatible_licenses = licenses.select do |license|
// 272:           license.to_s.start_with?(*INCOMPATIBLE_LICENSE_PREFIXES) || INCOMPATIBLE_LICENSES.include?(license.to_s)
// 273:         end
// 274:         if incompatible_licenses.present? && @core_tap
// 275:           problem <<~EOS
// 276:             Formula #{formula.name} contains incompatible licenses: #{incompatible_licenses}.
// 277:             Formulae in homebrew/core must either use a Debian Free Software Guidelines license
// 278:             or be released into the public domain: #{Formatter.url("https://docs.brew.sh/Licence-Guidelines")}
// 279:           EOS
// 280:         end
// 281:
// 282:         non_standard_licenses = licenses.reject { |license| SPDX.valid_license? license }
// 283:         if non_standard_licenses.present?
// 284:           problem <<~EOS
// 285:             Formula #{formula.name} contains non-standard SPDX licenses: #{non_standard_licenses}.
// 286:             For a list of valid licenses check: #{Formatter.url("https://spdx.org/licenses/")}
// 287:           EOS
// 288:         end
// 289:
// 290:         if @strict || @core_tap
// 291:           deprecated_licenses = licenses.select do |license|
// 292:             SPDX.deprecated_license? license
// 293:           end
// 294:           if deprecated_licenses.present?
// 295:             problem <<~EOS
// 296:               Formula #{formula.name} contains deprecated SPDX licenses: #{deprecated_licenses}.
// 297:               You may need to add `-only` or `-or-later` for GNU licenses (e.g. `GPL`, `LGPL`, `AGPL`, `GFDL`).
// 298:               For a list of valid licenses check: #{Formatter.url("https://spdx.org/licenses/")}
// 299:             EOS
// 300:           end
// 301:         end
// 302:
// 303:         invalid_exceptions = exceptions.reject { |exception| SPDX.valid_license_exception? exception }
// 304:         if invalid_exceptions.present?
// 305:           problem <<~EOS
// 306:             Formula #{formula.name} contains invalid or deprecated SPDX license exceptions: #{invalid_exceptions}.
// 307:             For a list of valid license exceptions check:
// 308:               #{Formatter.url("https://spdx.org/licenses/exceptions-index.html")}
// 309:           EOS
// 310:         end
// 311:
// 312:         return unless @online
// 313:
// 314:         user, repo = get_repo_data(%r{https?://github\.com/([^/]+)/([^/]+)/?.*})
// 315:         return if user.blank? || repo.blank?
// 316:
// 317:         stable = formula.stable
// 318:         raise "Stable is nil for formula #{formula.name}" if stable.nil?
// 319:
// 320:         url = stable.url
// 321:         raise "Stable URL is nil for formula #{formula.name}" if url.nil?
// 322:
// 323:         tag = SharedAudits.github_tag_from_url(url)
// 324:         tag ||= stable.specs[:tag]
// 325:         github_license = GitHub.get_repo_license(user, repo, ref: tag)
// 326:         return unless github_license
// 327:         return if (licenses + ["NOASSERTION"]).include?(github_license)
// 328:         return if PERMITTED_LICENSE_MISMATCHES[github_license]&.intersect?(licenses)
// 329:         return if formula.tap&.audit_exception :permitted_formula_license_mismatches, formula.name
// 330:
// 331:         problem "Formula license #{licenses} does not match GitHub license #{Array(github_license)}."
// 332:
// 333:       elsif @core_tap && !formula.disabled?
// 334:         problem "Formulae in homebrew/core must specify a license."
// 335:       end
// 336:     end
// 337:
// 338:     sig { void }
// 339:     def audit_deps
// 340:       @specs.each do |spec|
// 341:         # Check for things we don't like to depend on.
// 342:         # We allow non-Homebrew installs whenever possible.
// 343:         spec.declared_deps.each do |dep|
// 344:           begin
// 345:             dep_f = dep.to_formula
// 346:           rescue TapFormulaUnavailableError
// 347:             # Don't complain about missing cross-tap dependencies
// 348:             next
// 349:           rescue FormulaUnavailableError
// 350:             problem "Can't find dependency '#{dep.name}'."
// 351:             next
// 352:           rescue TapFormulaAmbiguityError
// 353:             problem "Ambiguous dependency '#{dep.name}'."
// 354:             next
// 355:           end
// 356:
// 357:           if dep_f.oldnames.include?(Utils.name_from_full_name(dep.name))
// 358:             problem "Dependency '#{dep.name}' was renamed; use new name '#{dep_f.name}'."
// 359:           end
// 360:
// 361:           if @core_tap &&
// 362:              @new_formula &&
// 363:              !dep.uses_from_macos? &&
// 364:              dep_f.keg_only? &&
// 365:              dep_f.keg_only_reason.provided_by_macos? &&
// 366:              dep_f.keg_only_reason.applicable? &&
// 367:              formula.requirements.none?(LinuxRequirement) &&
// 368:              !formula.tap&.audit_exception(:provided_by_macos_depends_on_allowlist, dep.name)
// 369:             new_formula_problem(
// 370:               "Dependency '#{dep.name}' is provided by macOS; " \
// 371:               "please replace 'depends_on' with 'uses_from_macos'.",
// 372:             )
// 373:           end
// 374:
// 375:           dep.options.each do |opt|
// 376:             next if @core_tap
// 377:             next if dep_f.option_defined?(opt)
// 378:             next if dep_f.requirements.find do |r|
// 379:               if r.recommended?
// 380:                 opt.name == "with-#{r.name}"
// 381:               elsif r.optional?
// 382:                 opt.name == "without-#{r.name}"
// 383:               end
// 384:             end
// 385:
// 386:             problem "Dependency '#{dep}' does not define option: #{opt.name.inspect}"
// 387:           end
// 388:
// 389:           problem "Don't use 'git' as a dependency (it's always available)" if @new_formula && dep.name == "git"
// 390:
// 391:           dep.tags.each do |tag|
// 392:             if [:run, :linked].include?(tag)
// 393:               problem "Dependency '#{dep.name}' is marked as :#{tag}. Remove :#{tag}; it is a no-op."
// 394:             elsif tag.is_a?(Symbol) && Dependable::RESERVED_TAGS.exclude?(tag)
// 395:               problem "Dependency '#{dep.name}' is marked as :#{tag} which is not a valid tag."
// 396:             end
// 397:           end
// 398:
// 399:           next unless @core_tap
// 400:
// 401:           if dep_f.tap.nil?
// 402:             problem <<~EOS
// 403:               Dependency '#{dep.name}' does not exist in any tap.
// 404:             EOS
// 405:           elsif !dep_f.tap!.core_tap?
// 406:             problem <<~EOS
// 407:               Dependency '#{dep.name}' is not in homebrew/core. Formulae in homebrew/core
// 408:               should not have dependencies in external taps.
// 409:             EOS
// 410:           end
// 411:
// 412:           if dep_f.deprecated? && !formula.deprecated? && !formula.disabled?
// 413:             problem <<~EOS
// 414:               Dependency '#{dep.name}' is deprecated but has un-deprecated dependents. Either
// 415:               un-deprecate '#{dep.name}' or deprecate it and all of its dependents.
// 416:             EOS
// 417:           end
// 418:
// 419:           if dep_f.disabled? && !formula.disabled?
// 420:             problem <<~EOS
// 421:               Dependency '#{dep.name}' is disabled but has un-disabled dependents. Either
// 422:               un-disable '#{dep.name}' or disable it and all of its dependents.
// 423:             EOS
// 424:           end
// 425:
// 426:           # we can only verify the OS requirement of the currently running platform
// 427:           os_req = if Homebrew::SimulateSystem.simulating_or_running_on_linux? &&
// 428:                       !dep_f.supports_linux? && !spec.depends_on_macos_set_top_level?
// 429:             "macOS"
// 430:           elsif Homebrew::SimulateSystem.simulating_or_running_on_macos? &&
// 431:                 !dep_f.supports_macos? && !spec.depends_on_linux_set_top_level?
// 432:             "Linux"
// 433:           end
// 434:           problem <<~EOS if os_req
// 435:             Dependency '#{dep.name}' has a #{os_req} requirement. Either move the
// 436:             dependency inside an `on_#{os_req.downcase}` block or add `depends_on :#{os_req.downcase}`.
// 437:           EOS
// 438:
// 439:           # we want to allow uses_from_macos for aliases but not bare dependencies.
// 440:           # we also allow `pkg-config` for backwards compatibility in external taps.
// 441:           if self.class.aliases.include?(dep.name) && !dep.uses_from_macos? && (dep.name != "pkg-config" || @core_tap)
// 442:             problem "Dependency '#{dep.name}' is an alias; use the canonical name '#{dep.to_formula.full_name}'."
// 443:           end
// 444:
// 445:           if dep.tags.include?(:recommended) || dep.tags.include?(:optional)
// 446:             problem "Formulae in homebrew/core should not have optional or recommended dependencies"
// 447:           end
// 448:         end
// 449:
// 450:         next unless @core_tap
// 451:
// 452:         if spec.requirements.map(&:recommended?).any? || spec.requirements.map(&:optional?).any?
// 453:           problem "Formulae in homebrew/core should not have optional or recommended requirements"
// 454:         end
// 455:       end
// 456:
// 457:       return unless @core_tap
// 458:       return if formula.tap&.audit_exception :versioned_dependencies_conflicts_allowlist, formula.name
// 459:
// 460:       # The number of conflicts on Linux is absurd.
// 461:       # TODO: remove this and check these there too.
// 462:       return if Homebrew::SimulateSystem.simulating_or_running_on_linux?
// 463:
// 464:       # Skip the versioned dependencies conflict audit for *-staging branches.
// 465:       # This will allow us to migrate dependents of formulae like Python or OpenSSL
// 466:       # gradually over separate PRs which target a *-staging branch. See:
// 467:       #   https://github.com/Homebrew/homebrew-core/pull/134260
// 468:       ignore_formula_conflict, staging_formula =
// 469:         if @tap_audit && (github_event_path = ENV.fetch("GITHUB_EVENT_PATH", nil)).present?
// 470:           event_payload = JSON.parse(File.read(github_event_path))
// 471:           base_info = event_payload.dig("pull_request", "base").to_h # handle `nil`
// 472:
// 473:           # We need to read the head ref from `GITHUB_EVENT_PATH` because
// 474:           # `git branch --show-current` returns the default branch on PR branches.
// 475:           staging_branch = base_info["ref"]&.end_with?("-staging")
// 476:           homebrew_owned_repo = base_info.dig("repo", "owner", "login") == "Homebrew"
// 477:           homebrew_core_pr = base_info.dig("repo", "name") == "homebrew-core"
// 478:           # Support staging branches named `formula-staging` or `formula@version-staging`.
// 479:           base_formula = base_info["ref"]&.split(/-|@/, 2)&.first
// 480:
// 481:           [staging_branch && homebrew_owned_repo && homebrew_core_pr, base_formula]
// 482:         end
// 483:
// 484:       recursive_runtime_formulae = formula.runtime_formula_dependencies(undeclared: false)
// 485:       version_hash = {}
// 486:       version_conflicts = Set.new
// 487:       recursive_runtime_formulae.each do |f|
// 488:         name = f.name
// 489:         unversioned_name = name.split("@").fetch(0)
// 490:         next if ignore_formula_conflict && unversioned_name == staging_formula
// 491:         # Allow use of the full versioned name (e.g. `python@3.99`) or an unversioned alias (`python`).
// 492:         next if formula.tap&.audit_exception :versioned_formula_dependent_conflicts_allowlist, name
// 493:         next if formula.tap&.audit_exception :versioned_formula_dependent_conflicts_allowlist, unversioned_name
// 494:
// 495:         version_hash[unversioned_name] ||= Set.new
// 496:         version_hash[unversioned_name] << name
// 497:         next if version_hash[unversioned_name].length < 2
// 498:
// 499:         version_conflicts += version_hash[unversioned_name]
// 500:       end
// 501:
// 502:       return if version_conflicts.empty?
// 503:
// 504:       return if formula.disabled?
// 505:
// 506:       return if formula.deprecated? &&
// 507:                 formula.deprecation_reason != DeprecateDisable::FORMULA_DEPRECATE_DISABLE_REASONS[:versioned_formula]
// 508:
// 509:       problem <<~EOS
// 510:         #{formula.full_name} contains conflicting version recursive dependencies:
// 511:           #{version_conflicts.to_a.join ", "}
// 512:         View these with `brew deps --tree #{formula.full_name}`.
// 513:       EOS
// 514:     end
// 515:
// 516:     sig { void }
// 517:     def audit_node_modules
// 518:       return unless @core_tap
// 519:
// 520:       node_modules = formula.libexec/"lib/node_modules"
// 521:       return unless node_modules.directory?
// 522:
// 523:       incompatible_license_packages = %w[
// 524:         @anthropic-ai/claude-agent-sdk
// 525:         @github/copilot
// 526:       ]
// 527:
// 528:       incompatible_license_packages.each do |package|
// 529:         # Search for package in all nested node_modules. Also including dot match for .pnpm hoisted packages
// 530:         next if node_modules.glob("{**/node_modules/,}#{package}/", File::FNM_DOTMATCH).empty?
// 531:
// 532:         problem <<~EOS
// 533:           Formula #{formula.name} uses #{package} which has an incompatible license.
// 534:           All installed npm dependencies must satisfy #{Formatter.url("https://docs.brew.sh/Licence-Guidelines")}
// 535:         EOS
// 536:       end
// 537:     end
// 538:
// 539:     sig { void }
// 540:     def audit_conflicts
// 541:       tap = formula.tap
// 542:       formula.conflicts.each do |conflict|
// 543:         conflicting_formula = Formulary.factory(conflict.name)
// 544:         next if tap != conflicting_formula.tap
// 545:
// 546:         problem "Formula should not conflict with itself" if formula == conflicting_formula
// 547:
// 548:         if T.must(tap).formula_renames.key?(conflict.name) || T.must(tap).aliases.include?(conflict.name)
// 549:           problem "Formula conflict should be declared using " \
// 550:                   "canonical name (#{conflicting_formula.name}) instead of '#{conflict.name}'"
// 551:         end
// 552:
// 553:         reverse_conflict_found = T.let(false, T::Boolean)
// 554:         conflicting_formula.conflicts.each do |reverse_conflict|
// 555:           reverse_conflict_formula = Formulary.factory(reverse_conflict.name)
// 556:           if T.must(tap).formula_renames.key?(reverse_conflict.name) ||
// 557:              T.must(tap).aliases.include?(reverse_conflict.name)
// 558:             problem "Formula #{conflicting_formula.name} conflict should be declared using " \
// 559:                     "canonical name (#{reverse_conflict_formula.name}) instead of '#{reverse_conflict.name}'"
// 560:           end
// 561:
// 562:           reverse_conflict_found ||= reverse_conflict_formula == formula
// 563:         end
// 564:         unless reverse_conflict_found
// 565:           problem "Formula #{conflicting_formula.name} should also have a conflict declared with #{formula.name}"
// 566:         end
// 567:       rescue TapFormulaUnavailableError
// 568:         # Don't complain about missing cross-tap conflicts.
// 569:         next
// 570:       rescue FormulaUnavailableError
// 571:         problem "Can't find conflicting formula #{conflict.name.inspect}."
// 572:       rescue TapFormulaAmbiguityError
// 573:         problem "Ambiguous conflicting formula #{conflict.name.inspect}."
// 574:       end
// 575:     end
// 576:
// 577:     sig { void }
// 578:     def audit_gcc_dependency
// 579:       return unless @core_tap
// 580:       return unless Homebrew::SimulateSystem.simulating_or_running_on_linux?
// 581:       return unless linux_only_gcc_dep?(formula)
// 582:       # https://github.com/Homebrew/homebrew-core/pull/171634
// 583:       # https://github.com/nghttp2/nghttp2/issues/2194
// 584:       return if formula.tap&.audit_exception(:linux_only_gcc_dependency_allowlist, formula.name)
// 585:
// 586:       problem "Formulae in homebrew/core should not have a Linux-only dependency on GCC."
// 587:     end
// 588:
// 589:     sig { void }
// 590:     def audit_glibc
// 591:       return unless @core_tap
// 592:       return if formula.name != "glibc"
// 593:       # Also allow LINUX_GLIBC_NEXT_CI_VERSION for when we're upgrading.
// 594:       return if [OS::LINUX_GLIBC_CI_VERSION, OS::LINUX_GLIBC_NEXT_CI_VERSION].include?(formula.version.to_s)
// 595:
// 596:       problem "The glibc version must be #{OS::LINUX_GLIBC_CI_VERSION}, as needed by our CI on Linux. " \
// 597:               "The glibc formula is for users who have a system glibc with a lower version, " \
// 598:               "which allows them to use our Linux bottles, which were compiled against system glibc on CI."
// 599:     end
// 600:
// 601:     sig { void }
// 602:     def audit_relicensed_formulae
// 603:       return unless @core_tap
// 604:
// 605:       relicensed_version = formula.tap&.audit_exception :relicensed_formulae_versions, formula.name
// 606:       return unless relicensed_version.is_a?(String)
// 607:       return if formula.version < Version.new(relicensed_version)
// 608:
// 609:       problem "#{formula.name} was relicensed to a non-open-source license from version #{relicensed_version}. " \
// 610:               "It must not be upgraded to version #{relicensed_version} or newer."
// 611:     end
// 612:
// 613:     sig { void }
// 614:     def audit_versioned_keg_only
// 615:       return unless @versioned_formula
// 616:       return unless @core_tap
// 617:
// 618:       if formula.keg_only?
// 619:         return if formula.keg_only_reason.versioned_formula?
// 620:         return if formula.name.start_with?("openssl", "libressl") && formula.keg_only_reason.by_macos?
// 621:       end
// 622:
// 623:       return if formula.tap&.audit_exception :versioned_keg_only_allowlist, formula.name
// 624:
// 625:       problem "Versioned formulae in homebrew/core should use `keg_only :versioned_formula`"
// 626:     end
// 627:
// 628:     sig { void }
// 629:     def audit_homepage
// 630:       homepage = formula.homepage
// 631:
// 632:       return if homepage.blank?
// 633:       return if SharedAudits.homepage_browsed_recently?(formula.homepage_browsed)
// 634:
// 635:       return unless @online
// 636:
// 637:       return if formula.tap&.audit_exception :cert_error_allowlist, formula.name, homepage
// 638:
// 639:       return unless DevelopmentTools.curl_handles_most_https_certificates?
// 640:
// 641:       # Skip gnu.org and nongnu.org audit on GitHub runners
// 642:       # See issue: https://github.com/Homebrew/homebrew-core/issues/206757
// 643:       github_runner = GitHub::Actions.env_set? && !ENV["GITHUB_ACTIONS_HOMEBREW_SELF_HOSTED"]
// 644:       return if homepage.match?(%r{^https?://www\.(?:non)?gnu\.org/.+}) && github_runner
// 645:
// 646:       use_homebrew_curl = [:stable, :head].any? do |spec_name|
// 647:         next false unless (spec = formula.public_send(spec_name))
// 648:
// 649:         spec.using == :homebrew_curl
// 650:       end
// 651:
// 652:       if (http_content_problem = curl_check_http_content(
// 653:         homepage,
// 654:         SharedAudits::URL_TYPE_HOMEPAGE,
// 655:         user_agents:       [:browser, :default],
// 656:         check_content:     true,
// 657:         strict:            @strict || false,
// 658:         use_homebrew_curl:,
// 659:       ))
// 660:         problem http_content_problem
// 661:       end
// 662:     end
// 663:
// 664:     sig { void }
// 665:     def audit_duplicate_formula
// 666:       return unless @core_tap
// 667:       return unless @new_formula
// 668:
// 669:       # Using internal API here as using `Formulary.factory` is too slow
// 670:       return if !@online && !Homebrew::API::Internal.cached_packages_json_file_path.exist?
// 671:
// 672:       formula_url = formula.stable&.url
// 673:       return unless formula_url
// 674:
// 675:       formula_hashes = Homebrew::API::Internal.formula_hashes
// 676:       duplicate_formula_name = formula_hashes.find do |name, formula_hash|
// 677:         formula_hash["stable_url_args"].any?(formula_url) && name != formula.name
// 678:       end&.first
// 679:
// 680:       return unless duplicate_formula_name
// 681:
// 682:       new_formula_problem "Possible duplicate, this formula has the same stable URL as `#{duplicate_formula_name}`"
// 683:     end
// 684:
// 685:     sig { void }
// 686:     def audit_bottle_spec
// 687:       # special case: new versioned formulae should be audited
// 688:       return unless @new_formula_inclusive
// 689:       return unless @core_tap
// 690:
// 691:       return unless formula.bottle_defined?
// 692:
// 693:       new_formula_problem "New formulae in homebrew/core should not have a `bottle do` block"
// 694:     end
// 695:
// 696:     sig { void }
// 697:     def audit_eol
// 698:       return unless @online
// 699:       return unless @core_tap
// 700:
// 701:       return if formula.deprecated? || formula.disabled?
// 702:
// 703:       name = if formula.versioned_formula?
// 704:         formula.name.split("@").fetch(0)
// 705:       else
// 706:         formula.name
// 707:       end
// 708:
// 709:       return if formula.tap&.audit_exception :eol_date_blocklist, name
// 710:
// 711:       metadata = SharedAudits.eol_data(name, formula.version.major.to_s)
// 712:       metadata ||= SharedAudits.eol_data(name, formula.version.major_minor.to_s)
// 713:
// 714:       return if metadata.blank? || (metadata.dig("result", "isEol") != true)
// 715:
// 716:       eol_from = metadata.dig("result", "eolFrom")
// 717:       eol_date = Date.parse(eol_from) if eol_from.present?
// 718:
// 719:       message = "Product is EOL"
// 720:       message += " since #{eol_date}" if eol_date.present?
// 721:       message += ", see #{Formatter.url("https://endoflife.date/#{name}")}"
// 722:
// 723:       problem message
// 724:     end
// 725:
// 726:     sig { void }
// 727:     def audit_wayback_url
// 728:       return unless @core_tap
// 729:       return if formula.deprecated? || formula.disabled?
// 730:
// 731:       regex = %r{^https?://web\.archive\.org}
// 732:       problem_prefix = "Formula with a Internet Archive Wayback Machine"
// 733:
// 734:       if formula.stable && regex.match?(T.must(formula.stable).url)
// 735:         problem "#{problem_prefix} `url` should be deprecated with `:repo_removed`"
// 736:       end
// 737:
// 738:       if regex.match?(formula.homepage)
// 739:         problem "#{problem_prefix} `homepage` should find an alternative `homepage` or be deprecated."
// 740:       end
// 741:
// 742:       return unless formula.head
// 743:
// 744:       return unless regex.match?(T.must(formula.head).url)
// 745:
// 746:       problem "Remove Internet Archive Wayback Machine `head` URL"
// 747:     end
// 748:
// 749:     sig { void }
// 750:     def audit_github_repository_archived
// 751:       return if formula.deprecated? || formula.disabled?
// 752:
// 753:       user, repo = get_repo_data(%r{https?://github\.com/([^/]+)/([^/]+)/?.*}) if @online
// 754:       return if user.blank? || repo.nil?
// 755:
// 756:       metadata = SharedAudits.github_repo_data(user, repo)
// 757:       return if metadata.nil?
// 758:
// 759:       problem "GitHub repository is archived" if metadata["archived"]
// 760:     end
// 761:
// 762:     sig { void }
// 763:     def audit_gitlab_repository_archived
// 764:       return if formula.deprecated? || formula.disabled?
// 765:
// 766:       user, repo = get_repo_data(%r{https?://gitlab\.com/([^/]+)/([^/]+)/?.*}) if @online
// 767:       return if user.blank? || repo.nil?
// 768:
// 769:       metadata = SharedAudits.gitlab_repo_data(user, repo)
// 770:       return if metadata.nil?
// 771:
// 772:       problem "GitLab repository is archived" if metadata["archived"]
// 773:     end
// 774:
// 775:     sig { void }
// 776:     def audit_forgejo_repository_archived
// 777:       return if formula.deprecated? || formula.disabled?
// 778:
// 779:       user, repo = get_repo_data(%r{https?://codeberg\.org/([^/]+)/([^/]+)/?.*}) if @online
// 780:       return if user.blank? || repo.nil?
// 781:
// 782:       metadata = SharedAudits.forgejo_repo_data(user, repo)
// 783:       return if metadata.nil?
// 784:
// 785:       problem "Forgejo repository is archived since #{metadata["archived_at"]}" if metadata["archived"]
// 786:     end
// 787:
// 788:     sig { void }
// 789:     def audit_github_repository
// 790:       user, repo = get_repo_data(%r{https?://github\.com/([^/]+)/([^/]+)/?.*}) if @new_formula
// 791:
// 792:       return if user.blank? || repo.nil?
// 793:
// 794:       self_submission = self_submission?(user)
// 795:       warning = SharedAudits.github(user, repo, self_submission:)
// 796:       return if warning.nil?
// 797:
// 798:       new_formula_problem warning
// 799:     end
// 800:
// 801:     sig { void }
// 802:     def audit_gitlab_repository
// 803:       user, repo = get_repo_data(%r{https?://gitlab\.com/([^/]+)/([^/]+)/?.*}) if @new_formula
// 804:       return if user.blank? || repo.nil?
// 805:
// 806:       self_submission = self_submission?(user)
// 807:       warning = SharedAudits.gitlab(user, repo, self_submission:)
// 808:       return if warning.nil?
// 809:
// 810:       new_formula_problem warning
// 811:     end
// 812:
// 813:     sig { void }
// 814:     def audit_bitbucket_repository
// 815:       user, repo = get_repo_data(%r{https?://bitbucket\.org/([^/]+)/([^/]+)/?.*}) if @new_formula
// 816:       return if user.blank? || repo.nil?
// 817:
// 818:       self_submission = self_submission?(user)
// 819:       warning = SharedAudits.bitbucket(user, repo, self_submission:)
// 820:       return if warning.nil?
// 821:
// 822:       new_formula_problem warning
// 823:     end
// 824:
// 825:     sig { void }
// 826:     def audit_forgejo_repository
// 827:       user, repo = get_repo_data(%r{https?://codeberg\.org/([^/]+)/([^/]+)/?.*}) if @new_formula
// 828:       return if user.blank? || repo.nil?
// 829:
// 830:       self_submission = self_submission?(user)
// 831:       warning = SharedAudits.forgejo(user, repo, self_submission:)
// 832:       return if warning.nil?
// 833:
// 834:       new_formula_problem warning
// 835:     end
// 836:
// 837:     sig { params(regex: Regexp).returns(T.nilable([String, String])) }
// 838:     def get_repo_data(regex)
// 839:       return unless @core_tap
// 840:       return unless @online
// 841:
// 842:       _, user, repo = *regex.match(T.must(formula.stable).url) if formula.stable
// 843:       _, user, repo = *regex.match(formula.homepage) unless user
// 844:       _, user, repo = *regex.match(T.must(formula.head).url) if !user && formula.head
// 845:       return if !user || !repo
// 846:
// 847:       repo.delete_suffix!(".git")
// 848:
// 849:       [user, repo]
// 850:     end
// 851:
// 852:     sig { void }
// 853:     def audit_specs
// 854:       problem "HEAD-only (no stable download)" if head_only?(formula) && @core_tap
// 855:
// 856:       %w[Stable HEAD].each do |name|
// 857:         spec_name = name.downcase.to_sym
// 858:         next unless (spec = formula.public_send(spec_name))
// 859:
// 860:         except = @except.to_a
// 861:         if spec_name == :head &&
// 862:            formula.tap&.audit_exception(:head_non_default_branch_allowlist, formula.name, spec.specs[:branch])
// 863:           except << "head_branch"
// 864:         end
// 865:
// 866:         ra = ResourceAuditor.new(
// 867:           spec, spec_name,
// 868:           online: @online, strict: @strict, only: @only, core_tap: @core_tap, except:,
// 869:           use_homebrew_curl: spec.using == :homebrew_curl
// 870:         ).audit
// 871:         ra.problems.each do |message|
// 872:           problem "#{name}: #{message}"
// 873:         end
// 874:
// 875:         spec.resources.each_value do |resource|
// 876:           problem "Resource name should be different from the formula name" if resource.name == formula.name
// 877:
// 878:           ra = ResourceAuditor.new(
// 879:             resource, spec_name,
// 880:             online: @online, strict: @strict, only: @only, except: @except,
// 881:             use_homebrew_curl: resource.using == :homebrew_curl
// 882:           ).audit
// 883:           ra.problems.each do |message|
// 884:             problem "#{name} resource #{resource.name.inspect}: #{message}"
// 885:           end
// 886:         end
// 887:
// 888:         next if spec.patches.empty?
// 889:         next if !@new_formula || !@core_tap
// 890:
// 891:         new_formula_problem(
// 892:           "Formulae should not require patches to build. " \
// 893:           "Patches should be submitted and accepted upstream first.",
// 894:         )
// 895:       end
// 896:
// 897:       return unless @core_tap
// 898:
// 899:       if formula.head && @versioned_formula &&
// 900:          !formula.tap&.audit_exception(:versioned_head_spec_allowlist, formula.name)
// 901:         problem "Versioned formulae should not have a `head` spec"
// 902:       end
// 903:
// 904:       stable = formula.stable
// 905:       return unless stable
// 906:       return unless (url = stable.url)
// 907:
// 908:       version = stable.version
// 909:       problem "Stable: version (#{version}) is set to a string without a digit" unless /\d/.match?(version.to_s)
// 910:
// 911:       stable_version_string = version.to_s
// 912:       if stable_version_string.start_with?("HEAD")
// 913:         problem "Stable: non-HEAD version (#{stable_version_string}) should not begin with `HEAD`"
// 914:       end
// 915:
// 916:       stable_url_version = Version.parse(url)
// 917:       stable_url_minor_version = stable_url_version.minor.to_i
// 918:
// 919:       throttle_rate = formula.livecheck.throttle
// 920:       throttle_days = formula.livecheck.throttle_days
// 921:       if throttle_days.nil? &&
// 922:          !throttle_rate.nil? &&
// 923:          !Livecheck.throttle_allows_bump?(formula, stable.version, throttle_rate:, throttle_days:)
// 924:         throttle_items = []
// 925:         throttle_items << "#{throttle_rate} releases on multiples of #{throttle_rate}" if throttle_rate
// 926:
// 927:         problem "Should only be updated every #{throttle_items.join(" or ")}"
// 928:       end
// 929:
// 930:       case url
// 931:       when /[\d._-](alpha|beta|rc\d)/
// 932:         matched = Regexp.last_match(1)
// 933:         version_prefix = stable_version_string.sub(/\d+$/, "")
// 934:         return if formula.tap&.audit_exception :unstable_allowlist, formula.name, version_prefix
// 935:         return if formula.tap&.audit_exception :unstable_devel_allowlist, formula.name, version_prefix
// 936:
// 937:         problem "Stable: version URLs should not contain `#{matched}`"
// 938:       when %r{download\.gnome\.org/sources}, %r{ftp\.gnome\.org/pub/GNOME/sources}i
// 939:         version_prefix = stable.version.major_minor
// 940:         return if formula.tap&.audit_exception :gnome_devel_allowlist, formula.name, version_prefix
// 941:         return if formula.tap&.audit_exception :gnome_devel_allowlist, formula.name, "all"
// 942:         return if stable_url_version < Version.new("1.0")
// 943:         # All minor versions are stable in the new GNOME version scheme (which starts at version 40.0)
// 944:         # https://discourse.gnome.org/t/new-gnome-versioning-scheme/4235
// 945:         return if stable_url_version >= Version.new("40.0")
// 946:         return if stable_url_minor_version.even?
// 947:
// 948:         problem "Stable: version (#{stable.version}) is a development release"
// 949:       when %r{isc.org/isc/bind\d*/}i
// 950:         return if stable_url_minor_version.even?
// 951:
// 952:         problem "Stable: version (#{stable.version}) is a development release"
// 953:
// 954:       when %r{https?://gitlab\.com/([\w-]+)/([\w-]+)}
// 955:         owner = T.must(Regexp.last_match(1))
// 956:         repo = T.must(Regexp.last_match(2))
// 957:
// 958:         tag = SharedAudits.gitlab_tag_from_url(url)
// 959:         tag ||= stable.specs[:tag]
// 960:         tag ||= stable.version.to_s
// 961:
// 962:         if @online
// 963:           error = SharedAudits.gitlab_release(owner, repo, tag, formula:)
// 964:           problem error if error
// 965:         end
// 966:       when %r{^https://github.com/([\w-]+)/([\w-]+)}
// 967:         owner = T.must(Regexp.last_match(1))
// 968:         repo = T.must(Regexp.last_match(2))
// 969:         tag = SharedAudits.github_tag_from_url(url)
// 970:         tag ||= formula.stable&.specs&.[](:tag)
// 971:
// 972:         if @online && !tag.nil?
// 973:           error = SharedAudits.github_release(owner, repo, tag, formula:)
// 974:           problem error if error
// 975:         end
// 976:       when %r{^https://codeberg\.org/([\w-]+)/([\w-]+)}
// 977:         owner = T.must(Regexp.last_match(1))
// 978:         repo = T.must(Regexp.last_match(2))
// 979:         tag = SharedAudits.forgejo_tag_from_url(url)
// 980:         tag ||= formula.stable&.specs&.[](:tag)
// 981:
// 982:         if @online && !tag.nil?
// 983:           error = SharedAudits.forgejo_release(owner, repo, tag, formula:)
// 984:           problem error if error
// 985:         end
// 986:       end
// 987:     end
// 988:
// 989:     sig { void }
// 990:     def audit_stable_version
// 991:       return unless @git
// 992:       return unless formula.tap # skip formula not from core or any taps
// 993:       return unless formula.tap!.git? # git log is required
// 994:       return if formula.stable.blank?
// 995:
// 996:       current_version = T.must(formula.stable).version
// 997:       current_version_scheme = formula.version_scheme
// 998:
// 999:       previous_version_info, base_ref_version_info = committed_version_info
// 1000:       return unless (base_ref_version = base_ref_version_info[:version])
// 1001:
// 1002:       if current_version == base_ref_version && current_version.to_s != base_ref_version.to_s
// 1003:         problem "Stable: version should not change from #{base_ref_version} to #{current_version}"
// 1004:       elsif current_version < base_ref_version && current_version_scheme == previous_version_info[:version_scheme]
// 1005:         problem "Stable: version should not decrease (from #{base_ref_version} to #{current_version})"
// 1006:       end
// 1007:     end
// 1008:
// 1009:     sig { void }
// 1010:     def audit_revision
// 1011:       new_formula_problem("New formulae should not define a revision.") if @new_formula && !formula.revision.zero?
// 1012:
// 1013:       return unless @git
// 1014:
// 1015:       tap = formula.tap
// 1016:       return if tap.nil?
// 1017:       return unless tap.git?
// 1018:       return if formula.stable.blank?
// 1019:
// 1020:       current_version = T.must(formula.stable).version
// 1021:       current_revision = formula.revision
// 1022:
// 1023:       previous_version_info, base_ref_version_info = committed_version_info
// 1024:
// 1025:       previous_version = previous_version_info[:version]
// 1026:       previous_revision = previous_version_info[:revision]
// 1027:       base_ref_version = base_ref_version_info[:version]
// 1028:       base_ref_revision = base_ref_version_info[:revision]
// 1029:
// 1030:       if (previous_version != base_ref_version || current_version != base_ref_version) &&
// 1031:          !current_revision.zero? && current_revision == base_ref_revision && current_revision == previous_revision
// 1032:         problem "`revision #{current_revision}` should be removed"
// 1033:       elsif current_version == previous_version && previous_revision && current_revision < previous_revision
// 1034:         problem "`revision` should not decrease (from #{previous_revision} to #{current_revision})"
// 1035:       elsif base_ref_revision && current_revision > (base_ref_revision + 1)
// 1036:         problem "`revision` should only increment by 1"
// 1037:       end
// 1038:
// 1039:       revision_increment = current_revision - previous_revision.to_i
// 1040:       return if revision_increment != 1
// 1041:
// 1042:       dependency_names = formula.recursive_dependencies.map(&:name)
// 1043:       return if dependency_names.empty?
// 1044:
// 1045:       changed_dependency_paths = changed_formulae_paths(tap, only_names: dependency_names)
// 1046:       return if changed_dependency_paths.empty?
// 1047:
// 1048:       missing_compatibility_bumps = changed_dependency_paths.filter_map do |path|
// 1049:         changed_formula = Formulary.factory(path)
// 1050:         # Each changed dependency that updates its version must raise its compatibility_version by exactly one.
// 1051:         _, base_ref_dependency_version_info = committed_version_info(formula: changed_formula)
// 1052:         previous_dependency_version = base_ref_dependency_version_info[:version]
// 1053:         current_dependency_version = changed_formula.stable&.version
// 1054:         if previous_dependency_version.present? && current_dependency_version.present? &&
// 1055:            current_dependency_version == previous_dependency_version
// 1056:           next
// 1057:         end
// 1058:
// 1059:         previous_compatibility_version = base_ref_dependency_version_info[:compatibility_version] || 0
// 1060:         current_compatibility_version = changed_formula.compatibility_version || 0
// 1061:         next if current_compatibility_version == previous_compatibility_version + 1
// 1062:
// 1063:         expected_compatibility_version = previous_compatibility_version + 1
// 1064:         "#{changed_formula.name} (#{previous_compatibility_version} to #{expected_compatibility_version})"
// 1065:       end
// 1066:       return if missing_compatibility_bumps.empty? || !formula.core_formula?
// 1067:
// 1068:       problem "`revision` increased but changed recursive dependencies must increase `compatibility_version` by 1 " \
// 1069:               "in the same PR: #{missing_compatibility_bumps.join(", ")}. " \
// 1070:               "See #{Formatter.url("https://docs.brew.sh/Formula-Cookbook#compatibility_version")}."
// 1071:     end
// 1072:
// 1073:     sig { void }
// 1074:     def audit_compatibility_version
// 1075:       return unless @git
// 1076:
// 1077:       tap = formula.tap
// 1078:       return if tap.nil?
// 1079:       return unless tap.git?
// 1080:
// 1081:       _, base_ref_version_info = committed_version_info
// 1082:       return if base_ref_version_info.empty?
// 1083:
// 1084:       previous_compatibility_version = base_ref_version_info[:compatibility_version] || 0
// 1085:       current_compatibility_version = formula.compatibility_version || previous_compatibility_version
// 1086:
// 1087:       if current_compatibility_version < previous_compatibility_version
// 1088:         problem "`compatibility_version` should not decrease " \
// 1089:                 "from #{previous_compatibility_version} to #{current_compatibility_version}"
// 1090:         return
// 1091:       elsif current_compatibility_version > (previous_compatibility_version + 1)
// 1092:         problem "`compatibility_version` should only increment by 1"
// 1093:         return
// 1094:       end
// 1095:
// 1096:       compatibility_increment = current_compatibility_version - previous_compatibility_version
// 1097:       return if compatibility_increment.zero?
// 1098:       return unless formula.valid_platform?
// 1099:
// 1100:       dependent_revision_bumps = changed_formulae_paths(tap).filter_map do |path|
// 1101:         changed_formula = Formulary.factory(path)
// 1102:         next if changed_formula.name == formula.name
// 1103:
// 1104:         dependencies = changed_formula.recursive_dependencies.map(&:name)
// 1105:         # Only formulae that depend (recursively) on the audited formula can justify the bump.
// 1106:         next unless dependencies.include?(formula.name)
// 1107:
// 1108:         _, base_ref_dependent_version_info = committed_version_info(formula: changed_formula)
// 1109:         previous_revision = base_ref_dependent_version_info[:revision] || 0
// 1110:         current_revision = changed_formula.revision
// 1111:         next if current_revision != previous_revision + 1
// 1112:
// 1113:         changed_formula.name
// 1114:       end
// 1115:       return if dependent_revision_bumps.any?
// 1116:
// 1117:       problem "`compatibility_version` increased from #{previous_compatibility_version} to " \
// 1118:               "#{current_compatibility_version} but no recursive dependent formulae increased " \
// 1119:               "`revision` by 1 in this PR. Only bump `compatibility_version` when at least one recursive " \
// 1120:               "dependent needs a `revision` bump. " \
// 1121:               "See #{Formatter.url("https://docs.brew.sh/Formula-Cookbook#compatibility_version")}."
// 1122:     end
// 1123:
// 1124:     sig { void }
// 1125:     def audit_version_scheme
// 1126:       return unless @git
// 1127:       return unless formula.tap # skip formula not from core or any taps
// 1128:       return unless formula.tap!.git? # git log is required
// 1129:       return if formula.stable.blank?
// 1130:
// 1131:       current_version_scheme = formula.version_scheme
// 1132:
// 1133:       _, base_ref_version_info = committed_version_info
// 1134:       previous_version_scheme = base_ref_version_info[:version_scheme]
// 1135:       return if previous_version_scheme.nil?
// 1136:
// 1137:       if current_version_scheme < previous_version_scheme
// 1138:         problem "`version_scheme` should not decrease (from #{previous_version_scheme} to #{current_version_scheme})"
// 1139:       elsif current_version_scheme > (previous_version_scheme + 1)
// 1140:         problem "`version_scheme` should only increment by 1"
// 1141:       end
// 1142:     end
// 1143:
// 1144:     sig { void }
// 1145:     def audit_unconfirmed_checksum_change
// 1146:       return unless @git
// 1147:       return unless formula.tap # skip formula not from core or any taps
// 1148:       return unless formula.tap!.git? # git log is required
// 1149:       return unless (current_stable = formula.stable)
// 1150:
// 1151:       current_version = current_stable.version
// 1152:       current_checksum = current_stable.checksum
// 1153:       current_url = current_stable.url
// 1154:
// 1155:       _, base_ref_version_info = committed_version_info
// 1156:       base_ref_checksum = base_ref_version_info[:checksum]
// 1157:
// 1158:       if current_version == base_ref_version_info[:version] &&
// 1159:          current_url == base_ref_version_info[:url] &&
// 1160:          current_checksum.present? && base_ref_checksum.present? &&
// 1161:          current_checksum != base_ref_checksum
// 1162:         problem(
// 1163:           "stable sha256 changed without the url/version also changing; " \
// 1164:           "please create an issue upstream to rule out malicious " \
// 1165:           "circumstances and to find out why the file changed.",
// 1166:         )
// 1167:       end
// 1168:     end
// 1169:
// 1170:     sig { void }
// 1171:     def audit_text
// 1172:       bin_names = Set.new
// 1173:       bin_names << formula.name
// 1174:       bin_names += formula.aliases
// 1175:       [formula.bin, formula.sbin].each do |dir|
// 1176:         next unless dir.exist?
// 1177:
// 1178:         bin_names += dir.children.map { |child| child.basename.to_s }
// 1179:       end
// 1180:       shell_commands = ["system", "shell_output", "pipe_output"]
// 1181:       bin_names.each do |name|
// 1182:         shell_commands.each do |cmd|
// 1183:           if text.to_s.match?(/test do.*#{cmd}[(\s]+['"]#{Regexp.escape(name)}[\s'"]/m)
// 1184:             problem %Q(Fully scope test `#{cmd}` calls, e.g.: #{cmd} "\#{bin}/#{name}")
// 1185:           end
// 1186:         end
// 1187:       end
// 1188:     end
// 1189:
// 1190:     sig { void }
// 1191:     def audit_reverse_migration
// 1192:       # Only enforce for new formula being re-added to core
// 1193:       return unless @strict
// 1194:       return unless @core_tap
// 1195:       return unless formula.tap!.tap_migrations.key?(formula.name)
// 1196:
// 1197:       problem <<~EOS
// 1198:         #{formula.name} seems to be listed in tap_migrations.json!
// 1199:         Please remove #{formula.name} from present tap & tap_migrations.json
// 1200:         before submitting it to Homebrew/homebrew-#{formula.tap!.repository}.
// 1201:       EOS
// 1202:     end
// 1203:
// 1204:     sig { void }
// 1205:     def audit_prefix_has_contents
// 1206:       return unless formula.prefix.directory?
// 1207:       return unless Keg.new(formula.prefix).empty_installation?
// 1208:
// 1209:       problem <<~EOS
// 1210:         The installation seems to be empty. Please ensure the prefix
// 1211:         is set correctly and expected files are installed.
// 1212:         The prefix configure/make argument may be case-sensitive.
// 1213:       EOS
// 1214:     end
// 1215:
// 1216:     sig { void }
// 1217:     def audit_deprecate_disable
// 1218:       error = SharedAudits.check_deprecate_disable_reason(formula)
// 1219:       problem error if error
// 1220:     end
// 1221:
// 1222:     sig { override.params(output: T.nilable(String)).void }
// 1223:     def problem_if_output(output)
// 1224:       problem(output) if output
// 1225:     end
// 1226:
// 1227:     sig { void }
// 1228:     def audit
// 1229:       only_audits = @only
// 1230:       except_audits = @except
// 1231:
// 1232:       methods.map(&:to_s).grep(/^audit_/).each do |audit_method_name|
// 1233:         name = audit_method_name.delete_prefix("audit_")
// 1234:         next if only_audits&.exclude?(name)
// 1235:         next if except_audits&.include?(name)
// 1236:
// 1237:         send(audit_method_name)
// 1238:       end
// 1239:     end
// 1240:
// 1241:     sig { params(tap: Tap, only_names: T::Array[String]).returns(T::Array[Pathname]) }
// 1242:     def changed_formulae_paths(tap, only_names: [].freeze)
// 1243:       return [] unless tap.git?
// 1244:
// 1245:       base_ref = git_audit_base_ref(tap)
// 1246:       changed_paths = Utils.safe_popen_read(Utils::Git.git, "-C", tap.path, "diff", "--name-only", base_ref)
// 1247:                            .lines
// 1248:                            .filter_map do |line|
// 1249:         relative_path = line.chomp
// 1250:         next unless relative_path.end_with?(".rb")
// 1251:
// 1252:         absolute_path = tap.path/relative_path
// 1253:         next unless absolute_path.exist?
// 1254:         next unless absolute_path.to_s.start_with?(tap.formula_dir.to_s)
// 1255:
// 1256:         absolute_path
// 1257:       end
// 1258:       return changed_paths if only_names.blank?
// 1259:
// 1260:       expected_paths = only_names.filter_map do |name|
// 1261:         formula_name = name.to_s.delete_prefix("#{tap.name}/")
// 1262:         formula_name = formula_name.delete_suffix(".rb")
// 1263:         tap.formula_files_by_name[formula_name]&.expand_path
// 1264:       end.map(&:to_s)
// 1265:
// 1266:       changed_paths.select { |path| expected_paths.include?(path.expand_path.to_s) }
// 1267:     end
// 1268:
// 1269:     sig { params(formula: Formula).returns([T::Hash[Symbol, T.untyped], T::Hash[Symbol, T.untyped]]) }
// 1270:     def committed_version_info(formula: @formula)
// 1271:       empty_result = [{}, {}]
// 1272:       return empty_result unless @git
// 1273:
// 1274:       tap = formula.tap
// 1275:       return empty_result unless tap # skip formula not from core or any taps
// 1276:       return empty_result unless tap.git? # git log is required
// 1277:       return empty_result if formula.stable.blank?
// 1278:
// 1279:       if @committed_version_info_cache.key?(formula.full_name)
// 1280:         return @committed_version_info_cache.fetch(formula.full_name)
// 1281:       end
// 1282:
// 1283:       previous_version_info = {}
// 1284:       base_ref_version_info = {}
// 1285:
// 1286:       current_version = formula.stable&.version
// 1287:       current_revision = formula.revision
// 1288:
// 1289:       fv = FormulaVersions.new(formula)
// 1290:       fv.rev_list(git_audit_base_ref(tap)) do |revision, path|
// 1291:         begin
// 1292:           fv.formula_at_revision(revision, path) do |f|
// 1293:             stable = f.stable
// 1294:             next if stable.blank?
// 1295:
// 1296:             previous_version_info[:version]  = stable.version
// 1297:             previous_version_info[:checksum] = stable.checksum
// 1298:             previous_version_info[:revision] = f.revision
// 1299:             previous_version_info[:version_scheme] = f.version_scheme
// 1300:             previous_version_info[:compatibility_version] = f.compatibility_version
// 1301:
// 1302:             base_ref_version_info[:url] ||= stable.url
// 1303:             base_ref_version_info[:version]  ||= previous_version_info[:version]
// 1304:             base_ref_version_info[:checksum] ||= previous_version_info[:checksum]
// 1305:             base_ref_version_info[:revision] ||= previous_version_info[:revision]
// 1306:             base_ref_version_info[:version_scheme] ||= previous_version_info[:version_scheme]
// 1307:             base_ref_version_info[:compatibility_version] ||= previous_version_info[:compatibility_version]
// 1308:           end
// 1309:         rescue MacOSVersion::Error, LegacyDSLError
// 1310:           break
// 1311:         end
// 1312:
// 1313:         break if previous_version_info[:version]  && current_version  != previous_version_info[:version]
// 1314:         break if previous_version_info[:revision] && current_revision != previous_version_info[:revision]
// 1315:       end
// 1316:
// 1317:       previous_version_info.compact!
// 1318:       base_ref_version_info.compact!
// 1319:
// 1320:       @committed_version_info_cache[formula.full_name] = [previous_version_info, base_ref_version_info]
// 1321:     end
// 1322:
// 1323:     private
// 1324:
// 1325:     sig { params(message: String, location: T.nilable(Homebrew::SourceLocation), corrected: T::Boolean).void }
// 1326:     def problem(message, location: nil, corrected: false)
// 1327:       @problems << { message:, location:, corrected: }
// 1328:     end
// 1329:
// 1330:     sig { params(message: String, location: T.nilable(Homebrew::SourceLocation), corrected: T::Boolean).void }
// 1331:     def new_formula_problem(message, location: nil, corrected: false)
// 1332:       @new_formula_problems << { message:, location:, corrected: }
// 1333:     end
// 1334:
// 1335:     sig { params(repo_owner: String).returns(T::Boolean) }
// 1336:     def self_submission?(repo_owner)
// 1337:       return false if repo_owner.blank?
// 1338:
// 1339:       SharedAudits.self_submission_for_repo_owner?(repo_owner)
// 1340:     end
// 1341:
// 1342:     sig { params(formula: Formula).returns(T::Boolean) }
// 1343:     def head_only?(formula)
// 1344:       !!formula.head && formula.stable.nil?
// 1345:     end
// 1346:
// 1347:     sig { params(formula: Formula).returns(T::Boolean) }
// 1348:     def linux_only_gcc_dep?(formula)
// 1349:       odie "`#linux_only_gcc_dep?` works only on Linux!" if Homebrew::SimulateSystem.simulating_or_running_on_macos?
// 1350:       return false if formula.deps.none? { |dep| dep.name == "gcc" && !dep.implicit? }
// 1351:
// 1352:       variations = formula.to_hash_with_variations["variations"]
// 1353:       # The formula has no variations, so all OS-version-arch triples depend on GCC.
// 1354:       return false if variations.blank?
// 1355:
// 1356:       MacOSVersion::SYMBOLS.keys.product(OnSystem::ARCH_OPTIONS).each do |os, arch|
// 1357:         bottle_tag = Utils::Bottles::Tag.new(system: os, arch:)
// 1358:         next unless bottle_tag.valid_combination?
// 1359:
// 1360:         variation_dependencies = variations.dig(bottle_tag.to_sym, "dependencies")
// 1361:         # This variation either:
// 1362:         #   1. does not exist
// 1363:         #   2. has no variation-specific dependencies
// 1364:         # In either case, it matches Linux. We must check for `nil` because an empty
// 1365:         # array indicates that this variation does not depend on GCC.
// 1366:         return false if variation_dependencies.nil?
// 1367:         # We found a non-Linux variation that depends on GCC.
// 1368:         return false if variation_dependencies.include?("gcc")
// 1369:       end
// 1370:
// 1371:       true
// 1372:     end
// 1373:
// 1374:     sig { params(tap: Tap).returns(String) }
// 1375:     def git_audit_base_ref(tap)
// 1376:       @git_audit_base_ref_cache ||= T.let({}, T.nilable(T::Hash[Pathname, T.nilable(String)]))
// 1377:       @git_audit_base_ref_cache[tap.path] ||= Utils.popen_read(Utils::Git.git, "-C", tap.path, "merge-base",
// 1378:                                                                "origin/HEAD", "HEAD").chomp.presence
// 1379:       @git_audit_base_ref_cache[tap.path] ||= "origin/HEAD"
// 1380:     end
// 1381:   end
// 1382: end
