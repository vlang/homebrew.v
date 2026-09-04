module translation_integrity_test

import os

fn repository_root() string {
	return os.real_path(os.join_path(os.dir(@FILE), '..'))
}

fn production_v_files() []string {
	root := repository_root()
	mut files := os.walk_ext(root, '.v')
	files = files.filter(!it.contains('/.git/') && !it.ends_with('_test.v')
		&& !it.contains('/homebrew/test/') && !it.contains('/homebrew/vendor/'))
	files.sort()
	return files
}

fn identifier_tokens(contents string) []string {
	mut tokens := []string{}
	mut start := -1
	for index, character in contents.bytes() {
		identifier := character.is_alnum() || character == `_`
		if identifier && start < 0 {
			start = index
		} else if !identifier && start >= 0 {
			tokens << contents[start..index]
			start = -1
		}
	}
	if start >= 0 {
		tokens << contents[start..]
	}
	return tokens
}

fn is_generated_boundary(name string) bool {
	if !name.starts_with('ruby_') {
		return false
	}
	line_marker := name.index('_l') or { return false }
	after_line := name[line_marker + 2..]
	definition_marker := after_line.index('_d') or { return false }
	after_definition := after_line[definition_marker + 2..]
	name_marker := after_definition.index('_') or { return false }
	line_number := after_line[..definition_marker]
	definition_number := after_definition[..name_marker]
	if line_number == '' || definition_number == '' {
		return false
	}
	return line_number.bytes().all(it.is_digit()) && definition_number.bytes().all(it.is_digit())
}

fn test_removed_translation_scaffolding_stays_removed() {
	root := repository_root()
	assert os.walk_ext(os.join_path(root, 'homebrew', 'test'), '.v').len == 0
	assert os.walk_ext(os.join_path(root, 'homebrew', 'vendor'), '.v').len == 0
	for file in production_v_files() {
		contents := os.read_file(file)!
		assert !contents.contains('// Original Ruby source (line-for-line):')
		assert !contents.contains('ruby.unimplemented_fn(')
	}
}

fn test_generated_boundaries_have_production_callers() {
	mut occurrences := map[string]int{}
	mut definitions := []string{}
	for file in production_v_files() {
		contents := os.read_file(file)!
		for token in identifier_tokens(contents) {
			if is_generated_boundary(token) {
				occurrences[token]++
			}
		}
		for line in contents.split_into_lines() {
			if line.starts_with('pub fn ruby_') {
				name := line.all_after('pub fn ').all_before('[').all_before('(')
				if is_generated_boundary(name) {
					definitions << name
				}
			}
		}
	}
	assert definitions.len > 0
	for name in definitions {
		assert occurrences[name] > 1, 'generated boundary `${name}` has no production caller'
	}
}
