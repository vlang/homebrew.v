module cask

import brew_runtime
import net.urllib
import os
import regex

// Translated from Homebrew/brew `cask/url.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CaskURL {
pub:
	uri            string
	options        map[string]brew_runtime.Value
	caller_path    string
	caller_line    int
	raw_line_value string
	has_raw_line   bool
}

fn cask_url_nil() brew_runtime.Value {
	return brew_runtime.Value{ type_name: 'NilClass', repr: 'nil' }
}

fn cask_url_header(value brew_runtime.Value) brew_runtime.Value {
	if value.type_name == 'NilClass' {
		return value
	}
	if value.type_name == 'Array' {
		return value
	}
	return brew_runtime.string_array_value([value.as_string()])
}

pub fn new_cask_url(uri string, supplied map[string]brew_runtime.Value) !CaskURL {
	urllib.parse(uri)!
	mut options := map[string]brew_runtime.Value{}
	for key in ['verified', 'using', 'tag', 'branch', 'revisions', 'revision', 'trust_cert', 'cookies',
		'referer', 'header', 'user_agent', 'data', 'only_path'] {
		if raw := supplied[key] {
			if raw.type_name != 'NilClass' {
				options[key] = if key == 'header' { cask_url_header(raw) } else { raw }
			}
		}
	}
	if 'user_agent' !in options {
		options['user_agent'] = brew_runtime.Value{ type_name: 'Symbol', repr: 'default' }
	}
	caller := supplied['caller_location'] or { brew_runtime.Value{} }
	line_text := caller.attributes['lineno'] or {
		if raw := caller.map_data['lineno'] { raw.as_string() } else { '0' }
	}
	raw_line := supplied['raw_url_line'] or { brew_runtime.Value{} }
	return CaskURL{
		uri: uri
		options: options
		caller_path: caller.attributes['path'] or {
			if raw := caller.map_data['path'] {
				raw.as_string()} else {
				''}}
		caller_line: line_text.int()
		raw_line_value: raw_line.as_string()
		has_raw_line: raw_line.type_name != '' && raw_line.type_name != 'NilClass'
	}
}

pub fn cask_url_value(url CaskURL) brew_runtime.Value {
	mut values := url.options.clone()
	values['uri'] = brew_runtime.string_value(url.uri)
	values['caller_path'] = brew_runtime.string_value(url.caller_path)
	values['caller_line'] = brew_runtime.int_value(url.caller_line)
	if url.has_raw_line {
		values['raw_url_line'] = brew_runtime.string_value(url.raw_line_value)
	}
	return brew_runtime.Value{
		type_name: 'Cask::URL'
		repr: url.uri
		map_data: values
		attributes: {
			'uri': url.uri
		}
	}
}

pub fn cask_url_from_value(value brew_runtime.Value) !CaskURL {
	if value.type_name != 'Cask::URL' {
		return error('expected Cask::URL, got ${value.type_name}')
	}
	mut supplied := value.map_data.clone()
	if raw_path := supplied['caller_path'] {
		supplied['caller_location'] = brew_runtime.structured_value('Thread::Backtrace::Location', raw_path.as_string(), {
			'path':   raw_path.as_string()
			'lineno': (supplied['caller_line'] or { brew_runtime.int_value(0) }).as_string()
		})
	}
	return new_cask_url((supplied['uri'] or { brew_runtime.string_value(value.as_string()) }).as_string(), supplied)
}

pub fn (url CaskURL) parsed() !urllib.URL {
	return urllib.parse(url.uri)
}

pub fn (url CaskURL) raw_url_line() ?string {
	if url.has_raw_line {
		return url.raw_line_value
	}
	if url.caller_path == '' || url.caller_line < 1 {
		return none
	}
	lines := os.read_lines(url.caller_path) or { return none }
	if url.caller_line > lines.len {
		return none
	}
	return '${lines[url.caller_line - 1]}\n'
}

