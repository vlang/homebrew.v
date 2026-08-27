module test_bot

import brew_runtime

// Translated from Homebrew/brew `test_bot/test_cleanup.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `reset_if_needed(repository)` at line 18.
pub fn ruby_test_cleanup_l18_d1_reset_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reset_if_needed', ...args)
}

// Ruby method `delete_or_move(paths, sudo: false)` at line 29.
pub fn ruby_test_cleanup_l29_d2_delete_or_move(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('delete_or_move', ...args)
}

// Ruby method `cleanup_shared` at line 58.
pub fn ruby_test_cleanup_l58_d3_cleanup_shared(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cleanup_shared', ...args)
}

// Ruby method `default_origin_ref(repository)` at line 139.
pub fn ruby_test_cleanup_l139_d4_default_origin_ref(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('default_origin_ref', ...args)
}

// Ruby method `checkout_branch_if_needed(repository)` at line 148.
pub fn ruby_test_cleanup_l148_d5_checkout_branch_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('checkout_branch_if_needed', ...args)
}

// Ruby method `cleanup_git_meta(repository)` at line 160.
pub fn ruby_test_cleanup_l160_d6_cleanup_git_meta(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cleanup_git_meta', ...args)
}

// Ruby method `clean_if_needed(repository)` at line 167.
pub fn ruby_test_cleanup_l167_d7_clean_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('clean_if_needed', ...args)
}

