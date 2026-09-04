module cmd

import ruby
import homebrew.cmd as fetch_cmd

// Translated from Homebrew/brew `test/cmd/fetch_spec.rb`.
// The original source is retained below until every stub has a typed V body.

fn fetch_spec_systems() []fetch_cmd.FetchSystem {
	return [
		fetch_cmd.FetchSystem{ os: 'macos', arch: 'arm64' },
		fetch_cmd.FetchSystem{ os: 'macos', arch: 'intel' },
		fetch_cmd.FetchSystem{ os: 'linux', arch: 'arm64' },
		fetch_cmd.FetchSystem{ os: 'linux', arch: 'intel' },
	]
}

fn fetch_spec_matrix_cask(on_system_blocks_exist bool) fetch_cmd.FetchCask {
	return fetch_cmd.FetchCask{
		token: 'sha256-os'
		on_system_blocks_exist: on_system_blocks_exist
		variants: [
			fetch_cmd.FetchCaskVariant{
				os: 'macos'
				arch: 'arm64'
				url: 'https://example.com/caffeine-arm-darwin.zip'
				sha256: 'arm-darwin'
			},
			fetch_cmd.FetchCaskVariant{
				os: 'macos'
				arch: 'intel'
				url: 'https://example.com/caffeine-intel-darwin.zip'
				sha256: 'intel-darwin'
			},
			fetch_cmd.FetchCaskVariant{
				os: 'linux'
				arch: 'arm64'
				url: 'https://example.com/caffeine-arm-linux.zip'
				sha256: 'arm-linux'
			},
			fetch_cmd.FetchCaskVariant{
				os: 'linux'
				arch: 'intel'
				url: 'https://example.com/caffeine-intel-linux.zip'
				sha256: 'intel-linux'
			},
		]
	}
}

// Ruby it `it "uses API bottle metadata before loading simple core formulae" do` at line 10.
pub fn ruby_fetch_spec_l10_d1_uses(args ...ruby.Value) ruby.Value {
	_ = args
	result := fetch_cmd.run_fetch_command(fetch_cmd.FetchCommandRequest{
		options: fetch_cmd.FetchCommandOptions{
			named: ['fast-fetch']
		}
		context: fetch_cmd.FetchCommandContext{
			api_formulae: [fetch_cmd.FetchApiFormula{
				name: 'fast-fetch'
				bottle_url: 'https://ghcr.io/fast-fetch.tar.gz'
			}]
		}
	})
	return ruby.bool_value(result.used_api && result.regular_loads == 0
		&& result.downloads.len == 1 && result.downloads[0].kind == 'bottle'
		&& result.fetches == 1 && result.shutdowns == 1)
}

// Ruby it `it "uses API cask metadata before loading simple core casks" do` at line 49.
pub fn ruby_fetch_spec_l49_d2_uses(args ...ruby.Value) ruby.Value {
	_ = args
	result := fetch_cmd.run_fetch_command(fetch_cmd.FetchCommandRequest{
		options: fetch_cmd.FetchCommandOptions{
			only_formula_or_cask: 'cask'
			named: ['fast-cask']
		}
		context: fetch_cmd.FetchCommandContext{
			api_casks: [fetch_cmd.FetchApiCask{
				token: 'fast-cask'
				url: 'https://example.com/fast-cask.zip'
				sha256: 'd7b9f4e8'
			}]
		}
	})
	return ruby.bool_value(result.used_api && result.regular_loads == 0
		&& result.downloads.len == 1 && result.downloads[0].kind == 'cask'
		&& result.fetches == 1 && result.shutdowns == 1)
}

// Ruby it `it "downloads Formula and Cask URLs concurrently", :cask, :integration_test do` at line 76.
pub fn ruby_fetch_spec_l76_d3_downloads(args ...ruby.Value) ruby.Value {
	_ = args
	result := fetch_cmd.run_fetch_command(fetch_cmd.FetchCommandRequest{
		options: fetch_cmd.FetchCommandOptions{
			no_install_from_api: true
			os_arch_combinations: [
				fetch_cmd.FetchSystem{ os: 'macos', arch: 'arm64' },
			]
		}
		context: fetch_cmd.FetchCommandContext{
			packages: [
				fetch_cmd.FetchPackage{
					kind: 'formula'
					formula: fetch_cmd.FetchFormula{
						name: 'testball1'
						source_url: 'https://example.com/testball1--0.1.tbz'
					}
				},
				fetch_cmd.FetchPackage{
					kind: 'formula'
					formula: fetch_cmd.FetchFormula{
						name: 'testball2'
						source_url: 'https://example.com/testball2--0.1.tbz'
					}
				},
				fetch_cmd.FetchPackage{
					kind: 'cask'
					cask: fetch_cmd.FetchCask{
						token: 'local-caffeine'
						variants: [fetch_cmd.FetchCaskVariant{
							os: 'macos'
							arch: 'arm64'
							url: 'https://example.com/caffeine.zip'
							sha256: 'caffeine'
						}]
					}
				},
			]
		}
	})
	fetch_index := result.events.index('fetch')
	return ruby.bool_value(result.downloads.len == 3 && result.fetches == 1
		&& result.shutdowns == 1 && fetch_index >= 3 && result.events.last() == 'shutdown')
}

