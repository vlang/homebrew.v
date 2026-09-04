module homebrew

// Translated from Homebrew/brew `messages.rb`.

pub struct CaveatMessage {
pub:
	package string
	caveats string
}

pub struct InstallTime {
pub:
	package string
	time    f64
}

// Messages is the typed V translation of Ruby's mutable end-of-command message
// collector. The ordered array plus membership check preserves Set insertion
// order for completions without introducing a second collection type.
pub struct Messages {
pub mut:
	caveats               []CaveatMessage
	completions_and_elisp []string
	package_count         int
	install_times         []InstallTime
}

pub fn new_messages() Messages {
	return Messages{}
}

pub fn (messages Messages) copy() Messages {
	return Messages{
		caveats: messages.caveats.clone()
		completions_and_elisp: messages.completions_and_elisp.clone()
		package_count: messages.package_count
		install_times: messages.install_times.clone()
	}
}

pub fn (mut messages Messages) record_caveats(package string, caveats string) {
	messages.caveats << CaveatMessage{
		package: package
		caveats: caveats
	}
}

pub fn (mut messages Messages) record_completions_and_elisp(completions []string) {
	for completion in completions {
		if completion !in messages.completions_and_elisp {
			messages.completions_and_elisp << completion
		}
	}
}

pub fn (mut messages Messages) package_installed(package string, elapsed_time f64) {
	messages.package_count++
	messages.install_times << InstallTime{
		package: package
		time: elapsed_time
	}
}

pub fn (messages Messages) display_messages(force_caveats bool, display_times bool) string {
	mut sections := []string{}
	caveats := messages.display_caveats(force_caveats)
	if caveats != '' {
		sections << caveats
	}
	if display_times {
		times := messages.display_install_times()
		if times != '' {
			sections << times
		}
	}
	return sections.join('\n')
}

pub fn (messages Messages) display_caveats(force bool) string {
	if messages.package_count == 0
		|| (messages.caveats.len == 0 && messages.completions_and_elisp.len == 0) {
		return ''
	}
	mut lines := []string{}
	if messages.completions_and_elisp.len > 0 {
		lines << '==> Caveats'
		lines << messages.completions_and_elisp
	}
	if messages.package_count == 1 && !force {
		return lines.join('\n')
	}
	if messages.completions_and_elisp.len == 0 {
		lines << '==> Caveats'
	}
	for caveat in messages.caveats {
		lines << '==> ${caveat.package}'
		lines << caveat.caveats
	}
	return lines.join('\n')
}

pub fn (messages Messages) display_install_times() string {
	if messages.install_times.len == 0 {
		return ''
	}
	mut lines := ['==> Installation times']
	for install_time in messages.install_times {
		padding := if install_time.package.len < 20 {
			' '.repeat(20 - install_time.package.len)
		} else {
			''
		}
		lines << '${install_time.package}${padding} ${install_time.time:10.3f} s'
	}
	return lines.join('\n')
}
