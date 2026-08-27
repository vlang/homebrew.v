module diagnostic

import brew_runtime

// Translated from Homebrew/brew `diagnostic/finding.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_accessor `attr_accessor :text` at line 12.
pub fn ruby_finding_l12_d1_text(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('text', ...args)
}

// Ruby attr_accessor `attr_accessor :text` at line 12.
pub fn ruby_finding_l12_d2_text(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('text=', ...args)
}

// Ruby attr_reader `attr_reader :commands` at line 15.
pub fn ruby_finding_l15_d3_commands(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('commands', ...args)
}

// Ruby method `initialize(commands: [], text: "")` at line 18.
pub fn ruby_finding_l18_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `to_s` at line 24.
pub fn ruby_finding_l24_d5_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby method `to_h` at line 31.
pub fn ruby_finding_l31_d6_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_h', ...args)
}

// Ruby attr_reader `attr_reader :text` at line 37.
pub fn ruby_finding_l37_d7_text(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('text', ...args)
}

// Ruby attr_reader `attr_reader :tier` at line 40.
pub fn ruby_finding_l40_d8_tier(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tier', ...args)
}

// Ruby attr_reader `attr_reader :affects` at line 43.
pub fn ruby_finding_l43_d9_affects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('affects', ...args)
}

// Ruby attr_reader `attr_reader :links` at line 46.
pub fn ruby_finding_l46_d10_links(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('links', ...args)
}

// Ruby attr_reader `attr_reader :remediation` at line 49.
pub fn ruby_finding_l49_d11_remediation(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('remediation', ...args)
}

// Ruby method `initialize(text, tier: 1, affects: [], links: [], remediation: nil)` at line 52.
pub fn ruby_finding_l52_d12_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `to_h` at line 71.
pub fn ruby_finding_l71_d13_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_h', ...args)
}

// Ruby method `to_s` at line 82.
pub fn ruby_finding_l82_d14_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby method `self.support_tier_message(tier:)` at line 90.
pub fn ruby_finding_l90_d15_self_support_tier_message(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.support_tier_message', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   # Module containing diagnostic checks.
// 6:   module Diagnostic
// 7:     extend Utils::Output::Mixin
// 8:
// 9:     class Finding
// 10:       class Remediation
// 11:         sig { returns(String) }
// 12:         attr_accessor :text
// 13:
// 14:         sig { returns(T::Array[String]) }
// 15:         attr_reader :commands
// 16:
// 17:         sig { params(commands: T::Array[String], text: String).void }
// 18:         def initialize(commands: [], text: "")
// 19:           @commands = commands
// 20:           @text = text
// 21:         end
// 22:
// 23:         sig { returns(String) }
// 24:         def to_s
// 25:           return "" if @commands.empty? && @text.empty?
// 26:
// 27:           @text.presence || "You can solve this by running:\n  #{@commands.join("\n  ")}"
// 28:         end
// 29:
// 30:         sig { returns(T::Hash[Symbol, T.any(String, T::Array[String])]) }
// 31:         def to_h
// 32:           { commands:, text: }
// 33:         end
// 34:       end
// 35:
// 36:       sig { returns(String) }
// 37:       attr_reader :text
// 38:
// 39:       sig { returns(T.any(Integer, Symbol)) }
// 40:       attr_reader :tier
// 41:
// 42:       sig { returns(T::Array[String]) }
// 43:       attr_reader :affects
// 44:
// 45:       sig { returns(T::Array[String]) }
// 46:       attr_reader :links
// 47:
// 48:       sig { returns(T.nilable(Remediation)) }
// 49:       attr_reader :remediation
// 50:
// 51:       sig { params(text: String, tier: T.any(Integer, Symbol), affects: T::Array[String], links: T::Array[String], remediation: T.any(T.nilable(Remediation), String)).void }
// 52:       def initialize(text, tier: 1, affects: [], links: [], remediation: nil)
// 53:         @text = text
// 54:         @tier = tier
// 55:         @affects = affects
// 56:         @links = links
// 57:         @remediation ||= T.let(
// 58:           if remediation.is_a?(String)
// 59:             Remediation.new(text: remediation)
// 60:           else
// 61:             remediation
// 62:           end,
// 63:           T.nilable(Homebrew::Diagnostic::Finding::Remediation),
// 64:         )
// 65:       end
// 66:
// 67:       sig {
// 68:         returns(T::Hash[Symbol,
// 69:                         T.any(Integer, Symbol, String, T::Array[String], T.nilable(T::Hash[Symbol, T.any(String, T::Array[String])]))])
// 70:       }
// 71:       def to_h
// 72:         {
// 73:           text:,
// 74:           tier:,
// 75:           affects:,
// 76:           links:,
// 77:           remediation: @remediation&.to_h,
// 78:         }
// 79:       end
// 80:
// 81:       sig { returns(String) }
// 82:       def to_s
// 83:         <<~EOS.rstrip
// 84:           #{text}
// 85:           #{remediation.to_s.strip}
// 86:         EOS
// 87:       end
// 88:
// 89:       sig { params(tier: T.any(Integer, String, Symbol)).returns(T.nilable(String)) }
// 90:       def self.support_tier_message(tier:)
// 91:         return if tier.to_s == "1"
// 92:
// 93:         tier_title, tier_slug, tier_issues = if tier.to_s == "unsupported"
// 94:           ["Unsupported", "unsupported", "Do not report any issues"]
// 95:         else
// 96:           ["Tier #{tier}", "tier-#{tier.to_s.downcase}", "You can report issues with Tier #{tier} configurations"]
// 97:         end
// 98:
// 99:         tier_issues = "Report issues to the upstream Nix project, not" if OS.nix_managed_homebrew?
// 100:
// 101:         <<~EOS
// 102:           This is a #{tier_title} configuration:
// 103:             #{Formatter.url("https://docs.brew.sh/Support-Tiers##{tier_slug}")}
// 104:           #{Formatter.bold("#{tier_issues} to Homebrew/* repositories!")}
// 105:             #{Formatter.url(OS::ISSUES_URL) if defined?(OS::ISSUES_URL)}
// 106:           Read the above document before opening any issues or PRs.
// 107:         EOS
// 108:       end
// 109:     end
// 110:   end
// 111: end
