module yard

import brew_runtime

// Translated from Homebrew/brew `yard/docstring_parser.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `parse_content(content)` at line 25.
pub fn ruby_docstring_parser_l25_d1_parse_content(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parse_content', ...args)
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
