module shared_context

import brew_runtime

// Translated from Homebrew/brew `test/support/helper/spec/shared_context/integration_test.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `supports_block_expectations?` at line 20.
pub fn ruby_integration_test_l20_d1_supports_block_expectations(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('supports_block_expectations?', ...args)
}

// Ruby method `expects_call_stack_jump?` at line 40.
pub fn ruby_integration_test_l40_d2_expects_call_stack_jump(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('expects_call_stack_jump?', ...args)
}

// Ruby method `command_id` at line 57.
pub fn ruby_integration_test_l57_d3_command_id(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('command_id', ...args)
}

// Ruby method `brew(*args)` at line 65.
pub fn ruby_integration_test_l65_d4_brew(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('brew', ...args)
}

// Ruby method `brew_sh(*args)` at line 122.
pub fn ruby_integration_test_l122_d5_brew_sh(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('brew_sh', ...args)
}

// Ruby method `setup_test_formula(name, content = nil, tap: CoreTap.instance,` at line 151.
pub fn ruby_integration_test_l151_d6_setup_test_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('setup_test_formula', ...args)
}

// Ruby method `install` at line 176.
pub fn ruby_integration_test_l176_d7_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby method `install_test_formula(name, content = nil, build_bottle: false)` at line 232.
pub fn ruby_integration_test_l232_d8_install_test_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_test_formula', ...args)
}

// Ruby method `uninstall_test_formula(name)` at line 243.
pub fn ruby_integration_test_l243_d9_uninstall_test_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uninstall_test_formula', ...args)
}

// Ruby method `setup_test_tap` at line 252.
pub fn ruby_integration_test_l252_d10_setup_test_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('setup_test_tap', ...args)
}

// Ruby method `install_and_rename_coretap_formula(old_name, new_name)` at line 266.
pub fn ruby_integration_test_l266_d11_install_and_rename_coretap_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_and_rename_coretap_formula', ...args)
}

