module language

import brew_runtime

// Translated from Homebrew/brew `language/node.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_accessor `attr_accessor :env_set` at line 17.
pub fn ruby_node_l17_d1_env_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('env_set', ...args)
}

// Ruby attr_accessor `attr_accessor :env_set` at line 17.
pub fn ruby_node_l17_d2_env_set(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('env_set=', ...args)
}

// Ruby method `self.npm_cache_config` at line 21.
pub fn ruby_node_l21_d3_self_npm_cache_config(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.npm_cache_config', ...args)
}

// Ruby method `self.npm_install_security_args(ignore_scripts: true)` at line 26.
pub fn ruby_node_l26_d4_self_npm_install_security_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.npm_install_security_args', ...args)
}

// Ruby method `self.pack_for_installation` at line 38.
pub fn ruby_node_l38_d5_self_pack_for_installation(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.pack_for_installation', ...args)
}

// Ruby method `self.setup_npm_environment` at line 64.
pub fn ruby_node_l64_d6_self_setup_npm_environment(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.setup_npm_environment', ...args)
}

// Ruby method `self.std_npm_install_args(libexec, ignore_scripts: true)` at line 79.
pub fn ruby_node_l79_d7_self_std_npm_install_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.std_npm_install_args', ...args)
}

// Ruby method `self.local_npm_install_args(ignore_scripts: true)` at line 105.
pub fn ruby_node_l105_d8_self_local_npm_install_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.local_npm_install_args', ...args)
}

// Ruby method `node_shebang_rewrite_info(node_path)` at line 132.
pub fn ruby_node_l132_d9_node_shebang_rewrite_info(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('node_shebang_rewrite_info', ...args)
}

