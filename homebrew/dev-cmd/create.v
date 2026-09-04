module dev_cmd

import ruby
import homebrew
import os

// Translated from Homebrew/brew `dev-cmd/create.rb`.

pub struct CreateOptions {
pub:
	url                string
	autotools          bool
	cabal              bool
	cask               bool
	cmake              bool
	crystal            bool
	go                 bool
	meson              bool
	node               bool
	perl               bool
	python             bool
	ruby               bool
	rust               bool
	zig                bool
	no_fetch           bool
	head               bool
	set_name           string
	set_version        string
	set_license        string
	tap                string
	force              bool
	stdin_available    bool
	stdin_line         string
	tap_path           string
	formula_path       string
	cask_path          string
	tap_installed      bool = true
	downloaded_content string
	downloaded_sha256  string
	formula_names      []string
	disallowed_reasons map[string]string
	aliases            map[string]string
}

pub struct CreateResult {
pub mut:
	path                     string
	name                     string
	token                    string
	version                  string
	content                  string
	mode                     string
	tap                      string
	stdout                   []string
	prompts                  []string
	editor_path              string
	python_resources_updated bool
}

@[heap]
pub struct CreateInput {
pub:
	options CreateOptions
}

pub fn create_input_boundary(input &CreateInput) ruby.Value {
	return ruby.structured_value('Homebrew::DevCmd::Create::Input', '', {
		'create_input_address': u64(voidptr(input)).str()
	})
}

fn create_input_from_value(value ruby.Value) &CreateInput {
	address := value.attributes['create_input_address'] or { panic('invalid Create input') }
	return unsafe { &CreateInput(voidptr(address.u64())) }
}

fn create_mode(options CreateOptions) string {
	if options.autotools {
		return 'autotools'
	}
	if options.cmake {
		return 'cmake'
	}
	if options.crystal {
		return 'crystal'
	}
	if options.go {
		return 'go'
	}
	if options.cabal {
		return 'cabal'
	}
	if options.meson {
		return 'meson'
	}
	if options.node {
		return 'node'
	}
	if options.perl {
		return 'perl'
	}
	if options.python {
		return 'python'
	}
	if options.ruby {
		return 'ruby'
	}
	if options.rust {
		return 'rust'
	}
	if options.zig {
		return 'zig'
	}
	return ''
}

// create_gets translates `$stdin.gets&.presence&.chomp`: EOF and an already-empty
// string are nil, while a line containing only a record separator becomes `""`.
pub fn create_gets(line string, available bool) ?string {
	if !available || line == '' {
		return none
	}
	if line.ends_with('\r\n') {
		return line[..line.len - 2]
	}
	if line.ends_with('\n') || line.ends_with('\r') {
		return line[..line.len - 1]
	}
	return line
}

fn create_archive_stem(url string) string {
	basename := url.all_after_last('/')
	if dot := basename.last_index('.') {
		if dot > 0 {
			return basename[..dot]
		}
	}
	return basename
}

// create_cask_token is the exact Cask::Utils.token_from transformation used by
// `brew create --cask`.
pub fn create_cask_token(name string) string {
	mut expanded := name.to_lower().replace('+', '-plus-')
	expanded = expanded.replace(' ', '-').replace('_', '-').replace('·', '-').replace('•', '-')
	mut filtered := ''
	for character in expanded.bytes() {
		if (character >= `a` && character <= `z`) || (character >= `0` && character <= `9`)
			|| character == `_` || character == `@` || character == `-` {
			filtered += character.ascii_str()
		}
	}
	for filtered.contains('--') {
		filtered = filtered.replace('--', '-')
	}
	return filtered.trim('-')
}

fn create_default_cask_path(options CreateOptions, token string) string {
	if options.cask_path != '' {
		return options.cask_path
	}
	return os.join_path(options.tap_path, 'Casks', '${token.to_lower()}.rb')
}

fn create_default_formula_path(options CreateOptions, name string) string {
	if options.formula_path != '' {
		return options.formula_path
	}
	return os.join_path(options.tap_path, 'Formula', '${name.to_lower()}.rb')
}

fn create_cask_template(token string, version string, sha256 string, url string,
	name string) string {
	return '# Documentation: https://docs.brew.sh/Cask-Cookbook\n' + '# PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!\n' + 'cask "${token}" do\n' + '  version "${version}"\n' + '  sha256 "${sha256}"\n\n' + '  url "${url}"\n' + '  name "${name}"\n' + '  desc ""\n' + '  homepage ""\n\n' + '  # Documentation: https://docs.brew.sh/Brew-Livecheck\n' + '  livecheck do\n' + '    url ""\n' + '    strategy ""\n' + '  end\n\n' + '  depends_on macos: ""\n\n' + '  app ""\n\n' + '  # Documentation: https://docs.brew.sh/Cask-Cookbook#stanza-zap\n' + '  zap trash: ""\n' + 'end\n'
}

