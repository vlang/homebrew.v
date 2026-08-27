module converter

import brew_runtime

// Translated from Homebrew/brew `manpages/converter/roff.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `convert_header(element, options)` at line 14.
pub fn ruby_roff_l14_d1_convert_header(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('convert_header', ...args)
}

// Ruby method `convert_variable(element, options)` at line 33.
pub fn ruby_roff_l33_d2_convert_variable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('convert_variable', ...args)
}

// Ruby method `convert_a(element, options)` at line 38.
pub fn ruby_roff_l38_d3_convert_a(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('convert_a', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "kramdown/converter/man"
// 5:
// 6: module Homebrew
// 7:   module Manpages
// 8:     module Converter
// 9:       # Converts our Kramdown-like input to roff.
// 10:       class Roff < ::Kramdown::Converter::Man
// 11:         # Override that adds Homebrew metadata for the top level header
// 12:         # and doesn't escape the text inside subheaders.
// 13:         sig { override.params(element: ::Kramdown::Element, options: T::Hash[Symbol, T.untyped]).void }
// 14:         def convert_header(element, options)
// 15:           if element.options[:level] == 1
// 16:             element.attr["data-date"] = Date.today.strftime("%B %Y")
// 17:             element.attr["data-extra"] = "Homebrew"
// 18:             return super
// 19:           end
// 20:
// 21:           result = +""
// 22:           inner(element, options.merge(result:))
// 23:           result.gsub!(" [", ' \fR[') # make args not bold
// 24:
// 25:           options[:result] << if element.options[:level] == 2
// 26:             macro("SH", quote(result))
// 27:           else
// 28:             macro("SS", quote(result))
// 29:           end
// 30:         end
// 31:
// 32:         sig { params(element: ::Kramdown::Element, options: T::Hash[Symbol, T.untyped]).void }
// 33:         def convert_variable(element, options)
// 34:           options[:result] << "\\fI#{escape(element.value)}\\fP"
// 35:         end
// 36:
// 37:         sig { override.params(element: ::Kramdown::Element, options: T::Hash[Symbol, T.untyped]).void }
// 38:         def convert_a(element, options)
// 39:           if element.attr["href"].chr == "#"
// 40:             # Hide internal links - just make them italicised
// 41:             convert_em(element, options)
// 42:           else
// 43:             super
// 44:             # Remove the space after links if the next character is not a space
// 45:             if options[:result].end_with?(".UE\n") &&
// 46:                (next_element = options[:next]) &&
// 47:                next_element.type == :text &&
// 48:                next_element.value.chr.present? # i.e. not a space character
// 49:               options[:result].chomp!
// 50:               options[:result] << " "
// 51:             end
// 52:           end
// 53:         end
// 54:       end
// 55:     end
// 56:   end
// 57: end
