module cmd

// Translated from Homebrew/brew `cmd/desc.rb`.
pub enum DescSearchField {
	name
	description
	either
}

pub enum DescItemKind {
	formula
	cask
}

pub struct DescItem {
pub:
	kind        DescItemKind
	full_name   string
	names       []string
	description ?string
	installed   bool
}

pub struct DescCommandRequest {
pub:
	named                []string
	items                []DescItem
	search               bool
	name_only            bool
	description_only     bool
	eval_all             bool
	no_install_from_api  bool
	tap_trust_configured bool
	tty                  bool
}

pub struct DescCommandResult {
pub:
	output       string
	searched     bool
	search_query string
	search_field DescSearchField
}

pub fn run_desc_command(request DescCommandRequest) !DescCommandResult {
	mut search_field := DescSearchField.either
	searching := request.search || request.name_only || request.description_only
	if request.name_only {
		search_field = .name
	} else if request.description_only {
		search_field = .description
	}
	if searching {
		if !request.eval_all && !request.tap_trust_configured && request.no_install_from_api {
			return error('`brew desc --search` needs `HOMEBREW_REQUIRE_TAP_TRUST=1` or `HOMEBREW_NO_REQUIRE_TAP_TRUST=1` set!')
		}
		return DescCommandResult{
			searched: true
			search_query: request.named.join(' ')
			search_field: search_field
		}
	}
	mut lines := []string{}
	for item in request.items {
		description := item.description or { continue }
		if description == '' {
			continue
		}
		match item.kind {
			.formula {
				lines << '${item.full_name}: ${description}'
			}
			.cask {
				status := if request.tty && item.installed { ' ✔' } else { '' }
				names := if item.names.len > 0 { ' (${item.names.join(', ')})' } else { '' }
				lines << '${item.full_name}${status}:${names} ${description}'
			}
		}
	}
	lines.sort()
	return DescCommandResult{
		output: if lines.len > 0 { lines.join('\n') + '\n' } else { '' }
		search_field: search_field
	}
}
