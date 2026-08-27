module homebrew

import brew_runtime

// Translated from Homebrew/brew `attestation.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.gh_executable` at line 67.
pub fn ruby_attestation_l67_d1_self_gh_executable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.gh_executable', ...args)
}

// Ruby method `self.sort_formulae_for_install(formulae)` at line 88.
pub fn ruby_attestation_l88_d2_self_sort_formulae_for_install(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.sort_formulae_for_install', ...args)
}

// Ruby method `self.check_attestation(bottle, signing_repo, signing_workflow = nil, subject = nil)` at line 115.
pub fn ruby_attestation_l115_d3_self_check_attestation(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.check_attestation', ...args)
}

// Ruby method `self.check_core_attestation(bottle)` at line 203.
pub fn ruby_attestation_l203_d4_self_check_core_attestation(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.check_core_attestation', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "date"
// 5: require "json"
// 6: require "utils/popen"
// 7: require "utils/github/api"
// 8: require "exceptions"
// 9: require "system_command"
// 10: require "utils/output"
// 11:
// 12: module Homebrew
// 13:   module Attestation
// 14:     extend SystemCommand::Mixin
// 15:     extend Utils::Output::Mixin
// 16:
// 17:     # @api private
// 18:     HOMEBREW_CORE_REPO = "Homebrew/homebrew-core"
// 19:
// 20:     # @api private
// 21:     BACKFILL_REPO = "trailofbits/homebrew-brew-verify"
// 22:
// 23:     # No backfill attestations after this date are considered valid.
// 24:     #
// 25:     # This date is shortly after the backfill operation for homebrew-core
// 26:     # completed, as can be seen here: <https://github.com/trailofbits/homebrew-brew-verify/attestations>.
// 27:     #
// 28:     # In effect, this means that, even if an attacker is able to compromise the backfill
// 29:     # signing workflow, they will be unable to convince a verifier to accept their newer,
// 30:     # malicious backfilled signatures.
// 31:     #
// 32:     # @api private
// 33:     BACKFILL_CUTOFF = DateTime.new(2024, 3, 14).freeze
// 34:
// 35:     # Raised when the attestation was not found.
// 36:     #
// 37:     # @api private
// 38:     class MissingAttestationError < RuntimeError; end
// 39:
// 40:     # Raised when attestation verification fails.
// 41:     #
// 42:     # @api private
// 43:     class InvalidAttestationError < RuntimeError; end
// 44:
// 45:     # Raised if attestation verification cannot continue due to missing
// 46:     # credentials.
// 47:     #
// 48:     # @api private
// 49:     class GhAuthNeeded < RuntimeError; end
// 50:
// 51:     # Raised if attestation verification cannot continue due to invalid
// 52:     # credentials.
// 53:     #
// 54:     # @api private
// 55:     class GhAuthInvalid < RuntimeError; end
// 56:
// 57:     # Raised if attestation verification cannot continue due to `gh`
// 58:     # being incompatible with attestations, typically because it's too old.
// 59:     #
// 60:     # @api private
// 61:     class GhIncompatible < RuntimeError; end
// 62:
// 63:     # Returns a path to a suitable `gh` executable for attestation verification.
// 64:     #
// 65:     # @api private
// 66:     sig { returns(Pathname) }
// 67:     def self.gh_executable
// 68:       @gh_executable ||= T.let(nil, T.nilable(Pathname))
// 69:       return @gh_executable if @gh_executable
// 70:
// 71:       # NOTE: We set HOMEBREW_NO_VERIFY_ATTESTATIONS when installing `gh` itself,
// 72:       #       to prevent a cycle during bootstrapping. This can eventually be resolved
// 73:       #       by vendoring a pure-Ruby Sigstore verifier client.
// 74:       @gh_executable = with_env(HOMEBREW_NO_VERIFY_ATTESTATIONS: "1") do
// 75:         ensure_executable!("gh", reason: "verifying attestations", latest: true)
// 76:       end
// 77:     end
// 78:
// 79:     # Prioritize installing `gh` first if it's in the formula list
// 80:     # or check for the existence of the `gh` executable elsewhere.
// 81:     #
// 82:     # This ensures that a valid version of `gh` is installed before
// 83:     # we use it to check the attestations of any other formulae we
// 84:     # want to install.
// 85:     #
// 86:     # @api private
// 87:     sig { params(formulae: T::Array[Formula]).returns(T::Array[Formula]) }
// 88:     def self.sort_formulae_for_install(formulae)
// 89:       if (gh = formulae.find { |f| f.full_name == "gh" })
// 90:         [gh] | formulae
// 91:       else
// 92:         Homebrew::Attestation.gh_executable
// 93:         formulae
// 94:       end
// 95:     end
// 96:
// 97:     # Verifies the given bottle against a cryptographic attestation of build provenance.
// 98:     #
// 99:     # The provenance is verified as originating from `signing_repository`, which is a `String`
// 100:     # that should be formatted as a GitHub `owner/repository`.
// 101:     #
// 102:     # Callers may additionally pass in `signing_workflow`, which will scope the attestation
// 103:     # down to an exact GitHub Actions workflow, in
// 104:     # `https://github/OWNER/REPO/.github/workflows/WORKFLOW.yml@REF` format.
// 105:     #
// 106:     # @return [Hash] the JSON-decoded response.
// 107:     # @raise [GhAuthNeeded] on any authentication failures
// 108:     # @raise [InvalidAttestationError] on any verification failures
// 109:     #
// 110:     # @api private
// 111:     sig {
// 112:       params(bottle: Bottle, signing_repo: String,
// 113:              signing_workflow: T.nilable(String), subject: T.nilable(String)).returns(T::Hash[String, T.untyped])
// 114:     }
// 115:     def self.check_attestation(bottle, signing_repo, signing_workflow = nil, subject = nil)
// 116:       cmd = ["attestation", "verify", bottle.cached_download, "--repo", signing_repo, "--format",
// 117:              "json"]
// 118:
// 119:       cmd += ["--cert-identity", signing_workflow] if signing_workflow.present?
// 120:
// 121:       # Fail early if we have no credentials. The command below invariably
// 122:       # fails without them, so this saves us an unnecessary subshell.
// 123:       credentials = GitHub::API.credentials
// 124:       raise GhAuthNeeded, "missing credentials" if credentials.blank?
// 125:
// 126:       begin
// 127:         result = system_command!(gh_executable, args: cmd,
// 128:                                  env: { "GH_TOKEN" => credentials, "GH_HOST" => "github.com" },
// 129:                                  secrets: [credentials], print_stderr: false, chdir: HOMEBREW_TEMP)
// 130:       rescue ErrorDuringExecution => e
// 131:         if e.exitstatus == 1 && e.stderr.include?("unknown command")
// 132:           raise GhIncompatible, "gh CLI is incompatible with attestations"
// 133:         end
// 134:
// 135:         # Even if we have credentials, they may be invalid or malformed.
// 136:         if e.exitstatus == 4 || e.stderr.include?("HTTP 401: Bad credentials")
// 137:           raise GhAuthInvalid, "invalid credentials"
// 138:         end
// 139:
// 140:         # The API used to return 404 but now can return 200 with an empty array.
// 141:         # We match the no attestation case precisely as there are similarly worded errors.
// 142:         if e.stderr.include?("HTTP 404: Not Found") || e.stderr.match?(/: no attestations found\R/)
// 143:           raise MissingAttestationError, "attestation not found: #{e}"
// 144:         end
// 145:
// 146:         raise InvalidAttestationError, "attestation verification failed: #{e}"
// 147:       end
// 148:
// 149:       begin
// 150:         attestations = JSON.parse(result.stdout)
// 151:       rescue JSON::ParserError
// 152:         raise InvalidAttestationError, "attestation verification returned malformed JSON"
// 153:       end
// 154:
// 155:       # `gh attestation verify` returns a JSON array of one or more results,
// 156:       # for all attestations that match the input's digest. We want to additionally
// 157:       # filter these down to just the attestation whose subject(s) contain the bottle's name.
// 158:       # As of 2024-12-04 GitHub's Artifact Attestation feature can put multiple subjects
// 159:       # in a single attestation, so we check every subject in each attestation
// 160:       # and select the first attestation with a matching subject.
// 161:       # In particular, this happens with v2.0.0 and later of the
// 162:       # `actions/attest` action.
// 163:       subject = bottle.filename.to_s if subject.blank?
// 164:
// 165:       attestation = if bottle.tag.to_sym == :all
// 166:         # :all-tagged bottles are created by `brew bottle --merge`, and are not directly
// 167:         # bound to their own filename (since they're created by deduplicating other filenames).
// 168:         # To verify these, we parse each attestation subject and look for one with a matching
// 169:         # formula (name, version), but not an exact tag match.
// 170:         # This is sound insofar as the signature has already been verified. However,
// 171:         # longer term, we should also directly attest to `:all`-tagged bottles.
// 172:         attestations.find do |a|
// 173:           candidate_subjects = a.dig("verificationResult", "statement", "subject")
// 174:           candidate_subjects.any? do |candidate|
// 175:             candidate["name"].start_with? "#{bottle.filename.name}--#{bottle.filename.version}"
// 176:           end
// 177:         end
// 178:       else
// 179:         attestations.find do |a|
// 180:           candidate_subjects = a.dig("verificationResult", "statement", "subject")
// 181:           candidate_subjects.any? { |candidate| candidate["name"] == subject }
// 182:         end
// 183:       end
// 184:
// 185:       raise InvalidAttestationError, "no attestation matches subject: #{subject}" if attestation.blank?
// 186:
// 187:       attestation
// 188:     end
// 189:
// 190:     ATTESTATION_MAX_RETRIES = 5
// 191:
// 192:     # Verifies the given bottle against a cryptographic attestation of build provenance
// 193:     # from homebrew-core's CI, falling back on a "backfill" attestation for older bottles.
// 194:     #
// 195:     # This is a specialization of `check_attestation` for homebrew-core.
// 196:     #
// 197:     # @return [Hash] the JSON-decoded response
// 198:     # @raise [GhAuthNeeded] on any authentication failures
// 199:     # @raise [InvalidAttestationError] on any verification failures
// 200:     #
// 201:     # @api private
// 202:     sig { params(bottle: Bottle).returns(T::Hash[String, T.untyped]) }
// 203:     def self.check_core_attestation(bottle)
// 204:       begin
// 205:         # Ideally, we would also constrain the signing workflow here, but homebrew-core
// 206:         # currently uses multiple signing workflows to produce bottles
// 207:         # (e.g. `dispatch-build-bottle.yml`, `dispatch-rebottle.yml`, etc.).
// 208:         #
// 209:         # We could check each of these (1) explicitly (slow), (2) by generating a pattern
// 210:         # to pass into `--cert-identity-regex` (requires us to build up a Go-style regex),
// 211:         # or (3) by checking the resulting JSON for the expected signing workflow.
// 212:         #
// 213:         # Long term, we should probably either do (3) *or* switch to a single reusable
// 214:         # workflow, which would then be our sole identity. However, GitHub's
// 215:         # attestations currently do not include reusable workflow state by default.
// 216:         attestation = check_attestation bottle, HOMEBREW_CORE_REPO
// 217:         return attestation
// 218:       rescue MissingAttestationError
// 219:         odebug "falling back on backfilled attestation for #{bottle.filename}"
// 220:
// 221:         # Our backfilled attestation is a little unique: the subject is not just the bottle
// 222:         # filename, but also has the bottle's hosted URL hash prepended to it.
// 223:         # This was originally unintentional, but has a virtuous side effect of further
// 224:         # limiting domain separation on the backfilled signatures (by committing them to
// 225:         # their original bottle URLs).
// 226:         url_sha256 = if EnvConfig.bottle_domain_custom?
// 227:           # If our bottle is coming from a mirror, we need to recompute the expected
// 228:           # non-mirror URL to make the hash match.
// 229:           checksum = bottle.resource.checksum
// 230:           odie "#{bottle.resource.name} checksum is nil" if checksum.nil?
// 231:           path, = Utils::Bottles.path_resolved_basename HOMEBREW_BOTTLE_DEFAULT_DOMAIN, bottle.name,
// 232:                                                         checksum, bottle.filename
// 233:           url = "#{HOMEBREW_BOTTLE_DEFAULT_DOMAIN}/#{path}"
// 234:
// 235:           Digest::SHA256.hexdigest(url)
// 236:         else
// 237:           Digest::SHA256.hexdigest(bottle.url)
// 238:         end
// 239:         subject = "#{url_sha256}--#{bottle.filename}"
// 240:
// 241:         # We don't pass in a signing workflow for backfill signatures because
// 242:         # some backfilled bottle signatures were signed from the 'backfill'
// 243:         # branch, and others from 'main' of trailofbits/homebrew-brew-verify
// 244:         # so the signing workflow is slightly different which causes some bottles to incorrectly
// 245:         # fail when checking their attestation. This shouldn't meaningfully affect security
// 246:         # because if somehow someone could generate false backfill attestations
// 247:         # from a different workflow we will still catch it because the
// 248:         # attestation would have been generated after our cutoff date.
// 249:         backfill_attestation = check_attestation bottle, BACKFILL_REPO, nil, subject
// 250:         timestamp = backfill_attestation.dig("verificationResult", "verifiedTimestamps",
// 251:                                              0, "timestamp")
// 252:
// 253:         raise InvalidAttestationError, "backfill attestation is missing verified timestamp" if timestamp.nil?
// 254:
// 255:         if DateTime.parse(timestamp) > BACKFILL_CUTOFF
// 256:           raise InvalidAttestationError, "backfill attestation post-dates cutoff"
// 257:         end
// 258:       end
// 259:
// 260:       backfill_attestation
// 261:     rescue InvalidAttestationError
// 262:       @attestation_retry_count ||= T.let(Hash.new(0), T.nilable(T::Hash[Bottle, Integer]))
// 263:       raise if @attestation_retry_count[bottle] >= ATTESTATION_MAX_RETRIES
// 264:
// 265:       sleep_time = 3 ** @attestation_retry_count[bottle]
// 266:       opoo "Failed to verify attestation. Retrying in #{sleep_time}s..."
// 267:       sleep sleep_time if ENV["HOMEBREW_TESTS"].blank?
// 268:       @attestation_retry_count[bottle] += 1
// 269:       retry
// 270:     end
// 271:   end
// 272: end
