module diagnostic

import brew_runtime

pub struct Remediation {
pub mut:
	text string
pub:
	commands []string
}

pub fn new_remediation(commands []string, text string) &Remediation {
	return &Remediation{
		commands: commands.clone()
		text: text
	}
}

pub fn (remediation Remediation) string() string {
	if remediation.commands.len == 0 && remediation.text == '' {
		return ''
	}
	if remediation.text != '' {
		return remediation.text
	}
	return 'You can solve this by running:\n  ${remediation.commands.join('\n  ')}'
}

pub fn (remediation Remediation) to_value() brew_runtime.Value {
	return brew_runtime.map_value({
		'commands': brew_runtime.string_array_value(remediation.commands)
		'text':     brew_runtime.string_value(remediation.text)
	})
}

pub struct Finding {
pub:
	text        string
	tier        string = '1'
	affects     []string
	links       []string
	remediation ?Remediation
}

pub fn new_finding(text string, tier string, affects []string, links []string,
	remediation ?Remediation) Finding {
	return Finding{
		text: text
		tier: if tier == '' { '1' } else { tier }
		affects: affects.clone()
		links: links.clone()
		remediation: remediation
	}
}

pub fn (finding Finding) to_value() brew_runtime.Value {
	remediation := if value := finding.remediation {
		value.to_value()
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
	return brew_runtime.map_value({
		'text':        brew_runtime.string_value(finding.text)
		'tier':        brew_runtime.string_value(finding.tier)
		'affects':     brew_runtime.string_array_value(finding.affects)
		'links':       brew_runtime.string_array_value(finding.links)
		'remediation': remediation
	})
}

pub fn (finding Finding) string() string {
	remediation := if value := finding.remediation { value.string().trim_space() } else { '' }
	return '${finding.text}\n${remediation}'.trim_right('\n')
}

pub fn support_tier_message(tier string, nix_managed bool, issues_url string) string {
	if tier == '1' {
		return ''
	}
	mut title := 'Tier ${tier}'
	mut slug := 'tier-${tier.to_lower()}'
	mut issue_text := 'You can report issues with Tier ${tier} configurations'
	if tier == 'unsupported' {
		title = 'Unsupported'
		slug = 'unsupported'
		issue_text = 'Do not report any issues'
	}
	if nix_managed {
		issue_text = 'Report issues to the upstream Nix project, not'
	}
	mut message := 'This is a ${title} configuration:\n  https://docs.brew.sh/Support-Tiers#${slug}\n${issue_text} to Homebrew/* repositories!'
	if issues_url != '' {
		message += '\n  ${issues_url}'
	}
	return '${message}\nRead the above document before opening any issues or PRs.\n'
}

fn remediation_value(remediation &Remediation) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::Diagnostic::Finding::Remediation', remediation.string(), {
		'remediation_address': u64(voidptr(remediation)).str()
	})
}

fn remediation_from_value(value brew_runtime.Value) &Remediation {
	address := value.attributes['remediation_address'] or { panic('invalid Remediation receiver') }
	return unsafe { &Remediation(voidptr(address.u64())) }
}

fn finding_value(finding Finding) brew_runtime.Value {
	mut attributes := {
		'text':    finding.text
		'tier':    finding.tier
		'affects': finding.affects.join('\n')
		'links':   finding.links.join('\n')
	}
	if remediation := finding.remediation {
		attributes['remediation_text'] = remediation.text
		attributes['remediation_commands'] = remediation.commands.join('\n')
	}
	return brew_runtime.structured_value('Homebrew::Diagnostic::Finding', finding.string(), attributes)
}

fn finding_from_value(value brew_runtime.Value) Finding {
	remediation := if text := value.attributes['remediation_text'] {
		?Remediation(Remediation{
			text: text
			commands: (value.attributes['remediation_commands'] or { '' }).split('\n').filter(it != '')
		})
	} else {
		none
	}
	return Finding{
		text: value.attributes['text'] or { value.repr }
		tier: value.attributes['tier'] or { '1' }
		affects: (value.attributes['affects'] or { '' }).split('\n').filter(it != '')
		links: (value.attributes['links'] or { '' }).split('\n').filter(it != '')
		remediation: remediation
	}
}

// Translated from Homebrew/brew `diagnostic/finding.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_accessor `attr_accessor :text` at line 12.
pub fn ruby_finding_l12_d1_text(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(remediation_from_value(args[0]).text)
}

