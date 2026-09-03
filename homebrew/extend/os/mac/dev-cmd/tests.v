module dev_cmd

// Translated from Homebrew/brew `extend/os/mac/dev-cmd/tests.rb`.
pub fn mac_dev_tests_os_bundle_args(bundle_args []string) []string {
	mut result := bundle_args.clone()
	result << ['--tag', '~needs_linux', '--tag', '~needs_systemd']
	return result
}

pub fn mac_dev_tests_os_files(files []string) []string {
	return files.filter(!(it.starts_with('test/os/linux/') || it == 'test/os/linux_spec.rb'))
}

// Ruby method `os_bundle_args(bundle_args)` at line 15.
pub fn ruby_tests_l15_d1_os_bundle_args(bundle_args []string) []string {
	return mac_dev_tests_os_bundle_args(bundle_args)
}

// Ruby method `os_files(files)` at line 20.
pub fn ruby_tests_l20_d2_os_files(files []string) []string {
	return mac_dev_tests_os_files(files)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module DevCmd
// 7:       module Tests
// 8:         extend T::Helpers
// 9:
// 10:         requires_ancestor { Homebrew::DevCmd::Tests }
// 11:
// 12:         private
// 13:
// 14:         sig { params(bundle_args: T::Array[String]).returns(T::Array[String]) }
// 15:         def os_bundle_args(bundle_args)
// 16:           non_linux_bundle_args(bundle_args)
// 17:         end
// 18:
// 19:         sig { params(files: T::Array[String]).returns(T::Array[String]) }
// 20:         def os_files(files)
// 21:           non_linux_files(files)
// 22:         end
// 23:       end
// 24:     end
// 25:   end
// 26: end
// 27:
// 28: Homebrew::DevCmd::Tests.prepend(OS::Mac::DevCmd::Tests)
