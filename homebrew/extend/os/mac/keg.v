module mac

import ruby
import homebrew.os.mac as mach
import os

pub struct MacKegCommandResult {
pub:
	success bool
	stderr  string
}

pub type MacKegCommandRunner = fn (string, []string) MacKegCommandResult

pub type MacKegMachSigner = fn (string) !

pub struct MacKegCodesignResult {
pub:
	attempted  bool
	signed     bool
	used_macho bool
	workaround bool
	error      string
}

pub fn mac_keg_link_directories(base []string) []string {
	mut directories := base.clone()
	if 'Frameworks' !in directories {
		directories << 'Frameworks'
	}
	return directories
}

pub fn mac_keg_required_directories(base []string, prefix string) []string {
	mut directories := base.clone()
	frameworks := os.join_path(prefix, 'Frameworks')
	if frameworks !in directories {
		directories << frameworks
	}
	directories.sort()
	return directories
}

pub fn mac_keg_change_dylib_id(mut file mach.MachState, identifier string) !bool {
	if file.dylib_id == identifier {
		return false
	}
	file.change_dylib_id(identifier, false)!
	return true
}

pub fn mac_keg_change_install_name(mut file mach.MachState, old string, replacement string) !bool {
	if old == replacement {
		return false
	}
	file.change_install_name(old, replacement, false)!
	return true
}

pub fn mac_keg_change_rpath(mut file mach.MachState, old string, replacement string) !bool {
	if old == replacement {
		return false
	}
	file.change_rpath(old, replacement, false, false, false)!
	return true
}

pub fn mac_keg_delete_rpath(mut file mach.MachState, rpath string) !bool {
	return file.delete_rpath(rpath, false)! != ''
}

fn mac_keg_walk(path string) []string {
	mut files := []string{}
	entries := os.ls(path) or { return files }
	for entry in entries {
		child := os.join_path(path, entry)
		if os.is_link(child) {
			continue
		}
		if os.is_dir(child) {
			files << mac_keg_walk(child)
		} else if os.is_file(child) {
			files << child
		}
	}
	return files
}

fn mac_keg_is_macho(path string) bool {
	bytes := os.read_bytes(path) or { return false }
	if bytes.len < 4 {
		return false
	}
	magic := [bytes[0], bytes[1], bytes[2], bytes[3]]
	return magic == [u8(0xfe), 0xed, 0xfa, 0xce] || magic == [u8(0xce), 0xfa, 0xed, 0xfe] || magic == [
		u8(0xfe),
		0xed,
		0xfa,
		0xcf,
	] || magic == [u8(0xcf), 0xfa, 0xed, 0xfe] || magic == [u8(0xca), 0xfe, 0xba, 0xbe] || magic == [
		u8(0xbe),
		0xba,
		0xfe,
		0xca,
	]
}

pub fn mac_keg_mach_o_files(path string) []string {
	mut seen_inodes := []u64{}
	mut files := []string{}
	for file in mac_keg_walk(path) {
		if !mac_keg_is_macho(file) {
			continue
		}
		information := os.stat(file) or { continue }
		if information.inode in seen_inodes {
			continue
		}
		seen_inodes << information.inode
		files << file
	}
	return files
}

fn mac_keg_copy_workaround(file string) ! {
	temporary := '${file}.homebrew-codesign-${os.getpid()}'
	os.cp(file, temporary)!
	os.mv(temporary, file)!
}

pub fn mac_keg_codesign_patched_binary(file string, macos_major int, arm bool,
	runner MacKegCommandRunner, signer MacKegMachSigner) MacKegCodesignResult {
	if macos_major < 11 {
		return MacKegCodesignResult{}
	}
	if arm {
		signer(file) or {
			return MacKegCodesignResult{
				attempted: true
				used_macho: true
				error: err.msg()
			}
		}
		return MacKegCodesignResult{
			attempted: true
			signed: true
			used_macho: true
		}
	}
	verification := runner('codesign', ['--verify', file])
	if !verification.stderr.to_lower().contains('invalid signature') {
		return MacKegCodesignResult{}
	}
	sign_arguments := ['--sign', '-', '--force',
		'--preserve-metadata=entitlements,requirements,flags,runtime', file]
	first := runner('codesign', sign_arguments)
	if first.success {
		return MacKegCodesignResult{ attempted: true, signed: true }
	}
	mac_keg_copy_workaround(file) or {
		return MacKegCodesignResult{ attempted: true, error: err.msg() }
	}
	second := runner('codesign', sign_arguments)
	return MacKegCodesignResult{
		attempted: true
		signed: second.success
		workaround: true
		error: if second.success { '' } else { second.stderr }
	}
}

pub fn mac_keg_prepare_debug_symbols(files []string, runner MacKegCommandRunner) ! {
	for file in files {
		result := runner('dsymutil', [file])
		if !result.success {
			return error('Failed to extract symbols from ${file}:\n${result.stderr}')
		}
	}
}

pub fn mac_keg_consistent_symlink_permissions(path string) ![]string {
	mut changed := []string{}
	for file in mac_keg_walk_including_links(path) {
		if !os.is_link(file) {
			continue
		}
		result := ruby.run_command('chmod', ['-h', '0777', '--', file])
		if result.exit_code != 0 {
			return error(result.output)
		}
		changed << file
	}
	return changed
}

fn mac_keg_walk_including_links(path string) []string {
	mut files := []string{}
	entries := os.ls(path) or { return files }
	for entry in entries {
		child := os.join_path(path, entry)
		files << child
		if os.is_dir(child) && !os.is_link(child) {
			files << mac_keg_walk_including_links(child)
		}
	}
	return files
}

fn mac_keg_result_value(result MacKegCodesignResult) ruby.Value {
	return ruby.structured_value('MacKegCodesignResult', result.signed.str(), {
		'attempted':  result.attempted.str()
		'signed':     result.signed.str()
		'used_macho': result.used_macho.str()
		'workaround': result.workaround.str()
		'error':      result.error
	})
}

pub fn mac_keg_mach_state_value(state &mach.MachState) ruby.Value {
	return ruby.structured_value('MachOPathname', state.path, {
		'mach_address': u64(voidptr(state)).str()
	})
}

fn mac_keg_mach_state_from_value(value ruby.Value) &mach.MachState {
	address := value.attributes['mach_address'] or { panic('invalid MachOPathname receiver') }
	return unsafe { &mach.MachState(voidptr(address.u64())) }
}

fn mac_keg_default_runner(command string, arguments []string) MacKegCommandResult {
	result := ruby.run_command(command, arguments)
	return MacKegCommandResult{ success: result.exit_code == 0, stderr: result.output }
}

fn mac_keg_default_signer(file string) ! {
	result := ruby.run_command('codesign', ['--sign', '-', '--force', file])
	if result.exit_code != 0 {
		return error(result.output)
	}
}

// Translated from Homebrew/brew `extend/os/mac/keg.rb`.
