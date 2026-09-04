module homebrew

import ruby

// Translated from Homebrew/brew `embedded_patch.rb`.

// EmbeddedPatch contains the concrete state and behavior shared by embedded
// string and DATA patches. Ruby inheritance is represented by composition in V.
pub struct EmbeddedPatch {
pub:
	strip         string
	has_directory bool
	directory     string
	owner         ?string
}

pub struct EmbeddedPatchSource {
pub:
	patch    EmbeddedPatch
	filename string
	contents string
}

// new_embedded_patch translates EmbeddedPatch#initialize.
pub fn new_embedded_patch(strip string) EmbeddedPatch {
	return EmbeddedPatch{
		strip: strip
	}
}

// with_directory translates the directory writer while retaining V value
// semantics. An empty directory has the same effect as Ruby's presence check.
pub fn (patch EmbeddedPatch) with_directory(directory string) EmbeddedPatch {
	return EmbeddedPatch{
		strip: patch.strip
		has_directory: true
		directory: directory
		owner: patch.owner
	}
}

pub fn (patch EmbeddedPatch) without_directory() EmbeddedPatch {
	return EmbeddedPatch{
		strip: patch.strip
		owner: patch.owner
	}
}

pub fn (patch EmbeddedPatch) with_owner(owner ?string) EmbeddedPatch {
	return EmbeddedPatch{
		strip: patch.strip
		has_directory: patch.has_directory
		directory: patch.directory
		owner: owner
	}
}

pub fn (patch EmbeddedPatch) external() bool {
	return false
}

// target_directory translates Pathname.pwd followed by the optional directory.
pub fn (patch EmbeddedPatch) target_directory(current_directory string) string {
	if patch.has_directory && patch.directory != '' {
		return ruby.join_path(current_directory, patch.directory)
	}
	return current_directory
}

// apply translates EmbeddedPatch#apply. V passes the abstract filename and
// contents explicitly because the translated descendants use composition.
pub fn (patch EmbeddedPatch) apply(filename string, contents string, current_directory string, homebrew_prefix string) ! {
	_ = filename
	apply_patch_text(contents, patch.strip, patch.target_directory(current_directory), homebrew_prefix)!
}

pub fn (patch EmbeddedPatch) inspect(class_name ...string) string {
	name := if class_name.len == 0 { 'EmbeddedPatch' } else { class_name[0] }
	return '#<${name}: :${patch.strip}>'
}
