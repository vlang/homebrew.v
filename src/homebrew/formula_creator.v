module homebrew

import brew_runtime

// Translated from Homebrew/brew `formula_creator.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_accessor `attr_accessor :name` at line 15.
pub fn ruby_formula_creator_l15_d1_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name', ...args)
}

// Ruby attr_accessor `attr_accessor :name` at line 15.
pub fn ruby_formula_creator_l15_d2_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('name=', ...args)
}

// Ruby attr_reader `attr_reader :version` at line 18.
pub fn ruby_formula_creator_l18_d3_version(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('version', ...args)
}

// Ruby attr_reader `attr_reader :url` at line 21.
pub fn ruby_formula_creator_l21_d4_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('url', ...args)
}

// Ruby attr_reader `attr_reader :head` at line 24.
pub fn ruby_formula_creator_l24_d5_head(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('head', ...args)
}

// Ruby method `initialize(url:, name: nil, version: nil, tap: nil, mode: nil, license: nil, fetch: false, head: false)` at line 30.
pub fn ruby_formula_creator_l30_d6_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `verify_tap_available!` at line 106.
pub fn ruby_formula_creator_l106_d7_verify_tap_available(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('verify_tap_available!', ...args)
}

// Ruby method `write_formula!` at line 111.
pub fn ruby_formula_creator_l111_d8_write_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('write_formula!', ...args)
}

// Ruby method `latest_versioned_formula(name)` at line 154.
pub fn ruby_formula_creator_l154_d9_latest_versioned_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('latest_versioned_formula', ...args)
}

// Ruby method `template` at line 162.
pub fn ruby_formula_creator_l162_d10_template(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('template', ...args)
}

