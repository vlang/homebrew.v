module lib

import brew_runtime

// Translated from Homebrew/brew `vendor/bundle/ruby/4.0.0/gems/ruby-macho-6.0.0/lib/macho.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.open(filename)` at line 27.
pub fn ruby_macho_l27_d1_self_open(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.open', ...args)
}

// Ruby method `self.codesign!(filename)` at line 50.
pub fn ruby_macho_l50_d2_self_codesign(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.codesign!', ...args)
}

// Original Ruby source (line-for-line):
// 1: # frozen_string_literal: true
// 2:
// 3: require_relative "macho/utils"
// 4: require_relative "macho/structure"
// 5: require_relative "macho/view"
// 6: require_relative "macho/headers"
// 7: require_relative "macho/code_signing"
// 8: require_relative "macho/load_commands"
// 9: require_relative "macho/sections"
// 10: require_relative "macho/macho_file"
// 11: require_relative "macho/fat_file"
// 12: require_relative "macho/exceptions"
// 13: require_relative "macho/tools"
// 14:
// 15: # The primary namespace for ruby-macho.
// 16: module MachO
// 17:   # release version
// 18:   VERSION = "6.0.0"
// 19:
// 20:   # Opens the given filename as a MachOFile or FatFile, depending on its magic.
// 21:   # @param filename [String] the file being opened
// 22:   # @return [MachOFile] if the file is a Mach-O
// 23:   # @return [FatFile] if the file is a Fat file
// 24:   # @raise [ArgumentError] if the given file does not exist
// 25:   # @raise [TruncatedFileError] if the file is too small to have a valid header
// 26:   # @raise [MagicError] if the file's magic is not valid Mach-O magic
// 27:   def self.open(filename)
// 28:     raise ArgumentError, "#{filename}: no such file" unless File.file?(filename)
// 29:     raise TruncatedFileError unless File.stat(filename).size >= 4
// 30:
// 31:     magic = File.open(filename, "rb") { |f| f.read(4) }.unpack1("N")
// 32:
// 33:     if Utils.fat_magic?(magic)
// 34:       file = FatFile.new(filename)
// 35:     elsif Utils.magic?(magic)
// 36:       file = MachOFile.new(filename)
// 37:     else
// 38:       raise MagicError, magic
// 39:     end
// 40:
// 41:     file
// 42:   end
// 43:
// 44:   # Signs a thin or fat Mach-O using an ad-hoc identity.
// 45:   # Necessary after changing signed Mach-O data because the signature covers
// 46:   # the header, load commands and all bytes preceding the signature.
// 47:   # @param filename [String] the file being opened
// 48:   # @return [void]
// 49:   # @raise [CodeSigningError] if the operation fails
// 50:   def self.codesign!(filename)
// 51:     raise ArgumentError, "#{filename}: no such file" unless File.file?(filename)
// 52:
// 53:     file = MachO.open(filename)
// 54:     file.codesign!
// 55:     file.write!
// 56:     nil
// 57:   rescue MachOError => e
// 58:     raise CodeSigningError, "#{filename}: signing failed: #{e.message}"
// 59:   end
// 60: end
