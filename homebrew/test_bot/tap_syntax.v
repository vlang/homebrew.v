module test_bot

import ruby

pub struct TapSyntaxInput {
pub:
	tap_name          string
	tap_path          string
	installed         bool
	official          bool
	typed             bool
	stable            bool
	has_formula_files bool
	has_cask_files    bool
}

pub struct TapSyntaxStep {
pub:
	command     []string
	removed_env []string
}

pub struct TapSyntaxRun {
pub:
	header string
	steps  []TapSyntaxStep
}

// Translated from Homebrew/brew `test_bot/tap_syntax.rb`.

pub fn tap_syntax_run(input TapSyntaxInput) TapSyntaxRun {
	mut steps := []TapSyntaxStep{}
	if !input.installed {
		return TapSyntaxRun{ header: 'Running TapSyntax#run!' }
	}
	if !input.stable {
		if input.official && input.typed {
			steps << TapSyntaxStep{ command: ['brew', 'typecheck', input.tap_name] }
		}
		steps << TapSyntaxStep{ command: ['brew', 'style', input.tap_name] }
	}
	if !input.has_formula_files && !input.has_cask_files {
		return TapSyntaxRun{
			header: 'Running TapSyntax#run!'
			steps: steps
		}
	}
	without_recursive_sorbet := ['HOMEBREW_SORBET_RECURSIVE']
	steps << TapSyntaxStep{
		command: ['brew', 'readall', '--aliases', '--os=all', '--arch=all', input.tap_name]
		removed_env: without_recursive_sorbet
	}
	if !input.stable {
		steps << TapSyntaxStep{
			command: ['brew', 'audit', '--except=installed', '--tap=${input.tap_name}']
			removed_env: without_recursive_sorbet
		}
	}
	return TapSyntaxRun{
		header: 'Running TapSyntax#run!'
		steps: steps
	}
}
