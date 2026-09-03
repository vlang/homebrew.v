module vulns

import net.urllib
import os
import x.json2

// Translated from Homebrew/brew `vulns/osv_export.rb`.
// The original source is retained below until every stub has a typed V body.
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

pub type OsvExportFetch = fn(string) !OsvExportUpstream

pub type OsvExportFirstFixed = fn(OsvExportFormula, string) ?string

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
			key := '${reference.reference_type}\0${decoded}'
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

// Ruby method `self.run(annotated, dir, first_fixed: nil, now: Time.now.utc)` at line 54.
pub fn ruby_osv_export_l54_d1_self_run(annotated []OsvExportAnnotated, dir string,
	options OsvExportRunOptions) ![]string {
	return osv_export_run(annotated, dir, options)
}

// Ruby method `self.merge_existing(path, record)` at line 91.
pub fn ruby_osv_export_l91_d2_self_merge_existing(path string,
	record OsvExportRecord) ?OsvExportRecord {
	return osv_export_merge_existing(path, record)
}

// Ruby method `self.record_for(formula, vuln_id, patches: formula.serialized_patches,` at line 121.
pub fn ruby_osv_export_l121_d3_self_record_for(formula OsvExportFormula, vuln_id string,
	patches []OsvExportPatch, fixed string, upstream ?OsvExportUpstream,
	now string) OsvExportRecord {
	return osv_export_record_for(formula, vuln_id, patches, fixed, upstream, now)
}

// Ruby method `self.affected_entry(formula, vuln_id, patches, fixed)` at line 157.
pub fn ruby_osv_export_l157_d4_self_affected_entry(formula OsvExportFormula, vuln_id string,
	patches []OsvExportPatch, fixed string) OsvExportAffected {
	return osv_export_affected_entry(formula, vuln_id, patches, fixed)
}

// Ruby method `self.purl(name)` at line 185.
pub fn ruby_osv_export_l185_d5_self_purl(name string) string {
	return osv_export_purl(name)
}

// Ruby method `self.patches_resolving(serialized_patches, vuln_id)` at line 193.
pub fn ruby_osv_export_l193_d6_self_patches_resolving(patches []OsvExportPatch,
	vuln_id string) []OsvExportPatch {
	return osv_export_patches_resolving(patches, vuln_id)
}

// Ruby method `self.patch_ref(patch)` at line 203.
pub fn ruby_osv_export_l203_d7_self_patch_ref(patch OsvExportPatch) ?OsvExportPatchRef {
	return osv_export_patch_ref(patch)
}

