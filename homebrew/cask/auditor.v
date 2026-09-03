module cask

import brew_runtime
import rand

// Translated from Homebrew/brew `cask/auditor.rb`.
// The original source is retained below until every stub has a typed V body.
const auditor_language_block_limit = 10

pub struct AuditorLanguageBlock {
pub:
	languages []string
	cask      AuditCask
	has_cask  bool
}

pub struct AuditorOptions {
pub:
	audit_download  bool
	audit_online    ?bool
	audit_strict    ?bool
	audit_signing   ?bool
	audit_new_cask  ?bool
	any_named_args  bool
	language        string
	language_set    bool
	only            []string
	except          []string
	language_blocks []AuditorLanguageBlock
	providers       AuditCollaborators
}

pub struct CaskAuditor {
pub:
	cask             AuditCask
	audit_download   bool
	audit_online     ?bool
	audit_strict     ?bool
	audit_signing    ?bool
	audit_new_cask   ?bool
	any_named_args   bool
	language         string
	language_set     bool
	only             []string
	except           []string
	language_entries []AuditorLanguageBlock
	providers        AuditCollaborators
pub mut:
	output_lines      []string
	audited_languages [][]string
}

pub fn new_cask_auditor(cask AuditCask, options AuditorOptions) CaskAuditor {
	return CaskAuditor{
		cask: cask
		audit_download: options.audit_download
		audit_online: options.audit_online
		audit_strict: options.audit_strict
		audit_signing: options.audit_signing
		audit_new_cask: options.audit_new_cask
		any_named_args: options.any_named_args
		language: options.language
		language_set: options.language_set
		only: options.only.clone()
		except: options.except.clone()
		language_entries: options.language_blocks.clone()
		providers: options.providers
	}
}

fn auditor_strict(auditor CaskAuditor) bool {
	return auditor.audit_strict or { false }
}

fn auditor_new_cask(auditor CaskAuditor) bool {
	return auditor.audit_new_cask or { false }
}

pub fn (auditor CaskAuditor) output_summary(audit ?CaskAudit) bool {
	if auditor.any_named_args || auditor_strict(auditor) {
		return true
	}
	resolved := audit or { return false }
	return resolved.errors_present()
}

pub fn (auditor CaskAuditor) language_blocks() []AuditorLanguageBlock {
	return auditor.language_entries.clone()
}

pub fn (auditor CaskAuditor) audit_cask_instance(cask AuditCask) CaskAudit {
	mut audit := new_cask_audit(cask, AuditOptions{
		download: auditor.audit_download
		online: auditor.audit_online
		strict: auditor.audit_strict
		signing: auditor.audit_signing
		new_cask: auditor.audit_new_cask
		only: auditor.only.clone()
		except: auditor.except.clone()
	}, auditor.providers)
	audit.run()
	return audit
}

pub fn (auditor CaskAuditor) audit_languages(block AuditorLanguageBlock) CaskAudit {
	base := if block.has_cask { block.cask } else { auditor.cask }
	localized := AuditCask{
		...base
		languages: block.languages.clone()
	}
	return auditor.audit_cask_instance(localized)
}

fn auditor_error_equal(left AuditError, right AuditError) bool {
	return left.message == right.message && left.location == right.location
		&& left.corrected == right.corrected
}

fn auditor_add_errors(mut destination []AuditError, additions []AuditError) {
	for problem in additions {
		if destination.any(auditor_error_equal(it, problem)) {
			continue
		}
		destination << problem
	}
}

fn auditor_to_sentence(values []string) string {
	if values.len == 0 {
		return ''
	}
	if values.len == 1 {
		return values[0]
	}
	if values.len == 2 {
		return '${values[0]} and ${values[1]}'
	}
	return '${values[..values.len - 1].join(', ')}, and ${values.last()}'
}

fn auditor_sample_language_blocks(blocks []AuditorLanguageBlock) []AuditorLanguageBlock {
	mut shuffled := blocks.clone()
	rand.shuffle(mut shuffled) or { return blocks[..auditor_language_block_limit].clone() }
	return shuffled[..auditor_language_block_limit].clone()
}

pub fn (mut auditor CaskAuditor) audit() []AuditError {
	mut errors := []AuditError{}
	auditor.output_lines = []string{}
	auditor.audited_languages = [][]string{}
	blocks := auditor.language_blocks()
	if !auditor.language_set && blocks.len > 0 {
		sample_languages := if blocks.len > auditor_language_block_limit && !auditor_new_cask(auditor) {
			auditor_sample_language_blocks(blocks)
		} else {
			blocks
		}
		if blocks.len > auditor_language_block_limit && !auditor_new_cask(auditor) {
			language_names := sample_languages.map(it.languages[0])
			auditor.output_lines << 'Auditing a sample of available languages for ${auditor.cask.token}: ${auditor_to_sentence(language_names)}'
		}
		for block in sample_languages {
			auditor.audited_languages << block.languages.clone()
			language_audit := auditor.audit_languages(block)
			if summary := language_audit.summary_text() {
				if auditor.output_summary(language_audit) {
					if auditor.output_summary(none) {
						quoted := block.languages.map("'${it}'")
						auditor.output_lines << 'Auditing language: ${auditor_to_sentence(quoted)}'
					}
					auditor.output_lines << summary
				}
			}
			auditor_add_errors(mut errors, language_audit.errors)
		}
	} else {
		direct_audit := auditor.audit_cask_instance(auditor.cask)
		if summary := direct_audit.summary_text() {
			if auditor.output_summary(direct_audit) {
				auditor.output_lines << summary
			}
		}
		auditor_add_errors(mut errors, direct_audit.errors)
	}
	return errors
}

