module translation_integrity_test

import os

const expected_test_tree_files = 894
const expected_spec_files = 654
const expected_ruby_test_files = 1
const expected_test_source_union = 898
const expected_rspec_examples = 7949

fn repository_root() string {
	return os.real_path(os.join_path(os.dir(@FILE), '..'))
}

fn without_rb_suffix(path string) string {
	return if path.ends_with('.rb') { path[..path.len - 3] } else { path }
}

fn translated_relative_path(relative_path string) string {
	mut components := relative_path.split('/')
	for index in 0 .. components.len - 1 {
		components[index] = components[index].to_lower()
	}
	mut translated_path := without_rb_suffix(components.join('/'))
	if translated_path.ends_with('_test') {
		translated_path += '_ruby'
	}
	return translated_path + '.v'
}

fn is_test_source(relative_path string) bool {
	return relative_path.starts_with('test/') || relative_path.ends_with('_spec.rb')
		|| relative_path.ends_with('_test.rb')
}

fn test_every_ruby_test_source_has_a_retained_v_translation() {
	root := repository_root()
	manifest := os.join_path(root, 'translation/manifests/homebrew_all.txt')
	mut test_tree_files := 0
	mut spec_files := 0
	mut ruby_test_files := 0
	mut test_source_union := 0
	for line in os.read_lines(manifest)! {
		relative_path := line.trim_space()
		if relative_path.starts_with('test/') {
			test_tree_files++
		}
		if relative_path.ends_with('_spec.rb') {
			spec_files++
		}
		if relative_path.ends_with('_test.rb') {
			ruby_test_files++
		}
		if !is_test_source(relative_path) {
			continue
		}
		test_source_union++
		target := os.join_path(root, 'src/homebrew', translated_relative_path(relative_path))
		assert os.is_file(target), 'missing V test translation for ${relative_path}'
		translated := os.read_file(target)!
		assert translated.contains('// Translated from Homebrew/brew `${relative_path}`.')
		assert translated.contains('// Original Ruby source (line-for-line):')
	}
	assert test_tree_files == expected_test_tree_files
	assert spec_files == expected_spec_files
	assert ruby_test_files == expected_ruby_test_files
	assert test_source_union == expected_test_source_union
}

fn test_every_rspec_example_has_an_explicit_translation_boundary() {
	root := repository_root()
	manifest := os.join_path(root, 'translation/manifests/homebrew_all.txt')
	mut translated_examples := 0
	for line in os.read_lines(manifest)! {
		relative_path := line.trim_space()
		if !is_test_source(relative_path) {
			continue
		}
		target := os.join_path(root, 'src/homebrew', translated_relative_path(relative_path))
		for translated_line in os.read_lines(target)! {
			if translated_line.starts_with('// Ruby it `')
				|| translated_line.starts_with('// Ruby specify `')
				|| translated_line.starts_with('// Ruby example `') {
				translated_examples++
			}
		}
	}
	assert translated_examples == expected_rspec_examples
}
