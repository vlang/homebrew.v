module test

import homebrew
import homebrew.extend as pathname_ext
import math

pub struct VersionSpecBoundary {
pub:
	line   int
	passed bool
}

struct VersionDetectionExpectation {
	expected string
	url      string
	tag      string
}

fn version_spec_boundary(line int, passed bool) VersionSpecBoundary {
	return VersionSpecBoundary{
		line: line
		passed: passed
	}
}

fn version_spec_new(value string) ?homebrew.Version {
	return homebrew.new_version(value) or { return none }
}

fn version_spec_equal(left string, right string) bool {
	left_version := version_spec_new(left) or { return false }
	right_version := version_spec_new(right) or { return false }
	return left_version.equals(right_version)
}

fn version_spec_relation(left string, relation string, right string) bool {
	left_version := version_spec_new(left) or { return false }
	right_version := version_spec_new(right) or { return false }
	comparison := left_version.compare_to(right_version)
	return match relation {
		'<' { comparison < 0 }
		'>' { comparison > 0 }
		'==' { left_version.equals(right_version) }
		'!=' { !left_version.equals(right_version) }
		'<=' { comparison <= 0 }
		'>=' { comparison >= 0 }
		else { false }
	}
}

fn version_spec_relations(expectations [][]string) bool {
	for expectation in expectations {
		if expectation.len != 3 || !version_spec_relation(expectation[0], expectation[1], expectation[2]) {
			return false
		}
	}
	return expectations.len > 0
}

fn version_spec_token(value string) ?homebrew.VersionToken {
	return homebrew.token_create(value) or { return none }
}

fn version_spec_numeric_component(value string, component string, expected ?string) bool {
	version := version_spec_new(value) or { return false }
	token := match component {
		'major' { version.major() }
		'minor' { version.minor() }
		'patch' { version.patch() }
		else {
			return false
		}
	}
	if expected_value := expected {
		actual := token or { return false }
		return actual.to_s() == expected_value
	}
	return token == none
}

fn version_spec_detect(expectations []VersionDetectionExpectation) bool {
	if expectations.len == 0 {
		return false
	}
	for expectation in expectations {
		detected := homebrew.detect_version(expectation.url, expectation.tag)
		if detected.to_s() != expectation.expected {
			return false
		}
	}
	return true
}

fn version_spec_compare_case(left string, comparator string, right string, expected bool) bool {
	left_version := version_spec_new(left) or { return false }
	right_version := version_spec_new(right) or { return false }
	actual := left_version.compare(comparator, right_version) or { return false }
	return actual == expected
}

fn version_spec_compare_examples() bool {
	expectations := [
		['0.1', '==', '0.1.0', 'true'],
		['0.1', '<', '0.2', 'true'],
		['1.2.3', '>', '1.2.2', 'true'],
		['1.2.4', '<', '1.2.4.1', 'true'],
		['0.1', '!=', '0.1.0', 'false'],
		['0.1', '>=', '0.2', 'false'],
		['1.2.3', '<=', '1.2.2', 'false'],
		['1.2.4', '>=', '1.2.4.1', 'false'],
		['1.2.3', '>', '1.2.3alpha4', 'true'],
		['1.2.3', '>', '1.2.3beta2', 'true'],
		['1.2.3', '>', '1.2.3rc3', 'true'],
		['1.2.3', '<', '1.2.3-p34', 'true'],
		['1.2.3', '<=', '1.2.3alpha4', 'false'],
		['1.2.3', '<=', '1.2.3beta2', 'false'],
		['1.2.3', '<=', '1.2.3rc3', 'false'],
		['1.2.3', '>=', '1.2.3-p34', 'false'],
	]
	for expectation in expectations {
		if !version_spec_compare_case(expectation[0], expectation[1], expectation[2], expectation[3] == 'true') {
			return false
		}
	}
	return true
}

fn version_spec_alpha_relations() bool {
	return version_spec_relations([
		['1.2.3alpha', '<', '1.2.3'],
		['1.2.3', '<', '1.2.3a'],
		['1.2.3alpha4', '==', '1.2.3a4'],
		['1.2.3alpha4', '==', '1.2.3A4'],
		['1.2.3alpha4', '>', '1.2.3alpha3'],
		['1.2.3alpha4', '<', '1.2.3alpha5'],
		['1.2.3alpha4', '<', '1.2.3alpha10'],
		['1.2.3alpha4', '<', '1.2.3beta2'],
		['1.2.3alpha4', '<', '1.2.3rc3'],
		['1.2.3alpha4', '<', '1.2.3'],
		['1.2.3alpha4', '<', '1.2.3-p34'],
	])
}

fn version_spec_beta_relations() bool {
	return version_spec_relations([
		['1.2.3beta2', '==', '1.2.3b2'],
		['1.2.3beta2', '==', '1.2.3B2'],
		['1.2.3beta2', '>', '1.2.3beta1'],
		['1.2.3beta2', '<', '1.2.3beta3'],
		['1.2.3beta2', '<', '1.2.3beta10'],
		['1.2.3beta2', '>', '1.2.3alpha4'],
		['1.2.3beta2', '<', '1.2.3rc3'],
		['1.2.3beta2', '<', '1.2.3'],
		['1.2.3beta2', '<', '1.2.3-p34'],
	])
}

fn version_spec_pre_relations() bool {
	return version_spec_relations([
		['1.2.3pre9', '==', '1.2.3PRE9'],
		['1.2.3pre9', '>', '1.2.3pre8'],
		['1.2.3pre8', '<', '1.2.3pre9'],
		['1.2.3pre9', '<', '1.2.3pre10'],
		['1.2.3pre3', '>', '1.2.3alpha2'],
		['1.2.3pre3', '>', '1.2.3alpha4'],
		['1.2.3pre3', '>', '1.2.3beta3'],
		['1.2.3pre3', '>', '1.2.3beta5'],
		['1.2.3pre3', '<', '1.2.3rc2'],
		['1.2.3pre3', '<', '1.2.3'],
		['1.2.3pre3', '<', '1.2.3-p2'],
	])
}

fn version_spec_rc_relations() bool {
	return version_spec_relations([
		['1.2.3rc3', '==', '1.2.3RC3'],
		['1.2.3rc3', '>', '1.2.3rc2'],
		['1.2.3rc3', '<', '1.2.3rc4'],
		['1.2.3rc3', '<', '1.2.3rc10'],
		['1.2.3rc3', '>', '1.2.3alpha4'],
		['1.2.3rc3', '>', '1.2.3beta2'],
		['1.2.3rc3', '<', '1.2.3'],
		['1.2.3rc3', '<', '1.2.3-p34'],
	])
}

fn version_spec_patch_relations() bool {
	return version_spec_relations([
		['1.2.3-p34', '==', '1.2.3-P34'],
		['1.2.3-p34', '>', '1.2.3-p33'],
		['1.2.3-p34', '<', '1.2.3-p35'],
		['1.2.3-p34', '>', '1.2.3-p9'],
		['1.2.3-p34', '>', '1.2.3alpha4'],
		['1.2.3-p34', '>', '1.2.3beta2'],
		['1.2.3-p34', '>', '1.2.3rc3'],
		['1.2.3-p34', '>', '1.2.3'],
	])
}

fn version_spec_post_relations() bool {
	return version_spec_relations([
		['1.2.3.post34', '>', '1.2.3.post33'],
		['1.2.3.post34', '<', '1.2.3.post35'],
		['1.2.3.post34', '>', '1.2.3rc35'],
		['1.2.3.post34', '>', '1.2.3alpha35'],
		['1.2.3.post34', '>', '1.2.3beta35'],
		['1.2.3.post34', '>', '1.2.3'],
	])
}

fn version_spec_erlang_order() bool {
	versions := ['R13B02-1', 'R13B03', 'R13B04', 'R14B', 'R14B01', 'R14B02', 'R14B03', 'R14B04',
		'R15B01', 'R15B02', 'R15B03', 'R15B03-1', 'R16B']
	for index in 0 .. versions.len - 1 {
		if !version_spec_relation(versions[index], '<', versions[index + 1]) {
			return false
		}
	}
	return true
}

fn version_spec_update_commit() bool {
	mut with_commit := version_spec_new('HEAD-abcdef') or { return false }
	mut without_commit := version_spec_new('HEAD') or { return false }
	with_commit.update_commit('ffffff') or { return false }
	without_commit.update_commit('ffffff') or { return false }
	with_commit_text := with_commit.to_str() or { return false }
	without_commit_text := without_commit.to_str() or { return false }
	with_commit_value := with_commit.commit() or { return false }
	without_commit_value := without_commit.commit() or { return false }
	return with_commit_value == 'ffffff' && with_commit_text == 'HEAD-ffffff' && without_commit_value == 'ffffff' && without_commit_text == 'HEAD-ffffff'
}

fn version_spec_components(component string) bool {
	values := ['1', '1.2', '1.2.3', '1.2.3alpha', '1.2.3alpha4', '1.2.3beta4', '1.2.3pre4', '1.2.3rc4',
		'1.2.3-p4']
	for value in values {
		expected := match component {
			'major' { ?string('1') }
			'minor' {
				if value == '1' { none } else { ?string('2') }
			}
			'patch' {
				if value in ['1', '1.2'] { none } else { ?string('3') }
			}
			else {
				return false
			}
		}
		if !version_spec_numeric_component(value, component, expected) {
			return false
		}
	}
	return true
}

fn version_spec_leading_components(count int) bool {
	values := ['1', '1.2', '1.2.3', '1.2.3alpha', '1.2.3alpha4', '1.2.3beta4', '1.2.3pre4', '1.2.3rc4',
		'1.2.3-p4']
	for value in values {
		version := version_spec_new(value) or { return false }
		leading := if count == 2 {
			version.major_minor()
		} else if count == 3 {
			version.major_minor_patch()
		} else {
			return false
		}
		expected := if count == 2 {
			if value == '1' { '1' } else { '1.2' }
		} else if value in ['1', '1.2'] {
			value
		} else {
			'1.2.3'
		}
		if leading.to_s() != expected {
			return false
		}
	}
	return true
}

fn version_spec_detection_expectations_450() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.14', 'https://brew.sh/foo.bar.la.1.14.zip', ''},
	]
}

fn version_spec_detection_expectations_455() []VersionDetectionExpectation {
	return [VersionDetectionExpectation{'1.1', 'https://brew.sh/grc_1.1.tar.gz', ''}]
}

fn version_spec_detection_expectations_460() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.39.0', 'https://brew.sh/boost_1_39_0.tar.bz2', ''},
	]
}

fn version_spec_detection_expectations_465() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'R13B', 'https://erlang.org/download/otp_src_R13B.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_470() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'R15B01', 'https://github.com/erlang/otp/tarball/OTP_R15B01', ''},
	]
}

fn version_spec_detection_expectations_475() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'R15B03-1', 'https://github.com/erlang/otp/tarball/OTP_R15B03-1', ''},
	]
}

fn version_spec_detection_expectations_480() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'9.04', 'https://kent.dl.sourceforge.net/sourceforge/p7zip/p7zip_9.04_src_all.tar.bz2', ''},
	]
}

fn version_spec_detection_expectations_485() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.1.4', 'https://github.com/sam-github/libnet/tarball/libnet-1.1.4', ''},
	]
}

fn version_spec_detection_expectations_490() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'0.7.1', 'https://codeload.github.com/gsamokovarov/jump/tar.gz/v0.7.1', ''},
	]
}

fn version_spec_detection_expectations_495() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.0-beta7', 'https://camaya.net/download/gloox-1.0-beta7.tar.bz2', ''},
	]
}

fn version_spec_detection_expectations_500() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.10-beta', 'http://sphinxsearch.com/downloads/sphinx-1.10-beta.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_505() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.23', 'https://kent.dl.sourceforge.net/sourceforge/astyle/astyle_1.23_macosx.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_510() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'3.1', 'http://www.sfr-fresh.com/linux/misc/dos2unix-3.1.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_515() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.1-2', 'https://brew.sh/foo-arse-1.1-2.tar.gz', ''},
		VersionDetectionExpectation{'3.3.04-1', 'https://brew.sh/3.3.04-1.tar.gz', ''},
		VersionDetectionExpectation{'1.2-20200102', 'https://brew.sh/v1.2-20200102.tar.gz', ''},
		VersionDetectionExpectation{'3.6.6-0.2', 'https://brew.sh/v3.6.6-0.2.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_526() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'45', 'https://brew.sh/foo_bar.45.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_531() []VersionDetectionExpectation {
	return [VersionDetectionExpectation{'45', 'https://brew.sh/foo_bar45.tar.gz', ''}]
}

fn version_spec_detection_expectations_536() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.2.3', 'https://brew.sh/foo-bar-la.1.2.3.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_541() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.21', 'https://brew.sh/foo_bar-1.21.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_546() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.21', 'https://sourceforge.net/foo_bar-1.21.tar.gz/download', ''},
		VersionDetectionExpectation{'1.21', 'https://sf.net/foo_bar-1.21.tar.gz/download', ''},
	]
}

fn version_spec_detection_expectations_553() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.0.5', 'https://github.com/lloyd/yajl/tarball/1.0.5', ''},
	]
}

fn version_spec_detection_expectations_558() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.2.34', 'https://github.com/lloyd/yajl/tarball/v1.2.34', ''},
	]
}

fn version_spec_detection_expectations_563() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'0.15.1b', 'https://brew.sh/mad-0.15.1b.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_568() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'398-2', 'https://kent.dl.sourceforge.net/sourceforge/lame/lame-398-2.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_573() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.9.1-p243', 'ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.1-p243.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_578() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'0.80.2', 'http://www.alcyone.com/binaries/omega/omega-0.80.2-src.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_583() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.2.2rc1', 'https://downloads.xiph.org/releases/vorbis/libvorbis-1.2.2rc1.tar.bz2', ''},
	]
}

fn version_spec_detection_expectations_588() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.8.0-rc1', 'https://ftp.mozilla.org/pub/mozilla.org/js/js-1.8.0-rc1.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_593() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'3.0.9b', 'http://rephial.org/downloads/3.0/angband-3.0.9b-src.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_598() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.4.14b', 'https://www.monkey.org/~provos/libevent-1.4.14b-stable.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_603() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'3.03', 'https://ftp.de.debian.org/debian/pool/main/s/sl/sl_3.03.orig.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_608() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.01b', 'https://ftp.de.debian.org/debian/pool/main/m/mmv/mmv_1.01b.orig.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_613() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1', 'https://deb.debian.org/debian/pool/main/e/example/example_1.orig.tar.gz', ''},
		VersionDetectionExpectation{'20040914', 'https://deb.debian.org/debian/pool/main/e/example/example_20040914.orig.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_620() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'4.8.0', 'https://homebrew.bintray.com/bottles/qt-4.8.0.lion.bottle.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_625() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'4.8.1', 'https://homebrew.bintray.com/bottles/qt-4.8.1.lion.bottle.1.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_630() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'R15B', 'https://homebrew.bintray.com/bottles/erlang-R15B.lion.bottle.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_635() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'R15B01', 'https://homebrew.bintray.com/bottles/erlang-R15B01.mountain_lion.bottle.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_640() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'R15B03-1', 'https://homebrew.bintray.com/bottles/erlang-R15B03-1.mountainlion.bottle.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_645() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'6.7.5-7', 'https://downloads.sf.net/project/machomebrew/mirror/ImageMagick-6.7.5-7.tar.bz2', ''},
	]
}

