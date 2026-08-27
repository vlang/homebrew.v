module rubocops

import brew_runtime

// Translated from Homebrew/brew `rubocops/uses_from_macos.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_formula(formula_nodes)` at line 62.
pub fn ruby_uses_from_macos_l62_d1_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
}

// Ruby method `audit_formula(formula_nodes)` at line 100.
pub fn ruby_uses_from_macos_l100_d2_audit_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_formula', ...args)
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
