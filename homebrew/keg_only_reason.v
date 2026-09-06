module homebrew

// Translated from Homebrew/brew `keg_only_reason.rb`.

// KegOnlyReason describes why a formula must not be linked into the shared
// prefix. Ruby accepts either a Symbol or String, so the V value records that
// distinction for the source-compatible hash representation.
pub struct KegOnlyReason {
pub:
	reason        string
	explanation   string
	reason_symbol bool
}

// new_keg_only_reason translates the usual Symbol form used by formula DSLs.
pub fn new_keg_only_reason(reason string, explanation string) KegOnlyReason {
	return KegOnlyReason{
		reason: reason.trim_left(':')
		explanation: explanation
		reason_symbol: true
	}
}

// new_keg_only_reason_string translates the less common String form.
pub fn new_keg_only_reason_string(reason string, explanation string) KegOnlyReason {
	return KegOnlyReason{
		reason: reason
		explanation: explanation
	}
}

pub fn (reason KegOnlyReason) versioned_formula() bool {
	return reason.reason == 'versioned_formula'
}

pub fn (reason KegOnlyReason) provided_by_macos() bool {
	return reason.reason == 'provided_by_macos'
}

pub fn (reason KegOnlyReason) shadowed_by_macos() bool {
	return reason.reason == 'shadowed_by_macos'
}

pub fn (reason KegOnlyReason) by_macos() bool {
	return reason.provided_by_macos() || reason.shadowed_by_macos()
}

// applicable translates the non-macOS base implementation. The macOS override
// remains a separate OS-specific translation boundary.
pub fn (reason KegOnlyReason) applicable() bool {
	return !reason.by_macos()
}

pub fn (reason KegOnlyReason) str() string {
	if reason.explanation != '' {
		return reason.explanation
	}
	if reason.versioned_formula() {
		return 'this is an alternate version of another formula\n'
	}
	if reason.provided_by_macos() {
		return 'macOS already provides this software and installing another version in\nparallel can cause all kinds of trouble\n'
	}
	if reason.shadowed_by_macos() {
		return 'macOS provides similar software and installing this software in\nparallel can cause all kinds of trouble\n'
	}
	return reason.reason.trim_space()
}

pub fn (reason KegOnlyReason) to_hash() map[string]string {
	return {
		'reason':      if reason.reason_symbol {
			':${reason.reason}'
		} else {
			reason.reason
		}
		'explanation': reason.explanation
	}
}
