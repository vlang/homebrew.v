module homebrew

import brew_runtime

// Translated from Homebrew/brew `resource_auditor.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :name` at line 13.
pub fn ruby_resource_auditor_l13_d1_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby attr_reader `attr_reader :version` at line 16.
pub fn ruby_resource_auditor_l16_d2_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby attr_reader `attr_reader :checksum` at line 19.
pub fn ruby_resource_auditor_l19_d3_checksum(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('checksum', ...args)
}

// Ruby attr_reader `attr_reader :url` at line 22.
pub fn ruby_resource_auditor_l22_d4_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url', ...args)
}

// Ruby attr_reader `attr_reader :mirrors` at line 25.
pub fn ruby_resource_auditor_l25_d5_mirrors(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('mirrors', ...args)
}

// Ruby attr_reader `attr_reader :using` at line 28.
pub fn ruby_resource_auditor_l28_d6_using(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('using', ...args)
}

// Ruby attr_reader `attr_reader :specs` at line 31.
pub fn ruby_resource_auditor_l31_d7_specs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('specs', ...args)
}

// Ruby attr_reader `attr_reader :owner` at line 34.
pub fn ruby_resource_auditor_l34_d8_owner(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('owner', ...args)
}

// Ruby attr_reader `attr_reader :spec_name` at line 37.
pub fn ruby_resource_auditor_l37_d9_spec_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('spec_name', ...args)
}

// Ruby attr_reader `attr_reader :problems` at line 40.
pub fn ruby_resource_auditor_l40_d10_problems(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('problems', ...args)
}

// Ruby method `initialize(resource, spec_name, online: nil, strict: nil, only: nil, except: nil, core_tap: nil,` at line 54.
pub fn ruby_resource_auditor_l54_d11_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `audit` at line 75.
pub fn ruby_resource_auditor_l75_d12_audit(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit', ...args)
}

// Ruby method `audit_version` at line 91.
pub fn ruby_resource_auditor_l91_d13_audit_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_version', ...args)
}

// Ruby method `audit_download_strategy` at line 109.
pub fn ruby_resource_auditor_l109_d14_audit_download_strategy(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_download_strategy', ...args)
}

// Ruby method `audit_checksum` at line 140.
pub fn ruby_resource_auditor_l140_d15_audit_checksum(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_checksum', ...args)
}

// Ruby method `self.curl_deps` at line 151.
pub fn ruby_resource_auditor_l151_d16_self_curl_deps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.curl_deps', ...args)
}

// Ruby method `audit_resource_name_matches_pypi_package_name_in_url` at line 160.
pub fn ruby_resource_auditor_l160_d17_audit_resource_name_matches_pypi_package_name_in_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_resource_name_matches_pypi_package_name_in_url',
		...args)
}

// Ruby method `audit_urls` at line 183.
pub fn ruby_resource_auditor_l183_d18_audit_urls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_urls', ...args)
}

// Ruby method `audit_curl_dep_http_mirror` at line 238.
pub fn ruby_resource_auditor_l238_d19_audit_curl_dep_http_mirror(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_curl_dep_http_mirror', ...args)
}

// Ruby method `audit_head_branch` at line 274.
pub fn ruby_resource_auditor_l274_d20_audit_head_branch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_head_branch', ...args)
}

// Ruby method `problem(text)` at line 299.
pub fn ruby_resource_auditor_l299_d21_problem(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('problem', ...args)
}

// Ruby method `curl_dep?` at line 306.
pub fn ruby_resource_auditor_l306_d22_curl_dep(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('curl_dep?', ...args)
}

// Ruby method `owner!` at line 311.
pub fn ruby_resource_auditor_l311_d23_owner(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('owner!', ...args)
}

