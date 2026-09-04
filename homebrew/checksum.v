module homebrew

import ruby

// Translated from Homebrew/brew `checksum.rb`.

// Checksum is the translated value object used for formula and cask digests.
pub struct Checksum {
pub:
	hexdigest string
}

// new_checksum translates Checksum#initialize by normalising the digest to
// lowercase at construction time.
pub fn new_checksum(hexdigest string) Checksum {
	return Checksum{
		hexdigest: hexdigest.to_lower()
	}
}

// inspect translates Checksum#inspect.
pub fn (checksum Checksum) inspect() string {
	return '#<Checksum ${checksum.hexdigest}>'
}

// str translates the delegated String#to_s operation.
pub fn (checksum Checksum) str() string {
	return checksum.hexdigest
}

// is_empty translates the delegated String#empty? operation.
pub fn (checksum Checksum) is_empty() bool {
	return checksum.hexdigest == ''
}

// length translates the delegated String#length operation. Homebrew checksums
// are ASCII hexadecimal strings, so byte length and Ruby character length agree.
pub fn (checksum Checksum) length() int {
	return checksum.hexdigest.len
}

// character_at translates the integer form of delegated String#[].
pub fn (checksum Checksum) character_at(index int) !string {
	mut normalized_index := index
	if normalized_index < 0 {
		normalized_index += checksum.hexdigest.len
	}
	if normalized_index < 0 || normalized_index >= checksum.hexdigest.len {
		return error('checksum index ${index} is out of bounds')
	}
	return checksum.hexdigest[normalized_index].ascii_str()
}

// equals_string translates the String branch of Checksum#==.
pub fn (checksum Checksum) equals_string(other string) bool {
	return checksum.hexdigest == other.to_lower()
}

// equals translates the Checksum branch of Checksum#==.
pub fn (checksum Checksum) equals(other Checksum) bool {
	return checksum.hexdigest == other.hexdigest
}

fn checksum_from_boundary(arguments []ruby.Value, method string) Checksum {
	if arguments.len == 0 {
		panic('Checksum#${method} requires a receiver')
	}
	return new_checksum(arguments[0].as_string())
}
