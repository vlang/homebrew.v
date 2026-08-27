module file

import brew_runtime

// Translated from Homebrew/brew `extend/file/atomic.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.atomic_write(file_name, temp_dir = dirname(file_name), &_block)` at line 29.
pub fn ruby_atomic_l29_d1_self_atomic_write(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.atomic_write', ...args)
}

// Ruby method `self.probe_stat_in(dir) # :nodoc:` at line 65.
pub fn ruby_atomic_l65_d2_self_probe_stat_in(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.probe_stat_in', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "fileutils"
// 5:
// 6: class File
// 7:   # Write to a file atomically. Useful for situations where you don't
// 8:   # want other processes or threads to see half-written files.
// 9:   #
// 10:   #   File.atomic_write('important.file') do |file|
// 11:   #     file.write('hello')
// 12:   #   end
// 13:   #
// 14:   # This method needs to create a temporary file. By default it will create it
// 15:   # in the same directory as the destination file. If you don't like this
// 16:   # behavior you can provide a different directory but it must be on the
// 17:   # same physical filesystem as the file you're trying to write.
// 18:   #
// 19:   #   File.atomic_write('/data/something.important', '/data/tmp') do |file|
// 20:   #     file.write('hello')
// 21:   #   end
// 22:   sig {
// 23:     type_parameters(:Out).params(
// 24:       file_name: T.any(Pathname, String),
// 25:       temp_dir:  String,
// 26:       _block:    T.proc.params(arg0: Tempfile).returns(T.type_parameter(:Out)),
// 27:     ).returns(T.type_parameter(:Out))
// 28:   }
// 29:   def self.atomic_write(file_name, temp_dir = dirname(file_name), &_block)
// 30:     require "tempfile" unless defined?(Tempfile)
// 31:
// 32:     Tempfile.open(".#{basename(file_name)}", temp_dir) do |temp_file|
// 33:       temp_file.binmode
// 34:       return_val = yield temp_file
// 35:       temp_file.close
// 36:
// 37:       old_stat = if exist?(file_name)
// 38:         # Get original file permissions
// 39:         stat(file_name)
// 40:       else
// 41:         # If not possible, probe which are the default permissions in the
// 42:         # destination directory.
// 43:         probe_stat_in(dirname(file_name))
// 44:       end
// 45:
// 46:       if old_stat
// 47:         # Set correct permissions on new file
// 48:         begin
// 49:           chown(old_stat.uid, old_stat.gid, T.must(temp_file.path))
// 50:           # This operation will affect filesystem ACL's
// 51:           chmod(old_stat.mode, T.must(temp_file.path))
// 52:         rescue Errno::EPERM, Errno::EACCES
// 53:           # Changing file ownership failed, moving on.
// 54:         end
// 55:       end
// 56:
// 57:       # Overwrite original file with temp file
// 58:       rename(T.must(temp_file.path), file_name)
// 59:       return_val
// 60:     end
// 61:   end
// 62:
// 63:   # Private utility method.
// 64:   sig { params(dir: String).returns(T.nilable(File::Stat)) }
// 65:   private_class_method def self.probe_stat_in(dir) # :nodoc:
// 66:     basename = [
// 67:       ".permissions_check",
// 68:       Thread.current.object_id,
// 69:       Process.pid,
// 70:       rand(1_000_000),
// 71:     ].join(".")
// 72:
// 73:     file_name = join(dir, basename)
// 74:     FileUtils.touch(file_name)
// 75:     stat(file_name)
// 76:   rescue Errno::ENOENT
// 77:     file_name = nil
// 78:   ensure
// 79:     FileUtils.rm_f(file_name) if file_name
// 80:   end
// 81: end