fn auditor_nil() brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'NilClass'
		repr: 'nil'
	}
}

fn auditor_optional_bool(value ?bool) brew_runtime.Value {
	resolved := value or { return auditor_nil() }
	return brew_runtime.bool_value(resolved)
}

fn auditor_error_value(problem AuditError) brew_runtime.Value {
	return brew_runtime.map_value({
		'message':   brew_runtime.string_value(problem.message)
		'location':  if problem.location == '' {
			auditor_nil()
		} else {
			brew_runtime.string_value(problem.location)
		}
		'corrected': brew_runtime.bool_value(problem.corrected)
	})
}

fn auditor_error_set_value(errors []AuditError) brew_runtime.Value {
	return brew_runtime.Value{
		type_name: 'Set'
		repr: errors.map(it.message).str()
		array_data: errors.map(auditor_error_value(it))
	}
}

fn auditor_language_block_value(block AuditorLanguageBlock) brew_runtime.Value {
	mut values := {
		'languages': brew_runtime.string_array_value(block.languages)
	}
	if block.has_cask {
		values['cask'] = audit_cask_boundary(block.cask)
	}
	return brew_runtime.map_value(values)
}

fn auditor_boundary_value(auditor CaskAuditor) brew_runtime.Value {
	base_cask_value := audit_cask_boundary(auditor.cask)
	mut cask_data := base_cask_value.map_data.clone()
	cask_data['language_blocks'] = brew_runtime.array_value(auditor.language_entries.map(auditor_language_block_value(it)))
	cask_value := brew_runtime.Value{
		...base_cask_value
		map_data: cask_data
	}
	return brew_runtime.Value{
		type_name: 'Cask::Auditor'
		repr: auditor.cask.token
		map_data: {
			'cask':              cask_value
			'audit_download':    brew_runtime.bool_value(auditor.audit_download)
			'audit_online':      auditor_optional_bool(auditor.audit_online)
			'audit_strict':      auditor_optional_bool(auditor.audit_strict)
			'audit_signing':     auditor_optional_bool(auditor.audit_signing)
			'audit_new_cask':    auditor_optional_bool(auditor.audit_new_cask)
			'any_named_args':    brew_runtime.bool_value(auditor.any_named_args)
			'language':          if auditor.language_set {
				brew_runtime.string_value(auditor.language)
			} else {
				auditor_nil()
			}
			'only':              brew_runtime.string_array_value(auditor.only)
			'except':            brew_runtime.string_array_value(auditor.except)
			'output_lines':      brew_runtime.string_array_value(auditor.output_lines)
			'audited_languages': brew_runtime.array_value(auditor.audited_languages.map(brew_runtime.string_array_value(it)))
		}
	}
}

fn auditor_value_bool(values map[string]brew_runtime.Value, key string, fallback bool) bool {
	return if value := values[key] { value.as_bool() or { fallback } } else { fallback }
}

fn auditor_optional_bool_from_value(values map[string]brew_runtime.Value, key string) ?bool {
	value := values[key] or { return none }
	if value.type_name == 'NilClass' || value.type_name == 'Nil' {
		return none
	}
	return value.as_bool() or { return none }
}

fn auditor_optional_bool_alias(values map[string]brew_runtime.Value, primary string, fallback string) ?bool {
	if primary in values {
		return auditor_optional_bool_from_value(values, primary)
	}
	return auditor_optional_bool_from_value(values, fallback)
}

fn auditor_language_blocks_from_value(cask_value brew_runtime.Value) []AuditorLanguageBlock {
	values := cask_value.as_map() or { return []AuditorLanguageBlock{} }
	raw_blocks := values['language_blocks'] or { return []AuditorLanguageBlock{} }
	mut blocks := []AuditorLanguageBlock{}
	for raw in raw_blocks.as_array() or { []brew_runtime.Value{} } {
		block_values := raw.as_map() or { continue }
		languages := (block_values['languages'] or { brew_runtime.string_array_value([]) }).as_string_array() or {
			[]string{}
		}
		if localized := block_values['cask'] {
			blocks << AuditorLanguageBlock{
				languages: languages
				cask: audit_cask_from_value(localized)
				has_cask: true
			}
		} else {
			blocks << AuditorLanguageBlock{
				languages: languages
			}
		}
	}
	return blocks
}