// Ruby method `install` at line 225.
pub fn ruby_formula_creator_l225_d11_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "digest"
// 5: require "erb"
// 6: require "utils/github"
// 7: require "utils/output"
// 8:
// 9: module Homebrew
// 10:   # Class for generating a formula from a template.
// 11:   class FormulaCreator
// 12:     include Utils::Output::Mixin
// 13:
// 14:     sig { returns(String) }
// 15:     attr_accessor :name
// 16:
// 17:     sig { returns(Version) }
// 18:     attr_reader :version
// 19:
// 20:     sig { returns(String) }
// 21:     attr_reader :url
// 22:
// 23:     sig { returns(T::Boolean) }
// 24:     attr_reader :head
// 25:
// 26:     sig {
// 27:       params(url: String, name: T.nilable(String), version: T.nilable(String), tap: T.nilable(String),
// 28:              mode: T.nilable(Symbol), license: T.nilable(String), fetch: T::Boolean, head: T::Boolean).void
// 29:     }
// 30:     def initialize(url:, name: nil, version: nil, tap: nil, mode: nil, license: nil, fetch: false, head: false)
// 31:       @url = url
// 32:       @mode = mode
// 33:       @license = license
// 34:       @fetch = fetch
// 35:
// 36:       tap = if tap.blank?
// 37:         CoreTap.instance
// 38:       else
// 39:         Tap.fetch(tap)
// 40:       end
// 41:       @tap = T.let(tap, Tap)
// 42:
// 43:       if (match_github = url.match %r{github\.com/(?<user>[^/]+)/(?<repo>[^/]+).*})
// 44:         user = T.must(match_github[:user])
// 45:         repository = T.must(match_github[:repo])
// 46:         if repository.end_with?(".git")
// 47:           # e.g. https://github.com/Homebrew/brew.git
// 48:           repository.delete_suffix!(".git")
// 49:           head = true
// 50:         end
// 51:         odebug "github: #{user} #{repository} head:#{head}"
// 52:         if name.blank?
// 53:           name = repository
// 54:           odebug "name from github: #{name}"
// 55:         end
// 56:       elsif name.blank?
// 57:         stem = Pathname.new(url).stem
// 58:         name = if stem.start_with?("index.cgi") && stem.include?("=")
// 59:           # special cases first
// 60:           # gitweb URLs e.g. http://www.codesrc.com/gitweb/index.cgi?p=libzipper.git;a=summary
// 61:           stem.rpartition("=").last
// 62:         else
// 63:           # e.g. http://digit-labs.org/files/tools/synscan/releases/synscan-5.02.tar.gz
// 64:           pathver = Version.parse(stem).to_s
// 65:           stem.sub(/[-_.]?#{Regexp.escape(pathver)}$/, "")
// 66:         end
// 67:         odebug "name from url: #{name}"
// 68:       end
// 69:       @name = T.let(name, String)
// 70:       @head = head
// 71:
// 72:       if version.present?
// 73:         version = Version.new(version)
// 74:         odebug "version from user: #{version}"
// 75:       else
// 76:         version = Version.detect(url)
// 77:         odebug "version from url: #{version}"
// 78:       end
// 79:
// 80:       if fetch && user && repository
// 81:         github = GitHub.repository(user, repository)
// 82:
// 83:         if version.null? && !head
// 84:           begin
// 85:             latest_release = GitHub.get_latest_release(user, repository)
// 86:             version = Version.new(latest_release.fetch("tag_name"))
// 87:             odebug "github: version from latest_release: #{version}"
// 88:
// 89:             @url = "https://github.com/#{user}/#{repository}/archive/refs/tags/#{version}.tar.gz"
// 90:             odebug "github: url changed to source archive #{@url}"
// 91:           rescue GitHub::API::HTTPNotFoundError
// 92:             odebug "github: latest_release lookup failed: #{url}"
// 93:           end
// 94:         end
// 95:       end
// 96:       @github = T.let(github, T.untyped)
// 97:       @version = T.let(version, Version)
// 98:
// 99:       @sha256 = T.let(nil, T.nilable(String))
// 100:       @desc = T.let(nil, T.nilable(String))
// 101:       @homepage = T.let(nil, T.nilable(String))
// 102:       @license = T.let(nil, T.nilable(String))
// 103:     end
// 104:
// 105:     sig { void }
// 106:     def verify_tap_available!
// 107:       raise TapUnavailableError, @tap.name unless @tap.installed?
// 108:     end
// 109:
// 110:     sig { returns(Pathname) }
// 111:     def write_formula!
// 112:       raise ArgumentError, "name is blank!" if @name.blank?
// 113:       raise ArgumentError, "tap is blank!" if @tap.blank?
// 114:
// 115:       path = @tap.new_formula_path(@name)
// 116:       raise "#{path} already exists" if path.exist?
// 117:
// 118:       if @version.nil? || @version.null?
// 119:         odie "Version cannot be determined from URL. Explicitly set the version with `--set-version` instead."
// 120:       end
// 121:
// 122:       if @fetch
// 123:         unless @head
// 124:           r = Resource.new
// 125:           r.url(@url)
// 126:           r.owner = self
// 127:           filepath = r.fetch
// 128:           html_doctype_prefix = "<!doctype html"
// 129:           # Number of bytes to read from file start to ensure it is not HTML.
// 130:           # HTML may start with arbitrary number of whitespace lines.
// 131:           bytes_to_read = 100
// 132:           if File.read(filepath, bytes_to_read).strip.downcase.start_with?(html_doctype_prefix)
// 133:             raise "Downloaded URL is not archive"
// 134:           end
// 135:
// 136:           @sha256 = T.let(filepath.sha256, T.nilable(String))
// 137:         end
// 138:
// 139:         if @github
// 140:           @desc = @github["description"]
// 141:           @homepage = @github["homepage"].presence || "https://github.com/#{@github["full_name"]}"
// 142:           @license = @github["license"]["spdx_id"] if @github["license"]
// 143:         end
// 144:       end
// 145:
// 146:       path.dirname.mkpath
// 147:       path.write ERB.new(template, trim_mode: ">").result(binding)
// 148:       path
// 149:     end
// 150:
// 151:     private
// 152:
// 153:     sig { params(name: String).returns(String) }
// 154:     def latest_versioned_formula(name)
// 155:       name_prefix = "#{name}@"
// 156:       CoreTap.instance.formula_names
// 157:              .select { |f| f.start_with?(name_prefix) }
// 158:              .max_by { |v| Gem::Version.new(v.sub(name_prefix, "")) } || "python"
// 159:     end
// 160:
// 161:     sig { returns(String) }
// 162:     def template
// 163:       <<~ERB
// 164:         # Documentation: https://docs.brew.sh/Formula-Cookbook
// 165:         #                https://docs.brew.sh/rubydoc/Formula
// 166:         # PLEASE REMOVE ALL GENERATED COMMENTS BEFORE SUBMITTING YOUR PULL REQUEST!
// 167:         class #{Formulary.class_s(name)} < Formula
// 168:         <% if @mode == :python %>
// 169:           include Language::Python::Virtualenv
// 170:
// 171:         <% end %>
// 172:           desc "#{@desc}"
// 173:           homepage "#{@homepage}"
// 174:         <% unless @head %>
// 175:           url "#{@url}"
// 176:         <% unless @version.detected_from_url? %>
// 177:           version "#{@version.to_s.delete_prefix("v")}"
// 178:         <% end %>
// 179:           sha256 "#{@sha256}"
// 180:         <% end %>
// 181:           license "#{@license}"
// 182:         <% if @head %>
// 183:           head "#{@url}"
// 184:         <% end %>
// 185:
// 186:         <% if @mode == :cabal %>
// 187:           depends_on "cabal-install" => :build
// 188:           depends_on "ghc" => :build
// 189:           depends_on "gmp"
// 190:
// 191:           uses_from_macos "libffi"
// 192:         <% elsif @mode == :cmake %>
// 193:           depends_on "cmake" => :build
// 194:         <% elsif @mode == :crystal %>
// 195:           depends_on "crystal" => :build
// 196:         <% elsif @mode == :go %>
// 197:           depends_on "go" => :build
// 198:         <% elsif @mode == :meson %>
// 199:           depends_on "meson" => :build
// 200:           depends_on "ninja" => :build
// 201:         <% elsif @mode == :node %>
// 202:           depends_on "node"
// 203:         <% elsif @mode == :perl %>
// 204:           uses_from_macos "perl"
// 205:         <% elsif @mode == :python %>
// 206:           depends_on "#{latest_versioned_formula("python")}"
// 207:         <% elsif @mode == :ruby %>
// 208:           depends_on "ruby"
// 209:         <% elsif @mode == :rust %>
// 210:           depends_on "rust" => :build
// 211:         <% elsif @mode == :zig %>
// 212:           depends_on "zig" => :build
// 213:         <% elsif @mode.nil? %>
// 214:           # depends_on "cmake" => :build
// 215:         <% end %>
// 216:
// 217:         <% if @mode == :perl || :python || :ruby %>
// 218:           # Additional dependency
// 219:           # resource "" do
// 220:           #   url ""
// 221:           #   sha256 ""
// 222:           # end
// 223:
// 224:         <% end %>
// 225:           def install
// 226:         <% if @mode == :cabal %>
// 227:             system "cabal", "v2-update"
// 228:             system "cabal", "v2-install", *std_cabal_v2_args
// 229:         <% elsif @mode == :cmake %>
// 230:             system "cmake", "-S", ".", "-B", "build", *std_cmake_args
// 231:             system "cmake", "--build", "build"
// 232:             system "cmake", "--install", "build"
// 233:         <% elsif @mode == :autotools %>
// 234:             # Remove unrecognized options if they cause configure to fail
// 235:             # https://docs.brew.sh/rubydoc/Formula.html#std_configure_args-instance_method
// 236:             system "./configure", "--disable-silent-rules", *std_configure_args
// 237:             system "make", "install" # if this fails, try separate make/make install steps
// 238:         <% elsif @mode == :crystal %>
// 239:             system "shards", "build", "--release"
// 240:             bin.install "bin/#{name}"
// 241:         <% elsif @mode == :go %>
// 242:             system "go", "build", *std_go_args
// 243:         <% elsif @mode == :meson %>
// 244:             system "meson", "setup", "build", *std_meson_args
// 245:             system "meson", "compile", "-C", "build", "--verbose"
// 246:             system "meson", "install", "-C", "build"
// 247:         <% elsif @mode == :node %>
// 248:             system "npm", "install", *std_npm_args
// 249:             bin.install_symlink libexec.glob("bin/*")
// 250:         <% elsif @mode == :perl %>
// 251:             ENV.prepend_create_path "PERL5LIB", libexec/"lib/perl5"
// 252:             ENV.prepend_path "PERL5LIB", libexec/"lib"
// 253:
// 254:             # Stage additional dependency (`Makefile.PL` style).
// 255:             # resource("").stage do
// 256:             #   system "perl", "Makefile.PL", "INSTALL_BASE=\#{libexec}"
// 257:             #   system "make"
// 258:             #   system "make", "install"
// 259:             # end
// 260:
// 261:             # Stage additional dependency (`Build.PL` style).
// 262:             # resource("").stage do
// 263:             #   system "perl", "Build.PL", "--install_base", libexec
// 264:             #   system "./Build"
// 265:             #   system "./Build", "install"
// 266:             # end
// 267:
// 268:             bin.install name
// 269:             bin.env_script_all_files(libexec/"bin", PERL5LIB: ENV["PERL5LIB"])
// 270:         <% elsif @mode == :python %>
// 271:             virtualenv_install_with_resources
// 272:         <% elsif @mode == :ruby %>
// 273:             ENV["BUNDLE_FORCE_RUBY_PLATFORM"] = "1"
// 274:             ENV["BUNDLE_VERSION"] = "system" # Avoid installing Bundler into the keg
// 275:             ENV["BUNDLE_WITHOUT"] = "development test"
// 276:             ENV["GEM_HOME"] = libexec
// 277:
// 278:             system "bundle", "install"
// 279:             system "gem", "build", "\#{name}.gemspec"
// 280:             system "gem", "install", "--ignore-dependencies", "\#{name}-\#{version}.gem"
// 281:
// 282:             bin.install libexec/"bin/\#{name}"
// 283:             bin.env_script_all_files(libexec/"bin", GEM_HOME: ENV["GEM_HOME"])
// 284:         <% elsif @mode == :rust %>
// 285:             system "cargo", "install", *std_cargo_args
// 286:         <% elsif @mode == :zig %>
// 287:             system "zig", "build", *std_zig_args
// 288:         <% else %>
// 289:             # Remove unrecognized options if they cause configure to fail
// 290:             # https://docs.brew.sh/rubydoc/Formula.html#std_configure_args-instance_method
// 291:             system "./configure", "--disable-silent-rules", *std_configure_args
// 292:             # system "cmake", "-S", ".", "-B", "build", *std_cmake_args
// 293:         <% end %>
// 294:           end
// 295:
// 296:           test do
// 297:             # `test do` will create, run in and delete a temporary directory.
// 298:             #
// 299:             # This test will fail and we won't accept that! For Homebrew/homebrew-core
// 300:             # this will need to be a test that verifies the functionality of the
// 301:             # software. Run the test with `brew test #{name}`. Options passed
// 302:             # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
// 303:             #
// 304:             # The installed folder is not in the path, so use the entire path to any
// 305:             # executables being tested: `system bin/"program", "do", "something"`.
// 306:             system "false"
// 307:           end
// 308:         end
// 309:       ERB
// 310:     end
// 311:   end
// 312: end
