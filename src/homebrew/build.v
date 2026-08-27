module homebrew

import brew_runtime

// Translated from Homebrew/brew `build.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :formula` at line 25.
pub fn ruby_build_l25_d1_formula(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formula', ...args)
}

// Ruby attr_reader `attr_reader :deps` at line 28.
pub fn ruby_build_l28_d2_deps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deps', ...args)
}

// Ruby attr_reader `attr_reader :reqs` at line 31.
pub fn ruby_build_l31_d3_reqs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reqs', ...args)
}

// Ruby attr_reader `attr_reader :args` at line 34.
pub fn ruby_build_l34_d4_args(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('args', ...args)
}

// Ruby method `initialize(formula, options, args:)` at line 37.
pub fn ruby_build_l37_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `effective_build_options_for(dependent)` at line 51.
pub fn ruby_build_l51_d6_effective_build_options_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('effective_build_options_for', ...args)
}

// Ruby method `expand_reqs` at line 58.
pub fn ruby_build_l58_d7_expand_reqs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('expand_reqs', ...args)
}

// Ruby method `expand_deps` at line 69.
pub fn ruby_build_l69_d8_expand_deps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('expand_deps', ...args)
}

// Ruby method `install` at line 83.
pub fn ruby_build_l83_d9_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('install', ...args)
}

// Ruby method `detect_stdlibs` at line 223.
pub fn ruby_build_l223_d10_detect_stdlibs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('detect_stdlibs', ...args)
}

// Ruby method `fixopt(formula)` at line 233.
pub fn ruby_build_l233_d11_fixopt(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fixopt', ...args)
}

