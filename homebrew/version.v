module homebrew

import json2
import math
import net.urllib
import regex
import strconv

// Translated from Homebrew/brew `version.rb`.

// VersionTokenKind mirrors the concrete Token subclasses in version.rb.
pub enum VersionTokenKind {
	null_token
	alpha
	beta
	rc
	pre
	patch
	post
	numeric
	string_token
}

// VersionToken is a typed representation of a Ruby Version::Token.
pub struct VersionToken {
pub:
	kind   VersionTokenKind
	text   string
	number int
}

// null_version_token represents Version::NULL_TOKEN.
pub fn null_version_token() VersionToken {
	return VersionToken{
		kind: .null_token
	}
}

// token_create translates Token.create and rejects values outside SCAN_PATTERN.
pub fn token_create(value string) !VersionToken {
	lower := value.to_lower()
	if lower.starts_with('alpha') && all_digits(lower[5..]) {
		return composite_token(.alpha, value)
	}
	if lower.starts_with('a') && lower.len > 1 && all_digits(lower[1..]) {
		return composite_token(.alpha, value)
	}
	if lower.starts_with('beta') && all_digits(lower[4..]) {
		return composite_token(.beta, value)
	}
	if lower.starts_with('b') && lower.len > 1 && all_digits(lower[1..]) {
		return composite_token(.beta, value)
	}
	if lower.starts_with('rc') && all_digits(lower[2..]) {
		return composite_token(.rc, value)
	}
	if lower.starts_with('pre') && all_digits(lower[3..]) {
		return composite_token(.pre, value)
	}
	if lower.starts_with('p') && all_digits(lower[1..]) {
		return composite_token(.patch, value)
	}
	if lower.starts_with('.post') && lower.len > 5 && all_digits(lower[5..]) {
		return composite_token(.post, value)
	}
	if all_digits(value) && value != '' {
		return VersionToken{
			kind: .numeric
			number: strconv.atoi(value)!
		}
	}
	if all_letters(value) && value != '' {
		return VersionToken{
			kind: .string_token
			text: value
		}
	}
	return error('Cannot find a matching token pattern for `${value}`')
}

// token_from_string translates the nil-or-string cases of Token.from.
pub fn token_from_string(value ?string) !VersionToken {
	if token_value := value {
		return token_create(token_value)
	}
	return null_version_token()
}

fn composite_token(kind VersionTokenKind, value string) VersionToken {
	mut revision := 0
	for index, character in value {
		if character.is_digit() {
			revision = strconv.atoi(value[index..]) or { 0 }
			break
		}
	}
	return VersionToken{
		kind: kind
		text: value
		number: revision
	}
}

fn all_digits(value string) bool {
	for character in value {
		if !character.is_digit() {
			return false
		}
	}
	return true
}

fn all_letters(value string) bool {
	for character in value {
		if !character.is_letter() {
			return false
		}
	}
	return true
}

// compare_tokens translates every Token#<=> implementation.
pub fn compare_tokens(left VersionToken, right VersionToken) int {
	if left.kind == right.kind {
		return match left.kind {
			.null_token {
				0
			}
			.numeric {
				compare_ints(left.number, right.number)
			}
			.alpha, .beta, .rc, .pre, .patch, .post {
				compare_ints(left.number, right.number)
			}
			.string_token {
				compare_strings(left.text, right.text)
			}
		}
	}
	if left.kind == .null_token {
		return match right.kind {
			.numeric {
				if right.number == 0 {
					0
				} else {
					-1
				}
			}
			.alpha, .beta, .pre, .rc {
				1
			}
			else {
				-1
			}
		}
	}
	if right.kind == .null_token {
		return -compare_tokens(right, left)
	}
	if left.kind == .numeric {
		return 1
	}
	if right.kind == .numeric {
		return -1
	}
	match left.kind {
		.alpha {
			if right.kind in [.beta, .rc, .pre, .patch, .post] {
				return -1
			}
		}
		.beta {
			if right.kind == .alpha {
				return 1
			}
			if right.kind in [.pre, .rc, .patch, .post] {
				return -1
			}
		}
		.pre {
			if right.kind in [.alpha, .beta] {
				return 1
			}
			if right.kind in [.rc, .patch, .post] {
				return -1
			}
		}
		.rc {
			if right.kind in [.alpha, .beta, .pre] {
				return 1
			}
			if right.kind in [.patch, .post] {
				return -1
			}
		}
		.patch, .post {
			if right.kind in [.alpha, .beta, .rc, .pre] {
				return 1
			}
		}
		else {}
	}
	return compare_strings(left.to_s(), right.to_s())
}

