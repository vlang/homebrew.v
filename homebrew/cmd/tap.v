module cmd

// Translated from Homebrew/brew `cmd/tap.rb`.
pub struct TapCommandTap {
pub:
	name      string
	installed bool
}

pub struct TapCommandRequest {
pub:
	named         []string
	installed     []TapCommandTap
	repair        bool
	custom_remote bool
	quiet         bool
	verify        bool
	force         bool
}

pub struct TapCommandResult {
pub:
	listed         []string
	repaired       []string
	installed      ?string
	clone_target   ?string
	custom_remote  bool
	quiet          bool
	verify         bool
	force          bool
	already_tapped bool
	output         string
}

pub fn run_tap_command(request TapCommandRequest) !TapCommandResult {
	if request.repair {
		mut repaired := request.installed.map(it.name)
		repaired.sort()
		return TapCommandResult{
			repaired: repaired
		}
	}
	if request.named.len == 0 {
		mut listed := request.installed.map(it.name)
		listed.sort()
		return TapCommandResult{
			listed: listed
			output: if listed.len > 0 { listed.join('\n') + '\n' } else { '' }
		}
	}
	name := request.named[0]
	parts := name.split('/')
	if parts.len != 2 || parts.any(it == '') {
		return error('Invalid tap name `${name}`')
	}
	mut clone_target := ?string(none)
	if request.named.len > 1 && request.named[1] != '' {
		clone_target = request.named[1]
	}
	already_tapped := request.installed.any(it.name == name && it.installed)
	return TapCommandResult{
		installed: if already_tapped { none } else { name }
		clone_target: clone_target
		custom_remote: request.custom_remote
		quiet: request.quiet
		verify: request.verify
		force: request.force
		already_tapped: already_tapped
		output: if already_tapped { '' } else { 'Tapped ${name}\n' }
	}
}
