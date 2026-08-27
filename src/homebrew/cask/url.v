module cask

import brew_runtime

// Translated from Homebrew/brew `cask/url.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :uri` at line 11.
pub fn ruby_url_l11_d1_uri(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uri', ...args)
}

// Ruby attr_reader `attr_reader :revisions` at line 14.
pub fn ruby_url_l14_d2_revisions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('revisions', ...args)
}

// Ruby attr_reader `attr_reader :trust_cert` at line 17.
pub fn ruby_url_l17_d3_trust_cert(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('trust_cert', ...args)
}

// Ruby attr_reader `attr_reader :cookies, :data` at line 20.
pub fn ruby_url_l20_d4_cookies(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cookies', ...args)
}

// Ruby attr_reader `attr_reader :cookies, :data` at line 20.
pub fn ruby_url_l20_d5_data(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('data', ...args)
}

// Ruby attr_reader `attr_reader :header` at line 23.
pub fn ruby_url_l23_d6_header(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('header', ...args)
}

// Ruby attr_reader `attr_reader :referer` at line 26.
pub fn ruby_url_l26_d7_referer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('referer', ...args)
}

// Ruby attr_reader `attr_reader :specs` at line 29.
pub fn ruby_url_l29_d8_specs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('specs', ...args)
}

// Ruby attr_reader `attr_reader :user_agent` at line 32.
pub fn ruby_url_l32_d9_user_agent(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('user_agent', ...args)
}

// Ruby attr_reader `attr_reader :using` at line 35.
pub fn ruby_url_l35_d10_using(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('using', ...args)
}

// Ruby attr_reader `attr_reader :tag, :branch, :revision, :only_path, :verified` at line 38.
pub fn ruby_url_l38_d11_tag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tag', ...args)
}

// Ruby attr_reader `attr_reader :tag, :branch, :revision, :only_path, :verified` at line 38.
pub fn ruby_url_l38_d12_branch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('branch', ...args)
}

// Ruby attr_reader `attr_reader :tag, :branch, :revision, :only_path, :verified` at line 38.
pub fn ruby_url_l38_d13_revision(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('revision', ...args)
}

// Ruby attr_reader `attr_reader :tag, :branch, :revision, :only_path, :verified` at line 38.
pub fn ruby_url_l38_d14_only_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('only_path', ...args)
}

// Ruby attr_reader `attr_reader :tag, :branch, :revision, :only_path, :verified` at line 38.
pub fn ruby_url_l38_d15_verified(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('verified', ...args)
}

// Ruby def_delegators `def_delegators :uri, :path, :scheme, :to_s` at line 42.
pub fn ruby_url_l42_d16_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('path', ...args)
}

// Ruby def_delegators `def_delegators :uri, :path, :scheme, :to_s` at line 42.
pub fn ruby_url_l42_d17_scheme(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('scheme', ...args)
}

// Ruby def_delegators `def_delegators :uri, :path, :scheme, :to_s` at line 42.
pub fn ruby_url_l42_d18_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby method `initialize(` at line 66.
pub fn ruby_url_l66_d19_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `location` at line 96.
pub fn ruby_url_l96_d20_location(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('location', ...args)
}

// Ruby method `unversioned?(ignore_major_version: false)` at line 101.
pub fn ruby_url_l101_d21_unversioned(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('unversioned?', ...args)
}

