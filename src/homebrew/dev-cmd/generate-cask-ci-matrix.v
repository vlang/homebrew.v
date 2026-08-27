module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/generate-cask-ci-matrix.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 63.
pub fn ruby_generate_cask_ci_matrix_l63_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `filter_runners(cask)` at line 136.
pub fn ruby_generate_cask_ci_matrix_l136_d2_filter_runners(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('filter_runners', ...args)
}

// Ruby method `runner_arch_pairs(runners:, multi_os:)` at line 176.
pub fn ruby_generate_cask_ci_matrix_l176_d3_runner_arch_pairs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('runner_arch_pairs', ...args)
}

// Ruby method `runners(cask:)` at line 196.
pub fn ruby_generate_cask_ci_matrix_l196_d4_runners(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('runners', ...args)
}

// Ruby method `architectures(cask:, os:)` at line 220.
pub fn ruby_generate_cask_ci_matrix_l220_d5_architectures(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('architectures', ...args)
}

// Ruby method `random_runner(available_runners = ARM_MACOS_RUNNERS)` at line 241.
pub fn ruby_generate_cask_ci_matrix_l241_d6_random_runner(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('random_runner', ...args)
}

// Ruby method `generate_matrix(tap, labels: [], cask_names: [], skip_install: false, new_cask: false)` at line 253.
pub fn ruby_generate_cask_ci_matrix_l253_d7_generate_matrix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('generate_matrix', ...args)
}