fn auditor_options_from_value(cask_value brew_runtime.Value, value brew_runtime.Value) AuditorOptions {
	values := value.as_map() or { map[string]brew_runtime.Value{} }
	language_value := values['language'] or { auditor_nil() }
	return AuditorOptions{
		audit_download: auditor_value_bool(values, 'audit_download', auditor_value_bool(values, 'download', false))
		audit_online: auditor_optional_bool_alias(values, 'audit_online', 'online')
		audit_strict: auditor_optional_bool_alias(values, 'audit_strict', 'strict')
		audit_signing: auditor_optional_bool_alias(values, 'audit_signing', 'signing')
		audit_new_cask: auditor_optional_bool_alias(values, 'audit_new_cask', 'new_cask')
		any_named_args: auditor_value_bool(values, 'any_named_args', false)
		language: language_value.as_string()
		language_set: language_value.type_name !in ['NilClass', 'Nil']
		only: (values['only'] or { brew_runtime.string_array_value([]) }).as_string_array() or {
			[]string{}
		}
		except: (values['except'] or { brew_runtime.string_array_value([]) }).as_string_array() or {
			[]string{}
		}
		language_blocks: auditor_language_blocks_from_value(cask_value)
	}
}

fn auditor_from_value(value brew_runtime.Value) CaskAuditor {
	if value.type_name == 'Cask::Auditor' {
		values := value.map_data.clone()
		cask_value := values['cask'] or { brew_runtime.string_value(value.as_string()) }
		return new_cask_auditor(audit_cask_from_value(cask_value), auditor_options_from_value(cask_value, brew_runtime.map_value(values)))
	}
	return new_cask_auditor(audit_cask_from_value(value), auditor_options_from_value(value, brew_runtime.map_value({})))
}

fn auditor_from_args(args []brew_runtime.Value) CaskAuditor {
	if args.len > 0 && args[0].type_name == 'Cask::Auditor' {
		return auditor_from_value(args[0])
	}
	cask_value := if args.len > 0 { args[0] } else { brew_runtime.string_value('') }
	options_value := if args.len > 1 { args[1] } else { brew_runtime.map_value({}) }
	return new_cask_auditor(audit_cask_from_value(cask_value), auditor_options_from_value(cask_value, options_value))
}

// Ruby method `self.audit(` at line 21.
pub fn ruby_auditor_l21_d1_self_audit(args ...brew_runtime.Value) brew_runtime.Value {
	mut auditor := auditor_from_args(args)
	return auditor_error_set_value(auditor.audit())
}

// Ruby attr_reader `attr_reader :cask` at line 33.
pub fn ruby_auditor_l33_d2_cask(args ...brew_runtime.Value) brew_runtime.Value {
	auditor := auditor_from_args(args)
	return audit_cask_boundary(auditor.cask)
}

// Ruby attr_reader `attr_reader :language` at line 36.
pub fn ruby_auditor_l36_d3_language(args ...brew_runtime.Value) brew_runtime.Value {
	auditor := auditor_from_args(args)
	return if auditor.language_set {
		brew_runtime.string_value(auditor.language)
	} else {
		auditor_nil()
	}
}

// Ruby method `initialize(` at line 46.
pub fn ruby_auditor_l46_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return auditor_boundary_value(auditor_from_args(args))
}

// Ruby method `audit` at line 73.
pub fn ruby_auditor_l73_d5_audit(args ...brew_runtime.Value) brew_runtime.Value {
	mut auditor := auditor_from_args(args)
	return auditor_error_set_value(auditor.audit())
}

// Ruby method `output_summary?(audit = nil)` at line 104.
pub fn ruby_auditor_l104_d6_output_summary(args ...brew_runtime.Value) brew_runtime.Value {
	auditor := auditor_from_args(args)
	if args.len < 2 || args[1].type_name in ['NilClass', 'Nil'] {
		return brew_runtime.bool_value(auditor.output_summary(none))
	}
	return brew_runtime.bool_value(auditor.output_summary(audit_from_value(args[1])))
}

// Ruby method `audit_languages(languages)` at line 115.
pub fn ruby_auditor_l115_d7_audit_languages(args ...brew_runtime.Value) brew_runtime.Value {
	auditor := auditor_from_args(args)
	languages := if args.len > 1 { args[1].as_string_array() or { []string{} } } else { []string{} }
	mut block := AuditorLanguageBlock{
		languages: languages
	}
	for candidate in auditor.language_blocks() {
		if candidate.languages == languages {
			block = candidate
			break
		}
	}
	mut audit := auditor.audit_languages(block)
	return audit_boundary_value(audit)
}

// Ruby method `audit_cask_instance(cask)` at line 128.
pub fn ruby_auditor_l128_d8_audit_cask_instance(args ...brew_runtime.Value) brew_runtime.Value {
	auditor := auditor_from_args(args)
	cask := if args.len > 1 { audit_cask_from_value(args[1]) } else { auditor.cask }
	mut audit := auditor.audit_cask_instance(cask)
	return audit_boundary_value(audit)
}

// Ruby method `language_blocks` at line 143.
pub fn ruby_auditor_l143_d9_language_blocks(args ...brew_runtime.Value) brew_runtime.Value {
	auditor := auditor_from_args(args)
	return brew_runtime.array_value(auditor.language_blocks().map(auditor_language_block_value(it)))
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
