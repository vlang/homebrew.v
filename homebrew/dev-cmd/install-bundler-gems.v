module dev_cmd

import ruby

// Translated from Homebrew/brew `dev-cmd/install-bundler-gems.rb`.
// The original source is retained below until every stub has a typed V body.
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

// Ruby method `run` at line 26.
pub fn ruby_install_bundler_gems_l26_d1_run(args ...ruby.Value) ruby.Value {
	groups_provided := args.len > 0 && args[0].type_name !in ['Nil', 'NilClass', '']
	groups := if groups_provided { args[0].as_string_array() or { []string{} } } else { []string{} }
	add_groups := if args.len > 1 && args[1].type_name !in ['Nil', 'NilClass', ''] {
		args[1].as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	valid_groups := if args.len > 2 {
		args[2].as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	plan := install_bundler_gems_plan(InstallBundlerGemsOptions{
		groups: groups
		groups_provided: groups_provided
		add_groups: add_groups
		valid_groups: valid_groups
	})
	return ruby.map_value({
		'groups':                 ruby.string_array_value(plan.groups)
		'forget_user_gem_groups': ruby.bool_value(plan.forget_user_gem_groups)
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: module Homebrew
// 7:   module DevCmd
// 8:     class InstallBundlerGems < AbstractCommand
// 9:       cmd_args do
// 10:         description <<~EOS
// 11:           Install Homebrew's Bundler gems.
// 12:         EOS
// 13:         comma_array "--groups",
// 14:                     description: "Installs the specified comma-separated list of gem groups (default: last used). " \
// 15:                                  "Replaces any previously installed groups."
// 16:         comma_array "--add-groups",
// 17:                     description: "Installs the specified comma-separated list of gem groups, " \
// 18:                                  "in addition to those already installed."
// 19:
// 20:         conflicts "--groups", "--add-groups"
// 21:
// 22:         named_args :none
// 23:       end
// 24:
// 25:       sig { override.void }
// 26:       def run
// 27:         groups = args.groups || args.add_groups || []
// 28:
// 29:         if groups.delete("all")
// 30:           groups |= Homebrew.valid_gem_groups
// 31:         elsif args.groups # if we have been asked to replace
// 32:           Homebrew.forget_user_gem_groups!
// 33:         end
// 34:
// 35:         Homebrew.install_bundler_gems!(groups:)
// 36:       end
// 37:     end
// 38:   end
// 39: end
