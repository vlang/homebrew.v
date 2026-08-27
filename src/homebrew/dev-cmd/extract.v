module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/extract.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 36.
pub fn ruby_extract_l36_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `formula_at_revision(repo, name, file, rev)` at line 165.
pub fn ruby_extract_l165_d2_formula_at_revision(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula_at_revision', ...args)
}

// Ruby method `with_monkey_patch(&_block)` at line 176.
pub fn ruby_extract_l176_d3_with_monkey_patch(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('with_monkey_patch', ...args)
}

// Ruby alias_method `send(:alias_method, :old_method_missing, :method_missing)` at line 181.
pub fn ruby_extract_l181_d4_old_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('old_method_missing', ...args)
}

// Ruby define_method `define_method(:method_missing) do |*_|` at line 184.
pub fn ruby_extract_l184_d5_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('method_missing', ...args)
}

// Ruby alias_method `send(:alias_method, :old_method_missing, :method_missing)` at line 192.
pub fn ruby_extract_l192_d6_old_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('old_method_missing', ...args)
}

// Ruby define_method `define_method(:method_missing) do |*_|` at line 195.
pub fn ruby_extract_l195_d7_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('method_missing', ...args)
}

// Ruby alias_method `send(:alias_method, :old_method_missing, :method_missing)` at line 203.
pub fn ruby_extract_l203_d8_old_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('old_method_missing', ...args)
}

// Ruby define_method `define_method(:method_missing) do |*_|` at line 206.
pub fn ruby_extract_l206_d9_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('method_missing', ...args)
}

// Ruby alias_method `send(:alias_method, :old_parse_symbol_spec, :parse_symbol_spec)` at line 214.
pub fn ruby_extract_l214_d10_old_parse_symbol_spec(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('old_parse_symbol_spec', ...args)
}

// Ruby define_method `define_method(:parse_symbol_spec) do |*_|` at line 217.
pub fn ruby_extract_l217_d11_parse_symbol_spec(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parse_symbol_spec', ...args)
}

// Ruby alias_method `send(:alias_method, :method_missing, :old_method_missing)` at line 227.
pub fn ruby_extract_l227_d12_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('method_missing', ...args)
}

// Ruby alias_method `send(:alias_method, :method_missing, :old_method_missing)` at line 235.
pub fn ruby_extract_l235_d13_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('method_missing', ...args)
}

// Ruby alias_method `send(:alias_method, :method_missing, :old_method_missing)` at line 243.
pub fn ruby_extract_l243_d14_method_missing(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('method_missing', ...args)
}

