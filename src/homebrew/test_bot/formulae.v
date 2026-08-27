module test_bot

import brew_runtime

// Translated from Homebrew/brew `test_bot/formulae.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_writer `attr_writer :testing_formulae` at line 8.
pub fn ruby_formulae_l8_d1_testing_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('testing_formulae=', ...args)
}

// Ruby attr_writer `attr_writer :added_formulae` at line 11.
pub fn ruby_formulae_l11_d2_added_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('added_formulae=', ...args)
}

// Ruby attr_writer `attr_writer :deleted_formulae` at line 14.
pub fn ruby_formulae_l14_d3_deleted_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deleted_formulae=', ...args)
}

// Ruby method `initialize(tap:, git:, dry_run:, fail_fast:, verbose:, output_paths:)` at line 26.
pub fn ruby_formulae_l26_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `run!(args:)` at line 46.
pub fn ruby_formulae_l46_d5_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run!', ...args)
}

// Ruby method `cleanup_bottle_etc_var(formula)` at line 109.
pub fn ruby_formulae_l109_d6_cleanup_bottle_etc_var(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cleanup_bottle_etc_var', ...args)
}

// Ruby method `verify_local_bottles` at line 116.
pub fn ruby_formulae_l116_d7_verify_local_bottles(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('verify_local_bottles', ...args)
}

// Ruby method `dependency_name_match?(dependency, dependency_name)` at line 166.
pub fn ruby_formulae_l166_d8_dependency_name_match(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('dependency_name_match?', ...args)
}

// Ruby method `annotate_added_dependencies(formula)` at line 175.
pub fn ruby_formulae_l175_d9_annotate_added_dependencies(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('annotate_added_dependencies', ...args)
}

// Ruby method `annotate_missing_all_bottle(formula, bottle_dir: Pathname.pwd)` at line 263.
pub fn ruby_formulae_l263_d10_annotate_missing_all_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('annotate_missing_all_bottle', ...args)
}

// Ruby method `testing_portable_ruby?` at line 325.
pub fn ruby_formulae_l325_d11_testing_portable_ruby(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('testing_portable_ruby?', ...args)
}

// Ruby method `install_ca_certificates_if_needed` at line 332.
pub fn ruby_formulae_l332_d12_install_ca_certificates_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install_ca_certificates_if_needed', ...args)
}

// Ruby method `setup_formulae_deps_instances(formula, formula_name, args:)` at line 340.
pub fn ruby_formulae_l340_d13_setup_formulae_deps_instances(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('setup_formulae_deps_instances', ...args)
}

// Ruby method `bottle_reinstall_formula(formula, new_formula, args:)` at line 428.
pub fn ruby_formulae_l428_d14_bottle_reinstall_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bottle_reinstall_formula', ...args)
}

// Ruby method `build_bottle?(formula, args:)` at line 499.
pub fn ruby_formulae_l499_d15_build_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('build_bottle?', ...args)
}

// Ruby method `setup_bottle_sudo_purge!(args:); end` at line 514.
pub fn ruby_formulae_l514_d16_setup_bottle_sudo_purge(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('setup_bottle_sudo_purge!', ...args)
}

// Ruby method `recursive_runtime_dependency_names(_formula, dependencies)` at line 517.
pub fn ruby_formulae_l517_d17_recursive_runtime_dependency_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('recursive_runtime_dependency_names', ...args)
}

// Ruby method `local_bottle_tag_hashes(formula_name, bottle_dir:)` at line 529.
pub fn ruby_formulae_l529_d18_local_bottle_tag_hashes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('local_bottle_tag_hashes', ...args)
}

// Ruby method `livecheck(formula)` at line 549.
pub fn ruby_formulae_l549_d19_livecheck(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('livecheck', ...args)
}

// Ruby method `formula!(formula_name, args:)` at line 611.
pub fn ruby_formulae_l611_d20_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula!', ...args)
}

// Ruby method `portable_formula!(formula_name, args:)` at line 841.
pub fn ruby_formulae_l841_d21_portable_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('portable_formula!', ...args)
}

// Ruby method `deleted_formula!(formula_name)` at line 948.
pub fn ruby_formulae_l948_d22_deleted_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deleted_formula!', ...args)
}