// Ruby method `detected_node_shebang(formula = T.cast(self, Formula))` at line 141.
pub fn ruby_node_l141_d10_detected_node_shebang(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('detected_node_shebang', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "release_cooldown"
// 5: require "utils/output"
// 6: require "utils/path"
// 7:
// 8: module Language
// 9:   # Helper functions for Node formulae.
// 10:   #
// 11:   # @api public
// 12:   module Node
// 13:     extend ::Utils::Output::Mixin
// 14:
// 15:     class << self
// 16:       sig { returns(T.nilable(T::Boolean)) }
// 17:       attr_accessor :env_set
// 18:     end
// 19:
// 20:     sig { returns(String) }
// 21:     def self.npm_cache_config
// 22:       "cache=#{HOMEBREW_CACHE}/npm_cache"
// 23:     end
// 24:
// 25:     sig { params(ignore_scripts: T::Boolean).returns(T::Array[String]) }
// 26:     def self.npm_install_security_args(ignore_scripts: true)
// 27:       args = %W[
// 28:         --min-release-age=#{Homebrew::RELEASE_COOLDOWN_DAYS}
// 29:         --#{npm_cache_config}
// 30:       ]
// 31:
// 32:       args << "--ignore-scripts" if ignore_scripts
// 33:
// 34:       args
// 35:     end
// 36:
// 37:     sig { returns(String) }
// 38:     def self.pack_for_installation
// 39:       # Homebrew assumes the buildpath/testpath will always be disposable
// 40:       # and from npm 5.0.0 the logic changed so that when a directory is
// 41:       # fed to `npm install` only symlinks are created linking back to that
// 42:       # directory, consequently breaking that assumption. We require a tarball
// 43:       # because npm install creates a "real" installation when fed a tarball.
// 44:       package = Pathname("package.json")
// 45:       if package.exist?
// 46:         begin
// 47:           pkg_json = JSON.parse(package.read)
// 48:         rescue JSON::ParserError
// 49:           opoo "Could not parse package.json!"
// 50:           raise
// 51:         end
// 52:         prepare_removed = pkg_json["scripts"]&.delete("prepare")
// 53:         prepack_removed = pkg_json["scripts"]&.delete("prepack")
// 54:         postpack_removed = pkg_json["scripts"]&.delete("postpack")
// 55:         package.atomic_write(JSON.pretty_generate(pkg_json)) if prepare_removed || prepack_removed || postpack_removed
// 56:       end
// 57:       output = Utils.popen_read("npm", "pack", "--ignore-scripts")
// 58:       raise "npm failed to pack #{Dir.pwd}" if !$CHILD_STATUS.exitstatus.zero? || output.lines.empty?
// 59:
// 60:       output.lines.fetch(-1).chomp
// 61:     end
// 62:
// 63:     sig { void }
// 64:     def self.setup_npm_environment
// 65:       # guard that this is only run once
// 66:       return if @env_set
// 67:
// 68:       @env_set = T.let(true, T.nilable(T::Boolean))
// 69:       # explicitly use our npm and node-gyp executables instead of the user
// 70:       # managed ones in HOMEBREW_PREFIX/lib/node_modules which might be broken
// 71:       begin
// 72:         ENV.prepend_path "PATH", Formula["node"].opt_libexec/"bin"
// 73:       rescue FormulaUnavailableError
// 74:         nil
// 75:       end
// 76:     end
// 77:
// 78:     sig { params(libexec: Pathname, ignore_scripts: T::Boolean).returns(T::Array[String]) }
// 79:     def self.std_npm_install_args(libexec, ignore_scripts: true)
// 80:       setup_npm_environment
// 81:
// 82:       pack = pack_for_installation
// 83:
// 84:       # npm 7 requires that these dirs exist before install
// 85:       (libexec/"lib").mkpath
// 86:
// 87:       # npm install args for global style module format installed into libexec
// 88:       # Delay packages published in the last day so builds are less likely to
// 89:       # install a freshly compromised npm release or dependency.
// 90:       args = %w[
// 91:         --loglevel=silly
// 92:         --global
// 93:         --build-from-source
// 94:       ] + npm_install_security_args(ignore_scripts:) + %W[
// 95:         --prefix=#{libexec}
// 96:         #{Dir.pwd}/#{pack}
// 97:       ]
// 98:
// 99:       args << "--unsafe-perm" if Process.uid.zero?
// 100:
// 101:       args
// 102:     end
// 103:
// 104:     sig { params(ignore_scripts: T::Boolean).returns(T::Array[String]) }
// 105:     def self.local_npm_install_args(ignore_scripts: true)
// 106:       setup_npm_environment
// 107:       # npm install args for local style module format
// 108:       # Delay packages published in the last day so builds are less likely to
// 109:       # install a freshly compromised npm release or dependency.
// 110:       %w[
// 111:         --loglevel=silly
// 112:         --build-from-source
// 113:       ] + npm_install_security_args(ignore_scripts:)
// 114:     end
// 115:
// 116:     # Mixin module for {Formula} adding shebang rewrite features.
// 117:     module Shebang
// 118:       extend T::Helpers
// 119:
// 120:       requires_ancestor { Formula }
// 121:
// 122:       module_function
// 123:
// 124:       # A regex to match potential shebang permutations.
// 125:       NODE_SHEBANG_REGEX = %r{\A#! ?(?:/usr/bin/(?:env )?)?node( |$)}
// 126:
// 127:       # The length of the longest shebang matching `SHEBANG_REGEX`.
// 128:       NODE_SHEBANG_MAX_LENGTH = T.let("#! /usr/bin/env node ".length, Integer)
// 129:
// 130:       # @private
// 131:       sig { params(node_path: T.any(String, Pathname)).returns(Utils::Shebang::RewriteInfo) }
// 132:       def node_shebang_rewrite_info(node_path)
// 133:         Utils::Shebang::RewriteInfo.new(
// 134:           NODE_SHEBANG_REGEX,
// 135:           NODE_SHEBANG_MAX_LENGTH,
// 136:           "#{node_path}\\1",
// 137:         )
// 138:       end
// 139:
// 140:       sig { params(formula: Formula).returns(Utils::Shebang::RewriteInfo) }
// 141:       def detected_node_shebang(formula = T.cast(self, Formula))
// 142:         node_deps = formula.deps.select(&:required?).map(&:name).grep(/^node(@.+)?$/)
// 143:         raise ShebangDetectionError.new("Node", "formula does not depend on Node") if node_deps.empty?
// 144:         raise ShebangDetectionError.new("Node", "formula has multiple Node dependencies") if node_deps.length > 1
// 145:
// 146:         node_shebang_rewrite_info(Utils::Path.formula_opt_bin(node_deps.first)/"node")
// 147:       end
// 148:     end
// 149:   end
// 150: end
