module homebrew

import brew_runtime

// Translated from Homebrew/brew `github_packages.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `upload_bottles(bottles_hash, keep_old:, dry_run:, warn_on_error:)` at line 57.
pub fn ruby_github_packages_l57_d1_upload_bottles(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('upload_bottles', ...args)
}

// Ruby method `self.version_rebuild(version, rebuild, bottle_tag = nil)` at line 91.
pub fn ruby_github_packages_l91_d2_self_version_rebuild(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.version_rebuild', ...args)
}

// Ruby method `self.repo_without_prefix(repo)` at line 106.
pub fn ruby_github_packages_l106_d3_self_repo_without_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.repo_without_prefix', ...args)
}

// Ruby method `self.root_url(org, repo, prefix = URL_PREFIX)` at line 112.
pub fn ruby_github_packages_l112_d4_self_root_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.root_url', ...args)
}

// Ruby method `self.root_url_if_match(url)` at line 120.
pub fn ruby_github_packages_l120_d5_self_root_url_if_match(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.root_url_if_match', ...args)
}

// Ruby method `self.image_formula_name(formula_name)` at line 130.
pub fn ruby_github_packages_l130_d6_self_image_formula_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.image_formula_name', ...args)
}

// Ruby method `self.image_version_rebuild(version_rebuild)` at line 139.
pub fn ruby_github_packages_l139_d7_self_image_version_rebuild(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.image_version_rebuild', ...args)
}

// Ruby method `upload_bottle(user, token, skopeo, formula_full_name, bottle_hash, keep_old:, dry_run:, warn_on_error:)` at line 153.
pub fn ruby_github_packages_l153_d8_upload_bottle(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('upload_bottle', ...args)
}

// Ruby method `load_schemas!` at line 393.
pub fn ruby_github_packages_l393_d9_load_schemas(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('load_schemas!', ...args)
}

// Ruby method `schema_uri(basename, uris)` at line 421.
pub fn ruby_github_packages_l421_d10_schema_uri(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('schema_uri', ...args)
}

// Ruby method `schema_resolver(uri)` at line 436.
pub fn ruby_github_packages_l436_d11_schema_resolver(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('schema_resolver', ...args)
}

// Ruby method `validate_schema!(schema_uri, json)` at line 441.
pub fn ruby_github_packages_l441_d12_validate_schema(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('validate_schema!', ...args)
}

// Ruby method `download(user, token, skopeo, image_uri, root, dry_run:)` at line 456.
pub fn ruby_github_packages_l456_d13_download(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('download', ...args)
}

// Ruby method `preupload_check(user, token, skopeo, _formula_full_name, bottle_hash, keep_old:, dry_run:, warn_on_error:)` at line 475.
pub fn ruby_github_packages_l475_d14_preupload_check(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('preupload_check', ...args)
}

// Ruby method `write_image_layout(root)` at line 525.
pub fn ruby_github_packages_l525_d15_write_image_layout(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write_image_layout', ...args)
}

// Ruby method `write_tar_gz(local_file, blobs)` at line 532.
pub fn ruby_github_packages_l532_d16_write_tar_gz(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write_tar_gz', ...args)
}

// Ruby method `write_image_config(platform_hash, tar_sha256, blobs)` at line 540.
pub fn ruby_github_packages_l540_d17_write_image_config(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write_image_config', ...args)
}

// Ruby method `write_image_index(manifests, blobs, annotations)` at line 552.
pub fn ruby_github_packages_l552_d18_write_image_index(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write_image_index', ...args)
}

// Ruby method `write_index_json(index_json_sha256, index_json_size, root, annotations)` at line 563.
pub fn ruby_github_packages_l563_d19_write_index_json(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write_index_json', ...args)
}

