module strategy

import encoding.xml
import homebrew.livecheck

// Translated from Homebrew/brew `livecheck/strategy/xml.rb`.
// The original source is retained below until every stub has a typed V body.
pub const xml_priority = 0

pub struct XmlRegex {
pub:
	pattern          string
	case_insensitive bool
}

pub type XmlDocumentParser = fn(string) !xml.XMLDocument

pub type XmlVersionsBlock = fn(xml.XMLDocument, ?XmlRegex) !livecheck.StrategyBlockValue

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

// Ruby method `self.match?(url)` at line 49.
pub fn ruby_xml_l49_d1_self_match(url string) bool {
	return xml_matches(url)
}

// Ruby method `self.parse_xml(content)` at line 57.
pub fn ruby_xml_l57_d2_self_parse_xml(content string) !xml.XMLDocument {
	return xml_parse_xml(content)
}

// Ruby method `self.element_text(element, child_path = nil)` at line 91.
pub fn ruby_xml_l91_d3_self_element_text(element xml.XMLNode, child_path ?string) ?string {
	return xml_element_text(element, child_path)
}

// Ruby method `self.versions_from_content(content, regex = nil, &block)` at line 114.
pub fn ruby_xml_l114_d4_self_versions_from_content(request XmlVersionsRequest) ![]string {
	return xml_versions_from_content(request)
}

