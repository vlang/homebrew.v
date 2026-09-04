module homebrew

import ruby

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

fn string_patch_boundary_value(patch StringPatch) ruby.Value {
	return ruby.structured_value('StringPatch', patch.filename(), {
		'strip': patch.strip
		'text':  patch.text
	})
}

fn string_patch_from_boundary(value ruby.Value) StringPatch {
	if value.type_name != 'StringPatch' {
		panic('expected StringPatch, got ${value.type_name}')
	}
	return new_string_patch(value.attribute('strip') or { panic(err) }, value.attribute('text') or {
		panic(err)
	})
}
