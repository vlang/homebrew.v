module api

// Translated from Homebrew/brew `api/cask_download.rb`.
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
