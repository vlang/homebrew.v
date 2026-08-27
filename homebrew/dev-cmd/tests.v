module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/tests.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 56.
pub fn ruby_tests_l56_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `setup_environment!` at line 189.
pub fn ruby_tests_l189_d2_setup_environment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('setup_environment!', ...args)
}

// Ruby method `check_test_environment!; end` at line 261.
pub fn ruby_tests_l261_d3_check_test_environment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_test_environment!', ...args)
}

// Ruby method `changed_test_files` at line 264.
pub fn ruby_tests_l264_d4_changed_test_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('changed_test_files', ...args)
}

// Ruby method `os_bundle_args(bundle_args)` at line 292.
pub fn ruby_tests_l292_d5_os_bundle_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('os_bundle_args', ...args)
}

// Ruby method `non_macos_bundle_args(bundle_args)` at line 298.
pub fn ruby_tests_l298_d6_non_macos_bundle_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('non_macos_bundle_args', ...args)
}

// Ruby method `non_linux_bundle_args(bundle_args)` at line 307.
pub fn ruby_tests_l307_d7_non_linux_bundle_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('non_linux_bundle_args', ...args)
}

// Ruby method `os_files(files)` at line 312.
pub fn ruby_tests_l312_d8_os_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('os_files', ...args)
}

// Ruby method `non_macos_files(files)` at line 318.
pub fn ruby_tests_l318_d9_non_macos_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('non_macos_files', ...args)
}

// Ruby method `non_linux_files(files)` at line 323.
pub fn ruby_tests_l323_d10_non_linux_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('non_linux_files', ...args)
}

// Ruby method `shared_context_test_files(filestub)` at line 328.
pub fn ruby_tests_l328_d11_shared_context_test_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shared_context_test_files', ...args)
}

// Ruby method `tests_tagged_with(tag)` at line 340.
pub fn ruby_tests_l340_d12_tests_tagged_with(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tests_tagged_with', ...args)
}

