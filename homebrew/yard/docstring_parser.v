module yard

import brew_runtime

// Translated from Homebrew/brew `yard/docstring_parser.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `parse_content(content)` at line 25.
pub fn ruby_docstring_parser_l25_d1_parse_content(args ...brew_runtime.Value) brew_runtime.Value {
	context := YardDocstringContext{
		content: if args.len > 0 && args[0].type_name !in ['Nil', 'NilClass'] {
			args[0].as_string()} else {
			''}
		object_name: if args.len > 1 { args[1].as_string() } else { '' }
		object_type: if args.len > 2 { args[2].as_string() } else { '' }
		namespace: if args.len > 3 { args[3].as_string() } else { '' }
		source: if args.len > 4 { args[4].as_string() } else { '' }
		handler_present: if args.len > 5 { args[5].as_bool() or { false } } else { false }
		file: if args.len > 6 { args[6].as_string() } else { '' }
		line: if args.len > 7 { int(args[7].as_int() or { 0 }) } else { 0 }
		statement: if args.len > 8 { args[8].as_string() } else { '' }
	}
	result := parse_yard_docstring(context)
	return yard_docstring_result_value(result)
}

pub struct YardTag {
pub:
	name string
	text string
}

pub struct YardDirective {
pub:
	name string
	text string
}

pub struct YardDocstringContext {
pub:
	content          string
	object_name      string
	object_full_name string
	object_type      string
	namespace        string
	source           string
	handler_present  bool
	file             string
	line             int
	statement        string
	tags             []YardTag
	directives       []YardDirective
}

pub struct YardDocstringResult {
pub:
	content    string
	tags       []YardTag
	directives []YardDirective
	warnings   []string
}

const yard_overridable_methods = ['hash', 'inspect', 'to_s', '<=>', '===', '!~', 'eql?', 'equal?',
	'!', '==', '!=']
const yard_self_explanatory_methods = ['to_yaml', 'to_json', 'to_str']

fn convert_yard_plain_text_tags(content string) string {
	mut lines := []string{}
	for line in content.split_into_lines() {
		trimmed := line.trim_space()
		upper := trimmed.to_upper()
		if upper.starts_with('TODO:') {
			lines << '@todo ${trimmed.all_after(':').trim_space()}'
		} else if upper.starts_with('FIXME:') {
			lines << '@todo ${trimmed.all_after(':').trim_space()}'
		} else if upper.starts_with('NOTE:') {
			lines << '@note ${trimmed.all_after(':').trim_space()}'
		} else {
			lines << line
		}
	}
	return lines.join('\n')
}

fn strip_non_documentation_comment(content string) string {
	first_line := content.split_into_lines()[0] or { '' }.trim_space().to_lower()
	if first_line.starts_with('typed:') || first_line.contains('rubocop:') {
		return ''
	}
	return content
}

fn parse_yard_tag_lines(content string, existing []YardTag) (string, []YardTag) {
	mut tags := existing.clone()
	mut prose := []string{}
	for line in content.split_into_lines() {
		trimmed := line.trim_space()
		if trimmed.starts_with('@') {
			separator := trimmed.index_u8(` `)
			name := if separator < 0 { trimmed[1..] } else { trimmed[1..separator] }
			text := if separator < 0 { '' } else { trimmed[separator + 1..].trim_space() }
			tags << YardTag{ name: name, text: text }
		} else {
			prose << line
		}
	}
	return prose.join('\n').trim_right('\n'), tags
}

fn yard_quoted_arguments(source string, keyword string) []string {
	position := source.index(keyword) or { return [] }
	mut remainder := source[position + keyword.len..]
	mut arguments := []string{}
	for arguments.len < 2 {
		start := remainder.index_u8(`"`)
		if start < 0 {
			break
		}
		mut value := ''
		mut escaped := false
		mut end := -1
		for index in start + 1 .. remainder.len {
			character := remainder[index]
			if escaped {
				value += character.ascii_str()
				escaped = false
				continue
			}
			if character == `\\` {
				escaped = true
				continue
			}
			if character == `"` {
				end = index
				break
			}
			value += character.ascii_str()
		}
		if end < 0 {
			break
		}
		arguments << value
		remainder = remainder[end + 1..]
	}
	return arguments
}

fn yard_replace_self(value string, namespace string) string {
	return value.replace('#{self.class}', namespace).replace('#{self}', namespace)
}

