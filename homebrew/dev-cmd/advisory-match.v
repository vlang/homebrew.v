module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/advisory-match.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 48.
pub fn ruby_advisory_match_l48_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `local_repology` at line 86.
pub fn ruby_advisory_match_l86_d2_local_repology(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('local_repology', ...args)
}

// Ruby method `each_formula` at line 93.
pub fn ruby_advisory_match_l93_d3_each_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('each_formula', ...args)
}

// Ruby method `text_mode?` at line 111.
pub fn ruby_advisory_match_l111_d4_text_mode(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('text_mode?', ...args)
}

// Ruby method `report(matcher, formula, hits)` at line 119.
pub fn ruby_advisory_match_l119_d5_report(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('report', ...args)
}

// Ruby method `<<(record); end` at line 146.
pub fn ruby_advisory_match_l146_d6_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('<<', ...args)
}

// Ruby method `finish; end` at line 149.
pub fn ruby_advisory_match_l149_d7_finish(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('finish', ...args)
}

// Ruby method `initialize(dir, verbose:)` at line 154.
pub fn ruby_advisory_match_l154_d8_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `<<(record)` at line 165.
pub fn ruby_advisory_match_l165_d9_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('<<', ...args)
}

// Ruby method `existing_source(path)` at line 186.
pub fn ruby_advisory_match_l186_d10_existing_source(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('existing_source', ...args)
}

// Ruby method `finish` at line 193.
pub fn ruby_advisory_match_l193_d11_finish(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('finish', ...args)
}

// Ruby method `initialize` at line 201.
pub fn ruby_advisory_match_l201_d12_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `<<(record)` at line 207.
pub fn ruby_advisory_match_l207_d13_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('<<', ...args)
}

// Ruby method `finish` at line 212.
pub fn ruby_advisory_match_l212_d14_finish(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('finish', ...args)
}

// Ruby method `initialize` at line 219.
pub fn ruby_advisory_match_l219_d15_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `<<(_record)` at line 225.
pub fn ruby_advisory_match_l225_d16_anonymous(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('<<', ...args)
}

// Ruby method `finish` at line 230.
pub fn ruby_advisory_match_l230_d17_finish(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('finish', ...args)
}

// Ruby method `build_emitter` at line 236.
pub fn ruby_advisory_match_l236_d18_build_emitter(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_emitter', ...args)
}