// Ruby method `integration_test_portable_ruby? = true` at line 961.
pub fn ruby_formulae_l961_d23_integration_test_portable_ruby(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('integration_test_portable_ruby?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module TestBot
// 6:     class Formulae < TestFormulae
// 7:       sig { params(testing_formulae: T::Array[String]).void }
// 8:       attr_writer :testing_formulae
// 9:
// 10:       sig { params(added_formulae: T::Array[String]).void }
// 11:       attr_writer :added_formulae
// 12:
// 13:       sig { params(deleted_formulae: T::Array[String]).void }
// 14:       attr_writer :deleted_formulae
// 15:
// 16:       sig {
// 17:         params(
// 18:           tap:          T.nilable(Tap),
// 19:           git:          String,
// 20:           dry_run:      T::Boolean,
// 21:           fail_fast:    T::Boolean,
// 22:           verbose:      T::Boolean,
// 23:           output_paths: T::Hash[Symbol, Pathname],
// 24:         ).void
// 25:       }
// 26:       def initialize(tap:, git:, dry_run:, fail_fast:, verbose:, output_paths:)
// 27:         super(tap:, git:, dry_run:, fail_fast:, verbose:)
// 28:
// 29:         @built_formulae = T.let([], T::Array[String])
// 30:         @bottle_checksums = T.let({}, T::Hash[Pathname, String])
// 31:         @bottle_output_path = T.let(output_paths.fetch(:bottle), Pathname)
// 32:         @linkage_output_path = T.let(output_paths.fetch(:linkage), Pathname)
// 33:         @skipped_or_failed_formulae_output_path = T.let(output_paths.fetch(:skipped_or_failed_formulae), Pathname)
// 34:         @testing_formulae = T.let([], T::Array[String])
// 35:         @added_formulae = T.let([], T::Array[String])
// 36:         @deleted_formulae = T.let([], T::Array[String])
// 37:         @testing_formulae_count = T.let(0, Integer)
// 38:         @tested_formulae_count = T.let(0, Integer)
// 39:         @unchanged_dependencies = T.let([], T::Array[String])
// 40:         @unchanged_build_dependencies = T.let([], T::Array[String])
// 41:         @bottle_filename = T.let(nil, T.nilable(Pathname))
// 42:         @bottle_json_filename = T.let(nil, T.nilable(Pathname))
// 43:       end
// 44:
// 45:       sig { params(args: Homebrew::Cmd::TestBotCmd::Args).void }
// 46:       def run!(args:)
// 47:         test_header(:Formulae)
// 48:
// 49:         verify_local_bottles
// 50:
// 51:         with_env(HOMEBREW_DISABLE_LOAD_FORMULA: "1") do
// 52:           # Portable Ruby bottles are handled differently.
// 53:           next if testing_portable_ruby?
// 54:
// 55:           download_artifacts_from_previous_run!("bottles{,_#{previous_run_artifact_specifier}*}",
// 56:                                                 dry_run: args.dry_run?)
// 57:         end
// 58:         @bottle_checksums.merge!(
// 59:           bottle_glob("*", artifact_cache, ".{json,tar.gz}", bottle_tag: "*").to_h do |bottle_file|
// 60:             [bottle_file.realpath, bottle_file.sha256]
// 61:           end,
// 62:         )
// 63:
// 64:         # #run! modifies `@testing_formulae`, so we need to track this separately.
// 65:         @testing_formulae_count = @testing_formulae.count
// 66:         perform_bash_cleanup = @testing_formulae.include?("bash")
// 67:         @tested_formulae_count = 0
// 68:
// 69:         sorted_formulae.each do |f|
// 70:           verify_local_bottles
// 71:           if testing_portable_ruby?
// 72:             portable_formula!(f, args:)
// 73:           else
// 74:             formula!(f, args:)
// 75:           end
// 76:           puts
// 77:           next if @testing_formulae_count < 3
// 78:
// 79:           progress_text = +"Test progress: "
// 80:           progress_text += "#{@tested_formulae_count} formula(e) tested, "
// 81:           progress_text += "#{@testing_formulae_count - @tested_formulae_count} remaining"
// 82:           info_header progress_text
// 83:         end
// 84:
// 85:         @deleted_formulae.each do |f|
// 86:           deleted_formula!(f)
// 87:           verify_local_bottles
// 88:           puts
// 89:         end
// 90:
// 91:         return unless GitHub::Actions.env_set?
// 92:
// 93:         # Remove `bash` after it is tested, since leaving a broken `bash`
// 94:         # installation in the environment can cause issues with subsequent
// 95:         # GitHub Actions steps.
// 96:         test "brew", "uninstall", "--formula", "--force", "bash" if perform_bash_cleanup
// 97:
// 98:         File.open(ENV.fetch("GITHUB_OUTPUT"), "a") do |f|
// 99:           f.puts "skipped_or_failed_formulae=#{@skipped_or_failed_formulae.join(",")}"
// 100:         end
// 101:
// 102:         @skipped_or_failed_formulae_output_path.write(@skipped_or_failed_formulae.join(","))
// 103:       ensure
// 104:         verify_local_bottles
// 105:         FileUtils.rm_rf artifact_cache
// 106:       end
// 107:
// 108:       sig { params(formula: Formula).void }
// 109:       def cleanup_bottle_etc_var(formula)
// 110:         # Restore bottled `etc`/`var` through `Formula#install_etc_var`, keeping
// 111:         # test-bot cleanup aligned with `InstallRenamed` config handling.
// 112:         formula.install_etc_var
// 113:       end
// 114:
// 115:       sig { returns(T::Boolean) }
// 116:       def verify_local_bottles
// 117:         # Portable Ruby bottles are handled differently.
// 118:         return false if testing_portable_ruby?
// 119:
// 120:         # Setting `HOMEBREW_DISABLE_LOAD_FORMULA` probably doesn't do anything here but let's set it just to be safe.
// 121:         with_env(HOMEBREW_DISABLE_LOAD_FORMULA: "1") do
// 122:           missing_bottles = @bottle_checksums.keys.reject do |bottle_path|
// 123:             next true if bottle_path.exist?
// 124:
// 125:             what = (bottle_path.extname == ".json") ? "JSON" : "tarball"
// 126:             onoe "Missing bottle #{what}: #{bottle_path}"
// 127:             false
// 128:           end
// 129:
// 130:           mismatched_checksums = @bottle_checksums.reject do |bottle_path, expected_sha256|
// 131:             next true unless bottle_path.exist?
// 132:             next true if (actual_sha256 = bottle_path.sha256) == expected_sha256
// 133:
// 134:             onoe <<~ERROR
// 135:               Bottle checksum mismatch for #{bottle_path}!
// 136:                 Expected: #{expected_sha256}
// 137:                 Actual:   #{actual_sha256}
// 138:             ERROR
// 139:             false
// 140:           end
// 141:
// 142:           unexpected_bottles = bottle_glob(
// 143:             "**/*", Pathname.pwd, ".{json,tar.gz}", bottle_tag: "*"
// 144:           ).reject do |local_bottle|
// 145:             next true if @bottle_checksums.key?(local_bottle.realpath)
// 146:
// 147:             what = (local_bottle.extname == ".json") ? "JSON" : "tarball"
// 148:             onoe "Unexpected bottle #{what}: #{local_bottle}"
// 149:             false
// 150:           end
// 151:
// 152:           return true if missing_bottles.blank? && mismatched_checksums.blank? && unexpected_bottles.blank?
// 153:
// 154:           # Delete these files so we don't end up uploading them.
// 155:           files_to_delete = mismatched_checksums.keys + unexpected_bottles
// 156:           files_to_delete += files_to_delete.select(&:symlink?).map(&:realpath)
// 157:           FileUtils.rm_rf files_to_delete
// 158:
// 159:           test "false" # ensure that `test-bot` exits with an error.
// 160:
// 161:           false
// 162:         end
// 163:       end
// 164:
// 165:       sig { params(dependency: Dependency, dependency_name: String).returns(T::Boolean) }
// 166:       def dependency_name_match?(dependency, dependency_name)
// 167:         return true if dependency.name == dependency_name
// 168:         return false if Utils.tap_from_full_name(dependency.name).present?
// 169:         return false if Utils.tap_from_full_name(dependency_name).present?
// 170:
// 171:         Utils.name_from_full_name(dependency.name) == Utils.name_from_full_name(dependency_name)
// 172:       end
// 173:
// 174:       sig { params(formula: Formula).void }
// 175:       def annotate_added_dependencies(formula)
// 176:         return unless GitHub::Actions.env_set?
// 177:         return if @added_formulae.include?(formula.name)
// 178:         return if (git = self.git).nil?
// 179:
// 180:         direct_runtime_dependencies = formula.deps.reject do |dependency|
// 181:           dependency.build? || dependency.optional? || dependency.test?
// 182:         end
// 183:
// 184:         new_line = T.let(nil, T.nilable(Integer))
// 185:         Utils.safe_popen_read(
// 186:           git, "-C", repository, "diff", "--no-ext-diff", "--unified=0", "origin/HEAD", "HEAD", "--",
// 187:           formula.path.relative_path_from(repository).to_s
// 188:         ).each_line do |diff_line|
// 189:           if (match = diff_line.match(/^@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@/))
// 190:             new_line = match[1]&.to_i
// 191:             next
// 192:           end
// 193:
// 194:           line = new_line
// 195:           next if line.nil?
// 196:
// 197:           if diff_line.start_with?("+") && !diff_line.start_with?("+++")
// 198:             dependency_name = diff_line[/^\+\s*depends_on\s+["']([^"']+)["']/, 1]
// 199:             new_line = line + 1
// 200:           elsif !diff_line.start_with?("-") || diff_line.start_with?("---")
// 201:             new_line = line + 1
// 202:             next
// 203:           else
// 204:             next
// 205:           end
// 206:           next if dependency_name.blank?
// 207:
// 208:           dependency = direct_runtime_dependencies.find do |runtime_dependency|
// 209:             dependency_name_match?(runtime_dependency, dependency_name)
// 210:           end
// 211:           next if dependency.nil?
// 212:
// 213:           dependency_formula = dependency.to_formula
// 214:           existing_runtime_dependency_names = recursive_runtime_dependency_names(
// 215:             formula,
// 216:             direct_runtime_dependencies.reject do |runtime_dependency|
// 217:               dependency_name_match?(runtime_dependency, dependency.name)
// 218:             end,
// 219:           )
// 220:           new_recursive_dependency_names =
// 221:             (
// 222:               [dependency_formula.full_name] +
// 223:               recursive_runtime_dependency_names(
// 224:                 dependency_formula,
// 225:                 dependency_formula.runtime_dependencies(read_from_tab: false, undeclared: false),
// 226:               )
// 227:             ).uniq - existing_runtime_dependency_names
// 228:           next if new_recursive_dependency_names.blank?
// 229:
// 230:           sizes = new_recursive_dependency_names.map do |formula_name|
// 231:             installed_sizes = @dependency_impact_installed_sizes ||=
// 232:               T.let({}, T.nilable(T::Hash[String, T.nilable(Integer)]))
// 233:             next installed_sizes[formula_name] if installed_sizes.key?(formula_name)
// 234:
// 235:             installed_sizes[formula_name] =
// 236:               if (bottle = Formulary.factory(formula_name).bottle_for_tag(Utils::Bottles.tag))
// 237:                 bottle.fetch_tab(quiet: true)
// 238:                 bottle.installed_size
// 239:               end
// 240:           rescue DownloadError, FormulaUnavailableError, Resource::BottleManifest::Error
// 241:             nil
// 242:           end
// 243:           dependency_count = new_recursive_dependency_names.count
// 244:           message = "Adding `#{dependency_name}` adds #{dependency_count} new recursive " \
// 245:                     "#{Utils.pluralize("dependency", dependency_count)} " \
// 246:                     "on #{Utils::Bottles.tag} (#{Formatter.disk_usage_readable(sizes.compact.sum)}"
// 247:           unknown_size_count = sizes.count(&:nil?)
// 248:           message << ", plus #{Utils.pluralize("unknown size", unknown_size_count, include_count: true)}" \
// 249:             if unknown_size_count.positive?
// 250:           puts GitHub::Actions::Annotation.new(
// 251:             :warning,
// 252:             "#{message}).",
// 253:             file:  formula.path.to_s.delete_prefix("#{repository}/"),
// 254:             line:,
// 255:             title: "#{formula}: new dependency impact",
// 256:           )
// 257:         end
// 258:       rescue => e
// 259:         opoo "Failed to determine dependency impact for #{formula.full_name}: #{e}"
// 260:       end
// 261:
// 262:       sig { params(formula: Formula, bottle_dir: Pathname).void }
// 263:       def annotate_missing_all_bottle(formula, bottle_dir: Pathname.pwd)
// 264:         return unless formula.bottle_specification.tag?(Utils::Bottles.tag(:all))
// 265:
// 266:         require "utils/ast"
// 267:
// 268:         bottle_tag = Utils::Bottles.tag
// 269:         bottle_sha256_node_tag = lambda do |sha256_node, tag|
// 270:           sha256_node.arguments.grep(RuboCop::AST::HashNode).any? do |hash_node|
// 271:             hash_node.pairs.any? do |pair|
// 272:               Utils::AST.literal_value(pair.key) == tag ||
// 273:                 Utils::AST.literal_value(pair.value) == tag
// 274:             end
// 275:           end
// 276:         end
// 277:         bottle_node = Utils::AST::FormulaAST.new(formula.path.read).bottle_block
// 278:         sha256_nodes = Utils::AST.body_children(
// 279:           bottle_node.is_a?(RuboCop::AST::BlockNode) ? bottle_node.body : nil,
// 280:         ).filter_map do |node|
// 281:           next unless node.is_a?(RuboCop::AST::SendNode)
// 282:           next if node.method_name != :sha256
// 283:
// 284:           node
// 285:         end
// 286:         return if sha256_nodes.any? { |sha256_node| bottle_sha256_node_tag.call(sha256_node, :all) }
// 287:
// 288:         # This predictor only has local JSONs, so mirror the merge-time tag count
// 289:         # and cellar/checksum dedupe gates; final merge handles version/rebuild.
// 290:         local_tag_hashes = local_bottle_tag_hashes(formula.name, bottle_dir:)
// 291:         return if local_tag_hashes.key?("all")
// 292:         return if local_tag_hashes.count < 2
// 293:         return if local_tag_hashes.values.uniq { |tag_hash| [tag_hash["cellar"], tag_hash["sha256"]] }.one?
// 294:
// 295:         tag_hash = local_tag_hashes[bottle_tag.to_s]
// 296:         line = sha256_nodes.find do |sha256_node|
// 297:           bottle_sha256_node_tag.call(sha256_node, bottle_tag.to_sym)
// 298:         end&.source_range&.line
// 299:         bottle_details = if tag_hash.present?
// 300:           " (cellar `#{tag_hash["cellar"]}`, sha256 `#{tag_hash["sha256"]}`)"
// 301:         else
// 302:           ""
// 303:         end
// 304:         message = "This formula had an `:all` bottle but the #{bottle_tag} test-bot bottle is " \
// 305:                   "platform-specific#{bottle_details}. If the final bottle merge cannot create a new " \
// 306:                   "`:all` bottle, expect #{Utils::Bottles.missing_all_bottle_publish_note}; this is for " \
// 307:                   "information only and should not block merge."
// 308:
// 309:         if GitHub::Actions.env_set?
// 310:           puts GitHub::Actions::Annotation.new(
// 311:             :warning,
// 312:             message,
// 313:             file:  formula.path.to_s.delete_prefix("#{repository}/"),
// 314:             line:,
// 315:             title: "#{formula}: missing :all bottle",
// 316:           )
// 317:         else
// 318:           opoo message
// 319:         end
// 320:       rescue => e
// 321:         opoo "Failed to determine missing `:all` bottle impact for #{formula.full_name}: #{e}"
// 322:       end
// 323:
// 324:       sig { returns(T::Boolean) }
// 325:       def testing_portable_ruby?
// 326:         !!tap&.core_tap? && @testing_formulae.include?("portable-ruby")
// 327:       end
// 328:
// 329:       private
// 330:
// 331:       sig { void }
// 332:       def install_ca_certificates_if_needed
// 333:         return if DevelopmentTools.ca_file_handles_most_https_certificates?
// 334:
// 335:         test "brew", "install", "--formulae", "ca-certificates",
// 336:              env: { "HOMEBREW_DEVELOPER" => nil }
// 337:       end
// 338:
// 339:       sig { params(formula: Formula, formula_name: String, args: Homebrew::Cmd::TestBotCmd::Args).void }
// 340:       def setup_formulae_deps_instances(formula, formula_name, args:)
// 341:         conflicts = T.let(formula.conflicts, T::Array[T.any(Formula, Formula::FormulaConflict)])
// 342:         formula_recursive_dependencies = formula.recursive_dependencies.map(&:to_formula)
// 343:         formula_recursive_dependencies.each do |dependency|
// 344:           conflicts += dependency.conflicts
// 345:         end
// 346:
// 347:         # If we depend on a versioned formula, make sure to unlink any other
// 348:         # installed versions to make sure that we use the right one.
// 349:         versioned_dependencies = formula_recursive_dependencies.select(&:versioned_formula?)
// 350:         versioned_dependencies.each do |dependency|
// 351:           alternative_versions = dependency.versioned_formulae
// 352:
// 353:           begin
// 354:             unversioned_name = dependency.name.sub(/@\d+(\.\d+)*$/, "")
// 355:             alternative_versions << Formula[unversioned_name]
// 356:           rescue FormulaUnavailableError
// 357:             nil
// 358:           end
// 359:
// 360:           unneeded_alternative_versions = alternative_versions - formula_recursive_dependencies
// 361:           conflicts += unneeded_alternative_versions
// 362:         end
// 363:
// 364:         unlink_formulae = conflicts.map(&:name)
// 365:         unlink_formulae.uniq.each do |name|
// 366:           unlink_formula = Formulary.factory(name)
// 367:           next unless unlink_formula.latest_version_installed?
// 368:           next unless unlink_formula.linked_keg.exist?
// 369:
// 370:           test "brew", "unlink", name
// 371:         end
// 372:
// 373:         info_header "Determining dependencies..."
// 374:         installed = Utils.safe_popen_read("brew", "list", "--formula", "--full-name").split("\n")
// 375:         dependencies =
// 376:           Utils.safe_popen_read("brew", "deps", "--formula",
// 377:                                 "--include-build",
// 378:                                 "--include-test",
// 379:                                 "--full-name",
// 380:                                 formula_name)
// 381:                .split("\n")
// 382:         installed_dependencies = installed & dependencies
// 383:         installed_dependencies.each do |name|
// 384:           link_formula = Formulary.factory(name)
// 385:           next if link_formula.keg_only?
// 386:           next if link_formula.linked_keg.exist?
// 387:           next if unlink_formulae.include?(name)
// 388:
// 389:           test "brew", "link", name
// 390:         end
// 391:
// 392:         dependencies -= installed
// 393:         @unchanged_dependencies = dependencies - @testing_formulae
// 394:         unless @unchanged_dependencies.empty?
// 395:           test "brew", "fetch", "--formulae", "--retry",
// 396:                *@unchanged_dependencies
// 397:         end
// 398:
// 399:         changed_dependencies = dependencies - @unchanged_dependencies
// 400:         unless changed_dependencies.empty?
// 401:           test "brew", "fetch", "--formulae", "--retry", "--build-from-source",
// 402:                *changed_dependencies
// 403:
// 404:           ignore_failures = !args.test_default_formula? && changed_dependencies.any? do |dep|
// 405:             !bottled?(Formulary.factory(dep), no_older_versions: true)
// 406:           end
// 407:
// 408:           # Install changed dependencies as new bottles so we don't have
// 409:           # checksum problems. We have to install all `changed_dependencies`
// 410:           # in one `brew install` command to make sure they are installed in
// 411:           # the right order.
// 412:           test("brew", "install", "--formulae", "--build-from-source",
// 413:                named_args:      changed_dependencies,
// 414:                ignore_failures:)
// 415:           # Run postinstall on them because the tested formula might depend on
// 416:           # this step
// 417:           test "brew", "postinstall", named_args: changed_dependencies, ignore_failures:
// 418:         end
// 419:
// 420:         runtime_or_test_dependencies =
// 421:           Utils.safe_popen_read("brew", "deps", "--formula", "--include-test", formula_name)
// 422:                .split("\n")
// 423:         build_dependencies = dependencies - runtime_or_test_dependencies
// 424:         @unchanged_build_dependencies = build_dependencies - @testing_formulae
// 425:       end
// 426:
// 427:       sig { params(formula: Formula, new_formula: T.nilable(T::Boolean), args: Homebrew::Cmd::TestBotCmd::Args).void }
// 428:       def bottle_reinstall_formula(formula, new_formula, args:)
// 429:         unless build_bottle?(formula, args:)
// 430:           @bottle_filename = T.let(nil, T.nilable(Pathname))
// 431:           return
// 432:         end
// 433:
// 434:         root_url = args.root_url
// 435:
// 436:         # GitHub Releases url
// 437:         root_url ||= if tap.present? && !T.must(tap).core_tap? && !args.test_default_formula?
// 438:           "#{T.must(tap).default_remote}/releases/download/#{formula.name}-#{formula.pkg_version}"
// 439:         end
// 440:
// 441:         setup_bottle_sudo_purge!(args:)
// 442:
// 443:         bottle_args = ["--verbose", "--json", formula.full_name]
// 444:         bottle_args << "--keep-old" if args.keep_old? && !new_formula
// 445:         bottle_args << "--skip-relocation" if args.skip_relocation?
// 446:         bottle_args << "--force-core-tap" if args.test_default_formula?
// 447:         bottle_args << "--root-url=#{root_url}" if root_url
// 448:         bottle_args << "--only-json-tab" if args.only_json_tab?
// 449:
// 450:         verify_local_bottles
// 451:         test "brew", "bottle", *bottle_args
// 452:         bottle_step = steps.fetch(-1)
// 453:
// 454:         if !bottle_step.passed? || !bottle_step.output?
// 455:           failed formula.full_name, "bottling failed" unless args.dry_run?
// 456:           return
// 457:         end
// 458:
// 459:         @bottle_filename = Pathname.new(
// 460:           T.must(bottle_step.output)
// 461:            .gsub(%r{.*(\./\S+#{HOMEBREW_BOTTLES_EXTNAME_REGEX}).*}om, '\1'),
// 462:         )
// 463:         @bottle_json_filename = Pathname.new(
// 464:           @bottle_filename.to_s.gsub(/\.(\d+\.)?tar\.gz$/, ".json"),
// 465:         )
// 466:
// 467:         @bottle_checksums[@bottle_filename.realpath] = @bottle_filename.sha256
// 468:         @bottle_checksums[@bottle_json_filename.realpath] = @bottle_json_filename.sha256
// 469:
// 470:         @bottle_output_path.write(bottle_step.output, mode: "a")
// 471:
// 472:         bottle_merge_args =
// 473:           ["--merge", "--write", "--no-commit", "--no-all-checks", @bottle_json_filename.to_s]
// 474:         bottle_merge_args << "--keep-old" if args.keep_old? && !new_formula
// 475:
// 476:         test "brew", "bottle", *bottle_merge_args
// 477:         annotate_missing_all_bottle(formula) if steps.fetch(-1).passed?
// 478:         test "brew", "uninstall", "--formula", "--force", "--ignore-dependencies", formula.full_name
// 479:
// 480:         @testing_formulae.delete(formula.name)
// 481:
// 482:         unless @unchanged_build_dependencies.empty?
// 483:           test "brew", "uninstall", "--formulae", "--force", "--ignore-dependencies", *@unchanged_build_dependencies
// 484:           @unchanged_dependencies -= @unchanged_build_dependencies
// 485:         end
// 486:
// 487:         verify_attestations = if formula.name == "gh"
// 488:           nil
// 489:         else
// 490:           ENV.fetch("HOMEBREW_VERIFY_ATTESTATIONS", nil)
// 491:         end
// 492:         test "brew", "install", "--only-dependencies", @bottle_filename.to_s,
// 493:              env: { "HOMEBREW_VERIFY_ATTESTATIONS" => verify_attestations }
// 494:         test "brew", "install", @bottle_filename.to_s,
// 495:              env: { "HOMEBREW_VERIFY_ATTESTATIONS" => verify_attestations }
// 496:       end
// 497:
// 498:       sig { params(formula: Formula, args: Homebrew::Cmd::TestBotCmd::Args).returns(T::Boolean) }
// 499:       def build_bottle?(formula, args:)
// 500:         # Build and runtime dependencies must be bottled on the current OS,
// 501:         # but accept an older compatible bottle for test dependencies.
// 502:         return false if formula.deps.any? do |dep|
// 503:           !bottled_or_built?(
// 504:             dep.to_formula,
// 505:             @built_formulae - @skipped_or_failed_formulae,
// 506:             no_older_versions: !dep.test?,
// 507:           )
// 508:         end
// 509:
// 510:         !args.build_from_source?
// 511:       end
// 512:
// 513:       sig { params(args: Homebrew::Cmd::TestBotCmd::Args).void }
// 514:       def setup_bottle_sudo_purge!(args:); end
// 515:
// 516:       sig { params(_formula: Formula, dependencies: T::Array[Dependency]).returns(T::Array[String]) }
// 517:       def recursive_runtime_dependency_names(_formula, dependencies)
// 518:         dependencies.each_with_object(Set.new) do |dep, set|
// 519:           dep_f = dep.to_formula
// 520:           set.add(dep_f.full_name)
// 521:           set.merge(dep_f.runtime_dependencies(read_from_tab: false, undeclared: false).map(&:name))
// 522:         end.to_a
// 523:       end
// 524:
// 525:       sig {
// 526:         params(formula_name: String, bottle_dir: Pathname)
// 527:           .returns(T::Hash[String, T::Hash[String, T.anything]])
// 528:       }
// 529:       def local_bottle_tag_hashes(formula_name, bottle_dir:)
// 530:         tag_hashes = T.let({}, T::Hash[String, T::Hash[String, T.anything]])
// 531:         bottle_glob(formula_name, bottle_dir, ".json", bottle_tag: "*").each do |local_bottle_json|
// 532:           bottle_hash = JSON.parse(local_bottle_json.read).dig(formula_name, "bottle")
// 533:           next unless bottle_hash.is_a?(Hash)
// 534:
// 535:           cellar = bottle_hash["cellar"]
// 536:           tags = bottle_hash["tags"]
// 537:           next unless tags.is_a?(Hash)
// 538:
// 539:           tags.each do |tag, tag_hash|
// 540:             next if !tag.is_a?(String) || !tag_hash.is_a?(Hash)
// 541:
// 542:             tag_hashes[tag] = tag_hash.merge("cellar" => tag_hash["cellar"] || cellar)
// 543:           end
// 544:         end
// 545:         tag_hashes
// 546:       end
// 547:
// 548:       sig { params(formula: Formula).void }
// 549:       def livecheck(formula)
// 550:         return unless formula.livecheck_defined?
// 551:         return if formula.livecheck.skip?
// 552:
// 553:         livecheck_step = test "brew", "livecheck", "--autobump", "--formula",
// 554:                               "--json", "--full-name", formula.full_name
// 555:
// 556:         return if livecheck_step.failed?
// 557:         return unless livecheck_step.output?
// 558:
// 559:         livecheck_info = JSON.parse(T.must(livecheck_step.output)).first
// 560:
// 561:         if livecheck_info["status"] == "error"
// 562:           error_msg = if livecheck_info["messages"].present? && livecheck_info["messages"].length.positive?
// 563:             livecheck_info["messages"].join("\n")
// 564:           else
// 565:             # An error message should always be provided alongside an "error"
// 566:             # status but this is a failsafe
// 567:             "Error encountered (no message provided)"
// 568:           end
// 569:
// 570:           if GitHub::Actions.env_set?
// 571:             puts GitHub::Actions::Annotation.new(
// 572:               :error,
// 573:               error_msg,
// 574:               title: "#{formula}: livecheck error",
// 575:               file:  formula.path.to_s.delete_prefix("#{repository}/"),
// 576:             )
// 577:           else
// 578:             onoe error_msg
// 579:           end
// 580:         end
// 581:
// 582:         # `status` and `version` are mutually exclusive (the presence of one
// 583:         # indicates the absence of the other)
// 584:         return if livecheck_info["status"].present?
// 585:
// 586:         return if livecheck_info["version"]["newer_than_upstream"] != true
// 587:
// 588:         current_version = livecheck_info["version"]["current"]
// 589:         latest_version = livecheck_info["version"]["latest"]
// 590:
// 591:         newer_than_upstream_msg = if current_version.present? && latest_version.present?
// 592:           "The formula version (#{current_version}) is newer than the " \
// 593:             "version from `brew livecheck` (#{latest_version})."
// 594:         else
// 595:           "The formula version is newer than the version from `brew livecheck`."
// 596:         end
// 597:
// 598:         if GitHub::Actions.env_set?
// 599:           puts GitHub::Actions::Annotation.new(
// 600:             :warning,
// 601:             newer_than_upstream_msg,
// 602:             title: "#{formula}: Formula version newer than livecheck",
// 603:             file:  formula.path.to_s.delete_prefix("#{repository}/"),
// 604:           )
// 605:         else
// 606:           opoo newer_than_upstream_msg
// 607:         end
// 608:       end
// 609:
// 610:       sig { params(formula_name: String, args: Homebrew::Cmd::TestBotCmd::Args).void }
// 611:       def formula!(formula_name, args:)
// 612:         cleanup_during!(@testing_formulae, args:)
// 613:
// 614:         test_header(:Formulae, method: "formula!(#{formula_name})")
// 615:
// 616:         formula = Formulary.factory(formula_name)
// 617:         begin
// 618:           if formula.disabled?
// 619:             skipped formula_name, "#{formula.full_name} has been disabled!"
// 620:             return
// 621:           end
// 622:
// 623:           new_formula = @added_formulae.include?(formula_name)
// 624:           annotate_added_dependencies(formula) unless new_formula
// 625:
// 626:           test "brew", "deps", "--tree", "--prune", "--annotate", "--include-build", "--include-test",
// 627:                named_args: formula_name
// 628:
// 629:           deps_without_compatible_bottles = formula.deps.map(&:to_formula)
// 630:           deps_without_compatible_bottles.reject! do |dep|
// 631:             bottled_or_built?(dep, @built_formulae - @skipped_or_failed_formulae)
// 632:           end
// 633:           bottled_on_current_version = bottled?(formula, no_older_versions: true)
// 634:
// 635:           if deps_without_compatible_bottles.present? && !bottled_on_current_version
// 636:             message = <<~EOS
// 637:               #{formula_name} has dependencies without compatible bottles:
// 638:                 #{deps_without_compatible_bottles * "\n  "}
// 639:             EOS
// 640:             skipped formula_name, message
// 641:             return
// 642:           end
// 643:
// 644:           ignore_failures = !args.test_default_formula? && !bottled_on_current_version && !new_formula
// 645:
// 646:           deps = []
// 647:           reqs = []
// 648:
// 649:           build_flag = if build_bottle?(formula, args:)
// 650:             "--build-bottle"
// 651:           else
// 652:             if GitHub::Actions.env_set?
// 653:               puts GitHub::Actions::Annotation.new(
// 654:                 :warning,
// 655:                 "#{formula} has unbottled dependencies, so a bottle will not be built.",
// 656:                 title: "No bottle built for #{formula}!",
// 657:                 file:  formula.path.to_s.delete_prefix("#{repository}/"),
// 658:               )
// 659:             else
// 660:               onoe "Not building a bottle for #{formula} because it has unbottled dependencies."
// 661:             end
// 662:
// 663:             skipped formula_name, "No bottle built."
// 664:             return
// 665:           end
// 666:
// 667:           # Online checks are a bit flaky and less useful for PRs that modify multiple formulae.
// 668:           skip_online_checks = args.skip_online_checks? || (@testing_formulae_count > 5)
// 669:
// 670:           fetch_args = [formula_name]
// 671:           fetch_args << build_flag
// 672:           fetch_args << "--force" if cleanup?(args)
// 673:
// 674:           audit_args = [formula_name]
// 675:           audit_args << "--online" unless skip_online_checks
// 676:           if new_formula
// 677:             if !args.skip_new?
// 678:               audit_args << "--new"
// 679:             elsif !args.skip_new_strict?
// 680:               audit_args << "--strict"
// 681:             end
// 682:           else
// 683:             audit_args << "--git" << "--skip-style"
// 684:             audit_args << "--except=unconfirmed_checksum_change" if args.skip_checksum_only_audit?
// 685:             audit_args << "--except=stable_version" if args.skip_stable_version_audit?
// 686:             audit_args << "--except=revision" if args.skip_revision_audit?
// 687:           end
// 688:
// 689:           # This needs to be done before any network operation.
// 690:           install_ca_certificates_if_needed
// 691:
// 692:           if (messages = unsatisfied_requirements_messages(formula))
// 693:             test "brew", "fetch", "--formula", "--retry", *fetch_args
// 694:             test "brew", "audit", "--formula", *audit_args
// 695:
// 696:             skipped formula_name, messages
// 697:             return
// 698:           end
// 699:
// 700:           deps |= formula.deps.to_a.reject(&:optional?)
// 701:           reqs |= formula.requirements.to_a.reject(&:optional?)
// 702:
// 703:           install_curl_if_needed(formula)
// 704:           install_mercurial_if_needed(deps, reqs)
// 705:           install_subversion_if_needed(deps, reqs)
// 706:           setup_formulae_deps_instances(formula, formula_name, args:)
// 707:
// 708:           test "brew", "uninstall", "--formula", "--force", formula_name if formula.latest_version_installed?
// 709:
// 710:           install_args = ["--verbose", "--formula"]
// 711:           install_args << build_flag
// 712:
// 713:           # We can't verify attestations if we're building `gh`.
// 714:           verify_attestations = if formula_name == "gh"
// 715:             nil
// 716:           else
// 717:             ENV.fetch("HOMEBREW_VERIFY_ATTESTATIONS", nil)
// 718:           end
// 719:           # Don't care about e.g. bottle failures for dependencies.
// 720:           test "brew", "install", "--only-dependencies", *install_args, formula_name,
// 721:                env: { "HOMEBREW_DEVELOPER"           => nil,
// 722:                       "HOMEBREW_VERIFY_ATTESTATIONS" => verify_attestations }
// 723:
// 724:           info_header "Starting tests for #{formula_name}"
// 725:
// 726:           test "brew", "fetch", "--formula", "--retry", *fetch_args
// 727:
// 728:           env = {}
// 729:           env["HOMEBREW_GIT_PATH"] = nil if deps.any? do |d|
// 730:             d.name == "git" && (!d.test? || d.build?)
// 731:           end
// 732:
// 733:           install_step_passed = formula_installed_from_bottle =
// 734:             artifact_cache_valid?(formula) &&
// 735:             verify_local_bottles && # Checking the artifact cache loads formulae, so do this check second.
// 736:             install_formula_from_bottle!(formula_name,
// 737:                                          bottle_dir:                  artifact_cache,
// 738:                                          testing_formulae_dependents: false,
// 739:                                          dry_run:                     args.dry_run?)
// 740:
// 741:           install_step_passed ||= begin
// 742:             test("brew", "install", *install_args,
// 743:                  named_args:      formula_name,
// 744:                  env:             env.merge({ "HOMEBREW_DEVELOPER"           => nil,
// 745:                                               "HOMEBREW_VERIFY_ATTESTATIONS" => verify_attestations }),
// 746:                  ignore_failures:, report_analytics: true)
// 747:             steps.fetch(-1).passed?
// 748:           end
// 749:
// 750:           livecheck(formula) if !args.skip_livecheck? && !skip_online_checks
// 751:
// 752:           test "brew", "style", "--formula", formula_name, report_analytics: true
// 753:           test "brew", "audit", "--formula", *audit_args, report_analytics: true unless formula.deprecated?
// 754:           unless install_step_passed
// 755:             if ignore_failures
// 756:               skipped formula_name, "install failed"
// 757:             else
// 758:               failed formula_name, "install failed"
// 759:             end
// 760:
// 761:             return
// 762:           end
// 763:
// 764:           if formula_installed_from_bottle
// 765:             moved_artifacts = bottle_glob(formula_name, artifact_cache, ".{json,tar.gz}").map(&:realpath)
// 766:             Pathname.pwd.install moved_artifacts
// 767:
// 768:             moved_artifacts.each do |old_location|
// 769:               new_location = old_location.basename.realpath
// 770:               @bottle_checksums[new_location] = @bottle_checksums.fetch(old_location)
// 771:               @bottle_checksums.delete(old_location)
// 772:             end
// 773:           else
// 774:             bottle_reinstall_formula(formula, new_formula, args:)
// 775:           end
// 776:           @built_formulae << formula.full_name
// 777:           test("brew", "linkage", "--test", named_args: formula_name, ignore_failures:, report_analytics: true)
// 778:           failed_linkage_or_test_messages ||= []
// 779:           failed_linkage_or_test_messages << "linkage failed" unless steps.fetch(-1).passed?
// 780:
// 781:           if steps.fetch(-1).passed?
// 782:             # Check for opportunistic linkage. Ignore failures because
// 783:             # they can be unavoidable but we still want to know about them.
// 784:             test "brew", "linkage", "--cached", "--test", "--strict",
// 785:                  named_args:      formula_name,
// 786:                  ignore_failures: !args.test_default_formula?
// 787:           end
// 788:
// 789:           test "brew", "linkage", "--cached", formula_name
// 790:           @linkage_output_path.write(Formatter.headline(steps.fetch(-1).command_trimmed, color: :blue), mode: "a")
// 791:           @linkage_output_path.write("\n", mode: "a")
// 792:           @linkage_output_path.write(steps.fetch(-1).output, mode: "a")
// 793:
// 794:           test "brew", "install", "--formula", "--only-dependencies", "--include-test", formula_name
// 795:
// 796:           if formula.test_defined?
// 797:             env = {}
// 798:             env["HOMEBREW_GIT_PATH"] = nil if deps.any? do |d|
// 799:               d.name == "git" && (!d.build? || d.test?)
// 800:             end
// 801:
// 802:             # Intentionally not passing --retry here to avoid papering over
// 803:             # flaky tests when a formula isn't being pulled in as a dependent.
// 804:             test(
// 805:               "brew", "test", "--verbose", named_args: formula_name, env:, ignore_failures:, report_analytics: true
// 806:             )
// 807:             failed_linkage_or_test_messages << "test failed" unless steps.fetch(-1).passed?
// 808:           end
// 809:
// 810:           # Move bottle and don't test dependents if the formula linkage or test failed.
// 811:           if failed_linkage_or_test_messages.present?
// 812:             if @bottle_filename
// 813:               failed_dir = @bottle_filename.dirname/"failed"
// 814:               moved_artifacts = [@bottle_filename, T.must(@bottle_json_filename)].map(&:realpath)
// 815:               failed_dir.install moved_artifacts
// 816:
// 817:               moved_artifacts.each do |old_location|
// 818:                 new_location = (failed_dir/old_location.basename).realpath
// 819:                 @bottle_checksums[new_location] = @bottle_checksums.fetch(old_location)
// 820:                 @bottle_checksums.delete(old_location)
// 821:               end
// 822:             end
// 823:
// 824:             if ignore_failures
// 825:               skipped formula_name, failed_linkage_or_test_messages.join(", ")
// 826:             else
// 827:               failed formula_name, failed_linkage_or_test_messages.join(", ")
// 828:             end
// 829:           end
// 830:         ensure
// 831:           @tested_formulae_count += 1
// 832:           cleanup_bottle_etc_var(formula) if cleanup?(args)
// 833:
// 834:           if @unchanged_dependencies.present?
// 835:             test "brew", "uninstall", "--formulae", "--force", "--ignore-dependencies", *@unchanged_dependencies
// 836:           end
// 837:         end
// 838:       end
// 839:
// 840:       sig { params(formula_name: String, args: Homebrew::Cmd::TestBotCmd::Args).void }
// 841:       def portable_formula!(formula_name, args:)
// 842:         test_header(:Formulae, method: "portable_formula!(#{formula_name})")
// 843:
// 844:         install_ca_certificates_if_needed
// 845:
// 846:         # Can't resolve attestations properly on old macOS versions.
// 847:         ENV["HOMEBREW_NO_VERIFY_ATTESTATIONS"] = "1"
// 848:
// 849:         # On Linux, install glibc and linux-headers from bottles and don't install their build dependencies.
// 850:         bottled_dep_allowlist = /\A(?:glibc|linux-headers)@/
// 851:         deps = Dependency.expand(Formula[formula_name],
// 852:                                  cache_key: "portable-package-#{formula_name}") do |_dependent, dep|
// 853:           next Dependable::PRUNE if dep.test? || dep.optional?
// 854:
// 855:           next unless bottled_dep_allowlist.match?(dep.name)
// 856:
// 857:           next Dependable::KEEP_BUT_PRUNE_RECURSIVE_DEPS
// 858:         end.map(&:name)
// 859:
// 860:         bottled_deps, deps = deps.partition { |dep| bottled_dep_allowlist.match?(dep) }
// 861:
// 862:         # Install bottled dependencies.
// 863:         test "brew", "install", *bottled_deps if bottled_deps.present?
// 864:
// 865:         # Build bottles for all other dependencies.
// 866:         test "brew", "install", "--build-bottle", *deps
// 867:
// 868:         # Build main bottle.
// 869:         test "brew", "install", "--build-bottle", formula_name
// 870:         test "brew", "uninstall", "--force", "--ignore-dependencies", *deps
// 871:         test "brew", "test", formula_name
// 872:         test "brew", "linkage", formula_name
// 873:         test "brew", "bottle", "--skip-relocation", "--json", "--no-rebuild", formula_name
// 874:
// 875:         # We only do full testing on `portable-ruby` itself.
// 876:         return if formula_name != "portable-ruby"
// 877:         return if args.dry_run?
// 878:         return unless integration_test_portable_ruby?
// 879:
// 880:         bottle_file = bottle_glob(formula_name).first
// 881:         if bottle_file.nil?
// 882:           failed formula_name, "no bottle file found for portable-ruby validation"
// 883:           return
// 884:         end
// 885:
// 886:         filename = bottle_file.basename.to_s
// 887:         _, tag_string, = Utils::Bottles.extname_tag_rebuild(filename)
// 888:         if tag_string.blank?
// 889:           failed formula_name, "could not parse bottle filename #{filename}"
// 890:           return
// 891:         end
// 892:
// 893:         pkg_version = filename.delete_prefix("portable-ruby--")
// 894:                               .sub(/\.#{Regexp.escape(tag_string)}\.bottle.*\.tar\.gz\z/, "")
// 895:         if pkg_version.empty?
// 896:           failed formula_name, "could not parse portable-ruby version from #{filename}"
// 897:           return
// 898:         end
// 899:
// 900:         tag_symbol = tag_string.to_sym
// 901:         bottle_tag = Utils::Bottles::Tag.from_symbol(tag_symbol)
// 902:         sha256 = bottle_file.sha256
// 903:         version = pkg_version.split("_").first.to_s
// 904:
// 905:         vendor_dir = HOMEBREW_LIBRARY_PATH/"vendor"
// 906:         (vendor_dir/"portable-ruby-version").atomic_write("#{pkg_version}\n")
// 907:         (HOMEBREW_LIBRARY_PATH/".ruby-version").atomic_write("#{version}\n")
// 908:         os = bottle_tag.linux? ? "linux" : "darwin"
// 909:         platform_file = vendor_dir/"portable-ruby-#{bottle_tag.standardized_arch}-#{os}"
// 910:         platform_file.atomic_write("ruby_TAG=#{tag_symbol}\nruby_SHA=#{sha256}\n")
// 911:
// 912:         # Seed `HOMEBREW_CACHE` so `brew vendor-install ruby` finds the just-built
// 913:         # bottle locally instead of trying to download it.
// 914:         HOMEBREW_CACHE.mkpath
// 915:         FileUtils.cp(bottle_file, HOMEBREW_CACHE/"portable-ruby-#{pkg_version}.#{tag_symbol}.bottle.tar.gz")
// 916:
// 917:         test "brew", "vendor-install", "ruby"
// 918:
// 919:         no_github_actions_env = { "GITHUB_ACTIONS" => nil }
// 920:         bundler_version = Utils::PortableRuby.sync_bundler_version!(pkg_version)
// 921:         test "brew", "vendor-gems", "--no-commit", "--update=--ruby,--bundler=#{bundler_version}",
// 922:              env: no_github_actions_env
// 923:         test "brew", "typecheck", "--update"
// 924:
// 925:         # Run the checks that gate a Homebrew/brew pull request.
// 926:         test "brew", "style" unless OS.not_tier_one_configuration?
// 927:         test "brew", "typecheck"
// 928:         test "brew", "install-bundler-gems", "--groups=all"
// 929:         test "brew", "vendor-gems", "--non-bundler-gems", "--no-commit",
// 930:              env: no_github_actions_env
// 931:         if OS.not_tier_one_configuration?
// 932:           test "brew", "tests", "--online", "--coverage", "--only=cask,formula"
// 933:         else
// 934:           test "brew", "tests", "--online", "--coverage"
// 935:         end
// 936:         test "brew", "update-test"
// 937:         test "brew", "update-test", "--to-tag"
// 938:         test "brew", "update-test", "--commit=HEAD"
// 939:
// 940:         require "mktemp"
// 941:         Mktemp.new("homebrew-test-bot").run do |_|
// 942:           test "brew", "test-bot", "--only-formulae", "--only-json-tab", "--test-default-formula",
// 943:                env: no_github_actions_env
// 944:         end
// 945:       end
// 946:
// 947:       sig { params(formula_name: String).void }
// 948:       def deleted_formula!(formula_name)
// 949:         test_header(:Formulae, method: "deleted_formula!(#{formula_name})")
// 950:
// 951:         test "brew", "uses",
// 952:              "--formula",
// 953:              "--include-build",
// 954:              "--include-optional",
// 955:              "--include-test",
// 956:              formula_name,
// 957:              env: require_current_tap_trust_env
// 958:       end
// 959:
// 960:       sig { returns(T::Boolean) }
// 961:       def integration_test_portable_ruby? = true
// 962:     end
// 963:   end
// 964: end
