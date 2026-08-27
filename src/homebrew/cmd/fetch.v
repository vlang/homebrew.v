module cmd

import brew_runtime

// Translated from Homebrew/brew `cmd/fetch.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 79.
pub fn ruby_fetch_l79_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `cask_downloads(cask)` at line 176.
pub fn ruby_fetch_l176_d2_cask_downloads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cask_downloads', ...args)
}

// Ruby method `enqueue_api_formula_bottles?` at line 239.
pub fn ruby_fetch_l239_d3_enqueue_api_formula_bottles(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('enqueue_api_formula_bottles?', ...args)
}

// Ruby method `enqueue_api_cask_downloads?` at line 282.
pub fn ruby_fetch_l282_d4_enqueue_api_cask_downloads(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('enqueue_api_cask_downloads?', ...args)
}

// Ruby method `api_fetchable?` at line 316.
pub fn ruby_fetch_l316_d5_api_fetchable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('api_fetchable?', ...args)
}

// Ruby method `api_fetch_names(regex:, capture:, named:, aliases:, renames:)` at line 333.
pub fn ruby_fetch_l333_d6_api_fetch_names(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('api_fetch_names', ...args)
}

// Ruby method `retries` at line 352.
pub fn ruby_fetch_l352_d7_retries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('retries', ...args)
}

