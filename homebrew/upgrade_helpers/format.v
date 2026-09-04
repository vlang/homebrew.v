module upgrade_helpers

fn right_pad(value string, width int) string {
	if value.len >= width {
		return value
	}
	return value + ' '.repeat(width - value.len)
}

// format_summary is the shared implementation behind Homebrew::Upgrade.format_upgrade_summary.
pub fn format_summary(upgrades []string) []string {
	if upgrades.len < 2 {
		return upgrades.clone()
	}
	mut name_width := 0
	mut old_version_width := 0
	for upgrade in upgrades {
		parts := upgrade.split_nth(' ', 2)
		if parts[0].len > name_width {
			name_width = parts[0].len
		}
		if parts.len > 1 && parts[1].contains(' -> ') {
			old_version := parts[1].all_before(' -> ')
			if old_version.len > old_version_width {
				old_version_width = old_version.len
			}
		}
	}
	mut result := []string{cap: upgrades.len}
	for upgrade in upgrades {
		parts := upgrade.split_nth(' ', 2)
		name := parts[0]
		if parts.len == 1 || parts[1] == '' {
			result << name
			continue
		}
		versions := parts[1]
		if versions.contains(' -> ') {
			old_version := versions.all_before(' -> ')
			updated_version := versions.all_after(' -> ')
			result << '${right_pad(name, name_width)}  ${right_pad(old_version, old_version_width)} -> ${updated_version}'
		} else {
			result << '${right_pad(name, name_width)}  ${versions}'
		}
	}
	return result
}
