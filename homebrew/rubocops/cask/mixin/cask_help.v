module mixin

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/mixin/cask_help.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CaskHelpDispatch {
pub:
	accepted              bool
	cask_block            bool
	on_system_block       bool
	file_path             string
	comments              []string
	stanzas               []ToplevelStanza
	called_stanza_handler bool
	called_cask_handler   bool
}

fn cask_help_block_name(source string) string {
	for line in source.split_into_lines() {
		trimmed := line.all_before('#').trim_space()
		if trimmed == '' {
			continue
		}
		return stanza_dispatch_name(trimmed)
	}
	return ''
}

fn cask_help_comments(source string) []string {
	mut comments := []string{}
	for line in source.split_into_lines() {
		trimmed := line.trim_space()
		if trimmed.starts_with('#') {
			comments << trimmed
		}
	}
	return comments
}

pub fn cask_help_inner_stanzas(source string) []ToplevelStanza {
	lines := source.split_into_lines()
	if lines.len < 2 {
		return []ToplevelStanza{}
	}
	mut candidates := []ToplevelStanza{}
	mut offset := lines[0].len + 1
	mut minimum_indent := int(1 << 30)
	for index in 1 .. lines.len {
		line := lines[index]
		trimmed := line.all_before('#').trim_space()
		if trimmed == '' || trimmed == 'end' {
			offset += line.len + 1
			continue
		}
		indent := line.len - line.trim_left(' \t').len
		if indent < minimum_indent {
			minimum_indent = indent
		}
		name := stanza_dispatch_name(trimmed)
		if name != '' {
			candidates << ToplevelStanza{
				name: name
				source: line.trim_space()
				begin_pos: offset + indent
				end_pos: offset + line.trim_right(' \t').len
			}
		}
		offset += line.len + 1
	}
	return candidates.filter(it.begin_pos - (source[..it.begin_pos].last_index('\n') or { -1 }) - 1 == minimum_indent)
}

pub fn dispatch_cask_help_block(source string, file_path string) CaskHelpDispatch {
	name := cask_help_block_name(source)
	is_cask := name == 'cask'
	is_on_system := name.starts_with('on_')
	if !is_cask && !is_on_system {
		return CaskHelpDispatch{}
	}
	stanzas := if is_cask { cask_toplevel_stanzas(source) } else { cask_help_inner_stanzas(source) }
	return CaskHelpDispatch{
		accepted: true
		cask_block: is_cask
		on_system_block: is_on_system
		file_path: if is_cask { file_path } else { '' }
		comments: cask_help_comments(source)
		stanzas: stanzas
		called_stanza_handler: true
		called_cask_handler: is_cask
	}
}

pub fn cask_help_on_system_methods(stanzas []ToplevelStanza) []ToplevelStanza {
	return stanzas.filter(it.name.starts_with('on_'))
}

pub fn cask_help_tap(file_path string) ?string {
	if file_path.starts_with('/homebrew-') {
		component := file_path[1..].all_before('/')
		if component.len > 'homebrew-'.len {
			return component
		}
	}
	marker := '/Taps/'
	position := file_path.index(marker) or { return none }
	remainder := file_path[position + marker.len..]
	owner_end := remainder.index('/') or { return none }
	after_owner := remainder[owner_end + 1..]
	tap := after_owner.all_before('/')
	if tap.starts_with('homebrew-') && tap.len > 'homebrew-'.len && after_owner.len > tap.len && after_owner[tap.len] == `/` {
		return tap
	}
	return none
}

fn cask_help_dispatch_value(dispatch CaskHelpDispatch) brew_runtime.Value {
	return brew_runtime.structured_value('RuboCop::Cop::Cask::CaskHelpDispatch', if dispatch.accepted {
		'accepted'
	} else {
		'ignored'
	}, {
		'accepted':              dispatch.accepted.str()
		'cask_block':            dispatch.cask_block.str()
		'on_system_block':       dispatch.on_system_block.str()
		'file_path':             dispatch.file_path
		'comment_count':         dispatch.comments.len.str()
		'stanza_count':          dispatch.stanzas.len.str()
		'called_stanza_handler': dispatch.called_stanza_handler.str()
		'called_cask_handler':   dispatch.called_cask_handler.str()
	})
}

// Ruby method `on_cask(cask_block); end` at line 12.
pub fn ruby_cask_help_l12_d1_on_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `on_cask_stanza_block(cask_stanza_block); end` at line 15.
pub fn ruby_cask_help_l15_d2_on_cask_stanza_block(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.object_value('NilClass', 'nil')
}

