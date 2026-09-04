module cask

import ruby
import rand

// Translated from Homebrew/brew `cask/auditor.rb`.
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

fn auditor_nil() ruby.Value {
	return ruby.Value{
		type_name: 'NilClass'
		repr: 'nil'
	}
}

fn auditor_optional_bool(value ?bool) ruby.Value {
	resolved := value or { return auditor_nil() }
	return ruby.bool_value(resolved)
}

fn auditor_error_value(problem AuditError) ruby.Value {
	return ruby.map_value({
		'message':   ruby.string_value(problem.message)
		'location':  if problem.location == '' {
			auditor_nil()
		} else {
			ruby.string_value(problem.location)
		}
		'corrected': ruby.bool_value(problem.corrected)
	})
}

fn auditor_error_set_value(errors []AuditError) ruby.Value {
	return ruby.Value{
		type_name: 'Set'
		repr: errors.map(it.message).str()
		array_data: errors.map(auditor_error_value(it))
	}
}

fn auditor_language_block_value(block AuditorLanguageBlock) ruby.Value {
	mut values := {
		'languages': ruby.string_array_value(block.languages)
	}
	if block.has_cask {
		values['cask'] = audit_cask_boundary(block.cask)
	}
	return ruby.map_value(values)
}

fn auditor_boundary_value(auditor CaskAuditor) ruby.Value {
	base_cask_value := audit_cask_boundary(auditor.cask)
	mut cask_data := base_cask_value.map_data.clone()
	cask_data['language_blocks'] = ruby.array_value(auditor.language_entries.map(auditor_language_block_value(it)))
	cask_value := ruby.Value{
		...base_cask_value
		map_data: cask_data
	}
	return ruby.Value{
		type_name: 'Cask::Auditor'
		repr: auditor.cask.token
		map_data: {
			'cask':              cask_value
			'audit_download':    ruby.bool_value(auditor.audit_download)
			'audit_online':      auditor_optional_bool(auditor.audit_online)
			'audit_strict':      auditor_optional_bool(auditor.audit_strict)
			'audit_signing':     auditor_optional_bool(auditor.audit_signing)
			'audit_new_cask':    auditor_optional_bool(auditor.audit_new_cask)
			'any_named_args':    ruby.bool_value(auditor.any_named_args)
			'language':          if auditor.language_set {
				ruby.string_value(auditor.language)
			} else {
				auditor_nil()
			}
			'only':              ruby.string_array_value(auditor.only)
			'except':            ruby.string_array_value(auditor.except)
			'output_lines':      ruby.string_array_value(auditor.output_lines)
			'audited_languages': ruby.array_value(auditor.audited_languages.map(ruby.string_array_value(it)))
		}
	}
}

fn auditor_value_bool(values map[string]ruby.Value, key string, fallback bool) bool {
	return if value := values[key] { value.as_bool() or { fallback } } else { fallback }
}

fn auditor_optional_bool_from_value(values map[string]ruby.Value, key string) ?bool {
	value := values[key] or { return none }
	if value.type_name == 'NilClass' || value.type_name == 'Nil' {
		return none
	}
	return value.as_bool() or { return none }
}

fn auditor_optional_bool_alias(values map[string]ruby.Value, primary string, fallback string) ?bool {
	if primary in values {
		return auditor_optional_bool_from_value(values, primary)
	}
	return auditor_optional_bool_from_value(values, fallback)
}

fn auditor_language_blocks_from_value(cask_value ruby.Value) []AuditorLanguageBlock {
	values := cask_value.as_map() or { return []AuditorLanguageBlock{} }
	raw_blocks := values['language_blocks'] or { return []AuditorLanguageBlock{} }
	mut blocks := []AuditorLanguageBlock{}
	for raw in raw_blocks.as_array() or { []ruby.Value{} } {
		block_values := raw.as_map() or { continue }
		languages := (block_values['languages'] or { ruby.string_array_value([]) }).as_string_array() or {
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

fn auditor_options_from_value(cask_value ruby.Value, value ruby.Value) AuditorOptions {
	values := value.as_map() or { map[string]ruby.Value{} }
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
		only: (values['only'] or { ruby.string_array_value([]) }).as_string_array() or {
			[]string{}
		}
		except: (values['except'] or { ruby.string_array_value([]) }).as_string_array() or {
			[]string{}
		}
		language_blocks: auditor_language_blocks_from_value(cask_value)
	}
}

fn auditor_from_value(value ruby.Value) CaskAuditor {
	if value.type_name == 'Cask::Auditor' {
		values := value.map_data.clone()
		cask_value := values['cask'] or { ruby.string_value(value.as_string()) }
		return new_cask_auditor(audit_cask_from_value(cask_value), auditor_options_from_value(cask_value, ruby.map_value(values)))
	}
	return new_cask_auditor(audit_cask_from_value(value), auditor_options_from_value(value, ruby.map_value({})))
}

fn auditor_from_args(args []ruby.Value) CaskAuditor {
	if args.len > 0 && args[0].type_name == 'Cask::Auditor' {
		return auditor_from_value(args[0])
	}
	cask_value := if args.len > 0 { args[0] } else { ruby.string_value('') }
	options_value := if args.len > 1 { args[1] } else { ruby.map_value({}) }
	return new_cask_auditor(audit_cask_from_value(cask_value), auditor_options_from_value(cask_value, options_value))
}
