module api

import brew_runtime

// Translated from Homebrew/brew `api/cask_download.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.download(token:, cask_struct:, languages: nil, require_sha: false)` at line 19.
pub fn ruby_cask_download_l19_self_download(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.download', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "api/cask_struct"
// 5: require "cask/cask"
// 6: require "cask/download"
// 7:
// 8: module Homebrew
// 9:   module API
// 10:     module CaskDownload
// 11:       sig {
// 12:         params(
// 13:           token:       String,
// 14:           cask_struct: Homebrew::API::CaskStruct,
// 15:           languages:   T.nilable(T::Array[String]),
// 16:           require_sha: T::Boolean,
// 17:         ).returns(T.nilable(::Cask::Download))
// 18:       }
// 19:       def self.download(token:, cask_struct:, languages: nil, require_sha: false)
// 20:         languages ||= cask_struct.languages.empty? ? [] : ::Cask::Config.new.languages
// 21:         cask_struct = cask_struct.localise(languages)
// 22:         return if cask_struct.languages.any? && cask_struct.language_variations.empty?
// 23:         return if cask_struct.url_args.empty?
// 24:
// 25:         cask = ::Cask::Cask.new(
// 26:           token,
// 27:           tap:                      CoreCaskTap.instance,
// 28:           loaded_from_api:          true,
// 29:           loaded_from_internal_api: true,
// 30:         ) do
// 31:           version cask_struct.version
// 32:           sha256 cask_struct.sha256
// 33:           url(*cask_struct.url_args, **cask_struct.url_kwargs)
// 34:           homepage cask_struct.homepage if cask_struct.homepage?
// 35:           if cask_struct.container?
// 36:             container(nested: cask_struct.container_args[:nested], type: cask_struct.container_args[:type])
// 37:           end
// 38:           # Staging (and the download queue's pre-staging) performs rename
// 39:           # operations through this cask, so they must be preserved here.
// 40:           cask_struct.renames.each do |from, to|
// 41:             rename from, to
// 42:           end
// 43:         end
// 44:
// 45:         ::Cask::Download.new(cask, require_sha:)
// 46:       end
// 47:     end
// 48:   end
// 49: end
