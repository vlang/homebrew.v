module dev_cmd

import brew_runtime
import homebrew
import os

// Translated from Homebrew/brew `dev-cmd/create.rb`.
// The original source is retained below until every stub has a typed V body.

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

pub fn create_input_boundary(input &CreateInput) brew_runtime.Value {
	return brew_runtime.structured_value('Homebrew::DevCmd::Create::Input', '', {
		'create_input_address': u64(voidptr(input)).str()
	})
}

fn create_input_from_value(value brew_runtime.Value) &CreateInput {
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

fn create_result_value(result CreateResult) brew_runtime.Value {
	return brew_runtime.map_value({
		'path':                     brew_runtime.object_value('Pathname', result.path)
		'name':                     brew_runtime.string_value(result.name)
		'token':                    brew_runtime.string_value(result.token)
		'version':                  brew_runtime.string_value(result.version)
		'content':                  brew_runtime.string_value(result.content)
		'mode':                     brew_runtime.string_value(result.mode)
		'tap':                      brew_runtime.string_value(result.tap)
		'stdout':                   brew_runtime.string_array_value(result.stdout)
		'prompts':                  brew_runtime.string_array_value(result.prompts)
		'editor_path':              brew_runtime.object_value('Pathname', result.editor_path)
		'python_resources_updated': brew_runtime.bool_value(result.python_resources_updated)
	})
}

fn create_error_value(err IError) brew_runtime.Value {
	message := err.msg()
	if message.starts_with('TapUnavailableError:') {
		return brew_runtime.object_value('TapUnavailableError', message)
	}
	if message.starts_with('CaskAlreadyCreatedError:') {
		return brew_runtime.object_value('Cask::CaskAlreadyCreatedError', message)
	}
	if message.contains('is not allowed to be created') || message.contains('is already aliased to')
		|| message.starts_with('Version cannot be determined') {
		return brew_runtime.object_value('SystemExit', message)
	}
	return brew_runtime.object_value('RuntimeError', message)
}

// Ruby method `run` at line 73.
pub fn ruby_create_l73_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || args[0].type_name != 'Homebrew::DevCmd::Create::Input' {
		return brew_runtime.object_value('ArgumentError', 'Create input is required')
	}
	result := run_create(create_input_from_value(args[0]).options) or { return create_error_value(err) }
	return create_result_value(result)
}

// Ruby method `create_cask` at line 86.
pub fn ruby_create_l86_d2_create_cask(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || args[0].type_name != 'Homebrew::DevCmd::Create::Input' {
		return brew_runtime.object_value('ArgumentError', 'Create input is required')
	}
	result := create_cask(create_input_from_value(args[0]).options) or { return create_error_value(err) }
	return create_result_value(result)
}

// Ruby method `create_formula` at line 157.
pub fn ruby_create_l157_d3_create_formula(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || args[0].type_name != 'Homebrew::DevCmd::Create::Input' {
		return brew_runtime.object_value('ArgumentError', 'Create input is required')
	}
	result := create_formula(create_input_from_value(args[0]).options) or { return create_error_value(err) }
	return create_result_value(result)
}

