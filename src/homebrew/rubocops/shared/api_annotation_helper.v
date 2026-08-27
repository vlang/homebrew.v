module shared

import brew_runtime

// Translated from Homebrew/brew `rubocops/shared/api_annotation_helper.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.methods_with_api_level(source_path, level)` at line 156.
pub fn ruby_api_annotation_helper_l156_d1_self_methods_with_api_level(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.methods_with_api_level', ...args)
}

// Ruby attr_reader `m = target_line.match(/\A(?:def\s+(?:self\.)?|attr_reader\s+:|attr_accessor\s+:)(\w+[!?]?)/) ||` at line 174.
pub fn ruby_api_annotation_helper_l174_d2_attr_reader_dynamic(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('attr_reader_dynamic', ...args)
}

// Ruby method `self.homebrew_dir` at line 189.
pub fn ruby_api_annotation_helper_l189_d3_self_homebrew_dir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.homebrew_dir', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module RuboCop
// 5:   module Cop
// 6:     # Shared helpers for reading `@api public/internal/private` annotations
// 7:     # from source files at RuboCop runtime. Results are cached at the class
// 8:     # level so each file is parsed at most once per RuboCop invocation.
// 9:     module ApiAnnotationHelper
// 10:       # Taps that enforce stricter public API rules.
// 11:       OFFICIAL_TAPS = %w[
// 12:         homebrew-core
// 13:         homebrew-cask
// 14:       ].freeze
// 15:
// 16:       # Source files whose `@api` annotations define the public API surface.
// 17:       API_SOURCE_FILES = %w[
// 18:         formula.rb
// 19:         cask/cask.rb
// 20:         cask/dsl.rb
// 21:         utils/path.rb
// 22:       ].freeze
// 23:
// 24:       # Methods documented in docs/Formula-Cookbook.md mapped to their
// 25:       # defining source files (relative to Library/Homebrew/).
// 26:       # Validated by `Homebrew/PublicApiCookbook`
// 27:       # against rubydoc links in `docs/Formula-Cookbook.md`.
// 28:       FORMULA_COOKBOOK_METHODS = T.let({
// 29:         "cd"                    => "extend/pathname.rb",
// 30:         "change_make_var!"      => "utils/string_inreplace_extension.rb",
// 31:         "compatibility_version" => "formula.rb",
// 32:         "conflicts_with"        => "formula.rb",
// 33:         "depends_on"            => "formula.rb",
// 34:         "deprecated_option"     => "formula.rb",
// 35:         "desc"                  => "formula.rb",
// 36:         "change_dylib_id"       => "formula.rb",
// 37:         "env_script_all_files"  => "extend/pathname.rb",
// 38:         "fails_with"            => "formula.rb",
// 39:         "post_install_steps"    => "formula.rb",
// 40:         "head"                  => "formula.rb",
// 41:         "homepage"              => "formula.rb",
// 42:         "install_symlink"       => "extend/pathname.rb",
// 43:         "keg_only"              => "formula.rb",
// 44:         "libexec"               => "formula.rb",
// 45:         "license"               => "formula.rb",
// 46:         "option"                => "formula.rb",
// 47:         "patch"                 => "formula.rb",
// 48:         "resource"              => "formula.rb",
// 49:         "revision"              => "formula.rb",
// 50:         "sha256"                => "formula.rb",
// 51:         "stable"                => "formula.rb",
// 52:         "test"                  => "formula.rb",
// 53:         "testpath"              => "formula.rb",
// 54:         "url"                   => "formula.rb",
// 55:         "uses_from_macos"       => "formula.rb",
// 56:         "version"               => "formula.rb",
// 57:         "version_scheme"        => "formula.rb",
// 58:         "write_env_script"      => "extend/pathname.rb",
// 59:         "write_exec_script"     => "extend/pathname.rb",
// 60:         "write_jar_script"      => "extend/pathname.rb",
// 61:       }.freeze, T::Hash[String, String])
// 62:
// 63:       # Methods documented in docs/Cask-Cookbook.md mapped to their
// 64:       # defining source files (relative to Library/Homebrew/).
// 65:       # Validated by `Homebrew/PublicApiCookbook`
// 66:       # against `@api public` annotations in cask source files.
// 67:       CASK_COOKBOOK_METHODS = T.let({
// 68:         "after_comma"          => "cask/dsl/version.rb",
// 69:         "app"                  => "cask/dsl.rb",
// 70:         "appdir"               => "cask/dsl.rb",
// 71:         "arch"                 => "cask/dsl.rb",
// 72:         "artifact"             => "cask/dsl.rb",
// 73:         "auto_updates"         => "cask/dsl.rb",
// 74:         "before_comma"         => "cask/dsl/version.rb",
// 75:         "binary"               => "cask/dsl.rb",
// 76:         "caveats"              => "cask/dsl.rb",
// 77:         "chomp"                => "cask/dsl/version.rb",
// 78:         "conflicts_with"       => "cask/dsl.rb",
// 79:         "container"            => "cask/dsl.rb",
// 80:         "csv"                  => "cask/dsl/version.rb",
// 81:         "depends_on"           => "cask/dsl.rb",
// 82:         "deprecate!"           => "cask/dsl.rb",
// 83:         "desc"                 => "cask/dsl.rb",
// 84:         "disable!"             => "cask/dsl.rb",
// 85:         "dots_to_hyphens"      => "cask/dsl/version.rb",
// 86:         "font"                 => "cask/dsl.rb",
// 87:         "homepage"             => "cask/dsl.rb",
// 88:         "hyphens_to_dots"      => "cask/dsl/version.rb",
// 89:         "installer"            => "cask/dsl.rb",
// 90:         "language"             => "cask/dsl.rb",
// 91:         "livecheck"            => "cask/dsl.rb",
// 92:         "major"                => "cask/dsl/version.rb",
// 93:         "major_minor"          => "cask/dsl/version.rb",
// 94:         "major_minor_patch"    => "cask/dsl/version.rb",
// 95:         "manpage"              => "cask/dsl.rb",
// 96:         "minor"                => "cask/dsl/version.rb",
// 97:         "minor_patch"          => "cask/dsl/version.rb",
// 98:         "name"                 => "cask/dsl.rb",
// 99:         "no_autobump!"         => "cask/dsl.rb",
// 100:         "no_dividers"          => "cask/dsl/version.rb",
// 101:         "no_dots"              => "cask/dsl/version.rb",
// 102:         "no_hyphens"           => "cask/dsl/version.rb",
// 103:         "no_underscores"       => "cask/dsl/version.rb",
// 104:         "patch"                => "cask/dsl/version.rb",
// 105:         "pkg"                  => "cask/dsl.rb",
// 106:         "postflight"           => "cask/dsl.rb",
// 107:         "preflight"            => "cask/dsl.rb",
// 108:         "rename"               => "cask/dsl.rb",
// 109:         "service"              => "cask/dsl.rb",
// 110:         "sha256"               => "cask/dsl.rb",
// 111:         "stage_only"           => "cask/dsl.rb",
// 112:         "staged_path"          => "cask/dsl.rb",
// 113:         "suite"                => "cask/dsl.rb",
// 114:         "to_s"                 => "cask/cask.rb",
// 115:         "token"                => "cask/cask.rb",
// 116:         "uninstall"            => "cask/dsl.rb",
// 117:         "uninstall_postflight" => "cask/dsl.rb",
// 118:         "uninstall_preflight"  => "cask/dsl.rb",
// 119:         "url"                  => "cask/dsl.rb",
// 120:         "version"              => "cask/dsl.rb",
// 121:         "zap"                  => "cask/dsl.rb",
// 122:       }.freeze, T::Hash[String, String])
// 123:
// 124:       # Methods listed in the "Service block methods" table of
// 125:       # docs/Formula-Cookbook.md. All live in `service.rb`.
// 126:       # Validated by `Homebrew/PublicApiCookbook` against that table and against
// 127:       # the `@api public` annotations in `service.rb` (a 1:1 correspondence).
// 128:       SERVICE_COOKBOOK_METHODS = T.let(%w[
// 129:         cron
// 130:         environment_variables
// 131:         error_log_path
// 132:         input_path
// 133:         interval
// 134:         keep_alive
// 135:         launch_only_once
// 136:         log_path
// 137:         macos_legacy_timers
// 138:         name
// 139:         nice
// 140:         process_type
// 141:         require_root
// 142:         restart_delay
// 143:         root_dir
// 144:         run
// 145:         run_at_load
// 146:         run_type
// 147:         sockets
// 148:         stop_timeout
// 149:         throttle_interval
// 150:         working_dir
// 151:       ].to_set.freeze, T::Set[String])
// 152:
// 153:       # Returns the set of method names annotated with a given `@api` level
// 154:       # (e.g. `"internal"`, `"private"`, `"public"`) in the given Ruby source file.
// 155:       sig { params(source_path: String, level: String).returns(T::Set[String]) }
// 156:       def self.methods_with_api_level(source_path, level)
// 157:         @api_method_cache = T.let(@api_method_cache, T.nilable(T::Hash[String, T::Set[String]]))
// 158:         @api_method_cache ||= {}
// 159:         cache_key = "#{source_path}:#{level}"
// 160:         return @api_method_cache.fetch(cache_key) if @api_method_cache.key?(cache_key)
// 161:
// 162:         methods = T.let(Set.new, T::Set[String])
// 163:         return methods unless File.exist?(source_path)
// 164:
// 165:         lines = File.readlines(source_path)
// 166:         lines.each_with_index do |line, idx|
// 167:           next if line.strip != "# @api #{level}"
// 168:
// 169:           # Scan forward up to 5 lines for a def, attr_reader, or delegate
// 170:           (1..5).each do |offset|
// 171:             target_line = lines[idx + offset]&.strip
// 172:             break if target_line.blank?
// 173:
// 174:             m = target_line.match(/\A(?:def\s+(?:self\.)?|attr_reader\s+:|attr_accessor\s+:)(\w+[!?]?)/) ||
// 175:                 target_line.match(/\Adelegate\s+(\w+[!?]?):/)
// 176:             if m
// 177:               methods.add(m[1].to_s)
// 178:               break
// 179:             end
// 180:           end
// 181:         end
// 182:
// 183:         @api_method_cache[cache_key] = methods.freeze
// 184:         methods
// 185:       end
// 186:
// 187:       # Returns the Homebrew library root path (parent of rubocops/).
// 188:       sig { returns(String) }
// 189:       def self.homebrew_dir
// 190:         File.expand_path("../..", __dir__)
// 191:       end
// 192:     end
// 193:   end
// 194: end
