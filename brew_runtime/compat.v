module brew_runtime

import os

const compatibility_backend_environment = 'BREW_V_BACKEND'

// compatibility_backend resolves the native Homebrew command used while the
// retained Ruby command graph is still being replaced by typed V bodies.
pub fn compatibility_backend() !string {
	configured := os.getenv(compatibility_backend_environment)
	if configured != '' {
		return resolve_compatibility_backend(configured)
	}

	current_executable := os.real_path(os.executable())
	for candidate in ['/opt/homebrew/bin/brew', '/home/linuxbrew/.linuxbrew/bin/brew',
		'/usr/local/bin/brew'] {
		backend := resolve_compatibility_backend(candidate) or { continue }
		if os.real_path(backend) != current_executable {
			return backend
		}
	}

	backend := resolve_compatibility_backend('brew')!
	if os.real_path(backend) == current_executable {
		return error('the resolved Homebrew backend points back to brew.v; set ${compatibility_backend_environment}')
	}
	return backend
}

// resolve_compatibility_backend validates either an explicit executable path or
// a command name that can be found on PATH.
pub fn resolve_compatibility_backend(candidate string) !string {
	path := if candidate.contains(os.path_separator) {
		os.real_path(candidate)
	} else {
		os.find_abs_path_of_executable(candidate)!
	}
	if !os.is_file(path) || !os.is_executable(path) {
		return error('Homebrew compatibility backend is not executable: ${candidate}')
	}
	return path
}

// exec_compatibility_backend mirrors brew.rb's final external-command dispatch:
// replace this process and forward every argument without shell interpolation.
pub fn exec_compatibility_backend(arguments []string) ! {
	backend := compatibility_backend()!
	os.execvp(backend, arguments)!
}