// Ruby it `it "collects one download per distinct URL across all platforms" do` at line 90.
pub fn ruby_fetch_spec_l90_d4_collects(args ...ruby.Value) ruby.Value {
	_ = args
	result := fetch_cmd.fetch_cask_downloads(fetch_spec_matrix_cask(true), fetch_cmd.FetchCommandOptions{
		all_platforms: true
		os_arch_combinations: fetch_spec_systems()
	})
	mut basenames := result.downloads.map(it.url.all_after_last('/'))
	basenames.sort()
	return ruby.bool_value(basenames == ['caffeine-arm-darwin.zip', 'caffeine-arm-linux.zip',
		'caffeine-intel-darwin.zip', 'caffeine-intel-linux.zip'])
}

// Ruby it `it "skips arches the cask's depends_on arch excludes" do` at line 98.
pub fn ruby_fetch_spec_l98_d5_skips(args ...ruby.Value) ruby.Value {
	_ = args
	result := fetch_cmd.fetch_cask_downloads(fetch_cmd.FetchCask{
		token: 'depends-on-arch-arm64'
		on_system_blocks_exist: true
		variants: [fetch_cmd.FetchCaskVariant{
			os: 'macos'
			arch: 'intel'
			url: 'https://example.com/arm-only.zip'
			sha256: 'arm-only'
			allowed_arches: ['arm64']
		}]
	}, fetch_cmd.FetchCommandOptions{
		os_arch_combinations: [fetch_cmd.FetchSystem{ os: 'macos', arch: 'intel' }]
	})
	return ruby.bool_value(result.downloads.len == 0 && result.warnings.len == 1)
}