// Ruby attr_accessor `attr_accessor :text` at line 12.
pub fn ruby_finding_l12_d2_text(args ...brew_runtime.Value) brew_runtime.Value {
	mut remediation := remediation_from_value(args[0])
	remediation.text = args[1].as_string()
	return args[1]
}

// Ruby attr_reader `attr_reader :commands` at line 15.
pub fn ruby_finding_l15_d3_commands(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(remediation_from_value(args[0]).commands)
}

// Ruby method `initialize(commands: [], text: "")` at line 18.
pub fn ruby_finding_l18_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	options := if args.len > 0 { args[0].map_data.clone() } else { map[string]brew_runtime.Value{} }
	commands := (options['commands'] or { brew_runtime.string_array_value([]) }).as_array() or {
		[]
	}.map(it.as_string())
	text := (options['text'] or { brew_runtime.string_value('') }).as_string()
	return remediation_value(new_remediation(commands, text))
}

// Ruby method `to_s` at line 24.
pub fn ruby_finding_l24_d5_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(remediation_from_value(args[0]).string())
}

// Ruby method `to_h` at line 31.
pub fn ruby_finding_l31_d6_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return remediation_from_value(args[0]).to_value()
}

// Ruby attr_reader `attr_reader :text` at line 37.
pub fn ruby_finding_l37_d7_text(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(finding_from_value(args[0]).text)
}

// Ruby attr_reader `attr_reader :tier` at line 40.
pub fn ruby_finding_l40_d8_tier(args ...brew_runtime.Value) brew_runtime.Value {
	finding := finding_from_value(args[0])
	return if finding.tier.bytes().all(it.is_digit()) {
		brew_runtime.int_value(finding.tier.int())
	} else {
		brew_runtime.string_value(finding.tier)
	}
}

// Ruby attr_reader `attr_reader :affects` at line 43.
pub fn ruby_finding_l43_d9_affects(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(finding_from_value(args[0]).affects)
}

// Ruby attr_reader `attr_reader :links` at line 46.
pub fn ruby_finding_l46_d10_links(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_array_value(finding_from_value(args[0]).links)
}

// Ruby attr_reader `attr_reader :remediation` at line 49.
pub fn ruby_finding_l49_d11_remediation(args ...brew_runtime.Value) brew_runtime.Value {
	remediation := finding_from_value(args[0]).remediation or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	mut value := remediation
	return remediation_value(&value)
}

// Ruby method `initialize(text, tier: 1, affects: [], links: [], remediation: nil)` at line 52.
pub fn ruby_finding_l52_d12_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		panic('Finding#initialize requires text')
	}
	options := if args.len > 1 { args[1].map_data.clone() } else { map[string]brew_runtime.Value{} }
	remediation := if value := options['remediation'] {
		if value.type_name == 'String' {
			?Remediation(Remediation{ text: value.as_string() })
		} else if value.type_name == 'Homebrew::Diagnostic::Finding::Remediation' {
			?Remediation(*remediation_from_value(value))
		} else {
			none
		}
	} else {
		none
	}
	finding := new_finding(args[0].as_string(), (options['tier'] or { brew_runtime.int_value(1) }).as_string(), (options['affects'] or { brew_runtime.string_array_value([]) }).as_array() or {
		[]
	}.map(it.as_string()), (options['links'] or { brew_runtime.string_array_value([]) }).as_array() or {
		[]
	}.map(it.as_string()), remediation)
	return finding_value(finding)
}

// Ruby method `to_h` at line 71.
pub fn ruby_finding_l71_d13_to_h(args ...brew_runtime.Value) brew_runtime.Value {
	return finding_from_value(args[0]).to_value()
}

// Ruby method `to_s` at line 82.
pub fn ruby_finding_l82_d14_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.string_value(finding_from_value(args[0]).string())
}

// Ruby method `self.support_tier_message(tier:)` at line 90.
pub fn ruby_finding_l90_d15_self_support_tier_message(args ...brew_runtime.Value) brew_runtime.Value {
	options := if args.len > 0 { args[0].map_data.clone() } else { map[string]brew_runtime.Value{} }
	tier := (options['tier'] or { brew_runtime.int_value(1) }).as_string()
	message := support_tier_message(tier, (options['nix_managed'] or { brew_runtime.bool_value(false) }).bool_data, (options['issues_url'] or { brew_runtime.string_value('') }).as_string())
	return if message == '' {
		brew_runtime.object_value('NilClass', 'nil')
	} else {
		brew_runtime.string_value(message)
	}
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
