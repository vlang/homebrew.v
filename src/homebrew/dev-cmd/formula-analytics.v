module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/formula-analytics.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 66.
pub fn ruby_formula_analytics_l66_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `setup_python` at line 72.
pub fn ruby_formula_analytics_l72_d2_setup_python(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('setup_python', ...args)
}

// Ruby method `formula_analytics_root` at line 88.
pub fn ruby_formula_analytics_l88_d3_formula_analytics_root(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_analytics_root', ...args)
}

// Ruby method `influxdb_query_script` at line 93.
pub fn ruby_formula_analytics_l93_d4_influxdb_query_script(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('influxdb_query_script', ...args)
}

// Ruby method `venv_root` at line 98.
pub fn ruby_formula_analytics_l98_d5_venv_root(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('venv_root', ...args)
}

// Ruby method `venv_python` at line 104.
pub fn ruby_formula_analytics_l104_d6_venv_python(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('venv_python', ...args)
}

// Ruby method `each_influx_record(query, &_block)` at line 109.
pub fn ruby_formula_analytics_l109_d7_each_influx_record(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('each_influx_record', ...args)
}

// Ruby method `influx_analytics(args)` at line 140.
pub fn ruby_formula_analytics_l140_d8_influx_analytics(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('influx_analytics', ...args)
}

// Ruby method `format_count(count)` at line 416.
pub fn ruby_formula_analytics_l416_d9_format_count(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('format_count', ...args)
}

// Ruby method `format_percent(percent)` at line 421.
pub fn ruby_formula_analytics_l421_d10_format_percent(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('format_percent', ...args)
}

