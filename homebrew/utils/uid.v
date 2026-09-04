module utils

import os

#include <pwd.h>

struct C.passwd {
	pw_dir &char
}

fn C.getpwuid(uid u32) &C.passwd

// Translated from Homebrew/brew `utils/uid.rb`.

// uid_home reads the passwd entry for the process UID, matching Etc.getpwuid
// rather than trusting a potentially overridden HOME environment variable.
pub fn uid_home() ?string {
	$if windows {
		return none
	} $else {
		entry := C.getpwuid(u32(os.getuid()))
		if isnil(entry) || isnil(entry.pw_dir) {
			return none
		}
		return unsafe { cstring_to_vstring(entry.pw_dir) }
	}
}