// Ruby method `file_uses_rspec_tag?(path, tag)` at line 351.
pub fn ruby_tests_l351_d13_file_uses_rspec_tag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('file_uses_rspec_tag?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "fileutils"
// 6: require "hardware"
// 7: require "system_command"
// 8: require "utils/git"
// 9:
// 10: module Homebrew
// 11:   module DevCmd
// 12:     class Tests < AbstractCommand
// 13:       include SystemCommand::Mixin
// 14:
// 15:       cmd_args do
// 16:         description <<~EOS
// 17:           Run Homebrew's unit and integration tests.
// 18:         EOS
// 19:         switch "--coverage",
// 20:                description: "Generate code coverage reports."
// 21:         switch "--generic",
// 22:                description: "Run only OS-agnostic tests."
// 23:         switch "--online",
// 24:                description: "Include tests that use the GitHub API and tests that use any of the taps for " \
// 25:                             "official external commands."
// 26:         switch "--debug",
// 27:                description: "Enable debugging using `ruby/debug`, or surface the standard `odebug` output."
// 28:         switch "--changed",
// 29:                description: "Only runs tests on files that were changed from the `main` branch."
// 30:         switch "--fail-fast",
// 31:                description: "Exit early on the first failing test."
// 32:         switch "--no-parallel",
// 33:                description: "Run tests serially."
// 34:         switch "--stackprof",
// 35:                description: "Use `stackprof` to profile tests."
// 36:         switch "--vernier",
// 37:                description: "Use `vernier` to profile tests."
// 38:         switch "--ruby-prof",
// 39:                description: "Use `ruby-prof` to profile tests."
// 40:         flag   "--only=",
// 41:                description: "Run only `<test_script>_spec.rb`. Appending `:<line_number>` will start at a " \
// 42:                             "specific line."
// 43:         flag   "--profile=",
// 44:                description: "Output the <n> slowest tests. When run without `--no-parallel` this will output " \
// 45:                             "the slowest tests for each parallel test process."
// 46:         flag   "--seed=",
// 47:                description: "Randomise tests with the specified <value> instead of a random seed."
// 48:
// 49:         conflicts "--changed", "--only"
// 50:         conflicts "--stackprof", "--vernier", "--ruby-prof"
// 51:
// 52:         named_args :none
// 53:       end
// 54:
// 55:       sig { override.void }
// 56:       def run
// 57:         # Given we might be testing various commands, we probably want everything (except sorbet-static)
// 58:         groups = Homebrew.valid_gem_groups - ["sorbet"]
// 59:         groups << "prof" if args.stackprof? || args.vernier? || args.ruby_prof?
// 60:         Homebrew.install_bundler_gems!(groups:)
// 61:
// 62:         HOMEBREW_LIBRARY_PATH.cd do
// 63:           setup_environment!
// 64:
// 65:           # Needs required here, after `setup_environment!`, so that
// 66:           # `HOMEBREW_TEST_GENERIC_OS` is set and `OS.linux?` and `OS.mac?` both
// 67:           # `return false`.
// 68:           require "extend/os/dev-cmd/tests"
// 69:
// 70:           check_test_environment!
// 71:
// 72:           parallel = !args.no_parallel?
// 73:
// 74:           only = args.only
// 75:           files = if only
// 76:             only.split(",").flat_map do |test|
// 77:               test_name, line = test.split(":", 2)
// 78:               tests = if line.present?
// 79:                 parallel = false
// 80:                 ["test/#{test_name}_spec.rb:#{line}"]
// 81:               else
// 82:                 Dir.glob("test/{#{test_name},#{test_name}/**/*}_spec.rb")
// 83:               end
// 84:               raise UsageError, "Invalid `--only` argument: #{test}" if tests.blank?
// 85:
// 86:               tests
// 87:             end
// 88:           elsif args.changed?
// 89:             changed_test_files
// 90:           else
// 91:             Dir.glob("test/**/*_spec.rb")
// 92:           end
// 93:
// 94:           if files.blank?
// 95:             raise UsageError, "The `--only` argument requires a valid file or folder name!" if only
// 96:
// 97:             if args.changed?
// 98:               opoo "No tests are directly associated with the changed files!"
// 99:               return
// 100:             end
// 101:           end
// 102:
// 103:           parallel_rspec_log_name = "parallel_runtime_rspec"
// 104:           parallel_rspec_log_name = "#{parallel_rspec_log_name}.generic" if args.generic?
// 105:           parallel_rspec_log_name = "#{parallel_rspec_log_name}.online" if args.online?
// 106:           parallel_rspec_log_name = "#{parallel_rspec_log_name}.log"
// 107:
// 108:           parallel_rspec_log_path = if ENV["CI"]
// 109:             "tests/#{parallel_rspec_log_name}"
// 110:           else
// 111:             "#{HOMEBREW_CACHE}/#{parallel_rspec_log_name}"
// 112:           end
// 113:           ENV["PARALLEL_RSPEC_LOG_PATH"] = parallel_rspec_log_path
// 114:
// 115:           parallel_args = if ENV["CI"]
// 116:             %W[
// 117:               --combine-stderr
// 118:               --serialize-stdout
// 119:               --runtime-log #{parallel_rspec_log_path}
// 120:             ]
// 121:           else
// 122:             %w[
// 123:               --nice
// 124:             ]
// 125:           end
// 126:
// 127:           # Generate seed ourselves and output later to avoid multiple different
// 128:           # seeds being output when running parallel tests.
// 129:           seed = args.seed || rand(0xFFFF).to_i
// 130:
// 131:           bundle_args = ["-I", (HOMEBREW_LIBRARY_PATH/"test").to_s]
// 132:           bundle_args += %W[
// 133:             --seed #{seed}
// 134:             --color
// 135:             --require spec_helper
// 136:           ]
// 137:           bundle_args << "--fail-fast" if args.fail_fast?
// 138:           bundle_args << "--profile" << args.profile if args.profile
// 139:           bundle_args << "--tag" << "~needs_arm" unless Hardware::CPU.arm?
// 140:           bundle_args << "--tag" << "~needs_intel" unless Hardware::CPU.intel?
// 141:           bundle_args << "--tag" << "~needs_network" unless args.online?
// 142:           bundle_args << "--tag" << "~needs_ci" unless ENV["CI"]
// 143:
// 144:           bundle_args = os_bundle_args(bundle_args)
// 145:           files = os_files(files)
// 146:
// 147:           puts "Randomized with seed #{seed}"
// 148:
// 149:           ENV["HOMEBREW_DEBUG"] = "1" if args.debug? # Used in spec_helper.rb to require the "debug" gem.
// 150:
// 151:           # Workaround for:
// 152:           #
// 153:           # ```
// 154:           # ruby: no -r allowed while running setuid (SecurityError)
// 155:           # ```
// 156:           Process::UID.change_privilege(Process.euid) if Process.euid != Process.uid
// 157:
// 158:           test_prof = "#{HOMEBREW_LIBRARY_PATH}/tmp/test_prof"
// 159:           if args.stackprof?
// 160:             ENV["TEST_STACK_PROF"] = "1"
// 161:             prof_input_filename = "#{test_prof}/stack-prof-report-wall-raw-total.dump"
// 162:             prof_filename = "#{test_prof}/stack-prof-report-wall-raw-total.html"
// 163:           elsif args.vernier?
// 164:             ENV["TEST_VERNIER"] = "1"
// 165:           elsif args.ruby_prof?
// 166:             ENV["TEST_RUBY_PROF"] = "call_stack"
// 167:             prof_filename = "#{test_prof}/ruby-prof-report-call_stack-wall-total.html"
// 168:           end
// 169:
// 170:           if parallel
// 171:             system("bundle", "exec", "parallel_rspec", *parallel_args,
// 172:                    "--", *bundle_args, "--", *files)
// 173:           else
// 174:             system("bundle", "exec", "rspec", *bundle_args, "--", *files)
// 175:           end
// 176:           success = $CHILD_STATUS.success?
// 177:
// 178:           safe_system "stackprof --d3-flamegraph #{prof_input_filename} > #{prof_filename}" if args.stackprof?
// 179:
// 180:           exec_browser prof_filename if prof_filename
// 181:
// 182:           return if success
// 183:
// 184:           Homebrew.failed = true
// 185:         end
// 186:       end
// 187:
// 188:       sig { returns(T::Array[String]) }
// 189:       def setup_environment!
// 190:         # Cleanup any unwanted user configuration.
// 191:         allowed_test_env = %w[
// 192:           HOMEBREW_GITHUB_API_TOKEN
// 193:           HOMEBREW_CACHE
// 194:           HOMEBREW_LOGS
// 195:           HOMEBREW_TEMP
// 196:         ]
// 197:         allowed_test_env << "HOMEBREW_USE_RUBY_FROM_PATH" if Homebrew::EnvConfig.developer?
// 198:         Homebrew::EnvConfig::ENVS.keys.map(&:to_s).each do |env|
// 199:           next if allowed_test_env.include?(env)
// 200:
// 201:           ENV.delete(env)
// 202:         end
// 203:
// 204:         # Fetch JSON API files if needed.
// 205:         require "api"
// 206:         Homebrew::API.fetch_api_files!
// 207:
// 208:         # Codespaces HOMEBREW_PREFIX and /tmp are mounted 755 which makes Ruby warn constantly.
// 209:         if (ENV["HOMEBREW_CODESPACES"] == "true") && (HOMEBREW_TEMP.to_s == "/tmp")
// 210:           # Need to keep this fairly short to avoid socket paths being too long in tests.
// 211:           homebrew_prefix_tmp = "/home/linuxbrew/tmp"
// 212:           ENV["HOMEBREW_TEMP"] = homebrew_prefix_tmp
// 213:           FileUtils.mkdir_p homebrew_prefix_tmp
// 214:           system "chmod", "-R", "g-w,o-w", HOMEBREW_PREFIX, homebrew_prefix_tmp
// 215:         end
// 216:
// 217:         ENV["HOMEBREW_TESTS"] = "1"
// 218:         ENV.delete("HOMEBREW_ASK")
// 219:         ENV["HOMEBREW_NO_AUTO_UPDATE"] = "1"
// 220:         ENV["HOMEBREW_NO_ANALYTICS_THIS_RUN"] = "1"
// 221:         ENV["HOMEBREW_TEST_GENERIC_OS"] = "1" if args.generic?
// 222:         ENV["HOMEBREW_TEST_ONLINE"] = "1" if args.online?
// 223:         # Keep in sync with `Library/Homebrew/brew.sh`.
// 224:         if ENV["HOMEBREW_TESTS_NO_SORBET_RUNTIME"]
// 225:           ENV.delete("HOMEBREW_SORBET_RUNTIME")
// 226:           ENV.delete("HOMEBREW_SORBET_RECURSIVE")
// 227:         else
// 228:           ENV["HOMEBREW_SORBET_RUNTIME"] = "1"
// 229:           ENV["HOMEBREW_SORBET_RECURSIVE"] = "1"
// 230:         end
// 231:
// 232:         ENV["USER"] ||= system_command!("id", args: ["-nu"]).stdout.chomp
// 233:
// 234:         # Avoid local configuration messing with tests, e.g. git being configured
// 235:         # to use GPG to sign by default
// 236:         ENV["HOME"] = "#{HOMEBREW_LIBRARY_PATH}/test"
// 237:         # Keep generic tool caches (e.g. RuboCop) out of the sandboxed test home.
// 238:         ENV["XDG_CACHE_HOME"] = "#{HOMEBREW_CACHE}/tests"
// 239:         # Sandbox the config home too, so the spec teardown can't delete the real `trust.json`.
// 240:         ENV["HOMEBREW_USER_CONFIG_HOME"] = "#{Dir.home}/.homebrew"
// 241:
// 242:         # Print verbose output when requesting debug or verbose output.
// 243:         ENV["HOMEBREW_VERBOSE_TESTS"] = "1" if args.debug? || args.verbose?
// 244:
// 245:         if args.coverage?
// 246:           ENV["HOMEBREW_TESTS_COVERAGE"] = "1"
// 247:           FileUtils.rm_f "test/coverage/.resultset.json"
// 248:           FileUtils.rm_f Dir["test/coverage/.simulated_files*"]
// 249:         end
// 250:
// 251:         # Override author/committer as global settings might be invalid and thus
// 252:         # will cause silent failure during the setup of dummy Git repositories.
// 253:         %w[AUTHOR COMMITTER].each do |role|
// 254:           ENV["GIT_#{role}_NAME"] = "brew tests"
// 255:           ENV["GIT_#{role}_EMAIL"] = "brew-tests@localhost"
// 256:           ENV["GIT_#{role}_DATE"]  = "Sun Jan 22 19:59:13 2017 +0000"
// 257:         end
// 258:       end
// 259:
// 260:       sig { void }
// 261:       def check_test_environment!; end
// 262:
// 263:       sig { returns(T::Array[String]) }
// 264:       def changed_test_files
// 265:         changed_files = Utils::Git.changed_files(HOMEBREW_REPOSITORY)
// 266:
// 267:         odebug "No files have been changed from the default branch." if changed_files.empty?
// 268:         return [] if changed_files.empty?
// 269:
// 270:         filestub_regex = %r{Library/Homebrew/([\w/-]+).rb}
// 271:         changed_files.filter_map { |file| file[filestub_regex, 1] }
// 272:                      .flat_map do |filestub|
// 273:           shared_context_tests = shared_context_test_files(filestub)
// 274:           next shared_context_tests if shared_context_tests.present?
// 275:
// 276:           if filestub.start_with?("test/")
// 277:             # Only run tests on *_spec.rb files in test/ folder
// 278:             filestub.end_with?("_spec") ? [Pathname("#{filestub}.rb")] : []
// 279:           else
// 280:             # For all other changed .rb files guess the associated test file name
// 281:             [Pathname("test/#{filestub}_spec.rb")]
// 282:           end
// 283:         end
// 284:           .uniq
// 285:           .select(&:exist?)
// 286:           .map(&:to_s)
// 287:       end
// 288:
// 289:       private
// 290:
// 291:       sig { params(bundle_args: T::Array[String]).returns(T::Array[String]) }
// 292:       def os_bundle_args(bundle_args)
// 293:         # for generic tests, remove macOS or Linux specific tests
// 294:         non_linux_bundle_args(non_macos_bundle_args(bundle_args))
// 295:       end
// 296:
// 297:       sig { params(bundle_args: T::Array[String]).returns(T::Array[String]) }
// 298:       def non_macos_bundle_args(bundle_args)
// 299:         bundle_args << "--tag" << "~needs_homebrew_core" if ENV["CI"]
// 300:         bundle_args << "--tag" << "~needs_svnadmin" unless args.online?
// 301:         bundle_args << "--tag" << "~needs_svn" unless args.online?
// 302:
// 303:         bundle_args << "--tag" << "~needs_macos" << "--tag" << "~cask"
// 304:       end
// 305:
// 306:       sig { params(bundle_args: T::Array[String]).returns(T::Array[String]) }
// 307:       def non_linux_bundle_args(bundle_args)
// 308:         bundle_args << "--tag" << "~needs_linux" << "--tag" << "~needs_systemd"
// 309:       end
// 310:
// 311:       sig { params(files: T::Array[String]).returns(T::Array[String]) }
// 312:       def os_files(files)
// 313:         # for generic tests, remove macOS or Linux specific files
// 314:         non_linux_files(non_macos_files(files))
// 315:       end
// 316:
// 317:       sig { params(files: T::Array[String]).returns(T::Array[String]) }
// 318:       def non_macos_files(files)
// 319:         files.grep_v(%r{^test/(os/mac|cask)(/.*|_spec\.rb)$})
// 320:       end
// 321:
// 322:       sig { params(files: T::Array[String]).returns(T::Array[String]) }
// 323:       def non_linux_files(files)
// 324:         files.grep_v(%r{^test/os/linux(/.*|_spec\.rb)$})
// 325:       end
// 326:
// 327:       sig { params(filestub: String).returns(T::Array[Pathname]) }
// 328:       def shared_context_test_files(filestub)
// 329:         case filestub
// 330:         when "test/support/helper/spec/shared_context/integration_test"
// 331:           tests_tagged_with("integration_test")
// 332:         when "test/support/helper/spec/shared_context/homebrew_cask"
// 333:           tests_tagged_with("cask")
// 334:         else
// 335:           []
// 336:         end
// 337:       end
// 338:
// 339:       sig { params(tag: String).returns(T::Array[Pathname]) }
// 340:       def tests_tagged_with(tag)
// 341:         Dir.glob("test/**/*_spec.rb").filter_map do |file|
// 342:           path = Pathname(file)
// 343:           next unless path.exist?
// 344:           next unless file_uses_rspec_tag?(path, tag)
// 345:
// 346:           path
// 347:         end
// 348:       end
// 349:
// 350:       sig { params(path: Pathname, tag: String).returns(T::Boolean) }
// 351:       def file_uses_rspec_tag?(path, tag)
// 352:         escaped_tag = Regexp.escape(tag)
// 353:         rspec_declaration_methods = %w[describe context it specify example].join("|")
// 354:         rspec_declaration_regex = /^\s*(?:RSpec\.)?(?:#{rspec_declaration_methods})\b/
// 355:         # Match symbol tag syntax: `:tag_name`.
// 356:         symbol_tag_regex = /(?:^|[,(])\s*:#{escaped_tag}\b/
// 357:         # Match hash tag syntax: `tag_name: true/false/nil/value`.
// 358:         hash_tag_regex = /(?:^|[,(])\s*#{escaped_tag}:\s*(?:true|false|nil|:[a-z_]\w*|[a-z_]\w*)?/i
// 359:
// 360:         path.read.each_line.any? do |line|
// 361:           is_rspec_declaration = line.match?(rspec_declaration_regex)
// 362:           has_tag = line.match?(symbol_tag_regex) || line.match?(hash_tag_regex)
// 363:           is_rspec_declaration && has_tag
// 364:         end
// 365:       end
// 366:     end
// 367:   end
// 368: end
