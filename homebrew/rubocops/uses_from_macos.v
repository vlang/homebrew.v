module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/uses_from_macos.rb`.
// The original source is retained below until every stub has a typed V body.
pub const provided_by_macos_formulae = [
	'apr',
	'bc',
	'bc-gh',
	'berkeley-db',
	'bison',
	'bzip2',
	'cups',
	'curl',
	'cyrus-sasl',
	'dyld-headers',
	'ed',
	'expat',
	'file-formula',
	'flex',
	'gperf',
	'icu4c',
	'krb5',
	'libarchive',
	'libedit',
	'libffi',
	'libiconv',
	'libpcap',
	'libressl',
	'libxcrypt',
	'libxml2',
	'libxslt',
	'llvm',
	'lsof',
	'm4',
	'ncompress',
	'ncurses',
	'net-snmp',
	'netcat',
	'openldap',
	'pax',
	'pcsc-lite',
	'pod2man',
	'ruby',
	'sqlite',
	'ssh-copy-id',
	'swift',
	'tcl-tk',
	'unifdef',
	'unzip',
	'whois',
	'zip',
	'zlib',
]

pub const allowed_uses_from_macos_deps = [
	'bash',
	'cpio',
	'expect',
	'git',
	'groff',
	'gzip',
	'jq',
	'less',
	'mandoc',
	'openssl',
	'perl',
	'php',
	'python',
	'rsync',
	'vim',
	'xz',
	'zsh',
]

pub struct UsesFromMacosProblem {
pub:
	kind       string
	dependency string
	begin_pos  int
	end_pos    int
	message    string
}

fn uses_from_macos_calls(source string) []UsesFromMacosProblem {
	mut calls := []UsesFromMacosProblem{}
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		line := source[line_start..line_end]
		mut cursor := 0
		for cursor < line.len && (line[cursor] == ` ` || line[cursor] == `\t`) {
			cursor++
		}
		if line[cursor..].starts_with('uses_from_macos') {
			after := cursor + 'uses_from_macos'.len
			if after == line.len || line[after] == ` ` || line[after] == `\t` || line[after] == `(` {
				mut quote := after
				for quote < line.len && line[quote] != `"` {
					quote++
				}
				if quote < line.len {
					mut end := quote + 1
					mut escaped := false
					for end < line.len {
						if escaped {
							escaped = false
						} else if line[end] == `\\` {
							escaped = true
						} else if line[end] == `"` {
							if end > quote + 1 {
								calls << UsesFromMacosProblem{
									dependency: line[quote + 1..end]
									begin_pos: line_start + cursor
									end_pos: line_end
								}
							}
							break
						}
						end++
					}
				}
			}
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return calls
}

pub fn audit_provided_by_macos(source string, formula_name string) []UsesFromMacosProblem {
	if !source.contains('keg_only :provided_by_macos') || formula_name in provided_by_macos_formulae {
		return []UsesFromMacosProblem{}
	}
	position := source.index('keg_only :provided_by_macos') or { 0 }
	return [UsesFromMacosProblem{
		kind: 'missing_from_provided_list'
		begin_pos: position
		end_pos: position + 'keg_only :provided_by_macos'.len
		message: 'Formulae that are `keg_only :provided_by_macos` should be added to the `PROVIDED_BY_MACOS_FORMULAE` list (in the Homebrew/brew repository)'
	}]
}

pub fn audit_uses_from_macos(source string) []UsesFromMacosProblem {
	depends_on_linux := source.contains('depends_on :linux')
	mut problems := []UsesFromMacosProblem{}
	for call in uses_from_macos_calls(source) {
		if depends_on_linux {
			problems << UsesFromMacosProblem{
				...call
				kind: 'linux_required'
				message: '`uses_from_macos` should not be used when Linux is required.'
			}
		}
		if call.dependency !in allowed_uses_from_macos_deps && call.dependency !in provided_by_macos_formulae {
			problems << UsesFromMacosProblem{
				...call
				kind: 'non_macos_dependency'
				message: "`uses_from_macos` should only be used for macOS dependencies, not '${call.dependency}'."
			}
		}
	}
	return problems
}

fn uses_from_macos_problem_value(problem UsesFromMacosProblem) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Problem', problem.message, {
		'kind':       problem.kind
		'dependency': problem.dependency
		'begin_pos':  problem.begin_pos.str()
		'end_pos':    problem.end_pos.str()
		'message':    problem.message
	})
}

// Ruby method `audit_formula(formula_nodes)` at line 62.
pub fn ruby_uses_from_macos_l62_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	formula_name := if args.len > 1 { args[1].as_string() } else { '' }
	return brew_runtime.array_value(audit_provided_by_macos(source, formula_name).map(uses_from_macos_problem_value(it)))
}