fn yard_link_for_backtick(value string, namespace string) ?string {
	if value.len < 2 || value[0] != `\`` || value[value.len - 1] != `\`` {
		return none
	}
	mut method_name := value[1..value.len - 1]
	if method_name.count('.') + method_name.count('#') > 1 {
		return none
	}
	method_name = method_name.trim_string_left(namespace)
	return '{${method_name}}'
}

fn add_yard_deprecation_tag(context YardDocstringContext, mut tags []YardTag) {
	if context.object_type != 'method' || context.object_name == '' {
		return
	}
	mut kind := ''
	mut keyword := ''
	if context.source.contains('odeprecated') {
		kind = 'deprecated'
		keyword = 'odeprecated'
	} else if context.source.contains('odisabled') {
		kind = 'disabled'
		keyword = 'odisabled'
	} else {
		return
	}
	arguments := yard_quoted_arguments(context.source, keyword)
	if arguments.len == 0 {
		return
	}
	mut method := yard_replace_self(arguments[0], context.namespace)
	mut replacement := if arguments.len > 1 {
		yard_replace_self(arguments[1], context.namespace)
	} else {
		''
	}
	if !method.contains(context.object_name) || !method.contains('`') {
		return
	}
	if link := yard_link_for_backtick(method, context.namespace) {
		full_name := if context.object_full_name != '' {
			context.object_full_name
		} else {
			context.object_name
		}
		method = if link.trim('{}').trim_left('.#') == full_name.trim_left('.#') {
			''
		} else {
			link
		}
	}
	if link := yard_link_for_backtick(replacement, context.namespace) {
		replacement = link
	}
	mut description := ''
	if method != '' && !method.contains('#{') {
		description = 'Calling ${method} is ${kind}'
		if replacement != '' && !replacement.contains('#{') {
			description += ', use ${replacement} instead'
		}
		description += '.'
	} else if replacement != '' && !replacement.contains('#{') {
		description = 'Use ${replacement} instead.'
	}
	tags << YardTag{ name: 'deprecated', text: description }
}

pub fn parse_yard_docstring(context YardDocstringContext) YardDocstringResult {
	converted := strip_non_documentation_comment(convert_yard_plain_text_tags(context.content))
	content, parsed_tags := parse_yard_tag_lines(converted, context.tags)
	mut tags := parsed_tags.clone()
	mut directives := context.directives.clone()
	add_yard_deprecation_tag(context, mut tags)
	mut api := ''
	mut is_private := false
	for tag in tags {
		if tag.name == 'api' && api == '' {
			api = tag.text
		}
		if tag.name == 'private' {
			is_private = true
		}
	}
	mut visibility := ''
	for directive in directives {
		if directive.name == 'visibility' {
			visibility = directive.text
			break
		}
	}
	if visibility == '' && context.object_name in yard_overridable_methods {
		directives << YardDirective{ name: 'visibility', text: 'private' }
		visibility = 'private'
	}
	if api == '' && !is_private {
		tags << YardTag{ name: 'api', text: 'private' }
		api = 'private'
	}
	mut warnings := []string{}
	if context.handler_present && api != '' && api != 'private' && visibility != 'private' && content.trim_space() == '' && context.object_name !in yard_self_explanatory_methods {
		warnings << '${api.capitalize()} API should be documented:\n  in `${context.file}`:${context.line}:\n\n${context.statement}\n'
	}
	return YardDocstringResult{
		content: content
		tags: tags
		directives: directives
		warnings: warnings
	}
}

