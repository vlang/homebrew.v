module compilers

import ruby
import os
import regex

// Translated from Homebrew/brew `sorbet/tapioca/compilers/rspec_dynamic_matchers.rb`.
fn rspec_matcher_unique_sorted(values []string) []string {
	mut seen := map[string]bool{}
	for value in values {
		seen[value] = true
	}
	mut result := seen.keys()
	result.sort()
	return result
}

fn rspec_matcher_word_byte(value u8) bool {
	return (value >= `a` && value <= `z`) || (value >= `A` && value <= `Z`) || (value >= `0` && value <= `9`) || value == `_`
}

fn rspec_matcher_name_byte(value u8) bool {
	return (value >= `a` && value <= `z`) || (value >= `0` && value <= `9`) || value == `_`
}

fn rspec_matcher_used_in_content(content string) []string {
	mut names := []string{}
	for index := 0; index < content.len; index++ {
		if index > 0 && rspec_matcher_word_byte(content[index - 1]) {
			continue
		}
		prefix := if content[index..].starts_with('be_') {
			'be_'
		} else if content[index..].starts_with('have_') {
			'have_'
		} else {
			continue
		}
		mut end := index + prefix.len
		for end < content.len && rspec_matcher_name_byte(content[end]) {
			end++
		}
		if end > index + prefix.len && (end == content.len || !rspec_matcher_word_byte(content[end])) {
			names << content[index..end]
		}
	}
	return names
}

fn rspec_matcher_declarations_in_content(content string) []string {
	patterns := [r'(RSpec::Matchers\.)?define[ \t\r\n]+:[a-z][a-z0-9_]*[!?]?',
		r'(RSpec::Matchers\.)?define_negated_matcher[ \t\r\n]+:[a-z][a-z0-9_]*[!?]?',
		r'(RSpec::Matchers\.)?alias_matcher[ \t\r\n]+:[a-z][a-z0-9_]*[!?]?',
		r'matcher[ \t\r\n]+:[a-z][a-z0-9_]*[!?]?']
	mut names := []string{}
	for pattern in patterns {
		mut expression := regex.regex_opt(pattern) or { continue }
		for matched in expression.find_all_str(content) {
			colon := matched.last_index(':') or { continue }
			names << matched[colon + 1..]
		}
	}
	return names
}

fn rspec_matcher_known_in_content(content string) []string {
	mut names := []string{}
	for line in content.split_into_lines() {
		trimmed := line.trim_space()
		if !trimmed.starts_with('def ') {
			continue
		}
		mut end := 4
		if end >= trimmed.len || trimmed[end] < `a` || trimmed[end] > `z` {
			continue
		}
		for end < trimmed.len && rspec_matcher_name_byte(trimmed[end]) {
			end++
		}
		if end < trimmed.len && (trimmed[end] == `!` || trimmed[end] == `?`) {
			end++
		}
		names << trimmed[4..end]
	}
	return names
}

pub fn rspec_matcher_declaration_files(test_root string) []string {
	if !os.is_dir(test_root) {
		return []
	}
	mut files := os.walk_ext(test_root, '.rb', hidden: true)
	files = files.filter(os.is_file(it))
	files.sort()
	return files
}

pub fn rspec_used_matchers(test_root string) ![]string {
	mut matchers := []string{}
	for file in rspec_matcher_declaration_files(test_root) {
		if !file.ends_with('_spec.rb') {
			continue
		}
		matchers << rspec_matcher_used_in_content(os.read_file(file)!)
	}
	return rspec_matcher_unique_sorted(matchers)
}

pub fn rspec_declared_dynamic_matchers(test_root string) ![]string {
	mut matchers := []string{}
	for file in rspec_matcher_declaration_files(test_root) {
		matchers << rspec_matcher_declarations_in_content(os.read_file(file)!)
	}
	return rspec_matcher_unique_sorted(matchers)
}

pub fn rspec_known_matchers(rbi_root string) ![]string {
	mut matchers := []string{}
	mut files := os.glob(os.join_path(rbi_root, 'rspec-expectations@*.rbi'))!
	files.sort()
	for file in files {
		matchers << rspec_matcher_known_in_content(os.read_file(file)!)
	}
	return rspec_matcher_unique_sorted(matchers)
}

pub fn rspec_missing_matchers(test_root string, rbi_root string) ![]string {
	mut known := map[string]bool{}
	for name in rspec_known_matchers(rbi_root)! {
		known[name] = true
	}
	mut missing := []string{}
	for name in rspec_used_matchers(test_root)! {
		if name !in known {
			missing << name
		}
	}
	for name in rspec_declared_dynamic_matchers(test_root)! {
		if name !in known {
			missing << name
		}
	}
	return rspec_matcher_unique_sorted(missing)
}

pub fn rspec_dynamic_matchers_decoration(test_root string,
	rbi_root string) !TapiocaDecoration {
	return TapiocaDecoration{
		constant_name: 'RSpec::Matchers'
		kind: 'path'
		methods: rspec_missing_matchers(test_root, rbi_root)!.map(TapiocaGeneratedMethod{
			name: it
			parameters: ['*args: T.untyped', '&block: T.untyped']
		})
	}
}

fn rspec_matcher_roots(args []ruby.Value) (string, string) {
	return if args.len > 0 { args[0].as_string() } else { 'homebrew/test' }, if args.len > 1 {
		args[1].as_string()
	} else {
		'homebrew/sorbet/rbi/gems'
	}
}
