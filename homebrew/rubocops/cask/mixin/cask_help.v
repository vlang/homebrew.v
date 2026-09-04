module mixin

import ruby

// Translated from Homebrew/brew `rubocops/cask/mixin/cask_help.rb`.
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

fn cask_help_dispatch_value(dispatch CaskHelpDispatch) ruby.Value {
	return ruby.structured_value('RuboCop::Cop::Cask::CaskHelpDispatch', if dispatch.accepted {
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
