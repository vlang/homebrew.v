module test_bot

import brew_runtime

// Translated from Homebrew/brew `test_bot/formulae_detect.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby attr_reader `attr_reader :testing_formulae, :added_formulae, :deleted_formulae` at line 12.
pub fn ruby_formulae_detect_l12_d1_testing_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('testing_formulae', ...args)
}

// Ruby attr_reader `attr_reader :testing_formulae, :added_formulae, :deleted_formulae` at line 12.
pub fn ruby_formulae_detect_l12_d2_added_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('added_formulae', ...args)
}

// Ruby attr_reader `attr_reader :testing_formulae, :added_formulae, :deleted_formulae` at line 12.
pub fn ruby_formulae_detect_l12_d3_deleted_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('deleted_formulae', ...args)
}

// Ruby method `initialize(argument, tap:, git:, dry_run:, fail_fast:, verbose:)` at line 24.
pub fn ruby_formulae_detect_l24_d4_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby method `run!(args:)` at line 35.
pub fn ruby_formulae_detect_l35_d5_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run!', ...args)
}

// Ruby method `detect_formulae!(args:)` at line 51.
pub fn ruby_formulae_detect_l51_d6_detect_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('detect_formulae!', ...args)
}

// Ruby method `safe_formula_canonical_name(formula_name, args:)` at line 230.
pub fn ruby_formulae_detect_l230_d7_safe_formula_canonical_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('safe_formula_canonical_name', ...args)
}

// Ruby method `rev_parse(ref)` at line 240.
pub fn ruby_formulae_detect_l240_d8_rev_parse(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('rev_parse', ...args)
}

// Ruby method `current_sha1` at line 245.
pub fn ruby_formulae_detect_l245_d9_current_sha1(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('current_sha1', ...args)
}

