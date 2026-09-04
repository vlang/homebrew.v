module homebrew

import ruby

// Translated from Homebrew/brew `string_patch.rb`.
// The original source is retained below until every stub has a typed V body.

pub struct StringPatch {
pub:
	strip string
	text  string
}

pub fn new_string_patch(strip string, text string) StringPatch {
	return StringPatch{
		strip: strip
		text:  text
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

// Ruby method `initialize(strip, str)` at line 9.
pub fn ruby_string_patch_l9_d1_initialize(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		panic('StringPatch#initialize requires strip and contents')
	}
	return string_patch_boundary_value(new_string_patch(args[0].as_string(), args[1].as_string()))
}

// Ruby method `filename = "embedded string patch"` at line 15.
pub fn ruby_string_patch_l15_d2_filename(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('StringPatch#filename requires a receiver')
	}
	return ruby.string_value(string_patch_from_boundary(args[0]).filename())
}

// Ruby method `contents` at line 18.
pub fn ruby_string_patch_l18_d3_contents(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		panic('StringPatch#contents requires a receiver')
	}
	return ruby.string_value(string_patch_from_boundary(args[0]).contents())
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "embedded_patch"
// 5:
// 6: # A string containing a patch.
// 7: class StringPatch < EmbeddedPatch
// 8:   sig { params(strip: T.any(String, Symbol), str: String).void }
// 9:   def initialize(strip, str)
// 10:     super(strip)
// 11:     @str = str
// 12:   end
// 13:
// 14:   sig { override.returns(String) }
// 15:   def filename = "embedded string patch"
// 16:
// 17:   sig { override.returns(String) }
// 18:   def contents
// 19:     @str
// 20:   end
// 21: end
