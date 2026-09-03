module cask

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/no_overrides.rb`.
// The original source is retained below until every stub has a typed V body.
pub const no_overrides_message_template = 'Do not use a top-level `%s` stanza as the default. Add it to an `on_{system}` block instead. Use `:or_older` or `:or_newer` to specify a range of macOS versions.'
pub const no_overrides_macos_message = 'Do not use a `depends_on macos:` stanza inside an `on_{system}` block. Add it once to specify the oldest macOS supported by any version in the cask.'

pub struct NoOverridesOffense {
pub:
	stanza      string
	begin_pos   int
	end_pos     int
	message     string
	replacement string
}

struct NoOverridesCall {
	name        string
	begin_pos   int
	end_pos     int
	ancestors   []string
	opens_block bool
}

struct NoOverridesAnalysis {
	offenses []NoOverridesOffense
	names    []string
}

fn no_overrides_overridable_methods() []string {
	return ['appcast', 'arch', 'auto_updates', 'container', 'desc', 'homepage', 'os', 'sha256',
		'url', 'version']
}

fn no_overrides_on_system_methods() []string {
	return ['on_arm', 'on_intel', 'on_golden_gate', 'on_tahoe', 'on_sequoia', 'on_sonoma',
		'on_ventura', 'on_monterey', 'on_big_sur', 'on_catalina', 'on_macos', 'on_linux']
}

fn no_overrides_identifier_start(character u8) bool {
	return character.is_letter() || character == `_`
}

fn no_overrides_identifier_character(character u8) bool {
	return character.is_alnum() || character == `_` || character == `!` || character == `?`
}

fn no_overrides_code_end(source string, line_start int, line_end int) int {
	mut cursor := line_start
	mut quote := u8(0)
	mut escaped := false
	mut interpolation_depth := 0
	for cursor < line_end {
		character := source[cursor]
		if quote != 0 {
			if escaped {
				escaped = false
			} else if character == `\\` {
				escaped = true
			} else if quote == `"` && character == `#` && cursor + 1 < line_end && source[cursor + 1] == `{` {
				interpolation_depth++
				cursor += 2
				continue
			} else if interpolation_depth > 0 && character == `}` {
				interpolation_depth--
			} else if interpolation_depth == 0 && character == quote {
				quote = 0
			}
		} else if character == `'` || character == `"` {
			quote = character
		} else if character == `#` {
			return cursor
		}
		cursor++
	}
	return line_end
}

fn no_overrides_leading_call(source string, line_start int, line_end int, ancestors []string) ?NoOverridesCall {
	code_end := no_overrides_code_end(source, line_start, line_end)
	mut begin_pos := line_start
	for begin_pos < code_end && (source[begin_pos] == ` ` || source[begin_pos] == `\t`) {
		begin_pos++
	}
	if begin_pos >= code_end || !no_overrides_identifier_start(source[begin_pos]) {
		return none
	}
	mut method_end := begin_pos + 1
	for method_end < code_end && no_overrides_identifier_character(source[method_end]) {
		method_end++
	}
	name := source[begin_pos..method_end]
	if name in ['end', 'else', 'elsif', 'when', 'rescue', 'ensure'] {
		return none
	}
	if method_end < code_end && !source[method_end].is_space() && source[method_end] !in [
		`(`,
		`{`,
	] {
		return none
	}
	mut end_pos := code_end
	for end_pos > method_end && (source[end_pos - 1] == ` ` || source[end_pos - 1] == `\t` || source[end_pos - 1] == `\r`) {
		end_pos--
	}
	code := source[begin_pos..end_pos]
	keyword_block := name in ['if', 'unless', 'case', 'begin', 'while', 'until', 'for', 'def', 'class',
		'module']
	return NoOverridesCall{
		name: name
		begin_pos: begin_pos
		end_pos: end_pos
		ancestors: ancestors.clone()
		opens_block: keyword_block || code.ends_with(' do') || code.contains(' do |')
	}
}

