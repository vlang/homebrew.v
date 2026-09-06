module homebrew

// Translated from Homebrew/brew `string_patch.rb`.

pub struct StringPatch {
pub:
	strip string
	text  string
}

pub fn new_string_patch(strip string, text string) StringPatch {
	return StringPatch{
		strip: strip
		text: text
	}
}

pub fn (patch StringPatch) filename() string {
	return 'embedded string patch'
}

pub fn (patch StringPatch) contents() string {
	return patch.text
}
