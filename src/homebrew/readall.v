module homebrew

import brew_runtime

// Translated from Homebrew/brew `readall.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `warn(message, category: nil)` at line 26.
pub fn ruby_readall_l26_d1_warn(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('warn', ...args)
}

// Ruby attr_accessor `attr_accessor :warning_buffer` at line 38.
pub fn ruby_readall_l38_d2_warning_buffer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('warning_buffer', ...args)
}

// Ruby attr_accessor `attr_accessor :warning_buffer` at line 38.
pub fn ruby_readall_l38_d3_warning_buffer(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('warning_buffer=', ...args)
}

// Ruby method `self.valid_ruby_syntax?(ruby_files)` at line 42.
pub fn ruby_readall_l42_d4_self_valid_ruby_syntax(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.valid_ruby_syntax?', ...args)
}

// Ruby method `self.valid_aliases?(alias_dir, formula_dir)` at line 54.
pub fn ruby_readall_l54_d5_self_valid_aliases(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.valid_aliases?', ...args)
}

// Ruby method `self.valid_formulae?(tap, bottle_tag: nil, files: nil)` at line 82.
pub fn ruby_readall_l82_d6_self_valid_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.valid_formulae?', ...args)
}

// Ruby method `self.valid_casks?(tap, os_name: nil, arch: nil, files: nil)` at line 119.
pub fn ruby_readall_l119_d7_self_valid_casks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.valid_casks?', ...args)
}

// Ruby method `self.valid_tap?(tap, aliases: false, no_simulate: false,` at line 184.
pub fn ruby_readall_l184_d8_self_valid_tap(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.valid_tap?', ...args)
}

// Ruby method `self.syntax_errors_or_warnings?(filename)` at line 223.
pub fn ruby_readall_l223_d9_self_syntax_errors_or_warnings(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.syntax_errors_or_warnings?', ...args)
}

