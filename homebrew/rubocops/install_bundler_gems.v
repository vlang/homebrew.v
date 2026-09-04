module rubocops

import ruby

// Translated from Homebrew/brew `rubocops/install_bundler_gems.rb`.
pub const install_bundler_gems_message = 'Only use `Homebrew.install_bundler_gems!` in dev-cmd.'

pub struct InstallBundlerGemsOffense {
pub:
	begin_pos int
	end_pos   int
	message   string
}

fn install_bundler_gems_allowed_path(file_path string) bool {
	if file_path.ends_with('/standalone/init.rb') || file_path.ends_with('/startup/bootsnap.rb') {
		return true
	}
	marker := '/dev-cmd/'
	index := file_path.last_index(marker) or { return false }
	return file_path.ends_with('.rb') && index + marker.len < file_path.len - '.rb'.len
}

pub fn audit_install_bundler_gems(source string, file_path string) ?InstallBundlerGemsOffense {
	if install_bundler_gems_allowed_path(file_path) {
		return none
	}
	call := 'Homebrew.install_bundler_gems!'
	begin_pos := source.index(call) or { return none }
	return InstallBundlerGemsOffense{
		begin_pos: begin_pos
		end_pos: begin_pos + call.len
		message: install_bundler_gems_message
	}
}
