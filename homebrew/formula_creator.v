module homebrew

import ruby
import os

// Translated from Homebrew/brew `formula_creator.rb`.

pub struct FormulaCreatorOptions {
pub:
	url                string
	name               string
	version            string
	tap                string = 'homebrew/core'
	mode               string
	license            string
	fetch              bool
	head               bool
	latest_release     string
	github_description string
	github_homepage    string
	github_full_name   string
	github_license     string
	tap_installed      bool = true
}

pub struct FormulaCreator {
pub mut:
	name    string
	version string
	url     string
	head    bool
	sha256  string
pub:
	tap                       string
	mode                      string
	fetch                     bool
	version_detected_from_url bool
	github_user               string
	github_repository         string
	desc                      string
	homepage                  string
	license                   string
	tap_installed             bool
}

fn formula_creator_archive_stem(url string) string {
	mut name := url.all_after_last('/').all_before('?').all_before('#')
	for suffix in ['.tar.gz', '.tar.bz2', '.tar.xz', '.tar.zst', '.tgz', '.tbz2', '.txz', '.zip',
		'.gz', '.bz2', '.xz', '.zst', '.tar'] {
		if name.to_lower().ends_with(suffix) {
			name = name[..name.len - suffix.len]
			break
		}
	}
	return name
}

fn formula_creator_detect_version(url string) string {
	stem := formula_creator_archive_stem(url)
	mut best := ''
	mut index := 0
	for index < stem.len {
		is_digit := stem[index] >= `0` && stem[index] <= `9`
		is_prefixed := stem[index] == `v` && index + 1 < stem.len && stem[index + 1] >= `0`
			&& stem[index + 1] <= `9`
		if !is_digit && !is_prefixed {
			index++
			continue
		}
		start := index
		if is_prefixed {
			index++
		}
		for index < stem.len {
			character := stem[index]
			if (character >= `0` && character <= `9`) || character == `.` || character == `_` {
				index++
				continue
			}
			break
		}
		candidate := stem[start..index].trim_right('._')
		if candidate.len > best.len {
			best = candidate
		}
	}
	return best
}

fn formula_creator_github_parts(url string) (string, string) {
	prefix := 'github.com/'
	start := url.index(prefix) or { return '', '' }
	parts := url[start + prefix.len..].split('/')
	if parts.len < 2 || parts[0] == '' || parts[1] == '' {
		return '', ''
	}
	return parts[0], parts[1].all_before('?').all_before('#')
}

pub fn new_formula_creator(options FormulaCreatorOptions) FormulaCreator {
	mut url := options.url
	mut name := options.name
	mut head := options.head
	user, raw_repository := formula_creator_github_parts(url)
	mut repository := raw_repository
	if repository.ends_with('.git') {
		repository = repository.trim_string_right('.git')
		head = true
	}
	if name == '' {
		if repository != '' {
			name = repository
		} else if url.contains('index.cgi') && url.contains('p=') {
			name = url.all_after('p=').all_before('.git').all_before(';')
		} else {
			stem := formula_creator_archive_stem(url)
			path_version := formula_creator_detect_version(url)
			name = if path_version == '' {
				stem
			} else {
				stem.all_before(path_version).trim_right('-_.')
			}
		}
	}
	detected_version := formula_creator_detect_version(url)
	mut version := if options.version != '' { options.version } else { detected_version }
	if options.fetch && user != '' && repository != '' && version == '' && !head
		&& options.latest_release != '' {
		version = options.latest_release
		url = 'https://github.com/${user}/${repository}/archive/refs/tags/${version}.tar.gz'
	}
	full_name := if options.github_full_name != '' {
		options.github_full_name
	} else if user != '' && repository != '' {
		'${user}/${repository}'
	} else {
		''
	}
	return FormulaCreator{
		name: name
		version: version
		url: url
		head: head
		tap: if options.tap == '' { 'homebrew/core' } else { options.tap }
		mode: options.mode.trim_left(':')
		fetch: options.fetch
		version_detected_from_url: options.version == '' && detected_version != ''
		github_user: user
		github_repository: repository
		desc: if options.fetch { options.github_description } else { '' }
		homepage: if options.fetch && options.github_homepage != '' {
			options.github_homepage
		} else if options.fetch && full_name != '' {
			'https://github.com/${full_name}'
		} else {
			''
		}
		license: if options.fetch { options.github_license } else { '' }
		tap_installed: options.tap_installed
	}
}

pub fn (mut creator FormulaCreator) set_name(name string) string {
	creator.name = name
	return name
}

pub fn (creator FormulaCreator) verify_tap_available() ! {
	if !creator.tap_installed {
		return error('TapUnavailableError: ${creator.tap}')
	}
}

fn formula_creator_version_parts(value string) []int {
	mut parts := []int{}
	mut digits := ''
	for character in value.trim_left('v').bytes() {
		if character >= `0` && character <= `9` {
			digits += character.ascii_str()
		} else if digits != '' {
			parts << digits.int()
			digits = ''
		}
	}
	if digits != '' {
		parts << digits.int()
	}
	return parts
}