pub fn (url CaskURL) unversioned(ignore_major_version bool) bool {
	line := url.raw_url_line() or { return false }
	url_start := line.index('url') or { return false }
	first_quote_offset := line[url_start + 3..].index('"') or { return false }
	first_quote := url_start + 3 + first_quote_offset
	second_quote_offset := line[first_quote + 1..].index('"') or { return false }
	second_quote := first_quote + 1 + second_quote_offset
	mut interpolated := line[first_quote + 1..second_quote]
	mut arch_expression := regex.regex_opt('#\\{\\s*arch\\s*\\}') or { return false }
	interpolated = arch_expression.replace(interpolated, '')
	if ignore_major_version {
		mut major_expression := regex.regex_opt('#\\{\\s*version\\s*\\.\\s*major\\s*\\}') or {
			return false
		}
		interpolated = major_expression.replace(interpolated, '')
	}
	return !interpolated.contains(r'#{')
}

fn cask_url_receiver(args []brew_runtime.Value) ?CaskURL {
	if args.len == 0 {
		return none
	}
	return cask_url_from_value(args[0]) or { return none }
}

fn cask_url_option(args []brew_runtime.Value, key string) brew_runtime.Value {
	url := cask_url_receiver(args) or { return cask_url_nil() }
	return url.options[key] or { cask_url_nil() }
}

// Ruby attr_reader `attr_reader :uri` at line 11.
pub fn ruby_url_l11_d1_uri(args ...brew_runtime.Value) brew_runtime.Value {
	url := cask_url_receiver(args) or { return cask_url_nil() }
	return brew_runtime.object_value('URI::Generic', url.uri)
}

// Ruby attr_reader `attr_reader :revisions` at line 14.
pub fn ruby_url_l14_d2_revisions(args ...brew_runtime.Value) brew_runtime.Value {
	return cask_url_option(args, 'revisions')
}

// Ruby attr_reader `attr_reader :trust_cert` at line 17.
pub fn ruby_url_l17_d3_trust_cert(args ...brew_runtime.Value) brew_runtime.Value {
	return cask_url_option(args, 'trust_cert')
}

// Ruby attr_reader `attr_reader :cookies, :data` at line 20.
pub fn ruby_url_l20_d4_cookies(args ...brew_runtime.Value) brew_runtime.Value {
	return cask_url_option(args, 'cookies')
}

// Ruby attr_reader `attr_reader :cookies, :data` at line 20.
pub fn ruby_url_l20_d5_data(args ...brew_runtime.Value) brew_runtime.Value {
	return cask_url_option(args, 'data')
}

// Ruby attr_reader `attr_reader :header` at line 23.
pub fn ruby_url_l23_d6_header(args ...brew_runtime.Value) brew_runtime.Value {
	return cask_url_option(args, 'header')
}

// Ruby attr_reader `attr_reader :referer` at line 26.
pub fn ruby_url_l26_d7_referer(args ...brew_runtime.Value) brew_runtime.Value {
	return cask_url_option(args, 'referer')
}

// Ruby attr_reader `attr_reader :specs` at line 29.
pub fn ruby_url_l29_d8_specs(args ...brew_runtime.Value) brew_runtime.Value {
	url := cask_url_receiver(args) or { return brew_runtime.map_value({}) }
	return brew_runtime.map_value(url.options)
}

// Ruby attr_reader `attr_reader :user_agent` at line 32.
pub fn ruby_url_l32_d9_user_agent(args ...brew_runtime.Value) brew_runtime.Value {
	return cask_url_option(args, 'user_agent')
}

// Ruby attr_reader `attr_reader :using` at line 35.
pub fn ruby_url_l35_d10_using(args ...brew_runtime.Value) brew_runtime.Value {
	return cask_url_option(args, 'using')
}

// Ruby attr_reader `attr_reader :tag, :branch, :revision, :only_path, :verified` at line 38.
pub fn ruby_url_l38_d11_tag(args ...brew_runtime.Value) brew_runtime.Value {
	return cask_url_option(args, 'tag')
}

// Ruby attr_reader `attr_reader :tag, :branch, :revision, :only_path, :verified` at line 38.
pub fn ruby_url_l38_d12_branch(args ...brew_runtime.Value) brew_runtime.Value {
	return cask_url_option(args, 'branch')
}