fn compare_ints(left int, right int) int {
	return if left < right {
		-1
	} else if left > right {
		1
	} else {
		0
	}
}

fn compare_strings(left string, right string) int {
	return if left < right {
		-1
	} else if left > right {
		1
	} else {
		0
	}
}

// equals implements Comparable equality for tokens.
pub fn (token VersionToken) equals(other VersionToken) bool {
	return compare_tokens(token, other) == 0
}

// to_s translates Token#to_str and Token#to_s.
pub fn (token VersionToken) to_s() string {
	return match token.kind {
		.null_token { '' }
		.numeric { token.number.str() }
		else { token.text }
	}
}

// inspect translates the Token and NullToken inspect methods.
pub fn (token VersionToken) inspect() string {
	if token.kind == .null_token {
		return '#<Version::NullToken>'
	}
	class_name := match token.kind {
		.alpha { 'AlphaToken' }
		.beta { 'BetaToken' }
		.rc { 'RCToken' }
		.pre { 'PreToken' }
		.patch { 'PatchToken' }
		.post { 'PostToken' }
		.numeric { 'NumericToken' }
		.string_token { 'StringToken' }
		.null_token { 'NullToken' }
	}
	value := if token.kind == .numeric { token.number.str() } else { '"${token.text}"' }
	return '#<Version::${class_name} ${value}>'
}

// numeric translates Token#numeric?.
pub fn (token VersionToken) numeric() bool {
	return token.kind == .numeric
}

// is_null translates Token#null?.
pub fn (token VersionToken) is_null() bool {
	return token.kind == .null_token
}

// revision translates CompositeToken#rev.
pub fn (token VersionToken) revision() int {
	return token.number
}

// Version is the V equivalent of Homebrew's Version class.
pub struct Version {
mut:
	value          string
	null_value     bool
	detected_value bool
}

// VersionNilComparisonOperand represents Ruby nil at the typed comparison boundary.
pub struct VersionNilComparisonOperand {}

// VersionForeignComparisonOperand represents an object that Token.from/Version#<=> cannot coerce.
pub struct VersionForeignComparisonOperand {}

// TokenComparisonOperand is the exact Token.from operand domain exercised by Token#<=>.
pub type TokenComparisonOperand = Version
	| VersionForeignComparisonOperand
	| VersionNilComparisonOperand
	| VersionToken
	| int
	| string

// VersionComparisonOperand is the exact operand domain accepted by Version#<=>.
pub type VersionComparisonOperand = Version
	| VersionForeignComparisonOperand
	| VersionNilComparisonOperand
	| VersionToken
	| int
	| string

// new_version translates Version#initialize.
pub fn new_version(value string) !Version {
	return new_version_with_detection(value, false)
}

// new_version_with_detection preserves the detected_from_url keyword argument.
pub fn new_version_with_detection(value string, detected_from_url bool) !Version {
	if value.trim_space() == '' {
		return error('Version must not be empty')
	}
	return Version{
		value: value
		detected_value: detected_from_url
	}
}

// null_version represents Version::NULL.
pub fn null_version() Version {
	return Version{
		null_value: true
	}
}

// token_from_operand translates Token.from, including nil/null and uncoercible objects.
pub fn token_from_operand(operand TokenComparisonOperand) ?VersionToken {
	return match operand {
		VersionNilComparisonOperand { null_version_token() }
		VersionForeignComparisonOperand { none }
		VersionToken { operand }
		Version {
			if operand.is_null() {
				null_version_token()
			} else {
				none
			}
		}
		string { token_create(operand) or { return none } }
		int { token_create(operand.str()) or { return none } }
	}
}