// Ruby method `self.parallel_slices_valid?(items, &_block)` at line 256.
pub fn ruby_readall_l256_d10_self_parallel_slices_valid(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.parallel_slices_valid?', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "formula"
// 5: require "cask/cask_loader"
// 6: require "tempfile"
// 7: require "utils/output"
// 8:
// 9: # Helper module for validating syntax in taps.
// 10: module Readall
// 11:   extend T::Generic
// 12:   extend Cachable
// 13:   extend Utils::Output::Mixin
// 14:
// 15:   Cache = type_template { { fixed: T::Hash[Symbol, T.untyped] } }
// 16:
// 17:   private_class_method :cache
// 18:
// 19:   MIN_FILES_PER_WORKER = 4
// 20:   private_constant :MIN_FILES_PER_WORKER
// 21:
// 22:   # Buffers Ruby compile warnings from {.syntax_errors_or_warnings?} so they
// 23:   # can be filtered before being printed to `$stderr`.
// 24:   module WarningBuffer
// 25:     sig { params(message: String, category: T.nilable(Symbol)).void }
// 26:     def warn(message, category: nil)
// 27:       buffer = Readall.warning_buffer
// 28:       buffer ? buffer << message : super
// 29:     end
// 30:   end
// 31:   private_constant :WarningBuffer
// 32:   Warning.singleton_class.prepend(WarningBuffer)
// 33:
// 34:   @warning_buffer = T.let(nil, T.nilable(T::Array[String]))
// 35:
// 36:   class << self
// 37:     sig { returns(T.nilable(T::Array[String])) }
// 38:     attr_accessor :warning_buffer
// 39:   end
// 40:
// 41:   sig { params(ruby_files: T::Array[Pathname]).returns(T::Boolean) }
// 42:   def self.valid_ruby_syntax?(ruby_files)
// 43:     parallel_slices_valid?(ruby_files) do |files|
// 44:       failed = T.let(false, T::Boolean)
// 45:       files.each do |ruby_file|
// 46:         # As a side effect, print syntax errors/warnings to `$stderr`.
// 47:         failed = true if syntax_errors_or_warnings?(ruby_file)
// 48:       end
// 49:       !failed
// 50:     end
// 51:   end
// 52:
// 53:   sig { params(alias_dir: Pathname, formula_dir: Pathname).returns(T::Boolean) }
// 54:   def self.valid_aliases?(alias_dir, formula_dir)
// 55:     return true unless alias_dir.directory?
// 56:
// 57:     formula_basenames = Set.new(formula_dir.glob("**/*.rb").map { |formula_file| formula_file.basename.to_s })
// 58:
// 59:     failed = T.let(false, T::Boolean)
// 60:     alias_dir.each_child do |f|
// 61:       if !f.symlink?
// 62:         onoe "Non-symlink alias: #{f}"
// 63:         failed = true
// 64:       elsif !f.file?
// 65:         onoe "Non-file alias: #{f}"
// 66:         failed = true
// 67:       end
// 68:
// 69:       if formula_basenames.include?("#{f.basename}.rb")
// 70:         onoe "Formula duplicating alias: #{f}"
// 71:         failed = true
// 72:       end
// 73:     end
// 74:     !failed
// 75:   end
// 76:
// 77:   sig {
// 78:     params(
// 79:       tap: Tap, bottle_tag: T.nilable(Utils::Bottles::Tag), files: T.nilable(T::Array[Pathname]),
// 80:     ).returns(T::Boolean)
// 81:   }
// 82:   def self.valid_formulae?(tap, bottle_tag: nil, files: nil)
// 83:     cache[:valid_formulae] ||= {}
// 84:
// 85:     success = T.let(true, T::Boolean)
// 86:     (files || tap.formula_files).each do |file|
// 87:       valid = cache[:valid_formulae][file]
// 88:       next if valid == true || valid&.include?(bottle_tag)
// 89:
// 90:       formula_name = file.basename(".rb").to_s
// 91:       formula_contents = file.read.force_encoding("UTF-8")
// 92:
// 93:       readall_namespace = "ReadallNamespace"
// 94:       readall_formula_class = Formulary.load_formula(formula_name, file, formula_contents, readall_namespace,
// 95:                                                      flags: [], ignore_errors: false)
// 96:       readall_formula = readall_formula_class.new(formula_name, file, :stable, tap:)
// 97:       readall_formula.to_hash
// 98:       cache[:valid_formulae][file] = if readall_formula.on_system_blocks_exist?
// 99:         [bottle_tag, *cache[:valid_formulae][file]]
// 100:       else
// 101:         true
// 102:       end
// 103:     rescue Interrupt
// 104:       raise
// 105:     # Handle all possible exceptions reading formulae.
// 106:     rescue Exception => e # rubocop:disable Lint/RescueException
// 107:       onoe "Invalid formula (#{bottle_tag}): #{file}"
// 108:       $stderr.puts e
// 109:       success = false
// 110:     end
// 111:     success
// 112:   end
// 113:
// 114:   sig {
// 115:     params(
// 116:       tap: Tap, os_name: T.nilable(Symbol), arch: T.nilable(Symbol), files: T.nilable(T::Array[Pathname]),
// 117:     ).returns(T::Boolean)
// 118:   }
// 119:   def self.valid_casks?(tap, os_name: nil, arch: nil, files: nil)
// 120:     validating_linux = if os_name.nil?
// 121:       Homebrew::SimulateSystem.current_os == :linux
// 122:     else
// 123:       os_name == :linux
// 124:     end
// 125:     return true unless validating_linux
// 126:
// 127:     os_and_arch = "Linux"
// 128:     os_and_arch += " on #{(arch == :intel) ? "Intel x86_64" : "ARM64"}" if arch
// 129:
// 130:     success = T.let(true, T::Boolean)
// 131:     (files || tap.cask_files).each do |file|
// 132:       cask = if arch
// 133:         Homebrew::SimulateSystem.with(os: :macos, arch:) do
// 134:           loaded_cask = Cask::CaskLoader.load(file)
// 135:           loaded_cask if loaded_cask.supports_linux?
// 136:         end
// 137:       else
// 138:         Homebrew::SimulateSystem.with(os: :macos) do
// 139:           loaded_cask = Cask::CaskLoader.load(file)
// 140:           loaded_cask if loaded_cask.supports_linux?
// 141:         end
// 142:       end
// 143:       next unless cask
// 144:
// 145:       check_linux_sha256 = lambda do
// 146:         cask.refresh
// 147:         arch_types = cask.depends_on.arch&.map { |cask_arch| cask_arch[:type] }
// 148:         # `depends_on arch:` excludes this architecture, so no Linux
// 149:         # checksum is expected for it.
// 150:         next true if arch_types&.exclude?(Homebrew::SimulateSystem.current_arch)
// 151:
// 152:         !cask.sha256.nil?
// 153:       end
// 154:       linux_sha256_valid = if arch
// 155:         Homebrew::SimulateSystem.with(os: :linux, arch:, &check_linux_sha256)
// 156:       else
// 157:         Homebrew::SimulateSystem.with(os: :linux, &check_linux_sha256)
// 158:       end
// 159:       # No `sha256` matched Linux, so the cask cannot be downloaded there
// 160:       # despite not being marked macOS-only.
// 161:       next if linux_sha256_valid
// 162:
// 163:       onoe "Invalid cask (#{os_and_arch}): #{file}"
// 164:       $stderr.puts "Missing Linux stanzas can leave Linux `sha256` as nil. " \
// 165:                    "Add `depends_on :macos` if this cask is macOS-only or " \
// 166:                    "`depends_on arch:` if it does not support this architecture."
// 167:       success = false
// 168:     rescue Interrupt
// 169:       raise
// 170:     # Handle all possible exceptions reading casks.
// 171:     rescue Exception => e # rubocop:disable Lint/RescueException
// 172:       onoe "Invalid cask (#{os_and_arch}): #{file}"
// 173:       $stderr.puts e
// 174:       success = false
// 175:     end
// 176:     success
// 177:   end
// 178:
// 179:   sig {
// 180:     params(
// 181:       tap: Tap, aliases: T::Boolean, no_simulate: T::Boolean, os_arch_combinations: T::Array[[Symbol, Symbol]],
// 182:     ).returns(T::Boolean)
// 183:   }
// 184:   def self.valid_tap?(tap, aliases: false, no_simulate: false,
// 185:                       os_arch_combinations: OnSystem::ALL_OS_ARCH_COMBINATIONS)
// 186:     success = true
// 187:
// 188:     if aliases
// 189:       valid_aliases = valid_aliases?(tap.alias_dir, tap.formula_dir)
// 190:       success = false unless valid_aliases
// 191:     end
// 192:
// 193:     items = tap.formula_files.map { |file| [:formula, file] } +
// 194:             tap.cask_files.map { |file| [:cask, file] }
// 195:
// 196:     all_files_valid = parallel_slices_valid?(items) do |slice|
// 197:       formula_files = slice.filter_map { |type, file| file if type == :formula }
// 198:       cask_files = slice.filter_map { |type, file| file if type == :cask }
// 199:
// 200:       slice_success = T.let(true, T::Boolean)
// 201:       if no_simulate
// 202:         slice_success = false unless valid_formulae?(tap, files: formula_files)
// 203:         slice_success = false unless valid_casks?(tap, files: cask_files)
// 204:       else
// 205:         os_arch_combinations.each do |os, arch|
// 206:           bottle_tag = Utils::Bottles::Tag.new(system: os, arch:)
// 207:           next unless bottle_tag.valid_combination?
// 208:
// 209:           Homebrew::SimulateSystem.with(os:, arch:) do
// 210:             slice_success = false unless valid_formulae?(tap, bottle_tag:, files: formula_files)
// 211:             slice_success = false unless valid_casks?(tap, os_name: os, arch:, files: cask_files)
// 212:           end
// 213:         end
// 214:       end
// 215:       slice_success
// 216:     end
// 217:     success = false unless all_files_valid
// 218:
// 219:     success
// 220:   end
// 221:
// 222:   sig { params(filename: Pathname).returns(T::Boolean) }
// 223:   private_class_method def self.syntax_errors_or_warnings?(filename)
// 224:     # Compile in-process (much faster than spawning `ruby -c -w` per file),
// 225:     # buffering compile warnings so they can be filtered.
// 226:     error = T.let(nil, T.nilable(String))
// 227:     warnings = self.warning_buffer = []
// 228:     old_verbose = $VERBOSE
// 229:     $VERBOSE = true
// 230:     begin
// 231:       RubyVM::InstructionSequence.compile_file(filename.to_s)
// 232:     rescue ScriptError, ArgumentError => e
// 233:       error = "#{e.message.chomp}\n"
// 234:     ensure
// 235:       $VERBOSE = old_verbose
// 236:       self.warning_buffer = nil
// 237:     end
// 238:
// 239:     # Ignore unnecessary warning about named capture conflicts.
// 240:     # See https://bugs.ruby-lang.org/issues/12359.
// 241:     messages = warnings.grep_v(/named capture conflicts a local variable/).join
// 242:     messages += error if error
// 243:
// 244:     $stderr.print messages
// 245:
// 246:     # Both syntax errors and syntax warnings count as failures.
// 247:     !messages.chomp.empty?
// 248:   end
// 249:
// 250:   sig {
// 251:     type_parameters(:U).params(
// 252:       items:  T::Array[T.type_parameter(:U)],
// 253:       _block: T.proc.params(arg0: T::Array[T.type_parameter(:U)]).returns(T::Boolean),
// 254:     ).returns(T::Boolean)
// 255:   }
// 256:   private_class_method def self.parallel_slices_valid?(items, &_block)
// 257:     require "hardware"
// 258:
// 259:     worker_count = [Hardware::CPU.cores, items.length / MIN_FILES_PER_WORKER].min
// 260:     return yield(items) if worker_count <= 1
// 261:
// 262:     workers = items.each_slice((items.length.to_f / worker_count).ceil).map do |slice|
// 263:       reader, writer = IO.pipe
// 264:       stdout_file = Tempfile.new("readall-stdout")
// 265:       stderr_file = Tempfile.new("readall-stderr")
// 266:       pid = Process.fork do
// 267:         reader.close
// 268:         success = begin
// 269:           # Capture output so parallel workers cannot interleave lines.
// 270:           $stdout = stdout_file.to_io
// 271:           $stderr = stderr_file.to_io
// 272:           yield(slice)
// 273:         rescue Interrupt
// 274:           false
// 275:         # Report any worker exception as a validation failure.
// 276:         rescue Exception => e # rubocop:disable Lint/RescueException
// 277:           $stderr.puts e.full_message
// 278:           false
// 279:         ensure
// 280:           $stdout.flush
// 281:           $stderr.flush
// 282:         end
// 283:         writer.write(Marshal.dump(success))
// 284:         writer.close
// 285:         exit!(true)
// 286:       end
// 287:       writer.close
// 288:       [pid, reader, stdout_file, stderr_file]
// 289:     end
// 290:
// 291:     success = T.let(true, T::Boolean)
// 292:     workers.each do |pid, reader, stdout_file, stderr_file|
// 293:       worker_success = begin
// 294:         # The data being loaded was written by our own forked child process.
// 295:         Marshal.load(reader) # rubocop:disable Security/MarshalLoad
// 296:       rescue EOFError
// 297:         nil
// 298:       end
// 299:       reader.close
// 300:       Process.wait(pid)
// 301:
// 302:       [stdout_file, stderr_file].each(&:rewind)
// 303:       $stdout.print stdout_file.read
// 304:       $stderr.print stderr_file.read
// 305:       [stdout_file, stderr_file].each(&:close!)
// 306:
// 307:       case worker_success
// 308:       when nil
// 309:         onoe "readall worker exited unexpectedly!"
// 310:         success = false
// 311:       when false
// 312:         success = false
// 313:       end
// 314:     end
// 315:     success
// 316:   end
// 317: end
// 318:
// 319: require "extend/os/readall"
