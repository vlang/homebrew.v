module strategy

import encoding.xml
import homebrew.livecheck

// Translated from Homebrew/brew `livecheck/strategy/xml.rb`.
pub const xml_priority = 0

pub struct XmlRegex {
pub:
	pattern          string
	case_insensitive bool
}

pub type XmlDocumentParser = fn (string) !xml.XMLDocument

pub type XmlVersionsBlock = fn (xml.XMLDocument, ?XmlRegex) !livecheck.StrategyBlockValue

pub struct XmlVersionsRequest {
pub:
	content     string
	regex       ?XmlRegex
	has_block   bool
	block_arity int
	block       XmlVersionsBlock = unsafe { nil }
}

pub struct XmlFindVersionsRequest {
pub:
	url         string
	regex       ?XmlRegex
	content     ?string
	options     livecheck.StrategyOptions
	has_block   bool
	block_arity int
	block       XmlVersionsBlock = unsafe { nil }
}

pub struct XmlMatchData {
pub:
	matches       map[string]string
	regex         ?XmlRegex
	url           string
	cached        bool
	has_cached    bool
	content       string
	has_content   bool
	final_url     string
	has_final_url bool
	messages      []string
	has_messages  bool
}

fn xml_default_parser(content string) !xml.XMLDocument {
	return xml.XMLDocument.from_string(content)
}

fn xml_undefined_prefix(message string) string {
	marker := 'Undefined prefix '
	start := message.to_lower().index(marker.to_lower()) or { return '' }
	remaining := message[start + marker.len..]
	end := remaining.index_any(' :.,;\t\r\n')
	return if end < 0 { remaining } else { remaining[..end] }
}

fn xml_remove_prefix(content string, prefix string) string {
	if prefix == '' {
		return content
	}
	return content.replace('<${prefix}:', '<').replace('</${prefix}:', '</').replace(' ${prefix}:', ' ')
}

pub fn xml_parse_xml_with(content string, parser XmlDocumentParser) !xml.XMLDocument {
	mut source := content
	mut parsing_tries := 0
	for {
		document := parser(source) or {
			prefix := xml_undefined_prefix(err.msg())
			if prefix == '' {
				if err.msg().to_lower().contains('undefined') {
					return error('Could not identify undefined prefix.')
				}
				return err
			}
			parsing_tries++
			if parsing_tries > 1 {
				return error('Could not parse XML after removing undefined prefix.')
			}
			source = xml_remove_prefix(source, prefix)
			continue
		}
		return document
	}
	return error('Could not parse XML.')
}

pub fn xml_parse_xml(content string) !xml.XMLDocument {
	return xml_parse_xml_with(content, xml_default_parser)
}

fn xml_local_name(name string) string {
	return name.all_after_last(':')
}

fn xml_node_with_local_names(node xml.XMLNode) xml.XMLNode {
	mut attributes := map[string]string{}
	for key, value in node.attributes {
		attributes[xml_local_name(key)] = value
	}
	mut children := []xml.XMLNodeContents{}
	for child in node.children {
		if child is xml.XMLNode {
			children << xml.XMLNodeContents(xml_node_with_local_names(child))
		} else {
			children << child
		}
	}
	return xml.XMLNode{
		name: xml_local_name(node.name)
		attributes: attributes
		children: children
	}
}

pub fn xml_strip_prefixes(document xml.XMLDocument) xml.XMLDocument {
	return xml.XMLDocument{
		version: document.version
		encoding: document.encoding
		doctype: document.doctype
		comments: document.comments
		root: xml_node_with_local_names(document.root)
	}
}

fn xml_direct_children(node xml.XMLNode, name string) []xml.XMLNode {
	mut children := []xml.XMLNode{}
	for child in node.children {
		if child is xml.XMLNode && xml_local_name(child.name) == name {
			children << child
		}
	}
	return children
}

pub fn xml_elements(document xml.XMLDocument, path string) []xml.XMLNode {
	parts := path.trim('/').split('/').filter(it != '')
	if parts.len == 0 {
		return []xml.XMLNode{}
	}
	mut current := []xml.XMLNode{}
	if xml_local_name(document.root.name) == parts[0] {
		current << document.root
	} else if path.starts_with('//') {
		current = document.root.get_elements_by_tag(parts[0])
		if current.len == 0 {
			current = document.root.get_elements_by_tag(parts[0].replace(':', ''))
		}
	}
	for part in parts[1..] {
		mut next := []xml.XMLNode{}
		for node in current {
			next << xml_direct_children(node, xml_local_name(part))
		}
		current = next.clone()
	}
	return current
}

pub fn xml_child(element xml.XMLNode, child_name string) ?xml.XMLNode {
	for child in element.children {
		if child is xml.XMLNode && xml_local_name(child.name) == xml_local_name(child_name) {
			return child
		}
	}
	return none
}

pub fn xml_element_text(element xml.XMLNode, child_path ?string) ?string {
	mut selected := element
	if path := child_path {
		if path.trim_space() != '' {
			selected = xml_child(element, path) or { return none }
		}
	}
	for child in selected.children {
		if child is string {
			text := child.trim_space()
			if text != '' {
				return text
			}
		} else if child is xml.XMLCData {
			text := child.text.trim_space()
			if text != '' {
				return text
			}
		}
	}
	return none
}

pub fn xml_matches(url string) bool {
	lower := url.to_lower()
	return lower.starts_with('http://') || lower.starts_with('https://')
}

pub fn xml_versions_from_content(request XmlVersionsRequest) ![]string {
	if request.content.trim_space() == '' || !request.has_block {
		return []string{}
	}
	document := xml_parse_xml(request.content)!
	if request.regex == none && request.block_arity == 2 {
		return error('Two arguments found in `strategy` block but no regex provided.')
	}
	value := request.block(document, request.regex)!
	return livecheck.strategy_handle_block_return(value)
}

pub fn xml_find_versions(request XmlFindVersionsRequest,
	fetcher livecheck.StrategyContentFetcher) !XmlMatchData {
	if !request.has_block {
		return error('Xml requires a `strategy` block')
	}
	mut match_data := XmlMatchData{
		matches: map[string]string{}
		regex: request.regex
		url: request.url
	}
	mut content := ''
	if supplied := request.content {
		match_data = XmlMatchData{ ...match_data, cached: true, has_cached: true }
		content = supplied
	}
	if request.url.trim_space() == '' {
		return match_data
	}
	if !match_data.has_cached {
		page := livecheck.strategy_page_content(request.url, request.options, fetcher)!
		match_data = XmlMatchData{
			...match_data
			content: page.content
			has_content: page.has_content
			final_url: page.final_url
			has_final_url: page.has_final_url
			messages: page.messages.clone()
			has_messages: page.has_messages
		}
		content = page.content
	}
	if content.trim_space() == '' {
		return match_data
	}
	versions := xml_versions_from_content(XmlVersionsRequest{
		content: content
		regex: request.regex
		has_block: true
		block_arity: request.block_arity
		block: request.block
	})!
	mut matches := map[string]string{}
	for version in versions {
		matches[version] = version
	}
	return XmlMatchData{ ...match_data, matches: matches }
}
