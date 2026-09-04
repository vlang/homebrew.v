module livecheck

// Translated from Homebrew/brew `livecheck/skip_conditions.rb`.
pub enum SkipConditionsPackageKind {
	formula
	cask
	resource
}

// SkipConditionsPackage is the source-shaped adapter for the Formula,
// Cask::Cask and Resource predicates consumed by this module.
pub struct SkipConditionsPackage {
pub:
	kind                   SkipConditionsPackageKind
	name                   string
	full_name              string
	stable_url             string
	livecheck_defined      bool
	livecheck_skip         bool
	livecheck_skip_message string
	head_only              bool
	any_version_installed  bool
	deprecated             bool
	disabled               bool
	versioned              bool
	has_disable_date       bool
	deprecation_reason     string
	present                bool
	version_latest         bool
	url_unversioned        bool
	livecheck_strategy     string
}

pub struct SkipConditionsMeta {
pub:
	livecheck_defined bool
	head_only         bool
}

pub struct SkipInformation {
pub mut:
	present      bool
	package_kind SkipConditionsPackageKind
	package_name string
	status       string
	messages     []string
	has_messages bool
	meta         SkipConditionsMeta
}

pub struct ReferencedSkipInformation {
pub:
	has_information bool
	information     SkipInformation
}

// SkipConditionsOutput is the injected `puts`/Tty collaborator.
pub struct SkipConditionsOutput {
pub:
	red   string
	reset string
pub mut:
	lines []string
}

pub fn (output SkipConditionsOutput) text() string {
	if output.lines.len == 0 {
		return ''
	}
	return '${output.lines.join('\n')}\n'
}

pub fn skip_conditions_package_from_livecheck(package LivecheckPackage) SkipConditionsPackage {
	return SkipConditionsPackage{
		kind: match package.kind {
			'cask' { .cask }
			'resource' { .resource }
			else { .formula }
		}
		name: package.name
		full_name: package.full_name
		stable_url: package.stable_url
		livecheck_defined: package.livecheck_defined
		livecheck_skip: package.livecheck_strategy == 'skip'
		livecheck_skip_message: if package.livecheck_strategy == 'skip' && package.livecheck_messages.len > 0 {
			package.livecheck_messages[0]
		} else {
			''
		}
		head_only: package.head_only
		any_version_installed: package.installed_head_commit != ''
		versioned: package.kind != 'cask' && package.name.contains('@')
		present: package.name != ''
		version_latest: package.version == 'latest'
	}
}

fn skip_empty() SkipInformation {
	return SkipInformation{}
}

fn skip_name(package SkipConditionsPackage, full_name bool) string {
	if full_name && package.kind != .resource && package.full_name != '' {
		return package.full_name
	}
	return package.name
}

fn skip_status(package SkipConditionsPackage, status string, messages []string,
	has_messages bool, full_name bool) SkipInformation {
	return SkipInformation{
		present: true
		package_kind: package.kind
		package_name: skip_name(package, full_name)
		status: status
		messages: messages.clone()
		has_messages: has_messages
		meta: SkipConditionsMeta{
			livecheck_defined: package.livecheck_defined
			head_only: package.kind == .formula && package.head_only
		}
	}
}

pub fn skip_information_equal(left SkipInformation, right SkipInformation) bool {
	return left.present == right.present && left.package_kind == right.package_kind && left.package_name == right.package_name && left.status == right.status && left.messages == right.messages && left.has_messages == right.has_messages && left.meta.livecheck_defined == right.meta.livecheck_defined && left.meta.head_only == right.meta.head_only
}

fn gist_url(url string) bool {
	lower := url.to_lower()
	return lower.contains('http://gist.github.com/') || lower.contains('https://gist.github.com/') || lower.contains('http://gist.githubusercontent.com/') || lower.contains('https://gist.githubusercontent.com/')
}

// Ruby method `self.package_or_resource_skip(` at line 17.
pub fn skip_conditions_package_or_resource_skip(package SkipConditionsPackage,
	livecheck_defined bool, full_name bool, verbose bool) SkipInformation {
	_ = verbose
	mut skip_message := ''
	if package.livecheck_skip_message.trim_space() != '' {
		skip_message = package.livecheck_skip_message
	} else if !livecheck_defined && package.kind == .formula {
		stable_url := package.stable_url.to_lower()
		if stable_url.contains('http://storage.googleapis.com/google-code-archive-downloads/') || stable_url.contains('https://storage.googleapis.com/google-code-archive-downloads/') {
			skip_message = 'Stable URL is from Google Code Archive'
		} else if stable_url.contains('http://web.archive.org/') || stable_url.contains('https://web.archive.org/') {
			skip_message = 'Stable URL is from Internet Archive'
		} else if gist_url(package.stable_url) {
			skip_message = 'Stable URL is a GitHub Gist'
		}
	}
	if !package.livecheck_skip && skip_message.trim_space() == '' {
		return skip_empty()
	}
	if skip_message != '' {
		return skip_status(package, 'skipped', [skip_message], true, full_name)
	}
	return skip_status(package, 'skipped', []string{}, false, full_name)
}

// Ruby method `self.formula_head_only(formula, _livecheck_defined, full_name: false, verbose: false)` at line 59.
pub fn skip_conditions_formula_head_only(formula SkipConditionsPackage,
	_livecheck_defined bool, full_name bool, verbose bool) SkipInformation {
	_ = verbose
	if !formula.head_only || formula.any_version_installed {
		return skip_empty()
	}
	return skip_status(formula, 'error', [
		'HEAD only formula must be installed to be checkable',
	], true, full_name)
}

