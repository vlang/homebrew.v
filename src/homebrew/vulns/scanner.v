module vulns

import brew_runtime

// Translated from Homebrew/brew `vulns/scanner.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.target_repo_url(source_url, head_url, homepage)` at line 16.
pub fn ruby_scanner_l16_d1_self_target_repo_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.target_repo_url', ...args)
}

// Ruby method `self.source_from_sbom(prefix)` at line 27.
pub fn ruby_scanner_l27_d2_self_source_from_sbom(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.source_from_sbom', ...args)
}

// Ruby method `self.resolved_ids(serialized_patches)` at line 47.
pub fn ruby_scanner_l47_d3_self_resolved_ids(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.resolved_ids', ...args)
}

// Ruby attr_reader `attr_reader :findings` at line 59.
pub fn ruby_scanner_l59_d4_findings(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('findings', ...args)
}

// Ruby attr_reader `attr_reader :checked, :skipped` at line 62.
pub fn ruby_scanner_l62_d5_checked(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('checked', ...args)
}

// Ruby attr_reader `attr_reader :checked, :skipped` at line 62.
pub fn ruby_scanner_l62_d6_skipped(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skipped', ...args)
}

// Ruby attr_reader `attr_reader :outdated_without_sbom` at line 65.
pub fn ruby_scanner_l65_d7_outdated_without_sbom(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('outdated_without_sbom', ...args)
}

// Ruby method `initialize(findings:, checked:, skipped:, outdated_without_sbom: [])` at line 71.
pub fn ruby_scanner_l71_d8_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `any_open?` at line 79.
pub fn ruby_scanner_l79_d9_any_open(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('any_open?', ...args)
}

// Ruby method `initialize(formulae, ignore_patches: true, min_severity: nil, only_fixed: false, except_fixed: false)` at line 97.
pub fn ruby_scanner_l97_d10_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `scan` at line 110.
pub fn ruby_scanner_l110_d11_scan(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('scan', ...args)
}

// Ruby method `target_for(formula)` at line 149.
pub fn ruby_scanner_l149_d12_target_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('target_for', ...args)
}

// Ruby method `build_target(formula)` at line 157.
pub fn ruby_scanner_l157_d13_build_target(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_target', ...args)
}

// Ruby method `stale_target?(formula)` at line 194.
pub fn ruby_scanner_l194_d14_stale_target(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('stale_target?', ...args)
}

// Ruby method `fetch_vulnerabilities(ids)` at line 202.
pub fn ruby_scanner_l202_d15_fetch_vulnerabilities(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fetch_vulnerabilities', ...args)
}

