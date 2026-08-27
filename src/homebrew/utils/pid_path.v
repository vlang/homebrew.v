module utils

// Translated from Homebrew/brew `utils/pid_path.rb`.
// The original source is retained below until every stub has a typed V body.

// Original Ruby source (line-for-line):
// 1: #!/usr/bin/env ruby
// 2: # typed: strict
// 3: # frozen_string_literal: true
// 4:
// 5: pid = ARGV[0]&.to_i
// 6: raise "Missing `pid` argument!" unless pid
// 7:
// 8: require "fiddle"
// 9:
// 10: # Canonically, this is a part of libproc.dylib. libproc is however just a symlink to libSystem
// 11: # and some security tools seem to not support aliases from the dyld shared cache and incorrectly flag this.
// 12: libproc = Fiddle.dlopen("/usr/lib/libSystem.B.dylib")
// 13:
// 14: libproc_proc_pidpath_function = Fiddle::Function.new(
// 15:   libproc["proc_pidpath"],
// 16:   [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP, Fiddle::TYPE_UINT32_T],
// 17:   Fiddle::TYPE_INT,
// 18: )
// 19:
// 20: # We have to allocate a (char) buffer of exactly `PROC_PIDPATHINFO_MAXSIZE` to use `proc_pidpath`
// 21: # From `include/sys/proc_info.h`, PROC_PIDPATHINFO_MAXSIZE = 4 * MAXPATHLEN
// 22: # From `include/sys/param.h`, MAXPATHLEN = PATH_MAX
// 23: # From `include/sys/syslimits.h`, PATH_MAX = 1024
// 24: # https://github.com/apple-oss-distributions/xnu/blob/e3723e1f17661b24996789d8afc084c0c3303b26/libsyscall/wrappers/libproc/libproc.c#L268-L275
// 25: buffer_size = 4 * 1024 # PROC_PIDPATHINFO_MAXSIZE = 4 * MAXPATHLEN
// 26: buffer = "\0" * buffer_size
// 27: pointer_to_buffer = Fiddle::Pointer.to_ptr(buffer)
// 28:
// 29: # `proc_pidpath` returns a positive value on success. See:
// 30: # https://stackoverflow.com/a/8149198
// 31: # https://github.com/chromium/chromium/blob/86df41504a235f9369f6f53887da12a718a19db4/base/process/process_handle_mac.cc#L37-L44
// 32: # https://github.com/apple-oss-distributions/xnu/blob/e3723e1f17661b24996789d8afc084c0c3303b26/libsyscall/wrappers/libproc/libproc.c#L263-L283
// 33: return_value = libproc_proc_pidpath_function.call(pid, pointer_to_buffer, buffer_size)
// 34: raise "Call to `proc_pidpath` failed! `proc_pidpath` returned #{return_value}." unless return_value.positive?
// 35:
// 36: puts pointer_to_buffer.to_s.strip