// Ruby method `testball` at line 285.
pub fn ruby_integration_test_l285_d12_testball(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('testball', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "open3"
// 5:
// 6: require "formula_installer"
// 7: require "uninstall"
// 8:
// 9: RSpec::Matchers.define :be_a_success do
// 10:   T.bind(self, T.class_of(RSpec::Matchers::DSL::Matcher))
// 11:
// 12:   match do |actual|
// 13:     T.bind(self, RSpec::Matchers::DSL::Matcher)
// 14:
// 15:     status = actual.is_a?(Proc) ? actual.call : actual
// 16:     expect(status).to respond_to(:success?)
// 17:     status.success?
// 18:   end
// 19:
// 20:   def supports_block_expectations?
// 21:     true
// 22:   end
// 23:
// 24:   # It needs to be nested like this:
// 25:   #
// 26:   #   expect {
// 27:   #     expect {
// 28:   #       # command
// 29:   #     }.to be_a_success
// 30:   #   }.to output(something).to_stdout
// 31:   #
// 32:   # rather than this:
// 33:   #
// 34:   #   expect {
// 35:   #     expect {
// 36:   #       # command
// 37:   #     }.to output(something).to_stdout
// 38:   #   }.to be_a_success
// 39:   #
// 40:   def expects_call_stack_jump?
// 41:     true
// 42:   end
// 43: end
// 44:
// 45: RSpec::Matchers.define_negated_matcher :be_a_failure, :be_a_success
// 46:
// 47: module Test
// 48:   module Helper
// 49:     module IntegrationTest
// 50:       extend T::Helpers
// 51:
// 52:       requires_ancestor { Kernel }
// 53:
// 54:       # Generate unique ID to be able to
// 55:       # properly merge coverage results.
// 56:       sig { returns(String) }
// 57:       def command_id
// 58:         Thread.current[:brew_integration_test_number] ||= 0
// 59:         "#{Process.pid}:#{ENV.fetch("TEST_ENV_NUMBER", "")}:#{Thread.current[:brew_integration_test_number] += 1}"
// 60:       end
// 61:
// 62:       # Runs a `brew` command with the test configuration
// 63:       # and with coverage reporting enabled.
// 64:       sig { params(args: T.untyped).returns(Process::Status) }
// 65:       def brew(*args)
// 66:         env = args.last.is_a?(Hash) ? args.pop : {}
// 67:
// 68:         # Avoid warnings when HOMEBREW_PREFIX/bin is not in PATH.
// 69:         # Also include our extra commands directory.
// 70:         path = [
// 71:           env["PATH"],
// 72:           (HOMEBREW_LIBRARY_PATH/"test/support/helper/cmd").realpath.to_s,
// 73:           (HOMEBREW_PREFIX/"bin").realpath.to_s,
// 74:           ENV.fetch("PATH"),
// 75:         ].compact.join(File::PATH_SEPARATOR)
// 76:
// 77:         env.merge!(
// 78:           "PATH"                         => path,
// 79:           "HOMEBREW_PATH"                => path,
// 80:           "HOMEBREW_BREW_FILE"           => HOMEBREW_PREFIX/"bin/brew",
// 81:           "HOMEBREW_INTEGRATION_TEST"    => command_id,
// 82:           "HOMEBREW_TEST_TMPDIR"         => TEST_TMPDIR,
// 83:           "HOMEBREW_DEV_CMD_RUN"         => "true",
// 84:           "HOMEBREW_ASK"                 => nil,
// 85:           "HOMEBREW_USE_RUBY_FROM_PATH"  => ENV.fetch("HOMEBREW_USE_RUBY_FROM_PATH", nil),
// 86:           "HOMEBREW_NO_INSTALL_FROM_API" => ENV.fetch("HOMEBREW_NO_INSTALL_FROM_API", nil),
// 87:           "GEM_HOME"                     => nil,
// 88:         )
// 89:
// 90:         @ruby_args ||= begin
// 91:           ruby_args = HOMEBREW_RUBY_EXEC_ARGS.dup
// 92:           if ENV["HOMEBREW_TESTS_COVERAGE"]
// 93:             simplecov_spec = Gem.loaded_specs["simplecov"]
// 94:             parallel_tests_spec = Gem.loaded_specs["parallel_tests"]
// 95:             specs = T.let([], T::Array[Gem::Specification])
// 96:             [simplecov_spec, parallel_tests_spec].each do |spec|
// 97:               specs << spec
// 98:               spec.runtime_dependencies.each do |dep|
// 99:                 specs += dep.to_specs
// 100:               rescue Gem::LoadError => e
// 101:                 T.bind(self, Utils::Output::Mixin)
// 102:                 onoe e
// 103:               end
// 104:             end
// 105:             specs.flat_map(&:full_require_paths).each { |lib| ruby_args << "-I" << lib }
// 106:             ruby_args << "-r#{HOMEBREW_LIBRARY_PATH}/test/support/helper/simplecov_start"
// 107:           end
// 108:           ruby_args << "-r#{HOMEBREW_LIBRARY_PATH}/test/support/helper/integration_mocks"
// 109:           ruby_args << "-e" << "$0 = ARGV.shift; load($0)"
// 110:           ruby_args << (HOMEBREW_LIBRARY_PATH/"brew.rb").resolved_path.to_s
// 111:         end
// 112:
// 113:         Bundler.with_unbundled_env do
// 114:           stdout, stderr, status = Open3.capture3(env, *@ruby_args, *args)
// 115:           $stdout.print stdout
// 116:           $stderr.print stderr
// 117:           status
// 118:         end
// 119:       end
// 120:
// 121:       sig { params(args: T.untyped).returns(Process::Status) }
// 122:       def brew_sh(*args)
// 123:         env = args.last.is_a?(Hash) ? args.pop : {}
// 124:         env = {
// 125:           "HOMEBREW_USE_RUBY_FROM_PATH" => ENV.fetch("HOMEBREW_USE_RUBY_FROM_PATH", nil),
// 126:           "HOMEBREW_CACHE"              => HOMEBREW_CACHE.to_s,
// 127:           "HOMEBREW_INTEGRATION_TEST"   => command_id,
// 128:         }.merge(env)
// 129:         Bundler.with_unbundled_env do
// 130:           brew_sh_path = env.delete("HOMEBREW_BREW_SH") || "#{ENV.fetch("HOMEBREW_PREFIX")}/bin/brew"
// 131:           stdout, stderr, status = Open3.capture3(
// 132:             env,
// 133:             brew_sh_path,
// 134:             *args,
// 135:           )
// 136:           $stdout.print stdout
// 137:           $stderr.print stderr
// 138:           status
// 139:         end
// 140:       end
// 141:
// 142:       sig {
// 143:         params(
// 144:           name:           String,
// 145:           content:        T.nilable(String),
// 146:           tap:            Tap,
// 147:           bottle_block:   T.nilable(String),
// 148:           tab_attributes: T.nilable(T::Hash[T.untyped, T.untyped]),
// 149:         ).returns(Pathname)
// 150:       }
// 151:       def setup_test_formula(name, content = nil, tap: CoreTap.instance,
// 152:                              bottle_block: nil, tab_attributes: nil)
// 153:         case name
// 154:         when /^testball/
// 155:           # Use a different tarball for testball2 to avoid lock errors when writing concurrency tests
// 156:           prefix = (name == "testball2") ? "testball2" : "testball"
// 157:           tarball = if OS.linux?
// 158:             TEST_FIXTURE_DIR/"tarballs/#{prefix}-0.1-linux.tbz"
// 159:           else
// 160:             TEST_FIXTURE_DIR/"tarballs/#{prefix}-0.1.tbz"
// 161:           end
// 162:           bottle_block ||= <<~RUBY if name == "testball_bottle"
// 163:             bottle do
// 164:               root_url "file://#{TEST_FIXTURE_DIR}/bottles"
// 165:               sha256 cellar: :any_skip_relocation, all: "d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97"
// 166:             end
// 167:           RUBY
// 168:           content = <<~RUBY
// 169:             desc "Some test"
// 170:             homepage "https://brew.sh/#{name}"
// 171:             url "file://#{tarball}"
// 172:             sha256 "#{tarball.sha256}"
// 173:
// 174:             option "with-foo", "Build with foo"
// 175:             #{bottle_block}
// 176:             def install
// 177:               (prefix/"foo"/"test").write("test") if build.with? "foo"
// 178:               prefix.install Dir["*"]
// 179:               (buildpath/"test.c").write \
// 180:                 "#include <stdio.h>\\nint main(){printf(\\"test\\");return 0;}"
// 181:               bin.mkpath
// 182:               system ENV.cc, "test.c", "-o", bin/"test"
// 183:             end
// 184:
// 185:             #{content}
// 186:
// 187:             # something here
// 188:           RUBY
// 189:         when "bar"
// 190:           content = <<~RUBY
// 191:             url "https://brew.sh/#{name}-1.0"
// 192:             depends_on "foo"
// 193:           RUBY
// 194:         when "package_license"
// 195:           content = <<~RUBY
// 196:             url "https://brew.sh/#patchelf-1.0"
// 197:             license "0BSD"
// 198:           RUBY
// 199:         else
// 200:           content ||= <<~RUBY
// 201:             url "https://brew.sh/#{name}-1.0"
// 202:           RUBY
// 203:         end
// 204:
// 205:         formula_path = Formulary.find_formula_in_tap(name.downcase, tap).tap do |path|
// 206:           path.dirname.mkpath
// 207:           path.write <<~RUBY
// 208:             class #{Formulary.class_s(name)} < Formula
// 209:             #{content.gsub(/^(?!$)/, "  ")}
// 210:             end
// 211:           RUBY
// 212:
// 213:           tap.clear_cache
// 214:         end
// 215:
// 216:         return formula_path if tab_attributes.nil?
// 217:
// 218:         keg = ::Formula[name].prefix
// 219:         keg.mkpath
// 220:
// 221:         tab = Tab.for_name(name)
// 222:         tab.tabfile ||= keg/AbstractTab::FILENAME
// 223:         tab_attributes.each do |key, value|
// 224:           tab.public_send(:"#{key}=", value)
// 225:         end
// 226:         tab.write
// 227:
// 228:         formula_path
// 229:       end
// 230:
// 231:       sig { params(name: String, content: T.nilable(String), build_bottle: T::Boolean).void }
// 232:       def install_test_formula(name, content = nil, build_bottle: false)
// 233:         setup_test_formula(name, content)
// 234:         fi = FormulaInstaller.new(::Formula[name], build_bottle:, installed_on_request: true)
// 235:         fi.prelude_fetch
// 236:         fi.prelude
// 237:         fi.fetch
// 238:         fi.install
// 239:         fi.finish
// 240:       end
// 241:
// 242:       sig { params(name: String).void }
// 243:       def uninstall_test_formula(name)
// 244:         rack = HOMEBREW_CELLAR/name
// 245:         return unless rack.directory?
// 246:
// 247:         kegs = rack.children.map { |prefix| Keg.new(prefix) }
// 248:         Homebrew::Uninstall.uninstall_kegs({ rack => kegs }, force: true, ignore_dependencies: true)
// 249:       end
// 250:
// 251:       sig { returns(Pathname) }
// 252:       def setup_test_tap
// 253:         path = HOMEBREW_TAP_DIRECTORY/"homebrew/homebrew-foo"
// 254:         path.mkpath
// 255:         path.cd do
// 256:           system "git", "init"
// 257:           system "git", "remote", "add", "origin", "https://github.com/Homebrew/homebrew-foo"
// 258:           FileUtils.touch "readme"
// 259:           system "git", "add", "--all"
// 260:           system "git", "commit", "-m", "init"
// 261:         end
// 262:         path
// 263:       end
// 264:
// 265:       sig { params(old_name: String, new_name: String).void }
// 266:       def install_and_rename_coretap_formula(old_name, new_name)
// 267:         CoreTap.instance.path.cd do |tap_path|
// 268:           system "git", "init"
// 269:           system "git", "add", "--all"
// 270:           system "git", "commit", "-m",
// 271:                  "#{old_name.capitalize} has not yet been renamed"
// 272:
// 273:           brew "install", old_name
// 274:
// 275:           (tap_path/"Formula/#{old_name}.rb").unlink
// 276:           (tap_path/"formula_renames.json").write JSON.pretty_generate(old_name => new_name)
// 277:
// 278:           system "git", "add", "--all"
// 279:           system "git", "commit", "-m",
// 280:                  "#{old_name.capitalize} has been renamed to #{new_name.capitalize}"
// 281:         end
// 282:       end
// 283:
// 284:       sig { returns(String) }
// 285:       def testball
// 286:         "#{TEST_FIXTURE_DIR}/testball.rb"
// 287:       end
// 288:     end
// 289:   end
// 290: end
// 291:
// 292: # These shared contexts starting with `when` don't make sense.
// 293: RSpec.shared_context "integration test" do # rubocop:disable RSpec/ContextWording
// 294:   T.bind(self, T.class_of(RSpec::Core::ExampleGroup))
// 295:   include Test::Helper::IntegrationTest
// 296:
// 297:   around do |example|
// 298:     ENV["HOMEBREW_INTEGRATION_TEST"] = "1"
// 299:     (HOMEBREW_PREFIX/"bin").mkpath
// 300:     FileUtils.touch HOMEBREW_PREFIX/"bin/brew"
// 301:
// 302:     example.run
// 303:   ensure
// 304:     FileUtils.rm_rf HOMEBREW_PREFIX/"bin"
// 305:     ENV.delete("HOMEBREW_INTEGRATION_TEST")
// 306:   end
// 307: end
// 308:
// 309: RSpec.configure do |config|
// 310:   config.include_context "integration test", :integration_test
// 311: end