// compare_token_operand translates Token#<=> before concrete token ordering.
pub fn compare_token_operand(token VersionToken, operand TokenComparisonOperand) ?int {
	other := token_from_operand(operand) or { return none }
	return compare_tokens(token, other)
}

// token_operand_relation translates Comparable's relational operators and their nil-result error.
pub fn token_operand_relation(token VersionToken, relation string, operand TokenComparisonOperand) !bool {
	comparison := compare_token_operand(token, operand) or {
		return error('comparison of Version::Token with foreign operand failed')
	}
	return comparison_relation(comparison, relation)
}

// compare_version_operand translates every coercion and nil outcome in Version#<=>.
pub fn compare_version_operand(version Version, operand VersionComparisonOperand) ?int {
	other := match operand {
		VersionNilComparisonOperand {
			return 1
		}
		VersionForeignComparisonOperand {
			return none
		}
		string {
			if operand == '' {
				if version.is_null() {
					return none
				}
				return 1
			}
			new_version(operand) or { return none }
		}
		int { new_version(operand.str()) or { return none } }
		VersionToken {
			if operand.is_null() {
				if version.is_null() {
					return none
				}
				return 1
			}
			new_version(operand.to_s()) or { return none }
		}
		Version {
			if operand.is_null() {
				if version.is_null() {
					return none
				}
				return 1
			}
			operand
		}
	}
	if version.is_null() {
		return -1
	}
	return version.compare_to(other)
}

// version_operand_relation translates Comparable's relational operators and their nil-result error.
pub fn version_operand_relation(version Version, relation string, operand VersionComparisonOperand) !bool {
	comparison := compare_version_operand(version, operand) or {
		return error('comparison of Version with foreign operand failed')
	}
	return comparison_relation(comparison, relation)
}

fn comparison_relation(comparison int, relation string) !bool {
	return match relation {
		'>' { comparison > 0 }
		'>=' { comparison >= 0 }
		'<' { comparison < 0 }
		'<=' { comparison <= 0 }
		'==' { comparison == 0 }
		'!=' { comparison != 0 }
		else {
			return error('Unknown comparator: ${relation}')
		}
	}
}

// detected_from_url translates detected_from_url?.
pub fn (version Version) detected_from_url() bool {
	return version.detected_value
}

// head translates head?.
pub fn (version Version) head() bool {
	return !version.null_value && (version.value == 'HEAD' || version.value.starts_with('HEAD-'))
}

// commit translates the HEAD commit capture.
pub fn (version Version) commit() ?string {
	if version.value.starts_with('HEAD-') {
		return version.value[5..]
	}
	return none
}

// update_commit translates update_commit and rejects non-HEAD versions.
pub fn (mut version Version) update_commit(commit ?string) ! {
	if !version.head() {
		return error('Cannot update commit for non-HEAD version.')
	}
	if commit_value := commit {
		version.value = 'HEAD-${commit_value}'
	} else {
		version.value = 'HEAD'
	}
}

// is_null translates Version#null?.
pub fn (version Version) is_null() bool {
	return version.null_value
}

// compare translates Version#compare.
pub fn (version Version) compare(comparator string, other Version) !bool {
	comparison := version.compare_to(other)
	return match comparator {
		'>=' { comparison >= 0 }
		'>' { comparison > 0 }
		'<' { comparison < 0 }
		'<=' { comparison <= 0 }
		'==' { version.equals(other) }
		'!=' { !version.equals(other) }
		else {
			return error('Unknown comparator: ${comparator}')
		}
	}
}