// Ruby alias_method `send(:alias_method, :parse_symbol_spec, :old_parse_symbol_spec)` at line 251.
pub fn ruby_extract_l251_d15_parse_symbol_spec(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('parse_symbol_spec', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "utils/git"
// 6: require "formulary"
// 7: require "software_spec"
// 8: require "tap"
// 9:
// 10: module Homebrew
// 11:   module DevCmd
// 12:     class Extract < AbstractCommand
// 13:       BOTTLE_BLOCK_REGEX = /  bottle (?:do.+?end|:[a-z]+)\n\n/m
// 14:
// 15:       cmd_args do
// 16:         usage_banner "`extract` [`--version=`] [`--git-revision=`] [`--force`] <formula> <tap>"
// 17:         description <<~EOS
// 18:           Look through repository history to find the most recent version of <formula> and
// 19:           create a copy in <tap>. Specifically, the command will create the new
// 20:           formula file at <tap>`/Formula/`<formula>`@`<version>`.rb`. If the tap is not
// 21:           installed yet, attempt to install/clone the tap before continuing. To extract
// 22:           a formula from a tap that is not `homebrew/core` use its fully-qualified form of
// 23:           <user>`/`<repo>`/`<formula>.
// 24:         EOS
// 25:         flag   "--git-revision=",
// 26:                description: "Search for the specified <version> of <formula> starting at <revision> instead of HEAD."
// 27:         flag   "--version=",
// 28:                description: "Extract the specified <version> of <formula> instead of the most recent."
// 29:         switch "-f", "--force",
// 30:                description: "Overwrite the destination formula if it already exists."
// 31:
// 32:         named_args [:formula, :tap], number: 2, without_api: true
// 33:       end
// 34:
// 35:       sig { override.void }
// 36:       def run
// 37:         if (tap_with_name = args.named.first&.then { Tap.with_formula_name(it) })
// 38:           source_tap, name = tap_with_name
// 39:         else
// 40:           name = args.named.fetch(0).downcase
// 41:           source_tap = CoreTap.instance
// 42:         end
// 43:         raise TapFormulaUnavailableError.new(source_tap, name) unless source_tap.installed?
// 44:
// 45:         destination_tap = Tap.fetch(args.named.fetch(1))
// 46:         unless Homebrew::EnvConfig.developer?
// 47:           odie "Cannot extract formula to homebrew/core!" if destination_tap.core_tap?
// 48:           odie "Cannot extract formula to homebrew/cask!" if destination_tap.core_cask_tap?
// 49:           odie "Cannot extract formula to the same tap!" if destination_tap == source_tap
// 50:         end
// 51:         destination_tap.install unless destination_tap.installed?
// 52:
// 53:         repo = source_tap.path
// 54:         start_rev = args.git_revision || "HEAD"
// 55:         pattern = if source_tap.core_tap?
// 56:           [source_tap.new_formula_path(name), repo/"Formula/#{name}.rb"].uniq
// 57:         else
// 58:           # A formula can technically live in the root directory of a tap or in any of its subdirectories
// 59:           [repo/"#{name}.rb", repo/"**/#{name}.rb"]
// 60:         end
// 61:
// 62:         rev = T.let(nil, T.nilable(String))
// 63:         if args.version
// 64:           ohai "Searching repository history"
// 65:           version = args.version
// 66:           version_segments = Gem::Version.new(version).segments if Gem::Version.correct?(version)
// 67:           test_formula = T.let(nil, T.nilable(Formula))
// 68:           result = ""
// 69:           loop do
// 70:             rev = rev.nil? ? start_rev : "#{rev}~1"
// 71:             rev, (path,) = Utils::Git.last_revision_commit_of_files(repo, pattern, before_commit: rev)
// 72:             if rev.nil? && source_tap.shallow?
// 73:               odie <<~EOS
// 74:                 Could not find #{name} but #{source_tap} is a shallow clone!
// 75:                 Try again after running:
// 76:                   git -C "#{source_tap.path}" fetch --unshallow
// 77:               EOS
// 78:             elsif rev.nil?
// 79:               odie "Could not find #{name}! The formula or version may not have existed."
// 80:             end
// 81:
// 82:             file = repo/T.must(path)
// 83:             result = Utils::Git.last_revision_of_file(repo, file, before_commit: rev)
// 84:             if result.empty?
// 85:               odebug "Skipping revision #{rev} - file is empty at this revision"
// 86:               next
// 87:             end
// 88:
// 89:             test_formula = formula_at_revision(repo, name, file, rev)
// 90:             break if test_formula.nil? || test_formula.version == version
// 91:
// 92:             if version_segments && Gem::Version.correct?(test_formula.version)
// 93:               test_formula_version_segments = Gem::Version.new(test_formula.version).segments
// 94:               if version_segments.length < test_formula_version_segments.length
// 95:                 odebug "Apply semantic versioning with #{test_formula_version_segments}"
// 96:                 break if version_segments == test_formula_version_segments.first(version_segments.length)
// 97:               end
// 98:             end
// 99:
// 100:             odebug "Trying #{test_formula.version} from revision #{rev} against desired #{version}"
// 101:           end
// 102:           odie "Could not find #{name}! The formula or version may not have existed." if test_formula.nil?
// 103:         else
// 104:           # Search in the root directory of `repository` as well as recursively in all of its subdirectories.
// 105:           files = if start_rev == "HEAD"
// 106:             Dir[repo/"{,**/}"].filter_map do |dir|
// 107:               Pathname.glob("#{dir}/#{name}.rb").find(&:file?)
// 108:             end
// 109:           else
// 110:             []
// 111:           end
// 112:
// 113:           if files.empty?
// 114:             ohai "Searching repository history"
// 115:             rev, (path,) = Utils::Git.last_revision_commit_of_files(repo, pattern, before_commit: start_rev)
// 116:             odie "Could not find #{name}! The formula or version may not have existed." if rev.nil?
// 117:             file = repo/T.must(path)
// 118:             version = T.must(formula_at_revision(repo, name, file, rev)).version
// 119:             result = Utils::Git.last_revision_of_file(repo, file)
// 120:           else
// 121:             file = files.fetch(0).realpath
// 122:             rev = T.let("HEAD", T.nilable(String))
// 123:             version = Formulary.factory(file).version
// 124:             result = File.read(file)
// 125:           end
// 126:         end
// 127:
// 128:         # The class name has to be renamed to match the new filename,
// 129:         # e.g. Foo version 1.2.3 becomes FooAT123 and resides in Foo@1.2.3.rb.
// 130:         class_name = Formulary.class_s(name)
// 131:
// 132:         # The version can only contain digits with decimals in between.
// 133:         version_string = version.to_s
// 134:                                 .sub(/\D*(.+?)\D*$/, "\\1")
// 135:                                 .gsub(/\D+/, ".")
// 136:
// 137:         # Remove any existing version suffixes, as a new one will be added later.
// 138:         name.sub!(/\b@(.*)\z\b/i, "")
// 139:         versioned_name = Formulary.class_s("#{name}@#{version_string}")
// 140:         result.sub!("class #{class_name} < Formula", "class #{versioned_name} < Formula")
// 141:
// 142:         # Remove bottle blocks, as they won't work.
// 143:         result.sub!(BOTTLE_BLOCK_REGEX, "")
// 144:
// 145:         path = destination_tap.path/"Formula/#{name}@#{version_string}.rb"
// 146:         if path.exist?
// 147:           unless args.force?
// 148:             odie <<~EOS
// 149:               Destination formula already exists: #{path}
// 150:               To overwrite it and continue anyways, run:
// 151:                 brew extract --force --version=#{version} #{name} #{destination_tap.name}
// 152:             EOS
// 153:           end
// 154:           odebug "Overwriting existing formula at #{path}"
// 155:           path.delete
// 156:         end
// 157:         ohai "Writing formula for #{name} at #{version} from revision #{rev} to:", path
// 158:         path.dirname.mkpath
// 159:         path.write result
// 160:       end
// 161:
// 162:       private
// 163:
// 164:       sig { params(repo: Pathname, name: String, file: Pathname, rev: String).returns(T.nilable(Formula)) }
// 165:       def formula_at_revision(repo, name, file, rev)
// 166:         return if rev.empty?
// 167:
// 168:         contents = Utils::Git.last_revision_of_file(repo, file, before_commit: rev)
// 169:         contents.gsub!("@url=", "url ")
// 170:         contents.gsub!("require 'brewkit'", "require 'formula'")
// 171:         contents.sub!(BOTTLE_BLOCK_REGEX, "")
// 172:         with_monkey_patch { Formulary.from_contents(name, file, contents, ignore_errors: true) }
// 173:       end
// 174:
// 175:       sig { params(_block: T.proc.void).returns(T.untyped) }
// 176:       def with_monkey_patch(&_block)
// 177:         DependencyCollector.clear_cache
// 178:
// 179:         BottleSpecification.class_eval do
// 180:           if method_defined?(:method_missing) || private_method_defined?(:method_missing)
// 181:             send(:alias_method, :old_method_missing, :method_missing)
// 182:             send(:private, :old_method_missing)
// 183:           end
// 184:           define_method(:method_missing) do |*_|
// 185:             # do nothing
// 186:           end
// 187:           send(:private, :method_missing)
// 188:         end
// 189:
// 190:         Module.class_eval do
// 191:           if method_defined?(:method_missing) || private_method_defined?(:method_missing)
// 192:             send(:alias_method, :old_method_missing, :method_missing)
// 193:             send(:private, :old_method_missing)
// 194:           end
// 195:           define_method(:method_missing) do |*_|
// 196:             # do nothing
// 197:           end
// 198:           send(:private, :method_missing)
// 199:         end
// 200:
// 201:         Resource.class_eval do
// 202:           if method_defined?(:method_missing) || private_method_defined?(:method_missing)
// 203:             send(:alias_method, :old_method_missing, :method_missing)
// 204:             send(:private, :old_method_missing)
// 205:           end
// 206:           define_method(:method_missing) do |*_|
// 207:             # do nothing
// 208:           end
// 209:           send(:private, :method_missing)
// 210:         end
// 211:
// 212:         DependencyCollector.class_eval do
// 213:           if method_defined?(:parse_symbol_spec) || private_method_defined?(:parse_symbol_spec)
// 214:             send(:alias_method, :old_parse_symbol_spec, :parse_symbol_spec)
// 215:             send(:private, :old_parse_symbol_spec)
// 216:           end
// 217:           define_method(:parse_symbol_spec) do |*_|
// 218:             # do nothing
// 219:           end
// 220:           send(:private, :parse_symbol_spec)
// 221:         end
// 222:
// 223:         yield
// 224:       ensure
// 225:         BottleSpecification.class_eval do
// 226:           if method_defined?(:old_method_missing) || private_method_defined?(:old_method_missing)
// 227:             send(:alias_method, :method_missing, :old_method_missing)
// 228:             send(:private, :method_missing)
// 229:             send(:undef_method, :old_method_missing)
// 230:           end
// 231:         end
// 232:
// 233:         Module.class_eval do
// 234:           if method_defined?(:old_method_missing) || private_method_defined?(:old_method_missing)
// 235:             send(:alias_method, :method_missing, :old_method_missing)
// 236:             send(:private, :method_missing)
// 237:             send(:undef_method, :old_method_missing)
// 238:           end
// 239:         end
// 240:
// 241:         Resource.class_eval do
// 242:           if method_defined?(:old_method_missing) || private_method_defined?(:old_method_missing)
// 243:             send(:alias_method, :method_missing, :old_method_missing)
// 244:             send(:private, :method_missing)
// 245:             send(:undef_method, :old_method_missing)
// 246:           end
// 247:         end
// 248:
// 249:         DependencyCollector.class_eval do
// 250:           if method_defined?(:old_parse_symbol_spec) || private_method_defined?(:old_parse_symbol_spec)
// 251:             send(:alias_method, :parse_symbol_spec, :old_parse_symbol_spec)
// 252:             send(:private, :parse_symbol_spec)
// 253:             send(:undef_method, :old_parse_symbol_spec)
// 254:           end
// 255:         end
// 256:         DependencyCollector.clear_cache
// 257:       end
// 258:     end
// 259:   end
// 260: end