fn formula_creator_version_greater(left string, right string) bool {
	left_parts := formula_creator_version_parts(left)
	right_parts := formula_creator_version_parts(right)
	part_count := if left_parts.len > right_parts.len {
		left_parts.len
	} else {
		right_parts.len
	}
	for index in 0 .. part_count {
		left_part := if index < left_parts.len { left_parts[index] } else { 0 }
		right_part := if index < right_parts.len { right_parts[index] } else { 0 }
		if left_part != right_part {
			return left_part > right_part
		}
	}
	return left > right
}

pub fn latest_versioned_formula(name string, formula_names []string) string {
	prefix := '${name}@'
	mut latest := ''
	for formula_name in formula_names {
		if !formula_name.starts_with(prefix) {
			continue
		}
		if latest == '' || formula_creator_version_greater(formula_name[prefix.len..], latest[prefix.len..]) {
			latest = formula_name
		}
	}
	return if latest == '' { 'python' } else { latest }
}

fn formula_creator_class_name(name string) string {
	mut result := ''
	mut uppercase_next := true
	for character in name.bytes() {
		if (character >= `a` && character <= `z`) || (character >= `A` && character <= `Z`)
			|| (character >= `0` && character <= `9`) {
			result += if uppercase_next {
				character.ascii_str().to_upper()
			} else {
				character.ascii_str()
			}
			uppercase_next = false
		} else {
			uppercase_next = true
		}
	}
	return result
}

pub fn formula_creator_install(mode string, name string) string {
	return match mode.trim_left(':') {
		'cabal' {
			'    system "cabal", "v2-update"\n    system "cabal", "v2-install", *std_cabal_v2_args'
		}
		'cmake' {
			'    system "cmake", "-S", ".", "-B", "build", *std_cmake_args\n    system "cmake", "--build", "build"\n    system "cmake", "--install", "build"'
		}
		'autotools' {
			'    system "./configure", "--disable-silent-rules", *std_configure_args\n    system "make", "install"'
		}
		'crystal' { '    system "shards", "build", "--release"\n    bin.install "bin/${name}"' }
		'go' { '    system "go", "build", *std_go_args' }
		'meson' {
			'    system "meson", "setup", "build", *std_meson_args\n    system "meson", "compile", "-C", "build", "--verbose"\n    system "meson", "install", "-C", "build"'
		}
		'node' {
			'    system "npm", "install", *std_npm_args\n    bin.install_symlink libexec.glob("bin/*")'
		}
		'perl' {
			'    ENV.prepend_create_path "PERL5LIB", libexec/"lib/perl5"\n    ENV.prepend_path "PERL5LIB", libexec/"lib"\n    bin.install name'
		}
		'python' { '    virtualenv_install_with_resources' }
		'ruby' {
			'    ENV["BUNDLE_FORCE_RUBY_PLATFORM"] = "1"\n    ENV["BUNDLE_VERSION"] = "system"\n    ENV["BUNDLE_WITHOUT"] = "development test"\n    ENV["GEM_HOME"] = libexec\n    system "bundle", "install"\n    system "gem", "build", "#{name}.gemspec"\n    system "gem", "install", "--ignore-dependencies", "#{name}-#{version}.gem"'
		}
		'rust' { '    system "cargo", "install", *std_cargo_args' }
		'zig' { '    system "zig", "build", *std_zig_args' }
		else { '    system "./configure", "--disable-silent-rules", *std_configure_args' }
	}
}

pub fn formula_creator_template(creator FormulaCreator, formula_names []string) string {
	mut lines := [
		'# Documentation: https://docs.brew.sh/Formula-Cookbook',
		'#                https://docs.brew.sh/rubydoc/Formula',
		'# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!',
		'class ${formula_creator_class_name(creator.name)} < Formula',
	]
	if creator.mode == 'python' {
		lines << '  include Language::Python::Virtualenv'
		lines << ''
	}
	lines << '  desc "${creator.desc}"'
	lines << '  homepage "${creator.homepage}"'
	if !creator.head {
		lines << '  url "${creator.url}"'
		if !creator.version_detected_from_url {
			lines << '  version "${creator.version.trim_string_left('v')}"'
		}
		lines << '  sha256 "${creator.sha256}"'
	}
	lines << '  license "${creator.license}"'
	if creator.head {
		lines << '  head "${creator.url}"'
	}
	dependencies := match creator.mode {
		'cabal' {
			['  depends_on "cabal-install" => :build', '  depends_on "ghc" => :build',
				'  depends_on "gmp"', '  uses_from_macos "libffi"']
		}
		'cmake' { ['  depends_on "cmake" => :build'] }
		'crystal' { ['  depends_on "crystal" => :build'] }
		'go' { ['  depends_on "go" => :build'] }
		'meson' { ['  depends_on "meson" => :build', '  depends_on "ninja" => :build'] }
		'node' { ['  depends_on "node"'] }
		'perl' { ['  uses_from_macos "perl"'] }
		'python' {
			[
				'  depends_on "${latest_versioned_formula('python', formula_names)}"',
			]
		}
		'ruby' { ['  depends_on "ruby"'] }
		'rust' { ['  depends_on "rust" => :build'] }
		'zig' { ['  depends_on "zig" => :build'] }
		else { []string{} }
	}
	if dependencies.len > 0 {
		lines << ''
		lines << dependencies
	}
	lines << ''
	lines << '  def install'
	lines << formula_creator_install(creator.mode, creator.name)
	lines << '  end'
	lines << ''
	lines << '  test do'
	lines << '    system "false"'
	lines << '  end'
	lines << 'end'
	return lines.join('\n') + '\n'
}

