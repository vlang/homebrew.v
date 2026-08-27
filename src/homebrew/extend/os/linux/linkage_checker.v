module linux

import brew_runtime

// Translated from Homebrew/brew `extend/os/linux/linkage_checker.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `check_dylibs(rebuild_cache:)` at line 39.
pub fn ruby_linkage_checker_l39_d1_check_dylibs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('check_dylibs', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "compilers"
// 5: require "os/linux/libstdcxx"
// 6:
// 7: module OS
// 8:   module Linux
// 9:     module LinkageChecker
// 10:       extend T::Helpers
// 11:
// 12:       requires_ancestor { ::LinkageChecker }
// 13:
// 14:       # Libraries provided by glibc and gcc.
// 15:       SYSTEM_LIBRARY_ALLOWLIST = %W[
// 16:         ld-linux-x86-64.so.2
// 17:         ld-linux-aarch64.so.1
// 18:         libanl.so.1
// 19:         libatomic.so.1
// 20:         libc.so.6
// 21:         libdl.so.2
// 22:         libm.so.6
// 23:         libmvec.so.1
// 24:         libnss_files.so.2
// 25:         libpthread.so.0
// 26:         libresolv.so.2
// 27:         librt.so.1
// 28:         libthread_db.so.1
// 29:         libutil.so.1
// 30:         libgcc_s.so.1
// 31:         libgomp.so.1
// 32:         #{OS::Linux::Libstdcxx::SONAME}
// 33:         libquadmath.so.0
// 34:       ].freeze
// 35:
// 36:       private
// 37:
// 38:       sig { params(rebuild_cache: T::Boolean).void }
// 39:       def check_dylibs(rebuild_cache:)
// 40:         super
// 41:
// 42:         # glibc and gcc are implicit dependencies.
// 43:         # No other linkage to system libraries is expected or desired.
// 44:         unwanted_system_dylibs.replace(system_dylibs.reject do |s|
// 45:           SYSTEM_LIBRARY_ALLOWLIST.include? File.basename(s)
// 46:         end)
// 47:
// 48:         # We build all formulae with an RPATH that includes the gcc formula's runtime lib directory.
// 49:         # See: https://github.com/Homebrew/brew/blob/e689cc07/Library/Homebrew/extend/os/linux/extend/ENV/super.rb#L53
// 50:         # This results in formulae showing linkage with gcc whenever it is installed, even if no dependency is
// 51:         # declared.
// 52:         # See discussions at:
// 53:         #   https://github.com/Homebrew/brew/pull/13659
// 54:         #   https://github.com/Homebrew/brew/pull/13796
// 55:         # TODO: Find a nicer way to handle this. (e.g. examining the ELF file to determine the required libstdc++.)
// 56:         undeclared_deps.delete("gcc")
// 57:         indirect_deps.delete("gcc")
// 58:       end
// 59:     end
// 60:   end
// 61: end
// 62:
// 63: LinkageChecker.prepend(OS::Linux::LinkageChecker)