// compare_to translates Version#<=> for typed Version operands.
pub fn (version Version) compare_to(other Version) int {
	if other.null_value {
		return if version.null_value { 0 } else { 1 }
	}
	if version.null_value {
		return -1
	}
	if version.value == other.value {
		return 0
	}
	if version.head() && !other.head() {
		return 1
	}
	if !version.head() && other.head() {
		return -1
	}
	if version.head() && other.head() {
		return 0
	}
	left_tokens := version.tokens()
	right_tokens := other.tokens()
	maximum := if left_tokens.len > right_tokens.len { left_tokens.len } else { right_tokens.len }
	mut left_index := 0
	mut right_index := 0
	for left_index < maximum {
		left := if left_index < left_tokens.len {
			left_tokens[left_index]
		} else {
			null_version_token()
		}
		right := if right_index < right_tokens.len {
			right_tokens[right_index]
		} else {
			null_version_token()
		}
		if left.equals(right) {
			left_index++
			right_index++
			continue
		}
		if left.numeric() && !right.numeric() {
			if compare_tokens(left, null_version_token()) > 0 {
				return 1
			}
			left_index++
		} else if !left.numeric() && right.numeric() {
			if compare_tokens(right, null_version_token()) > 0 {
				return -1
			}
			right_index++
		} else {
			return compare_tokens(left, right)
		}
	}
	return 0
}

// equals preserves Version::NULL's deliberate non-equality with itself.
pub fn (version Version) equals(other Version) bool {
	return !version.null_value && version.compare_to(other) == 0
}

// major translates Version#major.
pub fn (version Version) major() ?VersionToken {
	if version.null_value {
		return null_version_token()
	}
	tokens := version.tokens()
	if tokens.len == 0 {
		return none
	}
	return tokens[0]
}

// minor translates Version#minor.
pub fn (version Version) minor() ?VersionToken {
	if version.null_value {
		return null_version_token()
	}
	tokens := version.tokens()
	if tokens.len < 2 {
		return none
	}
	return tokens[1]
}

// patch translates Version#patch.
pub fn (version Version) patch() ?VersionToken {
	if version.null_value {
		return null_version_token()
	}
	tokens := version.tokens()
	if tokens.len < 3 {
		return none
	}
	return tokens[2]
}

// major_minor translates Version#major_minor.
pub fn (version Version) major_minor() Version {
	return version.leading_components(2)
}

// major_minor_patch translates Version#major_minor_patch.
pub fn (version Version) major_minor_patch() Version {
	return version.leading_components(3)
}

fn (version Version) leading_components(count int) Version {
	if version.null_value {
		return version
	}
	tokens := version.tokens()
	limit := if tokens.len < count { tokens.len } else { count }
	if limit == 0 {
		return null_version()
	}
	mut components := []string{cap: limit}
	for token in tokens[..limit] {
		components << token.to_s()
	}
	return new_version(components.join('.')) or { null_version() }
}

// hash translates Version#hash using a stable FNV-1a hash of the stored value.
pub fn (version Version) hash() u64 {
	return hash_string(version.to_s())
}

fn hash_string(value string) u64 {
	mut result := u64(14695981039346656037)
	for character in value.bytes() {
		result = (result ^ u64(character)) * u64(1099511628211)
	}
	return result
}

// to_f translates Ruby's numeric-prefix String#to_f behavior.
pub fn (version Version) to_f() f64 {
	if version.null_value {
		return math.nan()
	}
	prefix := numeric_prefix(version.value, true)
	return strconv.atof64(prefix) or { 0.0 }
}

// to_i translates Ruby's numeric-prefix String#to_i behavior.
pub fn (version Version) to_i() int {
	if version.null_value {
		return 0
	}
	prefix := numeric_prefix(version.value, false)
	return strconv.atoi(prefix) or { 0 }
}

fn numeric_prefix(value string, allow_decimal bool) string {
	mut index := 0
	for index < value.len && value[index].is_space() {
		index++
	}
	start := index
	if index < value.len && (value[index] == `+` || value[index] == `-`) {
		index++
	}
	mut digits := 0
	for index < value.len && value[index].is_digit() {
		index++
		digits++
	}
	if allow_decimal && index < value.len && value[index] == `.` {
		index++
		for index < value.len && value[index].is_digit() {
			index++
			digits++
		}
	}
	return if digits == 0 { '0' } else { value[start..index] }
}