// Ruby method `raw_url_line` at line 115.
pub fn ruby_url_l115_d22_raw_url_line(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raw_url_line', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "uri"
// 5: require "source_location"
// 6:
// 7: module Cask
// 8:   # Class corresponding to the `url` stanza.
// 9:   class URL
// 10:     sig { returns(URI::Generic) }
// 11:     attr_reader :uri
// 12:
// 13:     sig { returns(T.nilable(T::Hash[T.any(Symbol, String), String])) }
// 14:     attr_reader :revisions
// 15:
// 16:     sig { returns(T.nilable(T::Boolean)) }
// 17:     attr_reader :trust_cert
// 18:
// 19:     sig { returns(T.nilable(T::Hash[String, String])) }
// 20:     attr_reader :cookies, :data
// 21:
// 22:     sig { returns(T.nilable(T::Array[String])) }
// 23:     attr_reader :header
// 24:
// 25:     sig { returns(T.nilable(T.any(URI::Generic, String))) }
// 26:     attr_reader :referer
// 27:
// 28:     sig { returns(T::Hash[Symbol, T.untyped]) }
// 29:     attr_reader :specs
// 30:
// 31:     sig { returns(T.nilable(T.any(Symbol, String))) }
// 32:     attr_reader :user_agent
// 33:
// 34:     sig { returns(T.nilable(T.any(T::Class[AbstractDownloadStrategy], Symbol))) }
// 35:     attr_reader :using
// 36:
// 37:     sig { returns(T.nilable(String)) }
// 38:     attr_reader :tag, :branch, :revision, :only_path, :verified
// 39:
// 40:     extend Forwardable
// 41:
// 42:     def_delegators :uri, :path, :scheme, :to_s
// 43:
// 44:     # Creates a `url` stanza.
// 45:     #
// 46:     # @api public
// 47:     sig {
// 48:       params(
// 49:         uri:             T.any(URI::Generic, String),
// 50:         verified:        T.nilable(String),
// 51:         using:           T.nilable(T.any(T::Class[AbstractDownloadStrategy], Symbol)),
// 52:         tag:             T.nilable(String),
// 53:         branch:          T.nilable(String),
// 54:         revisions:       T.nilable(T::Hash[T.any(Symbol, String), String]),
// 55:         revision:        T.nilable(String),
// 56:         trust_cert:      T.nilable(T::Boolean),
// 57:         cookies:         T.nilable(T::Hash[T.any(String, Symbol), String]),
// 58:         referer:         T.nilable(T.any(URI::Generic, String)),
// 59:         header:          T.nilable(T.any(String, T::Array[String])),
// 60:         user_agent:      T.nilable(T.any(Symbol, String)),
// 61:         data:            T.nilable(T::Hash[String, String]),
// 62:         only_path:       T.nilable(String),
// 63:         caller_location: Thread::Backtrace::Location,
// 64:       ).void
// 65:     }
// 66:     def initialize(
// 67:       uri, verified: nil, using: nil, tag: nil, branch: nil, revisions: nil, revision: nil, trust_cert: nil,
// 68:       cookies: nil, referer: nil, header: nil, user_agent: nil, data: nil, only_path: nil,
// 69:       caller_location: caller_locations.fetch(0)
// 70:     )
// 71:       @uri = T.let(URI(uri), URI::Generic)
// 72:
// 73:       header = Array(header) unless header.nil?
// 74:
// 75:       specs = {}
// 76:       specs[:verified]   = @verified   = T.let(verified, T.nilable(String))
// 77:       specs[:using]      = @using      = T.let(using, T.nilable(T.any(T::Class[AbstractDownloadStrategy], Symbol)))
// 78:       specs[:tag]        = @tag        = T.let(tag, T.nilable(String))
// 79:       specs[:branch]     = @branch     = T.let(branch, T.nilable(String))
// 80:       specs[:revisions]  = @revisions  = T.let(revisions, T.nilable(T::Hash[T.any(Symbol, String), String]))
// 81:       specs[:revision]   = @revision   = T.let(revision, T.nilable(String))
// 82:       specs[:trust_cert] = @trust_cert = T.let(trust_cert, T.nilable(T::Boolean))
// 83:       specs[:cookies]    =
// 84:         @cookies = T.let(cookies&.transform_keys(&:to_s), T.nilable(T::Hash[String, String]))
// 85:       specs[:referer]    = @referer    = T.let(referer, T.nilable(T.any(URI::Generic, String)))
// 86:       specs[:headers]    = @header     = T.let(header, T.nilable(T::Array[String]))
// 87:       specs[:user_agent] = @user_agent = T.let(user_agent || :default, T.nilable(T.any(Symbol, String)))
// 88:       specs[:data]       = @data       = T.let(data, T.nilable(T::Hash[String, String]))
// 89:       specs[:only_path]  = @only_path  = T.let(only_path, T.nilable(String))
// 90:
// 91:       @specs = T.let(specs.compact, T::Hash[Symbol, T.untyped])
// 92:       @caller_location = caller_location
// 93:     end
// 94:
// 95:     sig { returns(Homebrew::SourceLocation) }
// 96:     def location
// 97:       Homebrew::SourceLocation.new(@caller_location.lineno, raw_url_line&.index("url"))
// 98:     end
// 99:
// 100:     sig { params(ignore_major_version: T::Boolean).returns(T::Boolean) }
// 101:     def unversioned?(ignore_major_version: false)
// 102:       interpolated_url = raw_url_line&.then { |line| line[/url\s+"([^"]+)"/, 1] }
// 103:
// 104:       return false unless interpolated_url
// 105:
// 106:       interpolated_url = interpolated_url.gsub(/\#{\s*arch\s*}/, "")
// 107:       interpolated_url = interpolated_url.gsub(/\#{\s*version\s*\.major\s*}/, "") if ignore_major_version
// 108:
// 109:       interpolated_url.exclude?('#{')
// 110:     end
// 111:
// 112:     private
// 113:
// 114:     sig { returns(T.nilable(String)) }
// 115:     def raw_url_line
// 116:       return @raw_url_line if defined?(@raw_url_line)
// 117:
// 118:       @raw_url_line = T.let(Pathname(T.must(@caller_location.path))
// 119:                       .each_line
// 120:                       .drop(@caller_location.lineno - 1)
// 121:                       .first, T.nilable(String))
// 122:     end
// 123:   end
// 124: end
