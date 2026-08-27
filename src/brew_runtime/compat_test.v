module brew_runtime

import os

fn test_resolve_compatibility_backend_accepts_an_executable() {
	shell := os.find_abs_path_of_executable('sh') or { panic(err) }
	assert resolve_compatibility_backend(shell)! == os.real_path(shell)
}

fn test_resolve_compatibility_backend_rejects_a_missing_executable() {
	if _ := resolve_compatibility_backend('/definitely/missing/brew-v-test-backend') {
		assert false, 'a missing compatibility backend was accepted'
	} else {
		assert err.msg().contains('not executable')
	}
}
