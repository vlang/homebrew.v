module test_bot

import ruby

pub struct SetupStep {
pub:
	command []string
	verbose bool
	passed  bool = true
}

pub struct SetupRun {
pub:
	header string
	steps  []SetupStep
}

// Translated from Homebrew/brew `test_bot/setup.rb`.

pub fn setup_run(verbose_doctor bool) SetupRun {
	return SetupRun{
		header: 'Running Setup#run!'
		steps: [
			SetupStep{
				command: ['brew', 'install-bundler-gems',
					'--add-groups=ast,audit,bottle,formula_test,livecheck,style']
			},
			SetupStep{
				command: ['brew', 'config']
				verbose: true
			},
			SetupStep{
				command: if verbose_doctor {
					['brew', 'doctor', '--debug']
				} else {
					['brew', 'doctor']
				}
				verbose: verbose_doctor
			},
		]
	}
}
