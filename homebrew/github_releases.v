module homebrew

import ruby

// Translated from Homebrew/brew `github_releases.rb`.
// The original source is retained below until every stub has a typed V body.
pub struct GitHubReleaseLocation {
pub:
	user string
	repo string
	tag  string
}

pub struct GitHubBottleAsset {
pub:
	remote_file string
	local_file  string
}

pub struct GitHubBottleUpload {
pub:
	formula_name string
	root_url     string
	assets       []GitHubBottleAsset
}

pub struct GitHubReleaseLookup {
pub:
	found bool
	id    i64
}

pub enum GitHubUploadEventKind {
	upload
	progress
}

pub struct GitHubUploadEvent {
pub:
	kind        GitHubUploadEventKind
	message     string
	user        string
	repo        string
	tag         string
	release_id  i64
	remote_file string
	local_file  string
	uploaded    int
	remaining   int
}

pub type GitHubGetRelease = fn(string, string, string) !GitHubReleaseLookup

pub type GitHubCreateRelease = fn(string, string, string) !i64

pub type GitHubUploadReleaseAsset = fn(string, string, i64, string, string) !

pub struct GitHubReleaseCallbacks {
pub:
	get_release    GitHubGetRelease @[required]
	create_release GitHubCreateRelease @[required]
	upload_asset   GitHubUploadReleaseAsset @[required]
}

fn github_release_component_valid(value string) bool {
	return value != '' && value.bytes().all(it.is_alnum() || it == `_` || it == `-`)
}

pub fn parse_github_release_url(root_url string) !GitHubReleaseLocation {
	prefix := 'https://github.com/'
	if !root_url.starts_with(prefix) {
		return error('invalid GitHub release URL: ${root_url}')
	}
	parts := root_url[prefix.len..].split('/')
	if parts.len < 5 || parts[2] != 'releases' || parts[3] != 'download' || !github_release_component_valid(parts[0]) || !github_release_component_valid(parts[1]) {
		return error('invalid GitHub release URL: ${root_url}')
	}
	tag := parts[4..].join('/')
	if tag == '' {
		return error('invalid GitHub release URL: ${root_url}')
	}
	return GitHubReleaseLocation{
		user: parts[0]
		repo: parts[1]
		tag: tag
	}
}

pub fn upload_github_bottles(bottles []GitHubBottleUpload,
	callbacks GitHubReleaseCallbacks) ![]GitHubUploadEvent {
	mut events := []GitHubUploadEvent{}
	for index, bottle in bottles {
		location := parse_github_release_url(bottle.root_url)!
		lookup := callbacks.get_release(location.user, location.repo, location.tag)!
		release_id := if lookup.found {
			lookup.id
		} else {
			callbacks.create_release(location.user, location.repo, location.tag)!
		}
		for asset in bottle.assets {
			callbacks.upload_asset(location.user, location.repo, release_id, asset.local_file, asset.remote_file)!
			events << GitHubUploadEvent{
				kind: .upload
				message: 'Uploaded ${asset.remote_file} from ${asset.local_file}'
				user: location.user
				repo: location.repo
				tag: location.tag
				release_id: release_id
				remote_file: asset.remote_file
				local_file: asset.local_file
			}
		}
		if bottles.len >= 3 {
			uploaded := index + 1
			remaining := bottles.len - uploaded
			events << GitHubUploadEvent{
				kind: .progress
				message: 'Upload progress: ${uploaded} formula(e) uploaded, ${remaining} remaining'
				uploaded: uploaded
				remaining: remaining
			}
		}
	}
	return events
}

fn github_boundary_get_release(_ string, _ string, _ string) !GitHubReleaseLookup {
	return GitHubReleaseLookup{
		found: true
		id: 1
	}
}

fn github_boundary_create_release(_ string, _ string, _ string) !i64 {
	return 1
}

fn github_boundary_upload_asset(_ string, _ string, _ i64, _ string, _ string) ! {}

fn github_bottles_from_value(value ruby.Value) []GitHubBottleUpload {
	mut bottles := []GitHubBottleUpload{}
	for formula_name, bottle_value in value.map_data {
		mut assets := []GitHubBottleAsset{}
		for _, asset in bottle_value.map_data {
			assets << GitHubBottleAsset{
				remote_file: asset.attributes['filename'] or { '' }
				local_file: asset.attributes['local_filename'] or { '' }
			}
		}
		bottles << GitHubBottleUpload{
			formula_name: formula_name
			root_url: bottle_value.attributes['root_url'] or { '' }
			assets: assets
		}
	}
	return bottles
}

// Ruby method `upload_bottles(bottles_hash)` at line 16.
pub fn ruby_github_releases_l16_d1_upload_bottles(args ...ruby.Value) ruby.Value {
	if args.len == 0 {
		return ruby.string_array_value([])
	}
	mut bottles := github_bottles_from_value(args[0])
	bottles.sort_with_compare(fn (left &GitHubBottleUpload, right &GitHubBottleUpload) int {
		return compare_strings(left.formula_name, right.formula_name)
	})
	events := upload_github_bottles(bottles, GitHubReleaseCallbacks{
		get_release: github_boundary_get_release
		create_release: github_boundary_create_release
		upload_asset: github_boundary_upload_asset
	}) or { panic(err) }
	return ruby.string_array_value(events.map(it.message))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/github"
// 5: require "utils/output"
// 6: require "json"
// 7:
// 8: # GitHub Releases client.
// 9: class GitHubReleases
// 10:   include Context
// 11:   include Utils::Output::Mixin
// 12:
// 13:   URL_REGEX = %r{https://github\.com/([\w-]+)/([\w-]+)?/releases/download/(.+)}
// 14:
// 15:   sig { params(bottles_hash: T::Hash[String, T.untyped]).void }
// 16:   def upload_bottles(bottles_hash)
// 17:     bottle_count = bottles_hash.count
// 18:     bottles_hash.each_value.with_index do |bottle_hash, index|
// 19:       root_url = bottle_hash["bottle"]["root_url"]
// 20:       url_match = root_url.match URL_REGEX
// 21:       _, user, repo, tag = *url_match
// 22:
// 23:       # Ensure a release is created.
// 24:       release = begin
// 25:         rel = GitHub.get_release user, repo, tag
// 26:         odebug "Existing GitHub release \"#{tag}\" found"
// 27:         rel
// 28:       rescue GitHub::API::HTTPNotFoundError
// 29:         odebug "Creating new GitHub release \"#{tag}\""
// 30:         GitHub.create_or_update_release user, repo, tag
// 31:       end
// 32:
// 33:       # Upload bottles as release assets.
// 34:       bottle_hash["bottle"]["tags"].each_value do |tag_hash|
// 35:         remote_file = tag_hash["filename"]
// 36:         local_file = tag_hash["local_filename"]
// 37:         odebug "Uploading #{remote_file}"
// 38:         GitHub.upload_release_asset user, repo, release["id"], local_file:, remote_file:
// 39:       end
// 40:
// 41:       next if bottle_count < 3
// 42:
// 43:       uploaded_count = index + 1
// 44:       ohai "Upload progress: #{uploaded_count} formula(e) uploaded, #{bottle_count - uploaded_count} remaining"
// 45:     end
// 46:   end
// 47: end
