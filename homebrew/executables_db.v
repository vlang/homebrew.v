module homebrew

import ruby
import os
import x.json2

// Translated from Homebrew/brew `executables_db.rb`.

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
			values['_warnings'].as_string_array() or { [] }
		} else {
			[]
		}
		removed: if '_removed' in values {
			values['_removed'].as_string_array() or { [] }
		} else {
			[]
		}
	}
	for formula, executables in values {
		if formula.starts_with('_') {
			continue
		}
		database.entries[formula] = executables.as_string_array() or { [] }
	}
	return database
}