// Ruby method `download_queue` at line 357.
pub fn ruby_fetch_l357_d8_download_queue(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('download_queue', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "formula"
// 6: require "fetch"
// 7: require "api/cask_download"
// 8: require "api/formula_bottle"
// 9: require "cask/config"
// 10: require "cask/download"
// 11: require "download_queue"
// 12:
// 13: module Homebrew
// 14:   module Cmd
// 15:     class FetchCmd < AbstractCommand
// 16:       include Fetch
// 17:
// 18:       FETCH_MAX_TRIES = 5
// 19:
// 20:       cmd_args do
// 21:         description <<~EOS
// 22:           Download a bottle (if available) or source packages for <formula>e
// 23:           and binaries for <cask>s. For files, also print SHA-256 checksums.
// 24:         EOS
// 25:         flag   "--os=",
// 26:                description: "Download for the given operating system. " \
// 27:                             "(Pass `all` to download for all operating systems.)"
// 28:         flag   "--arch=",
// 29:                description: "Download for the given CPU architecture. " \
// 30:                             "(Pass `all` to download for all architectures.)"
// 31:         switch "--all-platforms",
// 32:                description: "Download for every supported operating system and architecture, plus each " \
// 33:                             "language for <cask>s, fetching each distinct URL once."
// 34:         flag   "--bottle-tag=",
// 35:                description: "Download a bottle for given tag."
// 36:         switch "--HEAD",
// 37:                description: "Fetch HEAD version instead of stable version."
// 38:         switch "-f", "--force",
// 39:                description: "Remove a previously cached version and re-fetch."
// 40:         switch "-v", "--verbose",
// 41:                description: "Do a verbose VCS checkout, if the URL represents a VCS. This is useful for " \
// 42:                             "seeing if an existing VCS cache has been updated."
// 43:         switch "--retry",
// 44:                description: "Retry if downloading fails or re-download if the checksum of a previously cached " \
// 45:                             "version no longer matches. Tries at most #{FETCH_MAX_TRIES} times with " \
// 46:                             "exponential backoff."
// 47:         switch "--deps",
// 48:                description: "Also download dependencies for any listed <formula>."
// 49:         switch "-s", "--build-from-source",
// 50:                description: "Download source packages rather than a bottle."
// 51:         switch "--build-bottle",
// 52:                description: "Download source packages (for eventual bottling) rather than a bottle."
// 53:         switch "--force-bottle",
// 54:                description: "Download a bottle if it exists for the current or newest version of macOS, " \
// 55:                             "even if it would not be used during installation."
// 56:         switch "--formula", "--formulae",
// 57:                description: "Treat all named arguments as formulae."
// 58:         switch "--cask", "--casks",
// 59:                description: "Treat all named arguments as casks."
// 60:
// 61:         conflicts "--build-from-source", "--build-bottle", "--force-bottle", "--bottle-tag"
// 62:         conflicts "--cask", "--HEAD"
// 63:         conflicts "--cask", "--deps"
// 64:         conflicts "--cask", "-s"
// 65:         conflicts "--cask", "--build-bottle"
// 66:         conflicts "--cask", "--force-bottle"
// 67:         conflicts "--cask", "--bottle-tag"
// 68:         conflicts "--formula", "--cask"
// 69:         conflicts "--os", "--bottle-tag"
// 70:         conflicts "--arch", "--bottle-tag"
// 71:         conflicts "--all-platforms", "--os"
// 72:         conflicts "--all-platforms", "--arch"
// 73:         conflicts "--all-platforms", "--bottle-tag"
// 74:
// 75:         named_args [:formula, :cask], min: 1
// 76:       end
// 77:
// 78:       sig { override.void }
// 79:       def run
// 80:         Formulary.enable_factory_cache!
// 81:
// 82:         if enqueue_api_formula_bottles? || enqueue_api_cask_downloads?
// 83:           download_queue.fetch
// 84:           return
// 85:         end
// 86:
// 87:         bucket = if args.deps?
// 88:           args.named.to_formulae_and_casks.flat_map do |formula_or_cask|
// 89:             case formula_or_cask
// 90:             when Formula
// 91:               formula = formula_or_cask
// 92:               [formula, *formula.recursive_dependencies.map(&:to_formula)]
// 93:             else
// 94:               formula_or_cask
// 95:             end
// 96:           end
// 97:         else
// 98:           args.named.to_formulae_and_casks
// 99:         end.uniq
// 100:
// 101:         os_arch_combinations = args.os_arch_combinations
// 102:
// 103:         puts "Fetching: #{bucket * ", "}" if bucket.size > 1
// 104:         bucket.each do |formula_or_cask|
// 105:           case formula_or_cask
// 106:           when Formula
// 107:             formula = formula_or_cask
// 108:             ref = formula.reloadable_ref
// 109:
// 110:             os_arch_combinations.each do |os, arch|
// 111:               SimulateSystem.with(os:, arch:) do
// 112:                 formula = Formulary.factory(ref, args.HEAD? ? :head : :stable)
// 113:
// 114:                 formula.print_tap_action verb: "Fetching"
// 115:
// 116:                 fetched_bottle = false
// 117:                 if fetch_bottle?(
// 118:                   formula,
// 119:                   force_bottle:               args.force_bottle?,
// 120:                   bottle_tag:                 args.bottle_tag&.to_sym,
// 121:                   build_from_source_formulae: args.build_from_source_formulae,
// 122:                   os:                         args.os&.to_sym,
// 123:                   arch:                       args.arch&.to_sym,
// 124:                 )
// 125:                   begin
// 126:                     formula.clear_cache if args.force?
// 127:
// 128:                     bottle_tag = Utils::Bottles::Tag.from_arg(args.bottle_tag&.to_sym, os:, arch:)
// 129:
// 130:                     bottle = formula.bottle_for_tag(bottle_tag)
// 131:
// 132:                     if bottle.nil?
// 133:                       opoo "Bottle for tag #{bottle_tag.to_sym.inspect} is unavailable."
// 134:                       next
// 135:                     end
// 136:
// 137:                     if (manifest_resource = bottle.github_packages_manifest_resource)
// 138:                       download_queue.enqueue(manifest_resource)
// 139:                     end
// 140:                     download_queue.enqueue(bottle)
// 141:                   rescue Interrupt
// 142:                     raise
// 143:                   rescue => e
// 144:                     raise if Homebrew::EnvConfig.developer?
// 145:
// 146:                     fetched_bottle = false
// 147:                     onoe e.message
// 148:                     opoo "Bottle fetch failed, fetching the source instead."
// 149:                   else
// 150:                     fetched_bottle = true
// 151:                   end
// 152:                 end
// 153:
// 154:                 next if fetched_bottle
// 155:
// 156:                 if (resource = formula.resource)
// 157:                   download_queue.enqueue(resource)
// 158:                 end
// 159:
// 160:                 formula.enqueue_resources_and_patches(download_queue:)
// 161:               end
// 162:             end
// 163:           when Cask::Cask
// 164:             cask_downloads(formula_or_cask).each { |download| download_queue.enqueue(download) }
// 165:           else
// 166:             odie "Invalid formula or cask: #{formula_or_cask}"
// 167:           end
// 168:         end
// 169:
// 170:         download_queue.fetch
// 171:       ensure
// 172:         download_queue.shutdown
// 173:       end
// 174:
// 175:       sig { params(cask: Cask::Cask).returns(T::Array[Cask::Download]) }
// 176:       def cask_downloads(cask)
// 177:         ref = cask.reloadable_ref
// 178:
// 179:         if args.all_platforms? && cask.loaded_from_api?
// 180:           opoo "Cask #{cask} was loaded from the API; cannot fetch all operating system and " \
// 181:                "architecture variants. Set `HOMEBREW_NO_INSTALL_FROM_API=1` to fetch them all."
// 182:         end
// 183:
// 184:         # With `--all-platforms`, a cask without `on_system` blocks resolves
// 185:         # identically everywhere, so one combination covers the whole matrix.
// 186:         cask_combinations = args.os_arch_combinations
// 187:         cask_combinations = cask_combinations.first(1) if args.all_platforms? && !cask.on_system_blocks_exist?
// 188:
// 189:         downloads = T.let([], T::Array[Cask::Download])
// 190:         enqueued_urls = Set.new
// 191:
// 192:         cask_combinations.each do |os, arch|
// 193:           SimulateSystem.with(os:, arch:) do
// 194:             loaded_cask = begin
// 195:               Cask::CaskLoader.load(ref)
// 196:             rescue Cask::CaskInvalidError, Cask::CaskUnreadableError
// 197:               raise unless cask.on_system_blocks_exist?
// 198:             end
// 199:             if loaded_cask.nil? || loaded_cask.depends_on.arch&.none? { |dep_arch| dep_arch[:type] == arch }
// 200:               opoo "Cask #{cask} is not supported on os #{os} and arch #{arch}"
// 201:               next
// 202:             end
// 203:
// 204:             languages = (loaded_cask.languages if args.all_platforms?)
// 205:             languages = [nil] if languages.blank?
// 206:
// 207:             languages.each do |language|
// 208:               localized_cask = loaded_cask
// 209:               if language
// 210:                 # Reload per language: `Cask::Download` reads `sha256`/`url`
// 211:                 # lazily, so each download needs its own cask instance.
// 212:                 localized_cask = Cask::CaskLoader.load(ref)
// 213:                 localized_cask.config = localized_cask.config.merge(
// 214:                   Cask::Config.new(explicit: { languages: [language] }),
// 215:                 )
// 216:               end
// 217:
// 218:               if localized_cask.url.nil? || localized_cask.sha256.nil?
// 219:                 opoo "Cask #{cask} is not supported on os #{os} and arch #{arch}"
// 220:                 next
// 221:               end
// 222:
// 223:               next unless enqueued_urls.add?(localized_cask.url.to_s)
// 224:
// 225:               downloads << Cask::Download.new(
// 226:                 localized_cask,
// 227:                 require_sha: Homebrew::EnvConfig.cask_opts_require_sha?,
// 228:               )
// 229:             end
// 230:           end
// 231:         end
// 232:
// 233:         downloads
// 234:       end
// 235:
// 236:       private
// 237:
// 238:       sig { returns(T::Boolean) }
// 239:       def enqueue_api_formula_bottles?
// 240:         return false unless api_fetchable?
// 241:         return false if args.only_formula_or_cask == :cask
// 242:         return false if args.deps? || args.HEAD?
// 243:         return false if args.build_from_source? || args.build_bottle?
// 244:         return false if args.bottle_tag.present?
// 245:
// 246:         names = api_fetch_names(
// 247:           regex:   HOMEBREW_DEFAULT_TAP_FORMULA_REGEX,
// 248:           capture: :name,
// 249:           named:   ->(name) { Homebrew::API::Internal.formula_name?(name) },
// 250:           aliases: Homebrew::API::Internal.formula_aliases,
// 251:           renames: Homebrew::API::Internal.formula_renames,
// 252:         )
// 253:         return false if names.nil?
// 254:
// 255:         bottles = T.let([], T::Array[[String, Bottle]])
// 256:         bottle_tag = Utils::Bottles.tag
// 257:         names.each do |name|
// 258:           formula_struct = Homebrew::API::Internal.formula_struct(name)
// 259:           return false if formula_struct.pour_bottle?
// 260:
// 261:           bottle = Homebrew::API::FormulaBottle.bottle(name:, formula_struct:, bottle_tag:)
// 262:           return false if bottle.nil?
// 263:           return false if !args.force_bottle? && !bottle.compatible_locations?
// 264:
// 265:           bottles << [name, bottle]
// 266:         end
// 267:
// 268:         puts "Fetching: #{names * ", "}" if names.size > 1
// 269:         bottles.each do |name, bottle|
// 270:           ohai "Fetching #{name} from #{CoreTap.instance}"
// 271:           bottle.clear_cache if args.force?
// 272:
// 273:           if (manifest_resource = bottle.github_packages_manifest_resource)
// 274:             download_queue.enqueue(manifest_resource)
// 275:           end
// 276:           download_queue.enqueue(bottle)
// 277:         end
// 278:         true
// 279:       end
// 280:
// 281:       sig { returns(T::Boolean) }
// 282:       def enqueue_api_cask_downloads?
// 283:         return false unless api_fetchable?
// 284:         return false if args.only_formula_or_cask != :cask
// 285:
// 286:         tokens = api_fetch_names(
// 287:           regex:   HOMEBREW_DEFAULT_TAP_CASK_REGEX,
// 288:           capture: :token,
// 289:           named:   ->(token) { Homebrew::API::Internal.cask_name?(token) },
// 290:           aliases: {},
// 291:           renames: Homebrew::API::Internal.cask_renames,
// 292:         )
// 293:         return false if tokens.nil?
// 294:
// 295:         downloads = T.let([], T::Array[[String, Cask::Download]])
// 296:         tokens.each do |token|
// 297:           download = Homebrew::API::CaskDownload.download(
// 298:             token:,
// 299:             cask_struct: Homebrew::API::Internal.cask_struct(token),
// 300:             require_sha: Homebrew::EnvConfig.cask_opts_require_sha?,
// 301:           )
// 302:           return false if download.nil?
// 303:
// 304:           downloads << [token, download]
// 305:         end
// 306:
// 307:         puts "Fetching: #{tokens * ", "}" if tokens.size > 1
// 308:         downloads.each do |token, download|
// 309:           ohai "Fetching #{token} from #{CoreCaskTap.instance}"
// 310:           download_queue.enqueue(download)
// 311:         end
// 312:         true
// 313:       end
// 314:
// 315:       sig { returns(T::Boolean) }
// 316:       def api_fetchable?
// 317:         return false if Homebrew::EnvConfig.no_install_from_api?
// 318:         return false if args.all_platforms? || args.os.present? || args.arch.present?
// 319:         return false if ENV["HOMEBREW_TEST_GENERIC_OS"].present?
// 320:
// 321:         true
// 322:       end
// 323:
// 324:       sig {
// 325:         params(
// 326:           regex:   Regexp,
// 327:           capture: Symbol,
// 328:           named:   T.proc.params(name: String).returns(T::Boolean),
// 329:           aliases: T::Hash[String, String],
// 330:           renames: T::Hash[String, String],
// 331:         ).returns(T.nilable(T::Array[String]))
// 332:       }
// 333:       def api_fetch_names(regex:, capture:, named:, aliases:, renames:)
// 334:         requested_names = args.named.downcased_unique_named
// 335:         names = T.let(requested_names.filter_map do |requested_name|
// 336:           name = requested_name[regex, capture]
// 337:           next if name.blank?
// 338:
// 339:           name = name.downcase
// 340:           name = aliases.fetch(name, name)
// 341:           name = renames.fetch(name, name)
// 342:           next unless named.call(name)
// 343:
// 344:           name
// 345:         end, T::Array[String])
// 346:         return if names.length != requested_names.length
// 347:
// 348:         names
// 349:       end
// 350:
// 351:       sig { returns(Integer) }
// 352:       def retries
// 353:         @retries ||= T.let(args.retry? ? FETCH_MAX_TRIES : 1, T.nilable(Integer))
// 354:       end
// 355:
// 356:       sig { returns(DownloadQueue) }
// 357:       def download_queue
// 358:         @download_queue ||= T.let(begin
// 359:           DownloadQueue.new(retries:, force: args.force?)
// 360:         end, T.nilable(DownloadQueue))
// 361:       end
// 362:     end
// 363:   end
// 364: end
