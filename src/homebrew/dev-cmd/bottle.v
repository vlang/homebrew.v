module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/bottle.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 100.
pub fn ruby_bottle_l100_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `generate_sha256_line(tag, digest, cellar, tag_column, digest_column)` at line 119.
pub fn ruby_bottle_l119_d2_generate_sha256_line(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('generate_sha256_line', ...args)
}

// Ruby method `bottle_output(bottle, root_url_using)` at line 135.
pub fn ruby_bottle_l135_d3_bottle_output(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bottle_output', ...args)
}

// Ruby method `parse_json_files(filenames)` at line 164.
pub fn ruby_bottle_l164_d4_parse_json_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parse_json_files', ...args)
}

// Ruby method `merge_json_files(json_files)` at line 171.
pub fn ruby_bottle_l171_d5_merge_json_files(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('merge_json_files', ...args)
}

// Ruby method `merge_bottle_spec(old_keys, old_bottle_spec, new_bottle_hash)` at line 189.
pub fn ruby_bottle_l189_d6_merge_bottle_spec(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('merge_bottle_spec', ...args)
}

// Ruby method `keg_contain?(string, keg, ignores, formula_and_runtime_deps_names = nil)` at line 237.
pub fn ruby_bottle_l237_d7_keg_contain(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keg_contain?', ...args)
}

// Ruby method `keg_contain_absolute_symlink_starting_with?(string, keg)` at line 289.
pub fn ruby_bottle_l289_d8_keg_contain_absolute_symlink_starting_with(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keg_contain_absolute_symlink_starting_with?', ...args)
}

// Ruby method `cellar_parameter_needed?(cellar)` at line 308.
pub fn ruby_bottle_l308_d9_cellar_parameter_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cellar_parameter_needed?', ...args)
}

// Ruby method `sudo_purge` at line 318.
pub fn ruby_bottle_l318_d10_sudo_purge(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('sudo_purge', ...args)
}

// Ruby method `tar_args` at line 325.
pub fn ruby_bottle_l325_d11_tar_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tar_args', ...args)
}

// Ruby method `gnu_tar(gnu_tar_formula)` at line 330.
pub fn ruby_bottle_l330_d12_gnu_tar(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gnu_tar', ...args)
}

// Ruby method `reproducible_gnutar_args(mtime)` at line 335.
pub fn ruby_bottle_l335_d13_reproducible_gnutar_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reproducible_gnutar_args', ...args)
}

// Ruby method `gnu_tar_formula_ensure_installed_if_needed!` at line 353.
pub fn ruby_bottle_l353_d14_gnu_tar_formula_ensure_installed_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('gnu_tar_formula_ensure_installed_if_needed!', ...args)
}

// Ruby method `setup_tar_and_args!(mtime, default_tar: false)` at line 366.
pub fn ruby_bottle_l366_d15_setup_tar_and_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('setup_tar_and_args!', ...args)
}

// Ruby method `formula_ignores(formula)` at line 380.
pub fn ruby_bottle_l380_d16_formula_ignores(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_ignores', ...args)
}

// Ruby method `bottle_formula(formula)` at line 393.
pub fn ruby_bottle_l393_d17_bottle_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bottle_formula', ...args)
}

// Ruby method `merge` at line 713.
pub fn ruby_bottle_l713_d18_merge(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('merge', ...args)
}