fn version_spec_detection_expectations_650() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'6.7.5-7', 'https://homebrew.bintray.com/bottles/imagemagick-6.7.5-7.lion.bottle.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_655() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'6.7.5-7', 'https://homebrew.bintray.com/bottles/imagemagick-6.7.5-7.lion.bottle.1.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_660() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'2017-04-17', 'https://brew.sh/dada-v2017-04-17.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_665() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.3.0-beta.1', 'https://registry.npmjs.org/@angular/cli/-/cli-1.3.0-beta.1.tgz', ''},
		VersionDetectionExpectation{'2.074.0-beta1', 'https://github.com/dlang/dmd/archive/v2.074.0-beta1.tar.gz', ''},
		VersionDetectionExpectation{'2.074.0-rc1', 'https://github.com/dlang/dmd/archive/v2.074.0-rc1.tar.gz', ''},
		VersionDetectionExpectation{'5.0.0-alpha10', 'https://github.com/premake/premake-core/releases/download/v5.0.0-alpha10/premake-5.0.0-alpha10-src.zip', ''},
	]
}

fn version_spec_detection_expectations_678() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.486', 'https://mirrors.jenkins-ci.org/war/1.486/jenkins.war', ''},
		VersionDetectionExpectation{'0.10.11', 'https://github.com/hechoendrupal/DrupalConsole/releases/download/0.10.11/drupal.phar', ''},
	]
}

fn version_spec_detection_expectations_685() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.9.293', 'https://github.com/clojure/clojurescript/releases/download/r1.9.293/cljs.jar', ''},
		VersionDetectionExpectation{'0.6.1', 'https://github.com/fibjs/fibjs/releases/download/v0.6.1/fullsrc.zip', ''},
		VersionDetectionExpectation{'1.9', 'https://wwwlehre.dhbw-stuttgart.de/~sschulz/WORK/E_DOWNLOAD/V_1.9/E.tgz', ''},
	]
}

fn version_spec_detection_expectations_694() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'3.2', 'https://github.com/dvorka-oss/hstr/releases/download/v3.2/hstr-3.2.0-tarball.tgz', ''},
	]
}

fn version_spec_detection_expectations_700() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'2.3.2.0', 'https://github.com/JustArchi/ArchiSteamFarm/releases/download/2.3.2.0/ASF.zip', ''},
		VersionDetectionExpectation{'1.7.5.2', 'https://people.gnome.org/~newren/eg/download/1.7.5.2/eg', ''},
	]
}

fn version_spec_detection_expectations_707() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'3.4', 'https://www.antlr.org/download/antlr-3.4-complete.jar', ''},
		VersionDetectionExpectation{'9.2', 'https://cdn.nuxeo.com/nuxeo-9.2/nuxeo-server-9.2-tomcat.zip', ''},
		VersionDetectionExpectation{'0.181', 'https://search.maven.org/remotecontent?filepath=com/facebook/presto/presto-cli/0.181/presto-cli-0.181-executable.jar', ''},
		VersionDetectionExpectation{'1.2.3', 'https://search.maven.org/remotecontent?filepath=org/apache/orc/orc-tools/1.2.3/orc-tools-1.2.3-uber.jar', ''},
	]
}

fn version_spec_detection_expectations_723() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.2.0-rc2', 'https://www.apache.org/dyn/closer.cgi?path=/cassandra/1.2.0/apache-cassandra-1.2.0-rc2-bin.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_730() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'8d', 'https://www.ijg.org/files/jpegsrc.v8d.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_735() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'7.0.4', 'https://www.haskell.org/ghc/dist/7.0.4/ghc-7.0.4-x86_64-apple-darwin.tar.bz2', ''},
		VersionDetectionExpectation{'7.0.4', 'https://www.haskell.org/ghc/dist/7.0.4/ghc-7.0.4-i386-apple-darwin.tar.bz2', ''},
	]
}

fn version_spec_detection_expectations_742() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.4.1', 'https://pypy.org/download/pypy-1.4.1-osx.tar.bz2', ''},
	]
}

fn version_spec_detection_expectations_747() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'0.9.8s', 'https://www.openssl.org/source/openssl-0.9.8s.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_752() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.5E', 'ftp://ftp.visi.com/users/hawkeyd/X/Xaw3d-1.5E.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_757() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'2.0.863', 'https://downloads.sourceforge.net/project/assimp/assimp-2.0/assimp--2.0.863-sdk.zip', ''},
	]
}

fn version_spec_detection_expectations_762() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'20c', 'https://common-lisp.net/project/cmucl/downloads/release/20c/cmucl-20c-x86-darwin.tar.bz2', ''},
	]
}

fn version_spec_detection_expectations_769() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'2.1.0beta', 'https://downloads.sourceforge.net/project/fann/fann/2.1.0beta/fann-2.1.0beta.zip', ''},
	]
}

fn version_spec_detection_expectations_774() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'2.0.1', 'ftp://iges.org/grads/2.0/grads-2.0.1-bin-darwin9.8-intel.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_779() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'2.08', 'https://haxe.org/file/haxe-2.08-osx.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_784() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'2007f', 'ftp://ftp.cac.washington.edu/imap/imap-2007f.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_789() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'3.3.12ga7', 'https://downloads.sourceforge.net/project/x3270/x3270/3.3.12ga7/suite3270-3.3.12ga7-src.tgz', ''},
	]
}

fn version_spec_detection_expectations_796() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'2.9h', 'http://www.gedanken.demon.co.uk/download-wwwoffle/wwwoffle-2.9h.tgz', ''},
	]
}

fn version_spec_detection_expectations_801() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.3.6p2', 'http://synergy.googlecode.com/files/synergy-1.3.6p2-MacOSX-Universal.zip', ''},
	]
}

fn version_spec_detection_expectations_806() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'20120731', 'https://downloads.sourceforge.net/project/fontforge/fontforge-source/fontforge_full-20120731-b.tar.bz2', ''},
	]
}

fn version_spec_detection_expectations_813() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'2011.10', 'https://github.com/downloads/ezsystems/ezpublish-legacy/ezpublish_community_project-2011.10-with_ezc.tar.bz2', ''},
	]
}

fn version_spec_detection_expectations_821() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'2.4c', 'http://loop-aes.sourceforge.net/aespipe/aespipe-v2.4c.tar.bz2', ''},
	]
}

fn version_spec_detection_expectations_826() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'0.9.17', 'https://ftpmirror.gnu.org/libmicrohttpd/libmicrohttpd-0.9.17-w32.zip', ''},
		VersionDetectionExpectation{'1.29', 'https://ftpmirror.gnu.org/libidn/libidn-1.29-win64.zip', ''},
	]
}

fn version_spec_detection_expectations_833() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'0.35.1', 'https://github.com/barricklab/breseq/releases/download/v0.35.1/breseq-0.35.1.Source.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_841() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'20.0.1', 'https://download.jboss.org/wildfly/20.0.1.Final/wildfly-20.0.1.Final.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_846() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'2.10.0', 'https://github.com/trinityrnaseq/trinityrnaseq/releases/download/v2.10.0/trinityrnaseq-v2.10.0.FULL.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_854() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'4.0.18-1', 'https://ftpmirror.gnu.org/mtools/mtools-4.0.18-1.i686.rpm', ''},
		VersionDetectionExpectation{'5.5.7-5', 'https://ftpmirror.gnu.org/autogen/autogen-5.5.7-5.i386.rpm', ''},
		VersionDetectionExpectation{'2.8', 'https://ftpmirror.gnu.org/libtasn1/libtasn1-2.8-x86.zip', ''},
		VersionDetectionExpectation{'2.8', 'https://ftpmirror.gnu.org/libtasn1/libtasn1-2.8-x64.zip', ''},
		VersionDetectionExpectation{'4.0.18', 'https://ftpmirror.gnu.org/mtools/mtools_4.0.18_i386.deb', ''},
	]
}

fn version_spec_detection_expectations_867() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'2.18.3', 'https://opam.ocaml.org/archives/lablgtk.2.18.3+opam.tar.gz', ''},
		VersionDetectionExpectation{'1.9', 'https://opam.ocaml.org/archives/sha.1.9+opam.tar.gz', ''},
		VersionDetectionExpectation{'0.99.2', 'https://opam.ocaml.org/archives/ppx_tools.0.99.2+opam.tar.gz', ''},
		VersionDetectionExpectation{'1.0.2', 'https://opam.ocaml.org/archives/easy-format.1.0.2+opam.tar.gz', ''},
	]
}

fn version_spec_detection_expectations_878() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.8.12', 'https://waf.io/waf-1.8.12', ''},
		VersionDetectionExpectation{'0.7.1', 'https://codeload.github.com/gsamokovarov/jump/tar.gz/v0.7.1', ''},
		VersionDetectionExpectation{'0.9.1234', 'https://my.datomic.com/downloads/free/0.9.1234', ''},
		VersionDetectionExpectation{'1.2.3', 'https://my.datomic.com/downloads/free/1.2.3', ''},
	]
}

fn version_spec_detection_expectations_889() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'6-20151227', 'ftp://gcc.gnu.org/pub/gcc/snapshots/6-20151227/gcc-6-20151227.tar.bz2', ''},
	]
}

fn version_spec_detection_expectations_894() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'7.1.10', 'https://php.net/get/php-7.1.10.tar.gz/from/this/mirror', ''},
	]
}

fn version_spec_detection_expectations_899() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.2.3', 'https://github.com/foo/bar.git', 'v1.2.3-stable'},
	]
}

fn version_spec_detection_expectations_904() []VersionDetectionExpectation {
	return [
		VersionDetectionExpectation{'1.2.3-beta1', 'https://github.com/foo/bar.git', 'v1.2.3-beta1'},
	]
}

fn version_spec_example_7() bool {
	version := version_spec_new('1.2.3') or { return false }
	return version.to_s() == '1.2.3'
}

fn version_spec_example_9() bool {
	return homebrew.formula_optionally_versioned_pattern('foo', true) == '^foo(@\\d[\\d.]*)?\$'
}

fn version_spec_example_14() bool {
	token := version_spec_token('foo') or { return false }
	return token.inspect() == '#<Version::StringToken "foo">' && token.to_s() == 'foo'
}

fn version_spec_example_19() bool {
	nil_operand := homebrew.VersionNilComparisonOperand{}
	return (homebrew.compare_token_operand(version_spec_token('2') or { return false }, nil_operand) or { return false }) > 0 && (homebrew.compare_token_operand(version_spec_token('p194') or { return false }, nil_operand) or { return false }) > 0
}

fn version_spec_example_24() bool {
	return (homebrew.compare_token_operand(version_spec_token('2') or { return false }, homebrew.null_version_token()) or { return false }) > 0 && (homebrew.compare_token_operand(version_spec_token('p194') or { return false }, homebrew.null_version_token()) or { return false }) > 0
}

fn version_spec_example_29() bool {
	return (homebrew.compare_token_operand(version_spec_token('2') or { return false }, '2') or {
		return false
	}) == 0 && (homebrew.compare_token_operand(version_spec_token('p194') or { return false }, 'p194') or {
		return false
	}) == 0 && (homebrew.compare_token_operand(version_spec_token('1') or { return false }, 1) or {
		return false
	}) == 0
}

fn version_spec_example_35() bool {
	token := version_spec_token('1') or { return false }
	foreign := homebrew.VersionForeignComparisonOperand{}
	if homebrew.compare_token_operand(token, foreign) != none {
		return false
	}
	if _ := homebrew.token_operand_relation(token, '>', foreign) {
		return false
	}
	return true
}

fn version_spec_example_42() bool {
	return (version_spec_token('foo') or { return false }).to_s() == 'foo'
}

fn version_spec_example_49() bool {
	version := version_spec_new('1.2.3') or { return false }
	return version.to_s() == '1.2.3'
}

fn version_spec_example_55() bool {
	version := version_spec_new('1.2.3') or { return false }
	text := version.to_str() or { return false }
	return text == '1.2.3'
}

fn version_spec_example_60() bool {
	version := version_spec_new('1.2.3') or { return false }
	if !version.responds_to_to_str() {
		return false
	}
	text := version.to_str() or { return false }
	return text == '1.2.3'
}

fn version_spec_example_65() bool {
	return (version_spec_new('1.2.3') or { return false }).to_f() == 1.2
}

fn version_spec_example_71() bool {
	return (version_spec_new('1.2.3') or { return false }).to_json() == '"1.2.3"'
}

fn version_spec_example_79() bool {
	null := homebrew.null_version()
	return null.compare_to(version_spec_new('1') or { return false }) < 0 && null.compare_to(version_spec_new('0') or { return false }) <= 0 && !null.equals(null)
}

fn version_spec_example_96() bool {
	if _ := homebrew.null_version().to_str() {
		return false
	} else {
		return err.msg() == 'undefined method `to_str` for Version:NULL'
	}
}

fn version_spec_example_123() bool {
	null := homebrew.null_version_token()
	return null.inspect() == '#<Version::NullToken>' && null.equals(homebrew.null_version_token())
}

fn version_spec_example_129() bool {
	return version_spec_relations([
		['0.1', '==', '0.1.0'],
		['0.1', '<', '0.2'],
		['1.2.3', '>', '1.2.2'],
		['1.2.4', '<', '1.2.4.1'],
		['1.2.3', '>', '1.2.3alpha4'],
		['1.2.3', '>', '1.2.3beta2'],
		['1.2.3', '>', '1.2.3rc3'],
		['1.2.3', '<', '1.2.3-p34'],
	])
}

fn version_spec_example_161() bool {
	return version_spec_relations([
		['HEAD', '>', '1.2.3'],
		['HEAD-abcdef', '>', '1.2.3'],
		['1.2.3', '<', 'HEAD'],
		['1.2.3', '<', 'HEAD-fedcba'],
		['HEAD-abcdef', '==', 'HEAD-fedcba'],
		['HEAD', '==', 'HEAD-fedcba'],
	])
}

fn version_spec_example_247() bool {
	return version_spec_relations([
		['2.1.0-p194', '<', '2.1-p195'],
		['2.1-p195', '>', '2.1.0-p194'],
		['2.1-p194', '<', '2.1.0-p195'],
		['2.1.0-p195', '>', '2.1-p194'],
		['2-p194', '<', '2.1-p195'],
	])
}

fn version_spec_example_255() bool {
	version := version_spec_new('2.1.0-p194') or { return false }
	return (homebrew.compare_version_operand(version, homebrew.VersionNilComparisonOperand{}) or {
		return false
	}) > 0
}

fn version_spec_example_259() bool {
	version := version_spec_new('2.1.0-p194') or { return false }
	return (homebrew.compare_version_operand(version, homebrew.null_version()) or {
		return false
	}) > 0
}