// Ruby method `self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)` at line 147.
pub fn ruby_xml_l147_d5_self_find_versions(request XmlFindVersionsRequest,
	fetcher livecheck.StrategyContentFetcher) !XmlMatchData {
	return xml_find_versions(request, fetcher)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "livecheck/strategic"
// 5:
// 6: module Homebrew
// 7:   module Livecheck
// 8:     module Strategy
// 9:       # The {Xml} strategy fetches content at a URL, parses it as XML using
// 10:       # `REXML` and provides the `REXML::Document` to a `strategy` block.
// 11:       # If a regex is present in the `livecheck` block, it should be passed
// 12:       # as the second argument to the `strategy` block.
// 13:       #
// 14:       # This is a generic strategy that doesn't contain any logic for finding
// 15:       # versions, as the structure of XML data varies. Instead, a `strategy`
// 16:       # block must be used to extract version information from the XML data.
// 17:       # For more information on how to work with an `REXML::Document` object,
// 18:       # please refer to the [`REXML::Document`](https://ruby.github.io/rexml/REXML/Document.html)
// 19:       # and [`REXML::Element`](https://ruby.github.io/rexml/REXML/Element.html)
// 20:       # documentation.
// 21:       #
// 22:       # This strategy is not applied automatically and it is necessary to use
// 23:       # `strategy :xml` in a `livecheck` block (in conjunction with a
// 24:       # `strategy` block) to use it.
// 25:       #
// 26:       # This strategy's {find_versions} method can be used in other strategies
// 27:       # that work with XML content, so it should only be necessary to write
// 28:       # the version-finding logic that works with the parsed XML data.
// 29:       #
// 30:       # @api public
// 31:       class Xml
// 32:         extend Strategic
// 33:
// 34:         # A priority of zero causes livecheck to skip the strategy. We do this
// 35:         # for {Xml} so we can selectively apply it only when a strategy block
// 36:         # is provided in a `livecheck` block.
// 37:         PRIORITY = 0
// 38:
// 39:         # The `Regexp` used to determine if the strategy applies to the URL.
// 40:         URL_MATCH_REGEX = %r{^https?://}i
// 41:
// 42:         # Whether the strategy can be applied to the provided URL.
// 43:         # {Xml} will technically match any HTTP URL but is only usable with
// 44:         # a `livecheck` block containing a `strategy` block.
// 45:         #
// 46:         # @param url [String] the URL to match against
// 47:         # @return [Boolean]
// 48:         sig { override.params(url: String).returns(T::Boolean) }
// 49:         def self.match?(url)
// 50:           URL_MATCH_REGEX.match?(url)
// 51:         end
// 52:
// 53:         # Parses XML text and returns an `REXML::Document` object.
// 54:         # @param content [String] the XML text to parse
// 55:         # @return [REXML::Document]
// 56:         sig { params(content: String).returns(REXML::Document) }
// 57:         def self.parse_xml(content)
// 58:           parsing_tries = 0
// 59:           begin
// 60:             REXML::Document.new(content)
// 61:           rescue REXML::UndefinedNamespaceException => e
// 62:             undefined_prefix = e.to_s[/Undefined prefix ([^ ]+) found/i, 1]
// 63:             raise "Could not identify undefined prefix." if undefined_prefix.blank?
// 64:
// 65:             # Only retry parsing once after removing prefix from content
// 66:             parsing_tries += 1
// 67:             raise "Could not parse XML after removing undefined prefix." if parsing_tries > 1
// 68:
// 69:             # When an XML document contains a prefix without a corresponding
// 70:             # namespace, it's necessary to remove the prefix from the content
// 71:             # to be able to successfully parse it using REXML
// 72:             content = content.gsub(%r{(</?| )#{Regexp.escape(undefined_prefix)}:}, '\1')
// 73:             retry
// 74:           end
// 75:         end
// 76:
// 77:         # Retrieves the stripped inner text of an `REXML` element. Returns
// 78:         # `nil` if the optional child element doesn't exist or the text is
// 79:         # blank.
// 80:         # @param element [REXML::Element] an `REXML` element to retrieve text
// 81:         #   from, either directly or from a child element
// 82:         # @param child_path [String, nil] the XPath of a child element to
// 83:         #   retrieve text from
// 84:         # @return [String, nil]
// 85:         sig {
// 86:           params(
// 87:             element:    REXML::Element,
// 88:             child_path: T.nilable(String),
// 89:           ).returns(T.nilable(String))
// 90:         }
// 91:         def self.element_text(element, child_path = nil)
// 92:           element = element.get_elements(child_path).first if child_path.present?
// 93:           return if element.nil?
// 94:
// 95:           text = element.text
// 96:           return if text.blank?
// 97:
// 98:           text.strip
// 99:         end
// 100:
// 101:         # Parses XML text and identifies versions using a `strategy` block.
// 102:         # If a regex is provided, it will be passed as the second argument to
// 103:         # the `strategy` block (after the parsed XML data).
// 104:         # @param content [String] the XML text to parse and check
// 105:         # @param regex [Regexp, nil] a regex for use in a strategy block
// 106:         # @return [Array]
// 107:         sig {
// 108:           params(
// 109:             content: String,
// 110:             regex:   T.nilable(Regexp),
// 111:             block:   T.nilable(Proc),
// 112:           ).returns(T::Array[String])
// 113:         }
// 114:         def self.versions_from_content(content, regex = nil, &block)
// 115:           return [] if content.blank? || !block_given?
// 116:
// 117:           require "rexml/document"
// 118:           xml = parse_xml(content)
// 119:
// 120:           block_return_value = if regex.present?
// 121:             yield(xml, regex)
// 122:           elsif block.arity == 2
// 123:             raise "Two arguments found in `strategy` block but no regex provided."
// 124:           else
// 125:             yield(xml)
// 126:           end
// 127:           Strategy.handle_block_return(block_return_value)
// 128:         end
// 129:
// 130:         # Checks the XML content at the URL for versions, using the provided
// 131:         # `strategy` block to extract version information.
// 132:         #
// 133:         # @param url [String] the URL of the content to check
// 134:         # @param regex [Regexp, nil] a regex for matching versions in content
// 135:         # @param content [String, nil] content to check instead of fetching
// 136:         # @param options [Options] options to modify behavior
// 137:         # @return [Hash]
// 138:         sig {
// 139:           override.params(
// 140:             url:     String,
// 141:             regex:   T.nilable(Regexp),
// 142:             content: T.nilable(String),
// 143:             options: Options,
// 144:             block:   T.nilable(Proc),
// 145:           ).returns(T::Hash[Symbol, T.anything])
// 146:         }
// 147:         def self.find_versions(url:, regex: nil, content: nil, options: Options.new, &block)
// 148:           raise ArgumentError, "#{Utils.demodulize(name)} requires a `strategy` block" unless block_given?
// 149:
// 150:           match_data = { matches: {}, regex:, url: }
// 151:           match_data[:cached] = true if content
// 152:           return match_data if url.blank?
// 153:
// 154:           unless match_data[:cached]
// 155:             match_data.merge!(Strategy.page_content(url, options:))
// 156:             content = match_data[:content]
// 157:           end
// 158:           return match_data if content.blank?
// 159:
// 160:           versions_from_content(content, regex, &block).each do |match_text|
// 161:             match_data[:matches][match_text] = Version.new(match_text)
// 162:           end
// 163:
// 164:           match_data
// 165:         end
// 166:       end
// 167:     end
// 168:   end
// 169: end