// to_str translates the implicit conversion and errors for Version::NULL.
pub fn (version Version) to_str() !string {
	if version.null_value {
		return error('undefined method `to_str` for Version:NULL')
	}
	return version.value
}

// to_s translates the explicit string representation.
pub fn (version Version) to_s() string {
	return if version.null_value { '' } else { version.value }
}

// to_json translates the Ruby JSON representation.
pub fn (version Version) to_json() string {
	if version.null_value {
		return 'null'
	}
	return json2.encode(version.value, escape_unicode: true)
}

// responds_to_to_str translates the special respond_to? handling.
pub fn (version Version) responds_to_to_str() bool {
	return !version.null_value
}

// inspect translates Version#inspect.
pub fn (version Version) inspect() string {
	return if version.null_value { '#<Version::NULL>' } else { '#<Version ${version.value}>' }
}

// version_string exposes the protected Ruby version reader as a typed option.
pub fn (version Version) version_string() ?string {
	if version.null_value {
		return none
	}
	return version.value
}

// tokens translates the SCAN_PATTERN scan and concrete token construction.
pub fn (version Version) tokens() []VersionToken {
	if version.null_value {
		return []
	}
	mut result := []VersionToken{}
	mut index := 0
	for index < version.value.len {
		rest := version.value[index..]
		lower := rest.to_lower()
		mut length := composite_length(lower)
		if length > 0 {
			result << token_create(rest[..length]) or { null_version_token() }
			index += length
			continue
		}
		if version.value[index].is_digit() {
			length = 1
			for index + length < version.value.len && version.value[index + length].is_digit() {
				length++
			}
			result << token_create(rest[..length]) or { null_version_token() }
			index += length
			continue
		}
		if version.value[index].is_letter() {
			length = 1
			for index + length < version.value.len && version.value[index + length].is_letter() {
				length++
			}
			result << token_create(rest[..length]) or { null_version_token() }
			index += length
			continue
		}
		index++
	}
	return result
}

fn composite_length(value string) int {
	if value.starts_with('alpha') {
		return 5 + following_digits(value, 5)
	}
	if value.starts_with('a') && value.len > 1 && value[1].is_digit() {
		return 1 + following_digits(value, 1)
	}
	if value.starts_with('beta') {
		return 4 + following_digits(value, 4)
	}
	if value.starts_with('b') && value.len > 1 && value[1].is_digit() {
		return 1 + following_digits(value, 1)
	}
	if value.starts_with('pre') {
		return 3 + following_digits(value, 3)
	}
	if value.starts_with('rc') {
		return 2 + following_digits(value, 2)
	}
	if value.starts_with('p') {
		return 1 + following_digits(value, 1)
	}
	if value.starts_with('.post') && value.len > 5 && value[5].is_digit() {
		return 5 + following_digits(value, 5)
	}
	return 0
}

fn following_digits(value string, start int) int {
	mut count := 0
	for start + count < value.len && value[start + count].is_digit() {
		count++
	}
	return count
}

// formula_optionally_versioned_pattern translates formula_optionally_versioned_regex.
pub fn formula_optionally_versioned_pattern(name string, full bool) string {
	escaped := regex_escape(name)
	return '${if full {
		'^'
	} else {
		''
	}}${escaped}(@\\d[\\d.]*)?${if full {
		'\$'
	} else {
		''
	}}'
}

fn regex_escape(value string) string {
	mut escaped := ''
	for character in value {
		if character in [`\\`, `.`, `+`, `*`, `?`, `^`, `$`, `(`, `)`, `[`, `]`, `{`, `}`, `|`] {
			escaped += '\\'
		}
		escaped += character.ascii_str()
	}
	return escaped
}

// detect_version translates Version.detect; a non-empty tag takes precedence over the URL.
pub fn detect_version(url string, tag string) Version {
	return parse_version(if tag == '' { url } else { tag }, true)
}