// Ruby method `prune_if_needed(repository)` at line 184.
pub fn ruby_test_cleanup_l184_d8_prune_if_needed(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prune_if_needed', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "os"
// 5: require "tap"
// 6:
// 7: module Homebrew
// 8:   module TestBot
// 9:     class TestCleanup < Test
// 10:       protected
// 11:
// 12:       ALLOWED_TAPS = T.let([
// 13:         CoreTap.instance.name,
// 14:         CoreCaskTap.instance.name,
// 15:       ].freeze, T::Array[String])
// 16:
// 17:       sig { params(repository: String).void }
// 18:       def reset_if_needed(repository)
// 19:         default_ref = default_origin_ref(repository)
// 20:
// 21:         return if system(git.to_s, "-C", repository, "diff", "--quiet", default_ref)
// 22:
// 23:         test git.to_s, "-C", repository, "reset", "--hard", default_ref
// 24:       end
// 25:
// 26:       # Moving files is faster than removing them,
// 27:       # so move them if the current runner is ephemeral.
// 28:       sig { params(paths: T::Array[Pathname], sudo: T::Boolean).void }
// 29:       def delete_or_move(paths, sudo: false)
// 30:         return if paths.blank?
// 31:
// 32:         symlinks, paths = paths.partition(&:symlink?)
// 33:
// 34:         FileUtils.rm_f symlinks
// 35:         return if ENV["HOMEBREW_GITHUB_ACTIONS"].blank?
// 36:
// 37:         paths.select!(&:exist?)
// 38:         return if paths.blank?
// 39:
// 40:         if ENV["GITHUB_ACTIONS_HOMEBREW_SELF_HOSTED"].present?
// 41:           if sudo
// 42:             test "sudo", "rm", "-rf", *paths.map(&:to_s)
// 43:           else
// 44:             FileUtils.rm_rf paths
// 45:           end
// 46:         else
// 47:           paths.each do |path|
// 48:             if sudo
// 49:               test "sudo", "mv", path.to_s, Dir.mktmpdir
// 50:             else
// 51:               FileUtils.mv path, Dir.mktmpdir, force: true
// 52:             end
// 53:           end
// 54:         end
// 55:       end
// 56:
// 57:       sig { void }
// 58:       def cleanup_shared
// 59:         FileUtils.chmod_R("u+X", HOMEBREW_CELLAR, force: true)
// 60:
// 61:         if repository.exist?
// 62:           repo = repository.to_s
// 63:           cleanup_git_meta(repo)
// 64:           clean_if_needed(repo)
// 65:           prune_if_needed(repo)
// 66:         end
// 67:
// 68:         if HOMEBREW_REPOSITORY != HOMEBREW_PREFIX
// 69:           paths_to_delete = []
// 70:
// 71:           info_header "Determining #{HOMEBREW_PREFIX} files to purge..."
// 72:           Keg.must_be_writable_directories.each(&:mkpath)
// 73:           Pathname.glob("#{HOMEBREW_PREFIX}/**/*", File::FNM_DOTMATCH).each do |path|
// 74:             next if Keg.must_be_writable_directories.include?(path)
// 75:             next if path == HOMEBREW_PREFIX/"bin/brew"
// 76:             next if path == HOMEBREW_PREFIX/"var"
// 77:             next if path == HOMEBREW_PREFIX/"var/homebrew"
// 78:
// 79:             basename = path.basename.to_s
// 80:             next if basename == "."
// 81:             next if basename == ".keepme"
// 82:
// 83:             path_string = path.to_s
// 84:             next if path_string.start_with?(HOMEBREW_REPOSITORY.to_s)
// 85:             next if path_string.start_with?(Dir.pwd.to_s)
// 86:
// 87:             # allow deleting non-existent osxfuse symlinks.
// 88:             if (!path.symlink? || path.resolved_path_exists?) &&
// 89:                # don't try to delete other osxfuse files
// 90:                path_string.match?("(include|lib)/(lib|osxfuse/|pkgconfig/)?(osx|mac)?fuse(.*.(dylib|h|la|pc))?$")
// 91:               next
// 92:             end
// 93:
// 94:             FileUtils.chmod("u+rw", path) if path.owned? && (!path.readable? || !path.writable?)
// 95:             paths_to_delete << path
// 96:           end
// 97:
// 98:           # Do this in a second pass so that all children have their permissions fixed before we delete the parent.
// 99:           info_header "Purging..."
// 100:           delete_or_move paths_to_delete
// 101:         end
// 102:
// 103:         if tap
// 104:           checkout_branch_if_needed(HOMEBREW_REPOSITORY.to_s)
// 105:           reset_if_needed(HOMEBREW_REPOSITORY.to_s)
// 106:           clean_if_needed(HOMEBREW_REPOSITORY.to_s)
// 107:         end
// 108:
// 109:         # Keep all "brew" invocations after HOMEBREW_REPOSITORY operations
// 110:         # (which cleans up Homebrew/brew)
// 111:         taps_to_remove = Tap.map do |t|
// 112:           next if t.name == tap&.name
// 113:           next if ALLOWED_TAPS.include?(t.name)
// 114:
// 115:           t.path
// 116:         end.uniq.compact
// 117:         delete_or_move taps_to_remove
// 118:
// 119:         Pathname.glob("#{HOMEBREW_LIBRARY}/Taps/*/*").each do |git_repo|
// 120:           git_repo_str = git_repo.to_s
// 121:           cleanup_git_meta(git_repo_str)
// 122:           next if repository == git_repo
// 123:
// 124:           checkout_branch_if_needed(git_repo_str)
// 125:           reset_if_needed(git_repo_str)
// 126:           clean_if_needed(git_repo_str)
// 127:           prune_if_needed(git_repo_str)
// 128:         end
// 129:
// 130:         # don't need to do `brew cleanup` unless we're self-hosted.
// 131:         return if ENV["HOMEBREW_GITHUB_ACTIONS"] && !ENV["GITHUB_ACTIONS_HOMEBREW_SELF_HOSTED"]
// 132:
// 133:         test "brew", "cleanup", "--prune=3"
// 134:       end
// 135:
// 136:       private
// 137:
// 138:       sig { params(repository: String).returns(String) }
// 139:       def default_origin_ref(repository)
// 140:         default_branch = Utils.popen_read(
// 141:           git, "-C", repository, "symbolic-ref", "refs/remotes/origin/HEAD", "--short"
// 142:         ).strip.presence
// 143:         default_branch ||= "origin/main"
// 144:         default_branch
// 145:       end
// 146:
// 147:       sig { params(repository: String).void }
// 148:       def checkout_branch_if_needed(repository)
// 149:         # We limit this to two parts, because branch names can have slashes in
// 150:         default_branch = default_origin_ref(repository).split("/", 2).last
// 151:         current_branch = Utils.safe_popen_read(
// 152:           git, "-C", repository, "symbolic-ref", "HEAD", "--short"
// 153:         ).strip
// 154:         return if default_branch == current_branch
// 155:
// 156:         test git.to_s, "-C", repository, "checkout", "-f", default_branch.to_s
// 157:       end
// 158:
// 159:       sig { params(repository: String).void }
// 160:       def cleanup_git_meta(repository)
// 161:         pr_locks = "#{repository}/.git/refs/remotes/*/pr/*/*.lock"
// 162:         Dir.glob(pr_locks) { |lock| FileUtils.rm_f lock }
// 163:         FileUtils.rm_f "#{repository}/.git/gc.log"
// 164:       end
// 165:
// 166:       sig { params(repository: String).void }
// 167:       def clean_if_needed(repository)
// 168:         return if repository == HOMEBREW_PREFIX && HOMEBREW_PREFIX != HOMEBREW_REPOSITORY
// 169:
// 170:         clean_args = [
// 171:           "-dx",
// 172:           "--exclude=/*.bottle*.*",
// 173:           "--exclude=/Library/Taps",
// 174:           "--exclude=/Library/Homebrew/vendor",
// 175:         ]
// 176:         return if Utils.safe_popen_read(
// 177:           git, "-C", repository, "clean", "--dry-run", *clean_args
// 178:         ).strip.empty?
// 179:
// 180:         test git.to_s, "-C", repository, "clean", "-ff", *clean_args
// 181:       end
// 182:
// 183:       sig { params(repository: String).void }
// 184:       def prune_if_needed(repository)
// 185:         return unless Utils.safe_popen_read(
// 186:           "#{git} -C '#{repository}' -c gc.autoDetach=false gc --auto 2>&1",
// 187:         ).include?("git prune")
// 188:
// 189:         test git.to_s, "-C", repository, "prune"
// 190:       end
// 191:     end
// 192:   end
// 193: end
