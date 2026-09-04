module homebrew

import ruby
import os
import x.json2

// Translated from Homebrew/brew `executables_db.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `initialize(filename)` at line 22.
pub fn ruby_executables_db_l22_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'database filename is required')
	}
	database := load_executables_db(args[0].as_string()) or {
		return ruby.object_value('IOError', err.msg())
	}
	return executables_db_value(database)
}

// Ruby method `to_hash` at line 37.
pub fn ruby_executables_db_l37_d2_to_hash(args ...ruby.Value) ruby.Value {
	database := if args.len > 0 { executables_db_from_value(args[0]) } else { ExecutablesDb{} }
	return executables_hash_value(database.entries)
}

// Ruby method `update!(bottle_json_dir: nil, removed_formulae: [])` at line 42.
pub fn ruby_executables_db_l42_d3_update(args ...ruby.Value) ruby.Value {
	mut database := if args.len > 0 { executables_db_from_value(args[0]) } else { ExecutablesDb{} }
	bottle_json_dir := if args.len > 1 && args[1].type_name !in ['Nil', 'NilClass'] {
		args[1].as_string()
	} else {
		''
	}
	removed_formulae := if args.len > 2 { args[2].as_string_array() or { [] } } else { [] }
	database.update(bottle_json_dir, removed_formulae)
	return executables_db_value(database)
}

// Ruby method `save!` at line 81.
pub fn ruby_executables_db_l81_d4_save(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.object_value('ArgumentError', 'database is required')
	}
	database := executables_db_from_value(args[0])
	database.save() or { return ruby.object_value('IOError', err.msg()) }
	return ruby.object_value('NilClass', '')
}

pub struct ExecutablesDb {
pub:
	filename string
pub mut:
	entries  map[string][]string
	warnings []string
	removed  []string
}

fn executables_db_line(line string) ?(string, []string) {
	colon := line.index_u8(`:`)
	if colon < 0 {
		return none
	}
	mut name := line[..colon]
	if open := name.last_index('(') {
		if name.ends_with(')') {
			name = name[..open]
		}
	}
	if name == '' {
		return none
	}
	executables := if colon + 1 < line.len { line[colon + 1..].fields() } else { [] }
	return name, executables
}

pub fn load_executables_db(filename string) !ExecutablesDb {
	mut database := ExecutablesDb{
		filename: filename
		entries: map[string][]string{}
	}
	if !os.is_file(filename) {
		return database
	}
	contents := os.read_file(filename)!
	for line in contents.split_into_lines() {
		name, executables := executables_db_line(line) or { continue }
		if name !in database.entries {
			database.entries[name] = executables
		}
	}
	return database
}

fn executables_json_string(attributes map[string]json2.Any, key string) string {
	value := attributes[key] or { return '' }
	if value is json2.Null {
		return ''
	}
	return value.str()
}

fn executables_json_strings(value json2.Any) []string {
	if value is []json2.Any {
		return value.map(it.str())
	}
	if value is json2.Null {
		return []
	}
	return [value.str()]
}

fn formula_name_from_bottle_entry(full_name string, entry map[string]json2.Any) string {
	formula := (entry['formula'] or { json2.Any(map[string]json2.Any{}) }).as_map()
	name := executables_json_string(formula, 'name')
	if name != '' {
		return name
	}
	base := os.base(full_name)
	return base.trim_string_right('.rb')
}

fn bottle_entry_executables(entry map[string]json2.Any) ?[]string {
	bottle := (entry['bottle'] or { json2.Any(map[string]json2.Any{}) }).as_map()
	tags := (bottle['tags'] or { json2.Any(map[string]json2.Any{}) }).as_map()
	mut found := false
	mut executables := []string{}
	for _, raw_tag in tags {
		tag := raw_tag.as_map()
		if 'path_exec_files' !in tag {
			continue
		}
		found = true
		raw_paths := tag['path_exec_files'] or { continue }
		for path in executables_json_strings(raw_paths) {
			name := os.base(path)
			if name !in executables {
				executables << name
			}
		}
	}
	if !found {
		return none
	}
	executables.sort()
	return executables
}

pub fn (mut database ExecutablesDb) update(bottle_json_dir string,
	removed_formulae []string) {
	if bottle_json_dir.trim_space() != '' && os.is_dir(bottle_json_dir) {
		mut paths := os.walk_ext(bottle_json_dir, '.bottle.json', hidden: true)
		paths.sort()
		for path in paths {
			contents := os.read_file(path) or {
				database.warnings << 'Skipping ${path}: ${err.msg()}'
				continue
			}
			decoded := json2.decode[json2.Any](contents) or {
				database.warnings << 'Skipping ${path}: ${err.msg()}'
				continue
			}
			for full_name, raw_entry in decoded.as_map() {
				entry := raw_entry.as_map()
				executables := bottle_entry_executables(entry) or {
					database.warnings << 'Skipping ${full_name}: no `path_exec_files` in ${path}'
					continue
				}
				database.entries[formula_name_from_bottle_entry(full_name, entry)] = executables
			}
		}
	}
	mut removals := removed_formulae.clone()
	removals.sort()
	mut seen := []string{}
	for name in removals {
		if name in seen {
			continue
		}
		seen << name
		if name in database.entries {
			database.entries.delete(name)
			database.removed << name
		}
	}
}

pub fn (database ExecutablesDb) to_hash() map[string][]string {
	mut result := map[string][]string{}
	for formula, executables in database.entries {
		result[formula] = executables.clone()
	}
	return result
}

pub fn (database ExecutablesDb) save() ! {
	mut formulae := database.entries.keys()
	formulae.sort()
	mut lines := []string{cap: formulae.len}
	for formula in formulae {
		lines << '${formula}:${database.entries[formula].join(' ')}'
	}
	contents := if lines.len == 0 { '' } else { '${lines.join('\n')}\n' }
	os.write_file(database.filename, contents)!
}

fn executables_hash_value(entries map[string][]string) ruby.Value {
	mut values := map[string]ruby.Value{}
	for formula, executables in entries {
		values[formula] = ruby.string_array_value(executables)
	}
	return ruby.map_value(values)
}

pub fn executables_db_value(database ExecutablesDb) ruby.Value {
	values := database.entries.clone()
	mut boundary := {
		'_filename': ruby.string_value(database.filename)
		'_warnings': ruby.string_array_value(database.warnings)
		'_removed':  ruby.string_array_value(database.removed)
	}
	for formula, executables in values {
		boundary[formula] = ruby.string_array_value(executables)
	}
	return ruby.map_value(boundary)
}

pub fn executables_db_from_value(value ruby.Value) ExecutablesDb {
	values := value.as_map() or { return ExecutablesDb{} }
	mut database := ExecutablesDb{
		filename: if '_filename' in values { values['_filename'].as_string() } else { '' }
		warnings: if '_warnings' in values {
			values['_warnings'].as_string_array() or { [] }} else {
			[]}
		removed: if '_removed' in values {
			values['_removed'].as_string_array() or { [] }} else {
			[]}
	}
	for formula, executables in values {
		if formula.starts_with('_') {
			continue
		}
		database.entries[formula] = executables.as_string_array() or { [] }
	}
	return database
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