// parse_version translates the ordered VERSION_PARSERS table.
pub fn parse_version(specification string, detected_from_url bool) Version {
	mut spec := specification
	if detected_from_url {
		spec = urllib.query_unescape(spec) or { spec }
	}
	rules := detection_rules()
	for rule in rules {
		processed := if rule.use_url { spec } else { detection_stem(spec) }
		if captured := capture_version_rule(rule, processed) {
			value := if rule.underscores_to_dots { captured.replace('_', '.') } else { captured }
			return new_version_with_detection(value, detected_from_url) or { null_version() }
		}
	}
	return null_version()
}

enum VersionDetectionRuleKind {
	regular_expression
	architecture_suffix
	prerelease_suffix
}

struct VersionDetectionRule {
	pattern             string
	use_url             bool
	case_insensitive    bool
	underscores_to_dots bool
	kind                VersionDetectionRuleKind
	prerelease          string
}

fn detection_rules() []VersionDetectionRule {
	return [
		VersionDetectionRule{
			pattern: r'v?(\d{4}-\d{2}-\d{2})'
		},
		VersionDetectionRule{
			pattern: r'github\.com/.+/tarball/(?:v|[A-Za-z0-9_]+-)?((?:\d+[._-])+\d*)$'
			use_url: true
		},
		VersionDetectionRule{
			pattern: r'github\.com/.+/zipball/(?:v|[A-Za-z0-9_]+-)?((?:\d+[._-])+\d*)$'
			use_url: true
		},
		VersionDetectionRule{
			pattern: r'github\.com/.+/releases/download/[rvV]?_?(\d+(?:\.\d+)+)/'
			use_url: true
		},
		VersionDetectionRule{
			pattern: r'[_-]([Rr]\d+[AaBb]\d*(?:-\d+)?)'
		},
		VersionDetectionRule{
			pattern: r'((?:\d+_)+\d+)$'
			underscores_to_dots: true
		},
		VersionDetectionRule{
			pattern: r'[_-](\d+(?:\.\d+)+-\d+)(?:[._-][A-Za-z]+)?$'
		},
		VersionDetectionRule{
			pattern: r'[_-](\d+(?:\.\d+)+-[pP]\d+)(?:[._-][A-Za-z]+)?$'
		},
		VersionDetectionRule{
			pattern: r'[_-](\d+(?:\.\d+)+-[rR][cC]\d+)(?:[._-][A-Za-z]+)?$'
		},
		VersionDetectionRule{
			pattern: r'^v?(\d+(?:\.\d+)+(?:-\d+(?:\.\d+)*)+)'
		},
		VersionDetectionRule{
			pattern: r'[-v](\d+(?:\.\d+)*)$'
			use_url: true
		},
		VersionDetectionRule{
			pattern: r'-(\d+-\d+)'
		},
		VersionDetectionRule{
			pattern: r'-(\d+(?:\.\d+)*)$'
		},
		VersionDetectionRule{
			pattern: r'-(\d+(?:\.\d+)*(?:\.post\d+)?)$'
		},
		VersionDetectionRule{
			pattern: r'-(\d+(?:\.\d+)*(?:[abc]|rc)\d*)$'
			case_insensitive: true
		},
		VersionDetectionRule{
			pattern: r'-(\d+(?:\.\d+)*-alpha\d*)$'
			case_insensitive: true
		},
		VersionDetectionRule{
			pattern: r'-(\d+(?:\.\d+)*-beta\d*)$'
			case_insensitive: true
		},
		VersionDetectionRule{
			pattern: r'-(\d+(?:\.\d+)*-rc\d*)$'
			case_insensitive: true
		},
		VersionDetectionRule{
			pattern: r'-(\d+(?:\.\d+){1,2})-w(?:in)?\d+$'
			case_insensitive: true
		},
		VersionDetectionRule{
			pattern: r'\.(\d+(?:\.\d+){1,2})\+opam$'
		},
		VersionDetectionRule{
			kind: .architecture_suffix
		},
		VersionDetectionRule{
			pattern: r'[-.vV]?(\d+(?:\.\d+)+[-._]?alpha\.?\d{0,2})'
			kind: .prerelease_suffix
			prerelease: 'alpha'
		},
		VersionDetectionRule{
			pattern: r'[-.vV]?(\d+(?:\.\d+)+[-._]?beta\.?\d{0,2})'
			kind: .prerelease_suffix
			prerelease: 'beta'
		},
		VersionDetectionRule{
			pattern: r'[-.vV]?(\d+(?:\.\d+)+[-._]?pre\.?\d{0,2})'
			kind: .prerelease_suffix
			prerelease: 'pre'
		},
		VersionDetectionRule{
			pattern: r'[-.vV]?(\d+(?:\.\d+)+[-._]?rc\.?\d{0,2})'
			kind: .prerelease_suffix
			prerelease: 'rc'
		},
		VersionDetectionRule{
			pattern: r'(\d+(?:\.\d+)*)$'
		},
		VersionDetectionRule{
			pattern: r'[-vV](\d+(?:\.\d+)+[abc]?)[._-][A-Za-z]+$'
			case_insensitive: true
		},
		VersionDetectionRule{
			pattern: r'-(\d+(?:\.\d+)+)-'
		},
		VersionDetectionRule{
			pattern: r'_(\d+(?:\.\d+)*[abc]?)\.orig$'
			case_insensitive: true
		},
		VersionDetectionRule{
			pattern: r'-v?(\d[A-Za-z0-9.]+)'
		},
		VersionDetectionRule{
			pattern: r'_v?(\d[^_]+)'
		},
		VersionDetectionRule{
			pattern: r'/[rvV]?_?(\d+\.\d+(?:\.\d+){0,2})'
			use_url: true
		},
		VersionDetectionRule{
			pattern: r'\.v(\d+[a-z]?)'
			case_insensitive: true
		},
		VersionDetectionRule{
			pattern: r'[-.vV]?(\d+(?:\.\d+)+[-._]?alpha\.?\d{0,2})'
			use_url: true
			kind: .prerelease_suffix
			prerelease: 'alpha'
		},
		VersionDetectionRule{
			pattern: r'[-.vV]?(\d+(?:\.\d+)+[-._]?beta\.?\d{0,2})'
			use_url: true
			kind: .prerelease_suffix
			prerelease: 'beta'
		},
		VersionDetectionRule{
			pattern: r'[-.vV]?(\d+(?:\.\d+)+[-._]?pre\.?\d{0,2})'
			use_url: true
			kind: .prerelease_suffix
			prerelease: 'pre'
		},
		VersionDetectionRule{
			pattern: r'[-.vV]?(\d+(?:\.\d+)+[-._]?rc\.?\d{0,2})'
			use_url: true
			kind: .prerelease_suffix
			prerelease: 'rc'
		},
		VersionDetectionRule{
			pattern: r'[-.vV]?(\d+(?:\.\d+)+)'
			use_url: true
		},
	]
}

