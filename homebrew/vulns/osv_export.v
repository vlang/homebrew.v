module vulns

import net.urllib
import os
import x.json2

// Translated from Homebrew/brew `vulns/osv_export.rb`.
pub const osv_export_schema_version = '1.7.3'
pub const osv_export_ecosystem = 'Homebrew'
pub const osv_export_id_prefix = 'BREW'

pub struct OsvExportResolve {
pub:
	resolve_type string @[json: 'type']
	id           string
}

pub struct OsvExportPatch {
pub:
	patch_type string @[json: 'type'; omitempty]
	url        string @[omitempty]
	file       string @[omitempty]
	apply      []string @[omitempty]
	resolves   []OsvExportResolve @[omitempty]
}

pub struct OsvExportFormula {
pub:
	name               string
	pkg_version        string
	serialized_patches []OsvExportPatch
}

pub struct OsvExportAnnotated {
pub:
	formula OsvExportFormula
	patches []OsvExportPatch
}

pub struct OsvExportReference {
pub:
	reference_type string @[json: 'type']
	url            string
}

pub struct OsvExportSeverity {
pub:
	severity_type string @[json: 'type']
	score         string
}

pub struct OsvExportUpstream {
pub:
	summary    ?string @[omitempty]
	details    ?string @[omitempty]
	aliases    []string @[omitempty]
	severity   []OsvExportSeverity @[omitempty]
	references []OsvExportReference @[omitempty]
}

pub struct OsvExportPatchRef {
pub:
	patch_type string @[json: 'type'; omitempty]
	url        string @[omitempty]
	file       string @[omitempty]
	apply      []string @[omitempty]
}

pub struct OsvExportPackage {
pub:
	ecosystem string
	name      string
	purl      string
}

pub struct OsvExportEvent {
pub:
	introduced string @[omitempty]
	fixed      string @[omitempty]
}

pub struct OsvExportRange {
pub:
	range_type string @[json: 'type']
	events     []OsvExportEvent
}

pub struct OsvExportEcosystemSpecific {
pub:
	fix     string
	patches []OsvExportPatchRef
}

pub struct OsvExportAffected {
pub mut:
	package            OsvExportPackage
	ranges             []OsvExportRange
	ecosystem_specific OsvExportEcosystemSpecific
}

pub struct OsvExportDatabaseSpecific {
pub:
	source string
}

pub struct OsvExportRecord {
pub mut:
	schema_version    string
	id                string
	published         string
	modified          string
	upstream          []string
	affected          []OsvExportAffected
	database_specific OsvExportDatabaseSpecific
	summary           ?string @[omitempty]
	details           ?string @[omitempty]
	severity          []OsvExportSeverity @[omitempty]
	references        []OsvExportReference @[omitempty]
}

pub type OsvExportFetch = fn (string) !OsvExportUpstream

pub type OsvExportFirstFixed = fn (OsvExportFormula, string) ?string

pub struct OsvExportRunOptions {
pub:
	now         string
	fetch       OsvExportFetch @[required]
	first_fixed ?OsvExportFirstFixed
}

fn osv_export_resolved_ids(patches []OsvExportPatch) []string {
	mut result := []string{}
	for patch in patches {
		for resolved in patch.resolves {
			if resolved.resolve_type != 'security' {
				continue
			}
			id := resolved.id.to_upper()
			if id !in result {
				result << id
			}
		}
	}
	return result
}

fn osv_export_canonical(value json2.Any, ignore_modified bool) string {
	if value is map[string]json2.Any {
		mut keys := value.keys()
		keys.sort()
		mut parts := []string{}
		for key in keys {
			if ignore_modified && key == 'modified' {
				continue
			}
			current := value[key] or { continue }
			// Ruby's `except("modified")` applies only to the record itself; a
			// nested field with the same name remains part of the comparison.
			parts << '${json2.encode(key)}:${osv_export_canonical(current, false)}'
		}
		return '{${parts.join(',')}}'
	}
	if value is []json2.Any {
		mut parts := []string{}
		for item in value {
			parts << osv_export_canonical(item, false)
		}
		return '[${parts.join(',')}]'
	}
	return json2.encode(value)
}

pub fn osv_export_run(annotated []OsvExportAnnotated, dir string, options OsvExportRunOptions) ![]string {
	os.mkdir_all(dir)!
	mut written := []string{}
	mut upstream_cache := map[string]OsvExportUpstream{}
	mut failed := map[string]bool{}
	for item in annotated {
		for vuln_id in osv_export_resolved_ids(item.patches) {
			if vuln_id !in upstream_cache && vuln_id !in failed {
				upstream_cache[vuln_id] = options.fetch(vuln_id) or {
					failed[vuln_id] = true
					OsvExportUpstream{}
				}
			}
			path := os.join_path(dir, '${osv_export_id_prefix}-${item.formula.name}-${vuln_id}.json')
			existing := os.is_file(path)
			if failed[vuln_id] && existing {
				continue
			}
			mut fixed := item.formula.pkg_version
			if !existing {
				if callback := options.first_fixed {
					if boundary := callback(item.formula, vuln_id) {
						fixed = boundary
					}
				}
			}
			upstream := if failed[vuln_id] { none } else { upstream_cache[vuln_id] }
			record := osv_export_record_for(item.formula, vuln_id, item.patches, fixed, upstream, options.now)
			merged := osv_export_merge_existing(path, record) or { continue }
			os.write_file(path, '${json2.encode(merged, prettify: true)}\n')!
			written << path
		}
	}
	return written
}

