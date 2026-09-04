module mac

import ruby

pub struct MacReadallCask {
pub:
	path             string
	url_present      bool = true
	macos_versions   []int
	macos_comparator string = '>='
	evaluation_error string
}

pub struct MacReadallResult {
pub:
	valid     bool = true
	errors    []string
	processed []string
}

fn mac_readall_version_matches(current int, comparator string, wanted int) bool {
	return match comparator {
		'==' { current == wanted }
		'!=' { current != wanted }
		'>' { current > wanted }
		'>=' { current >= wanted }
		'<' { current < wanted }
		'<=' { current <= wanted }
		else { false }
	}
}

pub fn mac_readall_valid_casks(os_name string, current_macos_version int, arch string,
	casks []MacReadallCask, linux_super_valid bool) MacReadallResult {
	if os_name == 'linux' {
		return MacReadallResult{ valid: linux_super_valid }
	}
	mut valid := true
	mut errors := []string{}
	mut processed := []string{}
	for cask in casks {
		processed << cask.path
		if cask.evaluation_error != '' {
			errors << 'Invalid cask (macOS ${current_macos_version} on ${arch}): ${cask.path}\n${cask.evaluation_error}'
			valid = false
			continue
		}
		if cask.macos_versions.len > 0 && !cask.macos_versions.any(mac_readall_version_matches(current_macos_version, cask.macos_comparator, it)) {
			continue
		}
		if !cask.url_present {
			errors << 'Invalid cask (macOS ${current_macos_version} on ${arch}): ${cask.path}\nMissing URL'
			valid = false
		}
	}
	return MacReadallResult{ valid: valid, errors: errors, processed: processed }
}

fn mac_readall_casks_from_value(value ruby.Value) ![]MacReadallCask {
	mut casks := []MacReadallCask{}
	for item in value.as_array()! {
		values := item.as_map()!
		mut versions := []int{}
		if raw := values['macos_versions'] {
			for version in raw.as_array()! {
				versions << int(version.as_int()!)
			}
		}
		casks << MacReadallCask{
			path: (values['path'] or { return error('cask path is required') }).as_string()
			url_present: (values['url_present'] or { ruby.bool_value(true) }).as_bool()!
			macos_versions: versions
			macos_comparator: (values['macos_comparator'] or { ruby.string_value('>=') }).as_string()
			evaluation_error: (values['evaluation_error'] or { ruby.string_value('') }).as_string()
		}
	}
	return casks
}

// Translated from Homebrew/brew `extend/os/mac/readall.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `valid_casks?(tap, os_name: nil, arch: ::Hardware::CPU.type, files: nil)` at line 23.
pub fn ruby_readall_l23_d1_valid_casks(args ...ruby.Value) ruby.Value {
	os_name := if args.len > 0 { args[0].as_string() } else { 'macos' }
	current_version := if args.len > 1 { int(args[1].as_int() or { panic(err) }) } else { 15 }
	arch := if args.len > 2 { args[2].as_string() } else { 'arm' }
	casks := if args.len > 3 {
		mac_readall_casks_from_value(args[3]) or { panic(err) }
	} else {
		[]MacReadallCask{}
	}
	linux_super_valid := if args.len > 4 { args[4].as_bool() or { panic(err) } } else { true }
	return ruby.bool_value(mac_readall_valid_casks(os_name, current_version, arch, casks, linux_super_valid).valid)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5:
// 6: module OS
// 7:   module Mac
// 8:     module Readall
// 9:       module ClassMethods
// 10:         extend T::Helpers
// 11:         include ::Utils::Output::Mixin
// 12:
// 13:         requires_ancestor { Kernel }
// 14:
// 15:         sig {
// 16:           params(
// 17:             tap:     ::Tap,
// 18:             os_name: T.nilable(Symbol),
// 19:             arch:    T.nilable(Symbol),
// 20:             files:   T.nilable(T::Array[::Pathname]),
// 21:           ).returns(T::Boolean)
// 22:         }
// 23:         def valid_casks?(tap, os_name: nil, arch: ::Hardware::CPU.type, files: nil)
// 24:           return super if os_name == :linux
// 25:
// 26:           current_macos_version = if os_name.is_a?(Symbol)
// 27:             MacOSVersion.from_symbol(os_name)
// 28:           else
// 29:             MacOS.version
// 30:           end
// 31:
// 32:           success = T.let(true, T::Boolean)
// 33:           (files || tap.cask_files).each do |file|
// 34:             cask = ::Cask::CaskLoader.load(file)
// 35:
// 36:             # Fine to have missing URLs for unsupported macOS
// 37:             macos_req = cask.depends_on.macos
// 38:             next if macos_req&.version && Array(macos_req.version).none? do |macos_version|
// 39:               current_macos_version.compare(macos_req.comparator, macos_version)
// 40:             end
// 41:
// 42:             raise "Missing URL" if cask.url.nil?
// 43:           rescue Interrupt
// 44:             raise
// 45:           # Handle all possible exceptions reading Casks.
// 46:           rescue Exception => e # rubocop:disable Lint/RescueException
// 47:             os_and_arch = "macOS #{current_macos_version} on #{arch}"
// 48:             onoe "Invalid cask (#{os_and_arch}): #{file}"
// 49:             $stderr.puts e
// 50:             success = false
// 51:           end
// 52:           success
// 53:         end
// 54:       end
// 55:     end
// 56:   end
// 57: end
// 58:
// 59: Readall.singleton_class.prepend(OS::Mac::Readall::ClassMethods)
