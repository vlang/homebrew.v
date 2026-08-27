module test

import brew_runtime

// Translated from Homebrew/brew `test/github_packages_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby it `it "reports progress when uploading many bottles" do` at line 8.
pub fn ruby_github_packages_spec_l8_d1_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "does not report progress when uploading fewer than three bottles" do` at line 41.
pub fn ruby_github_packages_spec_l41_d2_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "includes skipped bottles in progress" do` at line 69.
pub fn ruby_github_packages_spec_l69_d3_includes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('includes', ...args)
}

// Ruby it `it "omits platform metadata from image index descriptors for all bottles" do` at line 96.
pub fn ruby_github_packages_spec_l96_d4_omits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('omits', ...args)
}

// Ruby method `validate_schema!(_schema_uri, _json); end` at line 104.
pub fn ruby_github_packages_spec_l104_d5_validate_schema(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('validate_schema!', ...args)
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
