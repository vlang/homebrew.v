module test

// Translated from Homebrew/brew `test/spec_helper.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: if ENV["HOMEBREW_TESTS_COVERAGE"]
// 5:   require "simplecov"
// 6:   require "simplecov-cobertura"
// 7:   SimpleCov.start
// 8:
// 9:   formatters = [
// 10:     SimpleCov::Formatter::HTMLFormatter,
// 11:     SimpleCov::Formatter::CoberturaFormatter,
// 12:   ]
// 13:   SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new(formatters)
// 14: end
// 15:
// 16: require_relative "../standalone"
// 17: require_relative "../warnings"
// 18:
// 19: Warnings.ignore(/CGI library is removed from Ruby 4\.0\./) { require "cgi" }
// 20:
// 21: require "test-prof"
// 22:
// 23: Warnings.ignore :parser_syntax do
// 24:   require "rubocop"
// 25: end
// 26:
// 27: require "rspec/github"
// 28: require "rspec/retry"
// 29: require "rspec/sorbet"
// 30: require "rubocop/rspec/support"
// 31: require "find"
// 32: require "timeout"
// 33:
// 34: $LOAD_PATH.unshift(File.expand_path("#{ENV.fetch("HOMEBREW_LIBRARY")}/Homebrew/test/support/lib"))
// 35:
// 36: require_relative "support/extend/cachable"
// 37:
// 38: require_relative "../global"
// 39:
// 40: require "debug" if ENV["HOMEBREW_DEBUG"]
// 41:
// 42: require "test/support/quiet_progress_formatter"
// 43: require "test/support/helper/api_hashable"
// 44: require "test/support/helper/cask"
// 45: require "test/support/helper/files"
// 46: require "test/support/helper/fixtures"
// 47: require "test/support/helper/formula"
// 48: require "test/support/helper/mktmpdir"
// 49: require "test/support/helper/subcommand"
// 50: require "test/support/helper/test_each"
// 51:
// 52: require "test/support/helper/spec/shared_context/homebrew_cask" if OS.mac?
// 53: require "test/support/helper/spec/shared_context/integration_test"
// 54: require "test/support/helper/spec/shared_context/trust_store"
// 55: require "test/support/helper/spec/shared_examples/formulae_exist"
// 56:
// 57: TEST_DIRECTORIES = [
// 58:   CoreTap.instance.path/"Formula",
// 59:   HOMEBREW_CACHE,
// 60:   HOMEBREW_CACHE_FORMULA,
// 61:   HOMEBREW_CACHE/"api",
// 62:   HOMEBREW_CELLAR,
// 63:   HOMEBREW_LOCKS,
// 64:   HOMEBREW_LOGS,
// 65:   HOMEBREW_TEMP,
// 66:   HOMEBREW_TEMP_CELLAR,
// 67:   HOMEBREW_ALIASES,
// 68: ].freeze
// 69:
// 70: # Make `instance_double` and `class_double`
// 71: # work when type-checking is active.
// 72: RSpec::Sorbet.allow_doubles!
// 73:
// 74: RSpec.configure do |config|
// 75:   config.order = :random
// 76:
// 77:   config.raise_errors_for_deprecations!
// 78:   config.warnings = true
// 79:   config.raise_on_warning = true
// 80:   config.disable_monkey_patching!
// 81:
// 82:   config.filter_run_when_matching :focus
// 83:
// 84:   config.silence_filter_announcements = true if ENV["TEST_ENV_NUMBER"]
// 85:
// 86:   # Improve backtrace formatting
// 87:   config.filter_gems_from_backtrace "rspec-retry", "sorbet-runtime"
// 88:   config.backtrace_exclusion_patterns << %r{test/spec_helper\.rb}
// 89:
// 90:   config.expect_with :rspec do |c|
// 91:     c.max_formatted_output_length = 200
// 92:   end
// 93:
// 94:   # Use rspec-retry to handle flaky tests.
// 95:   config.default_sleep_interval = 1
// 96:
// 97:   # Don't want the nicer default retry behaviour when using CodeCov to
// 98:   # identify flaky tests.
// 99:   config.default_retry_count = 2 unless ENV["CODECOV_TOKEN"]
// 100:
// 101:   config.expect_with :rspec do |expectations|
// 102:     # This option will default to `true` in RSpec 4. It makes the `description`
// 103:     # and `failure_message` of custom matchers include text for helper methods
// 104:     # defined using `chain`, e.g.:
// 105:     #     be_bigger_than(2).and_smaller_than(4).description
// 106:     #     # => "be bigger than 2 and smaller than 4"
// 107:     # ...rather than:
// 108:     #     # => "be bigger than 2"
// 109:     expectations.include_chain_clauses_in_custom_matcher_descriptions = true
// 110:   end
// 111:   config.mock_with :rspec do |mocks|
// 112:     # Prevents you from mocking or stubbing a method that does not exist on
// 113:     # a real object. This is generally recommended and will default to
// 114:     # `true` in RSpec 4.
// 115:     mocks.verify_partial_doubles = true
// 116:   end
// 117:   config.shared_context_metadata_behavior = :apply_to_host_groups
// 118:
// 119:   # Increase timeouts for integration tests (as we expect them to take longer).
// 120:   config.around(:each, :integration_test) do |example|
// 121:     example.metadata[:timeout] ||= 120
// 122:     example.run
// 123:   end
// 124:
// 125:   config.around(:each, :needs_network) do |example|
// 126:     example.metadata[:timeout] ||= 120
// 127:
// 128:     # Don't want the nicer default retry behaviour when using CodeCov to
// 129:     # identify flaky tests.
// 130:     example.metadata[:retry] ||= 4 unless ENV["CODECOV_TOKEN"]
// 131:
// 132:     example.metadata[:retry_wait] ||= 2
// 133:     example.metadata[:exponential_backoff] ||= true
// 134:     example.run
// 135:   end
// 136:
// 137:   # Never truncate output objects.
// 138:   RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = nil
// 139:
// 140:   config.include(RuboCop::RSpec::ExpectOffense)
// 141:
// 142:   config.include(Test::Helper::Cask)
// 143:   config.include(Test::Helper::Fixtures)
// 144:   config.include(Test::Helper::Formula)
// 145:   config.include(Test::Helper::MkTmpDir)
// 146:   config.include(Test::Helper::Subcommand)
// 147:
// 148:   config.extend(Test::Helper::TestEach)
// 149:
// 150:   # Enable aggregate failures by default
// 151:   config.define_derived_metadata do |metadata|
// 152:     metadata[:aggregate_failures] = true unless metadata.key?(:aggregate_failures)
// 153:   end
// 154:
// 155:   config.before(:each, :needs_linux) do
// 156:     skip "Not running on Linux." unless OS.linux?
// 157:   end
// 158:
// 159:   config.before(:each, :needs_macos) do
// 160:     skip "Not running on macOS." unless OS.mac?
// 161:   end
// 162:
// 163:   config.before(:each, :needs_ci) do
// 164:     skip "Not running on CI." unless ENV["CI"]
// 165:   end
// 166:
// 167:   config.before(:each, :needs_java) do
// 168:     skip "Java is not installed." unless which("java")
// 169:   end
// 170:
// 171:   config.before(:each, :needs_jq) do
// 172:     skip "jq is not installed." unless which("jq")
// 173:   end
// 174:
// 175:   config.before(:each, :needs_python) do
// 176:     skip "Python is not installed." if !which("python3") && !which("python")
// 177:   end
// 178:
// 179:   config.before(:each, :needs_network) do
// 180:     skip "Requires network connection." unless ENV["HOMEBREW_TEST_ONLINE"]
// 181:   end
// 182:
// 183:   config.before(:each, :needs_homebrew_core) do
// 184:     core_tap_path = "#{ENV.fetch("HOMEBREW_LIBRARY")}/Taps/homebrew/homebrew-core"
// 185:     skip "Requires homebrew/core to be tapped." unless Dir.exist?(core_tap_path)
// 186:   end
// 187:
// 188:   config.before(:each, :needs_systemd) do
// 189:     skip "No SystemD found." unless which("systemctl")
// 190:   end
// 191:
// 192:   config.before(:each, :needs_daemon_manager) do
// 193:     skip "No LaunchCTL or SystemD found." if !which("systemctl") && !which("launchctl")
// 194:   end
// 195:
// 196:   config.before do |example|
// 197:     next if example.metadata.key?(:needs_network)
// 198:     next if example.metadata.key?(:needs_utils_curl)
// 199:
// 200:     allow(Utils::Curl).to receive(:curl_executable).and_raise(<<~ERROR)
// 201:       Unexpected call to Utils::Curl.curl_executable without setting :needs_network or :needs_utils_curl.
// 202:     ERROR
// 203:   end
// 204:
// 205:   config.before(:each, :no_api) do
// 206:     ENV["HOMEBREW_NO_INSTALL_FROM_API"] = "1"
// 207:   end
// 208:
// 209:   svn_path_dirs = nil
// 210:   svn_skip_reason = nil
// 211:   svn_client_path_dirs = nil
// 212:   svn_client_skip_reason = nil
// 213:
// 214:   config.define_derived_metadata(:needs_svnadmin) do |metadata|
// 215:     metadata[:needs_svn] = true
// 216:   end
// 217:
// 218:   config.before(:each, :needs_svn) do
// 219:     skip svn_client_skip_reason if svn_client_skip_reason
// 220:     if svn_client_path_dirs
// 221:       ENV["PATH"] = PATH.new(ENV.fetch("PATH")).append(svn_client_path_dirs)
// 222:       next
// 223:     end
// 224:
// 225:     svn_paths = PATH.new(ENV.fetch("PATH"))
// 226:
// 227:     if OS.mac?
// 228:       xcrun_svn = Utils.popen_read("xcrun", "-f", "svn")
// 229:       svn_paths.append(File.dirname(xcrun_svn)) if $CHILD_STATUS.success? && xcrun_svn.present?
// 230:     end
// 231:
// 232:     svn_shim = HOMEBREW_SHIMS_PATH/"shared/svn"
// 233:     unless quiet_system svn_shim, "--version"
// 234:       svn_client_skip_reason = "Subversion is not installed."
// 235:       skip svn_client_skip_reason
// 236:     end
// 237:
// 238:     svn_shim_path = Pathname(Utils.popen_read(svn_shim, "--homebrew=print-path").chomp.presence)
// 239:     svn_paths.prepend(svn_shim_path.dirname)
// 240:
// 241:     svn = which("svn", svn_paths)
// 242:     unless svn
// 243:       svn_client_skip_reason = "svn is not installed."
// 244:       skip svn_client_skip_reason
// 245:     end
// 246:
// 247:     svn_client_path_dirs = [svn.dirname]
// 248:     ENV["PATH"] = PATH.new(ENV.fetch("PATH")).append(svn_client_path_dirs)
// 249:   end
// 250:
// 251:   config.before(:each, :needs_svnadmin) do
// 252:     skip svn_skip_reason if svn_skip_reason
// 253:     if svn_path_dirs
// 254:       ENV["PATH"] = PATH.new(ENV.fetch("PATH")).append(svn_path_dirs)
// 255:       next
// 256:     end
// 257:
// 258:     svnadmin = which("svnadmin")
// 259:     unless svnadmin
// 260:       svn_skip_reason = "svnadmin is not installed."
// 261:       skip svn_skip_reason
// 262:     end
// 263:
// 264:     svn_path_dirs = [svnadmin.dirname]
// 265:     ENV["PATH"] = PATH.new(ENV.fetch("PATH")).append(svn_path_dirs)
// 266:   end
// 267:
// 268:   config.before(:each, :needs_homebrew_curl) do
// 269:     ENV["HOMEBREW_CURL"] = HOMEBREW_BREWED_CURL_PATH
// 270:     skip "A `curl` with TLS 1.3 support is required." unless Utils::Curl.curl_supports_tls13?
// 271:   rescue FormulaUnavailableError
// 272:     skip "No `curl` formula is available."
// 273:   end
// 274:
// 275:   config.before(:each, :needs_unzip) do
// 276:     skip "Unzip is not installed." unless which("unzip")
// 277:   end
// 278:
// 279:   config.around do |example|
// 280:     Homebrew.raise_deprecation_exceptions = true
// 281:
// 282:     Tap.installed.each(&:clear_cache)
// 283:     Cachable::Registry.clear_all_caches
// 284:     FormulaInstaller.attempted.clear
// 285:     FormulaInstaller.installed.clear
// 286:     FormulaInstaller.fetched.clear
// 287:     Utils::Curl.clear_path_cache
// 288:
// 289:     TEST_DIRECTORIES.each(&:mkpath)
// 290:
// 291:     @__homebrew_failed = Homebrew.failed?
// 292:
// 293:     @__files_before_test = Test::Helper::Files.find_files
// 294:
// 295:     @__env = ENV.to_hash # dup doesn't work on ENV
// 296:
// 297:     @__stdout = $stdout.clone
// 298:     @__stderr = $stderr.clone
// 299:     @__stdin = $stdin.clone
// 300:
// 301:     # Link original API cache files to test cache directory.
// 302:     source_api_cache = Pathname("#{ENV.fetch("HOMEBREW_CACHE")}/api")
// 303:
// 304:     source_api_cache.glob("*.json").each do |path|
// 305:       target = HOMEBREW_CACHE/"api/#{path.basename}"
// 306:       FileUtils.ln_s path, target unless target.exist?
// 307:     end
// 308:     source_api_cache.glob("*.txt").each do |path|
// 309:       target = HOMEBREW_CACHE/"api/#{path.basename}"
// 310:       FileUtils.cp path, target unless target.exist?
// 311:     end
// 312:
// 313:     source_api_internal_cache = source_api_cache/"internal"
// 314:     target_api_internal_cache = HOMEBREW_CACHE/"api/internal"
// 315:     target_api_internal_cache.mkpath
// 316:
// 317:     # The real cache can hold package API files for multiple OS tags. Fan out
// 318:     # from one source so generated test-cache aliases do not collide.
// 319:     package_paths = source_api_internal_cache.glob("packages.*.jws.json")
// 320:     package_path = package_paths.find do |path|
// 321:       path.basename.to_s == "packages.#{Homebrew::SimulateSystem.current_tag}.jws.json"
// 322:     end || package_paths.first
// 323:
// 324:     source_api_internal_cache.glob("*.{json,txt}").each do |path|
// 325:       next if path.basename.to_s.start_with?("packages.")
// 326:
// 327:       target = target_api_internal_cache/path.basename
// 328:       next if target.exist?
// 329:
// 330:       (path.extname == ".txt") ? FileUtils.cp(path, target) : FileUtils.ln(path, target)
// 331:     end
// 332:
// 333:     if package_path
// 334:       [:generic, :linux, :macos, *MacOSVersion::SYMBOLS.keys].product([:arm, :intel]).each do |system, arch|
// 335:         tag = Utils::Bottles::Tag.new(system:, arch:)
// 336:         next unless tag.valid_combination?
// 337:
// 338:         target = target_api_internal_cache/"packages.#{tag}.jws.json"
// 339:         FileUtils.ln package_path, target unless target.exist?
// 340:       end
// 341:     end
// 342:
// 343:     begin
// 344:       if example.metadata.keys.exclude?(:focus) && !ENV.key?("HOMEBREW_VERBOSE_TESTS")
// 345:         $stdout.reopen(File::NULL)
// 346:         $stderr.reopen(File::NULL)
// 347:         $stdin.reopen(File::NULL)
// 348:       else
// 349:         # don't retry when focusing
// 350:         config.default_retry_count = 0
// 351:       end
// 352:
// 353:       begin
// 354:         timeout = example.metadata.fetch(:timeout, 60)
// 355:         Timeout.timeout(timeout) do
// 356:           example.run
// 357:         end
// 358:       rescue Timeout::Error => e
// 359:         example.example.set_exception(e)
// 360:       end
// 361:     rescue SystemExit => e
// 362:       example.example.set_exception(e)
// 363:     ensure
// 364:       ENV.replace(@__env)
// 365:       Homebrew::SimulateSystem.clear
// 366:       Context.current = Context::ContextStruct.new
// 367:       # Shut down and drop any memoized download queue so an example that
// 368:       # stubbed `DownloadQueue.new` cannot leak a double into later examples
// 369:       # or the `at_exit` shutdown hook.
// 370:       Homebrew.reset_default_download_queue if Homebrew.respond_to?(:reset_default_download_queue)
// 371:
// 372:       $stdout.reopen(@__stdout)
// 373:       $stderr.reopen(@__stderr)
// 374:       $stdin.reopen(@__stdin)
// 375:       @__stdout.close
// 376:       @__stderr.close
// 377:       @__stdin.close
// 378:
// 379:       Tap.all.each(&:clear_cache)
// 380:       Cachable::Registry.clear_all_caches
// 381:
// 382:       # Refuse to clean a config home outside the sandboxed `HOME`, else this deletes the user's
// 383:       # real `~/.homebrew/trust.json`; canonicalise first so `..`/symlinks can't slip past.
// 384:       home = Pathname(Dir.home).realpath
// 385:       user_config_home = Pathname(ENV.fetch("HOMEBREW_USER_CONFIG_HOME")).expand_path
// 386:       resolved_ancestor = user_config_home.ascend.find(&:exist?)&.realpath
// 387:       unless resolved_ancestor&.ascend&.include?(home)
// 388:         raise "HOMEBREW_USER_CONFIG_HOME (#{user_config_home}) is not sandboxed under HOME (#{Dir.home})"
// 389:       end
// 390:
// 391:       FileUtils.rm_rf [
// 392:         *TEST_DIRECTORIES,
// 393:         *Keg.must_exist_subdirectories,
// 394:         HOMEBREW_LINKED_KEGS,
// 395:         HOMEBREW_PINNED_KEGS,
// 396:         HOMEBREW_PINNED_CASKS,
// 397:         user_config_home/"trust.json",
// 398:         HOMEBREW_PREFIX/"Caskroom",
// 399:         HOMEBREW_PREFIX/"Frameworks",
// 400:         HOMEBREW_LIBRARY/"Taps/homebrew/homebrew-cask",
// 401:         HOMEBREW_LIBRARY/"Taps/homebrew/homebrew-bar",
// 402:         HOMEBREW_LIBRARY/"Taps/homebrew/homebrew-foo",
// 403:         HOMEBREW_LIBRARY/"Taps/homebrew/homebrew-test-bot",
// 404:         HOMEBREW_LIBRARY/"Taps/homebrew/homebrew-shallow",
// 405:         HOMEBREW_LIBRARY/"PinnedTaps",
// 406:         HOMEBREW_REPOSITORY/".git",
// 407:         CoreTap.instance.path/".git",
// 408:         CoreTap.instance.alias_dir,
// 409:         CoreTap.instance.path/"formula_renames.json",
// 410:         CoreTap.instance.path/"tap_migrations.json",
// 411:         CoreTap.instance.path/"audit_exceptions",
// 412:         CoreTap.instance.path/"style_exceptions",
// 413:         *Pathname.glob("#{HOMEBREW_CELLAR}/*/"),
// 414:         HOMEBREW_LIBRARY_PATH/"test/.vscode",
// 415:         HOMEBREW_LIBRARY_PATH/"test/.cursor",
// 416:         HOMEBREW_LIBRARY_PATH/"test/Library",
// 417:       ]
// 418:
// 419:       files_after_test = Test::Helper::Files.find_files
// 420:
// 421:       diff = Set.new(@__files_before_test) ^ Set.new(files_after_test)
// 422:       expect(diff).to be_empty, <<~EOS
// 423:         file leak detected:
// 424:         #{diff.map { |f| "  #{f}" }.join("\n")}
// 425:       EOS
// 426:
// 427:       Homebrew.failed = @__homebrew_failed
// 428:     end
// 429:   end
// 430: end
// 431:
// 432: RSpec::Matchers.define_negated_matcher :not_to_output, :output
// 433: RSpec::Matchers.alias_matcher :have_failed, :be_failed
// 434:
// 435: # Match consecutive elements in an array.
// 436: RSpec::Matchers.define :array_including_cons do |*cons|
// 437:   match do |actual|
// 438:     expect(actual.each_cons(cons.size)).to include(cons)
// 439:   end
// 440: end