// Ruby method `self.fetch_upstream(vuln_id)` at line 215.
pub fn ruby_osv_export_l215_d8_self_fetch_upstream(vuln_id string,
	fetch OsvExportFetch) !OsvExportUpstream {
	return osv_export_fetch_upstream(vuln_id, fetch)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "json"
// 5: require "fileutils"
// 6: require "uri"
// 7: require "vulns/osv"
// 8: require "vulns/scanner"
// 9:
// 10: module Homebrew
// 11:   module Vulns
// 12:     # Emits OSV-schema records for the `Homebrew` ecosystem describing CVEs that
// 13:     # homebrew-core formulae resolve via shipped patches.
// 14:     #
// 15:     # One record is written per (formula, vulnerability id) pair found in
// 16:     # `serialized_patches[].resolves`. The record states that the formula was
// 17:     # affected up to (but not including) the currently shipped version+revision;
// 18:     # this is a "fixed at or before what we ship today" approximation, since the
// 19:     # precise fix boundary requires homebrew-core git archaeology.
// 20:     #
// 21:     # Record shape follows the OSV 1.7 schema and mirrors the Debian DSA layout
// 22:     # (`upstream` listing the source CVE, `affected[].ranges` of type
// 23:     # `ECOSYSTEM`, `ecosystem_specific` carrying the resolving patch detail).
// 24:     #
// 25:     # See {Homebrew::DevCmd::GenerateVulnsAdvisories} for the entry point and
// 26:     # https://github.com/Homebrew/advisory-database for the published
// 27:     # feed.
// 28:     module OsvExport
// 29:       # https://ossf.github.io/osv-schema/ — value of the emitted
// 30:       # `schema_version` field, pinning the OSV schema release these records
// 31:       # target. `Homebrew` and `BREW` were registered in that schema in
// 32:       # ossf/osv-schema#576.
// 33:       SCHEMA_VERSION = "1.7.3"
// 34:       ECOSYSTEM = "Homebrew"
// 35:       ID_PREFIX = "BREW"
// 36:
// 37:       # `annotated` is a list of `[formula, serialized_patches]` pairs. The
// 38:       # patches are passed in rather than read from the formula so callers can
// 39:       # supply the union across OS/architecture variations (a `patch` inside an
// 40:       # `on_linux`/`on_intel` block only appears in `Formula#serialized_patches`
// 41:       # under the matching {SimulateSystem}).
// 42:       #
// 43:       # `first_fixed`, when given, is called `(formula, vuln_id) -> String?` for
// 44:       # records with no existing file to derive an accurate `fixed` boundary
// 45:       # (e.g. via {FormulaVersions} git history); existing records preserve
// 46:       # their on-disk `ranges` regardless.
// 47:       sig {
// 48:         params(annotated:   T::Array[[Formula, T::Array[T::Hash[String, T.untyped]]]],
// 49:                dir:         T.any(String, Pathname),
// 50:                first_fixed: T.nilable(T.proc.params(formula: Formula, vuln_id: String).returns(T.nilable(String))),
// 51:                now:         Time)
// 52:           .returns(T::Array[String])
// 53:       }
// 54:       def self.run(annotated, dir, first_fixed: nil, now: Time.now.utc)
// 55:         FileUtils.mkdir_p(dir)
// 56:         written = []
// 57:         upstream_cache = T.let({}, T::Hash[String, T.any(T::Hash[String, T.untyped], Symbol)])
// 58:
// 59:         annotated.each do |formula, patches|
// 60:           Scanner.resolved_ids(patches).each do |vuln_id|
// 61:             upstream = upstream_cache.fetch(vuln_id) { upstream_cache[vuln_id] = fetch_upstream(vuln_id) }
// 62:             path = File.join(dir, "#{ID_PREFIX}-#{formula.name}-#{vuln_id}.json")
// 63:             existing = File.file?(path)
// 64:             # A transient OSV outage would otherwise strip summary/severity/etc.
// 65:             # from an existing enriched record; leave it untouched instead.
// 66:             next if upstream == :failed && existing
// 67:
// 68:             fixed = (first_fixed&.call(formula, vuln_id) unless existing) || formula.pkg_version.to_s
// 69:             record = record_for(formula, vuln_id, patches:, fixed:,
// 70:                                 upstream: upstream.is_a?(Hash) ? upstream : nil, now:)
// 71:             merged = merge_existing(path, record)
// 72:             next if merged.nil?
// 73:
// 74:             File.write(path, "#{JSON.pretty_generate(merged)}\n")
// 75:             written << path
// 76:           end
// 77:         end
// 78:
// 79:         written
// 80:       end
// 81:
// 82:       # If a record already exists at `path`, carry forward its `published`
// 83:       # timestamp and `affected[].ranges` (so the `fixed` boundary reflects when
// 84:       # the annotation was first observed rather than drifting to today's
// 85:       # `pkg_version`), and skip the write entirely when nothing else has
// 86:       # changed. Records for annotations no longer in core are simply not
// 87:       # visited, so they persist.
// 88:       sig {
// 89:         params(path: String, record: T::Hash[Symbol, T.untyped]).returns(T.nilable(T::Hash[Symbol, T.untyped]))
// 90:       }
// 91:       def self.merge_existing(path, record)
// 92:         return record unless File.file?(path)
// 93:
// 94:         existing = JSON.parse(File.read(path))
// 95:         # Records written before `published` was introduced only have
// 96:         # `modified`; use it as the migration value so `published` does not
// 97:         # jump forward to today on first rewrite.
// 98:         if (existing_published = existing["published"] || existing["modified"])
// 99:           record[:published] = existing_published
// 100:         end
// 101:         Array(record[:affected]).each_with_index do |affected, index|
// 102:           existing_ranges = existing.dig("affected", index, "ranges")
// 103:           affected[:ranges] = existing_ranges if existing_ranges
// 104:         end
// 105:
// 106:         # Compare as parsed structures so key ordering (which JSON does not
// 107:         # define but Ruby serialisation preserves) does not cause spurious
// 108:         # rewrites of a hand-formatted or differently-serialised existing file.
// 109:         return if JSON.parse(JSON.generate(record)).except("modified") == existing.except("modified")
// 110:
// 111:         record
// 112:       rescue JSON::ParserError
// 113:         record
// 114:       end
// 115:
// 116:       sig {
// 117:         params(formula: Formula, vuln_id: String, patches: T::Array[T::Hash[String, T.untyped]],
// 118:                fixed: String, upstream: T.nilable(T::Hash[String, T.untyped]), now: Time)
// 119:           .returns(T::Hash[Symbol, T.untyped])
// 120:       }
// 121:       def self.record_for(formula, vuln_id, patches: formula.serialized_patches,
// 122:                           fixed: formula.pkg_version.to_s, upstream: nil, now: Time.now.utc)
// 123:         timestamp = now.strftime("%Y-%m-%dT%H:%M:%SZ")
// 124:         record = T.let({
// 125:           schema_version:    SCHEMA_VERSION,
// 126:           id:                "#{ID_PREFIX}-#{formula.name}-#{vuln_id}",
// 127:           published:         timestamp,
// 128:           modified:          timestamp,
// 129:           upstream:          [vuln_id],
// 130:           affected:          [affected_entry(formula, vuln_id, patches, fixed)],
// 131:           database_specific: { source: "generated" },
// 132:         }, T::Hash[Symbol, T.untyped])
// 133:
// 134:         if upstream
// 135:           record[:summary] = upstream["summary"] if upstream["summary"]
// 136:           record[:details] = upstream["details"] if upstream["details"]
// 137:           record[:severity] = upstream["severity"] if upstream["severity"]
// 138:           record[:upstream] = ([vuln_id] + Array(upstream["aliases"])).uniq
// 139:           if (refs = upstream["references"])
// 140:             # OSV.dev merges NVD and cve.org reference lists without normalising
// 141:             # percent-encoding, so the same URL can appear twice (e.g. `%40` vs
// 142:             # `@`). Collapse those while keeping the same URL under distinct
// 143:             # `type` values, which the schema allows and which carries meaning.
// 144:             record[:references] = refs.uniq do |r|
// 145:               [r["type"], URI::RFC2396_PARSER.unescape(r["url"].to_s)]
// 146:             end
// 147:           end
// 148:         end
// 149:
// 150:         record
// 151:       end
// 152:
// 153:       sig {
// 154:         params(formula: Formula, vuln_id: String, patches: T::Array[T::Hash[String, T.untyped]], fixed: String)
// 155:           .returns(T::Hash[Symbol, T.untyped])
// 156:       }
// 157:       def self.affected_entry(formula, vuln_id, patches, fixed)
// 158:         {
// 159:           package:            {
// 160:             ecosystem: ECOSYSTEM,
// 161:             name:      formula.name,
// 162:             purl:      purl(formula.name),
// 163:           },
// 164:           ranges:             [
// 165:             {
// 166:               type:   "ECOSYSTEM",
// 167:               events: [{ introduced: "0" }, { fixed: }],
// 168:             },
// 169:           ],
// 170:           ecosystem_specific: {
// 171:             fix:     "patch",
// 172:             patches: patches_resolving(patches, vuln_id).filter_map { |p| patch_ref(p) },
// 173:           },
// 174:         }
// 175:       end
// 176:
// 177:       # Formula names use `[a-z0-9._+@-]`. Of those, `@` and `+` fall outside the
// 178:       # purl-spec unreserved set for the name component and must be
// 179:       # percent-encoded (`@` would otherwise be read as the name/version
// 180:       # separator; `+` is disallowed unencoded in a canonical purl name).
// 181:       PURL_NAME_ENCODE = T.let({ "@" => "%40", "+" => "%2B" }.freeze, T::Hash[String, String])
// 182:       private_constant :PURL_NAME_ENCODE
// 183:
// 184:       sig { params(name: String).returns(String) }
// 185:       def self.purl(name)
// 186:         "pkg:brew/#{name.gsub(/[@+]/, PURL_NAME_ENCODE)}"
// 187:       end
// 188:
// 189:       sig {
// 190:         params(serialized_patches: T::Array[T::Hash[String, T.untyped]], vuln_id: String)
// 191:           .returns(T::Array[T::Hash[String, T.untyped]])
// 192:       }
// 193:       def self.patches_resolving(serialized_patches, vuln_id)
// 194:         target = vuln_id.upcase
// 195:         serialized_patches.select do |p|
// 196:           Array(p["resolves"]).any? { |r| r.is_a?(Hash) && r["type"] == "security" && r["id"].to_s.upcase == target }
// 197:         end
// 198:       end
// 199:
// 200:       PatchRef = T.type_alias { T::Hash[Symbol, T.any(String, T::Array[String])] }
// 201:
// 202:       sig { params(patch: T::Hash[String, T.untyped]).returns(T.nilable(PatchRef)) }
// 203:       def self.patch_ref(patch)
// 204:         ref = T.let({}, PatchRef)
// 205:         ref[:type] = patch["type"] if patch["type"]
// 206:         ref[:url] = patch["url"] if patch["url"]
// 207:         ref[:file] = patch["file"] if patch["file"]
// 208:         ref[:apply] = patch["apply"] if patch["apply"]
// 209:         ref.presence
// 210:       end
// 211:
// 212:       # Returns `:failed` (not `nil`) on error so callers can distinguish a
// 213:       # transient outage from a successful fetch that returned no enrichment.
// 214:       sig { params(vuln_id: String).returns(T.any(T::Hash[String, T.untyped], Symbol)) }
// 215:       def self.fetch_upstream(vuln_id)
// 216:         OSV.vulnerability(vuln_id)
// 217:       rescue OSV::Error
// 218:         :failed
// 219:       end
// 220:     end
// 221:   end
// 222: end