// Ruby method `old_checksums(formula, formula_ast, bottle_hash)` at line 897.
pub fn ruby_bottle_l897_d19_old_checksums(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('old_checksums', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "fileutils"
// 6: require "formula"
// 7: require "utils/bottles"
// 8: require "tab"
// 9: require "sbom"
// 10: require "keg"
// 11: require "formula_versions"
// 12: require "erb"
// 13: require "utils/gzip"
// 14: require "api"
// 15: require "extend/hash/deep_merge"
// 16: require "metafiles"
// 17: require "utils/github"
// 18:
// 19: module Homebrew
// 20:   module DevCmd
// 21:     class Bottle < AbstractCommand
// 22:       include FileUtils
// 23:
// 24:       BOTTLE_ERB = T.let(<<-EOS.freeze, String)
// 25:   bottle do
// 26:     <% if [HOMEBREW_BOTTLE_DEFAULT_DOMAIN.to_s,
// 27:            "#{HOMEBREW_BOTTLE_DEFAULT_DOMAIN}/bottles"].exclude?(root_url) %>
// 28:     root_url "<%= root_url %>"<% if root_url_using.present? %>,
// 29:       using: <%= root_url_using %>
// 30:     <% end %>
// 31:     <% end %>
// 32:     <% if rebuild.positive? %>
// 33:     rebuild <%= rebuild %>
// 34:     <% end %>
// 35:     <% sha256_lines.each do |line| %>
// 36:     <%= line %>
// 37:     <% end %>
// 38:   end
// 39:       EOS
// 40:
// 41:       MAXIMUM_STRING_MATCHES = 100
// 42:
// 43:       ALLOWABLE_HOMEBREW_REPOSITORY_LINKS = T.let([
// 44:         %r{#{Regexp.escape(HOMEBREW_LIBRARY)}/Homebrew/os/(mac|linux)/pkgconfig},
// 45:       ].freeze, T::Array[Regexp])
// 46:
// 47:       cmd_args do
// 48:         description <<~EOS
// 49:           Generate a bottle (binary package) from a formula that was installed with
// 50:           `--build-bottle`.
// 51:           If the formula specifies a rebuild version, it will be incremented in the
// 52:           generated DSL. Passing `--keep-old` will attempt to keep it at its original
// 53:           value, while `--no-rebuild` will remove it.
// 54:         EOS
// 55:         switch "--skip-relocation",
// 56:                description: "Do not check if the bottle can be marked as relocatable."
// 57:         switch "--force-core-tap",
// 58:                description: "Build a bottle even if <formula> is not in `homebrew/core` or any installed taps."
// 59:         switch "--no-rebuild",
// 60:                description: "If the formula specifies a rebuild version, remove it from the generated DSL."
// 61:         switch "--keep-old",
// 62:                description: "If the formula specifies a rebuild version, attempt to preserve its value in the " \
// 63:                             "generated DSL."
// 64:         switch "--json",
// 65:                description: "Write bottle information to a JSON file, which can be used as the value for " \
// 66:                             "`--merge`."
// 67:         switch "--merge",
// 68:                description: "Generate an updated bottle block for a formula and optionally merge it into the " \
// 69:                             "formula file. Instead of a formula name, requires the path to a JSON file generated " \
// 70:                             "with `brew bottle --json` <formula>."
// 71:         switch "--write",
// 72:                depends_on:  "--merge",
// 73:                description: "Write changes to the formula file. A new commit will be generated unless " \
// 74:                             "`--no-commit` is passed."
// 75:         switch "--no-commit",
// 76:                depends_on:  "--write",
// 77:                description: "When passed with `--write`, a new commit will not generated after writing changes " \
// 78:                             "to the formula file."
// 79:         switch "--only-json-tab",
// 80:                depends_on:  "--json",
// 81:                description: "When passed with `--json`, the tab will be written to the JSON file but not the bottle."
// 82:         switch "--no-all-checks",
// 83:                depends_on:  "--merge",
// 84:                description: "Don't try to create an `all` bottle or stop a no-change upload."
// 85:         flag   "--committer=",
// 86:                description: "Specify a committer name and email in `git`'s standard author format.",
// 87:                odeprecated: true
// 88:         flag   "--root-url=",
// 89:                description: "Use the specified <URL> as the root of the bottle's URL instead of Homebrew's default."
// 90:         flag   "--root-url-using=",
// 91:                description: "Use the specified download strategy class for downloading the bottle's URL instead of " \
// 92:                             "Homebrew's default."
// 93:
// 94:         conflicts "--no-rebuild", "--keep-old"
// 95:
// 96:         named_args [:installed_formula, :file], min: 1, without_api: true
// 97:       end
// 98:
// 99:       sig { override.void }
// 100:       def run
// 101:         if args.merge?
// 102:           Homebrew.install_bundler_gems!(groups: ["ast"])
// 103:           return merge
// 104:         end
// 105:
// 106:         Homebrew.install_bundler_gems!(groups: ["bottle"])
// 107:
// 108:         gnu_tar_formula_ensure_installed_if_needed! if args.only_json_tab?
// 109:
// 110:         args.named.to_resolved_formulae(uniq: false).each do |formula|
// 111:           bottle_formula formula
// 112:         end
// 113:       end
// 114:
// 115:       sig {
// 116:         params(tag: Symbol, digest: T.any(Checksum, String), cellar: T.nilable(T.any(String, Symbol)),
// 117:                tag_column: Integer, digest_column: Integer).returns(String)
// 118:       }
// 119:       def generate_sha256_line(tag, digest, cellar, tag_column, digest_column)
// 120:         line = "sha256 "
// 121:         tag_column += line.length
// 122:         digest_column += line.length
// 123:         if cellar.is_a?(Symbol)
// 124:           line += "cellar: :#{cellar},"
// 125:         elsif cellar_parameter_needed?(cellar)
// 126:           line += %Q(cellar: "#{cellar}",)
// 127:         end
// 128:         line += " " * (tag_column - line.length)
// 129:         line += "#{tag}:"
// 130:         line += " " * (digest_column - line.length)
// 131:         %Q(#{line}"#{digest}")
// 132:       end
// 133:
// 134:       sig { params(bottle: BottleSpecification, root_url_using: T.nilable(String)).returns(String) }
// 135:       def bottle_output(bottle, root_url_using)
// 136:         cellars = bottle.checksums.filter_map do |checksum|
// 137:           cellar = checksum["cellar"]
// 138:           next unless cellar_parameter_needed? cellar
// 139:
// 140:           case cellar
// 141:           when String
// 142:             %Q("#{cellar}")
// 143:           when Symbol
// 144:             ":#{cellar}"
// 145:           end
// 146:         end
// 147:         tag_column = cellars.empty? ? 0 : "cellar: #{cellars.max_by(&:length)}, ".length
// 148:
// 149:         tags = bottle.checksums.map { |checksum| checksum["tag"] }
// 150:         # Start where the tag ends, add the max length of the tag, add two for the `: `
// 151:         digest_column = tag_column + tags.max_by(&:length).length + 2
// 152:
// 153:         sha256_lines = bottle.checksums.map do |checksum|
// 154:           generate_sha256_line(checksum["tag"], checksum["digest"], checksum["cellar"], tag_column, digest_column)
// 155:         end
// 156:         erb_binding = bottle.instance_eval { binding }
// 157:         erb_binding.local_variable_set(:sha256_lines, sha256_lines)
// 158:         erb_binding.local_variable_set(:root_url_using, root_url_using)
// 159:         erb = ERB.new BOTTLE_ERB
// 160:         erb.result(erb_binding).gsub(/^\s*$\n/, "")
// 161:       end
// 162:
// 163:       sig { params(filenames: T::Array[String]).returns(T::Array[T::Hash[String, T.untyped]]) }
// 164:       def parse_json_files(filenames)
// 165:         filenames.map do |filename|
// 166:           JSON.parse(File.read(filename))
// 167:         end
// 168:       end
// 169:
// 170:       sig { params(json_files: T::Array[T::Hash[String, T.untyped]]).returns(T::Hash[String, T.untyped]) }
// 171:       def merge_json_files(json_files)
// 172:         json_files.reduce({}) do |hash, json_file|
// 173:           json_file.each_value do |json_hash|
// 174:             json_bottle = json_hash["bottle"]
// 175:             cellar = json_bottle.delete("cellar")
// 176:             json_bottle["tags"].each_value do |json_platform|
// 177:               json_platform["cellar"] ||= cellar
// 178:             end
// 179:           end
// 180:           hash.deep_merge(json_file)
// 181:         end
// 182:       end
// 183:
// 184:       sig {
// 185:         params(old_keys: T::Array[Symbol], old_bottle_spec: BottleSpecification,
// 186:                new_bottle_hash: T::Hash[String, T.untyped])
// 187:           .returns([T::Array[String], T::Array[T::Hash[Symbol, T.any(String, Symbol)]]])
// 188:       }
// 189:       def merge_bottle_spec(old_keys, old_bottle_spec, new_bottle_hash)
// 190:         mismatches = []
// 191:         checksums = []
// 192:
// 193:         new_values = {
// 194:           root_url: new_bottle_hash["root_url"],
// 195:           rebuild:  new_bottle_hash["rebuild"],
// 196:         }
// 197:
// 198:         skip_keys = [:sha256, :cellar]
// 199:         old_keys.each do |key|
// 200:           next if skip_keys.include?(key)
// 201:
// 202:           old_value = old_bottle_spec.public_send(key).to_s
// 203:           new_value = new_values[key].to_s
// 204:
// 205:           next if old_value.present? && new_value == old_value
// 206:
// 207:           mismatches << "#{key}: old: #{old_value.inspect}, new: #{new_value.inspect}"
// 208:         end
// 209:
// 210:         return [mismatches, checksums] if old_keys.exclude? :sha256
// 211:
// 212:         old_bottle_spec.collector.each_tag do |tag|
// 213:           old_tag_spec = old_bottle_spec.collector.specification_for(tag)
// 214:           odie "Specification for tag #{tag} is nil" if old_tag_spec.nil?
// 215:
// 216:           old_hexdigest = old_tag_spec.checksum.hexdigest
// 217:           old_cellar = old_tag_spec.cellar
// 218:           new_value = new_bottle_hash.dig("tags", tag.to_s)
// 219:           if new_value.present? && new_value["sha256"] != old_hexdigest
// 220:             mismatches << "sha256 #{tag}: old: #{old_hexdigest.inspect}, new: #{new_value["sha256"].inspect}"
// 221:           elsif new_value.present? && new_value["cellar"] != old_cellar.to_s
// 222:             mismatches << "cellar #{tag}: old: #{old_cellar.to_s.inspect}, new: #{new_value["cellar"].inspect}"
// 223:           else
// 224:             checksums << { cellar: old_cellar, tag.to_sym => old_hexdigest }
// 225:           end
// 226:         end
// 227:
// 228:         [mismatches, checksums]
// 229:       end
// 230:
// 231:       private
// 232:
// 233:       sig {
// 234:         params(string: String, keg: Keg, ignores: T::Array[Regexp],
// 235:                formula_and_runtime_deps_names: T.nilable(T::Array[String])).returns(T::Boolean)
// 236:       }
// 237:       def keg_contain?(string, keg, ignores, formula_and_runtime_deps_names = nil)
// 238:         @put_string_exists_header, @put_filenames = nil
// 239:
// 240:         print_filename = lambda do |str, filename|
// 241:           unless @put_string_exists_header
// 242:             opoo "String '#{str}' still exists in these files:"
// 243:             @put_string_exists_header = T.let(true, T.nilable(T::Boolean))
// 244:           end
// 245:
// 246:           @put_filenames ||= T.let([], T.nilable(T::Array[T.any(String, Pathname)]))
// 247:
// 248:           return false if @put_filenames.include?(filename)
// 249:
// 250:           puts Formatter.error(filename.to_s)
// 251:           @put_filenames << filename
// 252:         end
// 253:
// 254:         result = T.let(false, T::Boolean)
// 255:
// 256:         keg.each_unique_file_matching(string) do |file|
// 257:           next if Metafiles::EXTENSIONS.include?(file.extname) # Skip document files.
// 258:
// 259:           linked_libraries = Keg.file_linked_libraries(file, string)
// 260:           result ||= !linked_libraries.empty?
// 261:
// 262:           if args.verbose?
// 263:             print_filename.call(string, file) unless linked_libraries.empty?
// 264:             linked_libraries.each do |lib|
// 265:               puts " #{Tty.bold}-->#{Tty.reset} links to #{lib}"
// 266:             end
// 267:           end
// 268:
// 269:           text_matches = Keg.text_matches_in_file(file, string, ignores, linked_libraries,
// 270:                                                   formula_and_runtime_deps_names)
// 271:           result = true if text_matches.any?
// 272:
// 273:           next if !args.verbose? || text_matches.empty?
// 274:
// 275:           print_filename.call(string, file)
// 276:           text_matches.first(MAXIMUM_STRING_MATCHES).each do |match, offset|
// 277:             puts " #{Tty.bold}-->#{Tty.reset} match '#{match}' at offset #{Tty.bold}0x#{offset}#{Tty.reset}"
// 278:           end
// 279:
// 280:           if text_matches.size > MAXIMUM_STRING_MATCHES
// 281:             puts "Only the first #{MAXIMUM_STRING_MATCHES} matches were output."
// 282:           end
// 283:         end
// 284:
// 285:         keg_contain_absolute_symlink_starting_with?(string, keg) || result
// 286:       end
// 287:
// 288:       sig { params(string: String, keg: Keg).returns(T::Boolean) }
// 289:       def keg_contain_absolute_symlink_starting_with?(string, keg)
// 290:         absolute_symlinks_start_with_string = []
// 291:         keg.find do |pn|
// 292:           next if !pn.symlink? || !(link = pn.readlink).absolute?
// 293:
// 294:           absolute_symlinks_start_with_string << pn if link.to_s.start_with?(string)
// 295:         end
// 296:
// 297:         if args.verbose? && absolute_symlinks_start_with_string.present?
// 298:           opoo "Absolute symlink starting with #{string}:"
// 299:           absolute_symlinks_start_with_string.each do |pn|
// 300:             puts "  #{pn} -> #{pn.resolved_path}"
// 301:           end
// 302:         end
// 303:
// 304:         !absolute_symlinks_start_with_string.empty?
// 305:       end
// 306:
// 307:       sig { params(cellar: T.nilable(T.any(String, Symbol))).returns(T::Boolean) }
// 308:       def cellar_parameter_needed?(cellar)
// 309:         default_cellars = [
// 310:           Homebrew::DEFAULT_MACOS_CELLAR,
// 311:           Homebrew::DEFAULT_MACOS_ARM_CELLAR,
// 312:           Homebrew::DEFAULT_LINUX_CELLAR,
// 313:         ]
// 314:         cellar.present? && default_cellars.exclude?(cellar)
// 315:       end
// 316:
// 317:       sig { returns(T.nilable(T::Boolean)) }
// 318:       def sudo_purge
// 319:         return unless ENV["HOMEBREW_BOTTLE_SUDO_PURGE"]
// 320:
// 321:         system "/usr/bin/sudo", "--non-interactive", "/usr/sbin/purge"
// 322:       end
// 323:
// 324:       sig { returns(T::Array[String]) }
// 325:       def tar_args
// 326:         [].freeze
// 327:       end
// 328:
// 329:       sig { params(gnu_tar_formula: Formula).returns(String) }
// 330:       def gnu_tar(gnu_tar_formula)
// 331:         "#{gnu_tar_formula.opt_bin}/tar"
// 332:       end
// 333:
// 334:       sig { params(mtime: String).returns(T::Array[String]) }
// 335:       def reproducible_gnutar_args(mtime)
// 336:         # Ensure gnu tar is set up for reproducibility.
// 337:         # https://reproducible-builds.org/docs/archives/
// 338:         [
// 339:           # File modification times
// 340:           "--mtime=#{mtime}",
// 341:           # File ordering
// 342:           "--sort=name",
// 343:           # Users, groups and numeric ids
// 344:           "--owner=0", "--group=0", "--numeric-owner",
// 345:           # PAX headers
// 346:           "--format=pax",
// 347:           # Set exthdr names to exclude PID (for GNU tar <1.33). Also don't store atime and ctime.
// 348:           "--pax-option=globexthdr.name=/GlobalHead.%n,exthdr.name=%d/PaxHeaders/%f,delete=atime,delete=ctime"
// 349:         ].freeze
// 350:       end
// 351:
// 352:       sig { returns(T.nilable(Formula)) }
// 353:       def gnu_tar_formula_ensure_installed_if_needed!
// 354:         gnu_tar_formula = begin
// 355:           Formula["gnu-tar"]
// 356:         rescue FormulaUnavailableError
// 357:           nil
// 358:         end
// 359:         return if gnu_tar_formula.blank?
// 360:
// 361:         gnu_tar_formula.ensure_installed!(reason: "bottling")
// 362:         gnu_tar_formula
// 363:       end
// 364:
// 365:       sig { params(mtime: String, default_tar: T::Boolean).returns([String, T::Array[String]]) }
// 366:       def setup_tar_and_args!(mtime, default_tar: false)
// 367:         # Without --only-json-tab bottles are never reproducible
// 368:         default_tar_args = ["tar", tar_args].freeze
// 369:         return default_tar_args if !args.only_json_tab? || default_tar
// 370:
// 371:         # Use gnu-tar as it can be set up for reproducibility better than libarchive
// 372:         # and to be consistent between macOS and Linux.
// 373:         gnu_tar_formula = gnu_tar_formula_ensure_installed_if_needed!
// 374:         return default_tar_args if gnu_tar_formula.blank?
// 375:
// 376:         [gnu_tar(gnu_tar_formula), reproducible_gnutar_args(mtime)].freeze
// 377:       end
// 378:
// 379:       sig { params(formula: Formula).returns(T::Array[Regexp]) }
// 380:       def formula_ignores(formula)
// 381:         # Ignore matches to go keg, because all go binaries are statically linked.
// 382:         any_go_deps = formula.deps.any? do |dep|
// 383:           Version.formula_optionally_versioned_regex(:go).match?(dep.name)
// 384:         end
// 385:         return [] unless any_go_deps
// 386:
// 387:         cellar_regex = Regexp.escape(HOMEBREW_CELLAR)
// 388:         go_regex = Version.formula_optionally_versioned_regex(:go, full: false)
// 389:         Array(%r{#{cellar_regex}/#{go_regex}/[\d.]+/libexec})
// 390:       end
// 391:
// 392:       sig { params(formula: Formula).void }
// 393:       def bottle_formula(formula)
// 394:         local_bottle_json = args.json? && formula.local_bottle_path
// 395:
// 396:         unless local_bottle_json
// 397:           unless formula.latest_version_installed?
// 398:             return ofail "Formula not installed or up-to-date: #{formula.full_name}"
// 399:           end
// 400:           unless Utils::Bottles.built_as? formula
// 401:             return ofail "Formula was not installed with `--build-bottle`: #{formula.full_name}"
// 402:           end
// 403:         end
// 404:
// 405:         tap = formula.tap
// 406:         if tap.nil?
// 407:           return ofail "Formula not from core or any installed taps: #{formula.full_name}" unless args.force_core_tap?
// 408:
// 409:           tap = CoreTap.instance
// 410:         end
// 411:         raise TapUnavailableError, tap.name unless tap.installed?
// 412:
// 413:         return ofail "Formula has no stable version: #{formula.full_name}" unless formula.stable
// 414:
// 415:         bottle_tag, rebuild = if local_bottle_json
// 416:           _, tag_string, rebuild_string = Utils::Bottles.extname_tag_rebuild(formula.local_bottle_path.to_s)
// 417:           [T.must(tag_string).to_sym, rebuild_string.to_i]
// 418:         end
// 419:
// 420:         bottle_tag = if bottle_tag
// 421:           Utils::Bottles::Tag.from_symbol(bottle_tag)
// 422:         else
// 423:           Utils::Bottles.tag
// 424:         end
// 425:
// 426:         rebuild ||= if args.no_rebuild? || !tap
// 427:           0
// 428:         elsif args.keep_old?
// 429:           formula.bottle_specification.rebuild
// 430:         else
// 431:           ohai "Determining #{formula.full_name} bottle rebuild..."
// 432:           FormulaVersions.new(formula).formula_at_revision("origin/HEAD") do |upstream_formula|
// 433:             if formula.pkg_version == upstream_formula.pkg_version
// 434:               upstream_formula.bottle_specification.rebuild + 1
// 435:             else
// 436:               0
// 437:             end
// 438:           end || 0
// 439:         end
// 440:
// 441:         filename = ::Bottle::Filename.create(formula, bottle_tag, rebuild)
// 442:         local_filename = filename.to_s
// 443:         bottle_path = Pathname.pwd/local_filename
// 444:
// 445:         tab = nil
// 446:         keg = nil
// 447:
// 448:         tap_path = tap.path
// 449:         tap_git_revision = tap.git_head
// 450:         tap_git_remote = tap.remote
// 451:
// 452:         root_url = args.root_url
// 453:
// 454:         relocatable = T.let(false, T::Boolean)
// 455:         skip_relocation = T.let(false, T::Boolean)
// 456:
// 457:         prefix = HOMEBREW_PREFIX.to_s
// 458:         cellar = HOMEBREW_CELLAR.to_s
// 459:
// 460:         if local_bottle_json
// 461:           bottle_path = formula.local_bottle_path
// 462:           return unless bottle_path
// 463:
// 464:           local_filename = bottle_path.basename.to_s
// 465:
// 466:           tab_path = Utils::Bottles.receipt_path(bottle_path)
// 467:           raise "This bottle does not contain the file INSTALL_RECEIPT.json: #{bottle_path}" unless tab_path
// 468:
// 469:           tab_json = Utils::Bottles.file_from_bottle(bottle_path, tab_path)
// 470:           tab = Tab.from_file_content(tab_json, tab_path)
// 471:
// 472:           tag_spec = Formula[formula.name].bottle_specification
// 473:                                           .tag_specification_for(bottle_tag, no_older_versions: true)
// 474:           relocatable = BottleSpecification::RELOCATABLE_CELLARS.include?(tag_spec.cellar)
// 475:           skip_relocation = tag_spec.cellar == BottleSpecification::ANY_SKIP_RELOCATION_CELLAR
// 476:
// 477:           prefix = bottle_tag.default_prefix
// 478:           cellar = bottle_tag.default_cellar
// 479:         else
// 480:           tar_filename = filename.to_s.sub(/.gz$/, "")
// 481:           tar_path = Pathname.pwd/tar_filename
// 482:           return if tar_path.blank?
// 483:
// 484:           keg = Keg.new(formula.prefix)
// 485:         end
// 486:
// 487:         ohai "Bottling #{local_filename}..."
// 488:
// 489:         formula_and_runtime_deps_names = [formula.name] + formula.runtime_dependencies.map(&:name)
// 490:
// 491:         # this will be nil when using a local bottle
// 492:         keg&.lock do
// 493:           original_tab = nil
// 494:           changed_files = nil
// 495:
// 496:           begin
// 497:             keg.delete_pyc_files!
// 498:
// 499:             changed_files = keg.replace_locations_with_placeholders unless args.skip_relocation?
// 500:
// 501:             Formula.clear_cache
// 502:             Keg.clear_cache
// 503:             Tab.clear_cache
// 504:             Dependency.clear_cache
// 505:             Requirement.clear_cache
// 506:
// 507:             tab = keg.tab
// 508:             original_tab = tab.dup
// 509:             tab.poured_from_bottle = false
// 510:             tab.time = nil
// 511:             tab.changed_files = changed_files.dup
// 512:             if args.only_json_tab?
// 513:               tab.changed_files&.delete(Pathname.new(AbstractTab::FILENAME))
// 514:               tab.tabfile&.unlink
// 515:             else
// 516:               tab.write
// 517:             end
// 518:
// 519:             sbom = SBOM.create(formula, tab)
// 520:             sbom.write(bottling: true)
// 521:
// 522:             keg.consistent_reproducible_symlink_permissions!
// 523:
// 524:             cd cellar do
// 525:               sudo_purge
// 526:               # Tar then gzip for reproducible bottles.
// 527:               # GNU tar fails to create a bottle if modification time is unsigned integer
// 528:               # (i.e. before 1970)
// 529:               time_at_epoch = Time.at(1)
// 530:               tab_source_modified_time = [time_at_epoch, tab.source_modified_time].max
// 531:               tar_mtime = tab_source_modified_time.strftime("%Y-%m-%d %H:%M:%S")
// 532:               tar, tar_args = setup_tar_and_args!(tar_mtime, default_tar: formula.name == "gnu-tar")
// 533:               safe_system tar, "--create", "--numeric-owner",
// 534:                           *tar_args,
// 535:                           "--file", tar_path, "#{formula.name}/#{formula.pkg_version}"
// 536:               sudo_purge
// 537:               # Set filename as it affects the tarball checksum.
// 538:               relocatable_tar_path = "#{formula}-bottle.tar"
// 539:               mv T.must(tar_path), relocatable_tar_path
// 540:               # Use gzip, faster to compress than bzip2, faster to uncompress than bzip2
// 541:               # or an uncompressed tarball (and more bandwidth friendly).
// 542:               Utils::Gzip.compress_with_options(relocatable_tar_path,
// 543:                                                 mtime:     tab.source_modified_time,
// 544:                                                 orig_name: relocatable_tar_path,
// 545:                                                 output:    bottle_path)
// 546:               sudo_purge
// 547:             end
// 548:
// 549:             ohai "Detecting if #{local_filename} is relocatable..." if bottle_path.size > 1 * 1024 * 1024
// 550:
// 551:             is_usr_local_prefix = prefix == "/usr/local"
// 552:             prefix_check = if is_usr_local_prefix
// 553:               "#{prefix}/opt"
// 554:             else
// 555:               prefix
// 556:             end
// 557:
// 558:             # Ignore matches to source code, which is not required at run time.
// 559:             # These matches may be caused by debugging symbols.
// 560:             ignores = [%r{/include/|\.(c|cc|cpp|h|hpp)$}]
// 561:
// 562:             # Add additional workarounds to ignore
// 563:             ignores += formula_ignores(formula)
// 564:
// 565:             repository_reference = if HOMEBREW_PREFIX == HOMEBREW_REPOSITORY
// 566:               HOMEBREW_LIBRARY
// 567:             else
// 568:               HOMEBREW_REPOSITORY
// 569:             end.to_s
// 570:             if keg_contain?(repository_reference, keg, ignores + ALLOWABLE_HOMEBREW_REPOSITORY_LINKS)
// 571:               odie "Bottle contains non-relocatable reference to #{repository_reference}!"
// 572:             end
// 573:
// 574:             relocatable = true
// 575:             if args.skip_relocation?
// 576:               skip_relocation = true
// 577:             else
// 578:               relocatable = false if keg_contain?(prefix_check, keg, ignores, formula_and_runtime_deps_names)
// 579:               relocatable = false if keg_contain?(cellar, keg, ignores, formula_and_runtime_deps_names)
// 580:               relocatable = false if keg_contain?(HOMEBREW_LIBRARY.to_s, keg, ignores, formula_and_runtime_deps_names)
// 581:               if is_usr_local_prefix
// 582:                 relocatable = false if keg_contain_absolute_symlink_starting_with?(prefix, keg)
// 583:                 if tap.disabled_new_usr_local_relocation_formulae.exclude?(formula.name)
// 584:                   keg.new_usr_local_replacement_pairs.each_value do |value|
// 585:                     relocatable = false if keg_contain?(value.fetch(:old), keg, ignores)
// 586:                   end
// 587:                 else
// 588:                   relocatable = false if keg_contain?("#{prefix}/etc", keg, ignores)
// 589:                   relocatable = false if keg_contain?("#{prefix}/var", keg, ignores)
// 590:                   relocatable = false if keg_contain?("#{prefix}/share/vim", keg, ignores)
// 591:                 end
// 592:               end
// 593:               skip_relocation = relocatable && !keg.require_relocation?
// 594:             end
// 595:             puts if !relocatable && args.verbose?
// 596:           rescue Interrupt
// 597:             ignore_interrupts { bottle_path.unlink if bottle_path.exist? }
// 598:             raise
// 599:           ensure
// 600:             ignore_interrupts do
// 601:               original_tab&.write
// 602:               keg.replace_placeholders_with_locations(changed_files) if changed_files && !args.skip_relocation?
// 603:             end
// 604:           end
// 605:         end
// 606:
// 607:         bottle = BottleSpecification.new
// 608:         bottle.tap = tap
// 609:         bottle.root_url(root_url) if root_url
// 610:         bottle_cellar = if relocatable
// 611:           if skip_relocation
// 612:             BottleSpecification::ANY_SKIP_RELOCATION_CELLAR
// 613:           else
// 614:             BottleSpecification::ANY_CELLAR
// 615:           end
// 616:         else
// 617:           cellar
// 618:         end
// 619:         bottle.rebuild rebuild
// 620:         sha256 = bottle_path.sha256
// 621:         bottle.sha256 cellar: bottle_cellar, bottle_tag.to_sym => sha256
// 622:
// 623:         old_spec = formula.bottle_specification
// 624:         if args.keep_old? && !old_spec.checksums.empty?
// 625:           mismatches = [:root_url, :rebuild].reject do |key|
// 626:             old_spec.public_send(key) == bottle.public_send(key)
// 627:           end
// 628:           unless mismatches.empty?
// 629:             bottle_path.unlink if bottle_path.exist?
// 630:
// 631:             mismatches.map! do |key|
// 632:               old_value = old_spec.public_send(key).inspect
// 633:               value = bottle.public_send(key).inspect
// 634:               "#{key}: old: #{old_value}, new: #{value}"
// 635:             end
// 636:
// 637:             odie <<~EOS
// 638:               `--keep-old` was passed but there are changes in:
// 639:               #{mismatches.join("\n")}
// 640:             EOS
// 641:           end
// 642:         end
// 643:
// 644:         output = bottle_output(bottle, args.root_url_using)
// 645:
// 646:         puts "./#{local_filename}"
// 647:         puts output
// 648:
// 649:         return unless args.json?
// 650:
// 651:         if keg
// 652:           keg_prefix = "#{keg}/"
// 653:           path_exec_files = [keg/"bin", keg/"sbin"].select(&:exist?)
// 654:                                                    .flat_map(&:children)
// 655:                                                    .select(&:executable?)
// 656:                                                    .map { |path| path.to_s.delete_prefix(keg_prefix) }
// 657:           all_files = keg.find
// 658:                          .select(&:file?)
// 659:                          .map { |path| path.to_s.delete_prefix(keg_prefix) }
// 660:           installed_size = keg.disk_usage
// 661:         end
// 662:
// 663:         bottle_tab = tab
// 664:         odie "Cannot generate bottle JSON without an installation receipt." if bottle_tab.nil?
// 665:
// 666:         json = {
// 667:           formula.full_name => {
// 668:             "formula" => {
// 669:               "name"             => formula.name,
// 670:               "pkg_version"      => formula.pkg_version.to_s,
// 671:               "path"             => formula.tap_path.to_s.delete_prefix("#{HOMEBREW_REPOSITORY}/"),
// 672:               "tap_git_path"     => formula.tap_path.to_s.delete_prefix("#{tap_path}/"),
// 673:               "tap_git_revision" => tap_git_revision,
// 674:               "tap_git_remote"   => tap_git_remote,
// 675:               # descriptions can contain emoji. sigh.
// 676:               "desc"             => formula.desc.to_s.encode(
// 677:                 Encoding.find("ASCII"),
// 678:                 invalid: :replace, undef: :replace, replace: "",
// 679:               ).strip,
// 680:               "license"          => SPDX.license_expression_to_string(formula.license),
// 681:               "homepage"         => formula.homepage,
// 682:             },
// 683:             "bottle"  => {
// 684:               "root_url" => bottle.root_url,
// 685:               "cellar"   => bottle_cellar.to_s,
// 686:               "rebuild"  => bottle.rebuild,
// 687:               # date is used for org.opencontainers.image.created which is an RFC 3339 date-time.
// 688:               # Time#iso8601 produces an XML Schema date-time that meets RFC 3339 ABNF.
// 689:               "date"     => Pathname(filename.to_s).mtime.utc.iso8601,
// 690:               "tags"     => {
// 691:                 bottle_tag.to_s => {
// 692:                   "filename"        => filename.url_encode,
// 693:                   "local_filename"  => filename.to_s,
// 694:                   "sha256"          => sha256,
// 695:                   "tab"             => bottle_tab.to_bottle_hash,
// 696:                   "sbom"            => SBOM.create(formula, bottle_tab).to_spdx_supplement,
// 697:                   "path_exec_files" => path_exec_files,
// 698:                   "all_files"       => all_files,
// 699:                   "installed_size"  => installed_size,
// 700:                 },
// 701:               },
// 702:             },
// 703:           },
// 704:         }
// 705:
// 706:         puts "Writing #{filename.json}" if args.verbose?
// 707:         json_path = Pathname(filename.json)
// 708:         json_path.unlink if json_path.exist?
// 709:         json_path.write(JSON.pretty_generate(json))
// 710:       end
// 711:
// 712:       sig { returns(T::Hash[String, T.untyped]) }
// 713:       def merge
// 714:         bottles_hash = merge_json_files(parse_json_files(args.named))
// 715:
// 716:         any_cellars = BottleSpecification::RELOCATABLE_CELLARS.map(&:to_s)
// 717:         bottles_hash.each do |formula_name, bottle_hash|
// 718:           ohai formula_name
// 719:
// 720:           bottle = BottleSpecification.new
// 721:           bottle.root_url bottle_hash["bottle"]["root_url"]
// 722:           bottle.rebuild bottle_hash["bottle"]["rebuild"]
// 723:
// 724:           path = HOMEBREW_REPOSITORY/bottle_hash["formula"]["path"]
// 725:           formula = Formulary.factory(path)
// 726:
// 727:           old_bottle_spec = formula.bottle_specification
// 728:           old_pkg_version = formula.pkg_version
// 729:           FormulaVersions.new(formula).formula_at_revision("origin/HEAD") do |upstream_formula|
// 730:             old_pkg_version = upstream_formula.pkg_version
// 731:           end
// 732:
// 733:           old_bottle_spec_matches = old_bottle_spec &&
// 734:                                     bottle_hash["formula"]["pkg_version"] == old_pkg_version.to_s &&
// 735:                                     bottle.root_url == old_bottle_spec.root_url &&
// 736:                                     old_bottle_spec.collector.tags.present?
// 737:
// 738:           # if all the cellars and checksums are the same: we can create an
// 739:           # `all: $SHA256` bottle.
// 740:           tag_hashes = bottle_hash["bottle"]["tags"].values
// 741:           all_bottle = !args.no_all_checks? &&
// 742:                        (!old_bottle_spec_matches || bottle.rebuild != old_bottle_spec.rebuild) &&
// 743:                        tag_hashes.count > 1 &&
// 744:                        tag_hashes.uniq { |tag_hash| "#{tag_hash["cellar"]}-#{tag_hash["sha256"]}" }.one?
// 745:
// 746:           old_all_bottle = old_bottle_spec.tag?(Utils::Bottles.tag(:all))
// 747:           github_event_path = ENV.fetch("GITHUB_EVENT_PATH", nil)
// 748:           if !all_bottle && old_all_bottle && !args.no_all_checks? && github_event_path.present?
// 749:             begin
// 750:               github_event = JSON.parse(File.read(github_event_path))
// 751:               repository = github_event.dig("repository", "full_name")
// 752:               pull_request_number = github_event.dig("pull_request", "number")
// 753:               if repository.present? && pull_request_number.present?
// 754:                 GitHub.create_issue_comment(repository, pull_request_number, <<~MARKDOWN)
// 755:                   Warning: #{formula} should have had an `:all` bottle but one could not be created.
// 756:                   #{Utils::Bottles.missing_all_bottle_publish_note.capitalize}.
// 757:
// 758:                   ```json
// 759:                   #{JSON.pretty_generate(tag_hashes)}
// 760:                   ```
// 761:                 MARKDOWN
// 762:               end
// 763:             rescue GitHub::API::Error, JSON::ParserError, Errno::ENOENT => e
// 764:               opoo "Failed to post missing `:all` bottle warning to pull request: #{e.message}"
// 765:             end
// 766:           end
// 767:
// 768:           bottle_hash["bottle"]["tags"].each do |tag, tag_hash|
// 769:             cellar = tag_hash["cellar"]
// 770:             cellar = cellar.to_sym if any_cellars.include?(cellar)
// 771:
// 772:             tag_sym = if all_bottle
// 773:               :all
// 774:             else
// 775:               tag.to_sym
// 776:             end
// 777:
// 778:             sha256_hash = { cellar:, tag_sym => tag_hash["sha256"] }
// 779:             bottle.sha256 sha256_hash
// 780:
// 781:             break if all_bottle
// 782:           end
// 783:
// 784:           unless args.write?
// 785:             puts bottle_output(bottle, args.root_url_using)
// 786:             next
// 787:           end
// 788:
// 789:           no_bottle_changes = if !args.no_all_checks? && old_bottle_spec_matches &&
// 790:                                  bottle.rebuild != old_bottle_spec.rebuild
// 791:             bottle.collector.tags.all? do |tag|
// 792:               tag_spec = bottle.collector.specification_for(tag)
// 793:               next false if tag_spec.blank?
// 794:
// 795:               old_tag_spec = old_bottle_spec.collector.specification_for(tag)
// 796:               next false if old_tag_spec.blank?
// 797:
// 798:               next false if tag_spec.cellar != old_tag_spec.cellar
// 799:
// 800:               tag_spec.checksum.hexdigest == old_tag_spec.checksum.hexdigest
// 801:             end
// 802:           end
// 803:
// 804:           all_bottle_hash = T.let(nil, T.nilable(T::Hash[String, T.untyped]))
// 805:           bottle_hash["bottle"]["tags"].each do |tag, tag_hash|
// 806:             filename = ::Bottle::Filename.new(
// 807:               formula_name,
// 808:               PkgVersion.parse(bottle_hash["formula"]["pkg_version"]),
// 809:               Utils::Bottles::Tag.from_symbol(tag.to_sym),
// 810:               bottle_hash["bottle"]["rebuild"],
// 811:             )
// 812:
// 813:             if all_bottle && all_bottle_hash.nil?
// 814:               all_bottle_tag_hash = tag_hash.dup
// 815:
// 816:               all_filename = ::Bottle::Filename.new(
// 817:                 formula_name,
// 818:                 PkgVersion.parse(bottle_hash["formula"]["pkg_version"]),
// 819:                 Utils::Bottles::Tag.from_symbol(:all),
// 820:                 bottle_hash["bottle"]["rebuild"],
// 821:               )
// 822:
// 823:               all_bottle_tag_hash["filename"] = all_filename.url_encode
// 824:               all_bottle_tag_hash["local_filename"] = all_filename.to_s
// 825:               cellar = all_bottle_tag_hash.delete("cellar")
// 826:               sbom_tags = bottle_hash["bottle"]["tags"].filter_map do |tag, tag_hash|
// 827:                 [tag, tag_hash["sbom"]] if tag_hash["sbom"].present?
// 828:               end.to_h
// 829:               all_bottle_tag_hash["sbom"] = { "tags" => sbom_tags } if sbom_tags.present?
// 830:
// 831:               all_bottle_formula_hash = bottle_hash.dup
// 832:               all_bottle_formula_hash["bottle"]["cellar"] = cellar
// 833:               all_bottle_formula_hash["bottle"]["tags"] = { all: all_bottle_tag_hash }
// 834:
// 835:               all_bottle_hash = { formula_name => all_bottle_formula_hash }
// 836:
// 837:               puts "Copying #{filename} to #{all_filename}" if args.verbose?
// 838:               FileUtils.cp filename.to_s, all_filename.to_s
// 839:
// 840:               puts "Writing #{all_filename.json}" if args.verbose?
// 841:               all_local_json_path = Pathname(all_filename.json)
// 842:               all_local_json_path.unlink if all_local_json_path.exist?
// 843:               all_local_json_path.write(JSON.pretty_generate(all_bottle_hash))
// 844:             end
// 845:
// 846:             if all_bottle || no_bottle_changes
// 847:               puts "Removing #{filename} and #{filename.json}" if args.verbose?
// 848:               FileUtils.rm_f [filename.to_s, filename.json]
// 849:             end
// 850:           end
// 851:
// 852:           next if no_bottle_changes
// 853:
// 854:           require "utils/ast"
// 855:           formula_ast = Utils::AST::FormulaAST.new(path.read)
// 856:           checksums = old_checksums(formula, formula_ast, bottle_hash)
// 857:           update_or_add = checksums.nil? ? "add" : "update"
// 858:
// 859:           checksums&.each { |checksum| bottle.sha256(checksum) }
// 860:           output = bottle_output(bottle, args.root_url_using)
// 861:           puts output
// 862:
// 863:           case update_or_add
// 864:           when "update"
// 865:             formula_ast.replace_bottle_block(output)
// 866:           when "add"
// 867:             formula_ast.add_bottle_block(output)
// 868:           end
// 869:           path.atomic_write(formula_ast.process)
// 870:
// 871:           next if args.no_commit?
// 872:
// 873:           Utils::Git.set_name_email!(committer: args.committer.blank?)
// 874:           Utils::Git.setup_gpg!
// 875:
// 876:           if (committer = args.committer)
// 877:             committer = Utils.parse_author!(committer)
// 878:             ENV["GIT_COMMITTER_NAME"] = committer[:name]
// 879:             ENV["GIT_COMMITTER_EMAIL"] = committer[:email]
// 880:           end
// 881:
// 882:           short_name = Utils.name_from_full_name(formula_name)
// 883:           pkg_version = bottle_hash["formula"]["pkg_version"]
// 884:
// 885:           path.parent.cd do
// 886:             safe_system "git", "commit", "--no-edit", "--verbose",
// 887:                         "--message=#{short_name}: #{update_or_add} #{pkg_version} bottle.",
// 888:                         "--", path
// 889:           end
// 890:         end
// 891:       end
// 892:
// 893:       sig {
// 894:         params(formula: Formula, formula_ast: Utils::AST::FormulaAST, bottle_hash: T::Hash[String, T.untyped])
// 895:           .returns(T.nilable(T::Array[T::Hash[Symbol, T.any(String, Symbol)]]))
// 896:       }
// 897:       def old_checksums(formula, formula_ast, bottle_hash)
// 898:         bottle_node = T.cast(formula_ast.bottle_block, T.nilable(RuboCop::AST::BlockNode))
// 899:         return if bottle_node.nil?
// 900:         return [] unless args.keep_old?
// 901:
// 902:         old_keys = T.cast(Utils::AST.body_children(bottle_node.body), T::Array[RuboCop::AST::SendNode])
// 903:                     .map(&:method_name)
// 904:         old_bottle_spec = formula.bottle_specification
// 905:         mismatches, checksums = merge_bottle_spec(old_keys, old_bottle_spec, bottle_hash["bottle"])
// 906:         if mismatches.present?
// 907:           odie <<~EOS
// 908:             `--keep-old` was passed but there are changes in:
// 909:             #{mismatches.join("\n")}
// 910:           EOS
// 911:         end
// 912:         checksums
// 913:       end
// 914:     end
// 915:   end
// 916: end
// 917:
// 918: require "extend/os/dev-cmd/bottle"