pub fn create_cask(options CreateOptions) !CreateResult {
	if options.url == '' {
		return error('URL is required')
	}
	stem := create_archive_stem(options.url).all_after_last('=')
	mut name := options.set_name
	mut prompts := []string{}
	if name.trim_space() == '' {
		prompts << 'Cask name [${stem}]: '
		name = create_gets(options.stdin_line, options.stdin_available) or { stem }
	}
	token := create_cask_token(name)
	tap := if options.tap == '' { 'homebrew/cask' } else { options.tap }
	if !options.tap_installed {
		return error('TapUnavailableError: ${tap}')
	}
	path := create_default_cask_path(options, token)
	if os.exists(path) {
		return error('CaskAlreadyCreatedError: ${token}')
	}
	mut version := options.set_version
	if version == '' {
		version_url := options.url.replace(token, '').replace('x86_64', '').replace('x86', '')
		version = homebrew.detect_version(version_url, '').to_s().trim_right('-_.')
	}
	mut sha256 := ''
	mut interpolated_url := options.url
	if version != '' {
		if !options.no_fetch {
			sha256 = options.downloaded_sha256
		}
		interpolated_url = options.url.replace(version, '#{version}')
	}
	content := create_cask_template(token, version, sha256, interpolated_url, name)
	os.mkdir_all(os.dir(path))!
	os.write_file(path, content)!
	return CreateResult{
		path: path
		name: name
		token: token
		version: version
		content: content
		tap: tap
		stdout: [
			'Please run `brew audit --cask --new ${token}` before submitting, thanks.',
		]
		prompts: prompts
	}
}

pub fn create_formula(options CreateOptions) !CreateResult {
	if options.url == '' {
		return error('URL is required')
	}
	mode := create_mode(options)
	tap := if options.tap == '' { 'homebrew/core' } else { options.tap }
	mut creator := homebrew.new_formula_creator(homebrew.FormulaCreatorOptions{
		url: options.url
		name: options.set_name
		version: options.set_version
		tap: tap
		mode: mode
		license: options.set_license
		fetch: !options.no_fetch
		head: options.head
		tap_installed: options.tap_installed
	})
	mut prompts := []string{}
	if options.set_name.trim_space() == '' {
		prompts << 'Formula name [${creator.name}]: '
		if confirmed_name := create_gets(options.stdin_line, options.stdin_available) {
			if confirmed_name.trim_space() != '' {
				creator.set_name(confirmed_name)
			}
		}
	}
	creator.verify_tap_available()!
	if !options.force {
		if reason := options.disallowed_reasons[creator.name] {
			return error("The formula '${creator.name}' is not allowed to be created.\n${reason}\nIf you really want to create this formula use `--force`.")
		}
		if realname := options.aliases[creator.name] {
			return error("The formula '${realname}' is already aliased to '${creator.name}'.\nPlease check that you are not creating a duplicate.\nTo force creation use `--force`.")
		}
	}
	path := create_default_formula_path(options, creator.name)
	homebrew.write_formula(mut creator, path, options.downloaded_content, options.downloaded_sha256, options.formula_names)!
	content := os.read_file(path)!
	return CreateResult{
		path: path
		name: creator.name
		version: creator.version
		content: content
		mode: mode
		tap: tap
		stdout: [
			'Please audit and test formula before submitting:\n  HOMEBREW_NO_INSTALL_FROM_API=1 brew audit --new ${creator.name}\n  HOMEBREW_NO_INSTALL_FROM_API=1 brew install --build-from-source --verbose --debug ${creator.name}\n  HOMEBREW_NO_INSTALL_FROM_API=1 brew test ${creator.name}',
		]
		prompts: prompts
		python_resources_updated: options.python
	}
}

pub fn run_create(options CreateOptions) !CreateResult {
	mut result := if options.cask { create_cask(options)! } else { create_formula(options)! }
	result.editor_path = result.path
	return result
}

fn create_result_value(result CreateResult) ruby.Value {
	return ruby.map_value({
		'path':                     ruby.object_value('Pathname', result.path)
		'name':                     ruby.string_value(result.name)
		'token':                    ruby.string_value(result.token)
		'version':                  ruby.string_value(result.version)
		'content':                  ruby.string_value(result.content)
		'mode':                     ruby.string_value(result.mode)
		'tap':                      ruby.string_value(result.tap)
		'stdout':                   ruby.string_array_value(result.stdout)
		'prompts':                  ruby.string_array_value(result.prompts)
		'editor_path':              ruby.object_value('Pathname', result.editor_path)
		'python_resources_updated': ruby.bool_value(result.python_resources_updated)
	})
}

fn create_error_value(err IError) ruby.Value {
	message := err.msg()
	if message.starts_with('TapUnavailableError:') {
		return ruby.object_value('TapUnavailableError', message)
	}
	if message.starts_with('CaskAlreadyCreatedError:') {
		return ruby.object_value('Cask::CaskAlreadyCreatedError', message)
	}
	if message.contains('is not allowed to be created') || message.contains('is already aliased to')
		|| message.starts_with('Version cannot be determined') {
		return ruby.object_value('SystemExit', message)
	}
	return ruby.object_value('RuntimeError', message)
}