// Ruby attr_reader `attr_reader :tag, :branch, :revision, :only_path, :verified` at line 38.
pub fn ruby_url_l38_d13_revision(args ...brew_runtime.Value) brew_runtime.Value {
	return cask_url_option(args, 'revision')
}

// Ruby attr_reader `attr_reader :tag, :branch, :revision, :only_path, :verified` at line 38.
pub fn ruby_url_l38_d14_only_path(args ...brew_runtime.Value) brew_runtime.Value {
	return cask_url_option(args, 'only_path')
}

// Ruby attr_reader `attr_reader :tag, :branch, :revision, :only_path, :verified` at line 38.
pub fn ruby_url_l38_d15_verified(args ...brew_runtime.Value) brew_runtime.Value {
	return cask_url_option(args, 'verified')
}

// Ruby def_delegators `def_delegators :uri, :path, :scheme, :to_s` at line 42.
pub fn ruby_url_l42_d16_path(args ...brew_runtime.Value) brew_runtime.Value {
	url := cask_url_receiver(args) or { return cask_url_nil() }
	parsed := url.parsed() or { return brew_runtime.object_value('URI::InvalidURIError', err.msg()) }
	return brew_runtime.string_value(parsed.path)
}

// Ruby def_delegators `def_delegators :uri, :path, :scheme, :to_s` at line 42.
pub fn ruby_url_l42_d17_scheme(args ...brew_runtime.Value) brew_runtime.Value {
	url := cask_url_receiver(args) or { return cask_url_nil() }
	parsed := url.parsed() or { return brew_runtime.object_value('URI::InvalidURIError', err.msg()) }
	return brew_runtime.string_value(parsed.scheme)
}

// Ruby def_delegators `def_delegators :uri, :path, :scheme, :to_s` at line 42.
pub fn ruby_url_l42_d18_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	url := cask_url_receiver(args) or { return brew_runtime.string_value('') }
	return brew_runtime.string_value(url.uri)
}

// Ruby method `initialize(` at line 66.
pub fn ruby_url_l66_d19_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('ArgumentError', 'URL.new requires a URI')
	}
	options := if args.len > 1 && args[args.len - 1].type_name == 'Hash' {
		args[args.len - 1].map_data.clone()
	} else {
		map[string]brew_runtime.Value{}
	}
	url := new_cask_url(args[0].as_string(), options) or {
		return brew_runtime.object_value('URI::InvalidURIError', err.msg())
	}
	return cask_url_value(url)
}

// Ruby method `location` at line 96.
pub fn ruby_url_l96_d20_location(args ...brew_runtime.Value) brew_runtime.Value {
	url := cask_url_receiver(args) or { return cask_url_nil() }
	line := url.raw_url_line() or { '' }
	column := line.index('url') or { -1 }
	return brew_runtime.structured_value('Homebrew::SourceLocation', '${url.caller_line}:${column}', {
		'line':   url.caller_line.str()
		'column': column.str()
	})
}

// Ruby method `unversioned?(ignore_major_version: false)` at line 101.
pub fn ruby_url_l101_d21_unversioned(args ...brew_runtime.Value) brew_runtime.Value {
	url := cask_url_receiver(args) or { return brew_runtime.bool_value(false) }
	keywords := if args.len > 1 && args[args.len - 1].type_name == 'Hash' {
		args[args.len - 1].map_data
	} else {
		map[string]brew_runtime.Value{}
	}
	ignore_major := (keywords['ignore_major_version'] or { brew_runtime.bool_value(false) }).as_bool() or { false }
	return brew_runtime.bool_value(url.unversioned(ignore_major))
}

// Ruby method `raw_url_line` at line 115.
pub fn ruby_url_l115_d22_raw_url_line(args ...brew_runtime.Value) brew_runtime.Value {
	url := cask_url_receiver(args) or { return cask_url_nil() }
	line := url.raw_url_line() or { return cask_url_nil() }
	return brew_runtime.string_value(line)
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
