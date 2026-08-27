module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/generate-vulns-advisories.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 29.
pub fn ruby_generate_vulns_advisories_l29_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `all_variation_patches(formula)` at line 75.
pub fn ruby_generate_vulns_advisories_l75_d2_all_variation_patches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('all_variation_patches', ...args)
}

// Ruby method `first_fixed_version(formula, vuln_id)` at line 103.
pub fn ruby_generate_vulns_advisories_l103_d3_first_fixed_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('first_fixed_version', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "formula_versions"
// 7: require "vulns/osv_export"
// 8:
// 9: module Homebrew
// 10:   module DevCmd
// 11:     class GenerateVulnsAdvisories < AbstractCommand
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Generate OSV-schema advisory records for the `Homebrew` ecosystem from
// 15:           `homebrew/core` formula patch `resolves` annotations, for
// 16:           <https://github.com/Homebrew/advisory-database>.
// 17:
// 18:           Records are written to <directory>.
// 19:         EOS
// 20:         switch "-n", "--dry-run",
// 21:                description: "List the records that would be generated without writing files or querying OSV.dev."
// 22:
// 23:         named_args :directory, number: 1
// 24:
// 25:         hide_from_man_page!
// 26:       end
// 27:
// 28:       sig { override.void }
// 29:       def run
// 30:         tap = CoreTap.instance
// 31:         raise TapUnavailableError, tap.name unless tap.installed?
// 32:
// 33:         dir = args.named.first
// 34:
// 35:         Formulary.enable_factory_cache!
// 36:         Homebrew.with_no_api_env do
// 37:           latest_macos = MacOSVersion.new((HOMEBREW_MACOS_NEWEST_UNSUPPORTED.to_i - 1).to_s).to_sym
// 38:           Homebrew::SimulateSystem.with(os: latest_macos, arch: :arm) do
// 39:             annotated = tap.formula_names.filter_map do |name|
// 40:               formula = Formulary.factory(name)
// 41:               patches = all_variation_patches(formula)
// 42:               [formula, patches] if Homebrew::Vulns::Scanner.resolved_ids(patches).any?
// 43:             rescue
// 44:               onoe "Error loading formula '#{name}'."
// 45:               raise
// 46:             end
// 47:             ohai "#{annotated.size} formulae with security `resolves` annotations"
// 48:
// 49:             if args.dry_run?
// 50:               annotated.each do |formula, patches|
// 51:                 Homebrew::Vulns::Scanner.resolved_ids(patches).each do |vuln_id|
// 52:                   puts "#{Homebrew::Vulns::OsvExport::ID_PREFIX}-#{formula.name}-#{vuln_id}"
// 53:                 end
// 54:               end
// 55:               next
// 56:             end
// 57:
// 58:             written = Homebrew::Vulns::OsvExport.run(
// 59:               annotated, T.must(dir),
// 60:               first_fixed: ->(formula, vuln_id) { first_fixed_version(formula, vuln_id) }
// 61:             )
// 62:             written.each { |p| puts "  wrote #{p}" } if args.verbose?
// 63:             ohai "#{written.size} records written to #{dir}"
// 64:           end
// 65:         end
// 66:       end
// 67:
// 68:       # `Formula#serialized_patches` reflects the currently simulated OS and
// 69:       # architecture; a `patch` inside e.g. `on_linux` is invisible under
// 70:       # `SimulateSystem.with(os: :sequoia)`. Collect the union of the base
// 71:       # `patches` array and every OS/arch variation from
// 72:       # `Formula#to_hash_with_variations` so platform-gated `resolves`
// 73:       # annotations are exported.
// 74:       sig { params(formula: Formula).returns(T::Array[T::Hash[String, T.untyped]]) }
// 75:       def all_variation_patches(formula)
// 76:         hash = formula.to_hash_with_variations
// 77:         base = hash.fetch("patches")
// 78:         variation_patches = hash.fetch("variations").values.filter_map { |v| v["patches"] }
// 79:         (base + variation_patches.flatten(1)).uniq
// 80:       end
// 81:
// 82:       # Walk homebrew-core git history (newest first) via {FormulaVersions} and
// 83:       # return the `pkg_version` at the oldest revision where `vuln_id` still
// 84:       # appears in the formula's resolved patch ids: the version at which the
// 85:       # fix first shipped. Revisions that fail to load (older DSL) end the walk
// 86:       # early. Only invoked for records with no existing file, so the cost is
// 87:       # bounded to newly annotated (formula, CVE) pairs.
// 88:       #
// 89:       # Because `resolved_ids` includes CVEs inferred from patch URLs and
// 90:       # `apply` file paths, this finds the true fix version when the CVE is
// 91:       # named there. When a `resolves` line was added to a patch that had
// 92:       # already shipped without a CVE reference, it finds when `resolves` was
// 93:       # added (too recent); those cases are hand-corrected in the advisory
// 94:       # repository, which {Homebrew::Vulns::OsvExport.run} then preserves.
// 95:       #
// 96:       # Historical revisions are loaded under the enclosing {SimulateSystem}
// 97:       # (latest macOS/ARM) only; a `resolves` that lives inside e.g. `on_linux`
// 98:       # is invisible here and falls through to the current `pkg_version`.
// 99:       # {FormulaVersions} caches by revision alone, so per-variation historical
// 100:       # loading would need separate instances; deferred until a variation-only
// 101:       # security annotation actually exists in core.
// 102:       sig { params(formula: Formula, vuln_id: String).returns(T.nilable(String)) }
// 103:       def first_fixed_version(formula, vuln_id)
// 104:         # `FormulaVersions#rev_list` shells out to path-filtered `git rev-list`
// 105:         # over the whole homebrew-core history and dominates runtime; cache it
// 106:         # (and the instance, for its per-revision formula memoisation) per
// 107:         # formula so subsequent CVEs for the same formula reuse both.
// 108:         @formula_versions ||= T.let({}, T.nilable(T::Hash[String, FormulaVersions]))
// 109:         @formula_rev_lists ||= T.let({}, T.nilable(T::Hash[String, T::Array[[String, String]]]))
// 110:         fv = @formula_versions[formula.name] ||= FormulaVersions.new(formula)
// 111:         revs = @formula_rev_lists[formula.name] ||=
// 112:           [].tap { |a| fv.rev_list("HEAD") { |rev, entry| a << [rev, entry] } }
// 113:
// 114:         last_fixed = T.let(nil, T.nilable(String))
// 115:         revs.each do |rev, entry|
// 116:           resolved_here = fv.formula_at_revision(rev, entry) do |old|
// 117:             Homebrew::Vulns::Scanner.resolved_ids(old.serialized_patches).include?(vuln_id)
// 118:           end
// 119:           # `nil` means the revision failed to load; stop rather than guess.
// 120:           return last_fixed if resolved_here.nil?
// 121:           return last_fixed unless resolved_here
// 122:
// 123:           last_fixed = fv.formula_at_revision(rev, entry) { |old| old.pkg_version.to_s }
// 124:         end
// 125:         last_fixed
// 126:       end
// 127:     end
// 128:   end
// 129: end
