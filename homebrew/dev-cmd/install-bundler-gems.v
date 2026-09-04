module dev_cmd

import ruby

// Translated from Homebrew/brew `dev-cmd/install-bundler-gems.rb`.
pub struct InstallBundlerGemsOptions {
pub:
	groups          []string
	groups_provided bool
	add_groups      []string
	valid_groups    []string
}

pub struct InstallBundlerGemsPlan {
pub:
	groups                 []string
	forget_user_gem_groups bool
}

pub fn install_bundler_gems_plan(options InstallBundlerGemsOptions) InstallBundlerGemsPlan {
	mut groups := if options.groups_provided {
		options.groups.clone()
	} else {
		options.add_groups.clone()
	}
	mut forget := false
	if 'all' in groups {
		groups = groups.filter(it != 'all')
		for group in options.valid_groups {
			if group !in groups {
				groups << group
			}
		}
	} else if options.groups_provided {
		forget = true
	}
	return InstallBundlerGemsPlan{
		groups: groups
		forget_user_gem_groups: forget
	}
}
