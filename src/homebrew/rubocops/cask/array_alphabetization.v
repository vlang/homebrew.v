module cask

import brew_runtime

// Translated from Homebrew/brew `rubocops/cask/array_alphabetization.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `on_send(node)` at line 11.
pub fn ruby_array_alphabetization_l11_d1_on_send(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('on_send', ...args)
}

// Ruby method `sort_array(source)` at line 39.
pub fn ruby_array_alphabetization_l39_d2_sort_array(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sort_array', ...args)
}

// Ruby method `recursively_find_comments(source, index, line)` at line 69.
pub fn ruby_array_alphabetization_l69_d3_recursively_find_comments(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('recursively_find_comments', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     module Cask
// 7:       class ArrayAlphabetization < Base
// 8:         extend AutoCorrector
// 9:
// 10:         sig { params(node: RuboCop::AST::SendNode).void }
// 11:         def on_send(node)
// 12:           return unless [:conflicts_with, :uninstall, :zap].include?(node.method_name)
// 13:
// 14:           node.each_descendant(:pair).each do |pair|
// 15:             symbols = pair.children.select(&:sym_type?).map(&:value)
// 16:             next if symbols.intersect?([:signal, :script, :early_script, :args, :input])
// 17:
// 18:             pair.each_descendant(:array).each do |array|
// 19:               if array.children.length == 1
// 20:                 add_offense(array, message: "Avoid single-element arrays by removing the []") do |corrector|
// 21:                   corrector.replace(array.source_range, array.children.first.source)
// 22:                 end
// 23:               end
// 24:
// 25:               next if array.children.length <= 1
// 26:
// 27:               sorted_array = sort_array(array.source.split("\n")).join("\n")
// 28:
// 29:               next if array.source == sorted_array
// 30:
// 31:               add_offense(array, message: "The array elements should be ordered alphabetically") do |corrector|
// 32:                 corrector.replace(array.source_range, sorted_array)
// 33:               end
// 34:             end
// 35:           end
// 36:         end
// 37:
// 38:         sig { params(source: T::Array[String]).returns(T::Array[String]) }
// 39:         def sort_array(source)
// 40:           # Combine each comment with the line(s) below so that they remain in the same relative location
// 41:           combined_source = source.each_with_index.filter_map do |line, index|
// 42:             next if line.blank?
// 43:             next if line.strip.start_with?("#")
// 44:
// 45:             next recursively_find_comments(source, index, line)
// 46:           end
// 47:
// 48:           # Separate the lines into those that should be sorted and those that should not
// 49:           # i.e. skip the opening and closing brackets of the array.
// 50:           to_sort, to_keep = combined_source.partition { |line| !line.include?("[") && !line.include?("]") }
// 51:
// 52:           # Sort the lines that should be sorted
// 53:           to_sort.sort! do |a, b|
// 54:             a_non_comment = a.split("\n").reject { |line| line.strip.start_with?("#") }.fetch(0)
// 55:             b_non_comment = b.split("\n").reject { |line| line.strip.start_with?("#") }.fetch(0)
// 56:             a_non_comment.strip.downcase <=> b_non_comment.strip.downcase ||
// 57:               raise("Expected non-comment lines to be present")
// 58:           end
// 59:
// 60:           # Merge the sorted lines and the unsorted lines, preserving the original positions of the unsorted lines
// 61:           combined_source.map do |line|
// 62:             next line if to_keep.include?(line)
// 63:
// 64:             to_sort.shift || raise("Expected to_sort to be present")
// 65:           end
// 66:         end
// 67:
// 68:         sig { params(source: T::Array[String], index: Integer, line: String).returns(String) }
// 69:         def recursively_find_comments(source, index, line)
// 70:           if source.fetch(index - 1).strip.start_with?("#")
// 71:             return recursively_find_comments(source, index - 1, "#{source[index - 1]}\n#{line}")
// 72:           end
// 73:
// 74:           line
// 75:         end
// 76:       end
// 77:     end
// 78:   end
// 79: end
