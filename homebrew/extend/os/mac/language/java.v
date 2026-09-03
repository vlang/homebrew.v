module language

// Translated from Homebrew/brew `extend/os/mac/language/java.rb`.
// The original source is retained below until every stub has a typed V body.
pub type OpenJdkFormulaFinder = fn(string) ?string

pub fn mac_java_home(version string, finder OpenJdkFormulaFinder) ?string {
	opt_libexec := finder(version) or { return none }
	return '${opt_libexec.trim_right('/')}/openjdk.jdk/Contents/Home'
}

// Ruby method `java_home(version = nil)` at line 14.
pub fn ruby_java_l14_d1_java_home(version string, finder OpenJdkFormulaFinder) ?string {
	return mac_java_home(version, finder)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module OS
// 5:   module Mac
// 6:     module Language
// 7:       module Java
// 8:         module ClassMethods
// 9:           extend T::Helpers
// 10:
// 11:           requires_ancestor { T.class_of(::Language::Java) }
// 12:
// 13:           sig { params(version: T.nilable(String)).returns(T.nilable(::Pathname)) }
// 14:           def java_home(version = nil)
// 15:             openjdk = find_openjdk_formula(version)
// 16:             return unless openjdk
// 17:
// 18:             openjdk.opt_libexec/"openjdk.jdk/Contents/Home"
// 19:           end
// 20:         end
// 21:       end
// 22:     end
// 23:   end
// 24: end
// 25:
// 26: Language::Java.singleton_class.prepend(OS::Mac::Language::Java::ClassMethods)
