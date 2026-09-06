module diagnostic

import ruby

pub struct Remediation {
pub mut:
	text string
pub:
	commands []string
}

pub fn new_remediation(commands []string, text string) &Remediation {
	return &Remediation{
		commands: commands.clone()
		text: text
	}
}

pub fn (remediation Remediation) string() string {
	if remediation.commands.len == 0 && remediation.text == '' {
		return ''
	}
	if remediation.text != '' {
		return remediation.text
	}
	return 'You can solve this by running:\n  ${remediation.commands.join('\n  ')}'
}

pub fn (remediation Remediation) to_value() ruby.Value {
	return ruby.map_value({
		'commands': ruby.string_array_value(remediation.commands)
		'text':     ruby.string_value(remediation.text)
	})
}

pub struct Finding {
pub:
	text        string
	tier        string = '1'
	affects     []string
	links       []string
	remediation ?Remediation
}

pub fn new_finding(text string, tier string, affects []string, links []string,
	remediation ?Remediation) Finding {
	return Finding{
		text: text
		tier: if tier == '' { '1' } else { tier }
		affects: affects.clone()
		links: links.clone()
		remediation: remediation
	}
}

pub fn (finding Finding) to_value() ruby.Value {
	remediation := if value := finding.remediation {
		value.to_value()
	} else {
		ruby.object_value('NilClass', 'nil')
	}
	return ruby.map_value({
		'text':        ruby.string_value(finding.text)
		'tier':        ruby.string_value(finding.tier)
		'affects':     ruby.string_array_value(finding.affects)
		'links':       ruby.string_array_value(finding.links)
		'remediation': remediation
	})
}

pub fn (finding Finding) string() string {
	remediation := if value := finding.remediation { value.string().trim_space() } else { '' }
	return '${finding.text}\n${remediation}'.trim_right('\n')
}

pub fn support_tier_message(tier string, nix_managed bool, issues_url string) string {
	if tier == '1' {
		return ''
	}
	mut title := 'Tier ${tier}'
	mut slug := 'tier-${tier.to_lower()}'
	mut issue_text := 'You can report issues with Tier ${tier} configurations'
	if tier == 'unsupported' {
		title = 'Unsupported'
		slug = 'unsupported'
		issue_text = 'Do not report any issues'
	}
	if nix_managed {
		issue_text = 'Report issues to the upstream Nix project, not'
	}
	mut message := 'This is a ${title} configuration:\n  https://docs.brew.sh/Support-Tiers#${slug}\n${issue_text} to Homebrew/* repositories!'
	if issues_url != '' {
		message += '\n  ${issues_url}'
	}
	return '${message}\nRead the above document before opening any issues or PRs.\n'
}

fn finding_value(finding Finding) ruby.Value {
	mut attributes := {
		'text':    finding.text
		'tier':    finding.tier
		'affects': finding.affects.join('\n')
		'links':   finding.links.join('\n')
	}
	if remediation := finding.remediation {
		attributes['remediation_text'] = remediation.text
		attributes['remediation_commands'] = remediation.commands.join('\n')
	}
	return ruby.structured_value('Homebrew::Diagnostic::Finding', finding.string(), attributes)
}

// Translated from Homebrew/brew `diagnostic/finding.rb`.