// Ruby method `audit_formula(formula_nodes)` at line 100.
pub fn ruby_uses_from_macos_l100_d2_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.array_value(audit_uses_from_macos(source).map(uses_from_macos_problem_value(it)))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/extend/formula_cop"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     module FormulaAudit
// 9:       # This cop audits formulae that are keg-only because they are provided by macos.
// 10:       class ProvidedByMacos < FormulaCop
// 11:         PROVIDED_BY_MACOS_FORMULAE = %w[
// 12:           apr
// 13:           bc
// 14:           bc-gh
// 15:           berkeley-db
// 16:           bison
// 17:           bzip2
// 18:           cups
// 19:           curl
// 20:           cyrus-sasl
// 21:           dyld-headers
// 22:           ed
// 23:           expat
// 24:           file-formula
// 25:           flex
// 26:           gperf
// 27:           icu4c
// 28:           krb5
// 29:           libarchive
// 30:           libedit
// 31:           libffi
// 32:           libiconv
// 33:           libpcap
// 34:           libressl
// 35:           libxcrypt
// 36:           libxml2
// 37:           libxslt
// 38:           llvm
// 39:           lsof
// 40:           m4
// 41:           ncompress
// 42:           ncurses
// 43:           net-snmp
// 44:           netcat
// 45:           openldap
// 46:           pax
// 47:           pcsc-lite
// 48:           pod2man
// 49:           ruby
// 50:           sqlite
// 51:           ssh-copy-id
// 52:           swift
// 53:           tcl-tk
// 54:           unifdef
// 55:           unzip
// 56:           whois
// 57:           zip
// 58:           zlib
// 59:         ].freeze
// 60:
// 61:         sig { override.params(formula_nodes: FormulaNodes).void }
// 62:         def audit_formula(formula_nodes)
// 63:           return if (body_node = formula_nodes.body_node).nil?
// 64:
// 65:           find_method_with_args(body_node, :keg_only, :provided_by_macos) do
// 66:             return if PROVIDED_BY_MACOS_FORMULAE.include? @formula_name
// 67:
// 68:             problem "Formulae that are `keg_only :provided_by_macos` should be " \
// 69:                     "added to the `PROVIDED_BY_MACOS_FORMULAE` list (in the Homebrew/brew repository)"
// 70:           end
// 71:         end
// 72:       end
// 73:
// 74:       # This cop audits `uses_from_macos` dependencies in formulae.
// 75:       class UsesFromMacos < FormulaCop
// 76:         # These formulae aren't `keg_only :provided_by_macos` but are provided by
// 77:         # macOS (or very similarly, e.g. OpenSSL where system provides LibreSSL).
// 78:         # TODO: consider making some of these keg-only.
// 79:         ALLOWED_USES_FROM_MACOS_DEPS = %w[
// 80:           bash
// 81:           cpio
// 82:           expect
// 83:           git
// 84:           groff
// 85:           gzip
// 86:           jq
// 87:           less
// 88:           mandoc
// 89:           openssl
// 90:           perl
// 91:           php
// 92:           python
// 93:           rsync
// 94:           vim
// 95:           xz
// 96:           zsh
// 97:         ].freeze
// 98:
// 99:         sig { override.params(formula_nodes: FormulaNodes).void }
// 100:         def audit_formula(formula_nodes)
// 101:           return if (body_node = formula_nodes.body_node).nil?
// 102:
// 103:           depends_on_linux = depends_on?(:linux)
// 104:
// 105:           find_method_with_args(body_node, :uses_from_macos, /^"(.+)"/).each do |method|
// 106:             @offensive_node = method
// 107:             problem "`uses_from_macos` should not be used when Linux is required." if depends_on_linux
// 108:
// 109:             first_argument = parameters(method).first
// 110:             dep = if first_argument.instance_of?(RuboCop::AST::StrNode)
// 111:               first_argument
// 112:             elsif first_argument.instance_of?(RuboCop::AST::HashNode)
// 113:               first_argument.keys.first
// 114:             end
// 115:
// 116:             dep_name = string_content(dep)
// 117:             next if ALLOWED_USES_FROM_MACOS_DEPS.include? dep_name
// 118:             next if ProvidedByMacos::PROVIDED_BY_MACOS_FORMULAE.include? dep_name
// 119:
// 120:             problem "`uses_from_macos` should only be used for macOS dependencies, not '#{dep_name}'."
// 121:           end
// 122:         end
// 123:       end
// 124:     end
// 125:   end
// 126: end
