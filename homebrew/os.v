module homebrew

import ruby

// Translated from Homebrew/brew `os.rb`.

pub struct OsContext {
pub:
	repository    string
	prefix        string
	bundle_file   string
	update_before string
	update_after  string
	arguments     []string
	generic_os    bool
}

pub fn current_os_context() OsContext {
	return OsContext{
		repository: ruby.environment_value('HOMEBREW_REPOSITORY')
		prefix: ruby.environment_value('HOMEBREW_PREFIX')
		bundle_file: ruby.environment_value('HOMEBREW_BUNDLE_FILE')
		update_before: ruby.environment_value('HOMEBREW_UPDATE_BEFORE')
		update_after: ruby.environment_value('HOMEBREW_UPDATE_AFTER')
		arguments: ruby.process_arguments()
		generic_os: ruby.environment_value('HOMEBREW_TEST_GENERIC_OS') != ''
	}
}

pub fn os_is_macos(context OsContext) bool {
	if context.generic_os {
		return false
	}
	$if macos {
		return true
	} $else {
		return false
	}
}

pub fn os_is_linux(context OsContext) bool {
	if context.generic_os {
		return false
	}
	$if linux {
		return true
	} $else {
		return false
	}
}

pub fn os_kernel_version() !Version {
	return new_version(ruby.kernel_info().release)
}

pub fn os_kernel_name() string {
	return ruby.kernel_info().name
}

pub fn os_is_wsl(context OsContext) bool {
	if context.generic_os {
		return false
	}
	return ruby.kernel_info().release.to_lower().contains('-microsoft')
}

fn path_basename(path string) string {
	trimmed := path.trim_right('/')
	return trimmed.all_after_last('/')
}

pub fn os_is_nix_homebrew(context OsContext) bool {
	return path_basename(context.repository) == '.homebrew-is-managed-by-nix'
		|| ruby.path_exists(ruby.join_path(context.prefix, '.managed_by_nix_darwin'))
		|| (context.update_before == 'nix' && context.update_after == 'nix')
}

pub fn os_is_nix_darwin(context OsContext) bool {
	if context.bundle_file.starts_with('/nix/store/') {
		return true
	}
	for index, argument in context.arguments {
		if argument.starts_with('--file=/nix/store/') {
			return true
		}
		if argument == '--file' && index + 1 < context.arguments.len
			&& context.arguments[index + 1].starts_with('/nix/store/') {
			return true
		}
	}
	return false
}

pub fn os_is_nix_managed_homebrew(context OsContext) bool {
	return os_is_nix_homebrew(context) || os_is_nix_darwin(context)
}

pub fn os_nix_managed_homebrew_issues_url(context OsContext) string {
	return if os_is_nix_homebrew(context) {
		'https://github.com/zhaofengli/nix-homebrew/issues'
	} else {
		'https://github.com/nix-darwin/nix-darwin/issues'
	}
}

// The base translation defines an issues URL for supported Linux and macOS
// configurations. Detailed macOS release/hardware exclusions are translated in
// the OS::Mac and Hardware units.
pub fn os_not_tier_one_configuration(context OsContext) bool {
	if os_is_nix_managed_homebrew(context) || os_is_linux(context) {
		return false
	}
	return !os_is_macos(context)
}
