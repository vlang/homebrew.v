module test

import compress.gzip
import ruby
import homebrew as github_core
import os
import time

fn github_packages_spec_bottle(path string) ruby.Value {
	return ruby.map_value({
		'formula': ruby.map_value({
			'name':             ruby.string_value('testball')
			'pkg_version':      ruby.string_value('1.0')
			'tap_git_path':     ruby.string_value('Formula/t/testball.rb')
			'tap_git_revision': ruby.string_value('abcdef')
			'desc':             ruby.string_value('Test formula')
			'license':          ruby.string_value('MIT')
			'homepage':         ruby.string_value('https://brew.sh/testball')
		})
		'bottle':  ruby.map_value({
			'root_url': ruby.string_value('https://ghcr.io/v2/homebrew/core')
			'rebuild':  ruby.int_value(0)
			'date':     ruby.string_value('2026-05-10T00:00:00Z')
			'tags':     ruby.map_value({
				'all':          ruby.map_value({
					'local_filename': ruby.string_value(path)
					'tab':            ruby.map_value({
						'arch':     ruby.string_value('arm64')
						'built_on': ruby.map_value({
							'os':         ruby.string_value('Macintosh')
							'os_version': ruby.string_value('macOS 15')
						})
					})
					'sbom':           ruby.map_value({
						'documentDescribes': ruby.string_array_value([
							'SPDXRef-Compiler',
						])
						'packages':          ruby.array_value([
							ruby.map_value({
								'SPDXID': ruby.string_value('SPDXRef-Compiler')
							}),
						])
						'relationships':     ruby.array_value([])
					})
					'installed_size': ruby.int_value(100)
				})
				'arm64_sonoma': ruby.map_value({
					'local_filename': ruby.string_value(path)
					'tab':            ruby.map_value({
						'arch':     ruby.string_value('arm64')
						'built_on': ruby.map_value({
							'os':         ruby.string_value('Macintosh')
							'os_version': ruby.string_value('macOS 14')
						})
					})
					'installed_size': ruby.int_value(100)
				})
			})
		})
	})
}

fn github_packages_spec_manifest_map(root string) !map[string]ruby.Value {
	index := ruby.parse_json_value(os.read_file(os.join_path(root, 'index.json'))!)!.as_map()!
	descriptor := index['manifests']!.as_array()![0].as_map()!
	digest := descriptor['digest']!.as_string().trim_string_left('sha256:')
	image_index := ruby.parse_json_value(os.read_file(os.join_path(root, 'blobs', 'sha256', digest))!)!.as_map()!
	mut result := map[string]ruby.Value{}
	for manifest in image_index['manifests']!.as_array()! {
		manifest_map := manifest.as_map()!
		annotations := manifest_map['annotations']!.as_map()!
		result[annotations['org.opencontainers.image.ref.name']!.as_string()] = manifest
	}
	return result
}

// Translated from Homebrew/brew `test/github_packages_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "reports progress when uploading many bottles" do` at line 8.
pub fn ruby_github_packages_spec_l8_d1_reports(args ...ruby.Value) ruby.Value {
	result := github_core.github_packages_upload_progress(['foo', 'bar', 'baz'], {})
	return ruby.bool_value(result.events == [
		'Uploaded foo',
		'Upload progress: 1 formula(e) uploaded, 2 remaining',
		'Uploaded bar',
		'Upload progress: 2 formula(e) uploaded, 1 remaining',
		'Uploaded baz',
		'Upload progress: 3 formula(e) uploaded, 0 remaining',
	])
}

// Ruby it `it "does not report progress when uploading fewer than three bottles" do` at line 41.
pub fn ruby_github_packages_spec_l41_d2_does(args ...ruby.Value) ruby.Value {
	result := github_core.github_packages_upload_progress(['foo', 'bar'], {})
	return ruby.bool_value(result.events == ['Uploaded foo', 'Uploaded bar'])
}

// Ruby it `it "includes skipped bottles in progress" do` at line 69.
pub fn ruby_github_packages_spec_l69_d3_includes(args ...ruby.Value) ruby.Value {
	result := github_core.github_packages_upload_progress(['foo', 'bar', 'baz'], {
		'foo': true
		'bar': true
		'baz': true
	})
	return ruby.bool_value(result.events == [
		'Upload progress: 1 formula(e) uploaded, 2 remaining',
		'Upload progress: 2 formula(e) uploaded, 1 remaining',
		'Upload progress: 3 formula(e) uploaded, 0 remaining',
	])
}

