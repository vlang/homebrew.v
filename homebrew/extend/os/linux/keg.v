module linux

// Translated from Homebrew/brew `extend/os/linux/keg.rb`.
pub fn linux_binary_executable_or_library_files(elf_files []string) []string {
	return elf_files.clone()
}