pub fn write_formula(mut creator FormulaCreator, path string, downloaded_content string,
	downloaded_sha256 string, formula_names []string) !string {
	if creator.name == '' {
		return error('name is blank!')
	}
	if creator.tap == '' {
		return error('tap is blank!')
	}
	if os.exists(path) {
		return error('${path} already exists')
	}
	if creator.version == '' {
		return error('Version cannot be determined from URL. Explicitly set the version with `--set-version` instead.')
	}
	if creator.fetch && !creator.head {
		if downloaded_content.trim_space().to_lower().starts_with('<!doctype html') {
			return error('Downloaded URL is not archive')
		}
		creator.sha256 = downloaded_sha256
	}
	os.mkdir_all(os.dir(path))!
	os.write_file(path, formula_creator_template(creator, formula_names))!
	return path
}

fn formula_creator_boundary_value(creator FormulaCreator) ruby.Value {
	return ruby.structured_value('Homebrew::FormulaCreator', creator.name, {
		'name':                      creator.name
		'version':                   creator.version
		'url':                       creator.url
		'head':                      creator.head.str()
		'tap':                       creator.tap
		'mode':                      creator.mode
		'fetch':                     creator.fetch.str()
		'version_detected_from_url': creator.version_detected_from_url.str()
		'github_user':               creator.github_user
		'github_repository':         creator.github_repository
		'desc':                      creator.desc
		'homepage':                  creator.homepage
		'license':                   creator.license
		'tap_installed':             creator.tap_installed.str()
		'sha256':                    creator.sha256
	})
}

fn formula_creator_from_boundary(value ruby.Value) FormulaCreator {
	return FormulaCreator{
		name: value.attributes['name']
		version: value.attributes['version']
		url: value.attributes['url']
		head: value.attributes['head'] == 'true'
		tap: value.attributes['tap']
		mode: value.attributes['mode']
		fetch: value.attributes['fetch'] == 'true'
		version_detected_from_url: value.attributes['version_detected_from_url'] == 'true'
		github_user: value.attributes['github_user']
		github_repository: value.attributes['github_repository']
		desc: value.attributes['desc']
		homepage: value.attributes['homepage']
		license: value.attributes['license']
		tap_installed: value.attributes['tap_installed'] != 'false'
		sha256: value.attributes['sha256']
	}
}

fn formula_creator_options_from_args(args []ruby.Value) FormulaCreatorOptions {
	if args.len > 0 && args[0].type_name == 'Hash' {
		values := args[0].as_map() or { map[string]ruby.Value{} }
		return FormulaCreatorOptions{
			url: (values['url'] or { ruby.string_value('') }).as_string()
			name: (values['name'] or { ruby.string_value('') }).as_string()
			version: (values['version'] or { ruby.string_value('') }).as_string()
			tap: (values['tap'] or { ruby.string_value('homebrew/core') }).as_string()
			mode: (values['mode'] or { ruby.string_value('') }).as_string()
			license: (values['license'] or { ruby.string_value('') }).as_string()
			fetch: (values['fetch'] or { ruby.bool_value(false) }).as_bool() or { false }
			head: (values['head'] or { ruby.bool_value(false) }).as_bool() or { false }
			latest_release: (values['latest_release'] or { ruby.string_value('') }).as_string()
		}
	}
	return FormulaCreatorOptions{
		url: if args.len > 0 { args[0].as_string() } else { '' }
		name: if args.len > 1 { args[1].as_string() } else { '' }
		version: if args.len > 2 { args[2].as_string() } else { '' }
		tap: if args.len > 3 { args[3].as_string() } else { 'homebrew/core' }
		mode: if args.len > 4 { args[4].as_string() } else { '' }
		license: if args.len > 5 { args[5].as_string() } else { '' }
		fetch: if args.len > 6 { args[6].as_bool() or { false } } else { false }
		head: if args.len > 7 { args[7].as_bool() or { false } } else { false }
		latest_release: if args.len > 8 { args[8].as_string() } else { '' }
	}
}
