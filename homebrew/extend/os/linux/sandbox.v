module linux

import homebrew
import os
import homebrew.extend.os.linux.sandbox as linux_sandbox

pub struct LinuxSandboxRunContext {
pub:
	run   homebrew.SandboxRunContext
	apply linux_sandbox.LandlockApplyContext
}

// Translated from Homebrew/brew `extend/os/linux/sandbox.rb`.