// Ruby method `self.formula_deprecated(formula, livecheck_defined, full_name: false, verbose: false)` at line 79.
pub fn skip_conditions_formula_deprecated(formula SkipConditionsPackage,
	livecheck_defined bool, full_name bool, verbose bool) SkipInformation {
	_ = verbose
	if !formula.deprecated || livecheck_defined {
		return skip_empty()
	}
	return skip_status(formula, 'deprecated', []string{}, false, full_name)
}

// Ruby method `self.formula_disabled(formula, livecheck_defined, full_name: false, verbose: false)` at line 93.
pub fn skip_conditions_formula_disabled(formula SkipConditionsPackage,
	livecheck_defined bool, full_name bool, verbose bool) SkipInformation {
	_ = verbose
	if !formula.disabled || livecheck_defined {
		return skip_empty()
	}
	return skip_status(formula, 'disabled', []string{}, false, full_name)
}

// Ruby method `self.formula_versioned(formula, livecheck_defined, full_name: false, verbose: false)` at line 107.
pub fn skip_conditions_formula_versioned(formula SkipConditionsPackage,
	livecheck_defined bool, full_name bool, verbose bool) SkipInformation {
	_ = verbose
	if !formula.versioned || livecheck_defined {
		return skip_empty()
	}
	return skip_status(formula, 'versioned', []string{}, false, full_name)
}

// Ruby method `self.cask_deprecated(cask, livecheck_defined, full_name: false, verbose: false)` at line 121.
pub fn skip_conditions_cask_deprecated(cask SkipConditionsPackage,
	livecheck_defined bool, full_name bool, verbose bool) SkipInformation {
	_ = verbose
	if !cask.deprecated || livecheck_defined {
		return skip_empty()
	}
	if cask.has_disable_date && cask.deprecation_reason == 'fails_gatekeeper_check' {
		return skip_empty()
	}
	return skip_status(cask, 'deprecated', []string{}, false, full_name)
}

// Ruby method `self.cask_disabled(cask, livecheck_defined, full_name: false, verbose: false)` at line 136.
pub fn skip_conditions_cask_disabled(cask SkipConditionsPackage,
	livecheck_defined bool, full_name bool, verbose bool) SkipInformation {
	_ = verbose
	if !cask.disabled || livecheck_defined {
		return skip_empty()
	}
	return skip_status(cask, 'disabled', []string{}, false, full_name)
}

// Ruby method `self.cask_extract_plist(` at line 151.
pub fn skip_conditions_cask_extract_plist(cask SkipConditionsPackage,
	_livecheck_defined bool, full_name bool, verbose bool, extract_plist bool) SkipInformation {
	_ = verbose
	if extract_plist || cask.livecheck_strategy != 'extract_plist' {
		return skip_empty()
	}
	return skip_status(cask, 'skipped', [
		'Use `--extract-plist` to enable checking multiple casks with ExtractPlist strategy',
	], true, full_name)
}

// Ruby method `self.cask_version_latest(cask, livecheck_defined, full_name: false, verbose: false)` at line 177.
pub fn skip_conditions_cask_version_latest(cask SkipConditionsPackage,
	livecheck_defined bool, full_name bool, verbose bool) SkipInformation {
	_ = verbose
	if !(cask.present && cask.version_latest) || livecheck_defined {
		return skip_empty()
	}
	return skip_status(cask, 'latest', []string{}, false, full_name)
}

// Ruby method `self.cask_url_unversioned(cask, livecheck_defined, full_name: false, verbose: false)` at line 191.
pub fn skip_conditions_cask_url_unversioned(cask SkipConditionsPackage,
	livecheck_defined bool, full_name bool, verbose bool) SkipInformation {
	_ = verbose
	if !(cask.present && cask.url_unversioned) || livecheck_defined {
		return skip_empty()
	}
	return skip_status(cask, 'unversioned', []string{}, false, full_name)
}

// Ruby method `self.skip_information(package_or_resource, full_name: false, verbose: false, extract_plist: true)` at line 235.
pub fn skip_conditions_skip_information(package SkipConditionsPackage,
	full_name bool, verbose bool, extract_plist bool) SkipInformation {
	livecheck_defined := package.livecheck_defined
	first := skip_conditions_package_or_resource_skip(package, livecheck_defined, full_name, verbose)
	if first.present {
		return first
	}
	match package.kind {
		.formula {
			for result in [
				skip_conditions_formula_head_only(package, livecheck_defined, full_name, verbose),
				skip_conditions_formula_disabled(package, livecheck_defined, full_name, verbose),
				skip_conditions_formula_deprecated(package, livecheck_defined, full_name, verbose),
				skip_conditions_formula_versioned(package, livecheck_defined, full_name, verbose),
			] {
				if result.present {
					return result
				}
			}
		}
		.cask {
			for result in [
				skip_conditions_cask_disabled(package, livecheck_defined, full_name, verbose),
				skip_conditions_cask_deprecated(package, livecheck_defined, full_name, verbose),
				skip_conditions_cask_extract_plist(package, livecheck_defined, full_name, verbose, extract_plist),
				skip_conditions_cask_version_latest(package, livecheck_defined, full_name, verbose),
				skip_conditions_cask_url_unversioned(package, livecheck_defined, full_name, verbose),
			] {
				if result.present {
					return result
				}
			}
		}
		.resource {}
	}
	return skip_empty()
}
