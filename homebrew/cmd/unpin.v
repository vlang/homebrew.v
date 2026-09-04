module cmd

import ruby

// Translated from Homebrew/brew `cmd/unpin.rb`.
pub fn unpin_packages(mut packages []PinPackageState) PinCommandResult {
	mut warnings := []string{}
	mut failures := []string{}
	for package_kind in [PinPackageKind.formula, .cask] {
		for mut package in packages {
			if package.kind != package_kind {
				continue
			}
			if package.pinned || (package.kind == .cask && package.pin_symlink) {
				package.unpin()
			} else if !package.installed || !package.pinnable {
				failures << '${package.full_name} not installed'
			} else {
				warnings << '${package.full_name} not pinned'
			}
		}
	}
	return PinCommandResult{
		warnings: warnings
		failures: failures
	}
}

fn unpin_command_result_value(result PinCommandResult, packages []PinPackageState) ruby.Value {
	mut messages := result.warnings.clone()
	messages << result.failures
	return ruby.Value{
		type_name: 'UnpinCommandResult'
		repr: messages.join('\n')
		map_data: {
			'warnings': ruby.string_array_value(result.warnings)
			'failures': ruby.string_array_value(result.failures)
			'packages': ruby.array_value(packages.map(pin_package_value(it)))
		}
		attributes: {
			'failed': result.failed().str()
		}
	}
}