pub fn osv_export_merge_existing(path string, record OsvExportRecord) ?OsvExportRecord {
	if !os.is_file(path) {
		return record
	}
	contents := os.read_file(path) or { return record }
	mut existing := json2.decode[OsvExportRecord](contents) or { return record }
	mut merged := record
	mut affected := record.affected.clone()
	if existing.published != '' {
		merged.published = existing.published
	} else if existing.modified != '' {
		merged.published = existing.modified
	}
	for index in 0 .. affected.len {
		if index < existing.affected.len {
			mut current := affected[index]
			current.ranges = existing.affected[index].ranges.clone()
			affected[index] = current
		}
	}
	merged.affected = affected
	existing_value := json2.decode[json2.Any](contents) or { return merged }
	merged_value := json2.decode[json2.Any](json2.encode(merged)) or { return merged }
	if osv_export_canonical(existing_value, true) == osv_export_canonical(merged_value, true) {
		return none
	}
	return merged
}

pub fn osv_export_record_for(formula OsvExportFormula, vuln_id string,
	patches []OsvExportPatch, fixed string, upstream ?OsvExportUpstream,
	now string) OsvExportRecord {
	mut record := OsvExportRecord{
		schema_version: osv_export_schema_version
		id: '${osv_export_id_prefix}-${formula.name}-${vuln_id}'
		published: now
		modified: now
		upstream: [vuln_id]
		affected: [osv_export_affected_entry(formula, vuln_id, patches, fixed)]
		database_specific: OsvExportDatabaseSpecific{
			source: 'generated'
		}
	}
	if details := upstream {
		record.summary = details.summary
		record.details = details.details
		record.severity = details.severity.clone()
		mut ids := [vuln_id]
		for alias in details.aliases {
			if alias !in ids {
				ids << alias
			}
		}
		record.upstream = ids
		mut seen := map[string]bool{}
		for reference in details.references {
			// RFC 2396 decoding leaves literal `+` intact; query decoding would
			// incorrectly turn it into a space and miss equivalent `%2B` URLs.
			decoded := urllib.path_unescape(reference.url) or { reference.url }
			key := '${reference.reference_type}\x00${decoded}'
			if key !in seen {
				seen[key] = true
				record.references << reference
			}
		}
	}
	return record
}

pub fn osv_export_affected_entry(formula OsvExportFormula, vuln_id string,
	patches []OsvExportPatch, fixed string) OsvExportAffected {
	mut refs := []OsvExportPatchRef{}
	for patch in osv_export_patches_resolving(patches, vuln_id) {
		if reference := osv_export_patch_ref(patch) {
			refs << reference
		}
	}
	return OsvExportAffected{
		package: OsvExportPackage{
			ecosystem: osv_export_ecosystem
			name: formula.name
			purl: osv_export_purl(formula.name)
		}
		ranges: [OsvExportRange{
			range_type: 'ECOSYSTEM'
			events: [OsvExportEvent{
				introduced: '0'
			}, OsvExportEvent{
				fixed: fixed
			}]
		}]
		ecosystem_specific: OsvExportEcosystemSpecific{
			fix: 'patch'
			patches: refs
		}
	}
}

pub fn osv_export_purl(name string) string {
	return 'pkg:brew/${name.replace('@', '%40').replace('+', '%2B')}'
}

pub fn osv_export_patches_resolving(patches []OsvExportPatch,
	vuln_id string) []OsvExportPatch {
	target := vuln_id.to_upper()
	mut matches := []OsvExportPatch{}
	for patch in patches {
		for resolved in patch.resolves {
			if resolved.resolve_type == 'security' && resolved.id.to_upper() == target {
				matches << patch
				break
			}
		}
	}
	return matches
}

pub fn osv_export_patch_ref(patch OsvExportPatch) ?OsvExportPatchRef {
	if patch.patch_type == '' && patch.url == '' && patch.file == '' && patch.apply.len == 0 {
		return none
	}
	return OsvExportPatchRef{
		patch_type: patch.patch_type
		url: patch.url
		file: patch.file
		apply: patch.apply.clone()
	}
}

pub fn osv_export_fetch_upstream(vuln_id string, fetch OsvExportFetch) !OsvExportUpstream {
	return fetch(vuln_id)
}
