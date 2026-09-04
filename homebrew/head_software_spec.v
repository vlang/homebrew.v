module homebrew

import ruby

// Translated from Homebrew/brew `head_software_spec.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct HeadSoftwareSpec {
pub:
	flags   []string
	version Version
}

pub fn new_head_software_spec(flags []string) HeadSoftwareSpec {
	return HeadSoftwareSpec{
		flags:   flags.clone()
		version: new_version('HEAD') or { panic(err) }
	}
}

pub fn (spec HeadSoftwareSpec) verify_download_integrity(_filename string) {
	// HEAD downloads are moving VCS targets, so the Ruby body intentionally does
	// no checksum verification.
}

// Ruby method `initialize(flags: [])` at line 8.
pub fn ruby_head_software_spec_l8_d1_initialize(args ...ruby.Value) ruby.Value {
	flags := if args.len > 0 { args[0].as_string_array() or { []string{} } } else { []string{} }
	spec := new_head_software_spec(flags)
	return ruby.structured_value('HeadSoftwareSpec', 'HEAD', {
		'flags':   spec.flags.join(',')
		'version': spec.version.to_s()
	})
}

// Ruby method `verify_download_integrity(_filename)` at line 14.
pub fn ruby_head_software_spec_l14_d2_verify_download_integrity(args ...ruby.Value) ruby.Value {
	spec := new_head_software_spec([])
	spec.verify_download_integrity(if args.len > 0 { args[0].as_string() } else { '' })
	return ruby.object_value('NilClass', '')
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "software_spec"
// 5:
// 6: class HeadSoftwareSpec < SoftwareSpec
// 7:   sig { params(flags: T::Array[String]).void }
// 8:   def initialize(flags: [])
// 9:     super
// 10:     @resource.version(Version.new("HEAD"))
// 11:   end
// 12:
// 13:   sig { params(_filename: Pathname).returns(NilClass) }
// 14:   def verify_download_integrity(_filename)
// 15:     # no-op
// 16:   end
// 17: end
