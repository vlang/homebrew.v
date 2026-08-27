module services

import brew_runtime

// Translated from Homebrew/brew `services/cli.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.sudo_service_user` at line 15.
pub fn ruby_cli_l15_d1_self_sudo_service_user(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.sudo_service_user', ...args)
}

// Ruby method `self.sudo_service_user=(sudo_service_user)` at line 20.
pub fn ruby_cli_l20_d2_self_sudo_service_user(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.sudo_service_user=', ...args)
}

// Ruby method `self.bin` at line 26.
pub fn ruby_cli_l26_d3_self_bin(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.bin', ...args)
}

// Ruby method `self.running` at line 32.
pub fn ruby_cli_l32_d4_self_running(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.running', ...args)
}

// Ruby method `self.check!(targets)` at line 48.
pub fn ruby_cli_l48_d5_self_check(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.check!', ...args)
}

// Ruby method `self.kill_orphaned_services` at line 56.
pub fn ruby_cli_l56_d6_self_kill_orphaned_services(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.kill_orphaned_services', ...args)
}

// Ruby method `self.remove_unused_service_files` at line 74.
pub fn ruby_cli_l74_d7_self_remove_unused_service_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.remove_unused_service_files', ...args)
}

// Ruby method `self.run(targets, service_file = nil, verbose: false)` at line 95.
pub fn ruby_cli_l95_d8_self_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.run', ...args)
}

// Ruby method `self.start(targets, service_file = nil, verbose: false)` at line 122.
pub fn ruby_cli_l122_d9_self_start(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.start', ...args)
}

// Ruby method `self.stop(targets, verbose: false, no_wait: false, max_wait: 0, keep: false)` at line 174.
pub fn ruby_cli_l174_d10_self_stop(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.stop', ...args)
}

// Ruby method `self.kill(targets, verbose: false)` at line 258.
pub fn ruby_cli_l258_d11_self_kill(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.kill', ...args)
}

// Ruby method `self.take_root_ownership?(service)` at line 288.
pub fn ruby_cli_l288_d12_self_take_root_ownership(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.take_root_ownership?', ...args)
}

// Ruby method `self.launchctl_load(service, file:, enable:)` at line 361.
pub fn ruby_cli_l361_d13_self_launchctl_load(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.launchctl_load', ...args)
}

// Ruby method `self.systemd_load(service, enable:)` at line 367.
pub fn ruby_cli_l367_d14_self_systemd_load(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.systemd_load', ...args)
}

// Ruby method `self.service_load(service, file, enable:)` at line 378.
pub fn ruby_cli_l378_d15_self_service_load(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.service_load', ...args)
}

