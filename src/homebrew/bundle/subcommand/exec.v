module subcommand

import brew_runtime

// Translated from Homebrew/brew `bundle/subcommand/exec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 45.
pub fn ruby_exec_l45_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `self.run_command(*named_args, args:, context:)` at line 50.
pub fn ruby_exec_l50_d2_self_run_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.run_command', ...args)
}

// Ruby method `self.run_external_command(` at line 87.
pub fn ruby_exec_l87_d3_self_run_external_command(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.run_external_command', ...args)
}

// Ruby method `self.map_service_info(entries, &_block)` at line 320.
pub fn ruby_exec_l320_d4_self_map_service_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.map_service_info', ...args)
}

// Ruby method `self.run_services(entries, &_block)` at line 387.
pub fn ruby_exec_l387_d5_self_run_services(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.run_services', ...args)
}

// Ruby method `self.stop_services(entries)` at line 432.
pub fn ruby_exec_l432_d6_self_stop_services(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.stop_services', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_subcommand"
// 5:
// 6: require "English"
// 7: require "exceptions"
// 8: require "extend/ENV"
// 9: require "utils"
// 10: require "PATH"
// 11: require "utils/output"
// 12: module Homebrew
// 13:   module Cmd
// 14:     class Bundle < Homebrew::AbstractCommand
// 15:       class ExecSubcommand < Homebrew::AbstractSubcommand
// 16:         subcommand_args do
// 17:           usage_banner <<~EOS
// 18:             `brew bundle exec` [`--check`] [`--no-secrets`] [`--sandbox=`<path>] [`--deny-network`] <command>:
// 19:             Run an external command in an isolated build environment based on the `Brewfile` dependencies.
// 20:
// 21:             This sanitised build environment ignores unrequested dependencies, which makes sure that things you didn't specify in your `Brewfile` won't get picked up by commands like `bundle install`, `npm install`, etc. It will also add compiler flags which will help with finding keg-only dependencies like `openssl`, `icu4c`, etc.
// 22:           EOS
// 23:           named_args :command
// 24:           switch "--install",
// 25:                  description: "Run `install` before executing the command."
// 26:           switch "--services",
// 27:                  description: "Temporarily start services while executing the command.",
// 28:                  env:         :bundle_services
// 29:           switch "--check",
// 30:                  description: "Check that all dependencies in the Brewfile are installed before " \
// 31:                               "executing the command.",
// 32:                  env:         :bundle_check
// 33:           switch "--no-secrets",
// 34:                  description: "Attempt to remove secrets from the environment before executing the command.",
// 35:                  env:         :bundle_no_secrets
// 36:           flag "--sandbox=",
// 37:                description: "Run <command> in Homebrew's sandbox, allowing writes to <path> and Homebrew's " \
// 38:                             "temporary and cache directories."
// 39:           switch "--deny-network",
// 40:                  description: "Deny network access from inside the sandbox.",
// 41:                  depends_on:  "--sandbox="
// 42:         end
// 43:
// 44:         sig { override.void }
// 45:         def run
// 46:           self.class.run_command(*args.named, args:, context:)
// 47:         end
// 48:
// 49:         sig { params(named_args: String, args: T.untyped, context: Homebrew::Cmd::Bundle::SubcommandContext).void }
// 50:         def self.run_command(*named_args, args:, context:)
// 51:           sandbox_path = args.sandbox
// 52:           sandbox_options = {}
// 53:           if sandbox_path
// 54:             sandbox_options[:sandbox_path] = sandbox_path
// 55:             sandbox_options[:deny_network] = args.deny_network?
// 56:           end
// 57:
// 58:           run_external_command(
// 59:             *named_args,
// 60:             global:     context.global,
// 61:             file:       context.file,
// 62:             subcommand: context.subcommand,
// 63:             services:   args.services?,
// 64:             check:      args.check?,
// 65:             no_secrets: args.no_secrets?,
// 66:             **sandbox_options,
// 67:           )
// 68:         end
// 69:
// 70:         extend Utils::Output::Mixin
// 71:
// 72:         PATH_LIKE_ENV_REGEX = /.+#{File::PATH_SEPARATOR}/
// 73:
// 74:         sig {
// 75:           params(
// 76:             args:         String,
// 77:             global:       T::Boolean,
// 78:             file:         T.nilable(String),
// 79:             subcommand:   String,
// 80:             services:     T::Boolean,
// 81:             check:        T::Boolean,
// 82:             no_secrets:   T::Boolean,
// 83:             sandbox_path: T.nilable(String),
// 84:             deny_network: T::Boolean,
// 85:           ).void
// 86:         }
// 87:         def self.run_external_command(
// 88:           *args,
// 89:           global: false,
// 90:           file: nil,
// 91:           subcommand: "",
// 92:           services: false,
// 93:           check: false,
// 94:           no_secrets: false,
// 95:           sandbox_path: nil,
// 96:           deny_network: false
// 97:         )
// 98:           if check
// 99:             require "bundle/subcommand/check"
// 100:             CheckSubcommand.new(args, context: SubcommandContext.new(
// 101:               subcommand:   "check",
// 102:               global:,
// 103:               file:,
// 104:               no_upgrade:   false,
// 105:               verbose:      false,
// 106:               force:        false,
// 107:               ask:          false,
// 108:               jobs:         1,
// 109:               zap:          false,
// 110:               no_type_args: true,
// 111:               extensions:   Homebrew::Bundle.extensions,
// 112:             ), quiet: true).run
// 113:           end
// 114:
// 115:           # Store the old environment so we can check if things were already set
// 116:           # before we start mutating it.
// 117:           old_env = ENV.to_h
// 118:           ENV.clear_sensitive_environment! if no_secrets
// 119:
// 120:           # Setup Homebrew's ENV extensions
// 121:           ENV.activate_extensions!
// 122:
// 123:           command = args.first
// 124:           raise UsageError, "No command to execute was specified!" if command.blank?
// 125:           raise UsageError, "`--sandbox` requires a writable path." if sandbox_path == ""
// 126:           raise UsageError, "`--deny-network` requires `--sandbox`." if deny_network && sandbox_path.blank?
// 127:
// 128:           require "bundle/brewfile"
// 129:           @dsl ||= T.let(nil, T.nilable(Homebrew::Bundle::Dsl))
// 130:           @dsl = Homebrew::Bundle::Brewfile.read(global:, file:)
// 131:
// 132:           require "formula"
// 133:           require "formulary"
// 134:
// 135:           ENV.deps = @dsl.entries.filter_map do |entry|
// 136:             next if entry.type != :brew
// 137:
// 138:             Formulary.factory(entry.name)
// 139:           end
// 140:
// 141:           # Allow setting all dependencies to be keg-only
// 142:           # (i.e. should be explicitly in HOMEBREW_*PATHs ahead of HOMEBREW_PREFIX)
// 143:           ENV.keg_only_deps = if ENV["HOMEBREW_BUNDLE_EXEC_ALL_KEG_ONLY_DEPS"].present?
// 144:             ENV.delete("HOMEBREW_BUNDLE_EXEC_ALL_KEG_ONLY_DEPS")
// 145:             ENV.deps
// 146:           else
// 147:             ENV.deps.select(&:keg_only?)
// 148:           end
// 149:           ENV.setup_build_environment
// 150:
// 151:           # Enable compiler flag filtering
// 152:           ENV.refurbish_args
// 153:
// 154:           # Add variable to detect being inside a `brew bundle exec` environment
// 155:           ENV["HOMEBREW_INSIDE_BUNDLE"] = "1"
// 156:
// 157:           # Set up `nodenv`, `pyenv` and `rbenv` if present.
// 158:           env_formulae = %w[nodenv pyenv rbenv]
// 159:           ENV.deps.each do |dep|
// 160:             dep_name = dep.name
// 161:             next unless env_formulae.include?(dep_name)
// 162:
// 163:             dep_root = ENV.fetch("HOMEBREW_#{dep_name.upcase}_ROOT", "#{Dir.home}/.#{dep_name}")
// 164:             ENV.prepend_path "PATH", Pathname.new(dep_root)/"shims"
// 165:           end
// 166:
// 167:           # Setup pkgconf, if needed, to help locate packages
// 168:           Homebrew::Bundle.prepend_pkgconf_path_if_needed!
// 169:
// 170:           # For commands which aren't either absolute or relative
// 171:           # Add the command directory to PATH, since it may get blown away by superenv
// 172:           if command.exclude?("/") && (which_command = which(command))
// 173:             ENV.prepend_path "PATH", which_command.dirname.to_s
// 174:           end
// 175:
// 176:           # Replace the formula versions from the environment variables
// 177:           ENV.deps.each do |formula|
// 178:             formula_name = formula.name
// 179:             formula_version = Homebrew::Bundle.formula_versions_from_env(formula_name)
// 180:             next unless formula_version
// 181:
// 182:             ENV.each do |key, value|
// 183:               opt = %r{/opt/#{formula_name}([/:$])}
// 184:               next unless value.match(opt)
// 185:
// 186:               cellar = "/Cellar/#{formula_name}/#{formula_version}\\1"
// 187:
// 188:               # Look for PATH-like environment variables
// 189:               ENV[key] = if key.include?("PATH") && value.match?(PATH_LIKE_ENV_REGEX)
// 190:                 rejected_opts = []
// 191:                 path = PATH.new(ENV.fetch("PATH"))
// 192:                            .reject do |path_value|
// 193:                   rejected_opts << path_value if path_value.match?(opt)
// 194:                 end
// 195:                 rejected_opts.each do |path_value|
// 196:                   path.prepend(path_value.gsub(opt, cellar))
// 197:                 end
// 198:                 path.to_s
// 199:               else
// 200:                 value.gsub(opt, cellar)
// 201:               end
// 202:             end
// 203:           end
// 204:
// 205:           # Ensure brew bundle exec/sh/env commands have access to other tools in the PATH
// 206:           if (homebrew_path = ENV.fetch("HOMEBREW_PATH", nil))
// 207:             ENV.append_path "PATH", homebrew_path
// 208:           end
// 209:
// 210:           # For commands which aren't either absolute or relative
// 211:           raise "command was not found in your PATH: #{command}" if command.exclude?("/") && which(command).nil?
// 212:
// 213:           %w[HOMEBREW_TEMP TMPDIR HOMEBREW_TMPDIR].each do |var|
// 214:             value = ENV.fetch(var, nil)
// 215:             next if value.blank?
// 216:             next if File.writable?(value)
// 217:
// 218:             ENV.delete(var)
// 219:           end
// 220:
// 221:           ENV.each do |key, value|
// 222:             # Look for PATH-like environment variables
// 223:             next if key.exclude?("PATH") || !value.match?(PATH_LIKE_ENV_REGEX)
// 224:
// 225:             # Exclude Homebrew shims from the PATH as they don't work
// 226:             # without all Homebrew environment variables and can interfere with
// 227:             # non-Homebrew builds.
// 228:             ENV[key] = PATH.new(value)
// 229:                            .reject do |path_value|
// 230:               path_value.include?("/Homebrew/shims/")
// 231:             end.to_s
// 232:           end
// 233:
// 234:           if subcommand == "env"
// 235:             ENV.sort.each do |key, value|
// 236:               # Skip exporting Homebrew internal variables that won't be used by other tools.
// 237:               # Those Homebrew needs have already been set to global constants and/or are exported again later.
// 238:               # Setting these globally can interfere with nested Homebrew invocations/environments.
// 239:               if key.start_with?("HOMEBREW_", "PORTABLE_RUBY_")
// 240:                 ENV.delete(key)
// 241:                 next
// 242:               end
// 243:
// 244:               # No need to export empty values.
// 245:               next if value.blank?
// 246:
// 247:               # Skip exporting things that were the same in the old environment.
// 248:               old_value = old_env[key]
// 249:               next if old_value == value
// 250:
// 251:               # Look for PATH-like environment variables
// 252:               if key.include?("PATH") && value.match?(PATH_LIKE_ENV_REGEX)
// 253:                 old_values = old_value.to_s.split(File::PATH_SEPARATOR)
// 254:                 path = PATH.new(value)
// 255:                            .reject do |path_value|
// 256:                   # Exclude existing/old values as they've already been exported.
// 257:                   old_values.include?(path_value)
// 258:                 end
// 259:                 next if path.blank?
// 260:
// 261:                 puts "export #{key}=\"#{Utils::Shell.sh_quote(path.to_s)}:${#{key}:-}\""
// 262:               else
// 263:                 puts "export #{key}=\"#{Utils::Shell.sh_quote(value)}\""
// 264:               end
// 265:             end
// 266:             return
// 267:           elsif subcommand == "sh"
// 268:             preferred_path = Utils::Shell.preferred_path(default: "/bin/bash")
// 269:             notice = unless Homebrew::EnvConfig.no_env_hints?
// 270:               <<~EOS
// 271:                 Your shell has been configured to use a build environment from your `Brewfile`.
// 272:                 This should help you build stuff.
// 273:                 Hide these hints with `HOMEBREW_NO_ENV_HINTS=1` (see `man brew`).
// 274:                 When done, type `exit`.
// 275:               EOS
// 276:             end
// 277:             ENV["HOMEBREW_FORCE_API_AUTO_UPDATE"] = nil
// 278:             args = [Utils::Shell.shell_with_prompt("brew bundle", preferred_path:, notice:)]
// 279:           end
// 280:
// 281:           require "sandbox" if sandbox_path
// 282:
// 283:           if services
// 284:             require "bundle/brew_services"
// 285:
// 286:             exit_code = T.let(0, Integer)
// 287:             run_services(@dsl.entries) do
// 288:               if sandbox_path
// 289:                 begin
// 290:                   Sandbox.run_command(*args, writable_path: sandbox_path, deny_network:)
// 291:                 rescue ErrorDuringExecution => e
// 292:                   exit_code = e.exitstatus || 1
// 293:                 end
// 294:               else
// 295:                 Kernel.system(*args)
// 296:                 if (system_exit_code = $CHILD_STATUS&.exitstatus)
// 297:                   exit_code = system_exit_code
// 298:                 end
// 299:               end
// 300:             end
// 301:             exit!(exit_code)
// 302:           elsif sandbox_path
// 303:             Sandbox.run_command(*args, writable_path: sandbox_path, deny_network:)
// 304:           else
// 305:             exec(*args)
// 306:           end
// 307:         end
// 308:
// 309:         sig {
// 310:           params(
// 311:             entries: T::Array[Homebrew::Bundle::Dsl::Entry],
// 312:             _block:  T.proc.params(
// 313:               entry:                Homebrew::Bundle::Dsl::Entry,
// 314:               info:                 T::Hash[String, T.untyped],
// 315:               service_file:         Pathname,
// 316:               conflicting_services: T::Array[T::Hash[String, T.untyped]],
// 317:             ).void,
// 318:           ).void
// 319:         }
// 320:         private_class_method def self.map_service_info(entries, &_block)
// 321:           entries_formulae = entries.filter_map do |entry|
// 322:             next if entry.type != :brew
// 323:
// 324:             formula = Formula[entry.name]
// 325:             next unless formula.any_version_installed?
// 326:
// 327:             [entry, formula]
// 328:           end.to_h
// 329:
// 330:           return if entries_formulae.empty?
// 331:
// 332:           conflicts = entries_formulae.to_h do |entry, formula|
// 333:             [
// 334:               entry,
// 335:               (
// 336:                 formula.versioned_formulae_names +
// 337:                   formula.conflicts.map(&:name) +
// 338:                   Array(entry.options[:conflicts_with])
// 339:               ).uniq,
// 340:             ]
// 341:           end
// 342:
// 343:           # The formula + everything that could possible conflict with the service
// 344:           names_to_query = entries_formulae.flat_map do |entry, formula|
// 345:             [
// 346:               formula.name,
// 347:               *conflicts.fetch(entry),
// 348:             ]
// 349:           end
// 350:
// 351:           # We parse from a command invocation so that brew wrappers can invoke special actions
// 352:           # for the elevated nature of `brew services`
// 353:           services_info = JSON.parse(
// 354:             Utils.safe_popen_read(HOMEBREW_BREW_FILE, "services", "info", "--json", *names_to_query),
// 355:           )
// 356:
// 357:           entries_formulae.filter_map do |entry, formula|
// 358:             service_file = Homebrew::Bundle::Brew::Services.versioned_service_file(entry.name)
// 359:
// 360:             unless service_file&.file?
// 361:               prefix = formula.any_installed_prefix
// 362:               next if prefix.nil?
// 363:
// 364:               service_file = if Homebrew::Services::System.launchctl?
// 365:                 prefix/"#{formula.plist_name}.plist"
// 366:               else
// 367:                 prefix/"#{formula.service_name}.service"
// 368:               end
// 369:             end
// 370:
// 371:             next unless service_file.file?
// 372:
// 373:             info = services_info.find { |candidate| candidate["name"] == formula.name }
// 374:             conflicting_services = services_info.select do |candidate|
// 375:               next unless candidate["running"]
// 376:
// 377:               conflicts.fetch(entry).include?(candidate["name"])
// 378:             end
// 379:
// 380:             raise "Failed to get service info for #{entry.name}" if info.nil?
// 381:
// 382:             yield entry, info, service_file, conflicting_services
// 383:           end
// 384:         end
// 385:
// 386:         sig { params(entries: T::Array[Homebrew::Bundle::Dsl::Entry], _block: T.nilable(T.proc.void)).void }
// 387:         private_class_method def self.run_services(entries, &_block)
// 388:           entries_to_stop = []
// 389:           services_to_restart = []
// 390:
// 391:           map_service_info(entries) do |entry, info, service_file, conflicting_services|
// 392:             # Don't restart if already running this version
// 393:             loaded_file = Pathname.new(info["loaded_file"].to_s)
// 394:             next if info["running"] && loaded_file.file? && loaded_file.realpath == service_file.realpath
// 395:
// 396:             if info["running"] && !Homebrew::Bundle::Brew::Services.stop(info["name"], keep: true)
// 397:               opoo "Failed to stop #{info["name"]} service"
// 398:             end
// 399:
// 400:             conflicting_services.each do |conflict|
// 401:               if Homebrew::Bundle::Brew::Services.stop(conflict["name"], keep: true)
// 402:                 services_to_restart << conflict["name"] if conflict["registered"]
// 403:               else
// 404:                 opoo "Failed to stop #{conflict["name"]} service"
// 405:               end
// 406:             end
// 407:
// 408:             unless Homebrew::Bundle::Brew::Services.run(info["name"], file: service_file)
// 409:               opoo "Failed to start #{info["name"]} service"
// 410:             end
// 411:
// 412:             entries_to_stop << entry
// 413:           end
// 414:
// 415:           return unless block_given?
// 416:
// 417:           begin
// 418:             yield
// 419:           ensure
// 420:             # Do a full re-evaluation of services instead state has changed
// 421:             stop_services(entries_to_stop)
// 422:
// 423:             services_to_restart.each do |service|
// 424:               next if Homebrew::Bundle::Brew::Services.run(service)
// 425:
// 426:               opoo "Failed to restart #{service} service"
// 427:             end
// 428:           end
// 429:         end
// 430:
// 431:         sig { params(entries: T::Array[Homebrew::Bundle::Dsl::Entry]).void }
// 432:         private_class_method def self.stop_services(entries)
// 433:           map_service_info(entries) do |_, info, _, _|
// 434:             next unless info["loaded"]
// 435:
// 436:             # Try avoid services not started by `brew bundle services`
// 437:             next if Homebrew::Services::System.launchctl? && info["registered"]
// 438:
// 439:             if info["running"] && !Homebrew::Bundle::Brew::Services.stop(info["name"], keep: true)
// 440:               opoo "Failed to stop #{info["name"]} service"
// 441:             end
// 442:           end
// 443:         end
// 444:       end
// 445:     end
// 446:   end
// 447: end
