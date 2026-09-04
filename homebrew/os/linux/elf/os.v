module elf

import ruby

// Translated from Homebrew/brew `os/linux/elf/os.rb`.
fn elf_token_start(character u8) bool {
	return character == `_` || (character >= `a` && character <= `z`) || (character >= `A` && character <= `Z`)
}

fn elf_token_character(character u8) bool {
	return elf_token_start(character) || character.is_digit()
}

pub fn expand_elf_dst(input string, reference string, replacement string) string {
	mut output := []u8{}
	mut index := 0
	for index < input.len {
		if input[index] != `$` || index + 1 >= input.len {
			output << input[index]
			index++
			continue
		}
		start := index
		index++
		opening_brace := index < input.len && input[index] == `{`
		if opening_brace {
			index++
		}
		if index >= input.len || !elf_token_start(input[index]) {
			output << input[start..index].bytes()
			continue
		}
		name_start := index
		index++
		for index < input.len && elf_token_character(input[index]) {
			index++
		}
		name := input[name_start..index]
		closing_brace := index < input.len && input[index] == `}`
		if closing_brace {
			index++
		}
		original := input[start..index]
		if name == reference && opening_brace == closing_brace {
			output << replacement.bytes()
		} else {
			output << original.bytes()
		}
	}
	return output.bytestr()
}