fn version_spec_example_263() bool {
	version := version_spec_new('2.1.0-p194') or { return false }
	one := version_spec_new('1') or { return false }
	return (homebrew.compare_version_operand(version, '2.1.0-p194') or { return false }) == 0 && (homebrew.compare_version_operand(one, 1) or { return false }) == 0
}

fn version_spec_example_268() bool {
	version := version_spec_new('2.1.0-p194') or { return false }
	one := version_spec_new('1') or { return false }
	return (homebrew.compare_version_operand(version, version_spec_token('2') or { return false }) or {
		return false
	}) > 0 && (homebrew.compare_version_operand(one, version_spec_token('1') or { return false }) or {
		return false
	}) == 0
}

fn version_spec_example_273() bool {
	version := version_spec_new('2.1.0-p194') or { return false }
	return (homebrew.compare_version_operand(version, homebrew.null_version_token()) or {
		return false
	}) > 0
}

fn version_spec_example_277() bool {
	version := version_spec_new('1.0') or { return false }
	foreign := homebrew.VersionForeignComparisonOperand{}
	if homebrew.compare_version_operand(version, foreign) != none {
		return false
	}
	if _ := homebrew.version_operand_relation(version, '>', foreign) {
		return false
	}
	return true
}

fn version_spec_example_289() bool {
	v1 := version_spec_new('0.1.0') or { return false }
	v2 := version_spec_new('0.1.0') or { return false }
	v3 := version_spec_new('0.1.1') or { return false }
	values := {
		v1.hash(): 'foo'
	}
	return v1.equals(v2) && !v1.equals(v3) && v1.hash() == v2.hash() && v1.hash() != v3.hash() && values[v2.hash()] == 'foo'
}

fn version_spec_example_304() bool {
	version := version_spec_new('1.20') or { return false }
	text := version.to_str() or { return false }
	return !version.head() && text == '1.20'
}

fn version_spec_example_310() bool {
	version := version_spec_new('HEAD-abcdef') or { return false }
	text := version.to_str() or { return false }
	return (version.commit() or { return false }) == 'abcdef' && text == 'HEAD-abcdef'
}

fn version_spec_example_316() bool {
	version := version_spec_new('HEAD') or { return false }
	text := version.to_str() or { return false }
	return version.commit() == none && text == 'HEAD'
}

fn version_spec_example_328() bool {
	version := homebrew.detect_version('https://example.org/archive-1.0.0.tar.gz', '')
	return version.to_s() == '1.0.0' && version.detected_from_url()
}

fn version_spec_example_324() bool {
	version := version_spec_new('1.0.0') or { return false }
	return !version.detected_from_url()
}

fn version_spec_example_336() bool {
	return (version_spec_new('HEAD-abcdef') or { return false }).head() && (version_spec_new('HEAD') or { return false }).head()
}

fn version_spec_example_428() bool {
	return homebrew.parse_version('https://brew.sh/blah.tar', false).is_null() && homebrew.parse_version('foo', false).is_null()
}

fn version_spec_example_435() bool {
	return version_spec_detect(version_spec_detection_expectations_450())
}

fn version_spec_example_911() bool {
	parsed := pathname_ext.pathname_version('/opt/homebrew/Cellar/foo-0.1.9', fn (basename string) !string {
		return homebrew.parse_version(basename, false).to_s()
	}) or { return false }
	return parsed == '0.1.9'
}

pub fn version_spec_all_boundaries() []VersionSpecBoundary {
	return [
		ruby_version_spec_l7_d1_version(),
		ruby_version_spec_l9_d2_formula_optionally_versioned_regex(),
		ruby_version_spec_l14_d3_do(),
		ruby_version_spec_l19_d4_can(),
		ruby_version_spec_l24_d5_can(),
		ruby_version_spec_l29_d6_can(),
		ruby_version_spec_l35_d7_comparison(),
		ruby_version_spec_l42_d8_implicitly(),
		ruby_version_spec_l49_d9_returns(),
		ruby_version_spec_l55_d10_returns(),
		ruby_version_spec_l60_d11_implicitlys(),
		ruby_version_spec_l65_d12_returns(),
		ruby_version_spec_l71_d13_returns(),
		ruby_version_spec_l77_d14_null_version(),
		ruby_version_spec_l79_d15_do(),
		ruby_version_spec_l86_d16_returns(),
		ruby_version_spec_l92_d17_does(),
		ruby_version_spec_l96_d18_raises(),
		ruby_version_spec_l103_d19_does(),
		ruby_version_spec_l108_d20_returns(),
		ruby_version_spec_l114_d21_outputs(),
		ruby_version_spec_l121_d22_null_version(),
		ruby_version_spec_l123_d23_do(),
		ruby_version_spec_l129_d24_comparison(),
		ruby_version_spec_l141_d25_compare(),
		ruby_version_spec_l161_d26_head(),
		ruby_version_spec_l170_d27_comparing(),
		ruby_version_spec_l185_d28_comparing(),
		ruby_version_spec_l198_d29_comparing(),
		ruby_version_spec_l213_d30_comparing(),
		ruby_version_spec_l225_d31_comparing(),
		ruby_version_spec_l237_d32_comparing(),
		ruby_version_spec_l247_d33_comparing(),
		ruby_version_spec_l255_d34_can(),
		ruby_version_spec_l259_d35_can(),
		ruby_version_spec_l263_d36_can(),
		ruby_version_spec_l268_d37_can(),
		ruby_version_spec_l273_d38_can(),
		ruby_version_spec_l277_d39_comparison(),
		ruby_version_spec_l283_d40_erlang(),
		ruby_version_spec_l289_d41_hash(),
		ruby_version_spec_l304_d42_parses(),
		ruby_version_spec_l310_d43_head(),
		ruby_version_spec_l316_d44_head(),
		ruby_version_spec_l324_d45_is(),
		ruby_version_spec_l328_d46_is(),
		ruby_version_spec_l336_d47_head(),
		ruby_version_spec_l344_d48_update_commit(),
		ruby_version_spec_l358_d49_returns(),
		ruby_version_spec_l372_d50_returns(),
		ruby_version_spec_l386_d51_returns(),
		ruby_version_spec_l400_d52_returns(),
		ruby_version_spec_l414_d53_returns(),
		ruby_version_spec_l428_d54_returns(),
		ruby_version_spec_l435_d55_be_detected_from(),
		ruby_version_spec_l450_d56_version(),
		ruby_version_spec_l455_d57_version(),
		ruby_version_spec_l460_d58_boost(),
		ruby_version_spec_l465_d59_erlang(),
		ruby_version_spec_l470_d60_another(),
		ruby_version_spec_l475_d61_yet(),
		ruby_version_spec_l480_d62_p7zip(),
		ruby_version_spec_l485_d63_new(),
		ruby_version_spec_l490_d64_codeload(),
		ruby_version_spec_l495_d65_gloox(),
		ruby_version_spec_l500_d66_sphinx(),
		ruby_version_spec_l505_d67_astyle(),
		ruby_version_spec_l510_d68_version(),
		ruby_version_spec_l515_d69_version(),
		ruby_version_spec_l526_d70_version(),
		ruby_version_spec_l531_d71_noseparator(),
		ruby_version_spec_l536_d72_version(),
		ruby_version_spec_l541_d73_version(),
		ruby_version_spec_l546_d74_version(),
		ruby_version_spec_l553_d75_version(),
		ruby_version_spec_l558_d76_version(),
		ruby_version_spec_l563_d77_yet(),
		ruby_version_spec_l568_d78_lame(),
		ruby_version_spec_l573_d79_ruby(),
		ruby_version_spec_l578_d80_omega(),
		ruby_version_spec_l583_d81_rc(),
		ruby_version_spec_l588_d82_dash(),
		ruby_version_spec_l593_d83_angband(),
		ruby_version_spec_l598_d84_stable(),
		ruby_version_spec_l603_d85_debian(),
		ruby_version_spec_l608_d86_debian(),
		ruby_version_spec_l613_d87_debian(),
		ruby_version_spec_l620_d88_bottle(),
		ruby_version_spec_l625_d89_versioned(),
		ruby_version_spec_l630_d90_erlang(),
		ruby_version_spec_l635_d91_another(),
		ruby_version_spec_l640_d92_yet(),
		ruby_version_spec_l645_d93_imagemagick(),
		ruby_version_spec_l650_d94_imagemagick(),
		ruby_version_spec_l655_d95_imagemagick(),
		ruby_version_spec_l660_d96_date_based(),
		ruby_version_spec_l665_d97_unstable(),
		ruby_version_spec_l678_d98_jenkins(),
		ruby_version_spec_l685_d99_char(),
		ruby_version_spec_l694_d100_github(),
		ruby_version_spec_l700_d101_w_x_y_z(),
		ruby_version_spec_l707_d102_dash(),
		ruby_version_spec_l723_d103_apache(),
		ruby_version_spec_l730_d104_jpeg(),
		ruby_version_spec_l735_d105_ghc(),
		ruby_version_spec_l742_d106_pypy(),
		ruby_version_spec_l747_d107_openssl(),
		ruby_version_spec_l752_d108_xaw3d(),
		ruby_version_spec_l757_d109_assimp(),
		ruby_version_spec_l762_d110_cmucl(),
		ruby_version_spec_l769_d111_fann(),
		ruby_version_spec_l774_d112_grads(),
		ruby_version_spec_l779_d113_haxe(),
		ruby_version_spec_l784_d114_imap(),
		ruby_version_spec_l789_d115_suite3270(),
		ruby_version_spec_l796_d116_wwwoffle(),
		ruby_version_spec_l801_d117_synergy(),
		ruby_version_spec_l806_d118_fontforge(),
		ruby_version_spec_l813_d119_ezlupdate(),
		ruby_version_spec_l821_d120_aespipe(),
		ruby_version_spec_l826_d121_win(),
		ruby_version_spec_l833_d122_breseq(),
		ruby_version_spec_l841_d123_wildfly(),
		ruby_version_spec_l846_d124_trinity(),
		ruby_version_spec_l854_d125_with(),
		ruby_version_spec_l867_d126_opam(),
		ruby_version_spec_l878_d127_no(),
		ruby_version_spec_l889_d128_dash(),
		ruby_version_spec_l894_d129_semver(),
		ruby_version_spec_l899_d130_from(),
		ruby_version_spec_l904_d131_beta(),
		ruby_version_spec_l911_d132_version(),
	]
}

// Translated from Homebrew/brew `test/version_spec.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby subject `subject(:version) { described_class.new("1.2.3") }` at line 7.
pub fn ruby_version_spec_l7_d1_version() VersionSpecBoundary {
	return version_spec_boundary(7, version_spec_example_7())
}

// Ruby specify `specify ".formula_optionally_versioned_regex" do` at line 9.
pub fn ruby_version_spec_l9_d2_formula_optionally_versioned_regex() VersionSpecBoundary {
	return version_spec_boundary(9, version_spec_example_9())
}

// Ruby specify `specify do` at line 14.
pub fn ruby_version_spec_l14_d3_do() VersionSpecBoundary {
	return version_spec_boundary(14, version_spec_example_14())
}

// Ruby it `it "can be compared against nil" do` at line 19.
pub fn ruby_version_spec_l19_d4_can() VersionSpecBoundary {
	return version_spec_boundary(19, version_spec_example_19())
}

// Ruby it `it "can be compared against `Version::NULL_TOKEN`" do` at line 24.
pub fn ruby_version_spec_l24_d5_can() VersionSpecBoundary {
	return version_spec_boundary(24, version_spec_example_24())
}

// Ruby it `it "can be compared against strings" do` at line 29.
pub fn ruby_version_spec_l29_d6_can() VersionSpecBoundary {
	return version_spec_boundary(29, version_spec_example_29())
}

// Ruby specify `specify "comparison returns nil for non-token" do` at line 35.
pub fn ruby_version_spec_l35_d7_comparison() VersionSpecBoundary {
	return version_spec_boundary(35, version_spec_example_35())
}

// Ruby it `it "implicitly converts token to string" do` at line 42.
pub fn ruby_version_spec_l42_d8_implicitly() VersionSpecBoundary {
	return version_spec_boundary(42, version_spec_example_42())
}

// Ruby it `it "returns a string" do` at line 49.
pub fn ruby_version_spec_l49_d9_returns() VersionSpecBoundary {
	return version_spec_boundary(49, version_spec_example_49())
}

// Ruby it `it "returns a string" do` at line 55.
pub fn ruby_version_spec_l55_d10_returns() VersionSpecBoundary {
	return version_spec_boundary(55, version_spec_example_55())
}

// Ruby it `it "implicitlys converts to a string" do` at line 60.
pub fn ruby_version_spec_l60_d11_implicitlys() VersionSpecBoundary {
	return version_spec_boundary(60, version_spec_example_60())
}

// Ruby it `it "returns a float" do` at line 65.
pub fn ruby_version_spec_l65_d12_returns() VersionSpecBoundary {
	return version_spec_boundary(65, version_spec_example_65())
}

// Ruby it `it "returns a JSON string" do` at line 71.
pub fn ruby_version_spec_l71_d13_returns() VersionSpecBoundary {
	return version_spec_boundary(71, version_spec_example_71())
}

// Ruby subject `subject(:null_version) { Version::NULL }` at line 77.
pub fn ruby_version_spec_l77_d14_null_version() VersionSpecBoundary {
	return version_spec_boundary(77, homebrew.null_version().is_null())
}

// Ruby specify `specify do` at line 79.
pub fn ruby_version_spec_l79_d15_do() VersionSpecBoundary {
	return version_spec_boundary(79, version_spec_example_79())
}

// Ruby it `it "returns an empty string" do` at line 86.
pub fn ruby_version_spec_l86_d16_returns() VersionSpecBoundary {
	return version_spec_boundary(86, homebrew.null_version().to_s() == '')
}

// Ruby it `it "does not respond to it" do` at line 92.
pub fn ruby_version_spec_l92_d17_does() VersionSpecBoundary {
	return version_spec_boundary(92, !homebrew.null_version().responds_to_to_str())
}

// Ruby it `it "raises an error" do` at line 96.
pub fn ruby_version_spec_l96_d18_raises() VersionSpecBoundary {
	return version_spec_boundary(96, version_spec_example_96())
}

// Ruby it `it "does not implicitly convert to a string" do` at line 103.
pub fn ruby_version_spec_l103_d19_does() VersionSpecBoundary {
	return version_spec_boundary(103, !homebrew.null_version().responds_to_to_str())
}

// Ruby it `it "returns NaN" do` at line 108.
pub fn ruby_version_spec_l108_d20_returns() VersionSpecBoundary {
	return version_spec_boundary(108, math.is_nan(homebrew.null_version().to_f()))
}

// Ruby it `it "outputs `null`" do` at line 114.
pub fn ruby_version_spec_l114_d21_outputs() VersionSpecBoundary {
	return version_spec_boundary(114, homebrew.null_version().to_json() == 'null')
}