fn capture_version_rule(rule VersionDetectionRule, value string) ?string {
	return match rule.kind {
		.regular_expression { capture_version(rule.pattern, value, rule.case_insensitive) }
		.architecture_suffix { capture_architecture_version(value) }
		.prerelease_suffix { capture_prerelease_version(value, rule.prerelease) }
	}
}

fn capture_prerelease_version(value string, prerelease string) ?string {
	lower := value.to_lower()
	for start in 0 .. lower.len {
		if !lower[start].is_digit() {
			continue
		}
		mut index := start
		mut dots := 0
		for index < lower.len && (lower[index].is_digit() || lower[index] == `.`) {
			if lower[index] == `.` {
				dots++
			}
			index++
		}
		if dots == 0 {
			continue
		}
		if index < lower.len && lower[index] in [`-`, `_`, `.`] {
			index++
		}
		if index + prerelease.len > lower.len || lower[index..index + prerelease.len] != prerelease {
			continue
		}
		index += prerelease.len
		if index < lower.len && lower[index] == `.` {
			index++
		}
		mut digits := 0
		for index < lower.len && lower[index].is_digit() && digits < 2 {
			index++
			digits++
		}
		if index < lower.len && lower[index].is_digit() {
			continue
		}
		return value[start..index]
	}
	return none
}

