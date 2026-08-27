module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/vulns.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 48.
pub fn ruby_vulns_l48_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `formulae` at line 89.
pub fn ruby_vulns_l89_d2_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formulae', ...args)
}

// Ruby method `installed_formulae` at line 104.
pub fn ruby_vulns_l104_d3_installed_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('installed_formulae', ...args)
}

// Ruby method `untrusted_skipped` at line 116.
pub fn ruby_vulns_l116_d4_untrusted_skipped(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('untrusted_skipped', ...args)
}

// Ruby method `brewfile_path(value)` at line 124.
pub fn ruby_vulns_l124_d5_brewfile_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('brewfile_path', ...args)
}

// Ruby method `min_severity` at line 129.
pub fn ruby_vulns_l129_d6_min_severity(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('min_severity', ...args)
}

// Ruby method `max_summary` at line 140.
pub fn ruby_vulns_l140_d7_max_summary(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('max_summary', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6:
// 7: module Homebrew
// 8:   module Cmd
// 9:     class Vulns < AbstractCommand
// 10:       SEVERITIES = %w[low medium high critical].freeze
// 11:
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Check <formula> for known security vulnerabilities using the OSV.dev database.
// 15:
// 16:           With no arguments, all installed formulae are checked.
// 17:         EOS
// 18:         switch "-d", "--deps",
// 19:                description: "Also check the dependencies of named formulae."
// 20:         switch "--no-ignore-patches",
// 21:                description: "Report vulnerabilities even when a formula patch resolves them."
// 22:         flag   "--brewfile",
// 23:                description: "Check formulae listed in a Brewfile. " \
// 24:                             "Defaults to `./Brewfile`; use `--brewfile=`<path> to specify another."
// 25:         switch "--fix-available",
// 26:                description: "Only report vulnerabilities that have a fix available. " \
// 27:                             "Note that this may exclude vulnerabilities with fixes available " \
// 28:                             "if we cannot determine that the fix is included in the version " \
// 29:                             "under consideration."
// 30:         switch "--no-fix-available",
// 31:                description: "Only report vulnerabilities that do not have a fix available. " \
// 32:                             "Note that this may include vulnerabilities with fixes available " \
// 33:                             "if we cannot determine that the fix is included in the version " \
// 34:                             "under consideration."
// 35:         flag   "-s", "--severity=",
// 36:                description: "Only report findings at or above: `low`, `medium`, `high`, `critical`."
// 37:         flag   "-m", "--max-summary=",
// 38:                description: "Truncate summaries to <n> characters (default 60, 0 for no limit)."
// 39:         switch "-j", "--json",
// 40:                description: "Output JSON."
// 41:
// 42:         conflicts "--fix-available", "--no-fix-available"
// 43:
// 44:         named_args :formula
// 45:       end
// 46:
// 47:       sig { override.void }
// 48:       def run
// 49:         require "vulns"
// 50:
// 51:         summary_width = max_summary
// 52:         severity = min_severity
// 53:
// 54:         results = Homebrew::Vulns::Scanner.new(
// 55:           formulae,
// 56:           ignore_patches: !args.no_ignore_patches?,
// 57:           min_severity:   severity,
// 58:           only_fixed:     args.fix_available?,
// 59:           except_fixed:   args.no_fix_available?,
// 60:         ).scan
// 61:
// 62:         if args.json?
// 63:           Homebrew::Vulns::Output.json(results)
// 64:         else
// 65:           Homebrew::Vulns::Output.text(results, max_summary: summary_width)
// 66:         end
// 67:
// 68:         if untrusted_skipped.any?
// 69:           kegs = Utils.pluralize("installed keg", untrusted_skipped.size, include_count: true)
// 70:           opoo <<~EOS
// 71:             #{kegs} from an untrusted tap not scanned:
// 72:               #{untrusted_skipped.join("\n  ")}
// 73:             Run `brew trust` on the formula or tap to include it in future scans.
// 74:           EOS
// 75:           Homebrew.failed = true
// 76:         end
// 77:         if results.outdated_without_sbom.any?
// 78:           opoo <<~EOS
// 79:             The installed source of #{results.outdated_without_sbom.sort.join(", ")} could not be determined
// 80:             (older than the current formula and no SBOM was written at install time). Results above reflect
// 81:             the current formula version, not what is installed. Run `brew upgrade` for accurate results.
// 82:           EOS
// 83:           Homebrew.failed = true
// 84:         end
// 85:         Homebrew.failed = true if results.any_open?
// 86:       end
// 87:
// 88:       sig { returns(T::Array[Formula]) }
// 89:       def formulae
// 90:         list = T.let([], T::Array[Formula])
// 91:         if (brewfile = args.brewfile)
// 92:           require "bundle/brewfile"
// 93:           list += Homebrew::Bundle::Brewfile.read(file: brewfile_path(brewfile)).entries
// 94:                                             .select { |e| e.type == :brew }
// 95:                                             .map { |e| Formulary.resolve(e.name) }
// 96:         end
// 97:         list += args.named.to_resolved_formulae if args.named.any?
// 98:         list = installed_formulae if !args.brewfile && args.no_named?
// 99:         list += list.flat_map { |f| f.recursive_dependencies.map(&:to_formula) } if args.deps?
// 100:         list.uniq(&:full_name)
// 101:       end
// 102:
// 103:       sig { returns(T::Array[Formula]) }
// 104:       def installed_formulae
// 105:         Formula.racks.filter_map do |rack|
// 106:           Formulary.from_rack(rack)
// 107:         rescue Homebrew::UntrustedTapError => e
// 108:           untrusted_skipped << e.message.lines.first.to_s.strip
// 109:           nil
// 110:         rescue
// 111:           nil
// 112:         end.uniq(&:name)
// 113:       end
// 114:
// 115:       sig { returns(T::Array[String]) }
// 116:       def untrusted_skipped
// 117:         @untrusted_skipped ||= T.let([], T.nilable(T::Array[String]))
// 118:       end
// 119:
// 120:       # A bare `--brewfile` (no `=path`) yields `true` from OptionParser at
// 121:       # runtime; the generated RBI types it as `T.nilable(String)`, so accept
// 122:       # the wider type here and normalise `true`/`""` to the `nil` default.
// 123:       sig { params(value: T.nilable(T.any(String, TrueClass))).returns(T.nilable(String)) }
// 124:       def brewfile_path(value)
// 125:         value.presence if value.is_a?(String)
// 126:       end
// 127:
// 128:       sig { returns(T.nilable(Symbol)) }
// 129:       def min_severity
// 130:         raw = args.severity
// 131:         return if raw.nil?
// 132:
// 133:         raw = raw.downcase
// 134:         raise UsageError, "`--severity` must be one of: #{SEVERITIES.join(", ")}" unless SEVERITIES.include?(raw)
// 135:
// 136:         raw.to_sym
// 137:       end
// 138:
// 139:       sig { returns(Integer) }
// 140:       def max_summary
// 141:         raw = args.max_summary
// 142:         return Homebrew::Vulns::Output::DEFAULT_MAX_SUMMARY if raw.nil?
// 143:
// 144:         raise UsageError, "`--max-summary` must be a non-negative integer" unless raw.match?(/\A\d+\z/)
// 145:
// 146:         raw.to_i
// 147:       end
// 148:     end
// 149:   end
// 150: end
