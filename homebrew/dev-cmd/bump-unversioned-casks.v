module dev_cmd

import brew_runtime

// Translated from Homebrew/brew `dev-cmd/bump-unversioned-casks.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `run` at line 32.
pub fn ruby_bump_unversioned_casks_l32_d1_run(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('run', ...args)
}

// Ruby method `bump_unversioned_cask(cask, state:)` at line 90.
pub fn ruby_bump_unversioned_casks_l90_d2_bump_unversioned_cask(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('bump_unversioned_cask', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "timeout"
// 5: require "cask/download"
// 6: require "cask/installer"
// 7: require "cask/cask_loader"
// 8: require "system_command"
// 9: require "tap"
// 10: require "unversioned_cask_checker"
// 11:
// 12: module Homebrew
// 13:   module DevCmd
// 14:     class BumpUnversionedCasks < AbstractCommand
// 15:       include SystemCommand::Mixin
// 16:
// 17:       cmd_args do
// 18:         description <<~EOS
// 19:           Check all casks with unversioned URLs in a given <tap> for updates.
// 20:         EOS
// 21:         switch "-n", "--dry-run",
// 22:                description: "Do everything except caching state and opening pull requests."
// 23:         flag   "--limit=",
// 24:                description: "Maximum runtime in minutes."
// 25:         flag   "--state-file=",
// 26:                description: "File for caching state."
// 27:
// 28:         named_args [:cask, :tap], min: 1, without_api: true
// 29:       end
// 30:
// 31:       sig { override.void }
// 32:       def run
// 33:         Homebrew.install_bundler_gems!(groups: ["bump_unversioned_casks"])
// 34:
// 35:         state_file = if args.state_file.present?
// 36:           Pathname(T.must(args.state_file)).expand_path
// 37:         else
// 38:           HOMEBREW_CACHE/"bump_unversioned_casks.json"
// 39:         end
// 40:         state_file.dirname.mkpath
// 41:
// 42:         state = state_file.exist? ? JSON.parse(state_file.read) : {}
// 43:
// 44:         casks = args.named.to_paths(only: :cask, recurse_tap: true).map { |path| Cask::CaskLoader.load(path) }
// 45:
// 46:         unversioned_casks = casks.select do |cask|
// 47:           cask.url&.unversioned? && !cask.livecheck_defined?
// 48:         end
// 49:
// 50:         ohai "Unversioned Casks: #{unversioned_casks.count} (#{state.size} cached)"
// 51:
// 52:         checked, unchecked = unversioned_casks.partition { |c| state.key?(c.full_name) }
// 53:
// 54:         queue = Queue.new
// 55:
// 56:         # Start with random casks which have not been checked.
// 57:         unchecked.shuffle.each do |c|
// 58:           queue.enq c
// 59:         end
// 60:
// 61:         # Continue with previously checked casks, ordered by when they were last checked.
// 62:         checked.sort_by { |c| state.dig(c.full_name, "check_time") }.each do |c|
// 63:           queue.enq c
// 64:         end
// 65:
// 66:         limit = args.limit.presence&.to_i
// 67:         end_time = Time.now + (limit * 60) if limit
// 68:
// 69:         until queue.empty? || (end_time && end_time < Time.now)
// 70:           cask = queue.deq
// 71:
// 72:           key = cask.full_name
// 73:
// 74:           new_state = bump_unversioned_cask(cask, state: state.fetch(key, {}))
// 75:
// 76:           next unless new_state
// 77:
// 78:           state[key] = new_state
// 79:
// 80:           state_file.atomic_write JSON.pretty_generate(state) unless args.dry_run?
// 81:         end
// 82:       end
// 83:
// 84:       private
// 85:
// 86:       sig {
// 87:         params(cask: Cask::Cask, state: T::Hash[String, T.untyped])
// 88:           .returns(T.nilable(T::Hash[String, T.untyped]))
// 89:       }
// 90:       def bump_unversioned_cask(cask, state:)
// 91:         ohai "Checking #{cask.full_name}"
// 92:
// 93:         unversioned_cask_checker = UnversionedCaskChecker.new(cask)
// 94:
// 95:         if !unversioned_cask_checker.single_app_cask? &&
// 96:            !unversioned_cask_checker.single_pkg_cask? &&
// 97:            !unversioned_cask_checker.single_qlplugin_cask?
// 98:           opoo "Skipping, not a single-app or PKG cask."
// 99:           return
// 100:         end
// 101:
// 102:         last_check_time = state["check_time"]&.then { |t| Time.parse(t) }
// 103:
// 104:         check_time = Time.now
// 105:         if last_check_time && (check_time - last_check_time) / 3600 < 24
// 106:           opoo "Skipping, already checked within the last 24 hours."
// 107:           return
// 108:         end
// 109:
// 110:         last_sha256 = state["sha256"]
// 111:         last_time = state["time"]&.then { |t| Time.parse(t) }
// 112:         last_file_size = state["file_size"]
// 113:
// 114:         download = Cask::Download.new(cask)
// 115:         time, file_size = begin
// 116:           download.time_file_size
// 117:         rescue
// 118:           [nil, nil]
// 119:         end
// 120:
// 121:         if last_time != time || last_file_size != file_size
// 122:           sha256 = begin
// 123:             Timeout.timeout(5 * 60) do
// 124:               unversioned_cask_checker.installer.download.sha256
// 125:             end
// 126:           rescue => e
// 127:             onoe e
// 128:
// 129:             nil
// 130:           end
// 131:
// 132:           if sha256.present? && last_sha256 != sha256
// 133:             version = begin
// 134:               Timeout.timeout(60) do
// 135:                 unversioned_cask_checker.guess_cask_version
// 136:               end
// 137:             rescue Timeout::Error
// 138:               onoe "Timed out guessing version for cask '#{cask}'."
// 139:
// 140:               nil
// 141:             end
// 142:
// 143:             if version
// 144:               if cask.version == version
// 145:                 oh1 "Cask #{cask} is up-to-date at #{version}"
// 146:               else
// 147:                 sourcefile_path = cask.sourcefile_path
// 148:                 raise "unexpected nil cask.sourcefile_path" unless sourcefile_path
// 149:
// 150:                 bump_cask_pr_args = [
// 151:                   "bump-cask-pr",
// 152:                   "--version", version.to_s,
// 153:                   "--sha256", ":no_check",
// 154:                   "--message", "Automatic update via `brew bump-unversioned-casks`.",
// 155:                   sourcefile_path
// 156:                 ]
// 157:
// 158:                 if args.dry_run?
// 159:                   bump_cask_pr_args << "--dry-run"
// 160:                   oh1 "Would bump #{cask} from #{cask.version} to #{version}"
// 161:                 else
// 162:                   oh1 "Bumping #{cask} from #{cask.version} to #{version}"
// 163:                 end
// 164:
// 165:                 begin
// 166:                   system_command! HOMEBREW_BREW_FILE, args: bump_cask_pr_args
// 167:                 rescue ErrorDuringExecution => e
// 168:                   onoe e
// 169:                 end
// 170:               end
// 171:             end
// 172:           end
// 173:         end
// 174:
// 175:         {
// 176:           "sha256"     => sha256,
// 177:           "check_time" => check_time.iso8601,
// 178:           "time"       => time&.iso8601,
// 179:           "file_size"  => file_size,
// 180:         }
// 181:       end
// 182:     end
// 183:   end
// 184: end