// Ruby method `format_os_version_dimension(dimension)` at line 426.
pub fn ruby_formula_analytics_l426_d11_format_os_version_dimension(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('format_os_version_dimension', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5:
// 6: module Homebrew
// 7:   module DevCmd
// 8:     class FormulaAnalytics < AbstractCommand
// 9:       cmd_args do
// 10:         usage_banner <<~EOS
// 11:           `formula-analytics`
// 12:
// 13:           Query Homebrew's analytics.
// 14:         EOS
// 15:         flag   "--days-ago=",
// 16:                description: "Query from the specified days ago until the present. The default is 30 days."
// 17:         switch "--install",
// 18:                description: "Output the number of specifically requested installations or installation as " \
// 19:                             "dependencies of formulae. This is the default."
// 20:         switch "--install-on-request",
// 21:                description: "Output the number of specifically requested installations of formulae."
// 22:         switch "--cask-install",
// 23:                description: "Output the number of installations of casks."
// 24:         switch "--build-error",
// 25:                description: "Output the number of build errors for formulae."
// 26:         switch "--os-version",
// 27:                description: "Output the number of events by OS name and version."
// 28:         switch "--homebrew-devcmdrun-developer",
// 29:                description: "Output the number of devcmdrun/HOMEBREW_DEVELOPER events."
// 30:         switch "--homebrew-env-config",
// 31:                description: "Output rates of non-default Homebrew environment configuration variables."
// 32:         switch "--homebrew-os-arch-ci",
// 33:                description: "Output the number of OS/Architecture/CI events."
// 34:         switch "--homebrew-prefixes",
// 35:                description: "Output Homebrew prefixes."
// 36:         switch "--homebrew-versions",
// 37:                description: "Output Homebrew versions."
// 38:         switch "--brew-command-run",
// 39:                description: "Output `brew` commands run."
// 40:         switch "--brew-command-run-options",
// 41:                description: "Output `brew` commands run with options."
// 42:         switch "--brew-test-bot-test",
// 43:                description: "Output `brew test-bot` steps run."
// 44:         switch "--json",
// 45:                description: "Output JSON. This is required: plain text support has been removed."
// 46:         switch "--all-core-formulae-json",
// 47:                description: "Output a different JSON format containing the JSON data for all " \
// 48:                             "Homebrew/homebrew-core formulae."
// 49:         switch "--setup",
// 50:                description: "Install the necessary Python dependencies and exit without running a query."
// 51:
// 52:         conflicts "--install", "--cask-install", "--install-on-request", "--build-error", "--os-version",
// 53:                   "--homebrew-devcmdrun-developer", "--homebrew-env-config", "--homebrew-os-arch-ci",
// 54:                   "--homebrew-prefixes", "--homebrew-versions", "--brew-command-run", "--brew-command-run-options",
// 55:                   "--brew-test-bot-test"
// 56:         conflicts "--json", "--all-core-formulae-json", "--setup"
// 57:
// 58:         named_args :none
// 59:
// 60:         hide_from_man_page!
// 61:       end
// 62:
// 63:       FIRST_INFLUXDB_ANALYTICS_DATE = Date.new(2023, 03, 27).freeze
// 64:
// 65:       sig { override.void }
// 66:       def run
// 67:         setup_python
// 68:         influx_analytics(args)
// 69:       end
// 70:
// 71:       sig { void }
// 72:       def setup_python
// 73:         uv = which("uv", ORIGINAL_PATHS)
// 74:         odie <<~EOS if uv.nil?
// 75:           `uv` is required. Try:
// 76:             brew install uv
// 77:         EOS
// 78:
// 79:         vendor_python = venv_root.dirname
// 80:         vendor_python.children.reject { |path| path == venv_root }.each(&:rmtree) if vendor_python.exist?
// 81:
// 82:         with_env(UV_PROJECT_ENVIRONMENT: venv_root.to_s) do
// 83:           safe_system uv, "sync", "--frozen", "--project", formula_analytics_root, out: :err
// 84:         end
// 85:       end
// 86:
// 87:       sig { returns(Pathname) }
// 88:       def formula_analytics_root
// 89:         HOMEBREW_LIBRARY/"Homebrew/formula-analytics"
// 90:       end
// 91:
// 92:       sig { returns(Pathname) }
// 93:       def influxdb_query_script
// 94:         formula_analytics_root/"influxdb-query.py"
// 95:       end
// 96:
// 97:       sig { returns(Pathname) }
// 98:       def venv_root
// 99:         python_version = (formula_analytics_root/".python-version").read.chomp
// 100:         Pathname.new("~/.brew-formula-analytics/vendor/python").expand_path/python_version
// 101:       end
// 102:
// 103:       sig { returns(Pathname) }
// 104:       def venv_python
// 105:         venv_root/"bin/python"
// 106:       end
// 107:
// 108:       sig { params(query: String, _block: T.proc.params(record: T::Hash[String, T.untyped]).void).void }
// 109:       def each_influx_record(query, &_block)
// 110:         require "json"
// 111:         require "tempfile"
// 112:         require "utils/analytics"
// 113:         require "utils/popen"
// 114:
// 115:         request = {
// 116:           host:     URI.parse(Utils::Analytics::INFLUX_HOST).host,
// 117:           org:      Utils::Analytics::INFLUX_ORG,
// 118:           database: Utils::Analytics::INFLUX_BUCKET,
// 119:           query:,
// 120:         }.to_json
// 121:
// 122:         Tempfile.create("influxdb-query-stderr") do |stderr_file|
// 123:           Utils.popen([venv_python.to_s, influxdb_query_script.to_s], "r+b", { err: stderr_file.path }) do |pipe|
// 124:             pipe.write request
// 125:             pipe.close_write
// 126:             pipe.each_line { |line| yield JSON.parse(line) }
// 127:           end
// 128:
// 129:           next if $CHILD_STATUS.success?
// 130:
// 131:           stderr = stderr_file.read
// 132:           if stderr.include?("unauthenticated")
// 133:             odie "Could not authenticate with InfluxDB! Please check your `$HOMEBREW_INFLUXDB_TOKEN`!"
// 134:           end
// 135:           odie "InfluxDB query failed:\n#{stderr}"
// 136:         end
// 137:       end
// 138:
// 139:       sig { params(args: Homebrew::DevCmd::FormulaAnalytics::Args).void }
// 140:       def influx_analytics(args)
// 141:         require "utils/analytics"
// 142:         require "json"
// 143:
// 144:         if args.setup?
// 145:           safe_system venv_python, influxdb_query_script, "--check"
// 146:           return
// 147:         end
// 148:
// 149:         odie "`$HOMEBREW_NO_ANALYTICS` is set!" if ENV["HOMEBREW_NO_ANALYTICS"]
// 150:
// 151:         odie "No InfluxDB credentials found in `$HOMEBREW_INFLUXDB_TOKEN`!" unless ENV["HOMEBREW_INFLUXDB_TOKEN"]
// 152:
// 153:         max_days_ago = (Date.today - FIRST_INFLUXDB_ANALYTICS_DATE).to_s.to_i
// 154:         days_ago = (args.days_ago || 30).to_i
// 155:         if days_ago > max_days_ago
// 156:           opoo "Analytics started #{FIRST_INFLUXDB_ANALYTICS_DATE}. `--days-ago` set to maximum value."
// 157:           days_ago = max_days_ago
// 158:         end
// 159:         if days_ago > 365
// 160:           opoo "Analytics are only retained for 1 year, setting `--days-ago=365`."
// 161:           days_ago = 365
// 162:         end
// 163:
// 164:         all_core_formulae_json = args.all_core_formulae_json?
// 165:
// 166:         categories = []
// 167:         categories << :build_error if args.build_error?
// 168:         categories << :cask_install if args.cask_install?
// 169:         categories << :formula_install if args.install?
// 170:         categories << :formula_install_on_request if args.install_on_request?
// 171:         categories << :homebrew_devcmdrun_developer if args.homebrew_devcmdrun_developer?
// 172:         categories << :homebrew_env_config if args.homebrew_env_config?
// 173:         categories << :homebrew_os_arch_ci if args.homebrew_os_arch_ci?
// 174:         categories << :homebrew_prefixes if args.homebrew_prefixes?
// 175:         categories << :homebrew_versions if args.homebrew_versions?
// 176:         categories << :os_versions if args.os_version?
// 177:         categories << :command_run if args.brew_command_run?
// 178:         categories << :command_run_options if args.brew_command_run_options?
// 179:         categories << :test_bot_test if args.brew_test_bot_test?
// 180:
// 181:         category_matching_buckets = [:build_error, :cask_install, :command_run, :test_bot_test]
// 182:
// 183:         categories.each do |category|
// 184:           additional_where = all_core_formulae_json ? " AND tap_name ~ '^homebrew/(core|cask)$'" : ""
// 185:           bucket = if category_matching_buckets.include?(category)
// 186:             category
// 187:           elsif [:command_run_options, :homebrew_env_config].include?(category)
// 188:             :command_run
// 189:           else
// 190:             :formula_install
// 191:           end
// 192:
// 193:           case category
// 194:           when :homebrew_devcmdrun_developer
// 195:             dimension_key = "devcmdrun_developer"
// 196:             groups = [:devcmdrun, :developer]
// 197:           when :homebrew_env_config
// 198:             dimension_key = "env_config"
// 199:             groups = [:env_config, :env_config_state]
// 200:             # Events predating the user-set-aware `env_config_state` tag
// 201:             # counted brew's own exports as configuration, so drop them.
// 202:             additional_where += " AND env_config_state IS NOT NULL"
// 203:           when :homebrew_os_arch_ci
// 204:             dimension_key = "os_arch_ci"
// 205:             groups = [:os, :arch, :ci]
// 206:           when :homebrew_prefixes
// 207:             dimension_key = "prefix"
// 208:             groups = [:prefix, :os, :arch]
// 209:             standard_prefixes = %w[/opt/homebrew /usr/local /home/linuxbrew/.linuxbrew]
// 210:           when :homebrew_versions
// 211:             dimension_key = "version"
// 212:             groups = [:version]
// 213:           when :os_versions
// 214:             dimension_key = :os_version
// 215:             groups = [:os_name_and_version]
// 216:           when :command_run
// 217:             dimension_key = "command_run"
// 218:             groups = [:command]
// 219:           when :command_run_options
// 220:             dimension_key = "command_run_options"
// 221:             groups = [:command, :options, :devcmdrun, :developer]
// 222:           when :test_bot_test
// 223:             dimension_key = "test_bot_test"
// 224:             groups = [:command, :passed, :arch, :os]
// 225:           when :cask_install
// 226:             dimension_key = :cask
// 227:             groups = [:package, :tap_name]
// 228:           else
// 229:             dimension_key = :formula
// 230:             additional_where += " AND on_request = 'true'" if category == :formula_install_on_request
// 231:             groups = [:package, :tap_name, :options]
// 232:           end
// 233:
// 234:           sql_groups = groups.map { |e| "\"#{e}\"" }.join(",")
// 235:           query = <<~EOS
// 236:             SELECT #{sql_groups}, COUNT(*) AS "count" FROM "#{bucket}" WHERE time >= now() - INTERVAL '#{days_ago} day'#{additional_where} GROUP BY #{sql_groups}
// 237:           EOS
// 238:
// 239:           json = T.let({
// 240:             category:,
// 241:             total_items: 0,
// 242:             start_date:  Date.today - days_ago.to_i,
// 243:             end_date:    Date.today,
// 244:             total_count: 0,
// 245:             items:       [],
// 246:           }, T::Hash[Symbol, T.untyped])
// 247:
// 248:           each_influx_record(query) do |record|
// 249:             if category == :homebrew_env_config
// 250:               state = record["env_config_state"]
// 251:               env_config_name = record["env_config"].to_s
// 252:               # Drop malformed events from non-standard clients and events
// 253:               # for variables Homebrew no longer supports.
// 254:               next if %w[unset default non_default].exclude?(state)
// 255:               next unless Homebrew::EnvConfig::ENVS.key?(env_config_name.to_sym)
// 256:
// 257:               count = record["count"]
// 258:               json[:total_count] += count
// 259:               json[:items] << {
// 260:                 number: nil,
// 261:                 dimension_key => env_config_name,
// 262:                 count:,
// 263:                 non_default_count: (state == "non_default") ? count : 0,
// 264:                 set_default_count: (state == "default") ? count : 0,
// 265:                 unset_count:       (state == "unset") ? count : 0,
// 266:               }
// 267:               next
// 268:             end
// 269:
// 270:             dimension = case category
// 271:             when :homebrew_devcmdrun_developer
// 272:               "devcmdrun=#{record["devcmdrun"]} HOMEBREW_DEVELOPER=#{record["developer"]}"
// 273:             when :homebrew_os_arch_ci
// 274:               if record["ci"] == "true"
// 275:                 "#{record["os"]} #{record["arch"]} (CI)"
// 276:               else
// 277:                 "#{record["os"]} #{record["arch"]}"
// 278:               end
// 279:             when :homebrew_prefixes
// 280:               prefix = record["prefix"].to_s
// 281:               if T.must(standard_prefixes).none? { |std| std.casecmp?(prefix) }
// 282:                 "custom-prefix (#{record["os"]} #{record["arch"]})"
// 283:               else
// 284:                 prefix
// 285:               end
// 286:             when :os_versions
// 287:               format_os_version_dimension(record["os_name_and_version"])
// 288:             when :command_run_options
// 289:               "#{record["command"]} #{record["options"].to_s.split.sort.join(" ")}"
// 290:             when :test_bot_test
// 291:               command_and_package, options = record["command"].split.partition { |arg| !arg.start_with?("-") }
// 292:
// 293:               # Cleanup bad data before https://github.com/Homebrew/homebrew-test-bot/pull/1043
// 294:               # Can delete this code after 27th April 2025.
// 295:               next if %w[audit install linkage style test].exclude?(command_and_package.first)
// 296:               next if command_and_package.last.include?("/")
// 297:               next if options.include?("--tap=")
// 298:               next if options.include?("--only-dependencies")
// 299:               next if options.include?("--cached")
// 300:
// 301:               command_and_options = (command_and_package + options.sort).join(" ")
// 302:               passed = (record["passed"] == "true") ? "PASSED" : "FAILED"
// 303:
// 304:               "#{command_and_options} (#{record["os"]} #{record["arch"]}) (#{passed})"
// 305:             else
// 306:               record[groups.first.to_s]
// 307:             end
// 308:             next if dimension.blank?
// 309:
// 310:             if (tap_name = record["tap_name"].presence) &&
// 311:                ((tap_name != "homebrew/cask" && dimension_key == :cask) ||
// 312:                 (tap_name != "homebrew/core" && dimension_key == :formula))
// 313:               dimension = "#{tap_name}/#{dimension}"
// 314:             end
// 315:
// 316:             if (all_core_formulae_json || category == :build_error) &&
// 317:                (options = record["options"].presence)
// 318:               # homebrew/core formulae don't have non-HEAD options but they ended up in our analytics anyway.
// 319:               if all_core_formulae_json
// 320:                 options = options.split.include?("--HEAD") ? "--HEAD" : ""
// 321:               end
// 322:               dimension = "#{dimension} #{options}"
// 323:             end
// 324:
// 325:             dimension = dimension.strip
// 326:             next if dimension.match?(/[<>]/)
// 327:
// 328:             count = record["count"]
// 329:
// 330:             json[:total_items] += 1
// 331:             json[:total_count] += count
// 332:
// 333:             json[:items] << {
// 334:               number: nil,
// 335:               dimension_key => dimension,
// 336:               count:,
// 337:             }
// 338:           end
// 339:
// 340:           odie "No data returned" if json[:total_count].zero?
// 341:
// 342:           # Combine identical values
// 343:           deduped_items = {}
// 344:
// 345:           json[:items].each do |item|
// 346:             key = item[dimension_key]
// 347:             if deduped_items.key?(key)
// 348:               deduped_items[key][:count] += item[:count]
// 349:               if category == :homebrew_env_config
// 350:                 deduped_items[key][:non_default_count] += item[:non_default_count]
// 351:                 deduped_items[key][:set_default_count] += item[:set_default_count]
// 352:                 deduped_items[key][:unset_count] += item[:unset_count]
// 353:               end
// 354:             else
// 355:               deduped_items[key] = item
// 356:             end
// 357:           end
// 358:
// 359:           json[:items] = deduped_items.values
// 360:           json[:total_items] = json[:items].length if category == :homebrew_env_config
// 361:
// 362:           if all_core_formulae_json
// 363:             core_formula_items = {}
// 364:
// 365:             json[:items].each do |item|
// 366:               item.delete(:number)
// 367:               formula_name, = item[dimension_key].split.first
// 368:               next if formula_name.include?("/")
// 369:
// 370:               core_formula_items[formula_name] ||= []
// 371:               core_formula_items[formula_name] << item
// 372:             end
// 373:             json.delete(:items)
// 374:
// 375:             core_formula_items.each_value do |items|
// 376:               items.sort_by! { |item| -item[:count] }
// 377:               items.each do |item|
// 378:                 item[:count] = format_count(item[:count])
// 379:               end
// 380:             end
// 381:
// 382:             json[:formulae] = core_formula_items.sort_by { |name, _| name }.to_h
// 383:           else
// 384:             json[:items].sort_by! do |item|
// 385:               if category == :homebrew_env_config
// 386:                 -item[:non_default_count].to_f / item[:count]
// 387:               else
// 388:                 -item[:count]
// 389:               end
// 390:             end
// 391:
// 392:             json[:items].each_with_index do |item, index|
// 393:               item[:number] = index + 1
// 394:
// 395:               percent = if category == :homebrew_env_config
// 396:                 (item[:non_default_count].to_f / item[:count]) * 100
// 397:               else
// 398:                 (item[:count].to_f / json[:total_count]) * 100
// 399:               end
// 400:               item[:percent] = format_percent(percent)
// 401:               item[:count] = format_count(item[:count])
// 402:               next if category != :homebrew_env_config
// 403:
// 404:               item[:non_default_count] = format_count(item[:non_default_count])
// 405:               item[:set_default_count] = format_count(item[:set_default_count])
// 406:               item[:unset_count] = format_count(item[:unset_count])
// 407:               item[:default_value] = Homebrew::EnvConfig.default_description(item[dimension_key].to_sym)
// 408:             end
// 409:           end
// 410:
// 411:           puts JSON.pretty_generate json
// 412:         end
// 413:       end
// 414:
// 415:       sig { params(count: Integer).returns(String) }
// 416:       def format_count(count)
// 417:         count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
// 418:       end
// 419:
// 420:       sig { params(percent: Float).returns(String) }
// 421:       def format_percent(percent)
// 422:         format("%<percent>.2f", percent:).gsub(/\.00$/, "")
// 423:       end
// 424:
// 425:       sig { params(dimension: T.nilable(String)).returns(T.nilable(String)) }
// 426:       def format_os_version_dimension(dimension)
// 427:         return if dimension.blank?
// 428:
// 429:         require "macos_version"
// 430:         require "utils/analytics"
// 431:
// 432:         wsl = dimension.end_with?(Utils::Analytics::WSL_SUFFIX)
// 433:         dimension = dimension.delete_suffix(Utils::Analytics::WSL_SUFFIX)
// 434:         dimension = dimension.gsub(/^Intel ?/, "")
// 435:                              .gsub(/^macOS ?/, "")
// 436:                              .gsub(/ \(.+\)$/, "")
// 437:
// 438:         begin
// 439:           macos_version = ::MacOSVersion.new(dimension)
// 440:           if macos_version.pretty_name.presence && macos_version.to_sym != :dunno
// 441:             return "macOS #{macos_version.pretty_name} (#{macos_version.strip_patch})"
// 442:           end
// 443:         rescue MacOSVersion::Error
// 444:           nil
// 445:         end
// 446:
// 447:         formatted_dimension = case dimension
// 448:         when /Ubuntu(-Server)? (14|16|18|20|22|24)\.04/ then "Ubuntu #{Regexp.last_match(2)}.04 LTS"
// 449:         when /Ubuntu(-Server)? (\d+\.\d+).\d ?(LTS)?/
// 450:           "Ubuntu #{Regexp.last_match(2)} #{Regexp.last_match(3)}".strip
// 451:         when %r{Debian GNU/Linux (\d+)\.\d+} then "Debian #{Regexp.last_match(1)} #{Regexp.last_match(2)}"
// 452:         when /CentOS (\w+) (\d+)/ then "CentOS #{Regexp.last_match(1)} #{Regexp.last_match(2)}"
// 453:         when /Fedora Linux (\d+)[.\d]*/ then "Fedora Linux #{Regexp.last_match(1)}"
// 454:         when /KDE neon .*?([\d.]+)/ then "KDE neon #{Regexp.last_match(1)}"
// 455:         when /Amazon Linux (\d+)\.[.\d]*/ then "Amazon Linux #{Regexp.last_match(1)}"
// 456:         when /^Armbian\S*(?: OS)? (\d+)\.0?(\d+)\S*(?: (\w+))?/
// 457:           "Armbian #{Regexp.last_match(1)}.#{Regexp.last_match(2)} #{Regexp.last_match(3)&.downcase}".strip
// 458:         when /Fedora Linux Rawhide[.\dn]*/ then "Fedora Linux Rawhide"
// 459:         when /Red Hat Enterprise Linux CoreOS (\d+\.\d+)[-.\d]*/
// 460:           "Red Hat Enterprise Linux CoreOS #{Regexp.last_match(1)}"
// 461:         when /([A-Za-z ]+)\s+(\d+)\.\d{8}[.\d]*/ then "#{Regexp.last_match(1)} #{Regexp.last_match(2)}"
// 462:         # odisabled: add new entries when removing support, remove entries when no longer in the data
// 463:         when /^10\.14[.\d]*/ then "macOS Mojave (10.14)"
// 464:         when /^10\.13[.\d]*/ then "macOS High Sierra (10.13)"
// 465:         when /^10\.12[.\d]*/ then "macOS Sierra (10.12)"
// 466:         when /^10\.(\d+)/ then "macOS 10.#{Regexp.last_match(1)}"
// 467:         else dimension
// 468:         end
// 469:
// 470:         Utils::Analytics.with_wsl_suffix_if_needed(formatted_dimension, wsl:)
// 471:       end
// 472:     end
// 473:   end
// 474: end
