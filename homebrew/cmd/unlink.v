module cmd

// Translated from Homebrew/brew `cmd/unlink.rb`.
pub struct UnlinkCommandKeg {
pub:
	name string
	path string
}

pub struct UnlinkCommandOptions {
pub:
	dry_run bool
	verbose bool
}

pub struct UnlinkCommandResult {
pub:
	output string
	counts []int
}

pub type UnlinkCommandAction = fn (UnlinkCommandKeg, UnlinkCommandOptions) !int

pub fn unlink_command(kegs []UnlinkCommandKeg, options UnlinkCommandOptions,
	action UnlinkCommandAction) !UnlinkCommandResult {
	mut lines := []string{}
	mut counts := []int{}
	for keg in kegs {
		if options.dry_run {
			lines << 'Would remove:'
		}
		count := action(keg, options)!
		counts << count
		if !options.dry_run {
			mut message := 'Unlinking ${keg.path}... '
			if options.verbose {
				message += '\n'
			}
			lines << message + '${count} symlinks removed.'
		}
	}
	return UnlinkCommandResult{
		output: if lines.len == 0 { '' } else { lines.join('\n') + '\n' }
		counts: counts
	}
}

fn unlink_command_count(keg UnlinkCommandKeg, _ UnlinkCommandOptions) !int {
	return if keg.name == '' { 0 } else { 1 }
}
