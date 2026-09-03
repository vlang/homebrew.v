module api

// Translated from Homebrew/brew `extend/os/mac/api/internal.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct MacBottleTag {
pub:
	system string
	arch   string
}

pub fn mac_api_fallback_tag(prerelease bool, newest_supported string, arch string,
	effective_tag MacBottleTag) MacBottleTag {
	if prerelease {
		return MacBottleTag{
			system: newest_supported
			arch: arch
		}
	}
	return effective_tag
}

// Ruby method `fallback_tag` at line 16.
pub fn ruby_internal_l16_d1_fallback_tag(prerelease bool, newest_supported string, arch string,
	effective_tag MacBottleTag) MacBottleTag {
	return mac_api_fallback_tag(prerelease, newest_supported, arch, effective_tag)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module API
// 7:       module Internal
// 8:         module ClassMethods
// 9:           extend T::Helpers
// 10:
// 11:           requires_ancestor { T.class_of(::Homebrew::API::Internal) }
// 12:
// 13:           private
// 14:
// 15:           sig { returns(Utils::Bottles::Tag) }
// 16:           def fallback_tag
// 17:             if MacOS.version.prerelease?
// 18:               # When a new macOS version has been announced, we won't have generated a JSON file for it yet.
// 19:               # We need to fallback to allow us to test that macOS version.
// 20:               fallback_os = ::MacOSVersion.new(HOMEBREW_MACOS_NEWEST_SUPPORTED).to_sym
// 21:               ::Utils::Bottles::Tag.new(system: fallback_os, arch: ::Hardware::CPU.arch)
// 22:             else
// 23:               effective_tag
// 24:             end
// 25:           end
// 26:         end
// 27:       end
// 28:     end
// 29:   end
// 30: end
// 31:
// 32: Homebrew::API::Internal.singleton_class.prepend(OS::Mac::API::Internal::ClassMethods)