// Ruby method `url!` at line 316.
pub fn ruby_resource_auditor_l316_d24_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url!', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/path"
// 5: require "utils/svn"
// 6:
// 7: module Homebrew
// 8:   # Auditor for checking common violations in {Resource}s.
// 9:   class ResourceAuditor
// 10:     include Utils::Curl
// 11:
// 12:     sig { returns(T.nilable(String)) }
// 13:     attr_reader :name
// 14:
// 15:     sig { returns(T.nilable(Version)) }
// 16:     attr_reader :version
// 17:
// 18:     sig { returns(T.nilable(Checksum)) }
// 19:     attr_reader :checksum
// 20:
// 21:     sig { returns(T.nilable(String)) }
// 22:     attr_reader :url
// 23:
// 24:     sig { returns(T::Array[String]) }
// 25:     attr_reader :mirrors
// 26:
// 27:     sig { returns(T.nilable(T.any(T::Class[AbstractDownloadStrategy], Symbol))) }
// 28:     attr_reader :using
// 29:
// 30:     sig { returns(T::Hash[Symbol, T.untyped]) }
// 31:     attr_reader :specs
// 32:
// 33:     sig { returns(T.nilable(Resource::Owner)) }
// 34:     attr_reader :owner
// 35:
// 36:     sig { returns(Symbol) }
// 37:     attr_reader :spec_name
// 38:
// 39:     sig { returns(T::Array[String]) }
// 40:     attr_reader :problems
// 41:
// 42:     sig {
// 43:       params(
// 44:         resource:          T.any(Resource, SoftwareSpec),
// 45:         spec_name:         Symbol,
// 46:         online:            T.nilable(T::Boolean),
// 47:         strict:            T.nilable(T::Boolean),
// 48:         only:              T.nilable(T::Array[String]),
// 49:         except:            T.nilable(T::Array[String]),
// 50:         core_tap:          T.nilable(T::Boolean),
// 51:         use_homebrew_curl: T::Boolean,
// 52:       ).void
// 53:     }
// 54:     def initialize(resource, spec_name, online: nil, strict: nil, only: nil, except: nil, core_tap: nil,
// 55:                    use_homebrew_curl: false)
// 56:       @name     = T.let(resource.name, T.nilable(String))
// 57:       @version  = T.let(resource.version, T.nilable(Version))
// 58:       @checksum = T.let(resource.checksum, T.nilable(Checksum))
// 59:       @url      = T.let(resource.url&.to_s, T.nilable(String))
// 60:       @mirrors  = T.let(resource.mirrors, T::Array[String])
// 61:       @using    = T.let(resource.using, T.nilable(T.any(T::Class[AbstractDownloadStrategy], Symbol)))
// 62:       @specs    = T.let(resource.specs, T::Hash[Symbol, T.untyped])
// 63:       @owner    = T.let(resource.owner, T.nilable(T.any(Cask::Cask, Resource::Owner)))
// 64:       @spec_name = spec_name
// 65:       @online    = online
// 66:       @strict    = strict
// 67:       @only      = only
// 68:       @except    = except
// 69:       @core_tap  = core_tap
// 70:       @use_homebrew_curl = use_homebrew_curl
// 71:       @problems = T.let([], T::Array[String])
// 72:     end
// 73:
// 74:     sig { returns(ResourceAuditor) }
// 75:     def audit
// 76:       only_audits = @only
// 77:       except_audits = @except
// 78:
// 79:       methods.map(&:to_s).grep(/^audit_/).each do |audit_method_name|
// 80:         name = audit_method_name.delete_prefix("audit_")
// 81:         next if only_audits&.exclude?(name)
// 82:         next if except_audits&.include?(name)
// 83:
// 84:         send(audit_method_name)
// 85:       end
// 86:
// 87:       self
// 88:     end
// 89:
// 90:     sig { void }
// 91:     def audit_version
// 92:       if (version_text = version).nil?
// 93:         problem "Missing version"
// 94:       elsif (formula_owner = owner).is_a?(::Formula) &&
// 95:             !version_text.to_s.match?(GitHubPackages::VALID_OCI_TAG_REGEX) &&
// 96:             (formula_owner.core_formula? ||
// 97:             (formula_owner.bottle_defined? &&
// 98:               GitHubPackages::URL_REGEX.match?(formula_owner.bottle_specification.root_url)))
// 99:         problem "`version #{version}` does not match #{GitHubPackages::VALID_OCI_TAG_REGEX.source}"
// 100:       elsif !version_text.detected_from_url?
// 101:         version_url = Version.detect(url!, **specs)
// 102:         if version_url.to_s == version_text.to_s && version.instance_of?(Version)
// 103:           problem "`version #{version_text}` is redundant with version scanned from URL"
// 104:         end
// 105:       end
// 106:     end
// 107:
// 108:     sig { void }
// 109:     def audit_download_strategy
// 110:       url_strategy = DownloadStrategyDetector.detect(url!)
// 111:
// 112:       if (using == :git || url_strategy == GitDownloadStrategy) && specs[:tag] && !specs[:revision]
// 113:         problem "Git should specify `revision:` when a `tag:` is specified."
// 114:       end
// 115:
// 116:       return unless using
// 117:
// 118:       if using == :cvs
// 119:         mod = specs[:module]
// 120:
// 121:         problem "Redundant `module:` value in URL" if mod == name
// 122:
// 123:         if url!.match?(%r{:[^/]+$})
// 124:           mod = url!.split(":").last
// 125:
// 126:           if mod == name
// 127:             problem "Redundant CVS module appended to URL"
// 128:           else
// 129:             problem "Specify CVS module as `module: \"#{mod}\"` instead of appending it to the URL"
// 130:           end
// 131:         end
// 132:       end
// 133:
// 134:       return if url_strategy != DownloadStrategyDetector.detect("", using)
// 135:
// 136:       problem "Redundant `using:` value in URL"
// 137:     end
// 138:
// 139:     sig { void }
// 140:     def audit_checksum
// 141:       return if spec_name == :head
// 142:       # This condition is non-invertible.
// 143:       # rubocop:disable Style/InvertibleUnlessCondition
// 144:       return unless DownloadStrategyDetector.detect(url.to_s, using) <= CurlDownloadStrategy
// 145:       # rubocop:enable Style/InvertibleUnlessCondition
// 146:
// 147:       problem "Checksum is missing" if checksum.blank?
// 148:     end
// 149:
// 150:     sig { returns(T::Array[String]) }
// 151:     def self.curl_deps
// 152:       @curl_deps ||= T.let(begin
// 153:         ["curl"] + ::Formula["curl"].recursive_dependencies.map(&:name).uniq
// 154:       rescue FormulaUnavailableError
// 155:         []
// 156:       end, T.nilable(T::Array[String]))
// 157:     end
// 158:
// 159:     sig { void }
// 160:     def audit_resource_name_matches_pypi_package_name_in_url
// 161:       return unless url!.match?(%r{^https?://files\.pythonhosted\.org/packages/})
// 162:       # Skip the top-level package name as we only care about `resource "foo"` blocks.
// 163:       return if name == owner!.name
// 164:
// 165:       if url!.end_with? ".whl"
// 166:         path = URI(url!).path
// 167:         return unless path.present?
// 168:
// 169:         pypi_package_name, = File.basename(path).split("-", 2)
// 170:       else
// 171:         url =~ %r{/(?<package_name>[^/]+)-}
// 172:         pypi_package_name = Regexp.last_match(:package_name).to_s
// 173:       end
// 174:
// 175:       T.must(pypi_package_name).gsub!(/[_.]/, "-")
// 176:
// 177:       return if name.to_s.casecmp(pypi_package_name.to_s)&.zero?
// 178:
// 179:       problem "`resource` name should be '#{pypi_package_name}' to match the PyPI package name"
// 180:     end
// 181:
// 182:     sig { void }
// 183:     def audit_urls
// 184:       urls = [url.to_s] + mirrors
// 185:
// 186:       curl_dep = curl_dep?
// 187:       # Ideally `ca-certificates` would not be excluded here, but sourcing a HTTP mirror was tricky.
// 188:       # Instead, we have logic elsewhere to pass `--insecure` to curl when downloading the certs.
// 189:       # TODO: try remove the OS/env conditional
// 190:       if Homebrew::SimulateSystem.simulating_or_running_on_macos? && spec_name == :stable &&
// 191:          owner!.name != "ca-certificates" && curl_dep && !urls.find { |u| u.start_with?("http://") }
// 192:         problem "Should always include at least one HTTP mirror"
// 193:       end
// 194:
// 195:       return unless @online
// 196:
// 197:       urls.each do |url|
// 198:         next if !@strict && mirrors.include?(url)
// 199:
// 200:         strategy = DownloadStrategyDetector.detect(url, using)
// 201:         if strategy <= CurlDownloadStrategy && !url.start_with?("file")
// 202:
// 203:           raise HomebrewCurlDownloadStrategyError, url if
// 204:             strategy <= HomebrewCurlDownloadStrategy && !Utils::Path.formula_any_version_installed?("curl")
// 205:
// 206:           # Skip ftp.gnu.org audit, upstream has asked us to reduce load.
// 207:           # See issue: https://github.com/Homebrew/brew/issues/20456
// 208:           next if url.match?(%r{^https?://ftp\.gnu\.org/.+})
// 209:
// 210:           # Skip https audit for curl dependencies
// 211:           if !curl_dep && (http_content_problem = curl_check_http_content(
// 212:             url,
// 213:             "source URL",
// 214:             specs:,
// 215:             use_homebrew_curl: @use_homebrew_curl,
// 216:           ))
// 217:             problem http_content_problem
// 218:           end
// 219:         elsif strategy <= GitDownloadStrategy
// 220:           attempts = 0
// 221:           remote_exists = T.let(false, T::Boolean)
// 222:           while !remote_exists && attempts < Homebrew::EnvConfig.curl_retries.to_i
// 223:             remote_exists = Utils::Git.remote_exists?(url)
// 224:             attempts += 1
// 225:           end
// 226:           problem "The URL #{url} is not a valid Git URL" unless remote_exists
// 227:         elsif strategy <= SubversionDownloadStrategy
// 228:           next unless Utils::Svn.available?
// 229:
// 230:           problem "The URL #{url} is not a valid SVN URL" unless Utils::Svn.remote_exists? url
// 231:         end
// 232:       end
// 233:     end
// 234:
// 235:     # `curl` dependencies must be fetchable before `ca-certificates`, so at least
// 236:     # one mirror must serve the expected file over plain HTTP.
// 237:     sig { void }
// 238:     def audit_curl_dep_http_mirror
// 239:       return unless @online
// 240:       return if spec_name != :stable
// 241:       # Only audit the formula's own source, not its `resource` blocks.
// 242:       return if name != owner!.name
// 243:       return unless curl_dep?
// 244:
// 245:       checksum = self.checksum
// 246:       return if checksum.nil?
// 247:
// 248:       http_mirrors = mirrors.select { |mirror| mirror.start_with?("http://") }
// 249:       return if http_mirrors.empty?
// 250:
// 251:       working_mirror = http_mirrors.find do |mirror|
// 252:         details = curl_http_content_headers_and_checksum(
// 253:           mirror,
// 254:           hash_needed:       true,
// 255:           use_homebrew_curl: @use_homebrew_curl,
// 256:           # Fail rather than follow an HTTPS redirect, so a successful request
// 257:           # with a matching checksum proves the bytes came over plain HTTP.
// 258:           specs:             { proto_redir: "=http" },
// 259:         )
// 260:
// 261:         # Reject an explicit HTTPS `final_url` as defence-in-depth; a relative or
// 262:         # HTTP `Location` from an HTTP-to-HTTP redirect is fine.
// 263:         http_status_ok?(details[:status_code]) &&
// 264:           !details[:final_url].to_s.start_with?("https://") &&
// 265:           details[:file_hash] == checksum.hexdigest
// 266:       end
// 267:       return if working_mirror
// 268:
// 269:       problem "`curl` dependencies must have a working HTTP mirror that serves " \
// 270:               "the expected checksum over plain HTTP."
// 271:     end
// 272:
// 273:     sig { void }
// 274:     def audit_head_branch
// 275:       return unless @online
// 276:       return if spec_name != :head
// 277:       return if specs[:tag].present?
// 278:       return if specs[:revision].present?
// 279:       # Skip `resource` URLs as they use SHAs instead of branch specifiers.
// 280:       return if name != owner!.name
// 281:       return unless url.to_s.end_with?(".git")
// 282:       return unless Utils::Git.remote_exists?(url.to_s)
// 283:
// 284:       detected_branch = Utils.popen_read("git", "ls-remote", "--symref", "--end-of-options", url.to_s, "HEAD")
// 285:                              .match(%r{ref: refs/heads/(.*?)\s+HEAD})&.to_a&.second
// 286:
// 287:       if specs[:branch].blank?
// 288:         problem "Git `head` URL must specify a branch name"
// 289:         return
// 290:       end
// 291:
// 292:       return unless @core_tap
// 293:       return if specs[:branch] == detected_branch
// 294:
// 295:       problem "To use a non-default HEAD branch, add the formula to `head_non_default_branch_allowlist.json`."
// 296:     end
// 297:
// 298:     sig { params(text: String).void }
// 299:     def problem(text)
// 300:       @problems << text
// 301:     end
// 302:
// 303:     private
// 304:
// 305:     sig { returns(T::Boolean) }
// 306:     def curl_dep?
// 307:       self.class.curl_deps.include?(owner!.name)
// 308:     end
// 309:
// 310:     sig { returns(Resource::Owner) }
// 311:     def owner!
// 312:       owner || raise("ResourceAuditor owner is nil")
// 313:     end
// 314:
// 315:     sig { returns(String) }
// 316:     def url!
// 317:       url || raise("ResourceAuditor URL is nil")
// 318:     end
// 319:   end
// 320: end