fn no_overrides_macos_value(source string, call NoOverridesCall) ?string {
	if call.name != 'depends_on' {
		return none
	}
	mut cursor := call.begin_pos + call.name.len
	for cursor < call.end_pos {
		if source[cursor] == `'` || source[cursor] == `"` {
			quote := source[cursor]
			cursor++
			mut escaped := false
			for cursor < call.end_pos {
				if escaped {
					escaped = false
				} else if source[cursor] == `\\` {
					escaped = true
				} else if source[cursor] == quote {
					cursor++
					break
				}
				cursor++
			}
			continue
		}
		if source[cursor..call.end_pos].starts_with('macos:') && (cursor == call.begin_pos || !no_overrides_identifier_character(source[cursor - 1])) {
			cursor += 'macos:'.len
			for cursor < call.end_pos && source[cursor].is_space() {
				cursor++
			}
			value_begin := cursor
			mut quote := u8(0)
			mut escaped := false
			mut nesting := 0
			for cursor < call.end_pos {
				character := source[cursor]
				if quote != 0 {
					if escaped {
						escaped = false
					} else if character == `\\` {
						escaped = true
					} else if character == quote {
						quote = 0
					}
				} else if character == `'` || character == `"` {
					quote = character
				} else if character in [`[`, `{`, `(`] {
					nesting++
				} else if character in [`]`, `}`, `)`] {
					if nesting == 0 {
						break
					}
					nesting--
				} else if nesting == 0 && character == `,` {
					break
				}
				cursor++
			}
			mut value_end := cursor
			for value_end > value_begin && source[value_end - 1].is_space() {
				value_end--
			}
			if value_begin < value_end {
				return source[value_begin..value_end]
			}
			return none
		}
		cursor++
	}
	return none
}

fn no_overrides_has_ancestor(call NoOverridesCall, name string) bool {
	return call.ancestors.contains(name)
}

fn no_overrides_root_system(call NoOverridesCall) string {
	if call.ancestors.len == 0 {
		return ''
	}
	// CaskHelp#on_system_methods only selects direct children of the cask block.
	index := if call.ancestors[0] == 'cask' { 1 } else { 0 }
	if index < call.ancestors.len && no_overrides_on_system_methods().contains(call.ancestors[index]) {
		return call.ancestors[index]
	}
	return ''
}

fn no_overrides_unique(values []string) []string {
	mut result := []string{}
	for value in values {
		if !result.contains(value) {
			result << value
		}
	}
	return result
}

fn no_overrides_calls(source string) []NoOverridesCall {
	mut calls := []NoOverridesCall{}
	mut ancestors := []string{}
	mut line_start := 0
	for line_start < source.len {
		newline := source[line_start..].index_u8(`\n`)
		line_end := if newline < 0 { source.len } else { line_start + newline }
		mut content_start := line_start
		for content_start < line_end && (source[content_start] == ` ` || source[content_start] == `\t`) {
			content_start++
		}
		code_end := no_overrides_code_end(source, line_start, line_end)
		trimmed := source[content_start..code_end].trim_space()
		if trimmed == 'end' || trimmed.starts_with('end ') {
			if ancestors.len > 0 {
				ancestors.delete_last()
			}
		} else if call := no_overrides_leading_call(source, line_start, line_end, ancestors) {
			calls << call
			if call.opens_block {
				ancestors << call.name
			}
		}
		if newline < 0 {
			break
		}
		line_start = line_end + 1
	}
	return calls
}

fn no_overrides_analyze(source string) NoOverridesAnalysis {
	calls := no_overrides_calls(source)
	mut top_level := []NoOverridesCall{}
	mut block_calls := []NoOverridesCall{}
	mut macos_versions := []string{}
	for call in calls {
		if call.ancestors.len == 1 && call.ancestors[0] == 'cask' {
			top_level << call
		}
		root_system := no_overrides_root_system(call)
		if root_system != '' {
			// The Ruby method's first traversal intentionally gathers every nested
			// `depends_on macos:` value before its livecheck/send exclusions.
			if macos := no_overrides_macos_value(source, call) {
				macos_versions << macos
			}
		}
		if root_system == '' || no_overrides_has_ancestor(call, 'livecheck') || call.name == 'livecheck' || no_overrides_on_system_methods().contains(call.name) || call.name in [
			'if',
			'unless',
			'case',
			'begin',
			'while',
			'until',
			'for',
			'def',
			'class',
			'module',
		] {
			continue
		}
		block_calls << call
	}
	allow_macos_depends := macos_versions.len > 1 && no_overrides_unique(macos_versions).len > 1
	mut offenses := []NoOverridesOffense{}
	mut names := []string{}
	for call in block_calls {
		if call.name == 'depends_on' {
			if _ := no_overrides_macos_value(source, call) {
				root := no_overrides_root_system(call)
				if root != 'on_macos' && !allow_macos_depends {
					offenses << NoOverridesOffense{
						stanza: call.name
						begin_pos: call.begin_pos
						end_pos: call.end_pos
						message: no_overrides_macos_message
					}
				}
			}
		}
		if !names.contains(call.name) {
			names << call.name
		}
	}
	for stanza in top_level {
		if no_overrides_overridable_methods().contains(stanza.name) && names.contains(stanza.name) {
			offenses << NoOverridesOffense{
				stanza: stanza.name
				begin_pos: stanza.begin_pos
				end_pos: stanza.end_pos
				message: no_overrides_message_template.replace('%s', stanza.name)
			}
		}
	}
	return NoOverridesAnalysis{
		offenses: offenses
		names: names
	}
}