// Ruby method `find_changed_files(tap)` at line 351.
pub fn ruby_generate_cask_ci_matrix_l351_d8_find_changed_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('find_changed_files', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "tap"
// 6: require "utils/github/api"
// 7: require "cli/parser"
// 8: require "system_command"
// 9:
// 10: module Homebrew
// 11:   module DevCmd
// 12:     class GenerateCaskCiMatrix < AbstractCommand
// 13:       MAX_JOBS = 256
// 14:
// 15:       # Weight for each arch must add up to 1.0.
// 16:       X86_MACOS_RUNNERS = T.let({
// 17:         { symbol: :sequoia, name: "macos-15-intel", arch: :intel } => 1.0,
// 18:       }.freeze, T::Hash[T::Hash[Symbol, T.any(Symbol, String)], Float])
// 19:       X86_LINUX_RUNNERS = T.let({
// 20:         { symbol: :linux, name: "ubuntu-latest", arch: :intel } => 1.0,
// 21:       }.freeze, T::Hash[T::Hash[Symbol, T.any(Symbol, String)], Float])
// 22:       ARM_MACOS_RUNNERS = T.let({
// 23:         { symbol: :sonoma,  name: "macos-14", arch: :arm } => 0.0,
// 24:         { symbol: :sequoia, name: "macos-15", arch: :arm } => 0.0,
// 25:         { symbol: :tahoe,   name: "macos-26", arch: :arm } => 1.0,
// 26:       }.freeze, T::Hash[T::Hash[Symbol, T.any(Symbol, String)], Float])
// 27:       ARM_LINUX_RUNNERS = T.let({
// 28:         { symbol: :linux, name: OS::LINUX_CI_ARM_RUNNER, arch: :arm } => 1.0,
// 29:       }.freeze, T::Hash[T::Hash[Symbol, T.any(Symbol, String)], Float])
// 30:       MACOS_RUNNERS = T.let(X86_MACOS_RUNNERS.merge(ARM_MACOS_RUNNERS).freeze,
// 31:                             T::Hash[T::Hash[Symbol, T.any(Symbol, String)], Float])
// 32:       LINUX_RUNNERS = T.let(X86_LINUX_RUNNERS.merge(ARM_LINUX_RUNNERS).freeze,
// 33:                             T::Hash[T::Hash[Symbol, T.any(Symbol, String)], Float])
// 34:       RUNNERS = T.let(MACOS_RUNNERS.merge(LINUX_RUNNERS).freeze,
// 35:                       T::Hash[T::Hash[Symbol, T.any(Symbol, String)], Float])
// 36:
// 37:       cmd_args do
// 38:         description <<~EOS
// 39:           Generate a GitHub Actions matrix for a given pull request URL or list of cask names.
// 40:           For internal use in Homebrew taps.
// 41:         EOS
// 42:         switch "--url",
// 43:                description: "Treat named argument as a pull request URL."
// 44:         switch "--cask", "--casks",
// 45:                description: "Treat all named arguments as cask tokens."
// 46:         switch "--skip-install",
// 47:                description: "Skip installing casks."
// 48:         switch "--new",
// 49:                description: "Run new cask checks."
// 50:         switch "--syntax-only",
// 51:                description: "Only run syntax checks."
// 52:
// 53:         conflicts "--url", "--cask"
// 54:         conflicts "--syntax-only", "--skip-install"
// 55:         conflicts "--syntax-only", "--new"
// 56:
// 57:         named_args [:cask, :url], min: 0
// 58:
// 59:         hide_from_man_page!
// 60:       end
// 61:
// 62:       sig { override.void }
// 63:       def run
// 64:         skip_install = args.skip_install?
// 65:         new_cask = args.new?
// 66:         casks = args.named if args.casks?
// 67:         pr_url = args.named if args.url?
// 68:         syntax_only = args.syntax_only?
// 69:
// 70:         repository = ENV.fetch("GITHUB_REPOSITORY", nil)
// 71:         raise UsageError, "The `$GITHUB_REPOSITORY` environment variable must be set." if repository.blank?
// 72:
// 73:         tap = T.let(Tap.fetch(repository), Tap)
// 74:
// 75:         unless syntax_only
// 76:           raise UsageError, "Either `--cask` or `--url` must be specified." if !args.casks? && !args.url?
// 77:           raise UsageError, "Please provide a `--cask` or `--url` argument." if casks.blank? && pr_url.blank?
// 78:         end
// 79:         raise UsageError, "Only one `--url` can be specified." if pr_url&.count&.> 1
// 80:
// 81:         labels = if pr_url && (first_pr_url = pr_url.first)
// 82:           pr = GitHub::API.open_rest(first_pr_url)
// 83:           pr.fetch("labels").map { |l| l.fetch("name") }
// 84:         else
// 85:           []
// 86:         end
// 87:
// 88:         runner = random_runner[:name]
// 89:         syntax_job = {
// 90:           name:   "tap_syntax",
// 91:           tap:    tap.name,
// 92:           runner:,
// 93:           stable: false,
// 94:         }
// 95:         stable_syntax_job = syntax_job.merge(name: "tap_syntax (stable)", stable: true, skip_audit: true)
// 96:
// 97:         matrix = [syntax_job, stable_syntax_job]
// 98:
// 99:         if !syntax_only && !labels&.include?("ci-syntax-only")
// 100:           cask_jobs = if casks&.any?
// 101:             generate_matrix(tap, labels:, cask_names: casks, skip_install:, new_cask:)
// 102:           else
// 103:             generate_matrix(tap, labels:, skip_install:, new_cask:)
// 104:           end
// 105:
// 106:           if cask_jobs.any?
// 107:             # If casks were changed, skip `audit` for whole tap.
// 108:             syntax_job[:skip_audit] = true
// 109:
// 110:             # The syntax job only runs `style` at this point, which should work on Linux.
// 111:             # Running on macOS is currently faster though, since `homebrew/cask` and
// 112:             # `homebrew/core` are already tapped on macOS CI machines.
// 113:             # syntax_job[:runner] = "ubuntu-latest"
// 114:           end
// 115:
// 116:           matrix += cask_jobs
// 117:         end
// 118:
// 119:         jobs = matrix.count
// 120:         odie "Maximum job matrix size exceeded: #{jobs}/#{MAX_JOBS}" if jobs > MAX_JOBS
// 121:
// 122:         [syntax_job, stable_syntax_job].each do |job|
// 123:           job[:name] += " (#{job[:runner]})"
// 124:         end
// 125:
// 126:         puts JSON.pretty_generate(matrix)
// 127:         github_output = ENV.fetch("GITHUB_OUTPUT", nil)
// 128:         return unless github_output
// 129:
// 130:         File.open(ENV.fetch("GITHUB_OUTPUT"), "a") do |f|
// 131:           f.puts "matrix=#{JSON.generate(matrix)}"
// 132:         end
// 133:       end
// 134:
// 135:       sig { params(cask: Cask::Cask).returns(T::Hash[T::Hash[Symbol, T.any(Symbol, String)], Float]) }
// 136:       def filter_runners(cask)
// 137:         filtered_runners = T.let({}, T::Hash[T::Hash[Symbol, T.any(Symbol, String)], Float])
// 138:         if cask.supports_macos?
// 139:           # Skip macOS if no runner satisfies the cask's min/max macOS requirements.
// 140:           macos_requirements = [cask.depends_on.macos, cask.depends_on.maximum_macos]
// 141:                                .compact.select(&:version_specified?)
// 142:
// 143:           filtered_runners = if macos_requirements.empty?
// 144:             MACOS_RUNNERS.dup
// 145:           else
// 146:             MACOS_RUNNERS.select do |runner, _|
// 147:               macos_version = MacOSVersion.from_symbol(runner.fetch(:symbol).to_sym)
// 148:               macos_requirements.all? { |requirement| requirement.allows?(macos_version) }
// 149:             end
// 150:           end
// 151:
// 152:           if filtered_runners.any?
// 153:             macos_archs = architectures(cask:, os: :macos)
// 154:             filtered_runners.select! do |runner, _|
// 155:               macos_archs.include?(runner.fetch(:arch))
// 156:             end
// 157:           end
// 158:         end
// 159:
// 160:         return filtered_runners unless cask.supports_linux?
// 161:
// 162:         linux_archs = architectures(cask:, os: :linux)
// 163:         linux_runners = LINUX_RUNNERS.select do |runner, _|
// 164:           linux_archs.include?(runner.fetch(:arch))
// 165:         end
// 166:
// 167:         filtered_runners.merge(linux_runners)
// 168:       end
// 169:
// 170:       sig {
// 171:         params(
// 172:           runners:  T::Array[T::Hash[Symbol, T.any(Symbol, String)]],
// 173:           multi_os: T::Boolean,
// 174:         ).returns(T::Array[[T::Hash[Symbol, T.any(Symbol, String)], T.any(Symbol, String), T::Boolean]])
// 175:       }
// 176:       def runner_arch_pairs(runners:, multi_os:)
// 177:         macos_archs = runners.reject { |r| r.fetch(:symbol) == :linux }.map { |r| r.fetch(:arch) }.uniq
// 178:         linux_archs = runners.select { |r| r.fetch(:symbol) == :linux }.map { |r| r.fetch(:arch) }.uniq
// 179:         product_archs = macos_archs | linux_archs
// 180:         runners.product(product_archs).filter_map do |runner, arch|
// 181:           native_runner_arch = arch == runner.fetch(:arch)
// 182:           # we don't need to run simulated archs on Linux or macOS Sequoia
// 183:           # because they exist as real GitHub hosted runners
// 184:           next if runner.fetch(:symbol) == :linux && !native_runner_arch
// 185:           next if runner.fetch(:symbol) == :sequoia && !native_runner_arch
// 186:           # skip macOS runners simulating architectures not supported on macOS
// 187:           next if runner.fetch(:symbol) != :linux && !native_runner_arch && macos_archs.exclude?(arch)
// 188:           # if it's just a single OS test then we can just use the two real arch runners
// 189:           next if !native_runner_arch && !multi_os
// 190:
// 191:           [runner, arch, native_runner_arch]
// 192:         end
// 193:       end
// 194:
// 195:       sig { params(cask: Cask::Cask).returns([T::Array[T::Hash[Symbol, T.any(Symbol, String)]], T::Boolean]) }
// 196:       def runners(cask:)
// 197:         filtered_runners = filter_runners(cask)
// 198:
// 199:         filtered_macos_found = filtered_runners.keys.any? do |runner|
// 200:           cask.to_hash_with_variations["variations"].key?(runner.fetch(:symbol).to_sym)
// 201:         end
// 202:
// 203:         if filtered_macos_found
// 204:           # If the cask varies on a MacOS version, test it on every possible macOS version.
// 205:           [filtered_runners.keys, true]
// 206:         else
// 207:           macos_runners, linux_runners = filtered_runners.partition do |runner, _|
// 208:             runner.fetch(:symbol) != :linux
// 209:           end
// 210:           selected_runners = macos_runners.group_by { |runner, _| runner.fetch(:arch) }.map do |_, runners|
// 211:             random_runner(runners.to_h)
// 212:           end + linux_runners.map(&:first)
// 213:           [selected_runners, false]
// 214:         end
// 215:       end
// 216:
// 217:       private
// 218:
// 219:       sig { params(cask: Cask::Cask, os: Symbol).returns(T::Array[Symbol]) }
// 220:       def architectures(cask:, os:)
// 221:         architectures = T.let([], T::Array[Symbol])
// 222:         [:arm, :intel].each do |arch|
// 223:           tag = Utils::Bottles::Tag.new(system: os, arch:)
// 224:           cask.refresh_for_tag(tag) do
// 225:             if cask.depends_on.arch.blank?
// 226:               architectures = RUNNERS.keys.map { |r| r.fetch(:arch).to_sym }.uniq.sort
// 227:               next
// 228:             end
// 229:
// 230:             architectures = cask.depends_on.arch.map { |arch| arch[:type] }
// 231:           end
// 232:         end
// 233:
// 234:         architectures
// 235:       end
// 236:
// 237:       sig {
// 238:         params(available_runners: T::Hash[T::Hash[Symbol, T.any(Symbol, String)],
// 239:                                           Float]).returns(T::Hash[Symbol, T.any(Symbol, String)])
// 240:       }
// 241:       def random_runner(available_runners = ARM_MACOS_RUNNERS)
// 242:         max_runner = available_runners.max_by { |(_, weight)| rand ** (1.0 / weight) }
// 243:         raise "unexpected nil max_runner" unless max_runner
// 244:
// 245:         max_runner.first
// 246:       end
// 247:
// 248:       sig {
// 249:         params(tap: T.nilable(Tap), labels: T::Array[String], cask_names: T::Array[String], skip_install: T::Boolean,
// 250:                new_cask: T::Boolean).returns(T::Array[T::Hash[Symbol,
// 251:                                                               T.any(String, T::Boolean, T::Array[String])]])
// 252:       }
// 253:       def generate_matrix(tap, labels: [], cask_names: [], skip_install: false, new_cask: false)
// 254:         odie "This command must be run from inside a tap directory." unless tap
// 255:
// 256:         changed_files = find_changed_files(tap)
// 257:
// 258:         ruby_files_in_wrong_directory =
// 259:           changed_files[:modified_ruby_files] - (
// 260:             changed_files[:modified_cask_files] +
// 261:             changed_files[:modified_command_files] +
// 262:             changed_files[:modified_github_actions_files]
// 263:           )
// 264:
// 265:         if ruby_files_in_wrong_directory.any?
// 266:           ruby_files_in_wrong_directory.each do |path|
// 267:             puts "::error file=#{path}::File is in wrong directory."
// 268:           end
// 269:
// 270:           odie "Found Ruby files in wrong directory:\n#{ruby_files_in_wrong_directory.join("\n")}"
// 271:         end
// 272:
// 273:         cask_files_to_check = if cask_names.any?
// 274:           cask_names.map do |cask_name|
// 275:             Cask::CaskLoader.find_cask_in_tap(cask_name, tap).relative_path_from(tap.path)
// 276:           end
// 277:         else
// 278:           changed_files[:modified_cask_files]
// 279:         end
// 280:
// 281:         jobs = cask_files_to_check.count
// 282:         odie "Maximum job matrix size exceeded: #{jobs}/#{MAX_JOBS}" if jobs > MAX_JOBS
// 283:
// 284:         cask_files_to_check.flat_map do |path|
// 285:           cask_token = path.basename(".rb")
// 286:
// 287:           audit_args = ["--online"]
// 288:           audit_args << "--new" if changed_files.fetch(:added_files).include?(path) || new_cask
// 289:
// 290:           audit_exceptions = []
// 291:
// 292:           audit_exceptions << %w[homepage_https_availability] if labels.include?("ci-skip-homepage")
// 293:
// 294:           if labels.include?("ci-skip-livecheck")
// 295:             audit_exceptions << %w[hosting_with_livecheck livecheck_https_availability livecheck_version min_os]
// 296:           end
// 297:
// 298:           audit_exceptions << "min_os" if labels.include?("ci-skip-livecheck-min-os")
// 299:
// 300:           if labels.include?("ci-skip-repository")
// 301:             audit_exceptions << %w[github_repository github_prerelease_version
// 302:                                    gitlab_repository gitlab_prerelease_version
// 303:                                    forgejo_repository forgejo_prerelease_version
// 304:                                    bitbucket_repository]
// 305:           end
// 306:
// 307:           audit_exceptions << %w[token_valid token_bad_words] if labels.include?("ci-skip-token")
// 308:
// 309:           audit_args << "--except" << audit_exceptions.join(",") if audit_exceptions.any?
// 310:
// 311:           cask = Cask::CaskLoader.load(path.expand_path)
// 312:
// 313:           runners, multi_os = runners(cask:)
// 314:           runner_arch_pairs(runners:, multi_os:).map do |runner, arch, native_runner_arch|
// 315:             arch_args = native_runner_arch ? [] : ["--arch=#{arch}"]
// 316:             runner_output = {
// 317:               name:         "test #{cask_token} (#{runner.fetch(:name)}, #{arch})",
// 318:               tap:          tap.name,
// 319:               cask:         {
// 320:                 token: cask_token,
// 321:                 path:  "./#{path}",
// 322:               },
// 323:               audit_args:   audit_args + arch_args,
// 324:               fetch_args:   arch_args,
// 325:               skip_install: labels.include?("ci-skip-install") || !native_runner_arch || skip_install,
// 326:               runner:       runner.fetch(:name),
// 327:             }
// 328:
// 329:             if runner.fetch(:symbol) == :linux
// 330:               runner_output[:container] = {
// 331:                 image:   "ghcr.io/homebrew/brew:main",
// 332:                 options: "--user=linuxbrew",
// 333:               }
// 334:             end
// 335:
// 336:             runner_output
// 337:           end
// 338:         end
// 339:       end
// 340:
// 341:       sig {
// 342:         params(tap: Tap).returns({
// 343:           modified_files:                T::Array[Pathname],
// 344:           added_files:                   T::Array[Pathname],
// 345:           modified_ruby_files:           T::Array[Pathname],
// 346:           modified_command_files:        T::Array[Pathname],
// 347:           modified_github_actions_files: T::Array[Pathname],
// 348:           modified_cask_files:           T::Array[Pathname],
// 349:         })
// 350:       }
// 351:       def find_changed_files(tap)
// 352:         commit_range_start = Utils.safe_popen_read("git", "rev-parse", "origin").chomp
// 353:         commit_range_end = Utils.safe_popen_read("git", "rev-parse", "HEAD").chomp
// 354:         commit_range = "#{commit_range_start}...#{commit_range_end}"
// 355:
// 356:         modified_files = Utils.safe_popen_read("git", "diff", "--name-only", "--diff-filter=AMR", commit_range)
// 357:                               .split("\n")
// 358:                               .map do |path|
// 359:           Pathname(path)
// 360:         end
// 361:
// 362:         added_files = Utils.safe_popen_read("git", "diff", "--name-only", "--diff-filter=A", commit_range)
// 363:                            .split("\n")
// 364:                            .map do |path|
// 365:           Pathname(path)
// 366:         end
// 367:
// 368:         modified_ruby_files = modified_files.select { |path| path.extname == ".rb" }
// 369:         modified_command_files = modified_files.select { |path| path.ascend.to_a.last.to_s == "cmd" }
// 370:         modified_github_actions_files = modified_files.select do |path|
// 371:           path.to_s.start_with?(".github/actions/")
// 372:         end
// 373:         modified_cask_files = modified_files.select { |path| tap.cask_file?(path.to_s) }
// 374:
// 375:         {
// 376:           modified_files:,
// 377:           added_files:,
// 378:           modified_ruby_files:,
// 379:           modified_command_files:,
// 380:           modified_github_actions_files:,
// 381:           modified_cask_files:,
// 382:         }
// 383:       end
// 384:     end
// 385:   end
// 386: end