// Ruby method `partition_patched(formula, target, vulns)` at line 215.
pub fn ruby_scanner_l215_d16_partition_patched(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('partition_patched', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "sbom"
// 5: require "vulns/identify"
// 6: require "vulns/osv"
// 7: require "vulns/vulnerability"
// 8:
// 9: module Homebrew
// 10:   module Vulns
// 11:     class Scanner
// 12:       sig {
// 13:         params(source_url: T.nilable(String), head_url: T.nilable(String),
// 14:                homepage: T.nilable(String)).returns(T.nilable(String))
// 15:       }
// 16:       def self.target_repo_url(source_url, head_url, homepage)
// 17:         url = Identify.repo_url(source_url, head_url, homepage)
// 18:         url ||= source_url if Identify.tag(source_url)
// 19:         url ||= head_url
// 20:         url
// 21:       end
// 22:
// 23:       SBOM_SRC_SPDXID = /\ASPDXRef-Archive-.*-src\z/
// 24:       private_constant :SBOM_SRC_SPDXID
// 25:
// 26:       sig { params(prefix: Pathname).returns(T.nilable([T.nilable(String), T.nilable(String)])) }
// 27:       def self.source_from_sbom(prefix)
// 28:         file = prefix/SBOM::FILENAME
// 29:         return unless file.file?
// 30:
// 31:         data = JSON.parse(file.read)
// 32:         src = Array(data["packages"]).find { |p| p["SPDXID"].to_s.match?(SBOM_SRC_SPDXID) }
// 33:         return if src.nil?
// 34:
// 35:         url = src["downloadLocation"]
// 36:         url = nil if url == "NOASSERTION"
// 37:         version = src["versionInfo"]
// 38:         version = nil if version == "NOASSERTION"
// 39:         return if url.nil? && version.nil?
// 40:
// 41:         [url, version]
// 42:       rescue JSON::ParserError
// 43:         nil
// 44:       end
// 45:
// 46:       sig { params(serialized_patches: T::Array[T::Hash[String, T.untyped]]).returns(T::Array[String]) }
// 47:       def self.resolved_ids(serialized_patches)
// 48:         serialized_patches
// 49:           .flat_map { |p| Array(p["resolves"]) }
// 50:           .select { |r| r.is_a?(Hash) && r["type"] == "security" }
// 51:           .map { |r| r["id"].to_s.upcase }
// 52:           .uniq
// 53:       end
// 54:
// 55:       Finding = Struct.new(:name, :version, :tag, :repo_url, :open, :patched, keyword_init: true)
// 56:
// 57:       class Results
// 58:         sig { returns(T::Array[Finding]) }
// 59:         attr_reader :findings
// 60:
// 61:         sig { returns(Integer) }
// 62:         attr_reader :checked, :skipped
// 63:
// 64:         sig { returns(T::Array[String]) }
// 65:         attr_reader :outdated_without_sbom
// 66:
// 67:         sig {
// 68:           params(findings: T::Array[Finding], checked: Integer, skipped: Integer,
// 69:                  outdated_without_sbom: T::Array[String]).void
// 70:         }
// 71:         def initialize(findings:, checked:, skipped:, outdated_without_sbom: [])
// 72:           @findings = findings
// 73:           @checked = checked
// 74:           @skipped = skipped
// 75:           @outdated_without_sbom = outdated_without_sbom
// 76:         end
// 77:
// 78:         sig { returns(T::Boolean) }
// 79:         def any_open?
// 80:           findings.any? { |f| f.open.any? }
// 81:         end
// 82:       end
// 83:
// 84:       MAX_VULN_FETCH_THREADS = 15
// 85:       private_constant :MAX_VULN_FETCH_THREADS
// 86:
// 87:       SEVERITY_LEVELS = T.let(
// 88:         { low: 1, medium: 2, high: 3, critical: 4 }.freeze,
// 89:         T::Hash[Symbol, Integer],
// 90:       )
// 91:       private_constant :SEVERITY_LEVELS
// 92:
// 93:       sig {
// 94:         params(formulae: T::Array[Formula], ignore_patches: T::Boolean, min_severity: T.nilable(Symbol),
// 95:                only_fixed: T::Boolean, except_fixed: T::Boolean).void
// 96:       }
// 97:       def initialize(formulae, ignore_patches: true, min_severity: nil, only_fixed: false, except_fixed: false)
// 98:         @formulae = formulae
// 99:         @ignore_patches = ignore_patches
// 100:         @min_severity_level = T.let(min_severity ? SEVERITY_LEVELS.fetch(min_severity) : 0, Integer)
// 101:         @only_fixed = only_fixed
// 102:         @except_fixed = except_fixed
// 103:       end
// 104:
// 105:       Target = Struct.new(:repo_url, :tag, :version, :from_installed_sbom, :current_recipe_applies,
// 106:                           keyword_init: true)
// 107:       private_constant :Target
// 108:
// 109:       sig { returns(Results) }
// 110:       def scan
// 111:         queryable, skipped = @formulae.partition { |f| target_for(f) }
// 112:         outdated_without_sbom = queryable.select { |f| stale_target?(f) }.map(&:name)
// 113:         if queryable.empty?
// 114:           return Results.new(findings: [], checked: 0, skipped: skipped.size, outdated_without_sbom:)
// 115:         end
// 116:
// 117:         targets = queryable.map { |f| T.must(target_for(f)) }
// 118:         batch = OSV.query_batch(targets.map { |t| { ecosystem: "GIT", name: t.repo_url, version: t.tag } })
// 119:
// 120:         findings = queryable.each_with_index.filter_map do |formula, index|
// 121:           target = targets.fetch(index)
// 122:           ids = batch.fetch(index)
// 123:           next if ids.empty?
// 124:
// 125:           vulns = fetch_vulnerabilities(ids)
// 126:                   .select { |v| v.affects_version?(target.tag) }
// 127:                   .select { |v| v.severity_level >= @min_severity_level }
// 128:           vulns = vulns.select { |v| v.fix_available?(target.tag, target.repo_url) } if @only_fixed
// 129:           vulns = vulns.reject { |v| v.fix_available?(target.tag, target.repo_url) } if @except_fixed
// 130:           next if vulns.empty?
// 131:
// 132:           open, patched = partition_patched(formula, target, vulns)
// 133:           next if open.empty? && patched.empty?
// 134:
// 135:           Finding.new(
// 136:             name:     formula.name,
// 137:             version:  target.version,
// 138:             tag:      target.tag,
// 139:             repo_url: target.repo_url,
// 140:             open:,
// 141:             patched:,
// 142:           )
// 143:         end
// 144:
// 145:         Results.new(findings:, checked: queryable.size, skipped: skipped.size, outdated_without_sbom:)
// 146:       end
// 147:
// 148:       sig { params(formula: Formula).returns(T.nilable(Target)) }
// 149:       def target_for(formula)
// 150:         @targets ||= T.let({}, T.nilable(T::Hash[String, T.nilable(Target)]))
// 151:         @targets.fetch(formula.full_name) do
// 152:           @targets[formula.full_name] = build_target(formula)
// 153:         end
// 154:       end
// 155:
// 156:       sig { params(formula: Formula).returns(T.nilable(Target)) }
// 157:       def build_target(formula)
// 158:         stable = formula.stable
// 159:         stable_url = stable&.url
// 160:         head_url = formula.head&.url
// 161:         homepage = formula.homepage
// 162:
// 163:         stable_repo_url = self.class.target_repo_url(stable_url, head_url, homepage)
// 164:         stable_tag = Identify.tag(stable_url) || stable&.specs&.[](:tag) || stable&.version&.to_s
// 165:
// 166:         if (prefix = formula.any_installed_prefix)
// 167:           installed_pkg_version = formula.any_installed_version
// 168:           installed_version = installed_pkg_version&.version.to_s
// 169:           current_recipe_applies = installed_pkg_version == formula.pkg_version
// 170:
// 171:           if (sbom = self.class.source_from_sbom(prefix))
// 172:             sbom_url, sbom_version = sbom
// 173:             repo_url = self.class.target_repo_url(sbom_url, head_url, homepage)
// 174:             tag = Identify.tag(sbom_url) || sbom_version || installed_version.presence
// 175:             if repo_url && tag
// 176:               return Target.new(repo_url:, tag:, version: installed_version,
// 177:                                 from_installed_sbom: true, current_recipe_applies:)
// 178:             end
// 179:           end
// 180:
// 181:           return if stable_repo_url.nil? || stable_tag.nil?
// 182:
// 183:           return Target.new(repo_url: stable_repo_url, tag: stable_tag, version: installed_version,
// 184:                             from_installed_sbom: false, current_recipe_applies:)
// 185:         end
// 186:
// 187:         return if stable_repo_url.nil? || stable_tag.nil?
// 188:
// 189:         Target.new(repo_url: stable_repo_url, tag: stable_tag, version: formula.version.to_s,
// 190:                    from_installed_sbom: false, current_recipe_applies: true)
// 191:       end
// 192:
// 193:       sig { params(formula: Formula).returns(T::Boolean) }
// 194:       def stale_target?(formula)
// 195:         target = target_for(formula)
// 196:         return false if target.nil? || target.from_installed_sbom
// 197:
// 198:         !target.current_recipe_applies
// 199:       end
// 200:
// 201:       sig { params(ids: T::Array[T::Hash[String, T.untyped]]).returns(T::Array[Vulnerability]) }
// 202:       def fetch_vulnerabilities(ids)
// 203:         records = ids.each_slice(MAX_VULN_FETCH_THREADS).flat_map do |slice|
// 204:           slice
// 205:             .map { |v| Thread.new { OSV.vulnerability(v.fetch("id")) } }
// 206:             .map { |t| T.cast(t.value, T::Hash[String, T.untyped]) }
// 207:         end
// 208:         Vulnerability.from_osv_list(records)
// 209:       end
// 210:
// 211:       sig {
// 212:         params(formula: Formula, target: Target, vulns: T::Array[Vulnerability])
// 213:           .returns([T::Array[Vulnerability], T::Array[Vulnerability]])
// 214:       }
// 215:       def partition_patched(formula, target, vulns)
// 216:         return [vulns, []] unless @ignore_patches
// 217:         # The current formula's `serialized_patches` reflects the recipe on
// 218:         # disk. If the scanned keg was built from an older recipe it may lack a
// 219:         # patch the recipe has since gained, so its `resolves` must not
// 220:         # suppress findings.
// 221:         return [vulns, []] unless target.current_recipe_applies
// 222:
// 223:         resolved = self.class.resolved_ids(formula.serialized_patches)
// 224:         return [vulns, []] if resolved.empty?
// 225:
// 226:         patched, open = vulns.partition do |v|
// 227:           v.identifiers.any? { |id| resolved.include?(id.to_s.upcase) }
// 228:         end
// 229:         [open, patched]
// 230:       end
// 231:     end
// 232:   end
// 233: end
