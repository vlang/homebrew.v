module test

import brew_runtime

// Translated from Homebrew/brew `test/download_queue_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:download_queue) { described_class.new }` at line 7.
pub fn ruby_download_queue_spec_l7_d1_download_queue(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('download_queue', ...args)
}

// Ruby let `let(:cached_download) { HOMEBREW_CACHE/"downloads/testball--0.1.tar.gz" }` at line 9.
pub fn ruby_download_queue_spec_l9_d2_cached_download(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cached_download', ...args)
}

// Ruby let `let(:downloadable) do` at line 10.
pub fn ruby_download_queue_spec_l10_d3_downloadable(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('downloadable', ...args)
}

// Ruby let `let(:download_error) { DownloadError.new(downloadable, RuntimeError.new("network blew up")) }` at line 22.
pub fn ruby_download_queue_spec_l22_d4_download_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('download_error', ...args)
}

// Ruby let `let(:multi_line_download_error) { DownloadError.new(downloadable, RuntimeError.new("line one\nline two")) }` at line 23.
pub fn ruby_download_queue_spec_l23_d5_multi_line_download_error(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('multi_line_download_error', ...args)
}

// Ruby let `let(:retryable_download) { instance_double(Homebrew::RetryableDownload) }` at line 24.
pub fn ruby_download_queue_spec_l24_d6_retryable_download(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('retryable_download', ...args)
}

