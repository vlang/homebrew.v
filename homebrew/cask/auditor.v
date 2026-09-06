module cask

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