// Ruby it `it "omits platform metadata from image index descriptors for all bottles" do` at line 96.
pub fn ruby_github_packages_spec_l96_d4_omits(args ...ruby.Value) ruby.Value {
	root_parent := os.join_path(os.temp_dir(), 'brew-v-github-packages-spec-${os.getpid()}-${time.now().unix_micro()}')
	os.mkdir_all(root_parent) or { return ruby.bool_value(false) }
	defer { os.rmdir_all(root_parent) or {} }
	bottle := os.join_path(root_parent, 'testball--1.0.all.bottle.tar.gz')
	compressed := gzip.compress('test'.bytes()) or { return ruby.bool_value(false) }
	os.write_file_array(bottle, compressed) or { return ruby.bool_value(false) }
	result := github_core.github_packages_upload_bottle(github_packages_spec_bottle(bottle), 'testball', github_core.GitHubPackagesUploadOptions{
		user: 'brewtest'
		token: 'ghp_test'
		root_parent: root_parent
		dry_run: true
	}) or { return ruby.bool_value(false) }
	manifests := github_packages_spec_manifest_map(result.root) or {
		return ruby.bool_value(false)
	}
	all := manifests['1.0.all'] or { return ruby.bool_value(false) }
	all_map := all.as_map() or { return ruby.bool_value(false) }
	if 'platform' in all_map {
		return ruby.bool_value(false)
	}
	all_annotations := all_map['annotations'] or { return ruby.bool_value(false) }
	all_annotation_map := all_annotations.as_map() or { return ruby.bool_value(false) }
	all_tab_value := all_annotation_map['sh.brew.tab'] or { return ruby.bool_value(false) }
	all_tab := ruby.parse_json_value(all_tab_value.as_string()) or {
		return ruby.bool_value(false)
	}
	if 'arch' in all_tab.map_data || 'built_on' in all_tab.map_data {
		return ruby.bool_value(false)
	}
	supplement_value := all_annotation_map['sh.brew.sbom.supplement'] or {
		return ruby.bool_value(false)
	}
	supplement := ruby.parse_json_value(supplement_value.as_string()) or {
		return ruby.bool_value(false)
	}
	packages_value := supplement.map_data['packages'] or { return ruby.bool_value(false) }
	package_ids := packages_value.as_array() or {
		return ruby.bool_value(false)
	}
	mut ids := []string{}
	mut checksum := ''
	for package in package_ids {
		id := package.map_data['SPDXID'] or { continue }
		ids << id.as_string()
		if id.as_string() == 'SPDXRef-Bottle-testball' {
			checksums := package.map_data['checksums'] or { continue }
			checksum_values := checksums.as_array() or { continue }
			if checksum_values.len == 0 {
				continue
			}
			checksum_value := checksum_values[0].map_data['checksumValue'] or { continue }
			checksum = checksum_value.as_string()
		}
	}
	arm := manifests['1.0.arm64_sonoma'] or { return ruby.bool_value(false) }
	arm_map := arm.as_map() or { return ruby.bool_value(false) }
	platform := arm_map['platform'] or { return ruby.bool_value(false) }
	platform_map := platform.as_map() or { return ruby.bool_value(false) }
	arm_annotations := arm_map['annotations'] or { return ruby.bool_value(false) }
	arm_tab_value := arm_annotations.map_data['sh.brew.tab'] or {
		return ruby.bool_value(false)
	}
	arm_tab := ruby.parse_json_value(arm_tab_value.as_string()) or {
		return ruby.bool_value(false)
	}
	describes_value := supplement.map_data['documentDescribes'] or {
		return ruby.bool_value(false)
	}
	describes := describes_value.as_array() or { return ruby.bool_value(false) }
	bottle_digest := all_annotation_map['sh.brew.bottle.digest'] or {
		return ruby.bool_value(false)
	}
	architecture := platform_map['architecture'] or { return ruby.bool_value(false) }
	platform_os := platform_map['os'] or { return ruby.bool_value(false) }
	arm_arch := arm_tab.map_data['arch'] or { return ruby.bool_value(false) }
	built_on := arm_tab.map_data['built_on'] or { return ruby.bool_value(false) }
	built_on_os := built_on.map_data['os'] or { return ruby.bool_value(false) }
	return ruby.bool_value(ids.contains('SPDXRef-Compiler')
		&& ids.contains('SPDXRef-Bottle-testball')
		&& describes.map(it.as_string()).contains('SPDXRef-Bottle-testball')
		&& checksum == bottle_digest.as_string() && architecture.as_string() == 'arm64'
		&& platform_os.as_string() == 'darwin' && arm_arch.as_string() == 'arm64'
		&& built_on_os.as_string() == 'Macintosh')
}