// Ruby method `diff_formulae(start_revision, end_revision, path, filter)` at line 257.
pub fn ruby_formulae_detect_l257_d10_diff_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('diff_formulae', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module TestBot
// 6:     class FormulaeDetect < Test
// 7:       # Formulae must have GitHub homepages and stable URLs, no stable dependencies,
// 8:       # one executable and one library between them.
// 9:       DEFAULT_TEST_FORMULAE = %w[libdeflate bats-core].freeze
// 10:
// 11:       sig { returns(T::Array[String]) }
// 12:       attr_reader :testing_formulae, :added_formulae, :deleted_formulae
// 13:
// 14:       sig {
// 15:         params(
// 16:           argument:  String,
// 17:           tap:       T.nilable(Tap),
// 18:           git:       String,
// 19:           dry_run:   T::Boolean,
// 20:           fail_fast: T::Boolean,
// 21:           verbose:   T::Boolean,
// 22:         ).void
// 23:       }
// 24:       def initialize(argument, tap:, git:, dry_run:, fail_fast:, verbose:)
// 25:         super(tap:, git:, dry_run:, fail_fast:, verbose:)
// 26:
// 27:         @argument = argument
// 28:         @added_formulae = T.let([], T::Array[String])
// 29:         @deleted_formulae = T.let([], T::Array[String])
// 30:         @formulae_to_fetch = T.let([], T::Array[String])
// 31:         @testing_formulae = T.let([], T::Array[String])
// 32:       end
// 33:
// 34:       sig { params(args: Homebrew::Cmd::TestBotCmd::Args).void }
// 35:       def run!(args:)
// 36:         detect_formulae!(args:)
// 37:
// 38:         return unless GitHub::Actions.env_set?
// 39:
// 40:         File.open(ENV.fetch("GITHUB_OUTPUT"), "a") do |f|
// 41:           f.puts "testing_formulae=#{@testing_formulae.join(",")}"
// 42:           f.puts "added_formulae=#{@added_formulae.join(",")}"
// 43:           f.puts "deleted_formulae=#{@deleted_formulae.join(",")}"
// 44:           f.puts "formulae_to_fetch=#{@formulae_to_fetch.join(",")}"
// 45:         end
// 46:       end
// 47:
// 48:       private
// 49:
// 50:       sig { params(args: Homebrew::Cmd::TestBotCmd::Args).void }
// 51:       def detect_formulae!(args:)
// 52:         test_header(:FormulaeDetect, method: :detect_formulae!)
// 53:
// 54:         url = nil
// 55:         origin_ref = "origin/main"
// 56:
// 57:         github_repository = ENV.fetch("GITHUB_REPOSITORY", nil)
// 58:         github_ref = ENV.fetch("GITHUB_REF", nil)
// 59:
// 60:         if @argument == "HEAD"
// 61:           @testing_formulae = []
// 62:           # Use GitHub Actions variables for pull request jobs.
// 63:           if github_ref.present? && github_repository.present? &&
// 64:              %r{refs/pull/(\d+)/merge} =~ github_ref
// 65:             url = "https://github.com/#{github_repository}/pull/#{Regexp.last_match(1)}/checks"
// 66:           end
// 67:         elsif (canonical_formula_name = safe_formula_canonical_name(@argument, args:))
// 68:           unless canonical_formula_name.include?("/")
// 69:             ENV["HOMEBREW_NO_INSTALL_FROM_API"] = "1"
// 70:             CoreTap.instance.ensure_installed!
// 71:           end
// 72:
// 73:           @testing_formulae = [canonical_formula_name]
// 74:         else
// 75:           raise UsageError,
// 76:                 "#{@argument} is not detected from GitHub Actions or a formula name!"
// 77:         end
// 78:
// 79:         github_sha = ENV.fetch("GITHUB_SHA", nil)
// 80:         if github_repository.blank? || github_sha.blank? || github_ref.blank?
// 81:           if GitHub::Actions.env_set?
// 82:             odie <<~EOS
// 83:               We cannot find the needed GitHub Actions environment variables! Check you have e.g. exported them to a Docker container.
// 84:             EOS
// 85:           elsif ENV["CI"]
// 86:             onoe <<~EOS
// 87:               No known CI provider detected! If you are using GitHub Actions then we cannot find the expected environment variables! Check you have e.g. exported them to a Docker container.
// 88:             EOS
// 89:           end
// 90:         elsif (tap = self.tap.presence) && tap.full_name.casecmp(github_repository)&.zero?
// 91:           # Use GitHub Actions variables for pull request jobs.
// 92:           if (base_ref = ENV.fetch("GITHUB_BASE_REF", nil)).present?
// 93:             unless tap.official?
// 94:               test git.to_s, "-C", repository.to_s, "fetch",
// 95:                    "origin", "+refs/heads/#{base_ref}"
// 96:             end
// 97:             origin_ref = "origin/#{base_ref}"
// 98:             diff_start_sha1 = rev_parse(origin_ref)
// 99:             diff_end_sha1 = github_sha
// 100:           # Use GitHub Actions variables for merge group jobs.
// 101:           elsif ENV.fetch("GITHUB_EVENT_NAME", nil) == "merge_group"
// 102:             diff_start_sha1 = rev_parse(origin_ref)
// 103:             origin_ref = "origin/#{github_ref.gsub(%r{^refs/heads/}, "")}"
// 104:             diff_end_sha1 = github_sha
// 105:           # Use GitHub Actions variables for branch jobs.
// 106:           else
// 107:             test git.to_s, "-C", repository.to_s, "fetch", "origin", "+#{github_ref}" unless tap.official?
// 108:             origin_ref = "origin/#{github_ref.gsub(%r{^refs/heads/}, "")}"
// 109:             diff_end_sha1 = diff_start_sha1 = github_sha
// 110:           end
// 111:         end
// 112:
// 113:         if diff_start_sha1.present? && diff_end_sha1.present?
// 114:           merge_base_sha1 =
// 115:             Utils.safe_popen_read(git, "-C", repository, "merge-base",
// 116:                                   diff_start_sha1, diff_end_sha1).strip
// 117:           diff_start_sha1 = merge_base_sha1 if merge_base_sha1.present?
// 118:         end
// 119:
// 120:         diff_start_sha1 = current_sha1 if diff_start_sha1.blank?
// 121:         diff_end_sha1 = current_sha1 if diff_end_sha1.blank?
// 122:
// 123:         diff_start_sha1 = diff_end_sha1 if @testing_formulae.present?
// 124:
// 125:         if (tap = self.tap.presence)
// 126:           tap_origin_ref_revision_args =
// 127:             [git, "-C", tap.path.to_s, "log", "-1", "--format=%h (%s)", origin_ref]
// 128:           tap_origin_ref_revision = if args.dry_run?
// 129:             # May fail on dry run as we've not fetched.
// 130:             Utils.popen_read(*tap_origin_ref_revision_args).strip
// 131:           else
// 132:             Utils.safe_popen_read(*tap_origin_ref_revision_args)
// 133:           end.strip
// 134:           tap_revision = Utils.safe_popen_read(
// 135:             git, "-C", tap.path.to_s,
// 136:             "log", "-1", "--format=%h (%s)"
// 137:           ).strip
// 138:         end
// 139:
// 140:         puts <<-EOS
// 141:     url               #{url.presence                     || "(blank)"}
// 142:     tap #{origin_ref} #{tap_origin_ref_revision.presence || "(blank)"}
// 143:     HEAD              #{tap_revision.presence            || "(blank)"}
// 144:     diff_start_sha1   #{diff_start_sha1.presence         || "(blank)"}
// 145:     diff_end_sha1     #{diff_end_sha1.presence           || "(blank)"}
// 146:         EOS
// 147:
// 148:         modified_formulae = []
// 149:
// 150:         if diff_start_sha1 != diff_end_sha1 && (tap = self.tap.presence)
// 151:           formula_path = tap.formula_dir.to_s
// 152:           @added_formulae +=
// 153:             diff_formulae(diff_start_sha1, diff_end_sha1, formula_path, "A")
// 154:           modified_formulae +=
// 155:             diff_formulae(diff_start_sha1, diff_end_sha1, formula_path, "M")
// 156:           @deleted_formulae +=
// 157:             diff_formulae(diff_start_sha1, diff_end_sha1, formula_path, "D")
// 158:         end
// 159:
// 160:         # If a formula is both added and deleted: it's actually modified.
// 161:         added_and_deleted_formulae = @added_formulae & @deleted_formulae
// 162:         @added_formulae -= added_and_deleted_formulae
// 163:         @deleted_formulae -= added_and_deleted_formulae
// 164:         modified_formulae += added_and_deleted_formulae
// 165:
// 166:         if args.test_default_formula?
// 167:           @added_formulae.reject! { |formula| formula.start_with?("portable-") }
// 168:           modified_formulae.reject! { |formula| formula.start_with?("portable-") }
// 169:           # Build the default test formulae.
// 170:           modified_formulae += DEFAULT_TEST_FORMULAE
// 171:         elsif @added_formulae.present? &&
// 172:               @added_formulae.all? { |formula| formula.start_with?("portable-") }
// 173:           @added_formulae = ["portable-ruby"]
// 174:         elsif modified_formulae.present? &&
// 175:               modified_formulae.all? { |formula| formula.start_with?("portable-") }
// 176:           modified_formulae = ["portable-ruby"]
// 177:         elsif modified_formulae.any? { |formula| formula.start_with?("portable-") } &&
// 178:               !(ENV["GITHUB_EVENT_NAME"] == "merge_group" && args.only_formulae_detect?)
// 179:           odie "Portable Ruby (and related formulae) cannot be tested in the same job as other formulae!"
// 180:         end
// 181:
// 182:         @testing_formulae += @added_formulae + modified_formulae
// 183:
// 184:         # TODO: Remove `GITHUB_EVENT_NAME` check when formulae detection
// 185:         #       is fixed for branch jobs.
// 186:         if @testing_formulae.blank? &&
// 187:            @deleted_formulae.blank? &&
// 188:            diff_start_sha1 == diff_end_sha1 &&
// 189:            (ENV["GITHUB_EVENT_NAME"] != "push")
// 190:           raise UsageError, "Did not find any formulae or commits to test!"
// 191:         end
// 192:
// 193:         # Remove all duplicates.
// 194:         @testing_formulae.uniq!
// 195:         @added_formulae.uniq!
// 196:         modified_formulae.uniq!
// 197:         @deleted_formulae.uniq!
// 198:
// 199:         # We only need to do a fetch test on formulae that have had a change in the pkg version or bottle block.
// 200:         # These fetch tests only happen in merge queues.
// 201:         @formulae_to_fetch = if diff_start_sha1 == diff_end_sha1 || ENV["GITHUB_EVENT_NAME"] != "merge_group"
// 202:           []
// 203:         else
// 204:           require "formula_versions"
// 205:
// 206:           @testing_formulae.reject do |formula_name|
// 207:             latest_formula = Formula[formula_name]
// 208:
// 209:             # nil = formula not found, false = bottles changed, true = bottles not changed
// 210:             equal_bottles = FormulaVersions.new(latest_formula).formula_at_revision(diff_start_sha1) do |old_formula|
// 211:               old_formula.pkg_version == latest_formula.pkg_version &&
// 212:                 old_formula.bottle_specification == latest_formula.bottle_specification
// 213:             end
// 214:
// 215:             equal_bottles # only exclude the true case (bottles not changed)
// 216:           end
// 217:         end
// 218:
// 219:         puts <<-EOS
// 220:
// 221:     testing_formulae  #{@testing_formulae.join(" ").presence  || "(none)"}
// 222:     added_formulae    #{@added_formulae.join(" ").presence    || "(none)"}
// 223:     modified_formulae #{modified_formulae.join(" ").presence  || "(none)"}
// 224:     deleted_formulae  #{@deleted_formulae.join(" ").presence  || "(none)"}
// 225:     formulae_to_fetch #{@formulae_to_fetch.join(" ").presence || "(none)"}
// 226:         EOS
// 227:       end
// 228:
// 229:       sig { params(formula_name: String, args: Homebrew::Cmd::TestBotCmd::Args).returns(T.nilable(String)) }
// 230:       def safe_formula_canonical_name(formula_name, args:)
// 231:         Homebrew.with_no_api_env do
// 232:           Formulary.factory(formula_name).full_name
// 233:         end
// 234:       rescue FormulaUnavailableError, TapFormulaUnavailableError, TapFormulaAmbiguityError => e
// 235:         onoe e
// 236:         puts e.backtrace if args.debug?
// 237:       end
// 238:
// 239:       sig { params(ref: String).returns(String) }
// 240:       def rev_parse(ref)
// 241:         Utils.popen_read(git, "-C", repository, "rev-parse", "--verify", ref).strip
// 242:       end
// 243:
// 244:       sig { returns(String) }
// 245:       def current_sha1
// 246:         rev_parse("HEAD")
// 247:       end
// 248:
// 249:       sig {
// 250:         params(
// 251:           start_revision: String,
// 252:           end_revision:   String,
// 253:           path:           String,
// 254:           filter:         String,
// 255:         ).returns(T::Array[String])
// 256:       }
// 257:       def diff_formulae(start_revision, end_revision, path, filter)
// 258:         raise "A tap is required to call diff_formulae" unless @tap
// 259:
// 260:         Utils.safe_popen_read(
// 261:           git, "-C", repository,
// 262:           "diff-tree", "-r", "--name-only", "--diff-filter=#{filter}",
// 263:           start_revision, end_revision, "--", path
// 264:         ).lines(chomp: true).filter_map do |file|
// 265:           next unless @tap.formula_file?(file)
// 266:
// 267:           file = Pathname.new(file)
// 268:           @tap.formula_file_to_name(file)
// 269:         end
// 270:       end
// 271:     end
// 272:   end
// 273: end