// Ruby method `write_hash(directory, hash, filename = nil)` at line 578.
pub fn ruby_github_packages_l578_d20_write_hash(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write_hash', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/curl"
// 5: require "utils/gzip"
// 6: require "utils/output"
// 7: require "json"
// 8: require "zlib"
// 9: require "extend/hash/keys"
// 10: require "system_command"
// 11:
// 12: # GitHub Packages client.
// 13: class GitHubPackages
// 14:   include Context
// 15:   include SystemCommand::Mixin
// 16:   include Utils::Output::Mixin
// 17:
// 18:   URL_DOMAIN = "ghcr.io"
// 19:   URL_PREFIX = T.let("https://#{URL_DOMAIN}/v2/".freeze, String)
// 20:   DOCKER_PREFIX = T.let("docker://#{URL_DOMAIN}/".freeze, String)
// 21:   public_constant :URL_DOMAIN
// 22:   private_constant :URL_PREFIX
// 23:   private_constant :DOCKER_PREFIX
// 24:
// 25:   URL_REGEX = %r{(?:#{Regexp.escape(URL_PREFIX)}|#{Regexp.escape(DOCKER_PREFIX)})([\w-]+)/([\w-]+)}
// 26:
// 27:   # Valid OCI tag characters
// 28:   # https://github.com/opencontainers/distribution-spec/blob/main/spec.md#workflow-categories
// 29:   VALID_OCI_TAG_REGEX = /^[a-zA-Z0-9_][a-zA-Z0-9._-]{0,127}$/
// 30:
// 31:   # Translate Homebrew tab.arch to OCI platform.architecture
// 32:   TAB_ARCH_TO_PLATFORM_ARCHITECTURE = T.let(
// 33:     {
// 34:       "arm64"  => "arm64",
// 35:       "x86_64" => "amd64",
// 36:     }.freeze,
// 37:     T::Hash[String, String],
// 38:   )
// 39:
// 40:   # Translate Homebrew built_on.os to OCI platform.os
// 41:   BUILT_ON_OS_TO_PLATFORM_OS = T.let(
// 42:     {
// 43:       "Linux"     => "linux",
// 44:       "Macintosh" => "darwin",
// 45:     }.freeze,
// 46:     T::Hash[String, String],
// 47:   )
// 48:
// 49:   sig {
// 50:     params(
// 51:       bottles_hash:  T::Hash[String, T.untyped],
// 52:       keep_old:      T::Boolean,
// 53:       dry_run:       T::Boolean,
// 54:       warn_on_error: T::Boolean,
// 55:     ).void
// 56:   }
// 57:   def upload_bottles(bottles_hash, keep_old:, dry_run:, warn_on_error:)
// 58:     user = Homebrew::EnvConfig.github_packages_user
// 59:     token = Homebrew::EnvConfig.github_packages_token
// 60:
// 61:     raise UsageError, "HOMEBREW_GITHUB_PACKAGES_USER is unset." if user.blank?
// 62:     raise UsageError, "HOMEBREW_GITHUB_PACKAGES_TOKEN is unset." if token.blank?
// 63:
// 64:     skopeo = ensure_executable!("skopeo", reason: "upload")
// 65:
// 66:     require "json_schemer"
// 67:
// 68:     load_schemas!
// 69:
// 70:     bottles_hash.each do |formula_full_name, bottle_hash|
// 71:       # First, check that we won't encounter an error in the middle of uploading bottles.
// 72:       preupload_check(user, token, skopeo, formula_full_name, bottle_hash,
// 73:                       keep_old:, dry_run:, warn_on_error:)
// 74:     end
// 75:
// 76:     # We intentionally iterate over `bottles_hash` twice to
// 77:     # avoid erroring out in the middle of uploading bottles.
// 78:     bottle_count = bottles_hash.count
// 79:     bottles_hash.each_with_index do |(formula_full_name, bottle_hash), index|
// 80:       # Next, upload the bottles after checking them all.
// 81:       upload_bottle(user, token, skopeo, formula_full_name, bottle_hash,
// 82:                     keep_old:, dry_run:, warn_on_error:)
// 83:       next if bottle_count < 3
// 84:
// 85:       uploaded_count = index + 1
// 86:       ohai "Upload progress: #{uploaded_count} formula(e) uploaded, #{bottle_count - uploaded_count} remaining"
// 87:     end
// 88:   end
// 89:
// 90:   sig { params(version: Version, rebuild: Integer, bottle_tag: T.nilable(String)).returns(String) }
// 91:   def self.version_rebuild(version, rebuild, bottle_tag = nil)
// 92:     bottle_tag = (".#{bottle_tag}" if bottle_tag.present?)
// 93:
// 94:     rebuild = if rebuild.positive?
// 95:       if bottle_tag
// 96:         ".#{rebuild}"
// 97:       else
// 98:         "-#{rebuild}"
// 99:       end
// 100:     end
// 101:
// 102:     "#{version}#{bottle_tag}#{rebuild}"
// 103:   end
// 104:
// 105:   sig { params(repo: String).returns(String) }
// 106:   def self.repo_without_prefix(repo)
// 107:     # Remove redundant repository prefix for a shorter name.
// 108:     repo.delete_prefix("homebrew-")
// 109:   end
// 110:
// 111:   sig { params(org: String, repo: String, prefix: String).returns(String) }
// 112:   def self.root_url(org, repo, prefix = URL_PREFIX)
// 113:     # `docker`/`skopeo` insist on lowercase organisation (“repository name”).
// 114:     org = org.downcase
// 115:
// 116:     "#{prefix}#{org}/#{repo_without_prefix(repo)}"
// 117:   end
// 118:
// 119:   sig { params(url: T.nilable(String)).returns(T.nilable(String)) }
// 120:   def self.root_url_if_match(url)
// 121:     return if url.blank?
// 122:
// 123:     _, org, repo, = *url.to_s.match(URL_REGEX)
// 124:     return if org.blank? || repo.blank?
// 125:
// 126:     root_url(org, repo)
// 127:   end
// 128:
// 129:   sig { params(formula_name: String).returns(String) }
// 130:   def self.image_formula_name(formula_name)
// 131:     # Invalid docker name characters:
// 132:     # - `/` makes sense because we already use it to separate repository/formula.
// 133:     # - `x` makes sense because we already use it in `Formulary`.
// 134:     formula_name.tr("@", "/")
// 135:                 .tr("+", "x")
// 136:   end
// 137:
// 138:   sig { params(version_rebuild: String).returns(String) }
// 139:   def self.image_version_rebuild(version_rebuild)
// 140:     unless version_rebuild.match?(VALID_OCI_TAG_REGEX)
// 141:       raise ArgumentError, "GitHub Packages versions must match #{VALID_OCI_TAG_REGEX.source}!"
// 142:     end
// 143:
// 144:     version_rebuild
// 145:   end
// 146:
// 147:   sig {
// 148:     params(
// 149:       user: String, token: String, skopeo: Pathname, formula_full_name: String,
// 150:       bottle_hash: T::Hash[String, T.untyped], keep_old: T::Boolean, dry_run: T::Boolean, warn_on_error: T::Boolean
// 151:     ).void
// 152:   }
// 153:   def upload_bottle(user, token, skopeo, formula_full_name, bottle_hash, keep_old:, dry_run:, warn_on_error:)
// 154:     # We run the preupload check twice to prevent TOCTOU bugs.
// 155:     result = preupload_check(user, token, skopeo, formula_full_name, bottle_hash,
// 156:                              keep_old:, dry_run:, warn_on_error:)
// 157:     # Skip upload if preupload check returned early.
// 158:     return if result.nil?
// 159:
// 160:     formula_name, org, repo, version, rebuild, version_rebuild, image_name, image_uri, keep_old = *result
// 161:
// 162:     root = Pathname("#{formula_name}--#{version_rebuild}")
// 163:     FileUtils.rm_rf root
// 164:     root.mkpath
// 165:
// 166:     if keep_old
// 167:       download(user, token, skopeo, image_uri, root, dry_run:)
// 168:     else
// 169:       write_image_layout(root)
// 170:     end
// 171:
// 172:     blobs = root/"blobs/sha256"
// 173:     blobs.mkpath
// 174:
// 175:     git_path = bottle_hash["formula"]["tap_git_path"]
// 176:     git_revision = bottle_hash["formula"]["tap_git_revision"]
// 177:
// 178:     source_org_repo = "#{org}/#{repo}"
// 179:     source = "https://github.com/#{source_org_repo}/blob/#{git_revision.presence || "HEAD"}/#{git_path}"
// 180:
// 181:     formula_core_tap = formula_full_name.exclude?("/")
// 182:     documentation = if formula_core_tap
// 183:       "https://formulae.brew.sh/formula/#{formula_name}"
// 184:     elsif (remote = bottle_hash["formula"]["tap_git_remote"]) && remote.start_with?("https://github.com/")
// 185:       remote
// 186:     end
// 187:
// 188:     license = bottle_hash["formula"]["license"].to_s
// 189:     created_date = bottle_hash["bottle"]["date"]
// 190:     if keep_old
// 191:       index = JSON.parse((root/"index.json").read)
// 192:       image_index_sha256 = index["manifests"].first["digest"].delete_prefix("sha256:")
// 193:       image_index = JSON.parse((blobs/image_index_sha256).read)
// 194:       (blobs/image_index_sha256).unlink
// 195:
// 196:       formula_annotations_hash = image_index["annotations"]
// 197:       manifests = image_index["manifests"]
// 198:     else
// 199:       require "utils/spdx"
// 200:       image_license = SPDX.truncate_license(license)
// 201:
// 202:       formula_annotations_hash = {
// 203:         "com.github.package.type"                => GITHUB_PACKAGE_TYPE,
// 204:         "org.opencontainers.image.created"       => created_date,
// 205:         "org.opencontainers.image.description"   => bottle_hash["formula"]["desc"],
// 206:         "org.opencontainers.image.documentation" => documentation,
// 207:         "org.opencontainers.image.licenses"      => image_license,
// 208:         "org.opencontainers.image.ref.name"      => version_rebuild,
// 209:         "org.opencontainers.image.revision"      => git_revision,
// 210:         "org.opencontainers.image.source"        => source,
// 211:         "org.opencontainers.image.title"         => formula_full_name,
// 212:         "org.opencontainers.image.url"           => bottle_hash["formula"]["homepage"],
// 213:         "org.opencontainers.image.vendor"        => org,
// 214:         "org.opencontainers.image.version"       => version.to_s, # Schema accepts strings for version
// 215:       }.compact_blank
// 216:       manifests = []
// 217:     end
// 218:
// 219:     processed_image_refs = Set.new
// 220:     manifests.each do |manifest|
// 221:       processed_image_refs << manifest["annotations"]["org.opencontainers.image.ref.name"]
// 222:     end
// 223:
// 224:     require "sbom"
// 225:
// 226:     manifests += bottle_hash["bottle"]["tags"].map do |bottle_tag, tag_hash|
// 227:       bottle_tag = Utils::Bottles::Tag.from_symbol(bottle_tag.to_sym)
// 228:       all_bottle = bottle_tag.to_sym == :all
// 229:
// 230:       tag = GitHubPackages.version_rebuild(version, rebuild, bottle_tag.to_s)
// 231:
// 232:       if processed_image_refs.include?(tag)
// 233:         puts
// 234:         odie "A bottle JSON for #{bottle_tag} is present, but it is already in the image index!"
// 235:       else
// 236:         processed_image_refs << tag
// 237:       end
// 238:
// 239:       local_file = tag_hash["local_filename"]
// 240:       odebug "Uploading #{local_file}"
// 241:
// 242:       tar_gz_sha256 = write_tar_gz(local_file, blobs)
// 243:
// 244:       tab = tag_hash["tab"]
// 245:       architecture = TAB_ARCH_TO_PLATFORM_ARCHITECTURE[tab["arch"].presence || bottle_tag.standardized_arch.to_s]
// 246:       raise TypeError, "unknown tab['arch']: #{tab["arch"]}" if architecture.blank?
// 247:
// 248:       os = if tab["built_on"].present? && tab["built_on"]["os"].present?
// 249:         BUILT_ON_OS_TO_PLATFORM_OS[tab["built_on"]["os"]]
// 250:       elsif bottle_tag.linux?
// 251:         "linux"
// 252:       else
// 253:         "darwin"
// 254:       end
// 255:       raise TypeError, "unknown tab['built_on']['os']: #{tab["built_on"]["os"]}" if os.blank?
// 256:
// 257:       os_version = tab["built_on"]["os_version"].presence if tab["built_on"].present?
// 258:       case os
// 259:       when "darwin"
// 260:         os_version ||= "macOS #{bottle_tag.to_macos_version}"
// 261:       when "linux"
// 262:         os_version&.delete_suffix!(" LTS")
// 263:         os_version ||= OS::LINUX_CI_OS_VERSION
// 264:         glibc_version = tab["built_on"]["glibc_version"].presence if tab["built_on"].present?
// 265:         glibc_version ||= OS::LINUX_GLIBC_CI_VERSION
// 266:         cpu_variant = tab.dig("built_on", "oldest_cpu_family") || Hardware::CPU::INTEL_64BIT_OLDEST_CPU.to_s
// 267:       end
// 268:
// 269:       platform_hash = {
// 270:         architecture:,
// 271:         os:,
// 272:         "os.version" => os_version,
// 273:       }.compact_blank
// 274:
// 275:       tar_sha256 = Digest::SHA256.new
// 276:       Zlib::GzipReader.open(local_file) do |gz|
// 277:         while (data = gz.read(Utils::Gzip::GZIP_BUFFER_SIZE))
// 278:           tar_sha256 << data
// 279:         end
// 280:       end
// 281:
// 282:       config_json_sha256, config_json_size = write_image_config(platform_hash, tar_sha256.hexdigest, blobs)
// 283:
// 284:       documentation = "https://formulae.brew.sh/formula/#{formula_name}" if formula_core_tap
// 285:
// 286:       local_file_size = File.size(local_file)
// 287:
// 288:       path_exec_files_string = if (path_exec_files = tag_hash["path_exec_files"].presence)
// 289:         path_exec_files.join(",")
// 290:       end
// 291:       sbom_supplement_annotation = SBOM.github_packages_sbom_supplement_annotation(
// 292:         tag_hash["sbom"],
// 293:         formula_full_name:,
// 294:         formula_name:,
// 295:         version:,
// 296:         tar_gz_sha256:,
// 297:         root_url:          bottle_hash["bottle"]["root_url"],
// 298:         license:,
// 299:         created_date:,
// 300:       )
// 301:
// 302:       descriptor_annotations_hash = {
// 303:         "org.opencontainers.image.ref.name" => tag,
// 304:         "sh.brew.bottle.cpu.variant"        => cpu_variant,
// 305:         "sh.brew.bottle.digest"             => tar_gz_sha256,
// 306:         "sh.brew.bottle.glibc.version"      => glibc_version,
// 307:         "sh.brew.bottle.size"               => local_file_size.to_s,
// 308:         "sh.brew.bottle.installed_size"     => tag_hash["installed_size"].to_s,
// 309:         "sh.brew.license"                   => license,
// 310:         "sh.brew.tab"                       => (all_bottle ? tab.except("arch", "built_on") : tab).to_json,
// 311:         "sh.brew.sbom.supplement"           => sbom_supplement_annotation,
// 312:         "sh.brew.path_exec_files"           => path_exec_files_string,
// 313:       }.compact_blank
// 314:
// 315:       # TODO: upload/add tag_hash["all_files"] somewhere.
// 316:
// 317:       annotations_hash = formula_annotations_hash.merge(descriptor_annotations_hash).merge(
// 318:         {
// 319:           "org.opencontainers.image.created"       => created_date,
// 320:           "org.opencontainers.image.documentation" => documentation,
// 321:           "org.opencontainers.image.title"         => "#{formula_full_name} #{tag}",
// 322:         },
// 323:       ).compact_blank.sort.to_h
// 324:
// 325:       image_manifest = {
// 326:         schemaVersion: 2,
// 327:         config:        {
// 328:           mediaType: "application/vnd.oci.image.config.v1+json",
// 329:           digest:    "sha256:#{config_json_sha256}",
// 330:           size:      config_json_size,
// 331:         },
// 332:         layers:        [{
// 333:           mediaType:   "application/vnd.oci.image.layer.v1.tar+gzip",
// 334:           digest:      "sha256:#{tar_gz_sha256}",
// 335:           size:        File.size(local_file),
// 336:           annotations: {
// 337:             "org.opencontainers.image.title" => local_file,
// 338:           },
// 339:         }],
// 340:         annotations:   annotations_hash,
// 341:       }
// 342:       validate_schema!(IMAGE_MANIFEST_SCHEMA_URI, image_manifest)
// 343:       manifest_json_sha256, manifest_json_size = write_hash(blobs, image_manifest)
// 344:
// 345:       {
// 346:         mediaType:   "application/vnd.oci.image.manifest.v1+json",
// 347:         digest:      "sha256:#{manifest_json_sha256}",
// 348:         size:        manifest_json_size,
// 349:         platform:    all_bottle ? nil : platform_hash,
// 350:         annotations: descriptor_annotations_hash,
// 351:       }.compact
// 352:     end
// 353:
// 354:     index_json_sha256, index_json_size = write_image_index(manifests, blobs, formula_annotations_hash)
// 355:     raise "Image index too large!" if index_json_size >= 4 * 1024 * 1024 # GitHub will error 500 if too large
// 356:
// 357:     write_index_json(index_json_sha256, index_json_size, root,
// 358:                      "org.opencontainers.image.ref.name" => version_rebuild)
// 359:
// 360:     puts
// 361:     args = ["copy", "--retry-times=3", "--format=oci", "--all", "oci:#{root}", image_uri.to_s]
// 362:     if dry_run
// 363:       puts "#{skopeo} #{args.join(" ")} --dest-creds=#{user}:$HOMEBREW_GITHUB_PACKAGES_TOKEN"
// 364:     else
// 365:       args << "--dest-creds=#{user}:#{token}"
// 366:       retry_count = 0
// 367:       begin
// 368:         system_command!(skopeo, verbose: true, print_stdout: true, args:)
// 369:       rescue ErrorDuringExecution
// 370:         retry_count += 1
// 371:         odie "Cannot perform an upload to registry after retrying multiple times!" if retry_count >= 10
// 372:         Utils.exponential_backoff_sleep(retry_count)
// 373:         retry
// 374:       end
// 375:
// 376:       package_name = "#{GitHubPackages.repo_without_prefix(repo)}/#{image_name}"
// 377:       ohai "Uploaded to https://github.com/orgs/#{org}/packages/container/package/#{package_name}"
// 378:     end
// 379:   end
// 380:
// 381:   private
// 382:
// 383:   IMAGE_CONFIG_SCHEMA_URI = "https://opencontainers.org/schema/image/config"
// 384:   IMAGE_INDEX_SCHEMA_URI = "https://opencontainers.org/schema/image/index"
// 385:   IMAGE_LAYOUT_SCHEMA_URI = "https://opencontainers.org/schema/image/layout"
// 386:   IMAGE_MANIFEST_SCHEMA_URI = "https://opencontainers.org/schema/image/manifest"
// 387:
// 388:   GITHUB_PACKAGE_TYPE = "homebrew_bottle"
// 389:   private_constant :IMAGE_CONFIG_SCHEMA_URI, :IMAGE_INDEX_SCHEMA_URI, :IMAGE_LAYOUT_SCHEMA_URI,
// 390:                    :IMAGE_MANIFEST_SCHEMA_URI, :GITHUB_PACKAGE_TYPE
// 391:
// 392:   sig { void }
// 393:   def load_schemas!
// 394:     schema_uri("content-descriptor",
// 395:                "https://opencontainers.org/schema/image/content-descriptor.json")
// 396:     schema_uri("defs", %w[
// 397:       https://opencontainers.org/schema/defs.json
// 398:       https://opencontainers.org/schema/descriptor/defs.json
// 399:       https://opencontainers.org/schema/image/defs.json
// 400:       https://opencontainers.org/schema/image/descriptor/defs.json
// 401:       https://opencontainers.org/schema/image/index/defs.json
// 402:       https://opencontainers.org/schema/image/manifest/defs.json
// 403:     ])
// 404:     schema_uri("defs-descriptor", %w[
// 405:       https://opencontainers.org/schema/descriptor.json
// 406:       https://opencontainers.org/schema/defs-descriptor.json
// 407:       https://opencontainers.org/schema/descriptor/defs-descriptor.json
// 408:       https://opencontainers.org/schema/image/defs-descriptor.json
// 409:       https://opencontainers.org/schema/image/descriptor/defs-descriptor.json
// 410:       https://opencontainers.org/schema/image/index/defs-descriptor.json
// 411:       https://opencontainers.org/schema/image/manifest/defs-descriptor.json
// 412:       https://opencontainers.org/schema/index/defs-descriptor.json
// 413:     ])
// 414:     schema_uri("config-schema", IMAGE_CONFIG_SCHEMA_URI)
// 415:     schema_uri("image-index-schema", IMAGE_INDEX_SCHEMA_URI)
// 416:     schema_uri("image-layout-schema", IMAGE_LAYOUT_SCHEMA_URI)
// 417:     schema_uri("image-manifest-schema", IMAGE_MANIFEST_SCHEMA_URI)
// 418:   end
// 419:
// 420:   sig { params(basename: String, uris: T.any(String, T::Array[String])).void }
// 421:   def schema_uri(basename, uris)
// 422:     # The current `main` version has an invalid JSON schema.
// 423:     # Going forward, this should probably be pinned to tags.
// 424:     # We currently use features newer than the last one (v1.0.2).
// 425:     url = "https://raw.githubusercontent.com/opencontainers/image-spec/170393e57ed656f7f81c3070bfa8c3346eaa0a5a/schema/#{basename}.json"
// 426:     out = Utils::Curl.curl_output(url).stdout
// 427:     json = JSON.parse(out)
// 428:
// 429:     @schema_json ||= T.let({}, T.nilable(T::Hash[String, T::Hash[String, T.untyped]]))
// 430:     Array(uris).each do |uri|
// 431:       @schema_json[uri] = json
// 432:     end
// 433:   end
// 434:
// 435:   T::Sig::WithoutRuntime.sig { params(uri: URI::Generic).returns(T.nilable(T::Hash[String, T.untyped])) }
// 436:   def schema_resolver(uri)
// 437:     @schema_json&.fetch(uri.to_s.gsub(/#.*/, ""))
// 438:   end
// 439:
// 440:   sig { params(schema_uri: String, json: T::Hash[T.any(String, Symbol), T.untyped]).void }
// 441:   def validate_schema!(schema_uri, json)
// 442:     schema = JSONSchemer.schema(@schema_json&.fetch(schema_uri), ref_resolver: method(:schema_resolver))
// 443:     json = json.deep_stringify_keys
// 444:     return if schema.valid?(json)
// 445:
// 446:     puts
// 447:     ofail "#{Formatter.url(schema_uri)} JSON schema validation failed!"
// 448:     oh1 "Errors"
// 449:     puts schema.validate(json).to_a.inspect
// 450:     oh1 "JSON"
// 451:     puts json.inspect
// 452:     exit 1
// 453:   end
// 454:
// 455:   sig { params(user: String, token: String, skopeo: Pathname, image_uri: String, root: Pathname, dry_run: T::Boolean).void }
// 456:   def download(user, token, skopeo, image_uri, root, dry_run:)
// 457:     puts
// 458:     args = ["copy", "--all", image_uri.to_s, "oci:#{root}"]
// 459:     if dry_run
// 460:       puts "#{skopeo} #{args.join(" ")} --src-creds=#{user}:$HOMEBREW_GITHUB_PACKAGES_TOKEN"
// 461:     else
// 462:       args << "--src-creds=#{user}:#{token}"
// 463:       system_command!(skopeo, verbose: true, print_stdout: true, args:)
// 464:     end
// 465:   end
// 466:
// 467:   sig {
// 468:     params(
// 469:       user: String, token: String, skopeo: Pathname, _formula_full_name: String,
// 470:       bottle_hash: T::Hash[String, T.untyped], keep_old: T::Boolean, dry_run: T::Boolean, warn_on_error: T::Boolean
// 471:     ).returns(
// 472:       T.nilable([String, String, String, Version, Integer, String, String, String, T::Boolean]),
// 473:     )
// 474:   }
// 475:   def preupload_check(user, token, skopeo, _formula_full_name, bottle_hash, keep_old:, dry_run:, warn_on_error:)
// 476:     formula_name = bottle_hash["formula"]["name"]
// 477:
// 478:     _, org, repo, = *bottle_hash["bottle"]["root_url"].match(URL_REGEX)
// 479:     repo = "homebrew-#{repo}" unless repo.start_with?("homebrew-")
// 480:
// 481:     version = Version.new(bottle_hash["formula"]["pkg_version"])
// 482:     rebuild = bottle_hash["bottle"]["rebuild"].to_i
// 483:     version_rebuild = GitHubPackages.version_rebuild(version, rebuild)
// 484:
// 485:     image_name = GitHubPackages.image_formula_name(formula_name)
// 486:     image_tag = GitHubPackages.image_version_rebuild(version_rebuild)
// 487:     image_uri = "#{GitHubPackages.root_url(org, repo, DOCKER_PREFIX)}/#{image_name}:#{image_tag}"
// 488:
// 489:     puts
// 490:     inspect_args = ["inspect", "--raw", image_uri.to_s]
// 491:     if dry_run
// 492:       puts "#{skopeo} #{inspect_args.join(" ")} --creds=#{user}:$HOMEBREW_GITHUB_PACKAGES_TOKEN"
// 493:     else
// 494:       inspect_args << "--creds=#{user}:#{token}"
// 495:       inspect_result = system_command(skopeo, print_stderr: false, args: inspect_args)
// 496:
// 497:       # Order here is important.
// 498:       if !inspect_result.status.success? && !inspect_result.stderr.match?(/(name|manifest) unknown/)
// 499:         # We got an error and it was not about the tag or package being unknown.
// 500:         if warn_on_error
// 501:           opoo "#{image_uri} inspection returned an error, skipping upload!\n#{inspect_result.stderr}"
// 502:           return
// 503:         else
// 504:           odie "#{image_uri} inspection returned an error!\n#{inspect_result.stderr}"
// 505:         end
// 506:       elsif keep_old
// 507:         # If the tag doesn't exist, ignore `--keep-old`.
// 508:         keep_old = false unless inspect_result.status.success?
// 509:         # Otherwise, do nothing - the tag already existing is expected behaviour for --keep-old.
// 510:       elsif inspect_result.status.success?
// 511:         # The tag already exists and we are not passing `--keep-old`.
// 512:         if warn_on_error
// 513:           opoo "#{image_uri} already exists, skipping upload!"
// 514:           return
// 515:         else
// 516:           odie "#{image_uri} already exists!"
// 517:         end
// 518:       end
// 519:     end
// 520:
// 521:     [formula_name, org, repo, version, rebuild, version_rebuild, image_name, image_uri, keep_old]
// 522:   end
// 523:
// 524:   sig { params(root: Pathname).returns([String, Integer]) }
// 525:   def write_image_layout(root)
// 526:     image_layout = { imageLayoutVersion: "1.0.0" }
// 527:     validate_schema!(IMAGE_LAYOUT_SCHEMA_URI, image_layout)
// 528:     write_hash(root, image_layout, "oci-layout")
// 529:   end
// 530:
// 531:   sig { params(local_file: String, blobs: Pathname).returns(String) }
// 532:   def write_tar_gz(local_file, blobs)
// 533:     tar_gz_sha256 = Digest::SHA256.file(local_file)
// 534:                                   .hexdigest
// 535:     FileUtils.ln local_file, blobs/tar_gz_sha256, force: true
// 536:     tar_gz_sha256
// 537:   end
// 538:
// 539:   sig { params(platform_hash: T::Hash[T.any(String, Symbol), T.untyped], tar_sha256: String, blobs: Pathname).returns([String, Integer]) }
// 540:   def write_image_config(platform_hash, tar_sha256, blobs)
// 541:     image_config = platform_hash.merge({
// 542:       rootfs: {
// 543:         type:     "layers",
// 544:         diff_ids: ["sha256:#{tar_sha256}"],
// 545:       },
// 546:     })
// 547:     validate_schema!(IMAGE_CONFIG_SCHEMA_URI, image_config)
// 548:     write_hash(blobs, image_config)
// 549:   end
// 550:
// 551:   sig { params(manifests: T::Array[T::Hash[T.any(String, Symbol), T.untyped]], blobs: Pathname, annotations: T::Hash[String, String]).returns([String, Integer]) }
// 552:   def write_image_index(manifests, blobs, annotations)
// 553:     image_index = {
// 554:       schemaVersion: 2,
// 555:       manifests:,
// 556:       annotations:,
// 557:     }
// 558:     validate_schema!(IMAGE_INDEX_SCHEMA_URI, image_index)
// 559:     write_hash(blobs, image_index)
// 560:   end
// 561:
// 562:   sig { params(index_json_sha256: String, index_json_size: Integer, root: Pathname, annotations: T::Hash[String, String]).void }
// 563:   def write_index_json(index_json_sha256, index_json_size, root, annotations)
// 564:     index_json = {
// 565:       schemaVersion: 2,
// 566:       manifests:     [{
// 567:         mediaType:   "application/vnd.oci.image.index.v1+json",
// 568:         digest:      "sha256:#{index_json_sha256}",
// 569:         size:        index_json_size,
// 570:         annotations:,
// 571:       }],
// 572:     }
// 573:     validate_schema!(IMAGE_INDEX_SCHEMA_URI, index_json)
// 574:     write_hash(root, index_json, "index.json")
// 575:   end
// 576:
// 577:   sig { params(directory: Pathname, hash: T::Hash[T.any(String, Symbol), T.untyped], filename: T.nilable(String)).returns([String, Integer]) }
// 578:   def write_hash(directory, hash, filename = nil)
// 579:     json = JSON.pretty_generate(hash)
// 580:     sha256 = Digest::SHA256.hexdigest(json)
// 581:     filename ||= sha256
// 582:     path = directory/filename
// 583:     path.unlink if path.exist?
// 584:     path.write(json)
// 585:
// 586:     [sha256, json.size]
// 587:   end
// 588: end
