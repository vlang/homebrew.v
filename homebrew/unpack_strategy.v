module homebrew

import homebrew.unpack_strategy

// Translated from Homebrew/brew `unpack_strategy.rb`.

// unpack_detect exposes the translated dispatcher to Resource and download
// staging without coupling those callers to Ruby-style compatibility names.
pub fn unpack_detect(path string, options unpack_strategy.DetectOptions) unpack_strategy.Strategy {
	return unpack_strategy.detect(path, options)
}