fn yard_docstring_result_value(result YardDocstringResult) brew_runtime.Value {
	return brew_runtime.structured_value('YARD::DocstringParser::Result', result.content, {
		'content':    result.content
		'tags':       result.tags.map('${it.name}:${it.text}').join('\n')
		'directives': result.directives.map('${it.name}:${it.text}').join('\n')
		'warnings':   result.warnings.join('\n')
	})
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "sorbet-runtime"
// 5: require_relative "../extend/module"
// 6:
// 7: # from https://github.com/lsegal/yard/issues/484#issuecomment-442586899
// 8: module Homebrew
// 9:   module YARD
// 10:     class DocstringParser < ::YARD::DocstringParser
// 11:       # Every `Object` has these methods.
// 12:       unless const_defined?(:OVERRIDABLE_METHODS, false)
// 13:         OVERRIDABLE_METHODS = [
// 14:           :hash, :inspect, :to_s,
// 15:           :<=>, :===, :!~, :eql?, :equal?, :!, :==, :!=
// 16:         ].freeze
// 17:         private_constant :OVERRIDABLE_METHODS
// 18:       end
// 19:       unless const_defined?(:SELF_EXPLANATORY_METHODS, false)
// 20:         SELF_EXPLANATORY_METHODS = [:to_yaml, :to_json, :to_str].freeze
// 21:         private_constant :SELF_EXPLANATORY_METHODS
// 22:       end
// 23:
// 24:       sig { params(content: T.nilable(String)).returns(String) }
// 25:       def parse_content(content)
// 26:         # Convert plain text to tags.
// 27:         content = content&.gsub(/^\s*(TODO|FIXME):\s*/i, "@todo ")
// 28:         content = content&.gsub(/^\s*NOTE:\s*/i, "@note ")
// 29:
// 30:         # Ignore non-documentation comments.
// 31:         content = content&.sub(/\A(typed|.*rubocop):.*/m, "")
// 32:
// 33:         content = super
// 34:
// 35:         source = handler&.statement&.source
// 36:
// 37:         if object&.type == :method &&
// 38:            (match = source&.match(/\so(deprecated|disabled)\s+"((?:\\"|[^"])*)"(?:\s*,\s*"((?:\\"|[^"])*))?"/m))
// 39:           type = match[1]
// 40:           method = match[2]
// 41:           method = method.sub(/\#{self(\.class)?}/, object.namespace.to_s)
// 42:           replacement = match[3]
// 43:           replacement = replacement.sub(/\#{self(\.class)?}/, object.namespace.to_s)
// 44:
// 45:           # Only match `odeprecated`/`odisabled` for this method.
// 46:           if method.match?(/(.|#|`)#{Regexp.escape(object.name.to_s)}`/)
// 47:             if (method_name = method[/\A`([^`]*)`\Z/, 1]) && (
// 48:               (method_name.count(".") + method_name.count("#")) <= 1
// 49:             )
// 50:               method_name = method_name.delete_prefix(object.namespace.to_s)
// 51:               method = (method_name.delete_prefix(".") == object.name(true).to_s) ? nil : "{#{method_name}}"
// 52:             end
// 53:
// 54:             if replacement &&
// 55:                (replacement_method_name = replacement[/\A`([^`]*)`\Z/, 1]) && (
// 56:                  (replacement_method_name.count(".") + replacement_method_name.count("#")) <= 1
// 57:                )
// 58:               replacement_method_name = replacement_method_name.delete_prefix(object.namespace.to_s)
// 59:               replacement = "{#{replacement_method_name}}"
// 60:             end
// 61:
// 62:             if method && method.index('#{').nil?
// 63:               description = "Calling #{method} is #{type}"
// 64:               description += ", use #{replacement} instead" if replacement && replacement.index('#{').nil?
// 65:               description += "."
// 66:             elsif replacement && replacement.index('#{').nil?
// 67:               description = "Use #{replacement} instead."
// 68:             else
// 69:               description = ""
// 70:             end
// 71:
// 72:             tags << create_tag("deprecated", description)
// 73:           end
// 74:         end
// 75:
// 76:         api = tags.find { |tag| tag.tag_name == "api" }&.text
// 77:         is_private = tags.any? { |tag| tag.tag_name == "private" }
// 78:         visibility = directives.find { |d| d.tag.tag_name == "visibility" }&.tag&.text
// 79:
// 80:         # Hide `#hash`, `#inspect` and `#to_s`.
// 81:         if visibility.nil? && OVERRIDABLE_METHODS.include?(object&.name)
// 82:           create_directive("visibility", "private")
// 83:           visibility = "private"
// 84:         end
// 85:
// 86:         # Mark everything as `@api private` by default.
// 87:         if api.nil? && !is_private
// 88:           tags << create_tag("api", "private")
// 89:           api = "private"
// 90:         end
// 91:
// 92:         # Warn about undocumented non-private APIs.
// 93:         if handler && api && api != "private" && visibility != "private" &&
// 94:            content.chomp.empty? && SELF_EXPLANATORY_METHODS.none?(object&.name)
// 95:           stmt = handler.statement
// 96:           log.warn "#{api.capitalize} API should be documented:\n  " \
// 97:                    "in `#{handler.parser.file}`:#{stmt.line}:\n\n#{stmt.show}\n"
// 98:         end
// 99:
// 100:         content
// 101:       end
// 102:     end
// 103:   end
// 104: end
// 105:
// 106: YARD::Docstring.default_parser = Homebrew::YARD::DocstringParser
