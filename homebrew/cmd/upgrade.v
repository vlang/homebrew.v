module cmd

pub struct UpgradeCmdFormula {
pub:
	name                     string
	full_name                string
	full_specified_name      string
	pkg_version              string
	old_version              string
	installed_versions       []string
	latest_head_pkg_version  string
	outdated                 bool
	pinned                   bool
	deprecated               bool
	disabled                 bool
	core_formula             bool
	pour_bottle              bool
	optlinked                bool
	head                     bool
	latest_version_installed bool
	build_from_source        bool
	has_bottle               bool
	bottle_size              i64
}

pub struct UpgradeCmdCask {
pub:
	token                     string
	full_name                 string
	installed_version         string
	version                   string
	outdated                  bool
	pinned                    bool
	deprecated                bool
	disabled                  bool
	manual_installer          bool
	requirements_error        string
	source_download_prefetch  bool
	source_download_available bool
}

pub struct UpgradeCmdInstaller {
pub:
	formula     UpgradeCmdFormula
	valid       bool = true
	upgraded    bool = true
	pour_bottle bool = true
}

pub struct UpgradeCmdDependents {
pub:
	upgradeable []UpgradeCmdFormula
	pinned      []UpgradeCmdFormula
	skipped     []UpgradeCmdFormula
}

pub struct UpgradeCmdFormulaeContext {
pub:
	formulae_to_install []UpgradeCmdFormula
	formulae_installer  []UpgradeCmdInstaller
	dependants          UpgradeCmdDependents
	pinned_formulae     []UpgradeCmdFormula
}

pub struct UpgradeCmdFinalSummary {
pub:
	version_changes       []string
	pinned_formulae       []string
	pinned_casks          []string
	deprecated            []string
	disabled              []string
	source_build_formulae []string
}

fn upgrade_cmd_unique(values []string) []string {
	mut seen := map[string]bool{}
	mut result := []string{}
	for value in values {
		if seen[value] or { false } {
			continue
		}
		seen[value] = true
		result << value
	}
	return result
}

fn upgrade_cmd_compare_version(left string, right string) int {
	left_parts := left.trim_left('v').split_any('.-_')
	right_parts := right.trim_left('v').split_any('.-_')
	maximum := if left_parts.len > right_parts.len { left_parts.len } else { right_parts.len }
	for index in 0 .. maximum {
		left_part := if index < left_parts.len { left_parts[index] } else { '0' }
		right_part := if index < right_parts.len { right_parts[index] } else { '0' }
		if left_part.int() != right_part.int() {
			return if left_part.int() < right_part.int() { -1 } else { 1 }
		}
		if left_part != right_part && (left_part.int() == 0 || right_part.int() == 0) {
			return if left_part < right_part { -1 } else { 1 }
		}
	}
	return 0
}

fn upgrade_cmd_disk_size(size i64) string {
	if size < 1000 {
		return '${size}B'
	}
	if size < 1_000_000 {
		return '${size / 1000}KB'
	}
	if size < 1_000_000_000 {
		return '${size / 1_000_000}MB'
	}
	return '${size / 1_000_000_000}GB'
}

// Translated from Homebrew/brew `cmd/upgrade.rb`.