fn capture_architecture_version(value string) ?string {
	lower := value.to_lower()
	mut prefix := ''
	for suffix in ['.i386', '-i386', '_i386', '.i686', '-i686', '_i686', '.x86', '-x86', '_x86',
		'.x64', '-x64', '_x64', '.x64-32', '-x64-32', '_x64-32', '.x64-64', '-x64-64', '_x64-64'] {
		if lower.ends_with(suffix) {
			prefix = value[..value.len - suffix.len]
			break
		}
	}
	if prefix == '' {
		return none
	}
	for index, character in prefix {
		if character !in [`-`, `_`] || index + 1 >= prefix.len {
			continue
		}
		candidate := prefix[index + 1..]
		if valid_architecture_version(candidate) {
			return candidate
		}
	}
	return none
}

fn valid_architecture_version(value string) bool {
	parts := value.split('-')
	if parts.len > 2 || (parts.len == 2 && !all_digits(parts[1])) {
		return false
	}
	components := parts[0].split('.')
	if components.len !in [2, 3] {
		return false
	}
	for component in components {
		if component == '' || !all_digits(component) {
			return false
		}
	}
	return true
}

fn capture_version(pattern string, value string, case_insensitive bool) ?string {
	v_pattern := pattern.replace('[._-]', '[-._]').replace('[_-]', '[-_]')
	mut expression := regex.regex_opt(v_pattern) or { return none }
	if case_insensitive {
		expression.flag |= regex.f_ci
	}
	start, _ := expression.find(value)
	if start < 0 {
		return none
	}
	captured := expression.get_group_by_id(value, 0)
	if captured.trim_space() == '' {
		return none
	}
	return captured
}

fn detection_stem(spec string) string {
	if (spec.contains('sourceforge.net/') || spec.contains('sf.net/')) && spec.ends_with('/download') {
		return detection_archive_stem(version_basename(version_dirname(spec)))
	}
	basename := version_basename(spec)
	if bottle_stem := detection_bottle_stem(basename) {
		return bottle_stem
	}
	dot := basename.last_index('.') or { return basename }
	mut numeric_extension := true
	for character in basename[dot + 1..] {
		if character.is_letter() {
			numeric_extension = false
			break
		}
	}
	return if numeric_extension { basename } else { detection_archive_stem(basename) }
}

fn detection_bottle_stem(basename string) ?string {
	lower := basename.to_lower()
	if !lower.ends_with('.tar.gz') {
		return none
	}
	bottle_index := lower.last_index('.bottle.') or { return none }
	tag_start := lower[..bottle_index].last_index('.') or { return none }
	if tag_start == 0 || tag_start + 1 == bottle_index {
		return none
	}
	for character in lower[tag_start + 1..bottle_index] {
		if !character.is_letter() && !character.is_digit() && character != `_` {
			return none
		}
	}
	return basename[..tag_start]
}

fn version_basename(path string) string {
	separator := path.last_index('/') or { return path }
	return path[separator + 1..]
}

fn version_dirname(path string) string {
	separator := path.last_index('/') or { return '.' }
	return path[..separator]
}

fn detection_archive_stem(value string) string {
	for suffix in ['.tar.gz', '.tar.bz2', '.tar.xz', '.tar.lz', '.tar.lzma', '.tar.zst', '.tgz',
		'.tbz', '.tbz2', '.txz', '.zip', '.gz', '.bz2', '.xz', '.lz', '.lzma', '.zst', '.rpm', '.deb',
		'.jar', '.war', '.phar'] {
		if value.to_lower().ends_with(suffix) {
			return value[..value.len - suffix.len]
		}
	}
	dot := value.last_index('.') or { return value }
	return if all_letters(value[dot + 1..]) { value[..dot] } else { value }
}
