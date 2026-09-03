module homebrew

import brew_runtime

// Translated from Homebrew/brew `deprecate_disable.rb`.
// The original source is retained below until every stub has a typed V body.

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
			value:     reason
			is_symbol: preset != ''
		}
	}
	return none
}

pub fn deprecate_disable_subject_value(subject DeprecateDisableSubject) brew_runtime.Value {
	return brew_runtime.structured_value('DeprecateDisableSubject',
		deprecate_disable_type(subject), {
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

fn deprecate_disable_subject_from_value(value brew_runtime.Value) DeprecateDisableSubject {
	if value.type_name != 'DeprecateDisableSubject' {
		panic('expected DeprecateDisableSubject, got ${value.type_name}')
	}
	kind := if (value.attribute('kind') or { panic(err) }) == 'cask' {
		DeprecateDisablePackageKind.cask
	} else {
		DeprecateDisablePackageKind.formula
	}
	return DeprecateDisableSubject{
		kind:                kind
		deprecated:          (value.attribute('deprecated') or { panic(err) }) == 'true'
		disabled:            (value.attribute('disabled') or { panic(err) }) == 'true'
		deprecation_reason:  value.attribute('deprecation_reason') or { panic(err) }
		disable_reason:      value.attribute('disable_reason') or { panic(err) }
		disable_date:        value.attribute('disable_date') or { panic(err) }
		deprecation_date:    value.attribute('deprecation_date') or { panic(err) }
		deprecation_formula: value.attribute('deprecation_formula') or { panic(err) }
		deprecation_cask:    value.attribute('deprecation_cask') or { panic(err) }
		disable_formula:     value.attribute('disable_formula') or { panic(err) }
		disable_cask:        value.attribute('disable_cask') or { panic(err) }
	}
}

// Ruby method `type(formula_or_cask)` at line 40.
pub fn ruby_deprecate_disable_l40_d1_type(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('DeprecateDisable.type requires a formula or cask')
	}
	type_name := deprecate_disable_type(deprecate_disable_subject_from_value(args[0]))
	return if type_name == '' {
		brew_runtime.object_value('NilClass', '')
	} else {
		brew_runtime.object_value('Symbol', type_name)
	}
}

// Ruby method `replacement_with_type(formula, cask)` at line 52.
pub fn ruby_deprecate_disable_l52_d2_replacement_with_type(args ...brew_runtime.Value) brew_runtime.Value {
	formula := if args.len > 0 && args[0].type_name != 'NilClass' { args[0].as_string() } else { '' }
	cask := if args.len > 1 && args[1].type_name != 'NilClass' { args[1].as_string() } else { '' }
	replacement := deprecate_disable_replacement_with_type(formula, cask)
	return if replacement == '' {
		brew_runtime.object_value('NilClass', '')
	} else {
		brew_runtime.string_value(replacement)
	}
}

// Ruby method `message(formula_or_cask)` at line 63.
pub fn ruby_deprecate_disable_l63_d3_message(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('DeprecateDisable.message requires a formula or cask')
	}
	message := deprecate_disable_message(deprecate_disable_subject_from_value(args[0]),
		brew_runtime.today_iso()) or { return brew_runtime.object_value('NilClass', '') }
	return brew_runtime.string_value(message)
}

// Ruby method `to_reason_string_or_symbol(string, type:)` at line 122.
pub fn ruby_deprecate_disable_l122_d4_to_reason_string_or_symbol(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return brew_runtime.object_value('NilClass', '')
	}
	kind := if args.len > 1 && args[1].as_string().trim_left(':') == 'cask' {
		DeprecateDisablePackageKind.cask
	} else {
		DeprecateDisablePackageKind.formula
	}
	reason := deprecate_disable_reason_from_string(args[0].as_string(), kind) or {
		return brew_runtime.object_value('NilClass', '')
	}
	return if reason.is_symbol {
		brew_runtime.object_value('Symbol', reason.value)
	} else {
		brew_runtime.string_value(reason.value)
	}
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # Helper module for handling `disable!` and `deprecate!`.
// 5: # @api internal
// 6: module DeprecateDisable
// 7:   module_function
// 8:
// 9:   FORMULA_DEPRECATE_DISABLE_REASONS = T.let({
// 10:     does_not_build:      "does not build",
// 11:     no_license:          "has no license",
// 12:     repo_archived:       "has an archived upstream repository",
// 13:     repo_removed:        "has a removed upstream repository",
// 14:     unmaintained:        "is not maintained upstream",
// 15:     unreachable:         "is no longer reliably reachable upstream",
// 16:     unsupported:         "is not supported upstream",
// 17:     deprecated_upstream: "is deprecated upstream",
// 18:     versioned_formula:   "is a versioned formula",
// 19:     checksum_mismatch:   "was built with an initially released source file that had " \
// 20:                          "a different checksum than the current one. " \
// 21:                          "Upstream's repository might have been compromised. " \
// 22:                          "We can re-package this once upstream has confirmed that they retagged their release",
// 23:   }.freeze, T::Hash[Symbol, String])
// 24:
// 25:   CASK_DEPRECATE_DISABLE_REASONS = T.let({
// 26:     discontinued:             "is discontinued upstream",
// 27:     moved_to_mas:             "is now exclusively distributed on the Mac App Store",
// 28:     no_longer_available:      "is no longer available upstream",
// 29:     no_longer_meets_criteria: "no longer meets the criteria for acceptable casks",
// 30:     unmaintained:             "is not maintained upstream",
// 31:     fails_gatekeeper_check:   "does not pass the macOS Gatekeeper check",
// 32:     unreachable:              "is no longer reliably reachable upstream",
// 33:   }.freeze, T::Hash[Symbol, String])
// 34:
// 35:   # One year when << or >> to Date.today.
// 36:   REMOVE_DISABLED_TIME_WINDOW = 12
// 37:   REMOVE_DISABLED_BEFORE = T.let((Date.today << REMOVE_DISABLED_TIME_WINDOW).freeze, Date)
// 38:
// 39:   sig { params(formula_or_cask: T.any(Formula, Cask::Cask)).returns(T.nilable(Symbol)) }
// 40:   def type(formula_or_cask)
// 41:     return :deprecated if formula_or_cask.deprecated?
// 42:
// 43:     :disabled if formula_or_cask.disabled?
// 44:   end
// 45:
// 46:   sig {
// 47:     params(
// 48:       formula: T.nilable(String),
// 49:       cask:    T.nilable(String),
// 50:     ).returns(T.nilable(String))
// 51:   }
// 52:   def replacement_with_type(formula, cask)
// 53:     if formula && formula == cask
// 54:       formula
// 55:     elsif formula
// 56:       "--formula #{formula}"
// 57:     elsif cask
// 58:       "--cask #{cask}"
// 59:     end
// 60:   end
// 61:
// 62:   sig { params(formula_or_cask: T.any(Formula, Cask::Cask)).returns(T.nilable(String)) }
// 63:   def message(formula_or_cask)
// 64:     return if type(formula_or_cask).blank?
// 65:
// 66:     reason = if formula_or_cask.deprecated?
// 67:       formula_or_cask.deprecation_reason
// 68:     elsif formula_or_cask.disabled?
// 69:       formula_or_cask.disable_reason
// 70:     end
// 71:
// 72:     reason = if formula_or_cask.is_a?(Formula) && FORMULA_DEPRECATE_DISABLE_REASONS.key?(reason)
// 73:       FORMULA_DEPRECATE_DISABLE_REASONS[reason]
// 74:     elsif formula_or_cask.is_a?(Cask::Cask) && CASK_DEPRECATE_DISABLE_REASONS.key?(reason)
// 75:       CASK_DEPRECATE_DISABLE_REASONS[reason]
// 76:     else
// 77:       reason
// 78:     end
// 79:
// 80:     message = if reason.present?
// 81:       "#{type(formula_or_cask)} because it #{reason}!"
// 82:     else
// 83:       "#{type(formula_or_cask)}!"
// 84:     end
// 85:
// 86:     disable_date = formula_or_cask.disable_date
// 87:     if !disable_date && formula_or_cask.deprecation_date
// 88:       disable_date = formula_or_cask.deprecation_date >> REMOVE_DISABLED_TIME_WINDOW
// 89:     end
// 90:     if disable_date
// 91:       message += if disable_date < Date.today
// 92:         " It was disabled on #{disable_date}."
// 93:       else
// 94:         " It will be disabled on #{disable_date}."
// 95:       end
// 96:     end
// 97:
// 98:     replacement = if formula_or_cask.disabled?
// 99:       replacement_with_type(
// 100:         formula_or_cask.disable_replacement_formula,
// 101:         formula_or_cask.disable_replacement_cask,
// 102:       )
// 103:     elsif formula_or_cask.deprecated?
// 104:       replacement_with_type(
// 105:         formula_or_cask.deprecation_replacement_formula,
// 106:         formula_or_cask.deprecation_replacement_cask,
// 107:       )
// 108:     end
// 109:
// 110:     if replacement.present?
// 111:       message << "\n"
// 112:       message << <<~EOS
// 113:         Replacement:
// 114:           brew install #{replacement}
// 115:       EOS
// 116:     end
// 117:
// 118:     message
// 119:   end
// 120:
// 121:   sig { params(string: T.nilable(String), type: Symbol).returns(T.nilable(T.any(String, Symbol))) }
// 122:   def to_reason_string_or_symbol(string, type:)
// 123:     return if string.nil?
// 124:
// 125:     if (type == :formula && FORMULA_DEPRECATE_DISABLE_REASONS.key?(string.to_sym)) ||
// 126:        (type == :cask && CASK_DEPRECATE_DISABLE_REASONS.key?(string.to_sym))
// 127:       return string.to_sym
// 128:     end
// 129:
// 130:     string
// 131:   end
// 132: end