// Ruby method `validate_schema!(_schema_uri, _json); end` at line 104.
pub fn ruby_github_packages_spec_l104_d5_validate_schema(args ...ruby.Value) ruby.Value {
	return ruby.object_value('NilClass', 'nil')
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "github_packages"
// 5:
// 6: RSpec.describe GitHubPackages do
// 7:   describe "#upload_bottles" do
// 8:     it "reports progress when uploading many bottles" do
// 9:       github_packages = described_class.new
// 10:       events = []
// 11:       bottles_hash = {
// 12:         "foo" => {},
// 13:         "bar" => {},
// 14:         "baz" => {},
// 15:       }
// 16:
// 17:       allow(Homebrew::EnvConfig).to receive_messages(
// 18:         github_packages_user:  "brewtest",
// 19:         github_packages_token: "ghp_test",
// 20:       )
// 21:       allow(github_packages).to receive(:load_schemas!)
// 22:       allow(github_packages).to receive(:preupload_check)
// 23:       allow(github_packages).to receive(:ensure_executable!).and_return(Pathname("skopeo"))
// 24:       allow(github_packages).to receive(:upload_bottle) do |_, _, _, formula_full_name, *_args, **_options|
// 25:         events << "Uploaded #{formula_full_name}"
// 26:       end
// 27:       allow(github_packages).to receive(:ohai) { |message| events << message }
// 28:
// 29:       github_packages.upload_bottles(bottles_hash, keep_old: false, dry_run: false, warn_on_error: false)
// 30:
// 31:       expect(events).to eq([
// 32:         "Uploaded foo",
// 33:         "Upload progress: 1 formula(e) uploaded, 2 remaining",
// 34:         "Uploaded bar",
// 35:         "Upload progress: 2 formula(e) uploaded, 1 remaining",
// 36:         "Uploaded baz",
// 37:         "Upload progress: 3 formula(e) uploaded, 0 remaining",
// 38:       ])
// 39:     end
// 40:
// 41:     it "does not report progress when uploading fewer than three bottles" do
// 42:       github_packages = described_class.new
// 43:       events = []
// 44:       bottles_hash = {
// 45:         "foo" => {},
// 46:         "bar" => {},
// 47:       }
// 48:
// 49:       allow(Homebrew::EnvConfig).to receive_messages(
// 50:         github_packages_user:  "brewtest",
// 51:         github_packages_token: "ghp_test",
// 52:       )
// 53:       allow(github_packages).to receive(:load_schemas!)
// 54:       allow(github_packages).to receive(:preupload_check)
// 55:       allow(github_packages).to receive(:ensure_executable!).and_return(Pathname("skopeo"))
// 56:       allow(github_packages).to receive(:upload_bottle) do |_, _, _, formula_full_name, *_args, **_options|
// 57:         events << "Uploaded #{formula_full_name}"
// 58:       end
// 59:       allow(github_packages).to receive(:ohai) { |message| events << message }
// 60:
// 61:       github_packages.upload_bottles(bottles_hash, keep_old: false, dry_run: false, warn_on_error: false)
// 62:
// 63:       expect(events).to eq([
// 64:         "Uploaded foo",
// 65:         "Uploaded bar",
// 66:       ])
// 67:     end
// 68:
// 69:     it "includes skipped bottles in progress" do
// 70:       github_packages = described_class.new
// 71:       bottles_hash = {
// 72:         "foo" => {},
// 73:         "bar" => {},
// 74:         "baz" => {},
// 75:       }
// 76:
// 77:       allow(Homebrew::EnvConfig).to receive_messages(
// 78:         github_packages_user:  "brewtest",
// 79:         github_packages_token: "ghp_test",
// 80:       )
// 81:       allow(github_packages).to receive(:ensure_executable!).and_return(Pathname("skopeo"))
// 82:       allow(github_packages).to receive(:load_schemas!)
// 83:       allow(github_packages).to receive(:preupload_check)
// 84:
// 85:       expect do
// 86:         github_packages.upload_bottles(bottles_hash, keep_old: false, dry_run: false, warn_on_error: true)
// 87:       end.to output(<<~EOS).to_stdout
// 88:         ==> Upload progress: 1 formula(e) uploaded, 2 remaining
// 89:         ==> Upload progress: 2 formula(e) uploaded, 1 remaining
// 90:         ==> Upload progress: 3 formula(e) uploaded, 0 remaining
// 91:       EOS
// 92:     end
// 93:   end
// 94:
// 95:   describe "#upload_bottle" do
// 96:     it "omits platform metadata from image index descriptors for all bottles" do
// 97:       mktmpdir.cd do
// 98:         bottle = Pathname("testball--1.0.all.bottle.tar.gz")
// 99:         Zlib::GzipWriter.open(bottle) { |gz| gz.write("test") }
// 100:
// 101:         github_packages = Class.new(GitHubPackages) do
// 102:           private
// 103:
// 104:           def validate_schema!(_schema_uri, _json); end
// 105:         end.new
// 106:
// 107:         expect do
// 108:           github_packages.upload_bottle("brewtest", "ghp_test", Pathname("skopeo"), "testball",
// 109:                                         {
// 110:                                           "formula" => {
// 111:                                             "name"             => "testball",
// 112:                                             "pkg_version"      => "1.0",
// 113:                                             "tap_git_path"     => "Formula/t/testball.rb",
// 114:                                             "tap_git_revision" => "abcdef",
// 115:                                             "desc"             => "Test formula",
// 116:                                             "license"          => "MIT",
// 117:                                             "homepage"         => "https://brew.sh/testball",
// 118:                                           },
// 119:                                           "bottle"  => {
// 120:                                             "root_url" => "https://ghcr.io/v2/homebrew/core",
// 121:                                             "rebuild"  => 0,
// 122:                                             "date"     => "2026-05-10T00:00:00Z",
// 123:                                             "tags"     => {
// 124:                                               "all"          => {
// 125:                                                 "local_filename" => bottle.to_s,
// 126:                                                 "tab"            => {
// 127:                                                   "arch"     => "arm64",
// 128:                                                   "built_on" => {
// 129:                                                     "os"         => "Macintosh",
// 130:                                                     "os_version" => "macOS 15",
// 131:                                                   },
// 132:                                                 },
// 133:                                                 "sbom"           => {
// 134:                                                   "documentDescribes" => ["SPDXRef-Compiler"],
// 135:                                                   "packages"          => [{ "SPDXID" => "SPDXRef-Compiler" }],
// 136:                                                   "relationships"     => [],
// 137:                                                 },
// 138:                                                 "installed_size" => 100,
// 139:                                               },
// 140:                                               "arm64_sonoma" => {
// 141:                                                 "local_filename" => bottle.to_s,
// 142:                                                 "tab"            => {
// 143:                                                   "arch"     => "arm64",
// 144:                                                   "built_on" => {
// 145:                                                     "os"         => "Macintosh",
// 146:                                                     "os_version" => "macOS 14",
// 147:                                                   },
// 148:                                                 },
// 149:                                                 "installed_size" => 100,
// 150:                                               },
// 151:                                             },
// 152:                                           },
// 153:                                         },
// 154:                                         keep_old: false, dry_run: true, warn_on_error: false)
// 155:         end.to output.to_stdout
// 156:
// 157:         index_json = JSON.parse(Pathname("testball--1.0/index.json").read)
// 158:         image_index_sha256 = index_json.fetch("manifests").first.fetch("digest").delete_prefix("sha256:")
// 159:         image_index = JSON.parse((Pathname("testball--1.0/blobs/sha256")/image_index_sha256).read)
// 160:         manifests_by_tag = image_index.fetch("manifests").to_h do |manifest|
// 161:           [manifest.fetch("annotations").fetch("org.opencontainers.image.ref.name"), manifest]
// 162:         end
// 163:
// 164:         expect(manifests_by_tag.fetch("1.0.all")).not_to have_key("platform")
// 165:         expect(JSON.parse(manifests_by_tag.fetch("1.0.all").fetch("annotations").fetch("sh.brew.tab")))
// 166:           .not_to include("arch", "built_on")
// 167:         all_annotations = manifests_by_tag.fetch("1.0.all").fetch("annotations")
// 168:         all_supplement = JSON.parse(all_annotations.fetch("sh.brew.sbom.supplement"))
// 169:         all_package_ids = all_supplement.fetch("packages").map { |package| package.fetch("SPDXID") }
// 170:         expect(all_package_ids).to include("SPDXRef-Compiler", "SPDXRef-Bottle-testball")
// 171:         expect(all_supplement.fetch("documentDescribes")).to include("SPDXRef-Bottle-testball")
// 172:         expect(all_supplement.fetch("packages").find do |package|
// 173:           package.fetch("SPDXID") == "SPDXRef-Bottle-testball"
// 174:         end.fetch("checksums")).to eq([
// 175:           {
// 176:             "algorithm"     => "SHA256",
// 177:             "checksumValue" => all_annotations.fetch("sh.brew.bottle.digest"),
// 178:           },
// 179:         ])
// 180:         expect(manifests_by_tag.fetch("1.0.arm64_sonoma"))
// 181:           .to include("platform" => include("architecture" => "arm64", "os" => "darwin"))
// 182:         expect(JSON.parse(manifests_by_tag.fetch("1.0.arm64_sonoma").fetch("annotations").fetch("sh.brew.tab")))
// 183:           .to include("arch" => "arm64", "built_on" => include("os" => "Macintosh"))
// 184:       end
// 185:     end
// 186:   end
// 187: end
