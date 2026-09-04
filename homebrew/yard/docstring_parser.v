module yard

import ruby

// Translated from Homebrew/brew `yard/docstring_parser.rb`.

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

fn yard_docstring_result_value(result YardDocstringResult) ruby.Value {
	return ruby.structured_value('YARD::DocstringParser::Result', result.content, {
		'content':    result.content
		'tags':       result.tags.map('${it.name}:${it.text}').join('\n')
		'directives': result.directives.map('${it.name}:${it.text}').join('\n')
		'warnings':   result.warnings.join('\n')
	})
}
