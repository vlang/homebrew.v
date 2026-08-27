module shared

import brew_runtime

// Translated from Homebrew/brew `rubocops/shared/url_helper.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `audit_urls(urls, regex, &_block)` at line 23.
pub fn ruby_url_helper_l23_d1_audit_urls(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_urls', ...args)
}

// Ruby method `audit_url(type, urls, mirrors, livecheck_urls: [])` at line 52.
pub fn ruby_url_helper_l52_d2_audit_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('audit_url', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "rubocops/shared/helper_functions"
// 5:
// 6: module RuboCop
// 7:   module Cop
// 8:     # This module performs common checks the `homepage` field in both formulae and casks.
// 9:     module UrlHelper
// 10:       include HelperFunctions
// 11:
// 12:       # Yields to block when there is a match.
// 13:       #
// 14:       # @param urls [Array] url/mirror method call nodes
// 15:       # @param regex [Regexp] pattern to match URLs
// 16:       sig {
// 17:         params(
// 18:           urls:   T::Array[T.any(RuboCop::AST::BlockNode, RuboCop::AST::SendNode)],
// 19:           regex:  T.any(Regexp, String),
// 20:           _block: T.proc.params(match_object: MatchData, url: String, index: Integer).void,
// 21:         ).void
// 22:       }
// 23:       def audit_urls(urls, regex, &_block)
// 24:         urls.each_with_index do |url_node, index|
// 25:           if @type == :cask
// 26:             url_string_node = T.cast(url_node, RuboCop::AST::SendNode).first_argument
// 27:             url_string = url_node.source
// 28:           else
// 29:             url_string_node = parameters(url_node).first
// 30:             next unless url_string_node
// 31:
// 32:             url_string = string_content(url_string_node)
// 33:           end
// 34:
// 35:           match_object = regex_match_group(url_string_node, regex)
// 36:           next unless match_object
// 37:
// 38:           offending_node(url_string_node.parent)
// 39:
// 40:           yield match_object, url_string, index
// 41:         end
// 42:       end
// 43:
// 44:       sig {
// 45:         params(
// 46:           type:           Symbol,
// 47:           urls:           T::Array[T.any(RuboCop::AST::BlockNode, RuboCop::AST::SendNode)],
// 48:           mirrors:        T::Array[T.any(RuboCop::AST::BlockNode, RuboCop::AST::SendNode)],
// 49:           livecheck_urls: T::Array[String],
// 50:         ).void
// 51:       }
// 52:       def audit_url(type, urls, mirrors, livecheck_urls: [])
// 53:         @type = T.let(type, T.nilable(Symbol))
// 54:
// 55:         # URLs must be ASCII; IDNs must be punycode
// 56:         ascii_pattern = /[^\p{ASCII}]+/
// 57:         audit_urls(urls, ascii_pattern) do |_, url|
// 58:           problem "Please use the ASCII (Punycode-encoded host, URL-encoded path and query) version of #{url}."
// 59:         end
// 60:
// 61:         # Prefer ftpmirror.gnu.org as suggested by https://www.gnu.org/prep/ftp.en.html
// 62:         gnu_pattern = %r{^(?:https?|ftp)://ftp\.gnu\.org/(.*)}
// 63:         audit_urls(urls, gnu_pattern) do |match, url|
// 64:           problem "#{url} should be: https://ftpmirror.gnu.org/gnu/#{match[1]}"
// 65:         end
// 66:
// 67:         # Fossies upstream requests they aren't used as primary URLs
// 68:         # https://github.com/Homebrew/homebrew-core/issues/14486#issuecomment-307753234
// 69:         fossies_pattern = %r{^https?://fossies\.org/}
// 70:         audit_urls(urls, fossies_pattern) do
// 71:           problem "Please don't use \"fossies.org\" in the `url` (using as a mirror is fine)"
// 72:         end
// 73:
// 74:         apache_pattern = %r{
// 75:           ^https?://
// 76:           (?:dist\.apache\.org/repos/dist/release/
// 77:             |(?:dlcdn|downloads)\.apache\.org/
// 78:             |(?:[^/]*\.)?apache\.org/
// 79:              (?:dyn/(?:.*/)?(?:closer|mirrors)\.cgi\?(?:action=download&)?(?:filename|path)=/?
// 80:                |dist/))
// 81:           (.*)
// 82:         }ix
// 83:         audit_urls(urls, apache_pattern) do |match, url, index|
// 84:           next if livecheck_urls.include?(url)
// 85:
// 86:           fixed = "https://www.apache.org/dyn/closer.lua?path=#{match[1]}"
// 87:           url_parameter_node = parameters(urls.fetch(index)).fetch(0)
// 88:           problem "#{url} should be: #{fixed}" do |corrector|
// 89:             corrector.replace(url_parameter_node.source_range, "\"#{fixed}\"")
// 90:           end
// 91:         end
// 92:
// 93:         version_control_pattern = %r{^(cvs|bzr|hg|fossil)://}
// 94:         audit_urls(urls, version_control_pattern) do |match, _|
// 95:           problem "Use of the \"#{match[1]}://\" scheme is deprecated, pass `using: :#{match[1]}` instead"
// 96:         end
// 97:
// 98:         svn_pattern = %r{^svn\+http://}
// 99:         audit_urls(urls, svn_pattern) do |_, _|
// 100:           problem "Use of the \"svn+http://\" scheme is deprecated, pass `using: :svn` instead"
// 101:         end
// 102:
// 103:         audit_urls(mirrors, /.*/) do |_, mirror|
// 104:           urls.each do |url|
// 105:             url_string = string_content(parameters(url).fetch(0))
// 106:             next unless url_string.eql?(mirror)
// 107:
// 108:             problem "URL should not be duplicated as a mirror: #{url_string}"
// 109:           end
// 110:         end
// 111:
// 112:         urls += mirrors
// 113:
// 114:         # Check a variety of SSL/TLS URLs that don't consistently auto-redirect
// 115:         # or are overly common errors that need to be reduced & fixed over time.
// 116:         http_to_https_patterns = Regexp.union([%r{^http://ftp\.gnu\.org/},
// 117:                                                %r{^http://ftpmirror\.gnu\.org/},
// 118:                                                %r{^http://download\.savannah\.gnu\.org/},
// 119:                                                %r{^http://download-mirror\.savannah\.gnu\.org/},
// 120:                                                %r{^http://(?:[^/]*\.)?apache\.org/},
// 121:                                                %r{^http://code\.google\.com/},
// 122:                                                %r{^http://fossies\.org/},
// 123:                                                %r{^http://mirrors\.kernel\.org/},
// 124:                                                %r{^http://mirrors\.ocf\.berkeley\.edu/},
// 125:                                                %r{^http://(?:[^/]*\.)?bintray\.com/},
// 126:                                                %r{^http://tools\.ietf\.org/},
// 127:                                                %r{^http://launchpad\.net/},
// 128:                                                %r{^http://github\.com/},
// 129:                                                %r{^http://bitbucket\.org/},
// 130:                                                %r{^http://anonscm\.debian\.org/},
// 131:                                                %r{^http://cpan\.metacpan\.org/},
// 132:                                                %r{^http://hackage\.haskell\.org/},
// 133:                                                %r{^http://(?:[^/]*\.)?archive\.org},
// 134:                                                %r{^http://(?:[^/]*\.)?freedesktop\.org},
// 135:                                                %r{^http://(?:[^/]*\.)?mirrorservice\.org/},
// 136:                                                %r{^http://downloads?\.sourceforge\.net/}])
// 137:         audit_urls(urls, http_to_https_patterns) do |_, url, index|
// 138:           # It's fine to have a plain HTTP mirror further down the mirror list.
// 139:           https_url = url.dup.insert(4, "s")
// 140:           https_index = T.let(nil, T.nilable(Integer))
// 141:           audit_urls(urls, https_url) do |_, _, found_https_index|
// 142:             https_index = found_https_index
// 143:           end
// 144:           problem "Please use https:// for #{url}" if !https_index || https_index > index
// 145:         end
// 146:
// 147:         apache_mirror_pattern = %r{^https?://(?:[^/]*\.)?apache\.org/dyn/closer\.(?:cgi|lua)\?path=/?(.*)}i
// 148:         audit_urls(mirrors, apache_mirror_pattern) do |match, mirror|
// 149:           problem "#{mirror} should be: https://archive.apache.org/dist/#{match[1]}"
// 150:         end
// 151:
// 152:         cpan_pattern = %r{^http://search\.mcpan\.org/CPAN/(.*)}i
// 153:         audit_urls(urls, cpan_pattern) do |match, url|
// 154:           problem "#{url} should be: https://cpan.metacpan.org/#{match[1]}"
// 155:         end
// 156:
// 157:         gnome_pattern = %r{^(http|ftp)://ftp\.gnome\.org/pub/gnome/(.*)}i
// 158:         audit_urls(urls, gnome_pattern) do |match, url|
// 159:           problem "#{url} should be: https://download.gnome.org/#{match[2]}"
// 160:         end
// 161:
// 162:         debian_pattern = %r{^git://anonscm\.debian\.org/users/(.*)}i
// 163:         audit_urls(urls, debian_pattern) do |match, url|
// 164:           problem "#{url} should be: https://anonscm.debian.org/git/users/#{match[1]}"
// 165:         end
// 166:
// 167:         # Prefer HTTP/S when possible over FTP protocol due to possible firewalls.
// 168:         mirror_service_pattern = %r{^ftp://ftp\.mirrorservice\.org}
// 169:         audit_urls(urls, mirror_service_pattern) do |_, url|
// 170:           problem "Please use https:// for #{url}"
// 171:         end
// 172:
// 173:         cpan_ftp_pattern = %r{^ftp://ftp\.cpan\.org/pub/CPAN(.*)}i
// 174:         audit_urls(urls, cpan_ftp_pattern) do |match_obj, url|
// 175:           problem "#{url} should be: http://search.cpan.org/CPAN#{match_obj[1]}"
// 176:         end
// 177:
// 178:         # SourceForge url patterns
// 179:         sourceforge_patterns = %r{^https?://.*\b(sourceforge|sf)\.(com|net)}
// 180:         audit_urls(urls, sourceforge_patterns) do |_, url|
// 181:           # Skip if the URL looks like a SVN repository.
// 182:           next if url.include? "/svnroot/"
// 183:           next if url.include? "svn.sourceforge"
// 184:           next if url.include? "/p/"
// 185:
// 186:           if url =~ /(\?|&)use_mirror=/
// 187:             problem "Don't use \"#{Regexp.last_match(1)}use_mirror\" in SourceForge URLs (`url` is #{url})."
// 188:           end
// 189:
// 190:           problem "Don't use \"/download\" in SourceForge URLs (`url` is #{url})." if url.end_with?("/download")
// 191:
// 192:           if url.match?(%r{^https?://(sourceforge|sf)\.}) && !livecheck_urls.include?(url)
// 193:             problem "Use \"https://downloads.sourceforge.net\" to get geolocation (`url` is #{url})."
// 194:           end
// 195:
// 196:           if url.match?(%r{^https?://prdownloads\.})
// 197:             problem "Don't use \"prdownloads\" in SourceForge URLs (`url` is #{url})."
// 198:           end
// 199:
// 200:           if url.match?(%r{^http://\w+\.dl\.})
// 201:             problem "Don't use specific \"dl\" mirrors in SourceForge URLs (`url` is #{url})."
// 202:           end
// 203:
// 204:           # sf.net does HTTPS -> HTTP redirects.
// 205:           if url.match?(%r{^https?://downloads?\.sf\.net})
// 206:             problem "Use \"https://downloads.sourceforge.net\" instead of \"downloads.sf.net\" (`url` is #{url})"
// 207:           end
// 208:         end
// 209:
// 210:         # Debian has an abundance of secure mirrors. Let's not pluck the insecure
// 211:         # one out of the grab bag.
// 212:         unsecure_deb_pattern = %r{^http://http\.debian\.net/debian/(.*)}i
// 213:         audit_urls(urls, unsecure_deb_pattern) do |match, _|
// 214:           problem <<~EOS
// 215:             Please use a secure mirror for Debian URLs.
// 216:             We recommend:
// 217:               https://deb.debian.org/debian/#{match[1]}
// 218:           EOS
// 219:         end
// 220:
// 221:         # Check to use canonical URLs for Debian packages
// 222:         noncanon_deb_pattern =
// 223:           Regexp.union([%r{^https://mirrors\.kernel\.org/debian/},
// 224:                         %r{^https://mirrors\.ocf\.berkeley\.edu/debian/},
// 225:                         %r{^https://(?:[^/]*\.)?mirrorservice\.org/sites/ftp\.debian\.org/debian/}])
// 226:         audit_urls(urls, noncanon_deb_pattern) do |_, url|
// 227:           problem "Please use https://deb.debian.org/debian/ for #{url}"
// 228:         end
// 229:
// 230:         # Check for new-url Google Code download URLs, https:// is preferred
// 231:         google_code_pattern = Regexp.union([%r{^http://[A-Za-z0-9\-.]*\.googlecode\.com/files.*},
// 232:                                             %r{^http://code\.google\.com/}])
// 233:         audit_urls(urls, google_code_pattern) do |_, url|
// 234:           problem "Please use https:// for #{url}"
// 235:         end
// 236:
// 237:         # Check for `git://` GitHub repository URLs, https:// is preferred.
// 238:         git_gh_pattern = %r{^git://[^/]*github\.com/}
// 239:         audit_urls(urls, git_gh_pattern) do |_, url|
// 240:           problem "Please use https:// for #{url}"
// 241:         end
// 242:
// 243:         # Check for `git://` Gitorious repository URLs, https:// is preferred.
// 244:         git_gitorious_pattern = %r{^git://[^/]*gitorious\.org/}
// 245:         audit_urls(urls, git_gitorious_pattern) do |_, url|
// 246:           problem "Please use https:// for #{url}"
// 247:         end
// 248:
// 249:         # Check for `http://` GitHub repository URLs, https:// is preferred.
// 250:         gh_pattern = %r{^http://github\.com/.*\.git$}
// 251:         audit_urls(urls, gh_pattern) do |_, url|
// 252:           problem "Please use https:// for #{url}"
// 253:         end
// 254:
// 255:         # Check for default branch GitHub archives.
// 256:         if type == :formula
// 257:           tarball_gh_pattern = %r{^https://github\.com/.*archive/(main|master)\.(tar\.gz|zip)$}
// 258:           audit_urls(urls, tarball_gh_pattern) do
// 259:             problem "Use versioned rather than branch tarballs for stable checksums."
// 260:           end
// 261:         end
// 262:
// 263:         # Use new-style archive downloads.
// 264:         archive_gh_pattern = %r{https://.*github.*/(?:tar|zip)ball/}
// 265:         audit_urls(urls, archive_gh_pattern) do |_, url|
// 266:           next if url.end_with?(".git")
// 267:
// 268:           problem "Use /archive/ URLs for GitHub tarballs (`url` is #{url})."
// 269:         end
// 270:
// 271:         archive_refs_gh_pattern = %r{https://.*github.+/archive/(?![a-fA-F0-9]{40})(?!refs/(tags|heads)/)(.*)\.tar\.gz$}
// 272:         audit_urls(urls, archive_refs_gh_pattern) do |match, url|
// 273:           next if url.end_with?(".git")
// 274:
// 275:           problem %Q(Use "refs/tags/#{match[2]}" or "refs/heads/#{match[2]}" for GitHub references (`url` is #{url}).)
// 276:         end
// 277:
// 278:         # Don't use GitHub .zip files
// 279:         zip_gh_pattern = %r{https://.*github.*/(archive|releases)/.*\.zip$}
// 280:         audit_urls(urls, zip_gh_pattern) do |_, url|
// 281:           next if url.match? %r{raw.githubusercontent.com/.*/.*/(main|master|HEAD)/}
// 282:           next if url.include?("releases/download")
// 283:           next if url.include?("desktop.githubusercontent.com/releases/")
// 284:
// 285:           problem "Use GitHub tarballs rather than zipballs (`url` is #{url})."
// 286:         end
// 287:
// 288:         # Don't use GitHub codeload URLs
// 289:         codeload_gh_pattern = %r{https?://codeload\.github\.com/(.+)/(.+)/(?:tar\.gz|zip)/(.+)}
// 290:         audit_urls(urls, codeload_gh_pattern) do |match, url|
// 291:           problem <<~EOS
// 292:             Use GitHub archive URLs:
// 293:               https://github.com/#{match[1]}/#{match[2]}/archive/#{match[3]}.tar.gz
// 294:             Rather than codeload:
// 295:               #{url}
// 296:           EOS
// 297:         end
// 298:
// 299:         # Check for Maven Central URLs, prefer HTTPS redirector over specific host
// 300:         maven_pattern = %r{https?://(?:central|repo\d+)\.maven\.org/maven2/(.+)$}
// 301:         audit_urls(urls, maven_pattern) do |match, url|
// 302:           problem "#{url} should be: https://search.maven.org/remotecontent?filepath=#{match[1]}"
// 303:         end
// 304:       end
// 305:     end
// 306:   end
// 307: end
