module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/typecheck.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 46.
pub fn ruby_typecheck_l46_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `trim_rubocop_rbi(path: HOMEBREW_LIBRARY_PATH/"sorbet/rbi/gems/rubocop@*.rbi")` at line 144.
pub fn ruby_typecheck_l144_d2_trim_rubocop_rbi(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('trim_rubocop_rbi', ...args)
}

// Ruby method `extract_full_name(node)` at line 218.
pub fn ruby_typecheck_l218_d3_extract_full_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extract_full_name', ...args)
}

// Ruby method `extract_constant_path_parts(constant_path)` at line 237.
pub fn ruby_typecheck_l237_d4_extract_constant_path_parts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('extract_constant_path_parts', ...args)
}

// Ruby method `generate_trimmed_rbi(original_content, nodes_to_keep, parsed)` at line 264.
pub fn ruby_typecheck_l264_d5_generate_trimmed_rbi(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('generate_trimmed_rbi', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "abstract_command"
// 5: require "fileutils"
// 6:
// 7: module Homebrew
// 8:   module DevCmd
// 9:     class Typecheck < AbstractCommand
// 10:       include FileUtils
// 11:
// 12:       cmd_args do
// 13:         description <<~EOS
// 14:           Check for typechecking errors using Sorbet.
// 15:         EOS
// 16:         switch "--fix",
// 17:                description: "Automatically fix type errors."
// 18:         switch "-q", "--quiet",
// 19:                description: "Silence all non-critical errors."
// 20:         switch "--update",
// 21:                description: "Update RBI files."
// 22:         switch "--update-all",
// 23:                description: "Update all RBI files rather than just updated gems."
// 24:         switch "--suggest-typed",
// 25:                depends_on:  "--update",
// 26:                description: "Try upgrading `typed` sigils."
// 27:         switch "--lsp",
// 28:                description: "Start the Sorbet LSP server."
// 29:         flag   "--dir=",
// 30:                description: "Typecheck all files in a specific directory."
// 31:         flag   "--file=",
// 32:                description: "Typecheck a single file."
// 33:         flag   "--ignore=",
// 34:                description: "Ignores input files that contain the given string " \
// 35:                             "in their paths (relative to the input path passed to Sorbet)."
// 36:
// 37:         conflicts "--dir", "--file"
// 38:         conflicts "--lsp", "--update"
// 39:         conflicts "--lsp", "--update-all"
// 40:         conflicts "--lsp", "--fix"
// 41:
// 42:         named_args :tap
// 43:       end
// 44:
// 45:       sig { override.void }
// 46:       def run
// 47:         if (args.dir.present? || args.file.present?) && args.named.present?
// 48:           raise UsageError, "Cannot use `--dir` or `--file` when specifying a tap."
// 49:         elsif args.fix? && args.named.present?
// 50:           raise UsageError, "Cannot use `--fix` when specifying a tap."
// 51:         end
// 52:
// 53:         update = args.update? || args.update_all?
// 54:         groups = update ? Homebrew.valid_gem_groups : ["typecheck"]
// 55:         Homebrew.install_bundler_gems!(groups:)
// 56:
// 57:         # Sorbet doesn't use bash privileged mode so we align EUID and UID here.
// 58:         Process::UID.change_privilege(Process.euid) if Process.euid != Process.uid
// 59:
// 60:         HOMEBREW_LIBRARY_PATH.cd do
// 61:           if update
// 62:             workers = args.debug? ? ["--workers=1"] : []
// 63:             safe_system "bundle", "exec", "tapioca", "annotations"
// 64:             safe_system "bundle", "exec", "tapioca", "dsl", *workers
// 65:             # Prefer adding args here: Library/Homebrew/sorbet/tapioca/config.yml
// 66:             tapioca_args = args.update_all? ? ["--all"] : []
// 67:
// 68:             ohai "Updating Tapioca RBI files..."
// 69:             safe_system "bundle", "exec", "tapioca", "gem", *tapioca_args
// 70:
// 71:             ohai "Trimming RuboCop RBI because by default it's massive..."
// 72:             trim_rubocop_rbi
// 73:
// 74:             if args.suggest_typed?
// 75:               ohai "Checking if we can bump Sorbet `typed` sigils..."
// 76:               # --sorbet needed because of https://github.com/Shopify/spoom/issues/488
// 77:               #
// 78:               # Use the native sorbet binary directly to avoid Ruby version conflicts.
// 79:               # spoom's exec uses Bundler.with_unbundled_env which can cause `#!/usr/bin/env ruby`
// 80:               # scripts to use the wrong Ruby version (e.g., system Ruby 2.6 on macOS).
// 81:               sorbet_path = Gem::Specification.find_by_name("sorbet-static").full_gem_path
// 82:               sorbet_bin = File.join(sorbet_path, "libexec", "sorbet")
// 83:               system "bundle", "exec", "spoom", "srb", "bump", "--from", "false", "--to", "true",
// 84:                      "--sorbet", sorbet_bin
// 85:               system "bundle", "exec", "spoom", "srb", "bump", "--from", "true", "--to", "strict",
// 86:                      "--sorbet", sorbet_bin
// 87:             end
// 88:
// 89:             return
// 90:           end
// 91:
// 92:           srb_exec = %w[bundle exec srb tc]
// 93:
// 94:           srb_exec << "--quiet" if args.quiet?
// 95:
// 96:           if args.fix?
// 97:             # Auto-correcting method names is almost always wrong.
// 98:             srb_exec << "--suppress-error-code" << "7003"
// 99:
// 100:             srb_exec << "--autocorrect"
// 101:           end
// 102:
// 103:           if args.lsp?
// 104:             srb_exec << "--lsp"
// 105:             if (watchman = which("watchman", ORIGINAL_PATHS))
// 106:               srb_exec << "--watchman-path" << watchman.to_s
// 107:             else
// 108:               srb_exec << "--disable-watchman"
// 109:             end
// 110:           end
// 111:
// 112:           srb_exec += ["--ignore", args.ignore] if args.ignore.present?
// 113:           if args.file.present? || args.dir.present? || (tap_dirs = args.named.to_paths(only: :tap)).present?
// 114:             cd("sorbet") do
// 115:               path = if (file = args.file.presence)
// 116:                 srb_exec << "--file"
// 117:                 Pathname(file)
// 118:               elsif (dir = args.dir.presence)
// 119:                 srb_exec << "--dir"
// 120:                 Pathname(dir)
// 121:               end
// 122:               if path
// 123:                 srb_exec << if path.absolute?
// 124:                   path.to_path
// 125:                 else
// 126:                   "../#{path}"
// 127:                 end
// 128:               end
// 129:               tap_dirs&.each do |tap_dir|
// 130:                 srb_exec += ["--dir", tap_dir.to_s]
// 131:               end
// 132:             end
// 133:           end
// 134:           success = system(*srb_exec)
// 135:           return if success
// 136:
// 137:           $stderr.puts "Check #{Formatter.url("https://docs.brew.sh/Typechecking")} for " \
// 138:                        "more information on how to resolve these errors."
// 139:           Homebrew.failed = true
// 140:         end
// 141:       end
// 142:
// 143:       sig { params(path: T.any(String, Pathname)).void }
// 144:       def trim_rubocop_rbi(path: HOMEBREW_LIBRARY_PATH/"sorbet/rbi/gems/rubocop@*.rbi")
// 145:         rbi_file = Dir.glob(path).first
// 146:         return unless rbi_file.present?
// 147:         return unless (rbi_path = Pathname.new(rbi_file)).exist?
// 148:
// 149:         require "prism"
// 150:         original_content = rbi_path.read
// 151:         parsed = Prism.parse(original_content)
// 152:         return unless parsed.success?
// 153:
// 154:         allowlist = %w[
// 155:           CopHelper
// 156:           Parser::Source
// 157:           RuboCop::AST::Node
// 158:           RuboCop::AST::NodePattern
// 159:           RuboCop::AST::ProcessedSource
// 160:           RuboCop::CLI
// 161:           RuboCop::Config
// 162:           RuboCop::Cop::AllowedPattern
// 163:           RuboCop::Cop::AllowedMethods
// 164:           RuboCop::Cop::AutoCorrector
// 165:           RuboCop::Cop::AutocorrectLogic
// 166:           RuboCop::Cop::Base
// 167:           RuboCop::Cop::CommentsHelp
// 168:           RuboCop::Cop::ConfigurableFormatting
// 169:           RuboCop::Cop::ConfigurableNaming
// 170:           RuboCop::Cop::Corrector
// 171:           RuboCop::Cop::IgnoredMethods
// 172:           RuboCop::Cop::IgnoredNode
// 173:           RuboCop::Cop::IgnoredPattern
// 174:           RuboCop::Cop::MethodPreference
// 175:           RuboCop::Cop::Offense
// 176:           RuboCop::Cop::RangeHelp
// 177:           RuboCop::Cop::Registry
// 178:           RuboCop::Cop::Util
// 179:           RuboCop::DirectiveComment
// 180:           RuboCop::Error
// 181:           RuboCop::ExcludeLimit
// 182:           RuboCop::Ext::Comment
// 183:           RuboCop::Ext::ProcessedSource
// 184:           RuboCop::Ext::Range
// 185:           RuboCop::FileFinder
// 186:           RuboCop::Formatter::TextUtil
// 187:           RuboCop::Formatter::PathUtil
// 188:           RuboCop::Options
// 189:           RuboCop::ResultCache
// 190:           RuboCop::RSpec::ExpectOffense
// 191:           RuboCop::Runner
// 192:           RuboCop::TargetFinder
// 193:           RuboCop::Version
// 194:         ].freeze
// 195:
// 196:         nodes_to_keep = Set.new
// 197:
// 198:         parsed.value.statements.body.each do |node|
// 199:           case node
// 200:           when Prism::ModuleNode, Prism::ClassNode
// 201:             # Keep if it's in our allowlist or is a top-level essential node.
// 202:             full_name = extract_full_name(node)
// 203:             nodes_to_keep << node if full_name.blank? || allowlist.any? { |name| full_name.start_with?(name) }
// 204:           when Prism::ConstantWriteNode # Keep essential constants.
// 205:             nodes_to_keep << node if node.name.to_s.match?(/^[[:digit:][:upper:]_]+$/)
// 206:           else # Keep other top-level nodes (comments, etc.)
// 207:             nodes_to_keep << node
// 208:           end
// 209:         end
// 210:
// 211:         new_content = generate_trimmed_rbi(original_content, nodes_to_keep, parsed)
// 212:         rbi_path.write(new_content)
// 213:       end
// 214:
// 215:       private
// 216:
// 217:       sig { params(node: Prism::Node).returns(String) }
// 218:       def extract_full_name(node)
// 219:         case node
// 220:         when Prism::ModuleNode, Prism::ClassNode
// 221:           parts = []
// 222:
// 223:           constant_path = node.constant_path
// 224:           if constant_path.is_a?(Prism::ConstantReadNode)
// 225:             parts << constant_path.name.to_s
// 226:           elsif constant_path.is_a?(Prism::ConstantPathNode)
// 227:             parts.concat(extract_constant_path_parts(constant_path))
// 228:           end
// 229:
// 230:           parts.join("::")
// 231:         else
// 232:           ""
// 233:         end
// 234:       end
// 235:
// 236:       sig { params(constant_path: T.any(Prism::ConstantPathNode, Prism::Node)).returns(T::Array[String]) }
// 237:       def extract_constant_path_parts(constant_path)
// 238:         parts = []
// 239:         current = T.let(constant_path, T.nilable(Prism::Node))
// 240:
// 241:         while current
// 242:           case current
// 243:           when Prism::ConstantPathNode
// 244:             parts.unshift(current.name.to_s)
// 245:             current = current.parent
// 246:           when Prism::ConstantReadNode
// 247:             parts.unshift(current.name.to_s)
// 248:             break
// 249:           else
// 250:             break
// 251:           end
// 252:         end
// 253:
// 254:         parts
// 255:       end
// 256:
// 257:       sig {
// 258:         params(
// 259:           original_content: String,
// 260:           nodes_to_keep:    T::Set[Prism::Node],
// 261:           parsed:           Prism::ParseResult,
// 262:         ).returns(String)
// 263:       }
// 264:       def generate_trimmed_rbi(original_content, nodes_to_keep, parsed)
// 265:         lines = original_content.lines
// 266:         output_lines = []
// 267:
// 268:         first_node = parsed.value.statements.body.first
// 269:         if first_node
// 270:           first_line = first_node.location.start_line - 1
// 271:           (0...first_line).each { |i| output_lines << lines[i] if lines[i] }
// 272:         end
// 273:
// 274:         parsed.value.statements.body.each do |node|
// 275:           next unless nodes_to_keep.include?(node)
// 276:
// 277:           start_line = node.location.start_line - 1
// 278:           end_line = node.location.end_line - 1
// 279:
// 280:           (start_line..end_line).each { |i| output_lines << lines[i] if lines[i] }
// 281:           output_lines << "\n"
// 282:         end
// 283:
// 284:         header = <<~EOS.chomp
// 285:           # typed: true
// 286:
// 287:           # This file is autogenerated. Do not edit it by hand.
// 288:           # To regenerate, run `brew typecheck --update rubocop`.
// 289:         EOS
// 290:
// 291:         return header if output_lines.empty?
// 292:
// 293:         output_lines.join
// 294:       end
// 295:     end
// 296:   end
// 297: end
