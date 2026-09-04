module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/version.rb`.
pub struct VersionAuditOffense {
pub:
	begin_pos int
	end_pos   int
	version   string
	message   string
}

fn version_string_node(source string) ?VersionAuditOffense {
	mut offset := 0
	for line in source.split_into_lines() {
		trimmed := line.trim_space()
		if trimmed.starts_with('version ') {
			indent := line.index('version') or { 0 }
			remainder := trimmed['version '.len..].trim_space()
			if remainder.len >= 2 && remainder[0] in [`'`, `"`] && remainder[remainder.len - 1] == remainder[0] {
				return VersionAuditOffense{
					begin_pos: offset + indent
					end_pos: offset + line.len
					version: remainder[1..remainder.len - 1]
				}
			}
		}
		offset += line.len + 1
	}
	return none
}

pub fn audit_formula_version(source string) []VersionAuditOffense {
	node := version_string_node(source) or { return [] }
	mut offenses := []VersionAuditOffense{}
	if node.version == '' {
		offenses << VersionAuditOffense{
			...node
			message: 'Version is set to an empty string'
		}
	}
	if node.version.starts_with('v') {
		offenses << VersionAuditOffense{
			...node
			message: "Version ${node.version} should not have a leading 'v'"
		}
	}
	underscore := node.version.last_index('_') or { -1 }
	if underscore >= 0 && underscore + 1 < node.version.len && node.version[underscore + 1..].bytes().all(it.is_digit()) {
		offenses << VersionAuditOffense{
			...node
			message: 'Version ${node.version} should not end with an underline and a number'
		}
	}
	return offenses
}