// Ruby method `__gets` at line 250.
pub fn ruby_create_l250_d4_gets(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 || args[0].type_name == 'NilClass' {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	line := create_gets(args[0].as_string(), true) or {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	return brew_runtime.string_value(line)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5: require "formula_creator"
// 6: require "missing_formula"
// 7: require "cask/cask_loader"
// 8:
// 9: module Homebrew
// 10:   module DevCmd
// 11:     class Create < AbstractCommand
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Generate a formula or, with `--cask`, a cask for the downloadable file at <URL>
// 15:           and open it in the editor. Homebrew will attempt to automatically derive the
// 16:           formula name and version, but if it fails, you'll have to make your own template.
// 17:           The `wget` formula serves as a simple example. For the complete API, see:
// 18:           <https://docs.brew.sh/rubydoc/Formula>
// 19:         EOS
// 20:         switch "--autotools",
// 21:                description: "Create a basic template for an Autotools-style build."
// 22:         switch "--cabal",
// 23:                description: "Create a basic template for a Cabal build."
// 24:         switch "--cask",
// 25:                description: "Create a basic template for a cask."
// 26:         switch "--cmake",
// 27:                description: "Create a basic template for a CMake-style build."
// 28:         switch "--crystal",
// 29:                description: "Create a basic template for a Crystal build."
// 30:         switch "--go",
// 31:                description: "Create a basic template for a Go build."
// 32:         switch "--meson",
// 33:                description: "Create a basic template for a Meson-style build."
// 34:         switch "--node",
// 35:                description: "Create a basic template for a Node build."
// 36:         switch "--perl",
// 37:                description: "Create a basic template for a Perl build."
// 38:         switch "--python",
// 39:                description: "Create a basic template for a Python build."
// 40:         switch "--ruby",
// 41:                description: "Create a basic template for a Ruby build."
// 42:         switch "--rust",
// 43:                description: "Create a basic template for a Rust build."
// 44:         switch "--zig",
// 45:                description: "Create a basic template for a Zig build."
// 46:         switch "--no-fetch",
// 47:                description: "Homebrew will not download <URL> to the cache and will thus not add its SHA-256 " \
// 48:                             "to the formula for you, nor will it check the GitHub API for GitHub projects " \
// 49:                             "(to fill out its description and homepage)."
// 50:         switch "--HEAD",
// 51:                description: "Indicate that <URL> points to the package's repository rather than a file."
// 52:         flag   "--set-name=",
// 53:                description: "Explicitly set the <name> of the new formula or cask."
// 54:         flag   "--set-version=",
// 55:                description: "Explicitly set the <version> of the new formula or cask."
// 56:         flag   "--set-license=",
// 57:                description: "Explicitly set the <license> of the new formula."
// 58:         flag   "--tap=",
// 59:                description: "Generate the new formula within the given tap, specified as <user>`/`<repo>."
// 60:         switch "-f", "--force",
// 61:                description: "Ignore errors for disallowed formula names and names that shadow aliases."
// 62:
// 63:         conflicts "--autotools", "--cabal", "--cmake", "--crystal", "--go", "--meson", "--node",
// 64:                   "--perl", "--python", "--ruby", "--rust", "--zig", "--cask"
// 65:         conflicts "--cask", "--HEAD"
// 66:         conflicts "--cask", "--set-license"
// 67:
// 68:         named_args :url, number: 1
// 69:       end
// 70:
// 71:       # Create a formula from a tarball URL.
// 72:       sig { override.void }
// 73:       def run
// 74:         path = if args.cask?
// 75:           create_cask
// 76:         else
// 77:           create_formula
// 78:         end
// 79:
// 80:         exec_editor path
// 81:       end
// 82:
// 83:       private
// 84:
// 85:       sig { returns(Pathname) }
// 86:       def create_cask
// 87:         url = args.named.fetch(0)
// 88:         name = if args.set_name.blank?
// 89:           stem = Pathname.new(url).stem.rpartition("=").last
// 90:           print "Cask name [#{stem}]: "
// 91:           __gets || stem
// 92:         else
// 93:           args.set_name
// 94:         end
// 95:         token = Cask::Utils.token_from(T.must(name))
// 96:
// 97:         cask_tap = Tap.fetch(args.tap || "homebrew/cask")
// 98:         raise TapUnavailableError, cask_tap.name unless cask_tap.installed?
// 99:
// 100:         cask_path = cask_tap.new_cask_path(token)
// 101:         cask_path.dirname.mkpath unless cask_path.dirname.exist?
// 102:         raise Cask::CaskAlreadyCreatedError, token if cask_path.exist?
// 103:
// 104:         version = if args.set_version
// 105:           Version.new(T.must(args.set_version))
// 106:         else
// 107:           Version.detect(url.gsub(token, "").gsub(/x86(_64)?/, ""))
// 108:         end
// 109:
// 110:         interpolated_url, sha256 = if version.null?
// 111:           [url, ""]
// 112:         else
// 113:           sha256 = if args.no_fetch?
// 114:             ""
// 115:           else
// 116:             strategy = DownloadStrategyDetector.detect(url)
// 117:             downloader = strategy.new(url, token, version.to_s, cache: Cask::Cache.path)
// 118:             downloader.fetch
// 119:             downloader.cached_location.sha256
// 120:           end
// 121:
// 122:           [url.gsub(version.to_s, "\#{version}"), sha256]
// 123:         end
// 124:
// 125:         cask_path.atomic_write <<~RUBY
// 126:           # Documentation: https://docs.brew.sh/Cask-Cookbook
// 127:           # PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
// 128:           cask "#{token}" do
// 129:             version "#{version}"
// 130:             sha256 "#{sha256}"
// 131:
// 132:             url "#{interpolated_url}"
// 133:             name "#{name}"
// 134:             desc ""
// 135:             homepage ""
// 136:
// 137:             # Documentation: https://docs.brew.sh/Brew-Livecheck
// 138:             livecheck do
// 139:               url ""
// 140:               strategy ""
// 141:             end
// 142:
// 143:             depends_on macos: ""
// 144:
// 145:             app ""
// 146:
// 147:             # Documentation: https://docs.brew.sh/Cask-Cookbook#stanza-zap
// 148:             zap trash: ""
// 149:           end
// 150:         RUBY
// 151:
// 152:         puts "Please run `brew audit --cask --new #{token}` before submitting, thanks."
// 153:         cask_path
// 154:       end
// 155:
// 156:       sig { returns(Pathname) }
// 157:       def create_formula
// 158:         mode = if args.autotools?
// 159:           :autotools
// 160:         elsif args.cmake?
// 161:           :cmake
// 162:         elsif args.crystal?
// 163:           :crystal
// 164:         elsif args.go?
// 165:           :go
// 166:         elsif args.cabal?
// 167:           :cabal
// 168:         elsif args.meson?
// 169:           :meson
// 170:         elsif args.node?
// 171:           :node
// 172:         elsif args.perl?
// 173:           :perl
// 174:         elsif args.python?
// 175:           :python
// 176:         elsif args.ruby?
// 177:           :ruby
// 178:         elsif args.rust?
// 179:           :rust
// 180:         elsif args.zig?
// 181:           :zig
// 182:         end
// 183:
// 184:         formula_creator = FormulaCreator.new(
// 185:           url:     args.named.fetch(0),
// 186:           name:    args.set_name,
// 187:           version: args.set_version,
// 188:           tap:     args.tap,
// 189:           mode:,
// 190:           license: args.set_license,
// 191:           fetch:   !args.no_fetch?,
// 192:           head:    args.HEAD?,
// 193:         )
// 194:
// 195:         # ask for confirmation if name wasn't passed explicitly
// 196:         if args.set_name.blank?
// 197:           print "Formula name [#{formula_creator.name}]: "
// 198:           confirmed_name = __gets
// 199:           formula_creator.name = confirmed_name if confirmed_name.present?
// 200:         end
// 201:
// 202:         formula_creator.verify_tap_available!
// 203:
// 204:         # Check for disallowed formula, or names that shadow aliases,
// 205:         # unless --force is specified.
// 206:         unless args.force?
// 207:           if (reason = MissingFormula.disallowed_reason(formula_creator.name))
// 208:             odie <<~EOS
// 209:               The formula '#{formula_creator.name}' is not allowed to be created.
// 210:               #{reason}
// 211:               If you really want to create this formula use `--force`.
// 212:             EOS
// 213:           end
// 214:
// 215:           Homebrew.with_no_api_env do
// 216:             if Formula.aliases.include?(formula_creator.name)
// 217:               realname = Formulary.canonical_name(formula_creator.name)
// 218:               odie <<~EOS
// 219:                 The formula '#{realname}' is already aliased to '#{formula_creator.name}'.
// 220:                 Please check that you are not creating a duplicate.
// 221:                 To force creation use `--force`.
// 222:               EOS
// 223:             end
// 224:           end
// 225:         end
// 226:
// 227:         path = formula_creator.write_formula!
// 228:
// 229:         formula = Homebrew.with_no_api_env do
// 230:           CoreTap.instance.clear_cache
// 231:           Formula[formula_creator.name]
// 232:         end
// 233:
// 234:         if args.python?
// 235:           Homebrew.install_bundler_gems!(groups: ["ast"])
// 236:           require "utils/pypi"
// 237:           PyPI.update_python_resources! formula, ignore_non_pypi_packages: true
// 238:         end
// 239:
// 240:         puts <<~EOS
// 241:           Please audit and test formula before submitting:
// 242:             HOMEBREW_NO_INSTALL_FROM_API=1 brew audit --new #{formula_creator.name}
// 243:             HOMEBREW_NO_INSTALL_FROM_API=1 brew install --build-from-source --verbose --debug #{formula_creator.name}
// 244:             HOMEBREW_NO_INSTALL_FROM_API=1 brew test #{formula_creator.name}
// 245:         EOS
// 246:         path
// 247:       end
// 248:
// 249:       sig { returns(T.nilable(String)) }
// 250:       def __gets
// 251:         $stdin.gets&.presence&.chomp
// 252:       end
// 253:     end
// 254:   end
// 255: end