// Ruby subject `subject(:null_version) { Version::NULL_TOKEN }` at line 121.
pub fn ruby_version_spec_l121_d22_null_version() VersionSpecBoundary {
	return version_spec_boundary(121, homebrew.null_version_token().is_null())
}

// Ruby specify `specify do` at line 123.
pub fn ruby_version_spec_l123_d23_do() VersionSpecBoundary {
	return version_spec_boundary(123, version_spec_example_123())
}

// Ruby specify `specify "comparison" do` at line 129.
pub fn ruby_version_spec_l129_d24_comparison() VersionSpecBoundary {
	return version_spec_boundary(129, version_spec_example_129())
}

// Ruby specify `specify "compare" do` at line 141.
pub fn ruby_version_spec_l141_d25_compare() VersionSpecBoundary {
	return version_spec_boundary(141, version_spec_compare_examples())
}

// Ruby specify `specify "HEAD" do` at line 161.
pub fn ruby_version_spec_l161_d26_head() VersionSpecBoundary {
	return version_spec_boundary(161, version_spec_example_161())
}

// Ruby specify `specify "comparing alpha versions" do` at line 170.
pub fn ruby_version_spec_l170_d27_comparing() VersionSpecBoundary {
	return version_spec_boundary(170, version_spec_alpha_relations())
}

// Ruby specify `specify "comparing beta versions" do` at line 185.
pub fn ruby_version_spec_l185_d28_comparing() VersionSpecBoundary {
	return version_spec_boundary(185, version_spec_beta_relations())
}

// Ruby specify `specify "comparing pre versions" do` at line 198.
pub fn ruby_version_spec_l198_d29_comparing() VersionSpecBoundary {
	return version_spec_boundary(198, version_spec_pre_relations())
}

// Ruby specify `specify "comparing RC versions" do` at line 213.
pub fn ruby_version_spec_l213_d30_comparing() VersionSpecBoundary {
	return version_spec_boundary(213, version_spec_rc_relations())
}

// Ruby specify `specify "comparing patch-level versions" do` at line 225.
pub fn ruby_version_spec_l225_d31_comparing() VersionSpecBoundary {
	return version_spec_boundary(225, version_spec_patch_relations())
}

// Ruby specify `specify "comparing post-level versions" do` at line 237.
pub fn ruby_version_spec_l237_d32_comparing() VersionSpecBoundary {
	return version_spec_boundary(237, version_spec_post_relations())
}

// Ruby specify `specify "comparing unevenly-padded versions" do` at line 247.
pub fn ruby_version_spec_l247_d33_comparing() VersionSpecBoundary {
	return version_spec_boundary(247, version_spec_example_247())
}

// Ruby it `it "can be compared against nil" do` at line 255.
pub fn ruby_version_spec_l255_d34_can() VersionSpecBoundary {
	return version_spec_boundary(255, version_spec_example_255())
}

// Ruby it `it "can be compared against Version::NULL" do` at line 259.
pub fn ruby_version_spec_l259_d35_can() VersionSpecBoundary {
	return version_spec_boundary(259, version_spec_example_259())
}

// Ruby it `it "can be compared against strings" do` at line 263.
pub fn ruby_version_spec_l263_d36_can() VersionSpecBoundary {
	return version_spec_boundary(263, version_spec_example_263())
}

// Ruby it `it "can be compared against tokens" do` at line 268.
pub fn ruby_version_spec_l268_d37_can() VersionSpecBoundary {
	return version_spec_boundary(268, version_spec_example_268())
}

// Ruby it `it "can be compared against Version::NULL_TOKEN" do` at line 273.
pub fn ruby_version_spec_l273_d38_can() VersionSpecBoundary {
	return version_spec_boundary(273, version_spec_example_273())
}

// Ruby specify `specify "comparison returns nil for non-version" do` at line 277.
pub fn ruby_version_spec_l277_d39_comparison() VersionSpecBoundary {
	return version_spec_boundary(277, version_spec_example_277())
}

// Ruby specify `specify "erlang versions" do` at line 283.
pub fn ruby_version_spec_l283_d40_erlang() VersionSpecBoundary {
	return version_spec_boundary(283, version_spec_erlang_order())
}

// Ruby specify `specify "hash equality" do` at line 289.
pub fn ruby_version_spec_l289_d41_hash() VersionSpecBoundary {
	return version_spec_boundary(289, version_spec_example_289())
}

// Ruby it `it "parses a version from a string" do` at line 304.
pub fn ruby_version_spec_l304_d42_parses() VersionSpecBoundary {
	return version_spec_boundary(304, version_spec_example_304())
}

// Ruby specify `specify "HEAD with commit" do` at line 310.
pub fn ruby_version_spec_l310_d43_head() VersionSpecBoundary {
	return version_spec_boundary(310, version_spec_example_310())
}

// Ruby specify `specify "HEAD without commit" do` at line 316.
pub fn ruby_version_spec_l316_d44_head() VersionSpecBoundary {
	return version_spec_boundary(316, version_spec_example_316())
}

// Ruby it `it "is false if created explicitly" do` at line 324.
pub fn ruby_version_spec_l324_d45_is() VersionSpecBoundary {
	return version_spec_boundary(324, version_spec_example_324())
}

// Ruby it `it "is true if the version was detected from a URL" do` at line 328.
pub fn ruby_version_spec_l328_d46_is() VersionSpecBoundary {
	return version_spec_boundary(328, version_spec_example_328())
}

// Ruby specify `specify "#head?" do` at line 336.
pub fn ruby_version_spec_l336_d47_head() VersionSpecBoundary {
	return version_spec_boundary(336, version_spec_example_336())
}

// Ruby specify `specify "#update_commit" do` at line 344.
pub fn ruby_version_spec_l344_d48_update_commit() VersionSpecBoundary {
	return version_spec_boundary(344, version_spec_update_commit())
}

// Ruby it `it "returns major version token" do` at line 358.
pub fn ruby_version_spec_l358_d49_returns() VersionSpecBoundary {
	return version_spec_boundary(358, version_spec_components('major'))
}

// Ruby it `it "returns minor version token" do` at line 372.
pub fn ruby_version_spec_l372_d50_returns() VersionSpecBoundary {
	return version_spec_boundary(372, version_spec_components('minor'))
}

// Ruby it `it "returns patch version token" do` at line 386.
pub fn ruby_version_spec_l386_d51_returns() VersionSpecBoundary {
	return version_spec_boundary(386, version_spec_components('patch'))
}

// Ruby it `it "returns major.minor version" do` at line 400.
pub fn ruby_version_spec_l400_d52_returns() VersionSpecBoundary {
	return version_spec_boundary(400, version_spec_leading_components(2))
}

// Ruby it `it "returns major.minor.patch version" do` at line 414.
pub fn ruby_version_spec_l414_d53_returns() VersionSpecBoundary {
	return version_spec_boundary(414, version_spec_leading_components(3))
}

// Ruby it `it "returns a NULL version when the URL cannot be parsed" do` at line 428.
pub fn ruby_version_spec_l428_d54_returns() VersionSpecBoundary {
	return version_spec_boundary(428, version_spec_example_428())
}

// Ruby matcher `matcher :be_detected_from do |url, **specs|` at line 435.
pub fn ruby_version_spec_l435_d55_be_detected_from() VersionSpecBoundary {
	return version_spec_boundary(435, version_spec_example_435())
}

// Ruby specify `specify "version all dots" do` at line 450.
pub fn ruby_version_spec_l450_d56_version() VersionSpecBoundary {
	return version_spec_boundary(450, version_spec_detect(version_spec_detection_expectations_450()))
}

// Ruby specify `specify "version underscore separator" do` at line 455.
pub fn ruby_version_spec_l455_d57_version() VersionSpecBoundary {
	return version_spec_boundary(455, version_spec_detect(version_spec_detection_expectations_455()))
}

// Ruby specify `specify "boost version style" do` at line 460.
pub fn ruby_version_spec_l460_d58_boost() VersionSpecBoundary {
	return version_spec_boundary(460, version_spec_detect(version_spec_detection_expectations_460()))
}

// Ruby specify `specify "erlang version style" do` at line 465.
pub fn ruby_version_spec_l465_d59_erlang() VersionSpecBoundary {
	return version_spec_boundary(465, version_spec_detect(version_spec_detection_expectations_465()))
}

// Ruby specify `specify "another erlang version style" do` at line 470.
pub fn ruby_version_spec_l470_d60_another() VersionSpecBoundary {
	return version_spec_boundary(470, version_spec_detect(version_spec_detection_expectations_470()))
}

// Ruby specify `specify "yet another erlang version style" do` at line 475.
pub fn ruby_version_spec_l475_d61_yet() VersionSpecBoundary {
	return version_spec_boundary(475, version_spec_detect(version_spec_detection_expectations_475()))
}

// Ruby specify `specify "p7zip version style" do` at line 480.
pub fn ruby_version_spec_l480_d62_p7zip() VersionSpecBoundary {
	return version_spec_boundary(480, version_spec_detect(version_spec_detection_expectations_480()))
}

// Ruby specify `specify "new github style" do` at line 485.
pub fn ruby_version_spec_l485_d63_new() VersionSpecBoundary {
	return version_spec_boundary(485, version_spec_detect(version_spec_detection_expectations_485()))
}

// Ruby specify `specify "codeload style" do` at line 490.
pub fn ruby_version_spec_l490_d64_codeload() VersionSpecBoundary {
	return version_spec_boundary(490, version_spec_detect(version_spec_detection_expectations_490()))
}

// Ruby specify `specify "gloox beta style" do` at line 495.
pub fn ruby_version_spec_l495_d65_gloox() VersionSpecBoundary {
	return version_spec_boundary(495, version_spec_detect(version_spec_detection_expectations_495()))
}

// Ruby specify `specify "sphinx beta style" do` at line 500.
pub fn ruby_version_spec_l500_d66_sphinx() VersionSpecBoundary {
	return version_spec_boundary(500, version_spec_detect(version_spec_detection_expectations_500()))
}

// Ruby specify `specify "astyle version style" do` at line 505.
pub fn ruby_version_spec_l505_d67_astyle() VersionSpecBoundary {
	return version_spec_boundary(505, version_spec_detect(version_spec_detection_expectations_505()))
}

// Ruby specify `specify "version dos2unix" do` at line 510.
pub fn ruby_version_spec_l510_d68_version() VersionSpecBoundary {
	return version_spec_boundary(510, version_spec_detect(version_spec_detection_expectations_510()))
}

// Ruby specify `specify "version internal dash" do` at line 515.
pub fn ruby_version_spec_l515_d69_version() VersionSpecBoundary {
	return version_spec_boundary(515, version_spec_detect(version_spec_detection_expectations_515()))
}

// Ruby specify `specify "version single digit" do` at line 526.
pub fn ruby_version_spec_l526_d70_version() VersionSpecBoundary {
	return version_spec_boundary(526, version_spec_detect(version_spec_detection_expectations_526()))
}

// Ruby specify `specify "noseparator single digit" do` at line 531.
pub fn ruby_version_spec_l531_d71_noseparator() VersionSpecBoundary {
	return version_spec_boundary(531, version_spec_detect(version_spec_detection_expectations_531()))
}

// Ruby specify `specify "version developer that hates us format" do` at line 536.
pub fn ruby_version_spec_l536_d72_version() VersionSpecBoundary {
	return version_spec_boundary(536, version_spec_detect(version_spec_detection_expectations_536()))
}

// Ruby specify `specify "version regular" do` at line 541.
pub fn ruby_version_spec_l541_d73_version() VersionSpecBoundary {
	return version_spec_boundary(541, version_spec_detect(version_spec_detection_expectations_541()))
}

// Ruby specify `specify "version sourceforge download" do` at line 546.
pub fn ruby_version_spec_l546_d74_version() VersionSpecBoundary {
	return version_spec_boundary(546, version_spec_detect(version_spec_detection_expectations_546()))
}

// Ruby specify `specify "version github" do` at line 553.
pub fn ruby_version_spec_l553_d75_version() VersionSpecBoundary {
	return version_spec_boundary(553, version_spec_detect(version_spec_detection_expectations_553()))
}

// Ruby specify `specify "version github with high patch number" do` at line 558.
pub fn ruby_version_spec_l558_d76_version() VersionSpecBoundary {
	return version_spec_boundary(558, version_spec_detect(version_spec_detection_expectations_558()))
}

// Ruby specify `specify "yet another version" do` at line 563.
pub fn ruby_version_spec_l563_d77_yet() VersionSpecBoundary {
	return version_spec_boundary(563, version_spec_detect(version_spec_detection_expectations_563()))
}

// Ruby specify `specify "lame version style" do` at line 568.
pub fn ruby_version_spec_l568_d78_lame() VersionSpecBoundary {
	return version_spec_boundary(568, version_spec_detect(version_spec_detection_expectations_568()))
}

// Ruby specify `specify "ruby version style" do` at line 573.
pub fn ruby_version_spec_l573_d79_ruby() VersionSpecBoundary {
	return version_spec_boundary(573, version_spec_detect(version_spec_detection_expectations_573()))
}

// Ruby specify `specify "omega version style" do` at line 578.
pub fn ruby_version_spec_l578_d80_omega() VersionSpecBoundary {
	return version_spec_boundary(578, version_spec_detect(version_spec_detection_expectations_578()))
}

// Ruby specify `specify "rc style" do` at line 583.
pub fn ruby_version_spec_l583_d81_rc() VersionSpecBoundary {
	return version_spec_boundary(583, version_spec_detect(version_spec_detection_expectations_583()))
}

// Ruby specify `specify "dash rc style" do` at line 588.
pub fn ruby_version_spec_l588_d82_dash() VersionSpecBoundary {
	return version_spec_boundary(588, version_spec_detect(version_spec_detection_expectations_588()))
}

// Ruby specify `specify "angband version style" do` at line 593.
pub fn ruby_version_spec_l593_d83_angband() VersionSpecBoundary {
	return version_spec_boundary(593, version_spec_detect(version_spec_detection_expectations_593()))
}

// Ruby specify `specify "stable suffix" do` at line 598.
pub fn ruby_version_spec_l598_d84_stable() VersionSpecBoundary {
	return version_spec_boundary(598, version_spec_detect(version_spec_detection_expectations_598()))
}

// Ruby specify `specify "debian style" do` at line 603.
pub fn ruby_version_spec_l603_d85_debian() VersionSpecBoundary {
	return version_spec_boundary(603, version_spec_detect(version_spec_detection_expectations_603()))
}

// Ruby specify `specify "debian style with letter suffix" do` at line 608.
pub fn ruby_version_spec_l608_d86_debian() VersionSpecBoundary {
	return version_spec_boundary(608, version_spec_detect(version_spec_detection_expectations_608()))
}

// Ruby specify `specify "debian style dotless" do` at line 613.
pub fn ruby_version_spec_l613_d87_debian() VersionSpecBoundary {
	return version_spec_boundary(613, version_spec_detect(version_spec_detection_expectations_613()))
}

