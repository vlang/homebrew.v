module vulns

import brew_runtime

// Translated from Homebrew/brew `vulns/identify.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.repo_url(*urls)` at line 58.
pub fn ruby_identify_l58_d1_self_repo_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.repo_url', ...args)
}

// Ruby method `self.tag(url)` at line 76.
pub fn ruby_identify_l76_d2_self_tag(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.tag', ...args)
}

// Ruby method `self.registry_package(url)` at line 118.
pub fn ruby_identify_l118_d3_self_registry_package(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.registry_package', ...args)
}

// Ruby method `self.registry_purl(url)` at line 136.
pub fn ruby_identify_l136_d4_self_registry_purl(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.registry_purl', ...args)
}

// Ruby method `self.decode(component)` at line 200.
pub fn ruby_identify_l200_d5_self_decode(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.decode', ...args)
}

// Ruby method `self.version_after_prefix(basename, name)` at line 208.
pub fn ruby_identify_l208_d6_self_version_after_prefix(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.version_after_prefix', ...args)
}

// Ruby method `self.gem_name_version(basename)` at line 219.
pub fn ruby_identify_l219_d7_self_gem_name_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.gem_name_version', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "vulns/purl"
// 5:
// 6: module Homebrew
// 7:   module Vulns
// 8:     # Derives OSV.dev query keys (forge repo URL, release tag) from formula
// 9:     # source URLs. Shared between {Scanner} and the advisory-matching pipeline.
// 10:     module Identify
// 11:       TWO_SEGMENT_PATH = %r{/([^/]+/[^/]+)}
// 12:       private_constant :TWO_SEGMENT_PATH
// 13:
// 14:       # GitLab supports nested subgroups (e.g. `xorg/lib/libx11`); the path is
// 15:       # bounded by `.git`, the `/-/` route marker, the legacy `/uploads/` and
// 16:       # `/wikis/` routes, or the end of the URL. Host-level `/-/` and `/api/`
// 17:       # routes are rejected via the leading negative lookahead.
// 18:       GITLAB_PATH = %r{/(?!-|api/)([^/]+(?:/[^/]+)+?)(?:\.git)?(?=/-/|/uploads/|/wikis/|/?\z)}
// 19:       private_constant :GITLAB_PATH
// 20:
// 21:       FORGES = T.let(
// 22:         {
// 23:           "github.com"             => TWO_SEGMENT_PATH,
// 24:           "codeberg.org"           => TWO_SEGMENT_PATH,
// 25:           "gitlab.com"             => GITLAB_PATH,
// 26:           "gitlab.gnome.org"       => GITLAB_PATH,
// 27:           "gitlab.freedesktop.org" => GITLAB_PATH,
// 28:           "invent.kde.org"         => GITLAB_PATH,
// 29:         }.freeze,
// 30:         T::Hash[String, Regexp],
// 31:       )
// 32:       private_constant :FORGES
// 33:
// 34:       TAG_PATTERNS = T.let(
// 35:         [
// 36:           %r{/archive/refs/tags/([^/]+)\.tar\.gz$},
// 37:           %r{/archive/refs/tags/([^/]+)\.zip$},
// 38:           %r{/archive/([^/]+)\.tar\.gz$},
// 39:           %r{/archive/([^/]+)\.zip$},
// 40:           %r{/releases/download/([^/]+)/},
// 41:           %r{/tarball/([^/]+)$},
// 42:         ].freeze,
// 43:         T::Array[Regexp],
// 44:       )
// 45:       private_constant :TAG_PATTERNS
// 46:
// 47:       WAYBACK_PREFIX = %r{\Ahttps?://web\.archive\.org/web/\d+[a-z_*]*/}
// 48:       private_constant :WAYBACK_PREFIX
// 49:
// 50:       # OSV.dev's GIT ecosystem indexes repository URLs case-sensitively but
// 51:       # normalises `github.com` paths to lowercase (GitHub itself is
// 52:       # case-insensitive). GitLab and Codeberg are case-sensitive so their
// 53:       # paths are preserved.
// 54:       LOWERCASE_PATH_HOSTS = ["github.com"].freeze
// 55:       private_constant :LOWERCASE_PATH_HOSTS
// 56:
// 57:       sig { params(urls: T.nilable(String)).returns(T.nilable(String)) }
// 58:       def self.repo_url(*urls)
// 59:         urls.each do |url|
// 60:           next if url.nil?
// 61:
// 62:           url = url.sub(WAYBACK_PREFIX, "")
// 63:           FORGES.each do |host, path_pattern|
// 64:             match = url.match(%r{\Ahttps?://#{Regexp.escape(host)}#{path_pattern}})
// 65:             next if match.nil?
// 66:
// 67:             repo_path = T.must(match[1]).sub(/\.git$/, "")
// 68:             repo_path = repo_path.downcase if LOWERCASE_PATH_HOSTS.include?(host)
// 69:             return "https://#{host}/#{repo_path}"
// 70:           end
// 71:         end
// 72:         nil
// 73:       end
// 74:
// 75:       sig { params(url: T.nilable(String)).returns(T.nilable(String)) }
// 76:       def self.tag(url)
// 77:         return if url.nil?
// 78:
// 79:         TAG_PATTERNS.each do |pattern|
// 80:           match = url.match(pattern)
// 81:           return match[1] if match
// 82:         end
// 83:         nil
// 84:       end
// 85:
// 86:       # `ecosystem` is the OSV.dev ecosystem identifier for `name`, or `"CPAN"`
// 87:       # for CPAN distributions (queried via CPANSA, not OSV).
// 88:       RegistryPackage = Struct.new(:ecosystem, :name, :version, :purl, keyword_init: true)
// 89:
// 90:       ARCHIVE_EXTENSIONS = /\.(?:tar\.gz|tar\.bz2|tar\.xz|tgz|zip|gem|crate|tar|nupkg)\z/i
// 91:       private_constant :ARCHIVE_EXTENSIONS
// 92:
// 93:       # Cabal package versions are dot-separated non-negative integers only.
// 94:       HACKAGE_PKGID = /\A(.+)-(\d+(?:\.\d+)*)\z/
// 95:       private_constant :HACKAGE_PKGID
// 96:
// 97:       # Simplified from CPAN::DistnameInfo: greedy name, version is digits/
// 98:       # dots/underscores optionally `v`-prefixed. A -TRIAL suffix is stripped.
// 99:       # Does not handle the rare `_`-separated form (e.g. `libao-perl_0.03-1`);
// 100:       # no homebrew-core formula currently uses it.
// 101:       CPAN_DISTNAME = /\A(.+)-(v?\d[\d._]*)(?:-TRIAL\d*)?\z/
// 102:       private_constant :CPAN_DISTNAME
// 103:
// 104:       # Recognise a `Gem::Platform` suffix by its OS token; the CPU token is
// 105:       # open-ended (riscv64, s390x, ppc64le, ...) so is matched generically.
// 106:       GEM_PLATFORM_SUFFIX = /
// 107:         -(?:
// 108:           java|jruby|truffleruby|dalvik|dotnet|mswin\d+(?:_\d+)?|
// 109:           \w+-
// 110:           (?:aix|cygwin|darwin|freebsd|linux|macruby|mingw\w*|mswin\d*|
// 111:              netbsd\w*|openbsd|bitrig|solaris|wasi)
// 112:           (?:[-_][\w.]+)?
// 113:         )\z
// 114:       /x
// 115:       private_constant :GEM_PLATFORM_SUFFIX
// 116:
// 117:       sig { params(url: T.nilable(String)).returns(T.nilable(RegistryPackage)) }
// 118:       def self.registry_package(url)
// 119:         return if url.nil?
// 120:
// 121:         ecosystem, purl = registry_purl(url)
// 122:         return if purl.nil?
// 123:
// 124:         name = case purl.type
// 125:         when "maven" then "#{purl.namespace}:#{purl.name}"
// 126:         # OSV keys PyPI packages by their PEP 503 normalised name.
// 127:         when "pypi" then purl.name.gsub(/[-_.]+/, "-")
// 128:         # CPANSA is keyed on the distribution name alone, without the author.
// 129:         when "cpan" then purl.name
// 130:         else purl.namespace ? "#{purl.namespace}/#{purl.name}" : purl.name
// 131:         end
// 132:         RegistryPackage.new(ecosystem:, name:, version: purl.version, purl: purl.to_s).freeze
// 133:       end
// 134:
// 135:       sig { params(url: String).returns(T.nilable([String, Purl])) }
// 136:       def self.registry_purl(url)
// 137:         basename = decode(File.basename(url)).sub(ARCHIVE_EXTENSIONS, "")
// 138:
// 139:         case url
// 140:         when %r{\Ahttps://files\.pythonhosted\.org/packages/(?:[^/]+/){3}(?![^/]+\.whl\z)}
// 141:           # PEP 440 canonical versions contain no hyphen, so the last one delimits.
// 142:           name, _, version = basename.rpartition("-")
// 143:           return if name.empty?
// 144:
// 145:           ["PyPI", Purl.new(type: "pypi", name:, version:)]
// 146:         when %r{\Ahttps://registry\.npmjs\.org/(?:((?:@|%40)[^/]+)/)?([^/@%][^/]*)/-/}
// 147:           namespace = Regexp.last_match(1)
// 148:           name = T.must(Regexp.last_match(2))
// 149:           namespace &&= "@#{decode(namespace).delete_prefix("@")}"
// 150:           name = decode(name)
// 151:           return unless (version = version_after_prefix(basename, name))
// 152:
// 153:           ["npm", Purl.new(type: "npm", namespace:, name:, version:)]
// 154:         when %r{\Ahttps://static\.crates\.io/crates/([^/]+)/}
// 155:           name = decode(T.must(Regexp.last_match(1)))
// 156:           return unless (version = version_after_prefix(basename, name))
// 157:
// 158:           ["crates.io", Purl.new(type: "cargo", name:, version:)]
// 159:         when %r{\Ahttps://rubygems\.org/(?:downloads|gems)/}
// 160:           name, version = gem_name_version(basename)
// 161:           return if name.nil?
// 162:
// 163:           ["RubyGems", Purl.new(type: "gem", name:, version:)]
// 164:         when %r{\Ahttps://hackage\.haskell\.org/package/([^/]+)}
// 165:           match = T.must(Regexp.last_match(1)).match(HACKAGE_PKGID)
// 166:           return if match.nil?
// 167:
// 168:           ["Hackage", Purl.new(type: "hackage", name: T.must(match[1]), version: match[2])]
// 169:         when %r{\Ahttps://repo\.hex\.pm/tarballs/}
// 170:           # Hex package names are `[a-z][a-z0-9_]*` so the first hyphen delimits.
// 171:           name, sep, version = basename.partition("-")
// 172:           return if sep.empty?
// 173:
// 174:           ["Hex", Purl.new(type: "hex", name:, version:)]
// 175:         when %r{/authors/id/[A-Z]/[A-Z]{2}/([A-Z][A-Z0-9-]+)/}
// 176:           author = T.must(Regexp.last_match(1))
// 177:           match = basename.match(CPAN_DISTNAME)
// 178:           return if match.nil?
// 179:
// 180:           ["CPAN", Purl.new(type: "cpan", namespace: author, name: T.must(match[1]), version: match[2])]
// 181:         # Maven Central only: OSV's bare `Maven` ecosystem is Central-scoped,
// 182:         # so third-party repositories (Google, fabricmc, jfrog, ...) are skipped.
// 183:         when %r{\Ahttps://repo1?\.maven\.(?:apache\.)?org/maven2/(.+)/([^/]+)/([^/]+)/\2-\3[.-][^/]+\z},
// 184:              %r{\Ahttps://search\.maven\.org/remotecontent\?filepath=(.+)/([^/]+)/([^/]+)/\2-\3[.-][^/]+\z}
// 185:           group_id = T.must(Regexp.last_match(1)).tr("/", ".")
// 186:           artifact_id = T.must(Regexp.last_match(2))
// 187:           version = Regexp.last_match(3)
// 188:           ["Maven", Purl.new(type: "maven", namespace: group_id, name: artifact_id, version:)]
// 189:         when %r{\Ahttps://(?:cran|cloud)\.r-project\.org/src/contrib/(?:Archive/[^/]+/)?([^/_]+)_([^/]+)\.tar\.gz\z}
// 190:           ["CRAN", Purl.new(type: "cran", name: T.must(Regexp.last_match(1)), version: Regexp.last_match(2))]
// 191:         when %r{\Ahttps://(?:api|www)\.nuget\.org/(?:v3-flatcontainer|api/v2/package)/([^/]+)/([^/]+)(?:/|\z)}
// 192:           ["NuGet", Purl.new(type: "nuget", name: T.must(Regexp.last_match(1)), version: Regexp.last_match(2))]
// 193:         end
// 194:       end
// 195:
// 196:       # Percent-decode a URL path segment. Unlike `decode_www_form_component`
// 197:       # this leaves `+` alone and unlike `decode_uri_component` (missing from
// 198:       # Sorbet's stdlib RBI) it never raises on malformed input.
// 199:       sig { params(component: String).returns(String) }
// 200:       def self.decode(component)
// 201:         return component unless component.include?("%")
// 202:
// 203:         component.b.gsub(/%[0-9A-Fa-f]{2}/) { |m| Integer(m[1, 2], 16).chr }
// 204:                  .force_encoding(component.encoding)
// 205:       end
// 206:
// 207:       sig { params(basename: String, name: String).returns(T.nilable(String)) }
// 208:       def self.version_after_prefix(basename, name)
// 209:         prefix = "#{name}-"
// 210:         return unless basename.start_with?(prefix)
// 211:
// 212:         version = basename[prefix.length..]
// 213:         version.presence
// 214:       end
// 215:
// 216:       # Split a `.gem` basename into name and version, discarding any trailing
// 217:       # {Gem::Platform} suffix (e.g. `nokogiri-1.16.0-arm64-darwin-22`).
// 218:       sig { params(basename: String).returns([T.nilable(String), T.nilable(String)]) }
// 219:       def self.gem_name_version(basename)
// 220:         deplatformed = basename.sub(GEM_PLATFORM_SUFFIX, "")
// 221:         name, sep, version = deplatformed.rpartition("-")
// 222:         return [nil, nil] if sep.empty? || !version.match?(/\A\d[\w.]*\z/)
// 223:
// 224:         [name, version]
// 225:       end
// 226:     end
// 227:   end
// 228: end