// Ruby method `emit_index(matcher)` at line 247.
pub fn ruby_advisory_match_l247_d19_emit_index(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emit_index', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "fileutils"
// 6: require "formula"
// 7: require "vulns/match"
// 8:
// 9: module Homebrew
// 10:   module DevCmd
// 11:     class AdvisoryMatch < AbstractCommand
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Match <formula> against OSV.dev (GIT, language-registry and distro
// 15:           ecosystems) and CPANSA to produce candidate `BREW-*` advisory records
// 16:           for <https://github.com/Homebrew/advisory-database>.
// 17:
// 18:           This is authoring-time tooling for the advisory-database CI and the
// 19:           `homebrew-core` PR bot; use `brew vulns` to scan installed formulae.
// 20:         EOS
// 21:         switch "--all",
// 22:                description: "Match every formula in `homebrew/core`."
// 23:         switch "--index",
// 24:                description: "Emit the formula-identity index as JSON and exit."
// 25:         switch "--json",
// 26:                description: "Output candidate records as a JSON array."
// 27:         flag   "--output=",
// 28:                description: "Write each record to <directory> as " \
// 29:                             "`BREW-<formula>-<id>.json`, preserving existing " \
// 30:                             "`published`/`ranges` fields."
// 31:         flag   "--repology=",
// 32:                description: "Load the formula to distro-package index from " \
// 33:                             "<file> instead of the published `data/repology.json`."
// 34:         switch "--no-history",
// 35:                description: "Skip the `FormulaVersions` walk for the `fixed` " \
// 36:                             "boundary; use the current `pkg_version` instead."
// 37:         conflicts "--all", "--index"
// 38:         conflicts "--all", "--json"
// 39:         conflicts "--index", "--json"
// 40:         conflicts "--index", "--output"
// 41:
// 42:         named_args [:formula]
// 43:
// 44:         hide_from_man_page!
// 45:       end
// 46:
// 47:       sig { override.void }
// 48:       def run
// 49:         Formulary.enable_factory_cache!
// 50:         Homebrew.with_no_api_env do
// 51:           latest_macos = MacOSVersion.new((HOMEBREW_MACOS_NEWEST_UNSUPPORTED.to_i - 1).to_s).to_sym
// 52:           Homebrew::SimulateSystem.with(os: latest_macos, arch: :arm) do
// 53:             matcher = Homebrew::Vulns::Match.new(repology: local_repology, bulk: args.all? || args.index?)
// 54:             next emit_index(matcher) if args.index?
// 55:
// 56:             emitter = build_emitter
// 57:             begin
// 58:               matcher.each_advisory_batch(each_formula) do |formula, hits|
// 59:                 report(matcher, formula, hits) if text_mode?
// 60:                 hits.each do |hit|
// 61:                   # A `:not_applicable` hit (below every `introduced`) emitted
// 62:                   # as `{introduced: 0}` with no `fixed` reads to OSV consumers
// 63:                   # as currently affected; drop it instead.
// 64:                   status, = matcher.range_status(hit)
// 65:                   next if status&.state == :not_applicable
// 66:
// 67:                   first_fixed = matcher.first_fixed_version(formula, hit) unless args.no_history?
// 68:                   next if first_fixed == :never_affected
// 69:
// 70:                   boundary = first_fixed if first_fixed.is_a?(String)
// 71:                   emitter << matcher.to_brew_record(formula, hit, first_fixed: boundary)
// 72:                 end
// 73:               end
// 74:             rescue Homebrew::Vulns::OSV::Error => e
// 75:               onoe "OSV query failed: #{e.message}"
// 76:               Homebrew.failed = true
// 77:             end
// 78:             emitter.finish
// 79:           end
// 80:         end
// 81:       end
// 82:
// 83:       # A CI run that has just built the index locally (advisory-database's
// 84:       # Ingest) reads it directly instead of fetching the published copy.
// 85:       sig { returns(T.nilable(Homebrew::Vulns::Repology)) }
// 86:       def local_repology
// 87:         return unless (path = args.repology)
// 88:
// 89:         Homebrew::Vulns::Repology.from_file(Pathname(path))
// 90:       end
// 91:
// 92:       sig { returns(T::Enumerator[Formula]) }
// 93:       def each_formula
// 94:         return args.named.to_resolved_formulae.each unless args.all?
// 95:
// 96:         raise UsageError, "`--all` does not take named arguments" if args.named.any?
// 97:
// 98:         tap = CoreTap.instance
// 99:         raise TapUnavailableError, tap.name unless tap.installed?
// 100:
// 101:         Enumerator.new do |y|
// 102:           tap.formula_names.each do |name|
// 103:             y << Formulary.factory(name)
// 104:           rescue => e
// 105:             onoe "Error loading formula '#{name}': #{e}"
// 106:           end
// 107:         end
// 108:       end
// 109:
// 110:       sig { returns(T::Boolean) }
// 111:       def text_mode?
// 112:         !args.json? && args.output.nil?
// 113:       end
// 114:
// 115:       sig {
// 116:         params(matcher: Homebrew::Vulns::Match, formula: Formula,
// 117:                hits: T::Array[Homebrew::Vulns::Match::Hit]).void
// 118:       }
// 119:       def report(matcher, formula, hits)
// 120:         ohai "#{formula.name} #{formula.pkg_version}"
// 121:         if hits.empty?
// 122:           puts "  No advisories matched."
// 123:           return
// 124:         end
// 125:         hits.sort_by { |h| [-h.vulnerability.severity_level, h.canonical_id] }.each do |hit|
// 126:           v = hit.vulnerability
// 127:           status, = matcher.range_status(hit)
// 128:           state = case status&.state
// 129:           when nil       then "uncomparable"
// 130:           when :affected then "AFFECTED#{", upstream fix #{status&.fixed_in}" if status&.fixed_in}"
// 131:           when :fixed    then "fixed (upstream #{status&.fixed_in || "?"})"
// 132:           else "not applicable"
// 133:           end
// 134:           summary = v.summary&.slice(0, 60)
// 135:           puts "  #{hit.canonical_id} [#{hit.strategy}, #{matcher.confidence_for(hit, status)}] " \
// 136:                "#{v.severity_display} #{state}" \
// 137:                "#{" (resource: #{hit.resource})" if hit.resource}" \
// 138:                "#{" — #{summary}" if summary}"
// 139:         end
// 140:       end
// 141:
// 142:       # `--output` and text mode write per-record and only accumulate counts;
// 143:       # `--json` accumulates the array (single-formula / PR-bot use, so bounded).
// 144:       class Emitter
// 145:         sig { params(record: T::Hash[Symbol, T.untyped]).void }
// 146:         def <<(record); end
// 147:
// 148:         sig { void }
// 149:         def finish; end
// 150:       end
// 151:
// 152:       class DirEmitter < Emitter
// 153:         sig { params(dir: String, verbose: T::Boolean).void }
// 154:         def initialize(dir, verbose:)
// 155:           super()
// 156:           FileUtils.mkdir_p(dir)
// 157:           @dir = dir
// 158:           @verbose = verbose
// 159:           @written = T.let(0, Integer)
// 160:           @unchanged = T.let(0, Integer)
// 161:           @skipped_generated = T.let(0, Integer)
// 162:         end
// 163:
// 164:         sig { override.params(record: T::Hash[Symbol, T.untyped]).void }
// 165:         def <<(record)
// 166:           path = File.join(@dir, "#{record.fetch(:id)}.json")
// 167:           # A record already emitted by `generate-vulns-advisories` (a formula
// 168:           # `resolves` patch annotation) is more authoritative than a matched
// 169:           # candidate; overwriting it would drop `fix: "patch"` for a derived
// 170:           # `fix: null`/`"bump"`.
// 171:           if File.file?(path) && existing_source(path) == "generated"
// 172:             @skipped_generated += 1
// 173:             return
// 174:           end
// 175:           merged = Homebrew::Vulns::OsvExport.merge_existing(path, record)
// 176:           if merged.nil?
// 177:             @unchanged += 1
// 178:             return
// 179:           end
// 180:           File.write(path, "#{JSON.pretty_generate(merged)}\n")
// 181:           puts "  wrote #{path}" if @verbose
// 182:           @written += 1
// 183:         end
// 184:
// 185:         sig { params(path: String).returns(T.nilable(String)) }
// 186:         def existing_source(path)
// 187:           JSON.parse(File.read(path)).dig("database_specific", "source")
// 188:         rescue JSON::ParserError
// 189:           nil
// 190:         end
// 191:
// 192:         sig { override.void }
// 193:         def finish
// 194:           Utils::Output.ohai "#{@written} records written to #{@dir} " \
// 195:                              "(#{@unchanged} unchanged, #{@skipped_generated} generated left as-is)"
// 196:         end
// 197:       end
// 198:
// 199:       class JsonEmitter < Emitter
// 200:         sig { void }
// 201:         def initialize
// 202:           super
// 203:           @records = T.let([], T::Array[T::Hash[Symbol, T.untyped]])
// 204:         end
// 205:
// 206:         sig { override.params(record: T::Hash[Symbol, T.untyped]).void }
// 207:         def <<(record)
// 208:           @records << record
// 209:         end
// 210:
// 211:         sig { override.void }
// 212:         def finish
// 213:           puts JSON.pretty_generate(@records)
// 214:         end
// 215:       end
// 216:
// 217:       class CountEmitter < Emitter
// 218:         sig { void }
// 219:         def initialize
// 220:           super
// 221:           @count = T.let(0, Integer)
// 222:         end
// 223:
// 224:         sig { override.params(_record: T::Hash[Symbol, T.untyped]).void }
// 225:         def <<(_record)
// 226:           @count += 1
// 227:         end
// 228:
// 229:         sig { override.void }
// 230:         def finish
// 231:           Utils::Output.ohai "#{@count} candidate records"
// 232:         end
// 233:       end
// 234:
// 235:       sig { returns(Emitter) }
// 236:       def build_emitter
// 237:         if (dir = args.output)
// 238:           DirEmitter.new(dir, verbose: args.verbose?)
// 239:         elsif args.json?
// 240:           JsonEmitter.new
// 241:         else
// 242:           CountEmitter.new
// 243:         end
// 244:       end
// 245:
// 246:       sig { params(matcher: Homebrew::Vulns::Match).void }
// 247:       def emit_index(matcher)
// 248:         tap = CoreTap.instance
// 249:         raise TapUnavailableError, tap.name unless tap.installed?
// 250:
// 251:         index = tap.formula_names.each_with_object({}) do |name, h|
// 252:           identity = matcher.identify(Formulary.factory(name))
// 253:           next unless identity.identifiable?
// 254:
// 255:           h[name] = {
// 256:             git_repo:          identity.git_repo,
// 257:             git_tag:           identity.git_tag,
// 258:             primary_package:   identity.primary_package&.to_h,
// 259:             resource_packages: identity.resource_packages.transform_values(&:to_h),
// 260:             distro_packages:   identity.distro_packages,
// 261:           }.compact
// 262:         rescue => e
// 263:           onoe "Error loading formula '#{name}': #{e}"
// 264:         end
// 265:         puts JSON.pretty_generate(index)
// 266:       end
// 267:     end
// 268:   end
// 269: end
