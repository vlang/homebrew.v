module utils

// Translated from Homebrew/brew `extend/os/mac/utils/bottles.rb`.
pub struct MacBottlesMatchContext {
pub:
	version_prerelease    bool
	developer             bool
	skip_or_later_bottles bool
}

const mac_bottles_versions = {
	'golden_gate': '27'
	'tahoe':       '26'
	'sequoia':     '15'
	'sonoma':      '14'
	'ventura':     '13'
	'monterey':    '12'
	'big_sur':     '11'
	'catalina':    '10.15'
}
