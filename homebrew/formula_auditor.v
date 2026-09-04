module homebrew

import os

// Translated from Homebrew/brew `formula_auditor.rb`.
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

// Ruby method `audit_style` at line 80.
pub fn formula_auditor_audit_style(mut auditor FormulaAuditor) {
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
pub fn formula_auditor_audit_file(mut auditor FormulaAuditor) {
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

// Ruby method `audit_synced_versions_formulae` at line 182.
pub fn formula_auditor_audit_synced_versions_formulae(mut auditor FormulaAuditor) {
	for synced in auditor.formula.synced_versions {
		if synced.name != auditor.formula.name && synced.version != auditor.formula.version {
			formula_audit_problem(mut auditor, 'Version of ${synced.name} (${synced.version}) should match version of ${auditor.formula.name} (${auditor.formula.version})')
		}
	}
}

// Ruby method `audit_name` at line 204.
pub fn formula_auditor_audit_name(mut auditor FormulaAuditor) {
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
pub fn formula_auditor_audit_license(mut auditor FormulaAuditor) {
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
pub fn formula_auditor_audit_deps(mut auditor FormulaAuditor) {
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
pub fn formula_auditor_audit_node_modules(mut auditor FormulaAuditor) {
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
pub fn formula_auditor_audit_conflicts(mut auditor FormulaAuditor) {
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
pub fn formula_auditor_audit_gcc_dependency(mut auditor FormulaAuditor) {
	if !auditor.core_tap || !auditor.formula.linux || !formula_auditor_linux_only_gcc_dep(auditor.formula) {
		return
	}
	if formula_audit_exception(auditor, 'linux_only_gcc_dependency_allowlist', auditor.formula.name) {
		return
	}
	formula_audit_problem(mut auditor, 'Formulae in homebrew/core should not have a Linux-only dependency on GCC.')
}

// Ruby method `audit_glibc` at line 590.
pub fn formula_auditor_audit_glibc(mut auditor FormulaAuditor) {
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
pub fn formula_auditor_audit_relicensed_formulae(mut auditor FormulaAuditor) {
	f := auditor.formula
	if !auditor.core_tap || f.relicensed_version == '' || formula_audit_compare_versions(f.version, f.relicensed_version) < 0 {
		return
	}
	formula_audit_problem(mut auditor, '${f.name} was relicensed to a non-open-source license from version ${f.relicensed_version}. It must not be upgraded to version ${f.relicensed_version} or newer.')
}

// Ruby method `audit_versioned_keg_only` at line 614.
pub fn formula_auditor_audit_versioned_keg_only(mut auditor FormulaAuditor) {
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
pub fn formula_auditor_audit_homepage(mut auditor FormulaAuditor) {
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
pub fn formula_auditor_audit_duplicate_formula(mut auditor FormulaAuditor) {
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
pub fn formula_auditor_audit_bottle_spec(mut auditor FormulaAuditor) {
	if auditor.new_formula_inclusive && auditor.core_tap && auditor.formula.bottle_defined {
		formula_audit_new_problem(mut auditor, 'New formulae in homebrew/core should not have a `bottle do` block')
	}
}

// Ruby method `audit_eol` at line 697.
pub fn formula_auditor_audit_eol(mut auditor FormulaAuditor) {
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
pub fn formula_auditor_audit_wayback_url(mut auditor FormulaAuditor) {
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
pub fn formula_auditor_audit_github_repository_archived(mut auditor FormulaAuditor) {
	if auditor.formula.deprecated || auditor.formula.disabled || !auditor.options.online {
		return
	}
	if _, _ := formula_auditor_get_repo_data(auditor, 'github.com') {
		if auditor.formula.github_repo.archived {
			formula_audit_problem(mut auditor, 'GitHub repository is archived')
		}
	}
}

// Ruby method `audit_gitlab_repository_archived` at line 763.
pub fn formula_auditor_audit_gitlab_repository_archived(mut auditor FormulaAuditor) {
	if auditor.formula.deprecated || auditor.formula.disabled || !auditor.options.online {
		return
	}
	if _, _ := formula_auditor_get_repo_data(auditor, 'gitlab.com') {
		if auditor.formula.gitlab_repo.archived {
			formula_audit_problem(mut auditor, 'GitLab repository is archived')
		}
	}
}

// Ruby method `audit_forgejo_repository_archived` at line 776.
pub fn formula_auditor_audit_forgejo_repository_archived(mut auditor FormulaAuditor) {
	if auditor.formula.deprecated || auditor.formula.disabled || !auditor.options.online {
		return
	}
	if _, _ := formula_auditor_get_repo_data(auditor, 'codeberg.org') {
		data := auditor.formula.forgejo_repo
		if data.archived {
			formula_audit_problem(mut auditor, 'Forgejo repository is archived since ${data.archived_at}')
		}
	}
}

// Ruby method `audit_github_repository` at line 789.
pub fn formula_auditor_audit_github_repository(mut auditor FormulaAuditor) {
	if !auditor.new_formula {
		return
	}
	if owner, _ := formula_auditor_get_repo_data(auditor, 'github.com') {
		_ = formula_auditor_submission(owner, auditor.options.self_submission_owners)
		if auditor.formula.github_repo.warning != '' {
			formula_audit_new_problem(mut auditor, auditor.formula.github_repo.warning)
		}
	}
}

// Ruby method `audit_gitlab_repository` at line 802.
pub fn formula_auditor_audit_gitlab_repository(mut auditor FormulaAuditor) {
	if !auditor.new_formula {
		return
	}
	if owner, _ := formula_auditor_get_repo_data(auditor, 'gitlab.com') {
		_ = formula_auditor_submission(owner, auditor.options.self_submission_owners)
		if auditor.formula.gitlab_repo.warning != '' {
			formula_audit_new_problem(mut auditor, auditor.formula.gitlab_repo.warning)
		}
	}
}

// Ruby method `audit_bitbucket_repository` at line 814.
pub fn formula_auditor_audit_bitbucket_repository(mut auditor FormulaAuditor) {
	if !auditor.new_formula {
		return
	}
	if owner, _ := formula_auditor_get_repo_data(auditor, 'bitbucket.org') {
		_ = formula_auditor_submission(owner, auditor.options.self_submission_owners)
		if auditor.formula.bitbucket_repo.warning != '' {
			formula_audit_new_problem(mut auditor, auditor.formula.bitbucket_repo.warning)
		}
	}
}

// Ruby method `audit_forgejo_repository` at line 826.
pub fn formula_auditor_audit_forgejo_repository(mut auditor FormulaAuditor) {
	if !auditor.new_formula {
		return
	}
	if owner, _ := formula_auditor_get_repo_data(auditor, 'codeberg.org') {
		_ = formula_auditor_submission(owner, auditor.options.self_submission_owners)
		if auditor.formula.forgejo_repo.warning != '' {
			formula_audit_new_problem(mut auditor, auditor.formula.forgejo_repo.warning)
		}
	}
}

// Ruby method `get_repo_data(regex)` at line 838.
pub fn formula_auditor_get_repo_data(auditor FormulaAuditor, host string) ?(string, string) {
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
pub fn formula_auditor_audit_specs(mut auditor FormulaAuditor) {
	f := auditor.formula
	if formula_auditor_head_only(f) && auditor.core_tap {
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
pub fn formula_auditor_audit_stable_version(mut auditor FormulaAuditor) {
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
pub fn formula_auditor_audit_revision(mut auditor FormulaAuditor) {
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
pub fn formula_auditor_audit_compatibility_version(mut auditor FormulaAuditor) {
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
pub fn formula_auditor_audit_version_scheme(mut auditor FormulaAuditor) {
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
pub fn formula_auditor_audit_unconfirmed_checksum_change(mut auditor FormulaAuditor) {
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
pub fn formula_auditor_audit_text(mut auditor FormulaAuditor) {
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
pub fn formula_auditor_audit_reverse_migration(mut auditor FormulaAuditor) {
	if auditor.options.strict && auditor.core_tap && auditor.formula.tap_migration {
		f := auditor.formula
		formula_audit_problem(mut auditor, '${f.name} seems to be listed in tap_migrations.json!\nPlease remove ${f.name} from present tap & tap_migrations.json\nbefore submitting it to Homebrew/homebrew-${f.tap_repository}.\n')
	}
}

// Ruby method `audit_prefix_has_contents` at line 1205.
pub fn formula_auditor_audit_prefix_has_contents(mut auditor FormulaAuditor) {
	if auditor.formula.prefix_directory && auditor.formula.empty_installation {
		formula_audit_problem(mut auditor, 'The installation seems to be empty. Please ensure the prefix\nis set correctly and expected files are installed.\nThe prefix configure/make argument may be case-sensitive.\n')
	}
}

// Ruby method `audit_deprecate_disable` at line 1217.
pub fn formula_auditor_audit_deprecate_disable(mut auditor FormulaAuditor) {
	if auditor.formula.deprecate_disable_error != '' {
		formula_audit_problem(mut auditor, auditor.formula.deprecate_disable_error)
	}
}

// Ruby method `self_submission?(repo_owner)` at line 1336.
pub fn formula_auditor_submission(repo_owner string, submission_owners []string) bool {
	return repo_owner != '' && repo_owner in submission_owners
}

// Ruby method `head_only?(formula)` at line 1343.
pub fn formula_auditor_head_only(formula FormulaAuditFormula) bool {
	return formula.head_url != '' && !formula.stable
}

// Ruby method `linux_only_gcc_dep?(formula)` at line 1348.
pub fn formula_auditor_linux_only_gcc_dep(formula FormulaAuditFormula) bool {
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
