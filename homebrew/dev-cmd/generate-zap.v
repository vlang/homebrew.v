module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/generate-zap.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 95.
pub fn ruby_generate_zap_l95_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `resolve_patterns_from_cask(cask)` at line 133.
pub fn ruby_generate_zap_l133_d2_resolve_patterns_from_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('resolve_patterns_from_cask', ...args)
}

// Ruby method `bundle_identifiers(app_artifact)` at line 146.
pub fn ruby_generate_zap_l146_d3_bundle_identifiers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bundle_identifiers', ...args)
}

// Ruby method `scan_directories(directories, home_relative:, patterns:)` at line 164.
pub fn ruby_generate_zap_l164_d4_scan_directories(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('scan_directories', ...args)
}

// Ruby method `scan_home_root(patterns)` at line 186.
pub fn ruby_generate_zap_l186_d5_scan_home_root(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('scan_home_root', ...args)
}

// Ruby method `each_readable_child(dir, &block)` at line 204.
pub fn ruby_generate_zap_l204_d6_each_readable_child(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('each_readable_child', ...args)
}

// Ruby method `collapse_to_wildcards(paths)` at line 212.
pub fn ruby_generate_zap_l212_d7_collapse_to_wildcards(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('collapse_to_wildcards', ...args)
}

// Ruby method `replace_uuids(paths)` at line 235.
pub fn ruby_generate_zap_l235_d8_replace_uuids(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('replace_uuids', ...args)
}

// Ruby method `glob_shared_filelists(paths)` at line 240.
pub fn ruby_generate_zap_l240_d9_glob_shared_filelists(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('glob_shared_filelists', ...args)
}

// Ruby method `derive_rmdir_candidates(paths)` at line 245.
pub fn ruby_generate_zap_l245_d10_derive_rmdir_candidates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('derive_rmdir_candidates', ...args)
}

// Ruby method `normalize_path(path)` at line 266.
pub fn ruby_generate_zap_l266_d11_normalize_path(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('normalize_path', ...args)
}

// Ruby method `format_stanza(trash:, delete:, rmdir:)` at line 278.
pub fn ruby_generate_zap_l278_d12_format_stanza(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('format_stanza', ...args)
}

// Ruby method `format_patterns(patterns)` at line 291.
pub fn ruby_generate_zap_l291_d13_format_patterns(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('format_patterns', ...args)
}

// Ruby method `find_wildcard_groups(basenames)` at line 296.
pub fn ruby_generate_zap_l296_d14_find_wildcard_groups(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('find_wildcard_groups', ...args)
}

