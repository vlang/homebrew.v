module tap

import os

// Translated from Homebrew/brew `tap/abstract_core_tap.rb`.
pub enum AbstractCoreTapKind {
	core
	cask
}

pub struct AbstractCoreTap {
pub:
	kind AbstractCoreTapKind
}

pub fn abstract_core_tap_instance(kind AbstractCoreTapKind) AbstractCoreTap {
	return AbstractCoreTap{ kind: kind }
}

pub fn abstract_core_tap_should_install(no_install_from_api bool,
	automatically_set_no_install_from_api bool, installed bool) bool {
	return no_install_from_api && !automatically_set_no_install_from_api && !installed
}

pub fn abstract_core_tap_implicitly_trusted(no_install_from_api bool,
	base_implicitly_trusted bool) bool {
	return !no_install_from_api || base_implicitly_trusted
}

pub fn abstract_core_tap_formula_file_to_name(file string) string {
	return os.base(file).trim_string_right('.rb')
}

pub fn abstract_core_tap_should_report_analytics(no_install_from_api bool,
	base_value bool) bool {
	return if no_install_from_api { base_value } else { true }
}