pub fn audit_no_overrides(source string) []NoOverridesOffense {
	return no_overrides_analyze(source).offenses
}

// NoOverrides does not extend RuboCop's AutoCorrector at the pinned revision.
pub fn correct_no_overrides(source string) string {
	return source
}

fn no_overrides_offense_value(offense NoOverridesOffense) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Offense', offense.message, {
		'stanza':      offense.stanza
		'begin_pos':   offense.begin_pos.str()
		'end_pos':     offense.end_pos.str()
		'message':     offense.message
		'replacement': offense.replacement
	})
}

fn no_overrides_node_ancestry(node brew_runtime.Value) []string {
	path := if 'ancestry' in node.attributes {
		node.attributes['ancestry']
	} else {
		node.as_string()
	}
	return path.split('>').map(it.trim_space()).filter(it != '')
}

fn no_overrides_single_livecheck_node(node brew_runtime.Value) bool {
	path := no_overrides_node_ancestry(node)
	return path.len >= 2 && path[path.len - 2] == 'livecheck'
}

fn no_overrides_multi_livecheck_node(node brew_runtime.Value) bool {
	path := no_overrides_node_ancestry(node)
	return path.len >= 3 && path[path.len - 2] == 'begin' && path[path.len - 3] == 'livecheck'
}

// Ruby method `on_cask(cask_block)` at line 18.
pub fn ruby_no_overrides_l18_d1_on_cask(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.array_value(audit_no_overrides(source).map(no_overrides_offense_value(it)))
}

// Ruby method `on_system_stanzas(on_system)` at line 39.
pub fn ruby_no_overrides_l39_d2_on_system_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return brew_runtime.string_array_value(no_overrides_analyze(source).names)
}

// Ruby method `inside_livecheck_defined?(node)` at line 91.
pub fn ruby_no_overrides_l91_d3_inside_livecheck_defined(args ...brew_runtime.Value) brew_runtime.Value {
	node := if args.len > 0 { args[0] } else { brew_runtime.string_value('') }
	return brew_runtime.bool_value(no_overrides_single_livecheck_node(node) || no_overrides_multi_livecheck_node(node))
}

// Ruby method `single_stanza_livecheck_defined?(node)` at line 96.
pub fn ruby_no_overrides_l96_d4_single_stanza_livecheck_defined(args ...brew_runtime.Value) brew_runtime.Value {
	node := if args.len > 0 { args[0] } else { brew_runtime.string_value('') }
	return brew_runtime.bool_value(no_overrides_single_livecheck_node(node))
}

