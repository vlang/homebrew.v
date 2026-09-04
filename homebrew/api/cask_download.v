module api

import ruby

// Translated from Homebrew/brew `api/cask_download.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct CaskDownloadRename {
pub:
	from string
	to   string
}

pub struct CaskDownloadStruct {
pub:
	version             string
	sha256              string
	url_args            []string
	url_kwargs          map[string]string
	homepage            string
	container_nested    string
	container_type      string
	languages           []string
	language_variations []string
	renames             []CaskDownloadRename
}

pub struct CaskDownloadCask {
pub:
	token                    string
	version                  string
	sha256                   string
	url_args                 []string
	url_kwargs               map[string]string
	homepage                 string
	container_nested         string
	container_type           string
	renames                  []CaskDownloadRename
	loaded_from_api          bool
	loaded_from_internal_api bool
}

pub struct CaskDownload {
pub:
	cask        CaskDownloadCask
	require_sha bool
	languages   []string
}

pub fn cask_download(token string, cask_struct CaskDownloadStruct, requested_languages []string,
	configured_languages []string, require_sha bool) ?CaskDownload {
	languages := if requested_languages.len > 0 {
		requested_languages.clone()
	} else if cask_struct.languages.len > 0 {
		configured_languages.clone()
	} else {
		[]string{}
	}
	if cask_struct.languages.len > 0 && cask_struct.language_variations.len == 0 {
		return none
	}
	if cask_struct.url_args.len == 0 {
		return none
	}
	return CaskDownload{
		cask: CaskDownloadCask{
			token: token
			version: cask_struct.version
			sha256: cask_struct.sha256
			url_args: cask_struct.url_args.clone()
			url_kwargs: cask_struct.url_kwargs.clone()
			homepage: cask_struct.homepage
			container_nested: cask_struct.container_nested
			container_type: cask_struct.container_type
			renames: cask_struct.renames.clone()
			loaded_from_api: true
			loaded_from_internal_api: true
		}
		require_sha: require_sha
		languages: languages
	}
}

fn cask_download_struct_from_value(value ruby.Value) CaskDownloadStruct {
	return CaskDownloadStruct{
		version: value.attributes['version'] or { '' }
		sha256: value.attributes['sha256'] or { '' }
		url_args: (value.attributes['url_args'] or { '' }).split('|').filter(it != '')
		homepage: value.attributes['homepage'] or { '' }
		container_nested: value.attributes['container_nested'] or { '' }
		container_type: value.attributes['container_type'] or { '' }
		languages: (value.attributes['languages'] or { '' }).split(',').filter(it != '')
		language_variations: (value.attributes['language_variations'] or { '' }).split(',').filter(it != '')
		renames: value.array_data.map(CaskDownloadRename{
			from: it.attributes['from'] or { '' }
			to: it.attributes['to'] or { '' }
		})
	}
}

// Ruby method `self.download(token:, cask_struct:, languages: nil, require_sha: false)` at line 19.
pub fn ruby_cask_download_l19_self_download(args ...ruby.Value) ruby.Value {
	if args.len < 2 {
		return ruby.object_value('NilClass', '')
	}
	languages := if args.len > 2 { args[2].as_string_array() or { []string{} } } else { []string{} }
	require_sha := if args.len > 3 { args[3].as_bool() or { false } } else { false }
	configured_languages := if args.len > 4 {
		args[4].as_string_array() or { []string{} }
	} else {
		[]string{}
	}
	download := cask_download(args[0].as_string(), cask_download_struct_from_value(args[1]), languages, configured_languages, require_sha) or {
		return ruby.object_value('NilClass', '')
	}
	return ruby.structured_value('CaskDownload', download.cask.token, {
		'token':       download.cask.token
		'version':     download.cask.version
		'sha256':      download.cask.sha256
		'url':         download.cask.url_args[0]
		'require_sha': download.require_sha.str()
		'languages':   download.languages.join(',')
		'renames':     download.cask.renames.map('${it.from}->${it.to}').join('|')
	})
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