// Ruby method `self.install_service_file(service, file)` at line 407.
pub fn ruby_cli_l407_d16_self_install_service_file(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.install_service_file', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "services/formula_wrapper"
// 5: require "fileutils"
// 6: require "utils/output"
// 7:
// 8: module Homebrew
// 9:   module Services
// 10:     module Cli
// 11:       extend FileUtils
// 12:       extend Utils::Output::Mixin
// 13:
// 14:       sig { returns(T.nilable(String)) }
// 15:       def self.sudo_service_user
// 16:         @sudo_service_user
// 17:       end
// 18:
// 19:       sig { params(sudo_service_user: String).void }
// 20:       def self.sudo_service_user=(sudo_service_user)
// 21:         @sudo_service_user = T.let(sudo_service_user, T.nilable(String))
// 22:       end
// 23:
// 24:       # Binary name.
// 25:       sig { returns(String) }
// 26:       def self.bin
// 27:         "brew services"
// 28:       end
// 29:
// 30:       # Find all currently running services via launchctl list or systemctl list-units.
// 31:       sig { returns(T::Array[String]) }
// 32:       def self.running
// 33:         if System.launchctl?
// 34:           Utils.popen_read(System.launchctl, "list")
// 35:         else
// 36:           System::Systemctl.popen_read("list-units",
// 37:                                        "--type=service",
// 38:                                        "--state=running",
// 39:                                        "--no-pager",
// 40:                                        "--no-legend")
// 41:         end.chomp.split("\n").filter_map do |svc|
// 42:           svc[/homebrew(?>\.mxcl)?\.([\w+-.@]+)/]&.delete_suffix(".service")
// 43:         end
// 44:       end
// 45:
// 46:       # Check if formula has been found.
// 47:       sig { params(targets: T::Array[Services::FormulaWrapper]).returns(T::Boolean) }
// 48:       def self.check!(targets)
// 49:         raise UsageError, "Formula(e) missing, please provide a formula name or use `--all`." if targets.empty?
// 50:
// 51:         true
// 52:       end
// 53:
// 54:       # Kill services that don't have a service file
// 55:       sig { returns(T::Array[String]) }
// 56:       def self.kill_orphaned_services
// 57:         cleaned_labels = []
// 58:         cleaned_services = []
// 59:         running.each do |label|
// 60:           if (service = FormulaWrapper.from(label))
// 61:             unless service.dest.file?
// 62:               cleaned_labels << label
// 63:               cleaned_services << service
// 64:             end
// 65:           else
// 66:             opoo "Service #{label} not managed by `#{bin}` => skipping"
// 67:           end
// 68:         end
// 69:         kill(cleaned_services)
// 70:         cleaned_labels
// 71:       end
// 72:
// 73:       sig { returns(T::Array[String]) }
// 74:       def self.remove_unused_service_files
// 75:         cleaned = []
// 76:         System.path.glob("homebrew.*.{plist,service,timer}").each do |file|
// 77:           next if running.include?(File.basename(file).sub(/\.(plist|service|timer)$/i, ""))
// 78:
// 79:           puts "Removing unused service file: #{file}"
// 80:           rm file
// 81:           cleaned << file.to_s
// 82:         end
// 83:
// 84:         cleaned
// 85:       end
// 86:
// 87:       # Run a service as defined in the formula. This does not clean the service file like `start` does.
// 88:       sig {
// 89:         params(
// 90:           targets:      T::Array[Services::FormulaWrapper],
// 91:           service_file: T.nilable(String),
// 92:           verbose:      T::Boolean,
// 93:         ).void
// 94:       }
// 95:       def self.run(targets, service_file = nil, verbose: false)
// 96:         if service_file.present?
// 97:           file = Pathname.new service_file
// 98:           raise UsageError, "Provided service file does not exist." unless file.exist?
// 99:         end
// 100:
// 101:         targets.each do |service|
// 102:           if service.pid?
// 103:             puts "Service `#{service.name}` already running, use `#{bin} restart #{service.name}` to restart."
// 104:             next
// 105:           elsif System.root?
// 106:             puts "Service `#{service.name}` cannot be run (but can be started) as root."
// 107:             next
// 108:           end
// 109:
// 110:           service_load(service, file, enable: false)
// 111:         end
// 112:       end
// 113:
// 114:       # Start a service.
// 115:       sig {
// 116:         params(
// 117:           targets:      T::Array[Services::FormulaWrapper],
// 118:           service_file: T.nilable(String),
// 119:           verbose:      T::Boolean,
// 120:         ).void
// 121:       }
// 122:       def self.start(targets, service_file = nil, verbose: false)
// 123:         file = T.let(nil, T.nilable(Pathname))
// 124:
// 125:         if service_file.present?
// 126:           file = Pathname.new service_file
// 127:           raise UsageError, "Provided service file does not exist." unless file.exist?
// 128:         end
// 129:
// 130:         targets.each do |service|
// 131:           if service.pid?
// 132:             puts "Service `#{service.name}` already started, use `#{bin} restart #{service.name}` to restart."
// 133:             next
// 134:           end
// 135:
// 136:           odie "Formula `#{service.name}` is not installed." unless service.installed?
// 137:
// 138:           file ||= if service.service_file.exist? || System.systemctl?
// 139:             nil
// 140:           elsif service.formula.opt_prefix.exist? &&
// 141:                 (keg = Keg.for service.formula.opt_prefix) &&
// 142:                 keg.plist_installed?
// 143:             service_file = Dir["#{keg}/*#{service.service_file.extname}"].first
// 144:             Pathname.new service_file if service_file.present?
// 145:           end
// 146:
// 147:           install_service_file(service, file)
// 148:
// 149:           if !file && verbose
// 150:             ohai "Generated service file for #{service.formula.name}:"
// 151:             puts "   #{service.dest.read.gsub("\n", "\n   ")}"
// 152:             puts
// 153:           end
// 154:
// 155:           # Never skip loading when ownership was taken, otherwise
// 156:           # only skip a `--sudo-service-user` service when not root.
// 157:           root_ownership_taken = take_root_ownership?(service)
// 158:           next if !root_ownership_taken && sudo_service_user && !System.root?
// 159:
// 160:           service_load(service, nil, enable: true)
// 161:         end
// 162:       end
// 163:
// 164:       # Stop a service and unload it.
// 165:       sig {
// 166:         params(
// 167:           targets:  T::Array[Services::FormulaWrapper],
// 168:           verbose:  T::Boolean,
// 169:           no_wait:  T::Boolean,
// 170:           max_wait: T.nilable(T.any(Integer, Float)),
// 171:           keep:     T::Boolean,
// 172:         ).void
// 173:       }
// 174:       def self.stop(targets, verbose: false, no_wait: false, max_wait: 0, keep: false)
// 175:         targets.each do |service|
// 176:           unless service.loaded?
// 177:             unless keep
// 178:               rm service.dest if service.dest.exist? # get rid of installed service file anyway, dude
// 179:               rm service.timer_dest if System.systemctl? && service.timed? && service.timer_dest.exist?
// 180:             end
// 181:             if service.service_file_present?
// 182:               odie <<~EOS
// 183:                 Service `#{service.name}` is started as `#{service.owner}`. Try:
// 184:                   #{"sudo " unless System.root?}#{bin} stop #{service.name}
// 185:               EOS
// 186:             elsif System.launchctl? &&
// 187:                   quiet_system(System.launchctl, "bootout", "#{System.domain_target}/#{service.service_name}")
// 188:               ohai "Successfully stopped `#{service.name}` (label: #{service.service_name})"
// 189:             else
// 190:               opoo "Service `#{service.name}` is not started."
// 191:             end
// 192:             next
// 193:           end
// 194:
// 195:           systemctl_args = []
// 196:           if no_wait
// 197:             systemctl_args << "--no-block"
// 198:             puts "Stopping `#{service.name}`..."
// 199:           else
// 200:             puts "Stopping `#{service.name}`... (might take a while)"
// 201:           end
// 202:
// 203:           if System.systemctl?
// 204:             if keep
// 205:               System::Systemctl.quiet_run(*systemctl_args, "stop", service.timer_name) if service.timed?
// 206:               System::Systemctl.quiet_run(*systemctl_args, "stop", service.service_name)
// 207:             elsif service.timed?
// 208:               System::Systemctl.quiet_run(*systemctl_args, "disable", "--now", service.timer_name)
// 209:               System::Systemctl.quiet_run(*systemctl_args, "disable", "--now", service.service_name)
// 210:             else
// 211:               System::Systemctl.quiet_run(*systemctl_args, "disable", "--now", service.service_name)
// 212:             end
// 213:           elsif System.launchctl?
// 214:             dont_wait_statuses = [
// 215:               Errno::ESRCH::Errno,
// 216:               System::LAUNCHCTL_DOMAIN_ACTION_NOT_SUPPORTED,
// 217:             ]
// 218:             System.candidate_domain_targets.each do |domain_target|
// 219:               break unless service.loaded?
// 220:
// 221:               quiet_system System.launchctl, "bootout", "#{domain_target}/#{service.service_name}"
// 222:               unless no_wait
// 223:                 time_slept = 0
// 224:                 sleep_time = 1
// 225:                 max_wait = T.must(max_wait)
// 226:                 exit_status = $CHILD_STATUS.exitstatus
// 227:                 while dont_wait_statuses.exclude?(exit_status) &&
// 228:                       (exit_status == Errno::EINPROGRESS::Errno || service.loaded?) &&
// 229:                       (max_wait.zero? || time_slept < max_wait)
// 230:                   sleep(sleep_time)
// 231:                   time_slept += sleep_time
// 232:                   quiet_system System.launchctl, "bootout", "#{domain_target}/#{service.service_name}"
// 233:                   exit_status = $CHILD_STATUS.exitstatus
// 234:                 end
// 235:               end
// 236:               service.reset_cache!
// 237:               quiet_system System.launchctl, "stop", "#{domain_target}/#{service.service_name}" if service.pid?
// 238:             end
// 239:           end
// 240:
// 241:           unless keep
// 242:             rm service.dest if service.dest.exist?
// 243:             rm service.timer_dest if System.systemctl? && service.timed? && service.timer_dest.exist?
// 244:             # Run daemon-reload on systemctl to finish unloading stopped and deleted service.
// 245:             System::Systemctl.run(*systemctl_args, "daemon-reload") if System.systemctl?
// 246:           end
// 247:
// 248:           if service.loaded? || service.pid?
// 249:             opoo "Unable to stop `#{service.name}` (label: #{service.service_name})"
// 250:           else
// 251:             ohai "Successfully stopped `#{service.name}` (label: #{service.service_name})"
// 252:           end
// 253:         end
// 254:       end
// 255:
// 256:       # Stop a service but keep it registered.
// 257:       sig { params(targets: T::Array[Services::FormulaWrapper], verbose: T::Boolean).void }
// 258:       def self.kill(targets, verbose: false)
// 259:         targets.each do |service|
// 260:           if !service.pid?
// 261:             puts "Service `#{service.name}` is not started."
// 262:           elsif service.keep_alive?
// 263:             puts "Service `#{service.name}` is set to automatically restart and can't be killed."
// 264:           else
// 265:             puts "Killing `#{service.name}`... (might take a while)"
// 266:             if System.systemctl?
// 267:               System::Systemctl.quiet_run("stop", service.service_name)
// 268:             elsif System.launchctl?
// 269:               System.candidate_domain_targets.each do |domain_target|
// 270:                 break unless service.pid?
// 271:
// 272:                 quiet_system System.launchctl, "stop", "#{domain_target}/#{service.service_name}"
// 273:                 service.reset_cache!
// 274:               end
// 275:             end
// 276:
// 277:             if service.pid?
// 278:               opoo "Unable to kill `#{service.name}` (label: #{service.service_name})"
// 279:             else
// 280:               ohai "Successfully killed `#{service.name}` (label: #{service.service_name})"
// 281:             end
// 282:           end
// 283:         end
// 284:       end
// 285:
// 286:       # protections to avoid users editing root services
// 287:       sig { params(service: Services::FormulaWrapper).returns(T::Boolean) }
// 288:       def self.take_root_ownership?(service)
// 289:         return false unless System.root?
// 290:         return false if sudo_service_user
// 291:
// 292:         root_paths = T.let([], T::Array[Pathname])
// 293:
// 294:         if System.systemctl?
// 295:           group = "root"
// 296:         elsif System.launchctl?
// 297:           group = "admin"
// 298:           chown "root", group, service.dest
// 299:           require "plist"
// 300:           plist_data = service.dest.read
// 301:           plist = begin
// 302:             Plist.parse_xml(plist_data, marshal: false)
// 303:           rescue
// 304:             nil
// 305:           end
// 306:           return false unless plist
// 307:
// 308:           program_location = plist["ProgramArguments"]&.first
// 309:           key = "first ProgramArguments value"
// 310:           if program_location.blank?
// 311:             program_location = plist["Program"]
// 312:             key = "Program"
// 313:           end
// 314:
// 315:           if program_location.present?
// 316:             Dir.chdir("/") do
// 317:               if File.exist?(program_location)
// 318:                 program_location_path = Pathname(program_location).realpath
// 319:                 root_paths += [
// 320:                   program_location_path,
// 321:                   program_location_path.parent.realpath,
// 322:                 ]
// 323:               else
// 324:                 opoo <<~EOS
// 325:                   #{service.name}: the #{key} does not exist:
// 326:                     #{program_location}
// 327:                 EOS
// 328:               end
// 329:             end
// 330:           end
// 331:         end
// 332:
// 333:         if (formula = service.formula)
// 334:           root_paths += [
// 335:             formula.opt_prefix,
// 336:             formula.linked_keg,
// 337:             formula.bin,
// 338:             formula.sbin,
// 339:           ]
// 340:         end
// 341:         root_paths = root_paths.sort.uniq.select(&:exist?)
// 342:
// 343:         opoo <<~EOS
// 344:           Taking root:#{group} ownership of some #{service.formula} paths:
// 345:             #{root_paths.join("\n  ")}
// 346:           This will require manual removal of these paths using `sudo rm` on
// 347:           brew upgrade/reinstall/uninstall.
// 348:         EOS
// 349:         chown "root", group, root_paths
// 350:         chmod "+t", root_paths
// 351:         true
// 352:       end
// 353:
// 354:       sig {
// 355:         params(
// 356:           service: Services::FormulaWrapper,
// 357:           file:    T.nilable(T.any(String, Pathname)),
// 358:           enable:  T::Boolean,
// 359:         ).void
// 360:       }
// 361:       def self.launchctl_load(service, file:, enable:)
// 362:         safe_system System.launchctl, "enable", "#{System.domain_target}/#{service.service_name}" if enable
// 363:         safe_system System.launchctl, "bootstrap", System.domain_target, file
// 364:       end
// 365:
// 366:       sig { params(service: Services::FormulaWrapper, enable: T::Boolean).void }
// 367:       def self.systemd_load(service, enable:)
// 368:         System::Systemctl.run("start", service.service_name)
// 369:         if service.timed?
// 370:           System::Systemctl.run("start", service.timer_name)
// 371:           System::Systemctl.run("enable", service.timer_name) if enable
// 372:         elsif enable
// 373:           System::Systemctl.run("enable", service.service_name)
// 374:         end
// 375:       end
// 376:
// 377:       sig { params(service: Services::FormulaWrapper, file: T.nilable(Pathname), enable: T::Boolean).void }
// 378:       def self.service_load(service, file, enable:)
// 379:         if System.root? && !service.service_startup? && !sudo_service_user
// 380:           opoo "`#{service.name}` must be run as non-root to start at user login!"
// 381:         elsif !System.root? && service.service_startup?
// 382:           opoo "`#{service.name}` must be run as root to start at system startup!"
// 383:         end
// 384:
// 385:         if (service_user = sudo_service_user) && !System.user_exists?(service_user)
// 386:           function = enable ? "start" : "run"
// 387:           odie "Cannot #{function} `#{service.name}` as `#{service_user}` is not a user!"
// 388:         end
// 389:
// 390:         if System.launchctl?
// 391:           file ||= enable ? service.dest : service.service_file
// 392:           service.path_dirs.each(&:mkpath)
// 393:           launchctl_load(service, file:, enable:)
// 394:         elsif System.systemctl?
// 395:           # Systemctl loads based upon location so only install service
// 396:           # file when it is not installed. Used with the `run` command.
// 397:           install_service_file(service, file) unless service.dest.exist?
// 398:           service.path_dirs.each(&:mkpath)
// 399:           systemd_load(service, enable:)
// 400:         end
// 401:
// 402:         function = enable ? "started" : "ran"
// 403:         ohai("Successfully #{function} `#{service.name}` (label: #{service.service_name})")
// 404:       end
// 405:
// 406:       sig { params(service: Services::FormulaWrapper, file: T.nilable(Pathname)).void }
// 407:       def self.install_service_file(service, file)
// 408:         raise UsageError, "Formula `#{service.name}` is not installed." unless service.installed?
// 409:
// 410:         unless service.service_file.exist?
// 411:           raise UsageError,
// 412:                 "Formula `#{service.name}` has not implemented #plist, #service or provided a locatable service file."
// 413:         end
// 414:
// 415:         temp = Tempfile.new(service.service_name)
// 416:         temp << if file.nil?
// 417:           contents = service.service_contents
// 418:
// 419:           if sudo_service_user && System.launchctl?
// 420:             # set the username in the new plist file
// 421:             ohai "Setting username in #{service.service_name} to: #{sudo_service_user}"
// 422:             require "plist"
// 423:             plist_data = Plist.parse_xml(contents, marshal: false)
// 424:             plist_data["UserName"] = sudo_service_user
// 425:             plist_data.to_plist
// 426:           else
// 427:             contents
// 428:           end
// 429:         else
// 430:           file.read
// 431:         end
// 432:         temp.flush
// 433:
// 434:         rm service.dest if service.dest.exist?
// 435:         service.dest_dir.mkpath unless service.dest_dir.directory?
// 436:         cp T.must(temp.path), service.dest
// 437:
// 438:         # Clear tempfile.
// 439:         temp.close
// 440:
// 441:         chmod 0644, service.dest
// 442:         if System.systemctl? && service.timed?
// 443:           rm service.timer_dest if service.timer_dest.exist?
// 444:           cp service.timer_file, service.timer_dest
// 445:           chmod 0644, service.timer_dest
// 446:         end
// 447:
// 448:         System::Systemctl.run("daemon-reload") if System.systemctl?
// 449:       end
// 450:     end
// 451:   end
// 452: end