// Ruby it `it "collapses to a single download for a cask without on_system blocks" do` at line 103.
pub fn ruby_fetch_spec_l103_d6_collapses(args ...ruby.Value) ruby.Value {
	_ = args
	result := fetch_cmd.fetch_cask_downloads(fetch_spec_matrix_cask(false), fetch_cmd.FetchCommandOptions{
		all_platforms: true
		os_arch_combinations: fetch_spec_systems()
	})
	return ruby.bool_value(result.downloads.len == 1)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "cmd/fetch"
// 5: require "cmd/shared_examples/args_parse"
// 6:
// 7: RSpec.describe Homebrew::Cmd::FetchCmd do
// 8:   it_behaves_like "parseable arguments"
// 9:
// 10:   it "uses API bottle metadata before loading simple core formulae" do
// 11:     cmd = described_class.new(["fast-fetch"])
// 12:     download_queue = instance_double(Homebrew::DownloadQueue, fetch: nil, shutdown: nil)
// 13:     bottle_tag = with_env(HOMEBREW_TEST_GENERIC_OS: nil) { Utils::Bottles.tag }
// 14:     formula_struct = Homebrew::API::FormulaStruct.from_hash(
// 15:       "bottle_checksums"     => [
// 16:         {
// 17:           cellar:            :any_skip_relocation,
// 18:           bottle_tag.to_sym => "d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97",
// 19:         },
// 20:       ],
// 21:       "bottle_present"       => true,
// 22:       "desc"                 => "fast fetch",
// 23:       "homepage"             => "https://brew.sh",
// 24:       "license"              => "MIT",
// 25:       "ruby_source_checksum" => "abc123",
// 26:       "stable_present"       => true,
// 27:       "stable_version"       => "1.0",
// 28:     )
// 29:     enqueued_downloads = []
// 30:
// 31:     allow(Homebrew::DownloadQueue).to receive(:new).and_return(download_queue)
// 32:     allow(download_queue).to receive(:enqueue) { |download| enqueued_downloads << download }
// 33:     allow(Homebrew::API::Internal).to receive_messages(
// 34:       formula_aliases: {},
// 35:       formula_renames: {},
// 36:       formula_struct:  formula_struct,
// 37:     )
// 38:     allow(Homebrew::API::Internal).to receive(:formula_name?) { |name| name == "fast-fetch" }
// 39:
// 40:     expect(cmd.args.named).not_to receive(:to_formulae_and_casks)
// 41:     expect(Formulary).not_to receive(:factory)
// 42:     expect(download_queue).to receive(:shutdown)
// 43:
// 44:     with_env(HOMEBREW_TEST_GENERIC_OS: nil) { cmd.run }
// 45:
// 46:     expect(enqueued_downloads).to include(an_instance_of(Bottle))
// 47:   end
// 48:
// 49:   it "uses API cask metadata before loading simple core casks" do
// 50:     cmd = described_class.new(["--cask", "fast-cask"])
// 51:     download_queue = instance_double(Homebrew::DownloadQueue, fetch: nil, shutdown: nil)
// 52:     cask_struct = Homebrew::API::CaskStruct.new(
// 53:       sha256:   "d7b9f4e8bf83608b71fe958a99f19f2e5e68bb2582965d32e41759c24f1aef97",
// 54:       url_args: ["https://example.com/fast-cask.zip"],
// 55:       version:  "1.0",
// 56:     )
// 57:     enqueued_downloads = []
// 58:
// 59:     allow(Homebrew::DownloadQueue).to receive(:new).and_return(download_queue)
// 60:     allow(download_queue).to receive(:enqueue) { |download| enqueued_downloads << download }
// 61:     allow(Homebrew::API::Internal).to receive_messages(
// 62:       cask_renames: {},
// 63:       cask_struct:  cask_struct,
// 64:     )
// 65:     allow(Homebrew::API::Internal).to receive(:cask_name?) { |token| token == "fast-cask" }
// 66:
// 67:     expect(cmd.args.named).not_to receive(:to_formulae_and_casks)
// 68:     expect(Cask::CaskLoader).not_to receive(:load)
// 69:     expect(download_queue).to receive(:shutdown)
// 70:
// 71:     with_env(HOMEBREW_TEST_GENERIC_OS: nil) { cmd.run }
// 72:
// 73:     expect(enqueued_downloads).to include(an_instance_of(Cask::Download))
// 74:   end
// 75:
// 76:   it "downloads Formula and Cask URLs concurrently", :cask, :integration_test do
// 77:     setup_test_formula "testball1"
// 78:     setup_test_formula "testball2"
// 79:
// 80:     expect { brew "fetch", "testball1", "testball2", "local-caffeine" }.to be_a_success
// 81:
// 82:     expect(HOMEBREW_CACHE/"testball1--0.1.tbz").to be_a_symlink
// 83:     expect(HOMEBREW_CACHE/"testball1--0.1.tbz").to exist
// 84:     expect(HOMEBREW_CACHE/"testball2--0.1.tbz").to be_a_symlink
// 85:     expect(HOMEBREW_CACHE/"testball2--0.1.tbz").to exist
// 86:     expect((HOMEBREW_CACHE/"downloads").glob("*--caffeine.zip")).not_to be_empty
// 87:   end
// 88:
// 89:   describe "#cask_downloads", :cask do
// 90:     it "collects one download per distinct URL across all platforms" do
// 91:       cmd = described_class.new(["--cask", "--all-platforms", "sha256-os"])
// 92:       basenames = cmd.cask_downloads(Cask::CaskLoader.load("sha256-os"))
// 93:                      .map { |download| File.basename(download.url.to_s) }
// 94:       expect(basenames).to contain_exactly("caffeine-arm-darwin.zip", "caffeine-intel-darwin.zip",
// 95:                                            "caffeine-arm-linux.zip", "caffeine-intel-linux.zip")
// 96:     end
// 97:
// 98:     it "skips arches the cask's depends_on arch excludes" do
// 99:       cmd = described_class.new(["--cask", "--os=macos", "--arch=intel", "depends-on-arch-arm64"])
// 100:       expect(cmd.cask_downloads(Cask::CaskLoader.load("depends-on-arch-arm64"))).to be_empty
// 101:     end
// 102:
// 103:     it "collapses to a single download for a cask without on_system blocks" do
// 104:       cmd = described_class.new(["--cask", "--all-platforms", "local-caffeine"])
// 105:       expect(cmd.cask_downloads(Cask::CaskLoader.load("local-caffeine")).length).to eq(1)
// 106:     end
// 107:   end
// 108: end
