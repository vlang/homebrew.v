module subcommand

import ruby
import homebrew.bundle

// Translated from Homebrew/brew `bundle/subcommand/check.rb`.

fn bundle_check_result_value(result BundleCheckCommandResult) ruby.Value {
	return ruby.structured_value('Bundle::CheckSubcommand::Result', result.exit_code.str(), {
		'exit_code': result.exit_code.str()
		'stdout':    result.stdout
		'stderr':    result.stderr
	})
}

pub struct BundleCheckRunOptions {
pub:
	verbose                 bool
	quiet                   bool
	no_upgrade              bool
	already_output_formulae []string
}

pub fn run_bundle_check(state bundle.CheckerState,
	options BundleCheckRunOptions) !BundleCheckCommandResult {
	check := bundle.check_bundle_state(state, bundle.CheckerOptions{
		exit_on_first_error: !options.verbose
		no_upgrade: options.no_upgrade
		verbose: options.verbose
	})!
	return render_bundle_check(BundleDependencyCheck{
		work_to_be_done: check.work_to_be_done
		errors: check.errors
	}, BundleCheckCommandOptions{
		verbose: options.verbose
		quiet: options.quiet
		already_output_formulae: options.already_output_formulae
	})
}

pub struct BundleDependencyCheck {
pub:
	work_to_be_done bool
	errors          []string
}

pub struct BundleCheckCommandOptions {
pub:
	verbose                 bool
	quiet                   bool
	already_output_formulae []string
}

pub struct BundleCheckCommandResult {
pub:
	exit_code int
	stdout    string
	stderr    string
}

fn bundle_missing_formula_name(message string) ?string {
	prefix := 'Formula '
	suffix := ' needs to be installed'
	if !message.starts_with(prefix) {
		return none
	}
	end := message.index(suffix) or { return none }
	if end <= prefix.len {
		return none
	}
	return message[prefix.len..end]
}

pub fn render_bundle_check(check BundleDependencyCheck,
	options BundleCheckCommandOptions) BundleCheckCommandResult {
	if !check.work_to_be_done {
		return BundleCheckCommandResult{
			stdout: if options.quiet { '' } else { "The Brewfile's dependencies are satisfied.\n" }
		}
	}
	mut lines := []string{}
	if options.already_output_formulae.len == 0 {
		lines << "brew bundle can't satisfy your Brewfile's dependencies."
	}
	if options.verbose {
		for message in check.errors {
			name := bundle_missing_formula_name(message)
			if value := name {
				if value in options.already_output_formulae {
					continue
				}
			}
			lines << '→ ${message}'
		}
	} else {
		lines << 'Run `brew bundle check --verbose` to list unmet dependencies.'
	}
	lines << 'Satisfy missing dependencies with `brew bundle install`.'
	return BundleCheckCommandResult{
		exit_code: 1
		stderr: '${lines.join('\n')}\n'
	}
}