// Ruby method `normalize_pod2man_outputs!(formula)` at line 250.
pub fn ruby_build_l250_d12_normalize_pod2man_outputs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('normalize_pod2man_outputs!', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: # This script is loaded by formula_installer as a separate instance.
// 5: # Thrown exceptions are propagated back to the parent process over a pipe
// 6:
// 7: raise "#{__FILE__} must not be loaded via `require`." if $PROGRAM_NAME != __FILE__
// 8:
// 9: old_trap = trap("INT") { exit! 130 }
// 10:
// 11: require_relative "global"
// 12: require "build_options"
// 13: require "keg"
// 14: require "extend/ENV"
// 15: require "cmd/install"
// 16: require "utils/fork"
// 17: require "utils/output"
// 18: require "extend/pathname/write_mkpath_extension"
// 19:
// 20: # A formula build.
// 21: class Build
// 22:   include Utils::Output::Mixin
// 23:
// 24:   sig { returns(Formula) }
// 25:   attr_reader :formula
// 26:
// 27:   sig { returns(T::Array[Dependency]) }
// 28:   attr_reader :deps
// 29:
// 30:   sig { returns(Requirements) }
// 31:   attr_reader :reqs
// 32:
// 33:   sig { returns(Homebrew::Cmd::InstallCmd::Args) }
// 34:   attr_reader :args
// 35:
// 36:   sig { params(formula: Formula, options: Options, args: Homebrew::Cmd::InstallCmd::Args).void }
// 37:   def initialize(formula, options, args:)
// 38:     @formula = formula
// 39:     @formula.build = BuildOptions.new(options, formula.options)
// 40:     @args = args
// 41:     @deps = T.let([], T::Array[Dependency])
// 42:     @reqs = T.let(Requirements.new, Requirements)
// 43:
// 44:     return if args.ignore_dependencies?
// 45:
// 46:     @deps = expand_deps
// 47:     @reqs = expand_reqs
// 48:   end
// 49:
// 50:   sig { params(dependent: Formula).returns(BuildOptions) }
// 51:   def effective_build_options_for(dependent)
// 52:     args  = dependent.build.used_options
// 53:     args |= Tab.for_formula(dependent).used_options
// 54:     BuildOptions.new(args, dependent.options)
// 55:   end
// 56:
// 57:   sig { returns(Requirements) }
// 58:   def expand_reqs
// 59:     formula.recursive_requirements do |dependent, req|
// 60:       dependent = T.cast(dependent, Formula)
// 61:       build = effective_build_options_for(dependent)
// 62:       if req.prune_from_option?(build) || req.prune_if_build_and_not_dependent?(dependent, formula) || req.test?
// 63:         next Dependable::PRUNE
// 64:       end
// 65:     end
// 66:   end
// 67:
// 68:   sig { returns(T::Array[Dependency]) }
// 69:   def expand_deps
// 70:     formula.recursive_dependencies do |dependent, dep|
// 71:       build = effective_build_options_for(T.cast(dependent, Formula))
// 72:       if dep.prune_from_option?(build) ||
// 73:          dep.prune_if_build_and_not_dependent?(T.cast(dependent, Formula), formula) ||
// 74:          (dep.test? && !dep.build?) || dep.implicit?
// 75:         next Dependable::PRUNE
// 76:       elsif dep.build?
// 77:         next Dependable::KEEP_BUT_PRUNE_RECURSIVE_DEPS
// 78:       end
// 79:     end
// 80:   end
// 81:
// 82:   sig { void }
// 83:   def install
// 84:     formula_deps = deps.map(&:to_formula)
// 85:     keg_only_deps = formula_deps.select(&:keg_only?)
// 86:     run_time_deps = deps.reject(&:build?).map(&:to_formula)
// 87:
// 88:     formula_deps.each do |dep|
// 89:       fixopt(dep) unless dep.opt_prefix.directory?
// 90:     end
// 91:
// 92:     ENV.activate_extensions!(env: args.env)
// 93:
// 94:     if superenv?(args.env)
// 95:       superenv = ENV
// 96:       superenv.keg_only_deps = keg_only_deps
// 97:       superenv.deps = formula_deps
// 98:       superenv.run_time_deps = run_time_deps
// 99:       ENV.setup_build_environment(
// 100:         formula:,
// 101:         cc:            args.cc,
// 102:         build_bottle:  args.build_bottle?,
// 103:         bottle_arch:   args.bottle_arch,
// 104:         debug_symbols: args.debug_symbols?,
// 105:       )
// 106:       reqs.each do |req|
// 107:         req.modify_build_environment(
// 108:           env: args.env, cc: args.cc, build_bottle: args.build_bottle?, bottle_arch: args.bottle_arch,
// 109:         )
// 110:       end
// 111:     else
// 112:       ENV.setup_build_environment(
// 113:         formula:,
// 114:         cc:            args.cc,
// 115:         build_bottle:  args.build_bottle?,
// 116:         bottle_arch:   args.bottle_arch,
// 117:         debug_symbols: args.debug_symbols?,
// 118:       )
// 119:       reqs.each do |req|
// 120:         req.modify_build_environment(
// 121:           env: args.env, cc: args.cc, build_bottle: args.build_bottle?, bottle_arch: args.bottle_arch,
// 122:         )
// 123:       end
// 124:
// 125:       keg_only_deps.each do |dep|
// 126:         ENV.prepend_path "PATH", dep.opt_bin.to_s
// 127:         ENV.prepend_path "PKG_CONFIG_PATH", "#{dep.opt_lib}/pkgconfig"
// 128:         ENV.prepend_path "PKG_CONFIG_PATH", "#{dep.opt_share}/pkgconfig"
// 129:         ENV.prepend_path "ACLOCAL_PATH", "#{dep.opt_share}/aclocal"
// 130:         ENV.prepend_path "CMAKE_PREFIX_PATH", dep.opt_prefix.to_s
// 131:         ENV.prepend "LDFLAGS", "-L#{dep.opt_lib}" if dep.opt_lib.directory?
// 132:         ENV.prepend "CPPFLAGS", "-I#{dep.opt_include}" if dep.opt_include.directory?
// 133:       end
// 134:     end
// 135:
// 136:     new_env = {
// 137:       "TMPDIR" => HOMEBREW_TEMP.to_s,
// 138:       "TEMP"   => HOMEBREW_TEMP.to_s,
// 139:       "TMP"    => HOMEBREW_TEMP.to_s,
// 140:     }
// 141:
// 142:     with_env(new_env) do
// 143:       if args.debug? && !Homebrew::EnvConfig.disable_debrew?
// 144:         require "debrew"
// 145:         formula.extend(Debrew::Formula)
// 146:       end
// 147:
// 148:       formula.update_head_version
// 149:
// 150:       formula.brew(
// 151:         fetch:         false,
// 152:         keep_tmp:      args.keep_tmp?,
// 153:         debug_symbols: args.debug_symbols?,
// 154:         interactive:   args.interactive?,
// 155:       ) do
// 156:         with_env(
// 157:           # For head builds, HOMEBREW_FORMULA_PREFIX should include the commit,
// 158:           # which is not known until after the formula has been staged.
// 159:           HOMEBREW_FORMULA_PREFIX:    formula.prefix,
// 160:           # https://reproducible-builds.org/docs/build-path/
// 161:           HOMEBREW_FORMULA_BUILDPATH: formula.buildpath,
// 162:           # https://reproducible-builds.org/docs/source-date-epoch/
// 163:           SOURCE_DATE_EPOCH:          formula.source_modified_time.to_i.to_s,
// 164:           # Avoid make getting confused about timestamps.
// 165:           # https://github.com/Homebrew/homebrew-core/pull/87470
// 166:           TZ:                         "UTC0",
// 167:         ) do
// 168:           if args.git?
// 169:             formula.selective_patch(is_data: false)
// 170:             system "git", "init"
// 171:             system "git", "add", "-A"
// 172:             formula.selective_patch(is_data: true)
// 173:           else
// 174:             formula.patch
// 175:           end
// 176:
// 177:           if args.interactive?
// 178:             ohai "Entering interactive mode..."
// 179:             puts <<~EOS
// 180:               Type `exit` to return and finalize the installation.
// 181:               Install to this prefix: #{formula.prefix}
// 182:             EOS
// 183:
// 184:             if args.git?
// 185:               puts <<~EOS
// 186:                 This directory is now a Git repository. Make your changes and then use:
// 187:                   git diff | pbcopy
// 188:                 to copy the diff to the clipboard.
// 189:               EOS
// 190:             end
// 191:
// 192:             interactive_shell(formula)
// 193:           else
// 194:             formula.prefix.mkpath
// 195:             formula.logs.mkpath
// 196:
// 197:             (formula.logs/"00.options.out").write \
// 198:               "#{formula.full_name} #{formula.build.used_options.sort.join(" ")}".strip
// 199:
// 200:             Pathname.activate_extensions!
// 201:             formula.install
// 202:
// 203:             stdlibs = detect_stdlibs
// 204:             tab = Tab.create(formula, ENV.compiler, stdlibs.first)
// 205:             tab.write
// 206:
// 207:             # Find and link metafiles
// 208:             formula.prefix.install_metafiles T.must(formula.buildpath)
// 209:             if formula.libexec.exist?
// 210:               require "metafiles"
// 211:               no_metafiles = formula.prefix.children.none? { |p| p.file? && Metafiles.copy?(p.basename.to_s) }
// 212:               formula.prefix.install_metafiles formula.libexec if no_metafiles
// 213:             end
// 214:
// 215:             normalize_pod2man_outputs!(formula)
// 216:           end
// 217:         end
// 218:       end
// 219:     end
// 220:   end
// 221:
// 222:   sig { returns(T::Array[Symbol]) }
// 223:   def detect_stdlibs
// 224:     keg = Keg.new(formula.prefix)
// 225:
// 226:     # The stdlib recorded in the install receipt is used during dependency
// 227:     # compatibility checks, so we only care about the stdlib that libraries
// 228:     # link against.
// 229:     keg.detect_cxx_stdlibs(skip_executables: true)
// 230:   end
// 231:
// 232:   sig { params(formula: Formula).void }
// 233:   def fixopt(formula)
// 234:     path = if formula.linked_keg.directory? && formula.linked_keg.symlink?
// 235:       formula.linked_keg.resolved_path
// 236:     elsif formula.prefix.directory?
// 237:       formula.prefix
// 238:     elsif (children = formula.rack.children.presence) && children.size == 1 &&
// 239:           (first_child = children.first) && first_child.directory?
// 240:       first_child
// 241:     else
// 242:       raise
// 243:     end
// 244:     Keg.new(path).optlink(verbose: args.verbose?)
// 245:   rescue
// 246:     raise "#{formula.opt_prefix} not present or broken\nPlease reinstall #{formula.full_name}. Sorry :("
// 247:   end
// 248:
// 249:   sig { params(formula: Formula).void }
// 250:   def normalize_pod2man_outputs!(formula)
// 251:     keg = Keg.new(formula.prefix)
// 252:     keg.normalize_pod2man_outputs!
// 253:   end
// 254: end
// 255:
// 256: begin
// 257:   # Undocumented opt-out for internal use.
// 258:   # We need to allow formulae from paths here due to how we pass them through.
// 259:   ENV["HOMEBREW_INTERNAL_ALLOW_PACKAGES_FROM_PATHS"] = "1"
// 260:
// 261:   formula_path = ARGV.first
// 262:   args = Homebrew::Cmd::InstallCmd.new.args
// 263:   Context.current = args.context
// 264:
// 265:   error_pipe = Utils.forked_child_error_pipe
// 266:
// 267:   trap("INT", old_trap)
// 268:
// 269:   if formula_path&.end_with?(".json")
// 270:     raise "build.rb received an API JSON file as the formula path: #{formula_path}. " \
// 271:           "This usually means the formula source was not downloaded from the API. " \
// 272:           "Try clearing the cache: rm -rf $(brew --cache)/api-source"
// 273:   end
// 274:
// 275:   formula = args.named.to_formulae.fetch(0)
// 276:   options = Options.create(args.flags_only)
// 277:   build   = Build.new(formula, options, args:)
// 278:
// 279:   build.install
// 280: # Any exception means the build did not complete.
// 281: # The `case` for what to do per-exception class is further down.
// 282: rescue Exception => e # rubocop:disable Lint/RescueException
// 283:   Utils.report_forked_child_error(error_pipe, e)
// 284:   exit! 1
// 285: end
