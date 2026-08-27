module homebrew

import brew_runtime

// Translated from Homebrew/brew `executables_db.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(filename)` at line 22.
pub fn ruby_executables_db_l22_d1_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `to_hash` at line 37.
pub fn ruby_executables_db_l37_d2_to_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_hash', ...args)
}

// Ruby method `update!(bottle_json_dir: nil, removed_formulae: [])` at line 42.
pub fn ruby_executables_db_l42_d3_update(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('update!', ...args)
}

// Ruby method `save!` at line 81.
pub fn ruby_executables_db_l81_d4_save(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('save!', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # License: MIT
// 5: # The license text can be found in Library/Homebrew/command-not-found/LICENSE
// 6:
// 7: require "utils/output"
// 8:
// 9: module Homebrew
// 10:   # ExecutablesDB represents a DB associating formulae to the binaries they
// 11:   # provide.
// 12:   class ExecutablesDB
// 13:     include Utils::Output::Mixin
// 14:
// 15:     DB_LINE_REGEX = /^(?<name>.*?)(?:\([^)]*\))?:(?<exes_line>.*)?$/
// 16:
// 17:     # initialize a new DB with the given filename. The file will be used to
// 18:     # populate the DB if it exists. It'll be created or overridden when saving the
// 19:     # DB.
// 20:     # @see #save!
// 21:     sig { params(filename: String).void }
// 22:     def initialize(filename)
// 23:       @filename = filename
// 24:       @exes = T.let({}, T::Hash[String, T::Array[String]])
// 25:
// 26:       return unless File.file? @filename
// 27:
// 28:       File.new(@filename).each do |line|
// 29:         matches = line.match DB_LINE_REGEX
// 30:         next unless matches
// 31:
// 32:         @exes[matches[:name].to_s] ||= matches[:exes_line]&.split || []
// 33:       end
// 34:     end
// 35:
// 36:     sig { returns(T::Hash[String, T::Array[String]]) }
// 37:     def to_hash
// 38:       @exes.transform_values(&:dup)
// 39:     end
// 40:
// 41:     sig { params(bottle_json_dir: T.nilable(String), removed_formulae: T::Array[String]).void }
// 42:     def update!(bottle_json_dir: nil, removed_formulae: [])
// 43:       if (json_dir = bottle_json_dir.presence) && Pathname(json_dir).directory?
// 44:         Dir[File.join(json_dir, "**", "*.bottle.json")].each do |path|
// 45:           bottle_json = begin
// 46:             T.cast(JSON.parse(File.read(path)), T::Hash[String, T::Hash[String, T.untyped]])
// 47:           rescue JSON::ParserError => e
// 48:             opoo "Skipping #{path}: #{e.message}"
// 49:             next
// 50:           end
// 51:
// 52:           bottle_json.each do |full_name, hash|
// 53:             path_exec_file_tags = T.cast(
// 54:               hash.dig("bottle", "tags") || {},
// 55:               T::Hash[String, T::Hash[String, T.untyped]],
// 56:             ).values.select { |tag_hash| tag_hash.key?("path_exec_files") }
// 57:
// 58:             if path_exec_file_tags.empty?
// 59:               opoo "Skipping #{full_name}: no `path_exec_files` in #{path}"
// 60:               next
// 61:             end
// 62:
// 63:             @exes[hash.dig("formula", "name").to_s.presence || File.basename(full_name, ".rb")] =
// 64:               path_exec_file_tags.flat_map { |tag_hash| Array(tag_hash["path_exec_files"]) }
// 65:                                  .map { |file| File.basename(file.to_s) }
// 66:                                  .uniq
// 67:                                  .sort
// 68:           end
// 69:         end
// 70:       end
// 71:
// 72:       removed_formulae.uniq.sort.each do |name|
// 73:         next unless @exes.delete(name)
// 74:
// 75:         puts "Removed #{name}"
// 76:       end
// 77:     end
// 78:
// 79:     # save the DB in the underlying file
// 80:     sig { void }
// 81:     def save!
// 82:       File.open(@filename, "w") do |f|
// 83:         @exes.sort.each do |formula, binaries|
// 84:           f.write "#{formula}:#{binaries.join(" ")}\n"
// 85:         end
// 86:       end
// 87:     end
// 88:   end
// 89: end
