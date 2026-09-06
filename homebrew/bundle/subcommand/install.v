module subcommand

import ruby

// Translated from Homebrew/brew `bundle/subcommand/install.rb`.

pub struct BundleInstallCommandOptions {
pub:
	zap               bool
	cleanup           bool
	force_cleanup     bool
	force             bool
	ask               bool
	install_succeeded bool = true
	dsl               ruby.Value
	global            bool
	file              string
	no_upgrade        bool
	verbose           bool
	jobs              string
	quiet             bool
}

pub struct BundleInstallPlan {
pub:
	dsl                       ruby.Value
	install_exit_code         int
	mark_installed_on_request bool
	cleanup_requested         bool
	cleanup_force             bool
	cleanup_ask               bool
	cleanup_zap               bool
	reset_cleanup_before_run  bool
}

pub fn build_bundle_install_plan(options BundleInstallCommandOptions) !BundleInstallPlan {
	if options.zap && !options.cleanup && !options.force_cleanup {
		return error('`--zap` cannot be passed without `--cleanup` or `--force-cleanup`.')
	}
	if options.cleanup && !options.force && !options.force_cleanup && !options.ask {
		return error('`brew bundle install --cleanup` requires `--force`, `--force-cleanup` or `\$HOMEBREW_ASK`.')
	}
	if !options.install_succeeded {
		return BundleInstallPlan{
			dsl: options.dsl
			install_exit_code: 1
			mark_installed_on_request: true
		}
	}
	cleanup_requested := options.cleanup || options.force_cleanup
	return BundleInstallPlan{
		dsl: options.dsl
		mark_installed_on_request: true
		cleanup_requested: cleanup_requested
		cleanup_force: options.force || options.force_cleanup
		cleanup_ask: options.ask
		cleanup_zap: options.zap
		reset_cleanup_before_run: cleanup_requested
	}
}
