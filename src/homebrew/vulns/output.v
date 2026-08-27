module vulns

import brew_runtime

// Translated from Homebrew/brew `vulns/output.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.text(results, max_summary: DEFAULT_MAX_SUMMARY, io: $stdout)` at line 15.
pub fn ruby_output_l15_d1_self_text(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.text', ...args)
}

// Ruby method `self.json(results, io: $stdout)` at line 53.
pub fn ruby_output_l53_d2_self_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.json', ...args)
}

// Ruby method `self.vuln_json(vuln)` at line 68.
pub fn ruby_output_l68_d3_self_vuln_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.vuln_json', ...args)
}

// Ruby method `self.patched_summary(patched, io:)` at line 79.
pub fn ruby_output_l79_d4_self_patched_summary(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.patched_summary', ...args)
}

// Ruby method `self.truncate(text, max)` at line 91.
pub fn ruby_output_l91_d5_self_truncate(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.truncate', ...args)
}

// Ruby method `self.sanitize(text)` at line 104.
pub fn ruby_output_l104_d6_self_sanitize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.sanitize', ...args)
}

// Ruby method `self.colorize_severity(severity, display)` at line 114.
pub fn ruby_output_l114_d7_self_colorize_severity(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.colorize_severity', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "json"
// 5: require "utils/tty"
// 6: require "vulns/scanner"
// 7: require "vulns/vulnerability"
// 8:
// 9: module Homebrew
// 10:   module Vulns
// 11:     module Output
// 12:       DEFAULT_MAX_SUMMARY = 60
// 13:
// 14:       sig { params(results: Scanner::Results, max_summary: Integer, io: T.any(IO, StringIO)).void }
// 15:       def self.text(results, max_summary: DEFAULT_MAX_SUMMARY, io: $stdout)
// 16:         io.puts "Checking #{Utils.pluralize("package", results.checked, include_count: true)} for vulnerabilities..."
// 17:         if results.skipped.positive?
// 18:           io.puts "(#{Utils.pluralize("package", results.skipped, include_count: true)} " \
// 19:                   "skipped - no supported source URL)"
// 20:         end
// 21:         io.puts
// 22:
// 23:         open = results.findings.select { |f| f.open.any? }
// 24:         patched = results.findings.select { |f| f.patched.any? }
// 25:
// 26:         if open.empty?
// 27:           io.puts patched.empty? ? "No vulnerabilities found." : "No open vulnerabilities found."
// 28:           patched_summary(patched, io:)
// 29:           return
// 30:         end
// 31:
// 32:         total = 0
// 33:         open.sort_by { |f| -f.open.map(&:severity_level).max }.each do |f|
// 34:           io.puts "#{sanitize(f.name)} (#{sanitize(f.version)})"
// 35:           f.open.sort_by { |v| -v.severity_level }.each do |v|
// 36:             total += 1
// 37:             line = "  #{sanitize(v.id)} (#{colorize_severity(v.severity, v.severity_display)})"
// 38:             summary = v.summary
// 39:             line += " - #{truncate(sanitize(summary), max_summary)}" if summary
// 40:             io.puts line
// 41:             io.puts "    Fixed in: #{v.fixed_versions.map { |s| sanitize(s) }.join(", ")}" if v.fixed_versions.any?
// 42:           end
// 43:           io.puts
// 44:         end
// 45:
// 46:         io.puts "Found #{Utils.pluralize("vulnerabilit", total, plural: "ies", singular: "y",
// 47: include_count: true)} " \
// 48:                 "in #{Utils.pluralize("package", open.size, include_count: true)}"
// 49:         patched_summary(patched, io:)
// 50:       end
// 51:
// 52:       sig { params(results: Scanner::Results, io: T.any(IO, StringIO)).void }
// 53:       def self.json(results, io: $stdout)
// 54:         data = results.findings.map do |f|
// 55:           {
// 56:             formula:         f.name,
// 57:             version:         f.version,
// 58:             tag:             f.tag,
// 59:             repo_url:        f.repo_url,
// 60:             vulnerabilities: f.open.map { |v| vuln_json(v) },
// 61:             patched:         f.patched.map { |v| vuln_json(v) },
// 62:           }
// 63:         end
// 64:         io.puts JSON.pretty_generate(data)
// 65:       end
// 66:
// 67:       sig { params(vuln: Vulnerability).returns(T::Hash[Symbol, T.untyped]) }
// 68:       private_class_method def self.vuln_json(vuln)
// 69:         {
// 70:           id:             vuln.id,
// 71:           severity:       vuln.severity_display,
// 72:           summary:        vuln.summary,
// 73:           aliases:        vuln.aliases,
// 74:           fixed_versions: vuln.fixed_versions,
// 75:         }
// 76:       end
// 77:
// 78:       sig { params(patched: T::Array[Scanner::Finding], io: T.any(IO, StringIO)).void }
// 79:       private_class_method def self.patched_summary(patched, io:)
// 80:         return if patched.empty?
// 81:
// 82:         total = patched.sum { |f| f.patched.size }
// 83:         io.puts
// 84:         io.puts "#{total} resolved by formula patches (not counted; pass --no-ignore-patches to include):"
// 85:         patched.sort_by(&:name).each do |f|
// 86:           io.puts "  #{sanitize(f.name)}: #{f.patched.map { |v| sanitize(v.id) }.join(", ")}"
// 87:         end
// 88:       end
// 89:
// 90:       sig { params(text: String, max: Integer).returns(String) }
// 91:       private_class_method def self.truncate(text, max)
// 92:         return text if max <= 0 || text.length <= max
// 93:
// 94:         "#{text.slice(0, max)}..."
// 95:       end
// 96:
// 97:       OSC_7BIT = /\e\][^\a\e]*(?:\a|\e\\)/
// 98:       OSC_8BIT = /\u{009d}[^\a\u{009c}]*(?:\a|\u{009c})/
// 99:       CSI_7BIT = %r{\e\[[0-?]*[ -/]*[@-~]}
// 100:       CSI_8BIT = %r{\u{009b}[0-?]*[ -/]*[@-~]}
// 101:       private_constant :OSC_7BIT, :OSC_8BIT, :CSI_7BIT, :CSI_8BIT
// 102:
// 103:       sig { params(text: T.untyped).returns(String) }
// 104:       private_class_method def self.sanitize(text)
// 105:         text.to_s
// 106:             .gsub(OSC_7BIT, "")
// 107:             .gsub(OSC_8BIT, "")
// 108:             .gsub(CSI_7BIT, "")
// 109:             .gsub(CSI_8BIT, "")
// 110:             .delete("\e\b\r\a\u{0080}-\u{009f}")
// 111:       end
// 112:
// 113:       sig { params(severity: T.nilable(Symbol), display: String).returns(String) }
// 114:       private_class_method def self.colorize_severity(severity, display)
// 115:         case severity
// 116:         when :critical then "#{Tty.bold}#{Tty.red}#{display}#{Tty.reset}"
// 117:         when :high then "#{Tty.red}#{display}#{Tty.reset}"
// 118:         when :medium then "#{Tty.yellow}#{display}#{Tty.reset}"
// 119:         when :low then "#{Tty.green}#{display}#{Tty.reset}"
// 120:         else display
// 121:         end
// 122:       end
// 123:     end
// 124:   end
// 125: end
