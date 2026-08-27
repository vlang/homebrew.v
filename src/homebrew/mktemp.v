module homebrew

import brew_runtime

// Translated from Homebrew/brew `mktemp.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :tmpdir` at line 14.
pub fn ruby_mktemp_l14_d1_tmpdir(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tmpdir', ...args)
}

// Ruby method `initialize(prefix, retain: false, retain_in_cache: false)` at line 17.
pub fn ruby_mktemp_l17_d2_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `retain!` at line 27.
pub fn ruby_mktemp_l27_d3_retain(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('retain!', ...args)
}

// Ruby method `retain?` at line 33.
pub fn ruby_mktemp_l33_d4_retain(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('retain?', ...args)
}

// Ruby method `retain_in_cache?` at line 39.
pub fn ruby_mktemp_l39_d5_retain_in_cache(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('retain_in_cache?', ...args)
}

// Ruby method `quiet!` at line 45.
pub fn ruby_mktemp_l45_d6_quiet(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('quiet!', ...args)
}

// Ruby method `to_s` at line 50.
pub fn ruby_mktemp_l50_d7_to_s(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('to_s', ...args)
}

// Ruby method `run(chdir: true, &_block)` at line 60.
pub fn ruby_mktemp_l60_d8_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `chmod_rm_rf(path)` at line 114.
pub fn ruby_mktemp_l114_d9_chmod_rm_rf(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('chmod_rm_rf', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/output"
// 5:
// 6: # Performs {Formula#mktemp}'s functionality and tracks the results.
// 7: # Each instance is only intended to be used once.
// 8: # Can also be used to create a temporary directory with the brew instance's group.
// 9: class Mktemp
// 10:   include Utils::Output::Mixin
// 11:
// 12:   # Path to the tmpdir used in this run
// 13:   sig { returns(T.nilable(Pathname)) }
// 14:   attr_reader :tmpdir
// 15:
// 16:   sig { params(prefix: String, retain: T::Boolean, retain_in_cache: T::Boolean).void }
// 17:   def initialize(prefix, retain: false, retain_in_cache: false)
// 18:     @prefix = prefix
// 19:     @retain_in_cache = retain_in_cache
// 20:     @retain = T.let(retain || @retain_in_cache, T::Boolean)
// 21:     @quiet = T.let(false, T::Boolean)
// 22:     @tmpdir = T.let(nil, T.nilable(Pathname))
// 23:   end
// 24:
// 25:   # Instructs this {Mktemp} to retain the staged files.
// 26:   sig { void }
// 27:   def retain!
// 28:     @retain = true
// 29:   end
// 30:
// 31:   # True if the staged temporary files should be retained.
// 32:   sig { returns(T::Boolean) }
// 33:   def retain?
// 34:     @retain
// 35:   end
// 36:
// 37:   # True if the source files should be retained.
// 38:   sig { returns(T::Boolean) }
// 39:   def retain_in_cache?
// 40:     @retain_in_cache
// 41:   end
// 42:
// 43:   # Instructs this Mktemp to not emit messages when retention is triggered.
// 44:   sig { void }
// 45:   def quiet!
// 46:     @quiet = true
// 47:   end
// 48:
// 49:   sig { returns(String) }
// 50:   def to_s
// 51:     "[Mktemp: #{tmpdir} retain=#{@retain} quiet=#{@quiet}]"
// 52:   end
// 53:
// 54:   sig {
// 55:     type_parameters(:U).params(
// 56:       chdir:  T::Boolean,
// 57:       _block: T.proc.params(arg0: Mktemp).returns(T.type_parameter(:U)),
// 58:     ).returns(T.type_parameter(:U))
// 59:   }
// 60:   def run(chdir: true, &_block)
// 61:     prefix_name = @prefix.tr "@", "AT"
// 62:     @tmpdir = if retain_in_cache?
// 63:       tmp_dir = HOMEBREW_CACHE/"Sources/#{prefix_name}"
// 64:       chmod_rm_rf(tmp_dir) # clear out previous staging directory
// 65:       tmp_dir.mkpath
// 66:       tmp_dir
// 67:     else
// 68:       Pathname.new(Dir.mktmpdir("#{prefix_name}-", HOMEBREW_TEMP))
// 69:     end
// 70:
// 71:     # Make sure files inside the temporary directory have the same group as the
// 72:     # brew instance.
// 73:     #
// 74:     # Reference from `man 2 open`
// 75:     # > When a new file is created, it is given the group of the directory which
// 76:     # contains it.
// 77:     group_id = if HOMEBREW_ORIGINAL_BREW_FILE.grpowned?
// 78:       HOMEBREW_ORIGINAL_BREW_FILE.stat.gid
// 79:     else
// 80:       Process.gid
// 81:     end
// 82:     begin
// 83:       @tmpdir.chown(nil, group_id)
// 84:     rescue Errno::EPERM
// 85:       require "etc"
// 86:       group_name = begin
// 87:         Etc.getgrgid(group_id)&.name
// 88:       rescue ArgumentError
// 89:         # Cover for misconfigured NSS setups
// 90:         nil
// 91:       end
// 92:       opoo "Failed setting group \"#{group_name || group_id}\" on #{@tmpdir}"
// 93:     end
// 94:
// 95:     begin
// 96:       if chdir
// 97:         Dir.chdir(@tmpdir) { yield self }
// 98:       else
// 99:         yield self
// 100:       end
// 101:     ensure
// 102:       ignore_interrupts { chmod_rm_rf(@tmpdir) } unless retain?
// 103:     end
// 104:   ensure
// 105:     if retain? && @tmpdir.present? && !@quiet
// 106:       message = retain_in_cache? ? "Source files for debugging available at:" : "Temporary files retained at:"
// 107:       ohai message, @tmpdir.to_s
// 108:     end
// 109:   end
// 110:
// 111:   private
// 112:
// 113:   sig { params(path: Pathname).void }
// 114:   def chmod_rm_rf(path)
// 115:     if path.directory? && !path.symlink?
// 116:       FileUtils.chmod("u+rw", path) if path.owned? # Need permissions in order to see the contents
// 117:       path.children.each { |child| chmod_rm_rf(child) }
// 118:       FileUtils.rmdir(path)
// 119:     else
// 120:       FileUtils.rm_f(path)
// 121:     end
// 122:   rescue
// 123:     nil # Just skip this directory.
// 124:   end
// 125: end
