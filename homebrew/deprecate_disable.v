module homebrew

import ruby

// Translated from Homebrew/brew `deprecate_disable.rb`.

pub enum DeprecateDisablePackageKind {
	formula
	cask
}

pub struct DeprecateDisableSubject {
pub:
	kind                DeprecateDisablePackageKind
	deprecated          bool
	disabled            bool
	deprecation_reason  string
	disable_reason      string
	disable_date        string
	deprecation_date    string
	deprecation_formula string
	deprecation_cask    string
	disable_formula     string
	disable_cask        string
}

pub struct DeprecateDisableReason {
pub:
	value     string
	is_symbol bool
}

pub fn deprecate_disable_type(subject DeprecateDisableSubject) string {
	if subject.deprecated {
		return 'deprecated'
	}
	if subject.disabled {
		return 'disabled'
	}
	return ''
}

pub fn deprecate_disable_replacement_with_type(formula string, cask string) string {
	if formula != '' && formula == cask {
		return formula
	}
	if formula != '' {
		return '--formula ${formula}'
	}
	if cask != '' {
		return '--cask ${cask}'
	}
	return ''
}

fn formula_deprecate_disable_reason(reason string) string {
	return match reason {
		'does_not_build' {
			'does not build'
		}
		'no_license' {
			'has no license'
		}
		'repo_archived' {
			'has an archived upstream repository'
		}
		'repo_removed' {
			'has a removed upstream repository'
		}
		'unmaintained' {
			'is not maintained upstream'
		}
		'unreachable' {
			'is no longer reliably reachable upstream'
		}
		'unsupported' {
			'is not supported upstream'
		}
		'deprecated_upstream' {
			'is deprecated upstream'
		}
		'versioned_formula' {
			'is a versioned formula'
		}
		'checksum_mismatch' {
			"was built with an initially released source file that had a different checksum than the current one. Upstream's repository might have been compromised. We can re-package this once upstream has confirmed that they retagged their release"
		}
		else {
			''
		}
	}
}

fn cask_deprecate_disable_reason(reason string) string {
	return match reason {
		'discontinued' { 'is discontinued upstream' }
		'moved_to_mas' { 'is now exclusively distributed on the Mac App Store' }
		'no_longer_available' { 'is no longer available upstream' }
		'no_longer_meets_criteria' { 'no longer meets the criteria for acceptable casks' }
		'unmaintained' { 'is not maintained upstream' }
		'fails_gatekeeper_check' { 'does not pass the macOS Gatekeeper check' }
		'unreachable' { 'is no longer reliably reachable upstream' }
		else { '' }
	}
}

fn add_twelve_months(date string) string {
	parts := date.split('-')
	if parts.len != 3 {
		return date
	}
	year := parts[0].int() + 1
	mut day := parts[2].int()
	if parts[1] == '02' && day == 29 {
		day = 28
	}
	return '${year:04d}-${parts[1]}-${day:02d}'
}

pub fn deprecate_disable_message(subject DeprecateDisableSubject, today string) ?string {
	type_name := deprecate_disable_type(subject)
	if type_name == '' {
		return none
	}
	mut reason := if subject.deprecated {
		subject.deprecation_reason
	} else {
		subject.disable_reason
	}
	preset := match subject.kind {
		.formula { formula_deprecate_disable_reason(reason) }
		.cask { cask_deprecate_disable_reason(reason) }
	}
	if preset != '' {
		reason = preset
	}
	mut message := if reason != '' {
		'${type_name} because it ${reason}!'
	} else {
		'${type_name}!'
	}
	mut disable_date := subject.disable_date
	if disable_date == '' && subject.deprecation_date != '' {
		disable_date = add_twelve_months(subject.deprecation_date)
	}
	if disable_date != '' {
		message += if disable_date < today {
			' It was disabled on ${disable_date}.'
		} else {
			' It will be disabled on ${disable_date}.'
		}
	}
	formula := if subject.disabled { subject.disable_formula } else { subject.deprecation_formula }
	cask := if subject.disabled { subject.disable_cask } else { subject.deprecation_cask }
	replacement := deprecate_disable_replacement_with_type(formula, cask)
	if replacement != '' {
		message += '\nReplacement:\n  brew install ${replacement}\n'
	}
	return message
}

pub fn deprecate_disable_reason_from_string(value ?string, kind DeprecateDisablePackageKind) ?DeprecateDisableReason {
	if reason := value {
		preset := match kind {
			.formula { formula_deprecate_disable_reason(reason) }
			.cask { cask_deprecate_disable_reason(reason) }
		}
		return DeprecateDisableReason{
			value: reason
			is_symbol: preset != ''
		}
	}
	return none
}

pub fn deprecate_disable_subject_value(subject DeprecateDisableSubject) ruby.Value {
	return ruby.structured_value('DeprecateDisableSubject', deprecate_disable_type(subject), {
		'kind':                subject.kind.str()
		'deprecated':          subject.deprecated.str()
		'disabled':            subject.disabled.str()
		'deprecation_reason':  subject.deprecation_reason
		'disable_reason':      subject.disable_reason
		'disable_date':        subject.disable_date
		'deprecation_date':    subject.deprecation_date
		'deprecation_formula': subject.deprecation_formula
		'deprecation_cask':    subject.deprecation_cask
		'disable_formula':     subject.disable_formula
		'disable_cask':        subject.disable_cask
	})
}

fn deprecate_disable_subject_from_value(value ruby.Value) DeprecateDisableSubject {
	if value.type_name != 'DeprecateDisableSubject' {
		panic('expected DeprecateDisableSubject, got ${value.type_name}')
	}
	kind := if (value.attribute('kind') or { panic(err) }) == 'cask' {
		DeprecateDisablePackageKind.cask
	} else {
		DeprecateDisablePackageKind.formula
	}
	return DeprecateDisableSubject{
		kind: kind
		deprecated: (value.attribute('deprecated') or { panic(err) }) == 'true'
		disabled: (value.attribute('disabled') or { panic(err) }) == 'true'
		deprecation_reason: value.attribute('deprecation_reason') or { panic(err) }
		disable_reason: value.attribute('disable_reason') or { panic(err) }
		disable_date: value.attribute('disable_date') or { panic(err) }
		deprecation_date: value.attribute('deprecation_date') or { panic(err) }
		deprecation_formula: value.attribute('deprecation_formula') or { panic(err) }
		deprecation_cask: value.attribute('deprecation_cask') or { panic(err) }
		disable_formula: value.attribute('disable_formula') or { panic(err) }
		disable_cask: value.attribute('disable_cask') or { panic(err) }
	}
}

// Ruby method `to_reason_string_or_symbol(string, type:)` at line 122.
pub fn ruby_deprecate_disable_l122_d4_to_reason_string_or_symbol(args ...ruby.Value) ruby.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return ruby.object_value('NilClass', '')
	}
	kind := if args.len > 1 && args[1].as_string().trim_left(':') == 'cask' {
		DeprecateDisablePackageKind.cask
	} else {
		DeprecateDisablePackageKind.formula
	}
	reason := deprecate_disable_reason_from_string(args[0].as_string(), kind) or {
		return ruby.object_value('NilClass', '')
	}
	return if reason.is_symbol {
		ruby.object_value('Symbol', reason.value)
	} else {
		ruby.string_value(reason.value)
	}
}