// Ruby specify `specify "bottle style" do` at line 620.
pub fn ruby_version_spec_l620_d88_bottle() VersionSpecBoundary {
	return version_spec_boundary(620, version_spec_detect(version_spec_detection_expectations_620()))
}

// Ruby specify `specify "versioned bottle style" do` at line 625.
pub fn ruby_version_spec_l625_d89_versioned() VersionSpecBoundary {
	return version_spec_boundary(625, version_spec_detect(version_spec_detection_expectations_625()))
}

// Ruby specify `specify "erlang bottle style" do` at line 630.
pub fn ruby_version_spec_l630_d90_erlang() VersionSpecBoundary {
	return version_spec_boundary(630, version_spec_detect(version_spec_detection_expectations_630()))
}

// Ruby specify `specify "another erlang bottle style" do` at line 635.
pub fn ruby_version_spec_l635_d91_another() VersionSpecBoundary {
	return version_spec_boundary(635, version_spec_detect(version_spec_detection_expectations_635()))
}

// Ruby specify `specify "yet another erlang bottle style" do` at line 640.
pub fn ruby_version_spec_l640_d92_yet() VersionSpecBoundary {
	return version_spec_boundary(640, version_spec_detect(version_spec_detection_expectations_640()))
}

// Ruby specify `specify "imagemagick style" do` at line 645.
pub fn ruby_version_spec_l645_d93_imagemagick() VersionSpecBoundary {
	return version_spec_boundary(645, version_spec_detect(version_spec_detection_expectations_645()))
}

// Ruby specify `specify "imagemagick bottle style" do` at line 650.
pub fn ruby_version_spec_l650_d94_imagemagick() VersionSpecBoundary {
	return version_spec_boundary(650, version_spec_detect(version_spec_detection_expectations_650()))
}

// Ruby specify `specify "imagemagick versioned bottle style" do` at line 655.
pub fn ruby_version_spec_l655_d95_imagemagick() VersionSpecBoundary {
	return version_spec_boundary(655, version_spec_detect(version_spec_detection_expectations_655()))
}

// Ruby specify `specify "date-based version style" do` at line 660.
pub fn ruby_version_spec_l660_d96_date_based() VersionSpecBoundary {
	return version_spec_boundary(660, version_spec_detect(version_spec_detection_expectations_660()))
}

// Ruby specify `specify "unstable version style" do` at line 665.
pub fn ruby_version_spec_l665_d97_unstable() VersionSpecBoundary {
	return version_spec_boundary(665, version_spec_detect(version_spec_detection_expectations_665()))
}

// Ruby specify `specify "jenkins version style" do` at line 678.
pub fn ruby_version_spec_l678_d98_jenkins() VersionSpecBoundary {
	return version_spec_boundary(678, version_spec_detect(version_spec_detection_expectations_678()))
}

// Ruby specify `specify "char prefixed, url-only version style" do` at line 685.
pub fn ruby_version_spec_l685_d99_char() VersionSpecBoundary {
	return version_spec_boundary(685, version_spec_detect(version_spec_detection_expectations_685()))
}

// Ruby specify `specify "GitHub release tag takes precedence over asset filename" do` at line 694.
pub fn ruby_version_spec_l694_d100_github() VersionSpecBoundary {
	return version_spec_boundary(694, version_spec_detect(version_spec_detection_expectations_694()))
}

// Ruby specify `specify "w.x.y.z url-only version style" do` at line 700.
pub fn ruby_version_spec_l700_d101_w_x_y_z() VersionSpecBoundary {
	return version_spec_boundary(700, version_spec_detect(version_spec_detection_expectations_700()))
}

// Ruby specify `specify "dash version style" do` at line 707.
pub fn ruby_version_spec_l707_d102_dash() VersionSpecBoundary {
	return version_spec_boundary(707, version_spec_detect(version_spec_detection_expectations_707()))
}

// Ruby specify `specify "apache version style" do` at line 723.
pub fn ruby_version_spec_l723_d103_apache() VersionSpecBoundary {
	return version_spec_boundary(723, version_spec_detect(version_spec_detection_expectations_723()))
}

// Ruby specify `specify "jpeg version style" do` at line 730.
pub fn ruby_version_spec_l730_d104_jpeg() VersionSpecBoundary {
	return version_spec_boundary(730, version_spec_detect(version_spec_detection_expectations_730()))
}

// Ruby specify `specify "ghc version style" do` at line 735.
pub fn ruby_version_spec_l735_d105_ghc() VersionSpecBoundary {
	return version_spec_boundary(735, version_spec_detect(version_spec_detection_expectations_735()))
}

// Ruby specify `specify "pypy version style" do` at line 742.
pub fn ruby_version_spec_l742_d106_pypy() VersionSpecBoundary {
	return version_spec_boundary(742, version_spec_detect(version_spec_detection_expectations_742()))
}

// Ruby specify `specify "openssl version style" do` at line 747.
pub fn ruby_version_spec_l747_d107_openssl() VersionSpecBoundary {
	return version_spec_boundary(747, version_spec_detect(version_spec_detection_expectations_747()))
}

// Ruby specify `specify "xaw3d version style" do` at line 752.
pub fn ruby_version_spec_l752_d108_xaw3d() VersionSpecBoundary {
	return version_spec_boundary(752, version_spec_detect(version_spec_detection_expectations_752()))
}

// Ruby specify `specify "assimp version style" do` at line 757.
pub fn ruby_version_spec_l757_d109_assimp() VersionSpecBoundary {
	return version_spec_boundary(757, version_spec_detect(version_spec_detection_expectations_757()))
}

// Ruby specify `specify "cmucl version style" do` at line 762.
pub fn ruby_version_spec_l762_d110_cmucl() VersionSpecBoundary {
	return version_spec_boundary(762, version_spec_detect(version_spec_detection_expectations_762()))
}

// Ruby specify `specify "fann version style" do` at line 769.
pub fn ruby_version_spec_l769_d111_fann() VersionSpecBoundary {
	return version_spec_boundary(769, version_spec_detect(version_spec_detection_expectations_769()))
}

// Ruby specify `specify "grads version style" do` at line 774.
pub fn ruby_version_spec_l774_d112_grads() VersionSpecBoundary {
	return version_spec_boundary(774, version_spec_detect(version_spec_detection_expectations_774()))
}

// Ruby specify `specify "haxe version style" do` at line 779.
pub fn ruby_version_spec_l779_d113_haxe() VersionSpecBoundary {
	return version_spec_boundary(779, version_spec_detect(version_spec_detection_expectations_779()))
}

// Ruby specify `specify "imap version style" do` at line 784.
pub fn ruby_version_spec_l784_d114_imap() VersionSpecBoundary {
	return version_spec_boundary(784, version_spec_detect(version_spec_detection_expectations_784()))
}

// Ruby specify `specify "suite3270 version style" do` at line 789.
pub fn ruby_version_spec_l789_d115_suite3270() VersionSpecBoundary {
	return version_spec_boundary(789, version_spec_detect(version_spec_detection_expectations_789()))
}

// Ruby specify `specify "wwwoffle version style" do` at line 796.
pub fn ruby_version_spec_l796_d116_wwwoffle() VersionSpecBoundary {
	return version_spec_boundary(796, version_spec_detect(version_spec_detection_expectations_796()))
}

// Ruby specify `specify "synergy version style" do` at line 801.
pub fn ruby_version_spec_l801_d117_synergy() VersionSpecBoundary {
	return version_spec_boundary(801, version_spec_detect(version_spec_detection_expectations_801()))
}

// Ruby specify `specify "fontforge version style" do` at line 806.
pub fn ruby_version_spec_l806_d118_fontforge() VersionSpecBoundary {
	return version_spec_boundary(806, version_spec_detect(version_spec_detection_expectations_806()))
}

// Ruby specify `specify "ezlupdate version style" do` at line 813.
pub fn ruby_version_spec_l813_d119_ezlupdate() VersionSpecBoundary {
	return version_spec_boundary(813, version_spec_detect(version_spec_detection_expectations_813()))
}

// Ruby specify `specify "aespipe version style" do` at line 821.
pub fn ruby_version_spec_l821_d120_aespipe() VersionSpecBoundary {
	return version_spec_boundary(821, version_spec_detect(version_spec_detection_expectations_821()))
}

// Ruby specify `specify "win version style" do` at line 826.
pub fn ruby_version_spec_l826_d121_win() VersionSpecBoundary {
	return version_spec_boundary(826, version_spec_detect(version_spec_detection_expectations_826()))
}

// Ruby specify `specify "breseq version style" do` at line 833.
pub fn ruby_version_spec_l833_d122_breseq() VersionSpecBoundary {
	return version_spec_boundary(833, version_spec_detect(version_spec_detection_expectations_833()))
}

// Ruby specify `specify "wildfly version style" do` at line 841.
pub fn ruby_version_spec_l841_d123_wildfly() VersionSpecBoundary {
	return version_spec_boundary(841, version_spec_detect(version_spec_detection_expectations_841()))
}

// Ruby specify `specify "trinity version style" do` at line 846.
pub fn ruby_version_spec_l846_d124_trinity() VersionSpecBoundary {
	return version_spec_boundary(846, version_spec_detect(version_spec_detection_expectations_846()))
}

// Ruby specify `specify "with arch" do` at line 854.
pub fn ruby_version_spec_l854_d125_with() VersionSpecBoundary {
	return version_spec_boundary(854, version_spec_detect(version_spec_detection_expectations_854()))
}

// Ruby specify `specify "opam version" do` at line 867.
pub fn ruby_version_spec_l867_d126_opam() VersionSpecBoundary {
	return version_spec_boundary(867, version_spec_detect(version_spec_detection_expectations_867()))
}

// Ruby specify `specify "no extension version" do` at line 878.
pub fn ruby_version_spec_l878_d127_no() VersionSpecBoundary {
	return version_spec_boundary(878, version_spec_detect(version_spec_detection_expectations_878()))
}

// Ruby specify `specify "dash separated version" do` at line 889.
pub fn ruby_version_spec_l889_d128_dash() VersionSpecBoundary {
	return version_spec_boundary(889, version_spec_detect(version_spec_detection_expectations_889()))
}

// Ruby specify `specify "semver in middle of URL" do` at line 894.
pub fn ruby_version_spec_l894_d129_semver() VersionSpecBoundary {
	return version_spec_boundary(894, version_spec_detect(version_spec_detection_expectations_894()))
}

// Ruby specify `specify "from tag" do` at line 899.
pub fn ruby_version_spec_l899_d130_from() VersionSpecBoundary {
	return version_spec_boundary(899, version_spec_detect(version_spec_detection_expectations_899()))
}

// Ruby specify `specify "beta from tag" do` at line 904.
pub fn ruby_version_spec_l904_d131_beta() VersionSpecBoundary {
	return version_spec_boundary(904, version_spec_detect(version_spec_detection_expectations_904()))
}

// Ruby specify `specify "#version" do` at line 911.
pub fn ruby_version_spec_l911_d132_version() VersionSpecBoundary {
	return version_spec_boundary(911, version_spec_example_911())
}

