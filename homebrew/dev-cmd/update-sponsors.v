module dev_cmd

import ruby
import os

// Translated from Homebrew/brew `dev-cmd/update-sponsors.rb`.

pub const named_sponsor_monthly_amount = 100
pub const logo_sponsor_monthly_amount = 1000

pub struct UpdateSponsorsSponsorship {
pub:
	name                        string
	login                       string
	monthly_amount              int
	closest_tier_monthly_amount int
}

pub struct UpdateSponsorsOptions {
pub:
	repository   string
	sponsorships []UpdateSponsorsSponsorship
	diff_success bool
}

pub struct UpdateSponsorsResult {
pub:
	named_sponsors         []string
	logo_sponsors          []string
	largest_monthly_amount int
	readme_path            string
	content                string
	diff_command           []string
	stdout                 string
	stderr                 string
	failed                 bool
}

@[heap]
pub struct UpdateSponsorsInput {
pub:
	options UpdateSponsorsOptions
}

pub fn update_sponsor_name(sponsor UpdateSponsorsSponsorship) string {
	if sponsor.name != '' {
		return sponsor.name
	}
	return sponsor.login
}

pub fn update_sponsor_logo(sponsor UpdateSponsorsSponsorship) string {
	return 'https://github.com/${sponsor.login}.png?size=64'
}

pub fn update_sponsor_url(sponsor UpdateSponsorsSponsorship) string {
	return 'https://github.com/${sponsor.login}'
}

fn update_sponsors_to_sentence(values []string) string {
	return match values.len {
		0 { '' }
		1 { values[0] }
		2 { '${values[0]} and ${values[1]}' }
		else { '${values[..values.len - 1].join(', ')} and ${values.last()}' }
	}
}

fn update_sponsors_readme(content string, named_sponsors []string, logo_sponsors []string) string {
	marker := 'Homebrew is generously supported by'
	mut updated := content
	if marker_index := content.index(marker) {
		updated = content[..marker_index] + marker + ' ' + update_sponsors_to_sentence(named_sponsors) + '.\n'
	}
	if logo_sponsors.len > 0 {
		updated += '\n${logo_sponsors.join('')}\n'
	}
	return updated
}

pub fn run_update_sponsors(options UpdateSponsorsOptions) !UpdateSponsorsResult {
	mut named_sponsors := []string{}
	mut logo_sponsors := []string{}
	mut largest_monthly_amount := 0
	for sponsor in options.sponsorships {
		largest_monthly_amount = if sponsor.monthly_amount > sponsor.closest_tier_monthly_amount {
			sponsor.monthly_amount
		} else {
			sponsor.closest_tier_monthly_amount
		}
		if largest_monthly_amount >= named_sponsor_monthly_amount {
			named_sponsors << '[${update_sponsor_name(sponsor)}](${update_sponsor_url(sponsor)})'
		}
		if largest_monthly_amount >= logo_sponsor_monthly_amount {
			logo_sponsors << '[![${update_sponsor_name(sponsor)}](${update_sponsor_logo(sponsor)})](${update_sponsor_url(sponsor)})'
		}
	}
	if largest_monthly_amount == 0 {
		return error('No sponsorships amounts found! Ensure you have sufficient permissions!')
	}

	named_sponsors << 'many other users and organisations via [GitHub Sponsors](https://github.com/sponsors/Homebrew)'
	readme_path := os.join_path(options.repository, 'README.md')
	content := os.read_file(readme_path)!
	updated := update_sponsors_readme(content, named_sponsors, logo_sponsors)
	os.write_file(readme_path, updated)!
	diff_command := ['git', '-C', options.repository, 'diff', '--exit-code', 'README.md']
	if options.diff_success {
		return UpdateSponsorsResult{
			named_sponsors: named_sponsors
			logo_sponsors: logo_sponsors
			largest_monthly_amount: largest_monthly_amount
			readme_path: readme_path
			content: updated
			diff_command: diff_command
			stderr: 'No changes to list of sponsors.\n'
			failed: true
		}
	}
	return UpdateSponsorsResult{
		named_sponsors: named_sponsors
		logo_sponsors: logo_sponsors
		largest_monthly_amount: largest_monthly_amount
		readme_path: readme_path
		content: updated
		diff_command: diff_command
		stdout: 'List of sponsors updated in the README.\n'
	}
}

pub fn update_sponsors_input_boundary(input &UpdateSponsorsInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::UpdateSponsors::Input', '', {
		'update_sponsors_input_address': u64(voidptr(input)).str()
	})
}

fn update_sponsors_input_from_value(value ruby.Value) !&UpdateSponsorsInput {
	address := value.attributes['update_sponsors_input_address'] or {
		return error('invalid UpdateSponsors input')
	}
	return unsafe { &UpdateSponsorsInput(voidptr(address.u64())) }
}

fn update_sponsor_from_value(value ruby.Value) !UpdateSponsorsSponsorship {
	sponsor := value.as_map() or { return error('sponsor must be a Hash') }
	login_value := sponsor['login'] or { return error('sponsor login is required') }
	name := if name_value := sponsor['name'] {
		if name_value.type_name == 'NilClass' { '' } else { name_value.as_string() }
	} else {
		''
	}
	monthly_amount := if value_ := sponsor['monthly_amount'] {
		int(value_.as_int() or { return error('monthly_amount must be an Integer') })
	} else {
		0
	}
	closest_tier_monthly_amount := if value_ := sponsor['closest_tier_monthly_amount'] {
		int(value_.as_int() or { return error('closest_tier_monthly_amount must be an Integer') })
	} else {
		0
	}
	return UpdateSponsorsSponsorship{
		name: name
		login: login_value.as_string()
		monthly_amount: monthly_amount
		closest_tier_monthly_amount: closest_tier_monthly_amount
	}
}

fn update_sponsors_result_value(result UpdateSponsorsResult) ruby.Value {
	return ruby.map_value({
		'named_sponsors':         ruby.string_array_value(result.named_sponsors)
		'logo_sponsors':          ruby.string_array_value(result.logo_sponsors)
		'largest_monthly_amount': ruby.int_value(result.largest_monthly_amount)
		'readme_path':            ruby.string_value(result.readme_path)
		'content':                ruby.string_value(result.content)
		'diff_command':           ruby.string_array_value(result.diff_command)
		'stdout':                 ruby.string_value(result.stdout)
		'stderr':                 ruby.string_value(result.stderr)
		'failed':                 ruby.bool_value(result.failed)
	})
}