// Ruby it `it "reports rejected download errors in parallel mode and marks the fetch as failed" do` at line 36.
pub fn ruby_download_queue_spec_l36_d7_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "defers multi-line failure details on a TTY until the in-place redraw has finished" do` at line 45.
pub fn ruby_download_queue_spec_l45_d8_defers(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('defers', ...args)
}

// Ruby it `it "fetches only downloads of the given class and keeps others queued unreported" do` at line 74.
pub fn ruby_download_queue_spec_l74_d9_fetches(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('fetches', ...args)
}

// Ruby it `it "raises and clears queue state on a bottle manifest failure in parallel mode" do` at line 96.
pub fn ruby_download_queue_spec_l96_d10_raises(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('raises', ...args)
}

// Ruby it `it "reports but tolerates failed downloads when failures are allowed" do` at line 105.
pub fn ruby_download_queue_spec_l105_d11_reports(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('reports', ...args)
}

// Ruby it `it "tolerates failed downloads in serial mode when failures are allowed" do` at line 115.
pub fn ruby_download_queue_spec_l115_d12_tolerates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('tolerates', ...args)
}

// Ruby it `it "removes known-bad cached files for tolerated checksum mismatches" do` at line 125.
pub fn ruby_download_queue_spec_l125_d13_removes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('removes', ...args)
}

// Ruby it `it "removes known-bad cached files for tolerated checksum mismatches in serial mode" do` at line 138.
pub fn ruby_download_queue_spec_l138_d14_removes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('removes', ...args)
}

// Ruby it `it "cancels remaining downloads and raises on a bottle manifest failure in serial mode" do` at line 152.
pub fn ruby_download_queue_spec_l152_d15_cancels(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('cancels', ...args)
}

// Ruby it `it "brackets TTY redraw frames in a DEC 2026 synchronized update" do` at line 162.
pub fn ruby_download_queue_spec_l162_d16_brackets(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('brackets', ...args)
}

// Ruby it `it "leaves the final terminal column empty when rendering progress" do` at line 184.
pub fn ruby_download_queue_spec_l184_d17_leaves(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('leaves', ...args)
}

// Ruby it `it "emits no synchronized update sequences when stdout is not a TTY" do` at line 202.
pub fn ruby_download_queue_spec_l202_d18_emits(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('emits', ...args)
}

// Ruby it `it "prints the heading to stderr when stdout is not a TTY" do` at line 211.
pub fn ruby_download_queue_spec_l211_d19_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Ruby it `it "keeps the heading off stdout when stdout is not a TTY" do` at line 220.
pub fn ruby_download_queue_spec_l220_d20_keeps(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('keeps', ...args)
}

// Ruby it `it "prints the heading to stdout on a TTY" do` at line 229.
pub fn ruby_download_queue_spec_l229_d21_prints(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('prints', ...args)
}

// Ruby it `it "wakes when downloads complete instead of polling with sleep" do` at line 243.
pub fn ruby_download_queue_spec_l243_d22_wakes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('wakes', ...args)
}

// Ruby it `it "skips fetching already downloaded files with a valid checksum" do` at line 258.
pub fn ruby_download_queue_spec_l258_d23_skips(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('skips', ...args)
}

// Ruby it `it "runs queued staging before completing the fetch" do` at line 271.
pub fn ruby_download_queue_spec_l271_d24_runs(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('runs', ...args)
}

// Ruby it `it "uses the fetched path for queued staging when it changes during fetch" do` at line 283.
pub fn ruby_download_queue_spec_l283_d25_uses(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('uses', ...args)
}

// Ruby it `it "interrupts queued staging when the fetch is interrupted", timeout: 5 do` at line 296.
pub fn ruby_download_queue_spec_l296_d26_interrupts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('interrupts', ...args)
}

// Ruby it `it "promotes an in-flight download to queued staging" do` at line 335.
pub fn ruby_download_queue_spec_l335_d27_promotes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('promotes', ...args)
}

// Ruby it `it "checks attestations for valid cached bottles" do` at line 347.
pub fn ruby_download_queue_spec_l347_d28_checks(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('checks', ...args)
}

// Ruby it `it "memoizes the queue created on first use" do` at line 366.
pub fn ruby_download_queue_spec_l366_d29_memoizes(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('memoizes', ...args)
}

// Ruby it `it "does not leak a queue stubbed by an earlier example" do` at line 373.
pub fn ruby_download_queue_spec_l373_d30_does(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('does', ...args)
}

// Ruby it `it "shuts down a memoized real queue when reset" do` at line 377.
pub fn ruby_download_queue_spec_l377_d31_shuts(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('shuts', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: true
// 2: # frozen_string_literal: true
// 3:
// 4: require "download_queue"
// 5:
// 6: RSpec.describe Homebrew::DownloadQueue do
// 7:   subject(:download_queue) { described_class.new }
// 8:
// 9:   let(:cached_download) { HOMEBREW_CACHE/"downloads/testball--0.1.tar.gz" }
// 10:   let(:downloadable) do
// 11:     instance_double(
// 12:       Downloadable,
// 13:       cached_download:,
// 14:       checksum:               nil,
// 15:       downloaded_and_valid?:  false,
// 16:       downloader:             nil,
// 17:       download_queue_message: "Bottle testball",
// 18:       download_queue_name:    "testball",
// 19:       download_queue_type:    "Bottle",
// 20:     )
// 21:   end
// 22:   let(:download_error) { DownloadError.new(downloadable, RuntimeError.new("network blew up")) }
// 23:   let(:multi_line_download_error) { DownloadError.new(downloadable, RuntimeError.new("line one\nline two")) }
// 24:   let(:retryable_download) { instance_double(Homebrew::RetryableDownload) }
// 25:
// 26:   before do
// 27:     allow(Homebrew::EnvConfig).to receive(:download_concurrency).and_return(2)
// 28:     allow(retryable_download).to receive(:fetch).and_raise(download_error)
// 29:     allow(Homebrew::RetryableDownload).to receive(:new).and_return(retryable_download)
// 30:   end
// 31:
// 32:   after do
// 33:     download_queue.shutdown
// 34:   end
// 35:
// 36:   it "reports rejected download errors in parallel mode and marks the fetch as failed" do
// 37:     download_queue.enqueue(downloadable)
// 38:
// 39:     expect { download_queue.fetch }.to output(/network blew up/).to_stderr
// 40:
// 41:     expect(download_queue.failed_downloads).to eq([downloadable])
// 42:     expect(Homebrew).to have_failed
// 43:   end
// 44:
// 45:   it "defers multi-line failure details on a TTY until the in-place redraw has finished" do
// 46:     allow($stdout).to receive(:tty?).and_return(true)
// 47:     ENV["TERM"] = "xterm-256color"
// 48:     allow(downloadable).to receive(:fetched_size).and_return(nil)
// 49:     allow(retryable_download).to receive(:fetch).and_raise(multi_line_download_error)
// 50:
// 51:     download_queue.enqueue(downloadable)
// 52:
// 53:     # Stub the write methods (rather than reassigning $stdout/$stderr) so both
// 54:     # streams append to one buffer in call order, the same way they'd interleave
// 55:     # on a real terminal.
// 56:     combined_output = +""
// 57:     allow($stdout).to receive(:print) { |message| combined_output << message }
// 58:     allow($stdout).to receive(:flush)
// 59:     allow($stderr).to receive(:puts) { |message| combined_output << "#{message}\n" }
// 60:
// 61:     download_queue.fetch
// 62:
// 63:     show_cursor_index = combined_output.index(Tty.show_cursor)
// 64:     failure_index = combined_output.index("line one\nline two")
// 65:
// 66:     expect(show_cursor_index).not_to be_nil
// 67:     expect(failure_index).not_to be_nil
// 68:     # The redraw loop assumes every line it prints in-place occupies exactly one
// 69:     # terminal row, so a multi-line failure must be held back until the cursor is
// 70:     # restored to normal scrolling, not printed while the redraw is still live.
// 71:     expect(failure_index).to be > show_cursor_index
// 72:   end
// 73:
// 74:   it "fetches only downloads of the given class and keeps others queued unreported" do
// 75:     manifest = instance_double(
// 76:       Resource::BottleManifest,
// 77:       cached_download:        HOMEBREW_CACHE/"downloads/testball_manifest.json",
// 78:       checksum:               nil,
// 79:       downloaded_and_valid?:  true,
// 80:       downloader:             nil,
// 81:       download_queue_message: "Bottle Manifest testball",
// 82:       download_queue_name:    "testball",
// 83:       download_queue_type:    "Bottle Manifest",
// 84:     )
// 85:     allow(manifest).to receive(:is_a?) { |klass| klass == Resource::BottleManifest }
// 86:
// 87:     download_queue.enqueue(manifest)
// 88:     download_queue.enqueue(downloadable)
// 89:
// 90:     expect do
// 91:       download_queue.fetch(only: Resource::BottleManifest)
// 92:     end.to output(/Bottle Manifest testball/).to_stderr
// 93:     expect(download_queue.downloads.keys).to eq [downloadable]
// 94:   end
// 95:
// 96:   it "raises and clears queue state on a bottle manifest failure in parallel mode" do
// 97:     allow(retryable_download).to receive(:fetch).and_raise(Resource::BottleManifest::Error.new("manifest missing"))
// 98:
// 99:     download_queue.enqueue(downloadable)
// 100:
// 101:     expect { download_queue.fetch }.to raise_error(Resource::BottleManifest::Error, /manifest missing/)
// 102:     expect(download_queue.downloads).to be_empty
// 103:   end
// 104:
// 105:   it "reports but tolerates failed downloads when failures are allowed" do
// 106:     allow(retryable_download).to receive(:fetch).and_raise(Resource::BottleManifest::Error.new("manifest missing"))
// 107:
// 108:     download_queue.enqueue(downloadable)
// 109:
// 110:     expect { download_queue.fetch(allow_failures: true) }.to output(/✘/).to_stderr
// 111:     expect(download_queue.failed_downloads).to be_empty
// 112:     expect(Homebrew).not_to have_failed
// 113:   end
// 114:
// 115:   it "tolerates failed downloads in serial mode when failures are allowed" do
// 116:     allow(Homebrew::EnvConfig).to receive(:download_concurrency).and_return(1)
// 117:     allow(retryable_download).to receive(:fetch).and_raise(Resource::BottleManifest::Error.new("manifest missing"))
// 118:
// 119:     download_queue.enqueue(downloadable)
// 120:
// 121:     expect { download_queue.fetch(allow_failures: true) }.to output(/✘/).to_stderr
// 122:     expect(Homebrew).not_to have_failed
// 123:   end
// 124:
// 125:   it "removes known-bad cached files for tolerated checksum mismatches" do
// 126:     cached_download.dirname.mkpath
// 127:     cached_download.write("corrupt")
// 128:     allow(retryable_download).to receive(:fetch)
// 129:       .and_raise(ChecksumMismatchError.new(cached_download, Checksum.new("aa" * 32), Checksum.new("bb" * 32)))
// 130:
// 131:     download_queue.enqueue(downloadable)
// 132:
// 133:     expect { download_queue.fetch(allow_failures: true) }.to output(/✘/).to_stderr
// 134:     expect(cached_download).not_to exist
// 135:     expect(Homebrew).not_to have_failed
// 136:   end
// 137:
// 138:   it "removes known-bad cached files for tolerated checksum mismatches in serial mode" do
// 139:     allow(Homebrew::EnvConfig).to receive(:download_concurrency).and_return(1)
// 140:     cached_download.dirname.mkpath
// 141:     cached_download.write("corrupt")
// 142:     allow(retryable_download).to receive(:fetch)
// 143:       .and_raise(ChecksumMismatchError.new(cached_download, Checksum.new("aa" * 32), Checksum.new("bb" * 32)))
// 144:
// 145:     download_queue.enqueue(downloadable)
// 146:
// 147:     expect { download_queue.fetch(allow_failures: true) }.to output(/✘/).to_stderr
// 148:     expect(cached_download).not_to exist
// 149:     expect(Homebrew).not_to have_failed
// 150:   end
// 151:
// 152:   it "cancels remaining downloads and raises on a bottle manifest failure in serial mode" do
// 153:     allow(Homebrew::EnvConfig).to receive(:download_concurrency).and_return(1)
// 154:     allow(retryable_download).to receive(:fetch).and_raise(Resource::BottleManifest::Error.new("manifest missing"))
// 155:
// 156:     download_queue.enqueue(downloadable)
// 157:
// 158:     expect(download_queue).to receive(:cancel)
// 159:     expect { download_queue.fetch }.to raise_error(Resource::BottleManifest::Error, /manifest missing/)
// 160:   end
// 161:
// 162:   it "brackets TTY redraw frames in a DEC 2026 synchronized update" do
// 163:     allow($stdout).to receive(:tty?).and_return(true)
// 164:     ENV["TERM"] = "xterm-256color"
// 165:     allow(downloadable).to receive(:fetched_size).and_return(nil)
// 166:     allow(retryable_download).to receive(:fetch).and_return(cached_download)
// 167:
// 168:     # Build the queue while stdout is a TTY so it captures the TTY render path,
// 169:     # before the output matcher swaps $stdout to capture the redraw frames.
// 170:     download_queue.enqueue(downloadable)
// 171:
// 172:     expect { download_queue.fetch }.to output(
// 173:       include("\e[?2026h").and(
// 174:         satisfy("closes every synchronized update it opens") do |out|
// 175:           last_open = out.rindex("\e[?2026h")
// 176:           last_close = out.rindex("\e[?2026l")
// 177:           out.scan("\e[?2026h").length <= out.scan("\e[?2026l").length &&
// 178:             !last_open.nil? && !last_close.nil? && last_close > last_open
// 179:         end,
// 180:       ),
// 181:     ).to_stdout
// 182:   end
// 183:
// 184:   it "leaves the final terminal column empty when rendering progress" do
// 185:     allow($stdout).to receive(:tty?).and_return(true)
// 186:     ENV["TERM"] = "xterm-256color"
// 187:     allow(Tty).to receive(:width).and_return(80)
// 188:     allow(downloadable).to receive_messages(fetched_size: 559_300_000, total_size: 559_300_000, phase: :downloading)
// 189:     allow(retryable_download).to receive(:fetch).and_return(cached_download)
// 190:
// 191:     download_queue.enqueue(downloadable)
// 192:
// 193:     rendered_lines = []
// 194:     allow(download_queue).to receive(:stdout_print_and_flush) do |message|
// 195:       rendered_lines << message if message.include?("559.3MB")
// 196:     end
// 197:     download_queue.fetch
// 198:
// 199:     expect(Tty.strip_ansi(rendered_lines.fetch(0)).chomp.each_grapheme_cluster.count).to eq(Tty.width - 1)
// 200:   end
// 201:
// 202:   it "emits no synchronized update sequences when stdout is not a TTY" do
// 203:     allow($stdout).to receive(:tty?).and_return(false)
// 204:     allow(retryable_download).to receive(:fetch).and_return(cached_download)
// 205:
// 206:     download_queue.enqueue(downloadable)
// 207:
// 208:     expect { download_queue.fetch }.not_to output(/\e\[\?2026/).to_stdout
// 209:   end
// 210:
// 211:   it "prints the heading to stderr when stdout is not a TTY" do
// 212:     allow($stdout).to receive(:tty?).and_return(false)
// 213:     allow(retryable_download).to receive(:fetch).and_return(cached_download)
// 214:     download_queue.enqueue(downloadable)
// 215:
// 216:     expect { download_queue.fetch(heading: "Downloading Homebrew API data") }
// 217:       .to output(/^==> Downloading Homebrew API data$/).to_stderr
// 218:   end
// 219:
// 220:   it "keeps the heading off stdout when stdout is not a TTY" do
// 221:     allow($stdout).to receive(:tty?).and_return(false)
// 222:     allow(retryable_download).to receive(:fetch).and_return(cached_download)
// 223:     download_queue.enqueue(downloadable)
// 224:
// 225:     expect { download_queue.fetch(heading: "Downloading Homebrew API data") }
// 226:       .not_to output(/Downloading Homebrew API data/).to_stdout
// 227:   end
// 228:
// 229:   it "prints the heading to stdout on a TTY" do
// 230:     allow($stdout).to receive(:tty?).and_return(true)
// 231:     ENV["TERM"] = "xterm-256color"
// 232:     allow(downloadable).to receive(:fetched_size).and_return(nil)
// 233:     allow(retryable_download).to receive(:fetch).and_return(cached_download)
// 234:
// 235:     # Build the queue while stdout is a TTY so it captures the TTY render path,
// 236:     # before the output matcher swaps $stdout to capture the heading.
// 237:     download_queue.enqueue(downloadable)
// 238:
// 239:     expect { download_queue.fetch(heading: "Downloading Homebrew API data") }
// 240:       .to output(/==>.*Downloading Homebrew API data/).to_stdout
// 241:   end
// 242:
// 243:   it "wakes when downloads complete instead of polling with sleep" do
// 244:     allow($stdout).to receive(:tty?).and_return(false)
// 245:     allow(retryable_download).to receive(:fetch) do
// 246:       sleep 0.1
// 247:       cached_download
// 248:     end
// 249:
// 250:     expect(download_queue).not_to receive(:sleep)
// 251:
// 252:     expect do
// 253:       download_queue.enqueue(downloadable)
// 254:       download_queue.fetch
// 255:     end.to output(/✔︎ Bottle testball/).to_stderr
// 256:   end
// 257:
// 258:   it "skips fetching already downloaded files with a valid checksum" do
// 259:     cached_download.dirname.mkpath
// 260:     cached_download.write("already downloaded")
// 261:
// 262:     allow(downloadable).to receive(:downloaded_and_valid?).and_return(true)
// 263:
// 264:     expect(retryable_download).not_to receive(:fetch)
// 265:     expect(downloadable).to receive(:downloader).and_return(nil)
// 266:
// 267:     download_queue.enqueue(downloadable)
// 268:     download_queue.fetch
// 269:   end
// 270:
// 271:   it "runs queued staging before completing the fetch" do
// 272:     allow(retryable_download).to receive(:fetch).and_return(cached_download)
// 273:
// 274:     expect(downloadable).to receive(:stage_from_download_queue?).with(cached_download, pour: false).and_return(true)
// 275:     expect(downloadable).to receive(:extracting!).ordered
// 276:     expect(downloadable).to receive(:stage_from_download_queue).with(cached_download, pour: false).ordered
// 277:     expect(downloadable).to receive(:downloaded!).ordered
// 278:
// 279:     download_queue.enqueue(downloadable, stage: true)
// 280:     download_queue.fetch
// 281:   end
// 282:
// 283:   it "uses the fetched path for queued staging when it changes during fetch" do
// 284:     fetched_download = HOMEBREW_CACHE/"downloads/fetched-testball--0.1.tar.gz"
// 285:     allow(retryable_download).to receive(:fetch).and_return(fetched_download)
// 286:
// 287:     expect(downloadable).to receive(:stage_from_download_queue?).with(fetched_download, pour: false).and_return(true)
// 288:     expect(downloadable).to receive(:extracting!).ordered
// 289:     expect(downloadable).to receive(:stage_from_download_queue).with(fetched_download, pour: false).ordered
// 290:     expect(downloadable).to receive(:downloaded!).ordered
// 291:
// 292:     download_queue.enqueue(downloadable, stage: true)
// 293:     download_queue.fetch
// 294:   end
// 295:
// 296:   it "interrupts queued staging when the fetch is interrupted", timeout: 5 do
// 297:     allow(retryable_download).to receive(:fetch).and_return(cached_download)
// 298:     allow(downloadable).to receive(:stage_from_download_queue?).and_return(true)
// 299:     allow(downloadable).to receive_messages(extracting!: nil, downloaded!: nil)
// 300:     fetch_started = Queue.new
// 301:     staging_started = Queue.new
// 302:     staging_interrupted = Queue.new
// 303:     release_fetch = Queue.new
// 304:     release_staging = Queue.new
// 305:     allow(downloadable).to receive(:download_queue_message) do
// 306:       fetch_started << true
// 307:       release_fetch.pop
// 308:       "Bottle testball"
// 309:     end
// 310:     allow(downloadable).to receive(:stage_from_download_queue) do
// 311:       staging_started << true
// 312:       release_staging.pop
// 313:     rescue Interrupt
// 314:       staging_interrupted << true
// 315:       raise
// 316:     end
// 317:
// 318:     download_queue.enqueue(downloadable, stage: true)
// 319:     fetch_thread = Thread.current
// 320:     interrupter = Thread.new do
// 321:       next unless staging_started.pop(timeout: 1)
// 322:       next unless fetch_started.pop(timeout: 1)
// 323:
// 324:       fetch_thread.raise(Interrupt)
// 325:     end
// 326:
// 327:     expect { download_queue.fetch }.to raise_error(Interrupt)
// 328:     expect(staging_interrupted.pop(timeout: 1)).to be(true)
// 329:   ensure
// 330:     release_fetch&.push(true)
// 331:     release_staging&.push(true)
// 332:     interrupter.kill if interrupter && !interrupter.join(1)
// 333:   end
// 334:
// 335:   it "promotes an in-flight download to queued staging" do
// 336:     expect(retryable_download).to receive(:fetch).once.and_return(cached_download)
// 337:     expect(downloadable).to receive(:stage_from_download_queue?).with(cached_download, pour: false).and_return(true)
// 338:     expect(downloadable).to receive(:extracting!).ordered
// 339:     expect(downloadable).to receive(:stage_from_download_queue).with(cached_download, pour: false).ordered
// 340:     expect(downloadable).to receive(:downloaded!).ordered
// 341:
// 342:     download_queue.enqueue(downloadable)
// 343:     download_queue.enqueue(downloadable, stage: true)
// 344:     download_queue.fetch
// 345:   end
// 346:
// 347:   it "checks attestations for valid cached bottles" do
// 348:     bottle = Bottle.allocate
// 349:     allow(bottle).to receive_messages(
// 350:       cached_download:,
// 351:       checksum:               nil,
// 352:       downloaded_and_valid?:  true,
// 353:       downloader:             nil,
// 354:       download_queue_message: "Bottle testball",
// 355:       download_queue_name:    "testball",
// 356:       download_queue_type:    "Bottle",
// 357:     )
// 358:
// 359:     expect(Utils::Attestation).to receive(:check_attestation).with(bottle, quiet: true)
// 360:
// 361:     download_queue.enqueue(bottle, check_attestation: true)
// 362:     download_queue.fetch
// 363:   end
// 364:
// 365:   describe "Homebrew.default_download_queue", order: :defined do
// 366:     it "memoizes the queue created on first use" do
// 367:       queue = instance_double(described_class, shutdown: nil)
// 368:       allow(described_class).to receive(:new).and_return(queue)
// 369:
// 370:       expect(Homebrew.default_download_queue).to be(queue)
// 371:     end
// 372:
// 373:     it "does not leak a queue stubbed by an earlier example" do
// 374:       expect(Homebrew.default_download_queue).to be_an_instance_of(described_class)
// 375:     end
// 376:
// 377:     it "shuts down a memoized real queue when reset" do
// 378:       queue = Homebrew.default_download_queue
// 379:       expect(queue).to receive(:shutdown)
// 380:
// 381:       Homebrew.reset_default_download_queue
// 382:     end
// 383:   end
// 384: end