// Original Ruby source (line-for-line):
// 1: # typed: false
// 2: # frozen_string_literal: true
// 3:
// 4: require "version"
// 5:
// 6: RSpec.describe Version do
// 7:   subject(:version) { described_class.new("1.2.3") }
// 8:
// 9:   specify ".formula_optionally_versioned_regex" do
// 10:     expect(described_class.formula_optionally_versioned_regex("foo")).to match("foo@1.2")
// 11:   end
// 12:
// 13:   describe Version::Token do
// 14:     specify do
// 15:       expect(described_class.create("foo").inspect).to eq('#<Version::StringToken "foo">')
// 16:       expect(described_class.create("foo").to_s).to eq("foo")
// 17:     end
// 18:
// 19:     it "can be compared against nil" do
// 20:       expect(described_class.create("2")).to be > nil
// 21:       expect(described_class.create("p194")).to be > nil
// 22:     end
// 23:
// 24:     it "can be compared against `Version::NULL_TOKEN`" do
// 25:       expect(described_class.create("2")).to be > Version::NULL_TOKEN
// 26:       expect(described_class.create("p194")).to be > Version::NULL_TOKEN
// 27:     end
// 28:
// 29:     it "can be compared against strings" do
// 30:       expect(described_class.create("2")).to eq "2"
// 31:       expect(described_class.create("p194")).to eq "p194"
// 32:       expect(described_class.create("1")).to eq 1
// 33:     end
// 34:
// 35:     specify "comparison returns nil for non-token" do
// 36:       v = described_class.create("1")
// 37:       expect(v <=> Object.new).to be_nil
// 38:       expect { v > Object.new }.to raise_error(ArgumentError)
// 39:     end
// 40:
// 41:     describe "#to_str" do
// 42:       it "implicitly converts token to string" do
// 43:         expect(String.try_convert(described_class.create("foo"))).not_to be_nil
// 44:       end
// 45:     end
// 46:   end
// 47:
// 48:   describe "#to_s" do
// 49:     it "returns a string" do
// 50:       expect(version.to_s).to eq "1.2.3"
// 51:     end
// 52:   end
// 53:
// 54:   describe "#to_str" do
// 55:     it "returns a string" do
// 56:       expect(version.to_str).to eq "1.2.3"
// 57:     end
// 58:   end
// 59:
// 60:   it "implicitlys converts to a string" do
// 61:     expect(String.try_convert(version)).to eq "1.2.3"
// 62:   end
// 63:
// 64:   describe "#to_f" do
// 65:     it "returns a float" do
// 66:       expect(version.to_f).to eq 1.2
// 67:     end
// 68:   end
// 69:
// 70:   describe "#to_json" do
// 71:     it "returns a JSON string" do
// 72:       expect(version.to_json).to eq "\"1.2.3\""
// 73:     end
// 74:   end
// 75:
// 76:   describe "when the version is `NULL`" do
// 77:     subject(:null_version) { Version::NULL }
// 78:
// 79:     specify do
// 80:       expect(null_version).to be < described_class.new("1")
// 81:       expect(null_version).not_to be > described_class.new("0")
// 82:       expect(null_version).not_to eql(null_version)
// 83:     end
// 84:
// 85:     describe "#to_s" do
// 86:       it "returns an empty string" do
// 87:         expect(null_version.to_s).to eq ""
// 88:       end
// 89:     end
// 90:
// 91:     describe "#to_str" do
// 92:       it "does not respond to it" do
// 93:         expect(null_version).not_to respond_to(:to_str)
// 94:       end
// 95:
// 96:       it "raises an error" do
// 97:         expect do
// 98:           null_version.to_str
// 99:         end.to raise_error NoMethodError, "undefined method `to_str` for Version:NULL"
// 100:       end
// 101:     end
// 102:
// 103:     it "does not implicitly convert to a string" do
// 104:       expect(String.try_convert(null_version)).to be_nil
// 105:     end
// 106:
// 107:     describe "#to_f" do
// 108:       it "returns NaN" do
// 109:         expect(null_version.to_f).to be_nan
// 110:       end
// 111:     end
// 112:
// 113:     describe "#to_json" do
// 114:       it "outputs `null`" do
// 115:         expect(null_version.to_json).to eq "null"
// 116:       end
// 117:     end
// 118:   end
// 119:
// 120:   describe "::NULL_TOKEN" do
// 121:     subject(:null_version) { Version::NULL_TOKEN }
// 122:
// 123:     specify do
// 124:       expect(null_version.inspect).to eq("#<Version::NullToken>")
// 125:       expect(null_version).to eq Version::NULL_TOKEN
// 126:     end
// 127:   end
// 128:
// 129:   specify "comparison" do
// 130:     expect(described_class.new("0.1")).to eq described_class.new("0.1.0")
// 131:     expect(described_class.new("0.1")).to be < described_class.new("0.2")
// 132:     expect(described_class.new("1.2.3")).to be > described_class.new("1.2.2")
// 133:     expect(described_class.new("1.2.4")).to be < described_class.new("1.2.4.1")
// 134:
// 135:     expect(described_class.new("1.2.3")).to be > described_class.new("1.2.3alpha4")
// 136:     expect(described_class.new("1.2.3")).to be > described_class.new("1.2.3beta2")
// 137:     expect(described_class.new("1.2.3")).to be > described_class.new("1.2.3rc3")
// 138:     expect(described_class.new("1.2.3")).to be < described_class.new("1.2.3-p34")
// 139:   end
// 140:
// 141:   specify "compare" do
// 142:     expect(described_class.new("0.1").compare("==", described_class.new("0.1.0"))).to be true
// 143:     expect(described_class.new("0.1").compare("<", described_class.new("0.2"))).to be true
// 144:     expect(described_class.new("1.2.3").compare(">", described_class.new("1.2.2"))).to be true
// 145:     expect(described_class.new("1.2.4").compare("<", described_class.new("1.2.4.1"))).to be true
// 146:     expect(described_class.new("0.1").compare("!=", described_class.new("0.1.0"))).to be false
// 147:     expect(described_class.new("0.1").compare(">=", described_class.new("0.2"))).to be false
// 148:     expect(described_class.new("1.2.3").compare("<=", described_class.new("1.2.2"))).to be false
// 149:     expect(described_class.new("1.2.4").compare(">=", described_class.new("1.2.4.1"))).to be false
// 150:
// 151:     expect(described_class.new("1.2.3").compare(">", described_class.new("1.2.3alpha4"))).to be true
// 152:     expect(described_class.new("1.2.3").compare(">", described_class.new("1.2.3beta2"))).to be true
// 153:     expect(described_class.new("1.2.3").compare(">", described_class.new("1.2.3rc3"))).to be true
// 154:     expect(described_class.new("1.2.3").compare("<", described_class.new("1.2.3-p34"))).to be true
// 155:     expect(described_class.new("1.2.3").compare("<=", described_class.new("1.2.3alpha4"))).to be false
// 156:     expect(described_class.new("1.2.3").compare("<=", described_class.new("1.2.3beta2"))).to be false
// 157:     expect(described_class.new("1.2.3").compare("<=", described_class.new("1.2.3rc3"))).to be false
// 158:     expect(described_class.new("1.2.3").compare(">=", described_class.new("1.2.3-p34"))).to be false
// 159:   end
// 160:
// 161:   specify "HEAD" do
// 162:     expect(described_class.new("HEAD")).to be > described_class.new("1.2.3")
// 163:     expect(described_class.new("HEAD-abcdef")).to be > described_class.new("1.2.3")
// 164:     expect(described_class.new("1.2.3")).to be < described_class.new("HEAD")
// 165:     expect(described_class.new("1.2.3")).to be < described_class.new("HEAD-fedcba")
// 166:     expect(described_class.new("HEAD-abcdef")).to eq described_class.new("HEAD-fedcba")
// 167:     expect(described_class.new("HEAD")).to eq described_class.new("HEAD-fedcba")
// 168:   end
// 169:
// 170:   specify "comparing alpha versions" do
// 171:     expect(described_class.new("1.2.3alpha")).to be < described_class.new("1.2.3")
// 172:     expect(described_class.new("1.2.3")).to be < described_class.new("1.2.3a")
// 173:     expect(described_class.new("1.2.3alpha4")).to eq described_class.new("1.2.3a4")
// 174:     expect(described_class.new("1.2.3alpha4")).to eq described_class.new("1.2.3A4")
// 175:     expect(described_class.new("1.2.3alpha4")).to be > described_class.new("1.2.3alpha3")
// 176:     expect(described_class.new("1.2.3alpha4")).to be < described_class.new("1.2.3alpha5")
// 177:     expect(described_class.new("1.2.3alpha4")).to be < described_class.new("1.2.3alpha10")
// 178:
// 179:     expect(described_class.new("1.2.3alpha4")).to be < described_class.new("1.2.3beta2")
// 180:     expect(described_class.new("1.2.3alpha4")).to be < described_class.new("1.2.3rc3")
// 181:     expect(described_class.new("1.2.3alpha4")).to be < described_class.new("1.2.3")
// 182:     expect(described_class.new("1.2.3alpha4")).to be < described_class.new("1.2.3-p34")
// 183:   end
// 184:
// 185:   specify "comparing beta versions" do
// 186:     expect(described_class.new("1.2.3beta2")).to eq described_class.new("1.2.3b2")
// 187:     expect(described_class.new("1.2.3beta2")).to eq described_class.new("1.2.3B2")
// 188:     expect(described_class.new("1.2.3beta2")).to be > described_class.new("1.2.3beta1")
// 189:     expect(described_class.new("1.2.3beta2")).to be < described_class.new("1.2.3beta3")
// 190:     expect(described_class.new("1.2.3beta2")).to be < described_class.new("1.2.3beta10")
// 191:
// 192:     expect(described_class.new("1.2.3beta2")).to be > described_class.new("1.2.3alpha4")
// 193:     expect(described_class.new("1.2.3beta2")).to be < described_class.new("1.2.3rc3")
// 194:     expect(described_class.new("1.2.3beta2")).to be < described_class.new("1.2.3")
// 195:     expect(described_class.new("1.2.3beta2")).to be < described_class.new("1.2.3-p34")
// 196:   end
// 197:
// 198:   specify "comparing pre versions" do
// 199:     expect(described_class.new("1.2.3pre9")).to eq described_class.new("1.2.3PRE9")
// 200:     expect(described_class.new("1.2.3pre9")).to be > described_class.new("1.2.3pre8")
// 201:     expect(described_class.new("1.2.3pre8")).to be < described_class.new("1.2.3pre9")
// 202:     expect(described_class.new("1.2.3pre9")).to be < described_class.new("1.2.3pre10")
// 203:
// 204:     expect(described_class.new("1.2.3pre3")).to be > described_class.new("1.2.3alpha2")
// 205:     expect(described_class.new("1.2.3pre3")).to be > described_class.new("1.2.3alpha4")
// 206:     expect(described_class.new("1.2.3pre3")).to be > described_class.new("1.2.3beta3")
// 207:     expect(described_class.new("1.2.3pre3")).to be > described_class.new("1.2.3beta5")
// 208:     expect(described_class.new("1.2.3pre3")).to be < described_class.new("1.2.3rc2")
// 209:     expect(described_class.new("1.2.3pre3")).to be < described_class.new("1.2.3")
// 210:     expect(described_class.new("1.2.3pre3")).to be < described_class.new("1.2.3-p2")
// 211:   end
// 212:
// 213:   specify "comparing RC versions" do
// 214:     expect(described_class.new("1.2.3rc3")).to eq described_class.new("1.2.3RC3")
// 215:     expect(described_class.new("1.2.3rc3")).to be > described_class.new("1.2.3rc2")
// 216:     expect(described_class.new("1.2.3rc3")).to be < described_class.new("1.2.3rc4")
// 217:     expect(described_class.new("1.2.3rc3")).to be < described_class.new("1.2.3rc10")
// 218:
// 219:     expect(described_class.new("1.2.3rc3")).to be > described_class.new("1.2.3alpha4")
// 220:     expect(described_class.new("1.2.3rc3")).to be > described_class.new("1.2.3beta2")
// 221:     expect(described_class.new("1.2.3rc3")).to be < described_class.new("1.2.3")
// 222:     expect(described_class.new("1.2.3rc3")).to be < described_class.new("1.2.3-p34")
// 223:   end
// 224:
// 225:   specify "comparing patch-level versions" do
// 226:     expect(described_class.new("1.2.3-p34")).to eq described_class.new("1.2.3-P34")
// 227:     expect(described_class.new("1.2.3-p34")).to be > described_class.new("1.2.3-p33")
// 228:     expect(described_class.new("1.2.3-p34")).to be < described_class.new("1.2.3-p35")
// 229:     expect(described_class.new("1.2.3-p34")).to be > described_class.new("1.2.3-p9")
// 230:
// 231:     expect(described_class.new("1.2.3-p34")).to be > described_class.new("1.2.3alpha4")
// 232:     expect(described_class.new("1.2.3-p34")).to be > described_class.new("1.2.3beta2")
// 233:     expect(described_class.new("1.2.3-p34")).to be > described_class.new("1.2.3rc3")
// 234:     expect(described_class.new("1.2.3-p34")).to be > described_class.new("1.2.3")
// 235:   end
// 236:
// 237:   specify "comparing post-level versions" do
// 238:     expect(described_class.new("1.2.3.post34")).to be > described_class.new("1.2.3.post33")
// 239:     expect(described_class.new("1.2.3.post34")).to be < described_class.new("1.2.3.post35")
// 240:
// 241:     expect(described_class.new("1.2.3.post34")).to be > described_class.new("1.2.3rc35")
// 242:     expect(described_class.new("1.2.3.post34")).to be > described_class.new("1.2.3alpha35")
// 243:     expect(described_class.new("1.2.3.post34")).to be > described_class.new("1.2.3beta35")
// 244:     expect(described_class.new("1.2.3.post34")).to be > described_class.new("1.2.3")
// 245:   end
// 246:
// 247:   specify "comparing unevenly-padded versions" do
// 248:     expect(described_class.new("2.1.0-p194")).to be < described_class.new("2.1-p195")
// 249:     expect(described_class.new("2.1-p195")).to be > described_class.new("2.1.0-p194")
// 250:     expect(described_class.new("2.1-p194")).to be < described_class.new("2.1.0-p195")
// 251:     expect(described_class.new("2.1.0-p195")).to be > described_class.new("2.1-p194")
// 252:     expect(described_class.new("2-p194")).to be < described_class.new("2.1-p195")
// 253:   end
// 254:
// 255:   it "can be compared against nil" do
// 256:     expect(described_class.new("2.1.0-p194")).to be > nil
// 257:   end
// 258:
// 259:   it "can be compared against Version::NULL" do
// 260:     expect(described_class.new("2.1.0-p194")).to be > Version::NULL
// 261:   end
// 262:
// 263:   it "can be compared against strings" do
// 264:     expect(described_class.new("2.1.0-p194")).to eq "2.1.0-p194"
// 265:     expect(described_class.new("1")).to eq 1
// 266:   end
// 267:
// 268:   it "can be compared against tokens" do
// 269:     expect(described_class.new("2.1.0-p194")).to be > Version::Token.create("2")
// 270:     expect(described_class.new("1")).to eq Version::Token.create("1")
// 271:   end
// 272:
// 273:   it "can be compared against Version::NULL_TOKEN" do
// 274:     expect(described_class.new("2.1.0-p194")).to be > Version::NULL_TOKEN
// 275:   end
// 276:
// 277:   specify "comparison returns nil for non-version" do
// 278:     v = described_class.new("1.0")
// 279:     expect(v <=> Object.new).to be_nil
// 280:     expect { v > Object.new }.to raise_error(ArgumentError)
// 281:   end
// 282:
// 283:   specify "erlang versions" do
// 284:     versions = %w[R16B R15B03-1 R15B03 R15B02 R15B01 R14B04 R14B03
// 285:                   R14B02 R14B01 R14B R13B04 R13B03 R13B02-1].reverse
// 286:     expect(versions.sort_by { |v| described_class.new(v) }).to eq(versions)
// 287:   end
// 288:
// 289:   specify "hash equality" do
// 290:     v1 = described_class.new("0.1.0")
// 291:     v2 = described_class.new("0.1.0")
// 292:     v3 = described_class.new("0.1.1")
// 293:
// 294:     expect(v1).to eql(v2)
// 295:     expect(v1).not_to eql(v3)
// 296:     expect(v1.hash).to eq(v2.hash)
// 297:     expect(v1.hash).not_to eq(v3.hash)
// 298:
// 299:     h = { v1 => :foo }
// 300:     expect(h[v2]).to eq(:foo)
// 301:   end
// 302:
// 303:   describe "::new" do
// 304:     it "parses a version from a string" do
// 305:       v = described_class.new("1.20")
// 306:       expect(v).not_to be_head
// 307:       expect(v.to_str).to eq("1.20")
// 308:     end
// 309:
// 310:     specify "HEAD with commit" do
// 311:       v = described_class.new("HEAD-abcdef")
// 312:       expect(v.commit).to eq("abcdef")
// 313:       expect(v.to_str).to eq("HEAD-abcdef")
// 314:     end
// 315:
// 316:     specify "HEAD without commit" do
// 317:       v = described_class.new("HEAD")
// 318:       expect(v.commit).to be_nil
// 319:       expect(v.to_str).to eq("HEAD")
// 320:     end
// 321:   end
// 322:
// 323:   describe "#detected_from_url?" do
// 324:     it "is false if created explicitly" do
// 325:       expect(described_class.new("1.0.0")).not_to be_detected_from_url
// 326:     end
// 327:
// 328:     it "is true if the version was detected from a URL" do
// 329:       version = described_class.detect("https://example.org/archive-1.0.0.tar.gz")
// 330:
// 331:       expect(version).to eq "1.0.0"
// 332:       expect(version).to be_detected_from_url
// 333:     end
// 334:   end
// 335:
// 336:   specify "#head?" do
// 337:     v1 = described_class.new("HEAD-abcdef")
// 338:     v2 = described_class.new("HEAD")
// 339:
// 340:     expect(v1).to be_head
// 341:     expect(v2).to be_head
// 342:   end
// 343:
// 344:   specify "#update_commit" do
// 345:     v1 = described_class.new("HEAD-abcdef")
// 346:     v2 = described_class.new("HEAD")
// 347:
// 348:     v1.update_commit("ffffff")
// 349:     expect(v1.commit).to eq("ffffff")
// 350:     expect(v1.to_str).to eq("HEAD-ffffff")
// 351:
// 352:     v2.update_commit("ffffff")
// 353:     expect(v2.commit).to eq("ffffff")
// 354:     expect(v2.to_str).to eq("HEAD-ffffff")
// 355:   end
// 356:
// 357:   describe "#major" do
// 358:     it "returns major version token" do
// 359:       expect(described_class.new("1").major).to eq Version::Token.create("1")
// 360:       expect(described_class.new("1.2").major).to eq Version::Token.create("1")
// 361:       expect(described_class.new("1.2.3").major).to eq Version::Token.create("1")
// 362:       expect(described_class.new("1.2.3alpha").major).to eq Version::Token.create("1")
// 363:       expect(described_class.new("1.2.3alpha4").major).to eq Version::Token.create("1")
// 364:       expect(described_class.new("1.2.3beta4").major).to eq Version::Token.create("1")
// 365:       expect(described_class.new("1.2.3pre4").major).to eq Version::Token.create("1")
// 366:       expect(described_class.new("1.2.3rc4").major).to eq Version::Token.create("1")
// 367:       expect(described_class.new("1.2.3-p4").major).to eq Version::Token.create("1")
// 368:     end
// 369:   end
// 370:
// 371:   describe "#minor" do
// 372:     it "returns minor version token" do
// 373:       expect(described_class.new("1").minor).to be_nil
// 374:       expect(described_class.new("1.2").minor).to eq Version::Token.create("2")
// 375:       expect(described_class.new("1.2.3").minor).to eq Version::Token.create("2")
// 376:       expect(described_class.new("1.2.3alpha").minor).to eq Version::Token.create("2")
// 377:       expect(described_class.new("1.2.3alpha4").minor).to eq Version::Token.create("2")
// 378:       expect(described_class.new("1.2.3beta4").minor).to eq Version::Token.create("2")
// 379:       expect(described_class.new("1.2.3pre4").minor).to eq Version::Token.create("2")
// 380:       expect(described_class.new("1.2.3rc4").minor).to eq Version::Token.create("2")
// 381:       expect(described_class.new("1.2.3-p4").minor).to eq Version::Token.create("2")
// 382:     end
// 383:   end
// 384:
// 385:   describe "#patch" do
// 386:     it "returns patch version token" do
// 387:       expect(described_class.new("1").patch).to be_nil
// 388:       expect(described_class.new("1.2").patch).to be_nil
// 389:       expect(described_class.new("1.2.3").patch).to eq Version::Token.create("3")
// 390:       expect(described_class.new("1.2.3alpha").patch).to eq Version::Token.create("3")
// 391:       expect(described_class.new("1.2.3alpha4").patch).to eq Version::Token.create("3")
// 392:       expect(described_class.new("1.2.3beta4").patch).to eq Version::Token.create("3")
// 393:       expect(described_class.new("1.2.3pre4").patch).to eq Version::Token.create("3")
// 394:       expect(described_class.new("1.2.3rc4").patch).to eq Version::Token.create("3")
// 395:       expect(described_class.new("1.2.3-p4").patch).to eq Version::Token.create("3")
// 396:     end
// 397:   end
// 398:
// 399:   describe "#major_minor" do
// 400:     it "returns major.minor version" do
// 401:       expect(described_class.new("1").major_minor).to eq described_class.new("1")
// 402:       expect(described_class.new("1.2").major_minor).to eq described_class.new("1.2")
// 403:       expect(described_class.new("1.2.3").major_minor).to eq described_class.new("1.2")
// 404:       expect(described_class.new("1.2.3alpha").major_minor).to eq described_class.new("1.2")
// 405:       expect(described_class.new("1.2.3alpha4").major_minor).to eq described_class.new("1.2")
// 406:       expect(described_class.new("1.2.3beta4").major_minor).to eq described_class.new("1.2")
// 407:       expect(described_class.new("1.2.3pre4").major_minor).to eq described_class.new("1.2")
// 408:       expect(described_class.new("1.2.3rc4").major_minor).to eq described_class.new("1.2")
// 409:       expect(described_class.new("1.2.3-p4").major_minor).to eq described_class.new("1.2")
// 410:     end
// 411:   end
// 412:
// 413:   describe "#major_minor_patch" do
// 414:     it "returns major.minor.patch version" do
// 415:       expect(described_class.new("1").major_minor_patch).to eq described_class.new("1")
// 416:       expect(described_class.new("1.2").major_minor_patch).to eq described_class.new("1.2")
// 417:       expect(described_class.new("1.2.3").major_minor_patch).to eq described_class.new("1.2.3")
// 418:       expect(described_class.new("1.2.3alpha").major_minor_patch).to eq described_class.new("1.2.3")
// 419:       expect(described_class.new("1.2.3alpha4").major_minor_patch).to eq described_class.new("1.2.3")
// 420:       expect(described_class.new("1.2.3beta4").major_minor_patch).to eq described_class.new("1.2.3")
// 421:       expect(described_class.new("1.2.3pre4").major_minor_patch).to eq described_class.new("1.2.3")
// 422:       expect(described_class.new("1.2.3rc4").major_minor_patch).to eq described_class.new("1.2.3")
// 423:       expect(described_class.new("1.2.3-p4").major_minor_patch).to eq described_class.new("1.2.3")
// 424:     end
// 425:   end
// 426:
// 427:   describe "::parse" do
// 428:     it "returns a NULL version when the URL cannot be parsed" do
// 429:       expect(described_class.parse("https://brew.sh/blah.tar")).to be_null
// 430:       expect(described_class.parse("foo")).to be_null
// 431:     end
// 432:   end
// 433:
// 434:   describe "::detect" do
// 435:     matcher :be_detected_from do |url, **specs|
// 436:       match do |expected|
// 437:         @detected = described_class.detect(url, **specs)
// 438:         @detected == expected
// 439:       end
// 440:
// 441:       failure_message do |expected|
// 442:         message = <<~EOS
// 443:           expected: %s
// 444:           detected: %s
// 445:         EOS
// 446:         format(message, expected, @detected)
// 447:       end
// 448:     end
// 449:
// 450:     specify "version all dots" do
// 451:       expect(described_class.new("1.14"))
// 452:         .to be_detected_from("https://brew.sh/foo.bar.la.1.14.zip")
// 453:     end
// 454:
// 455:     specify "version underscore separator" do
// 456:       expect(described_class.new("1.1"))
// 457:         .to be_detected_from("https://brew.sh/grc_1.1.tar.gz")
// 458:     end
// 459:
// 460:     specify "boost version style" do
// 461:       expect(described_class.new("1.39.0"))
// 462:         .to be_detected_from("https://brew.sh/boost_1_39_0.tar.bz2")
// 463:     end
// 464:
// 465:     specify "erlang version style" do
// 466:       expect(described_class.new("R13B"))
// 467:         .to be_detected_from("https://erlang.org/download/otp_src_R13B.tar.gz")
// 468:     end
// 469:
// 470:     specify "another erlang version style" do
// 471:       expect(described_class.new("R15B01"))
// 472:         .to be_detected_from("https://github.com/erlang/otp/tarball/OTP_R15B01")
// 473:     end
// 474:
// 475:     specify "yet another erlang version style" do
// 476:       expect(described_class.new("R15B03-1"))
// 477:         .to be_detected_from("https://github.com/erlang/otp/tarball/OTP_R15B03-1")
// 478:     end
// 479:
// 480:     specify "p7zip version style" do
// 481:       expect(described_class.new("9.04"))
// 482:         .to be_detected_from("https://kent.dl.sourceforge.net/sourceforge/p7zip/p7zip_9.04_src_all.tar.bz2")
// 483:     end
// 484:
// 485:     specify "new github style" do
// 486:       expect(described_class.new("1.1.4"))
// 487:         .to be_detected_from("https://github.com/sam-github/libnet/tarball/libnet-1.1.4")
// 488:     end
// 489:
// 490:     specify "codeload style" do
// 491:       expect(described_class.new("0.7.1"))
// 492:         .to be_detected_from("https://codeload.github.com/gsamokovarov/jump/tar.gz/v0.7.1")
// 493:     end
// 494:
// 495:     specify "gloox beta style" do
// 496:       expect(described_class.new("1.0-beta7"))
// 497:         .to be_detected_from("https://camaya.net/download/gloox-1.0-beta7.tar.bz2")
// 498:     end
// 499:
// 500:     specify "sphinx beta style" do
// 501:       expect(described_class.new("1.10-beta"))
// 502:         .to be_detected_from("http://sphinxsearch.com/downloads/sphinx-1.10-beta.tar.gz")
// 503:     end
// 504:
// 505:     specify "astyle version style" do
// 506:       expect(described_class.new("1.23"))
// 507:         .to be_detected_from("https://kent.dl.sourceforge.net/sourceforge/astyle/astyle_1.23_macosx.tar.gz")
// 508:     end
// 509:
// 510:     specify "version dos2unix" do
// 511:       expect(described_class.new("3.1"))
// 512:         .to be_detected_from("http://www.sfr-fresh.com/linux/misc/dos2unix-3.1.tar.gz")
// 513:     end
// 514:
// 515:     specify "version internal dash" do
// 516:       expect(described_class.new("1.1-2"))
// 517:         .to be_detected_from("https://brew.sh/foo-arse-1.1-2.tar.gz")
// 518:       expect(described_class.new("3.3.04-1"))
// 519:         .to be_detected_from("https://brew.sh/3.3.04-1.tar.gz")
// 520:       expect(described_class.new("1.2-20200102"))
// 521:         .to be_detected_from("https://brew.sh/v1.2-20200102.tar.gz")
// 522:       expect(described_class.new("3.6.6-0.2"))
// 523:         .to be_detected_from("https://brew.sh/v3.6.6-0.2.tar.gz")
// 524:     end
// 525:
// 526:     specify "version single digit" do
// 527:       expect(described_class.new("45"))
// 528:         .to be_detected_from("https://brew.sh/foo_bar.45.tar.gz")
// 529:     end
// 530:
// 531:     specify "noseparator single digit" do
// 532:       expect(described_class.new("45"))
// 533:         .to be_detected_from("https://brew.sh/foo_bar45.tar.gz")
// 534:     end
// 535:
// 536:     specify "version developer that hates us format" do
// 537:       expect(described_class.new("1.2.3"))
// 538:         .to be_detected_from("https://brew.sh/foo-bar-la.1.2.3.tar.gz")
// 539:     end
// 540:
// 541:     specify "version regular" do
// 542:       expect(described_class.new("1.21"))
// 543:         .to be_detected_from("https://brew.sh/foo_bar-1.21.tar.gz")
// 544:     end
// 545:
// 546:     specify "version sourceforge download" do
// 547:       expect(described_class.new("1.21"))
// 548:         .to be_detected_from("https://sourceforge.net/foo_bar-1.21.tar.gz/download")
// 549:       expect(described_class.new("1.21"))
// 550:         .to be_detected_from("https://sf.net/foo_bar-1.21.tar.gz/download")
// 551:     end
// 552:
// 553:     specify "version github" do
// 554:       expect(described_class.new("1.0.5"))
// 555:         .to be_detected_from("https://github.com/lloyd/yajl/tarball/1.0.5")
// 556:     end
// 557:
// 558:     specify "version github with high patch number" do
// 559:       expect(described_class.new("1.2.34"))
// 560:         .to be_detected_from("https://github.com/lloyd/yajl/tarball/v1.2.34")
// 561:     end
// 562:
// 563:     specify "yet another version" do
// 564:       expect(described_class.new("0.15.1b"))
// 565:         .to be_detected_from("https://brew.sh/mad-0.15.1b.tar.gz")
// 566:     end
// 567:
// 568:     specify "lame version style" do
// 569:       expect(described_class.new("398-2"))
// 570:         .to be_detected_from("https://kent.dl.sourceforge.net/sourceforge/lame/lame-398-2.tar.gz")
// 571:     end
// 572:
// 573:     specify "ruby version style" do
// 574:       expect(described_class.new("1.9.1-p243"))
// 575:         .to be_detected_from("ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.1-p243.tar.gz")
// 576:     end
// 577:
// 578:     specify "omega version style" do
// 579:       expect(described_class.new("0.80.2"))
// 580:         .to be_detected_from("http://www.alcyone.com/binaries/omega/omega-0.80.2-src.tar.gz")
// 581:     end
// 582:
// 583:     specify "rc style" do
// 584:       expect(described_class.new("1.2.2rc1"))
// 585:         .to be_detected_from("https://downloads.xiph.org/releases/vorbis/libvorbis-1.2.2rc1.tar.bz2")
// 586:     end
// 587:
// 588:     specify "dash rc style" do
// 589:       expect(described_class.new("1.8.0-rc1"))
// 590:         .to be_detected_from("https://ftp.mozilla.org/pub/mozilla.org/js/js-1.8.0-rc1.tar.gz")
// 591:     end
// 592:
// 593:     specify "angband version style" do
// 594:       expect(described_class.new("3.0.9b"))
// 595:         .to be_detected_from("http://rephial.org/downloads/3.0/angband-3.0.9b-src.tar.gz")
// 596:     end
// 597:
// 598:     specify "stable suffix" do
// 599:       expect(described_class.new("1.4.14b"))
// 600:         .to be_detected_from("https://www.monkey.org/~provos/libevent-1.4.14b-stable.tar.gz")
// 601:     end
// 602:
// 603:     specify "debian style" do
// 604:       expect(described_class.new("3.03"))
// 605:         .to be_detected_from("https://ftp.de.debian.org/debian/pool/main/s/sl/sl_3.03.orig.tar.gz")
// 606:     end
// 607:
// 608:     specify "debian style with letter suffix" do
// 609:       expect(described_class.new("1.01b"))
// 610:         .to be_detected_from("https://ftp.de.debian.org/debian/pool/main/m/mmv/mmv_1.01b.orig.tar.gz")
// 611:     end
// 612:
// 613:     specify "debian style dotless" do
// 614:       expect(described_class.new("1"))
// 615:         .to be_detected_from("https://deb.debian.org/debian/pool/main/e/example/example_1.orig.tar.gz")
// 616:       expect(described_class.new("20040914"))
// 617:         .to be_detected_from("https://deb.debian.org/debian/pool/main/e/example/example_20040914.orig.tar.gz")
// 618:     end
// 619:
// 620:     specify "bottle style" do
// 621:       expect(described_class.new("4.8.0"))
// 622:         .to be_detected_from("https://homebrew.bintray.com/bottles/qt-4.8.0.lion.bottle.tar.gz")
// 623:     end
// 624:
// 625:     specify "versioned bottle style" do
// 626:       expect(described_class.new("4.8.1"))
// 627:         .to be_detected_from("https://homebrew.bintray.com/bottles/qt-4.8.1.lion.bottle.1.tar.gz")
// 628:     end
// 629:
// 630:     specify "erlang bottle style" do
// 631:       expect(described_class.new("R15B"))
// 632:         .to be_detected_from("https://homebrew.bintray.com/bottles/erlang-R15B.lion.bottle.tar.gz")
// 633:     end
// 634:
// 635:     specify "another erlang bottle style" do
// 636:       expect(described_class.new("R15B01"))
// 637:         .to be_detected_from("https://homebrew.bintray.com/bottles/erlang-R15B01.mountain_lion.bottle.tar.gz")
// 638:     end
// 639:
// 640:     specify "yet another erlang bottle style" do
// 641:       expect(described_class.new("R15B03-1"))
// 642:         .to be_detected_from("https://homebrew.bintray.com/bottles/erlang-R15B03-1.mountainlion.bottle.tar.gz")
// 643:     end
// 644:
// 645:     specify "imagemagick style" do
// 646:       expect(described_class.new("6.7.5-7"))
// 647:         .to be_detected_from("https://downloads.sf.net/project/machomebrew/mirror/ImageMagick-6.7.5-7.tar.bz2")
// 648:     end
// 649:
// 650:     specify "imagemagick bottle style" do
// 651:       expect(described_class.new("6.7.5-7"))
// 652:         .to be_detected_from("https://homebrew.bintray.com/bottles/imagemagick-6.7.5-7.lion.bottle.tar.gz")
// 653:     end
// 654:
// 655:     specify "imagemagick versioned bottle style" do
// 656:       expect(described_class.new("6.7.5-7"))
// 657:         .to be_detected_from("https://homebrew.bintray.com/bottles/imagemagick-6.7.5-7.lion.bottle.1.tar.gz")
// 658:     end
// 659:
// 660:     specify "date-based version style" do
// 661:       expect(described_class.new("2017-04-17"))
// 662:         .to be_detected_from("https://brew.sh/dada-v2017-04-17.tar.gz")
// 663:     end
// 664:
// 665:     specify "unstable version style" do
// 666:       expect(described_class.new("1.3.0-beta.1"))
// 667:         .to be_detected_from("https://registry.npmjs.org/@angular/cli/-/cli-1.3.0-beta.1.tgz")
// 668:       expect(described_class.new("2.074.0-beta1"))
// 669:         .to be_detected_from("https://github.com/dlang/dmd/archive/v2.074.0-beta1.tar.gz")
// 670:       expect(described_class.new("2.074.0-rc1"))
// 671:         .to be_detected_from("https://github.com/dlang/dmd/archive/v2.074.0-rc1.tar.gz")
// 672:       expect(described_class.new("5.0.0-alpha10"))
// 673:         .to be_detected_from(
// 674:           "https://github.com/premake/premake-core/releases/download/v5.0.0-alpha10/premake-5.0.0-alpha10-src.zip",
// 675:         )
// 676:     end
// 677:
// 678:     specify "jenkins version style" do
// 679:       expect(described_class.new("1.486"))
// 680:         .to be_detected_from("https://mirrors.jenkins-ci.org/war/1.486/jenkins.war")
// 681:       expect(described_class.new("0.10.11"))
// 682:         .to be_detected_from("https://github.com/hechoendrupal/DrupalConsole/releases/download/0.10.11/drupal.phar")
// 683:     end
// 684:
// 685:     specify "char prefixed, url-only version style" do
// 686:       expect(described_class.new("1.9.293"))
// 687:         .to be_detected_from("https://github.com/clojure/clojurescript/releases/download/r1.9.293/cljs.jar")
// 688:       expect(described_class.new("0.6.1"))
// 689:         .to be_detected_from("https://github.com/fibjs/fibjs/releases/download/v0.6.1/fullsrc.zip")
// 690:       expect(described_class.new("1.9"))
// 691:         .to be_detected_from("https://wwwlehre.dhbw-stuttgart.de/~sschulz/WORK/E_DOWNLOAD/V_1.9/E.tgz")
// 692:     end
// 693:
// 694:     specify "GitHub release tag takes precedence over asset filename" do
// 695:       url = "https://github.com/dvorka-oss/hstr/releases/download/v3.2/hstr-3.2.0-tarball.tgz"
// 696:
// 697:       expect(described_class.detect(url).to_s).to eq("3.2")
// 698:     end
// 699:
// 700:     specify "w.x.y.z url-only version style" do
// 701:       expect(described_class.new("2.3.2.0"))
// 702:         .to be_detected_from("https://github.com/JustArchi/ArchiSteamFarm/releases/download/2.3.2.0/ASF.zip")
// 703:       expect(described_class.new("1.7.5.2"))
// 704:         .to be_detected_from("https://people.gnome.org/~newren/eg/download/1.7.5.2/eg")
// 705:     end
// 706:
// 707:     specify "dash version style" do
// 708:       expect(described_class.new("3.4"))
// 709:         .to be_detected_from("https://www.antlr.org/download/antlr-3.4-complete.jar")
// 710:       expect(described_class.new("9.2"))
// 711:         .to be_detected_from("https://cdn.nuxeo.com/nuxeo-9.2/nuxeo-server-9.2-tomcat.zip")
// 712:       expect(described_class.new("0.181"))
// 713:         .to be_detected_from(
// 714:           "https://search.maven.org/remotecontent?filepath=" \
// 715:           "com/facebook/presto/presto-cli/0.181/presto-cli-0.181-executable.jar",
// 716:         )
// 717:       expect(described_class.new("1.2.3"))
// 718:         .to be_detected_from(
// 719:           "https://search.maven.org/remotecontent?filepath=org/apache/orc/orc-tools/1.2.3/orc-tools-1.2.3-uber.jar",
// 720:         )
// 721:     end
// 722:
// 723:     specify "apache version style" do
// 724:       expect(described_class.new("1.2.0-rc2"))
// 725:         .to be_detected_from(
// 726:           "https://www.apache.org/dyn/closer.cgi?path=/cassandra/1.2.0/apache-cassandra-1.2.0-rc2-bin.tar.gz",
// 727:         )
// 728:     end
// 729:
// 730:     specify "jpeg version style" do
// 731:       expect(described_class.new("8d"))
// 732:         .to be_detected_from("https://www.ijg.org/files/jpegsrc.v8d.tar.gz")
// 733:     end
// 734:
// 735:     specify "ghc version style" do
// 736:       expect(described_class.new("7.0.4"))
// 737:         .to be_detected_from("https://www.haskell.org/ghc/dist/7.0.4/ghc-7.0.4-x86_64-apple-darwin.tar.bz2")
// 738:       expect(described_class.new("7.0.4"))
// 739:         .to be_detected_from("https://www.haskell.org/ghc/dist/7.0.4/ghc-7.0.4-i386-apple-darwin.tar.bz2")
// 740:     end
// 741:
// 742:     specify "pypy version style" do
// 743:       expect(described_class.new("1.4.1"))
// 744:         .to be_detected_from("https://pypy.org/download/pypy-1.4.1-osx.tar.bz2")
// 745:     end
// 746:
// 747:     specify "openssl version style" do
// 748:       expect(described_class.new("0.9.8s"))
// 749:         .to be_detected_from("https://www.openssl.org/source/openssl-0.9.8s.tar.gz")
// 750:     end
// 751:
// 752:     specify "xaw3d version style" do
// 753:       expect(described_class.new("1.5E"))
// 754:         .to be_detected_from("ftp://ftp.visi.com/users/hawkeyd/X/Xaw3d-1.5E.tar.gz")
// 755:     end
// 756:
// 757:     specify "assimp version style" do
// 758:       expect(described_class.new("2.0.863"))
// 759:         .to be_detected_from("https://downloads.sourceforge.net/project/assimp/assimp-2.0/assimp--2.0.863-sdk.zip")
// 760:     end
// 761:
// 762:     specify "cmucl version style" do
// 763:       expect(described_class.new("20c"))
// 764:         .to be_detected_from(
// 765:           "https://common-lisp.net/project/cmucl/downloads/release/20c/cmucl-20c-x86-darwin.tar.bz2",
// 766:         )
// 767:     end
// 768:
// 769:     specify "fann version style" do
// 770:       expect(described_class.new("2.1.0beta"))
// 771:         .to be_detected_from("https://downloads.sourceforge.net/project/fann/fann/2.1.0beta/fann-2.1.0beta.zip")
// 772:     end
// 773:
// 774:     specify "grads version style" do
// 775:       expect(described_class.new("2.0.1"))
// 776:         .to be_detected_from("ftp://iges.org/grads/2.0/grads-2.0.1-bin-darwin9.8-intel.tar.gz")
// 777:     end
// 778:
// 779:     specify "haxe version style" do
// 780:       expect(described_class.new("2.08"))
// 781:         .to be_detected_from("https://haxe.org/file/haxe-2.08-osx.tar.gz")
// 782:     end
// 783:
// 784:     specify "imap version style" do
// 785:       expect(described_class.new("2007f"))
// 786:         .to be_detected_from("ftp://ftp.cac.washington.edu/imap/imap-2007f.tar.gz")
// 787:     end
// 788:
// 789:     specify "suite3270 version style" do
// 790:       expect(described_class.new("3.3.12ga7"))
// 791:         .to be_detected_from(
// 792:           "https://downloads.sourceforge.net/project/x3270/x3270/3.3.12ga7/suite3270-3.3.12ga7-src.tgz",
// 793:         )
// 794:     end
// 795:
// 796:     specify "wwwoffle version style" do
// 797:       expect(described_class.new("2.9h"))
// 798:         .to be_detected_from("http://www.gedanken.demon.co.uk/download-wwwoffle/wwwoffle-2.9h.tgz")
// 799:     end
// 800:
// 801:     specify "synergy version style" do
// 802:       expect(described_class.new("1.3.6p2"))
// 803:         .to be_detected_from("http://synergy.googlecode.com/files/synergy-1.3.6p2-MacOSX-Universal.zip")
// 804:     end
// 805:
// 806:     specify "fontforge version style" do
// 807:       expect(described_class.new("20120731"))
// 808:         .to be_detected_from(
// 809:           "https://downloads.sourceforge.net/project/fontforge/fontforge-source/fontforge_full-20120731-b.tar.bz2",
// 810:         )
// 811:     end
// 812:
// 813:     specify "ezlupdate version style" do
// 814:       expect(described_class.new("2011.10"))
// 815:         .to be_detected_from(
// 816:           "https://github.com/downloads/ezsystems" \
// 817:           "/ezpublish-legacy/ezpublish_community_project-2011.10-with_ezc.tar.bz2",
// 818:         )
// 819:     end
// 820:
// 821:     specify "aespipe version style" do
// 822:       expect(described_class.new("2.4c"))
// 823:         .to be_detected_from("http://loop-aes.sourceforge.net/aespipe/aespipe-v2.4c.tar.bz2")
// 824:     end
// 825:
// 826:     specify "win version style" do
// 827:       expect(described_class.new("0.9.17"))
// 828:         .to be_detected_from("https://ftpmirror.gnu.org/libmicrohttpd/libmicrohttpd-0.9.17-w32.zip")
// 829:       expect(described_class.new("1.29"))
// 830:         .to be_detected_from("https://ftpmirror.gnu.org/libidn/libidn-1.29-win64.zip")
// 831:     end
// 832:
// 833:     specify "breseq version style" do
// 834:       expect(described_class.new("0.35.1"))
// 835:         .to be_detected_from(
// 836:           "https://github.com/barricklab/breseq" \
// 837:           "/releases/download/v0.35.1/breseq-0.35.1.Source.tar.gz",
// 838:         )
// 839:     end
// 840:
// 841:     specify "wildfly version style" do
// 842:       expect(described_class.new("20.0.1"))
// 843:         .to be_detected_from("https://download.jboss.org/wildfly/20.0.1.Final/wildfly-20.0.1.Final.tar.gz")
// 844:     end
// 845:
// 846:     specify "trinity version style" do
// 847:       expect(described_class.new("2.10.0"))
// 848:         .to be_detected_from(
// 849:           "https://github.com/trinityrnaseq/trinityrnaseq" \
// 850:           "/releases/download/v2.10.0/trinityrnaseq-v2.10.0.FULL.tar.gz",
// 851:         )
// 852:     end
// 853:
// 854:     specify "with arch" do
// 855:       expect(described_class.new("4.0.18-1"))
// 856:         .to be_detected_from("https://ftpmirror.gnu.org/mtools/mtools-4.0.18-1.i686.rpm")
// 857:       expect(described_class.new("5.5.7-5"))
// 858:         .to be_detected_from("https://ftpmirror.gnu.org/autogen/autogen-5.5.7-5.i386.rpm")
// 859:       expect(described_class.new("2.8"))
// 860:         .to be_detected_from("https://ftpmirror.gnu.org/libtasn1/libtasn1-2.8-x86.zip")
// 861:       expect(described_class.new("2.8"))
// 862:         .to be_detected_from("https://ftpmirror.gnu.org/libtasn1/libtasn1-2.8-x64.zip")
// 863:       expect(described_class.new("4.0.18"))
// 864:         .to be_detected_from("https://ftpmirror.gnu.org/mtools/mtools_4.0.18_i386.deb")
// 865:     end
// 866:
// 867:     specify "opam version" do
// 868:       expect(described_class.new("2.18.3"))
// 869:         .to be_detected_from("https://opam.ocaml.org/archives/lablgtk.2.18.3+opam.tar.gz")
// 870:       expect(described_class.new("1.9"))
// 871:         .to be_detected_from("https://opam.ocaml.org/archives/sha.1.9+opam.tar.gz")
// 872:       expect(described_class.new("0.99.2"))
// 873:         .to be_detected_from("https://opam.ocaml.org/archives/ppx_tools.0.99.2+opam.tar.gz")
// 874:       expect(described_class.new("1.0.2"))
// 875:         .to be_detected_from("https://opam.ocaml.org/archives/easy-format.1.0.2+opam.tar.gz")
// 876:     end
// 877:
// 878:     specify "no extension version" do
// 879:       expect(described_class.new("1.8.12"))
// 880:         .to be_detected_from("https://waf.io/waf-1.8.12")
// 881:       expect(described_class.new("0.7.1"))
// 882:         .to be_detected_from("https://codeload.github.com/gsamokovarov/jump/tar.gz/v0.7.1")
// 883:       expect(described_class.new("0.9.1234"))
// 884:         .to be_detected_from("https://my.datomic.com/downloads/free/0.9.1234")
// 885:       expect(described_class.new("1.2.3"))
// 886:         .to be_detected_from("https://my.datomic.com/downloads/free/1.2.3")
// 887:     end
// 888:
// 889:     specify "dash separated version" do
// 890:       expect(described_class.new("6-20151227"))
// 891:         .to be_detected_from("ftp://gcc.gnu.org/pub/gcc/snapshots/6-20151227/gcc-6-20151227.tar.bz2")
// 892:     end
// 893:
// 894:     specify "semver in middle of URL" do
// 895:       expect(described_class.new("7.1.10"))
// 896:         .to be_detected_from("https://php.net/get/php-7.1.10.tar.gz/from/this/mirror")
// 897:     end
// 898:
// 899:     specify "from tag" do
// 900:       expect(described_class.new("1.2.3"))
// 901:         .to be_detected_from("https://github.com/foo/bar.git", tag: "v1.2.3-stable")
// 902:     end
// 903:
// 904:     specify "beta from tag" do
// 905:       expect(described_class.new("1.2.3-beta1"))
// 906:         .to be_detected_from("https://github.com/foo/bar.git", tag: "v1.2.3-beta1")
// 907:     end
// 908:   end
// 909:
// 910:   describe Pathname do
// 911:     specify "#version" do
// 912:       d = HOMEBREW_CELLAR/"foo-0.1.9"
// 913:       d.mkpath
// 914:       expect(d.version).to eq(Version.new("0.1.9"))
// 915:     end
// 916:   end
// 917: end