// Ruby method `multi_stanza_livecheck_defined?(node)` at line 101.
pub fn ruby_no_overrides_l101_d5_multi_stanza_livecheck_defined(args ...brew_runtime.Value) brew_runtime.Value {
	node := if args.len > 0 { args[0] } else { brew_runtime.string_value('') }
	return brew_runtime.bool_value(no_overrides_multi_livecheck_node(node))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Cask
// 7:       class NoOverrides < Base
// 8:         include CaskHelp
// 9:
// 10:         # These stanzas can be overridden by `on_*` blocks, so take them into account.
// 11:         # TODO: Update this list when stanzas in `Cask::DSL` start or stop calling `set_unique_stanza`.
// 12:         OVERRIDABLE_METHODS = [
// 13:           :appcast, :arch, :auto_updates, :container,
// 14:           :desc, :homepage, :os, :sha256, :url, :version
// 15:         ].freeze
// 16:
// 17:         sig { override.params(cask_block: RuboCop::Cask::AST::CaskBlock).void }
// 18:         def on_cask(cask_block)
// 19:           message = "Do not use a top-level `%<stanza>s` stanza as the default. " \
// 20:                     "Add it to an `on_{system}` block instead. " \
// 21:                     "Use `:or_older` or `:or_newer` to specify a range of macOS versions."
// 22:           cask_stanzas = cask_block.toplevel_stanzas
// 23:
// 24:           return if (on_blocks = on_system_methods(cask_stanzas)).none?
// 25:
// 26:           stanzas_in_blocks = on_system_stanzas(on_blocks)
// 27:
// 28:           cask_stanzas.each do |stanza|
// 29:             # Skip if the stanza is not allowed to be overridden.
// 30:             next unless OVERRIDABLE_METHODS.include?(stanza.stanza_name)
// 31:             # Skip if the stanza outside of a block is not also in an `on_*` block.
// 32:             next unless stanzas_in_blocks.include?(stanza.stanza_name)
// 33:
// 34:             add_offense(stanza.source_range, message: format(message, stanza: stanza.stanza_name))
// 35:           end
// 36:         end
// 37:
// 38:         sig { params(on_system: T::Array[RuboCop::Cask::AST::Stanza]).returns(T::Set[Symbol]) }
// 39:         def on_system_stanzas(on_system)
// 40:           message = "Do not use a `depends_on macos:` stanza inside an `on_{system}` block. " \
// 41:                     "Add it once to specify the oldest macOS supported by any version in the cask."
// 42:           names = T.let(Set.new, T::Set[Symbol])
// 43:           method_nodes = on_system.map(&:method_node)
// 44:
// 45:           # Check if multiple `on_{system}` blocks have different `depends_on macos:` versions.
// 46:           # If so, this indicates architecture-specific requirements and is allowed.
// 47:           macos_versions = T.let([], T::Array[String])
// 48:           method_nodes.select(&:block_type?).each do |node|
// 49:             node.child_nodes.each do |child|
// 50:               child.each_node(:send) do |send_node|
// 51:                 next if send_node.method_name != :depends_on
// 52:
// 53:                 macos_pair = send_node.arguments.first.pairs.find { |a| a.key.value == :macos }
// 54:                 macos_versions << macos_pair.value.source if macos_pair
// 55:               end
// 56:             end
// 57:           end
// 58:           # Allow if there are multiple different macOS versions specified
// 59:           allow_macos_depends_in_blocks = macos_versions.size > 1 && macos_versions.uniq.size > 1
// 60:
// 61:           method_nodes.select(&:block_type?).each do |node|
// 62:             node.child_nodes.each do |child|
// 63:               child.each_node(:send) do |send_node|
// 64:                 # Skip (nested) `livecheck` block as its `url` is different
// 65:                 # from a download `url`.
// 66:                 next if send_node.method_name == :livecheck || inside_livecheck_defined?(send_node)
// 67:                 # Skip string interpolations.
// 68:                 if send_node.ancestors.drop_while { |a| !a.begin_type? }.any? { |a| a.dstr_type? || a.regexp_type? }
// 69:                   next
// 70:                 end
// 71:                 next if RuboCop::Cask::Constants::ON_SYSTEM_METHODS.include?(send_node.method_name)
// 72:
// 73:                 if send_node.method_name == :depends_on &&
// 74:                    send_node.arguments.first.pairs.any? { |a| a.key.value == :macos } &&
// 75:                    OnSystemConditionalsHelper::ON_SYSTEM_OPTIONS.map do |m|
// 76:                      :"on_#{m}"
// 77:                    end.include?(T.cast(node, RuboCop::AST::BlockNode).method_name) &&
// 78:                    T.cast(node, RuboCop::AST::BlockNode).method_name != :on_macos && !allow_macos_depends_in_blocks
// 79:                   # Allow `depends_on macos:` in multiple `on_{system}` blocks for architecture-specific requirements
// 80:                   add_offense(send_node.source_range, message:)
// 81:                 end
// 82:
// 83:                 names.add(send_node.method_name)
// 84:               end
// 85:             end
// 86:           end
// 87:           names
// 88:         end
// 89:
// 90:         sig { params(node: RuboCop::AST::Node).returns(T::Boolean) }
// 91:         def inside_livecheck_defined?(node)
// 92:           single_stanza_livecheck_defined?(node) || multi_stanza_livecheck_defined?(node)
// 93:         end
// 94:
// 95:         sig { params(node: RuboCop::AST::Node).returns(T::Boolean) }
// 96:         def single_stanza_livecheck_defined?(node)
// 97:           node.parent.block_type? && node.parent.method_name == :livecheck
// 98:         end
// 99:
// 100:         sig { params(node: RuboCop::AST::Node).returns(T::Boolean) }
// 101:         def multi_stanza_livecheck_defined?(node)
// 102:           grandparent_node = node.parent.parent
// 103:           node.parent.begin_type? && grandparent_node.block_type? && grandparent_node.method_name == :livecheck
// 104:         end
// 105:       end
// 106:     end
// 107:   end
// 108: end