// Ruby method `format_directive(key, paths)` at line 325.
pub fn ruby_generate_zap_l325_d15_format_directive(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('format_directive', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "cask"
// 6: require "system_command"
// 7:
// 8: module Homebrew
// 9:   module DevCmd
// 10:     class GenerateZap < AbstractCommand
// 11:       include SystemCommand::Mixin
// 12:
// 13:       cmd_args do
// 14:         description <<~EOS
// 15:           Generate a `zap` stanza for a cask by scanning the system for associated
// 16:           files and directories.
// 17:
// 18:           Accepts a cask token (e.g. `firefox`) or, with `--name`, a raw application
// 19:           name string (e.g. `Firefox`). When a cask token is given, the application
// 20:           name is resolved from the cask's `app` artifact.
// 21:
// 22:           The target application should have been launched at least once so that
// 23:           preference files and caches exist on disk.
// 24:
// 25:           Outputs `trash`, `delete`, and `rmdir` directives suitable for pasting
// 26:           into a cask definition.
// 27:         EOS
// 28:
// 29:         switch "--name",
// 30:                description: "Treat the argument as a raw application name instead of a cask token."
// 31:
// 32:         named_args :cask_or_name, number: 1
// 33:       end
// 34:
// 35:       USER_TRASH_PATHS = [
// 36:         "Desktop",
// 37:         "Documents",
// 38:         "Library",
// 39:         "Library/Application Scripts",
// 40:         "Library/Application Support",
// 41:         "Library/Application Support/CrashReporter",
// 42:         "Library/Application Support/com.apple.sharedfilelist/" \
// 43:         "com.apple.LSSharedFileList.ApplicationRecentDocuments",
// 44:         "Library/Caches",
// 45:         "Library/Caches/com.apple.helpd/Generated",
// 46:         "Library/Caches/com.apple.helpd/SDMHelpData/Other/English/HelpSDMIndexFile",
// 47:         "Library/Containers",
// 48:         "Library/Cookies",
// 49:         "Library/Group Containers",
// 50:         "Library/HTTPStorages",
// 51:         "Library/Internet Plug-Ins",
// 52:         "Library/LaunchAgents",
// 53:         "Library/Logs",
// 54:         "Library/Logs/DiagnosticReports",
// 55:         "Library/PreferencePanes",
// 56:         "Library/Preferences",
// 57:         "Library/Preferences/ByHost",
// 58:         "Library/Saved Application State",
// 59:         "Library/WebKit",
// 60:         "Music",
// 61:       ].freeze
// 62:
// 63:       SYSTEM_DELETE_PATHS = [
// 64:         "/Library/Application Support",
// 65:         "/Library/Caches",
// 66:         "/Library/Frameworks",
// 67:         "/Library/LaunchAgents",
// 68:         "/Library/LaunchDaemons",
// 69:         "/Library/Logs",
// 70:         "/Library/PreferencePanes",
// 71:         "/Library/Preferences",
// 72:         "/Library/PrivilegedHelperTools",
// 73:         "/Library/Screen Savers",
// 74:         "/Library/ScriptingAdditions",
// 75:         "/Library/Services",
// 76:         "/Users/Shared",
// 77:         "/etc/newsyslog.d",
// 78:       ].freeze
// 79:
// 80:       RMDIR_EXCLUSIONS = [
// 81:         "Library/Application Support/CrashReporter",
// 82:         "Library/Application Support/com.apple.sharedfilelist/" \
// 83:         "com.apple.LSSharedFileList.ApplicationRecentDocuments",
// 84:         "/Library/Application Support",
// 85:         "/Library/Caches",
// 86:         "/Library/Preferences",
// 87:       ].freeze
// 88:
// 89:       UUID_PATTERN = /[0-9A-F]{8}(-[0-9A-F]{4}){3}-[0-9A-F]{12}/i
// 90:
// 91:       # Keep in sync with `RuboCop::Cop::Cask::SharedFilelistGlob`.
// 92:       SHARED_FILELIST_PATTERN = /\.sfl\d\z/
// 93:
// 94:       sig { override.void }
// 95:       def run
// 96:         patterns = if args.name?
// 97:           [args.named.fetch(0)]
// 98:         else
// 99:           resolve_patterns_from_cask(args.named.to_casks.fetch(0))
// 100:         end
// 101:
// 102:         ohai "Scanning for files matching #{format_patterns(patterns)}..."
// 103:
// 104:         begin
// 105:           trash_paths = scan_directories(USER_TRASH_PATHS, home_relative: true, patterns:) + scan_home_root(patterns)
// 106:           delete_paths = scan_directories(SYSTEM_DELETE_PATHS, home_relative: false, patterns:)
// 107:         rescue Errno::EACCES, Errno::EPERM => e
// 108:           message = "Unable to generate a complete zap stanza: #{e.message}"
// 109:
// 110:           unless Cask::Utils.full_disk_access_enabled?
// 111:             message += " Please enable Full Disk Access for your terminal under " \
// 112:                        "#{Cask::Utils.privacy_security_preference_pane("Full Disk Access")}."
// 113:           end
// 114:
// 115:           odie message
// 116:         end
// 117:
// 118:         trash_paths  = glob_shared_filelists(replace_uuids(collapse_to_wildcards(trash_paths)))
// 119:         delete_paths = glob_shared_filelists(replace_uuids(collapse_to_wildcards(delete_paths)))
// 120:
// 121:         rmdir_paths = derive_rmdir_candidates(trash_paths + delete_paths)
// 122:
// 123:         if trash_paths.empty? && delete_paths.empty?
// 124:           opoo "No files found matching #{format_patterns(patterns)}."
// 125:           puts "# No zap stanza required"
// 126:           return
// 127:         end
// 128:
// 129:         puts format_stanza(trash: trash_paths, delete: delete_paths, rmdir: rmdir_paths)
// 130:       end
// 131:
// 132:       sig { params(cask: Cask::Cask).returns(T::Array[String]) }
// 133:       def resolve_patterns_from_cask(cask)
// 134:         app_artifact = cask.artifacts.find { |a| a.is_a?(Cask::Artifact::App) }
// 135:         if app_artifact
// 136:           patterns = [app_artifact.target.basename(".app").to_s]
// 137:           patterns.concat(bundle_identifiers(app_artifact))
// 138:           patterns.uniq
// 139:         else
// 140:           ohai "No app artifact found in cask \"#{cask.token}\"; using token as app name."
// 141:           [cask.token.tr("-", " ").split.map(&:capitalize).join(" ")]
// 142:         end
// 143:       end
// 144:
// 145:       sig { params(app_artifact: Cask::Artifact::App).returns(T::Array[String]) }
// 146:       def bundle_identifiers(app_artifact)
// 147:         info_plist = app_artifact.target/"Contents/Info.plist"
// 148:         return [] if !info_plist.exist? || !info_plist.readable?
// 149:
// 150:         plist = system_command!("plutil", args: ["-convert", "xml1", "-o", "-", info_plist]).plist
// 151:         bundle_identifier = plist["CFBundleIdentifier"]
// 152:         return [] unless bundle_identifier.is_a?(String)
// 153:
// 154:         [bundle_identifier]
// 155:       end
// 156:
// 157:       sig {
// 158:         params(
// 159:           directories:   T::Array[String],
// 160:           home_relative: T::Boolean,
// 161:           patterns:      T::Array[String],
// 162:         ).returns(T::Array[String])
// 163:       }
// 164:       def scan_directories(directories, home_relative:, patterns:)
// 165:         home = Dir.home
// 166:         downcased_patterns = patterns.map(&:downcase)
// 167:         matches = []
// 168:
// 169:         directories.each do |dir|
// 170:           full_dir = home_relative ? File.join(home, dir) : dir
// 171:           next unless File.directory?(full_dir)
// 172:
// 173:           each_readable_child(full_dir) do |entry|
// 174:             downcased_entry = entry.downcase
// 175:             next unless downcased_patterns.any? { |pattern| downcased_entry.include?(pattern) }
// 176:
// 177:             full_path = File.join(full_dir, entry)
// 178:             matches << normalize_path(full_path)
// 179:           end
// 180:         end
// 181:
// 182:         matches.uniq.sort
// 183:       end
// 184:
// 185:       sig { params(patterns: T::Array[String]).returns(T::Array[String]) }
// 186:       def scan_home_root(patterns)
// 187:         home = Dir.home
// 188:         downcased_patterns = patterns.map(&:downcase)
// 189:         matches = []
// 190:
// 191:         each_readable_child(home) do |entry|
// 192:           next unless entry.start_with?(".")
// 193:
// 194:           downcased_entry = entry.downcase
// 195:           next unless downcased_patterns.any? { |pattern| downcased_entry.include?(pattern) }
// 196:
// 197:           matches << normalize_path(File.join(home, entry))
// 198:         end
// 199:
// 200:         matches.sort
// 201:       end
// 202:
// 203:       sig { params(dir: String, block: T.proc.params(entry: String).void).void }
// 204:       def each_readable_child(dir, &block)
// 205:         Dir.each_child(dir, &block)
// 206:       rescue Errno::EPERM, Errno::EACCES
// 207:         # Skip directories we lack permission to read, e.g. macOS-protected paths.
// 208:         nil
// 209:       end
// 210:
// 211:       sig { params(paths: T::Array[String]).returns(T::Array[String]) }
// 212:       def collapse_to_wildcards(paths)
// 213:         grouped = paths.group_by { |p| File.dirname(p) }
// 214:
// 215:         result = []
// 216:         grouped.each_value do |entries|
// 217:           if entries.size == 1
// 218:             result << entries.first
// 219:             next
// 220:           end
// 221:
// 222:           basenames = entries.map { |e| File.basename(e) }
// 223:           wildcarded = find_wildcard_groups(basenames)
// 224:
// 225:           dir = File.dirname(entries.fetch(0))
// 226:           wildcarded.each do |name|
// 227:             result << File.join(dir, name)
// 228:           end
// 229:         end
// 230:
// 231:         result.uniq.sort
// 232:       end
// 233:
// 234:       sig { params(paths: T::Array[String]).returns(T::Array[String]) }
// 235:       def replace_uuids(paths)
// 236:         paths.map { |p| p.gsub(UUID_PATTERN, "*") }.uniq.sort
// 237:       end
// 238:
// 239:       sig { params(paths: T::Array[String]).returns(T::Array[String]) }
// 240:       def glob_shared_filelists(paths)
// 241:         paths.map { |p| p.sub(SHARED_FILELIST_PATTERN, ".sfl*") }.uniq.sort
// 242:       end
// 243:
// 244:       sig { params(paths: T::Array[String]).returns(T::Array[String]) }
// 245:       def derive_rmdir_candidates(paths)
// 246:         home = Dir.home
// 247:         candidates = []
// 248:
// 249:         paths.each do |path|
// 250:           expanded = path.start_with?("~") ? File.join(home, path[2..]) : path
// 251:           parent = File.dirname(expanded)
// 252:
// 253:           next unless parent.match?(%r{/(Application Support|Containers|Group Containers)/})
// 254:
// 255:           normalized = normalize_path(parent)
// 256:
// 257:           next if RMDIR_EXCLUSIONS.any? { |excl| normalized == "~/#{excl}" || normalized == excl }
// 258:
// 259:           candidates << normalized unless paths.include?(normalized)
// 260:         end
// 261:
// 262:         candidates.uniq.sort
// 263:       end
// 264:
// 265:       sig { params(path: String).returns(String) }
// 266:       def normalize_path(path)
// 267:         home = Dir.home
// 268:         path.start_with?(home) ? path.sub(home, "~") : path
// 269:       end
// 270:
// 271:       sig {
// 272:         params(
// 273:           trash:  T::Array[String],
// 274:           delete: T::Array[String],
// 275:           rmdir:  T::Array[String],
// 276:         ).returns(String)
// 277:       }
// 278:       def format_stanza(trash:, delete:, rmdir:)
// 279:         directives = []
// 280:         directives << format_directive("trash", trash) unless trash.empty?
// 281:         directives << format_directive("delete", delete) unless delete.empty?
// 282:         directives << format_directive("rmdir", rmdir) unless rmdir.empty?
// 283:
// 284:         directives.join(",\n")
// 285:                   .prepend("zap ")
// 286:       end
// 287:
// 288:       private
// 289:
// 290:       sig { params(patterns: T::Array[String]).returns(String) }
// 291:       def format_patterns(patterns)
// 292:         patterns.map { |pattern| "\"#{pattern}\"" }.to_sentence
// 293:       end
// 294:
// 295:       sig { params(basenames: T::Array[String]).returns(T::Array[String]) }
// 296:       def find_wildcard_groups(basenames)
// 297:         return basenames if basenames.size <= 1
// 298:
// 299:         used = Array.new(basenames.size, false)
// 300:         result = []
// 301:
// 302:         basenames.each_with_index do |name, i|
// 303:           next if used[i]
// 304:
// 305:           group_indices = [i]
// 306:           basenames.each_with_index do |other, j|
// 307:             next if i == j || used[j]
// 308:             next unless other.start_with?(name)
// 309:
// 310:             group_indices << j
// 311:           end
// 312:
// 313:           if group_indices.size > 1
// 314:             result << "#{name}*"
// 315:             group_indices.each { |idx| used[idx] = true }
// 316:           else
// 317:             result << name
// 318:           end
// 319:         end
// 320:
// 321:         result
// 322:       end
// 323:
// 324:       sig { params(key: String, paths: T::Array[String]).returns(String) }
// 325:       def format_directive(key, paths)
// 326:         if paths.size == 1
// 327:           "#{key}: \"#{paths.first}\""
// 328:         else
// 329:           items = paths.map { |p| "       \"#{p}\"" }.join(",\n")
// 330:           "#{key}: [\n#{items},\n     ]"
// 331:         end
// 332:       end
// 333:     end
// 334:   end
// 335: end
