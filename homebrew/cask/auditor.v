module cask

import brew_runtime

// Translated from Homebrew/brew `cask/auditor.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.audit(` at line 21.
pub fn ruby_auditor_l21_d1_self_audit(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.audit', ...args)
}

// Ruby attr_reader `attr_reader :cask` at line 33.
pub fn ruby_auditor_l33_d2_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask', ...args)
}

// Ruby attr_reader `attr_reader :language` at line 36.
pub fn ruby_auditor_l36_d3_language(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('language', ...args)
}

// Ruby method `initialize(` at line 46.
pub fn ruby_auditor_l46_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `audit` at line 73.
pub fn ruby_auditor_l73_d5_audit(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit', ...args)
}

// Ruby method `output_summary?(audit = nil)` at line 104.
pub fn ruby_auditor_l104_d6_output_summary(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('output_summary?', ...args)
}

// Ruby method `audit_languages(languages)` at line 115.
pub fn ruby_auditor_l115_d7_audit_languages(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_languages', ...args)
}

// Ruby method `audit_cask_instance(cask)` at line 128.
pub fn ruby_auditor_l128_d8_audit_cask_instance(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_cask_instance', ...args)
}

// Ruby method `language_blocks` at line 143.
pub fn ruby_auditor_l143_d9_language_blocks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('language_blocks', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cask/audit"
// 5: require "utils/output"
// 6:
// 7: module Cask
// 8:   # Helper class for auditing all available languages of a cask.
// 9:   class Auditor
// 10:     include ::Utils::Output::Mixin
// 11:
// 12:     # TODO: use argument forwarding (...) when Sorbet supports it in strict mode
// 13:     sig {
// 14:       params(
// 15:         cask: ::Cask::Cask, audit_download: T::Boolean, audit_online: T.nilable(T::Boolean),
// 16:         audit_strict: T.nilable(T::Boolean), audit_signing: T.nilable(T::Boolean),
// 17:         audit_new_cask: T.nilable(T::Boolean),
// 18:         any_named_args: T::Boolean, language: T.nilable(String), only: T::Array[String], except: T::Array[String]
// 19:       ).returns(T::Set[Audit::Error])
// 20:     }
// 21:     def self.audit(
// 22:       cask, audit_download: false, audit_online: nil, audit_strict: nil, audit_signing: nil,
// 23:       audit_new_cask: nil, any_named_args: false, language: nil,
// 24:       only: [], except: []
// 25:     )
// 26:       new(
// 27:         cask, audit_download:, audit_online:, audit_strict:, audit_signing:,
// 28:         audit_new_cask:, any_named_args:, language:, only:, except:
// 29:       ).audit
// 30:     end
// 31:
// 32:     sig { returns(::Cask::Cask) }
// 33:     attr_reader :cask
// 34:
// 35:     sig { returns(T.nilable(String)) }
// 36:     attr_reader :language
// 37:
// 38:     sig {
// 39:       params(
// 40:         cask: ::Cask::Cask, audit_download: T::Boolean, audit_online: T.nilable(T::Boolean),
// 41:         audit_strict: T.nilable(T::Boolean), audit_signing: T.nilable(T::Boolean),
// 42:         audit_new_cask: T.nilable(T::Boolean),
// 43:         any_named_args: T::Boolean, language: T.nilable(String), only: T::Array[String], except: T::Array[String]
// 44:       ).void
// 45:     }
// 46:     def initialize(
// 47:       cask,
// 48:       audit_download: false,
// 49:       audit_online: nil,
// 50:       audit_strict: nil,
// 51:       audit_signing: nil,
// 52:       audit_new_cask: nil,
// 53:       any_named_args: false,
// 54:       language: nil,
// 55:       only: [],
// 56:       except: []
// 57:     )
// 58:       @cask = cask
// 59:       @audit_download = audit_download
// 60:       @audit_online = audit_online
// 61:       @audit_new_cask = audit_new_cask
// 62:       @audit_strict = audit_strict
// 63:       @audit_signing = audit_signing
// 64:       @any_named_args = any_named_args
// 65:       @language = language
// 66:       @only = only
// 67:       @except = except
// 68:     end
// 69:
// 70:     LANGUAGE_BLOCK_LIMIT = 10
// 71:
// 72:     sig { returns(T::Set[Audit::Error]) }
// 73:     def audit
// 74:       errors = Set.new
// 75:
// 76:       if !language && !(blocks = language_blocks).empty?
// 77:         sample_languages = if blocks.length > LANGUAGE_BLOCK_LIMIT && !@audit_new_cask
// 78:           sample_keys = T.must(blocks.keys.sample(LANGUAGE_BLOCK_LIMIT))
// 79:           ohai "Auditing a sample of available languages for #{cask}: " \
// 80:                "#{sample_keys.map { |lang| lang[0].to_s }.to_sentence}"
// 81:           blocks.select { |k| sample_keys.include?(k) }
// 82:         else
// 83:           blocks
// 84:         end
// 85:
// 86:         sample_languages.each_key do |l|
// 87:           audit = audit_languages(l)
// 88:           if audit.summary.present? && output_summary?(audit)
// 89:             ohai "Auditing language: #{l.map { |lang| "'#{lang}'" }.to_sentence}" if output_summary?
// 90:             puts audit.summary
// 91:           end
// 92:           errors += audit.errors
// 93:         end
// 94:       else
// 95:         audit = audit_cask_instance(cask)
// 96:         puts audit.summary if audit.summary.present? && output_summary?(audit)
// 97:         errors += audit.errors
// 98:       end
// 99:
// 100:       errors
// 101:     end
// 102:
// 103:     sig { params(audit: T.nilable(Audit)).returns(T::Boolean) }
// 104:     def output_summary?(audit = nil)
// 105:       return true if @any_named_args
// 106:       return true if @audit_strict
// 107:       return false if audit.nil?
// 108:
// 109:       audit.errors?
// 110:     end
// 111:
// 112:     private
// 113:
// 114:     sig { params(languages: T::Array[String]).returns(::Cask::Audit) }
// 115:     def audit_languages(languages)
// 116:       original_config = cask.config
// 117:       begin
// 118:         localized_config = original_config.merge(Config.new(explicit: { languages: }))
// 119:         cask.config = localized_config
// 120:
// 121:         audit_cask_instance(cask)
// 122:       ensure
// 123:         cask.config = original_config
// 124:       end
// 125:     end
// 126:
// 127:     sig { params(cask: ::Cask::Cask).returns(::Cask::Audit) }
// 128:     def audit_cask_instance(cask)
// 129:       audit = Audit.new(
// 130:         cask,
// 131:         online:   @audit_online,
// 132:         strict:   @audit_strict,
// 133:         signing:  @audit_signing,
// 134:         new_cask: @audit_new_cask,
// 135:         download: @audit_download,
// 136:         only:     @only,
// 137:         except:   @except,
// 138:       )
// 139:       audit.run!
// 140:     end
// 141:
// 142:     sig { returns(T::Hash[T::Array[String], T.proc.returns(T.untyped)]) }
// 143:     def language_blocks
// 144:       cask.instance_variable_get(:@dsl).instance_variable_get(:@language_blocks)
// 145:     end
// 146:   end
// 147: end