// Ruby method `on_block(block_node)` at line 18.
pub fn ruby_cask_help_l18_d3_on_block(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	file_path := if args.len > 1 { args[1].as_string() } else { '' }
	return cask_help_dispatch_value(dispatch_cask_help_block(source, file_path))
}

// Ruby alias `alias on_itblock on_block` at line 34.
pub fn ruby_cask_help_l34_d4_on_itblock(args ...brew_runtime.Value) brew_runtime.Value {
	return ruby_cask_help_l18_d3_on_block(...args)
}

// Ruby method `on_system_methods(cask_stanzas)` at line 43.
pub fn ruby_cask_help_l43_d5_on_system_methods(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return stanza_values(cask_help_on_system_methods(cask_toplevel_stanzas(source)))
}

// Ruby method `inner_stanzas(block_node, comments)` at line 55.
pub fn ruby_cask_help_l55_d6_inner_stanzas(args ...brew_runtime.Value) brew_runtime.Value {
	source := if args.len > 0 { args[0].as_string() } else { '' }
	return stanza_values(cask_help_inner_stanzas(source))
}

// Ruby method `cask_tap` at line 62.
pub fn ruby_cask_help_l62_d7_cask_tap(args ...brew_runtime.Value) brew_runtime.Value {
	file_path := if args.len > 0 { args[0].as_string() } else { '' }
	tap := cask_help_tap(file_path) or { return brew_runtime.object_value('NilClass', 'nil') }
	return brew_runtime.string_value(tap)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Cask
// 7:       # Common functionality for cops checking casks.
// 8:       module CaskHelp
// 9:         prepend CommentsHelp # Update the rbi file if changing this: https://github.com/sorbet/sorbet/issues/259
// 10:
// 11:         sig { overridable.params(cask_block: RuboCop::Cask::AST::CaskBlock).void }
// 12:         def on_cask(cask_block); end
// 13:
// 14:         sig { overridable.params(cask_stanza_block: RuboCop::Cask::AST::StanzaBlock).void }
// 15:         def on_cask_stanza_block(cask_stanza_block); end
// 16:
// 17:         sig { params(block_node: RuboCop::AST::BlockNode).void }
// 18:         def on_block(block_node)
// 19:           super if defined? super
// 20:
// 21:           return if !block_node.cask_block? && !block_node.cask_on_system_block?
// 22:
// 23:           comments = comments_in_range(block_node).to_a
// 24:           stanza_block = RuboCop::Cask::AST::StanzaBlock.new(block_node, comments)
// 25:           on_cask_stanza_block(stanza_block)
// 26:
// 27:           return unless block_node.cask_block?
// 28:
// 29:           @file_path = T.let(processed_source.file_path, T.nilable(String))
// 30:
// 31:           cask_block = RuboCop::Cask::AST::CaskBlock.new(block_node, comments)
// 32:           on_cask(cask_block)
// 33:         end
// 34:         alias on_itblock on_block
// 35:
// 36:         sig {
// 37:           params(
// 38:             cask_stanzas: T::Array[RuboCop::Cask::AST::Stanza],
// 39:           ).returns(
// 40:             T::Array[RuboCop::Cask::AST::Stanza],
// 41:           )
// 42:         }
// 43:         def on_system_methods(cask_stanzas)
// 44:           cask_stanzas.select(&:on_system_block?)
// 45:         end
// 46:
// 47:         sig {
// 48:           params(
// 49:             block_node: RuboCop::AST::BlockNode,
// 50:             comments:   T::Array[Parser::Source::Comment],
// 51:           ).returns(
// 52:             T::Array[RuboCop::Cask::AST::Stanza],
// 53:           )
// 54:         }
// 55:         def inner_stanzas(block_node, comments)
// 56:           block_contents = block_node.child_nodes.select(&:begin_type?)
// 57:           inner_nodes = block_contents.map(&:child_nodes).flatten.select(&:send_type?)
// 58:           inner_nodes.map { |n| RuboCop::Cask::AST::Stanza.new(n, comments) }
// 59:         end
// 60:
// 61:         sig { returns(T.nilable(String)) }
// 62:         def cask_tap
// 63:           return unless (match_obj = @file_path&.match(%r{(?:/Taps/[\w-]+|^)/(homebrew-[\w-]+)/}))
// 64:
// 65:           match_obj[1]
// 66:         end
// 67:       end
// 68:     end
// 69:   end
// 70: end
