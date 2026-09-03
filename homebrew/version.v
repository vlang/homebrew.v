module homebrew

import json2
import math
import net.urllib
import regex
import strconv

// Translated from Homebrew/brew `version.rb`.
// The original source is retained below until every stub has a typed V body.

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

// Ruby method `self.formula_optionally_versioned_regex(name, full: true)` at line 11.
pub fn ruby_version_l11_d1_self_formula_optionally_versioned_regex(name string, full bool) string {
	return formula_optionally_versioned_pattern(name, full)
}

// Ruby method `self.create(val)` at line 24.
pub fn ruby_version_l24_d2_self_create(value string) !VersionToken {
	return token_create(value)
}

// Ruby method `self.from(val)` at line 39.
pub fn ruby_version_l39_d3_self_from(value ?string) !VersionToken {
	return token_from_string(value)
}

// Ruby attr_reader `attr_reader :value` at line 50.
pub fn ruby_version_l50_d4_value(token VersionToken) string {
	return token.to_s()
}

// Ruby method `initialize(value)` at line 53.
pub fn ruby_version_l53_d5_initialize(value string) !VersionToken {
	return token_create(value)
}

// Ruby method `<=>(other); end` at line 58.
pub fn ruby_version_l58_d6_anonymous(token VersionToken, other VersionToken) int {
	return compare_tokens(token, other)
}

// Ruby method `inspect` at line 61.
pub fn ruby_version_l61_d7_inspect(token VersionToken) string {
	return token.inspect()
}

// Ruby method `hash` at line 66.
pub fn ruby_version_l66_d8_hash(token VersionToken) u64 {
	return hash_string(token.to_s())
}

// Ruby method `to_f` at line 71.
pub fn ruby_version_l71_d9_to_f(token VersionToken) f64 {
	return new_version(token.to_s()) or { return 0.0 }.to_f()
}

// Ruby method `to_i` at line 76.
pub fn ruby_version_l76_d10_to_i(token VersionToken) int {
	return new_version(token.to_s()) or { return 0 }.to_i()
}

// Ruby method `to_str` at line 81.
pub fn ruby_version_l81_d11_to_str(token VersionToken) string {
	return token.to_s()
}

// Ruby method `to_s = to_str` at line 86.
pub fn ruby_version_l86_d12_to_s(token VersionToken) string {
	return token.to_s()
}

// Ruby method `numeric?` at line 89.
pub fn ruby_version_l89_d13_numeric(token VersionToken) bool {
	return token.numeric()
}

// Ruby method `null?` at line 94.
pub fn ruby_version_l94_d14_null(token VersionToken) bool {
	return token.is_null()
}

// Ruby method `blank? = null?` at line 99.
pub fn ruby_version_l99_d15_blank(token VersionToken) bool {
	return token.is_null()
}

// Ruby attr_reader `attr_reader :value` at line 105.
pub fn ruby_version_l105_d16_value() ?string {
	return none
}

// Ruby method `initialize` at line 108.
pub fn ruby_version_l108_d17_initialize() VersionToken {
	return null_version_token()
}

// Ruby method `<=>(other)` at line 113.
pub fn ruby_version_l113_d18_anonymous(other VersionToken) int {
	return compare_tokens(null_version_token(), other)
}

// Ruby method `null?` at line 129.
pub fn ruby_version_l129_d19_null() bool {
	return true
}

// Ruby method `blank? = true` at line 134.
pub fn ruby_version_l134_d20_blank() bool {
	return true
}

// Ruby method `inspect` at line 137.
pub fn ruby_version_l137_d21_inspect() string {
	return null_version_token().inspect()
}

// Ruby attr_reader `attr_reader :value` at line 151.
pub fn ruby_version_l151_d22_value(token VersionToken) string {
	return token.text
}

// Ruby method `initialize(value)` at line 154.
pub fn ruby_version_l154_d23_initialize(value string) !VersionToken {
	return token_create(value)
}

// Ruby method `<=>(other)` at line 159.
pub fn ruby_version_l159_d24_anonymous(token VersionToken, other VersionToken) int {
	return compare_tokens(token, other)
}

// Ruby attr_reader `attr_reader :value` at line 176.
pub fn ruby_version_l176_d25_value(token VersionToken) int {
	return token.number
}

// Ruby method `initialize(value)` at line 179.
pub fn ruby_version_l179_d26_initialize(value string) !VersionToken {
	return token_create(value)
}

// Ruby method `<=>(other)` at line 184.
pub fn ruby_version_l184_d27_anonymous(token VersionToken, other VersionToken) int {
	return compare_tokens(token, other)
}

// Ruby method `numeric?` at line 198.
pub fn ruby_version_l198_d28_numeric() bool {
	return true
}

// Ruby method `rev` at line 206.
pub fn ruby_version_l206_d29_rev(token VersionToken) int {
	return token.revision()
}

// Ruby method `<=>(other)` at line 216.
pub fn ruby_version_l216_d30_anonymous(token VersionToken, other VersionToken) int {
	return compare_tokens(token, other)
}

// Ruby method `<=>(other)` at line 235.
pub fn ruby_version_l235_d31_anonymous(token VersionToken, other VersionToken) int {
	return compare_tokens(token, other)
}

// Ruby method `<=>(other)` at line 256.
pub fn ruby_version_l256_d32_anonymous(token VersionToken, other VersionToken) int {
	return compare_tokens(token, other)
}

// Ruby method `<=>(other)` at line 277.
pub fn ruby_version_l277_d33_anonymous(token VersionToken, other VersionToken) int {
	return compare_tokens(token, other)
}

// Ruby method `<=>(other)` at line 298.
pub fn ruby_version_l298_d34_anonymous(token VersionToken, other VersionToken) int {
	return compare_tokens(token, other)
}

// Ruby method `<=>(other)` at line 317.
pub fn ruby_version_l317_d35_anonymous(token VersionToken, other VersionToken) int {
	return compare_tokens(token, other)
}

// Ruby method `self.detect(url, **specs)` at line 344.
pub fn ruby_version_l344_d36_self_detect(url string, tag string) Version {
	return detect_version(url, tag)
}

// Ruby method `self.parse(spec, detected_from_url: false)` at line 349.
pub fn ruby_version_l349_d37_self_parse(spec string, detected_from_url bool) Version {
	return parse_version(spec, detected_from_url)
}

// Ruby method `initialize(val, detected_from_url: false)` at line 501.
pub fn ruby_version_l501_d38_initialize(value string, detected_from_url bool) !Version {
	return new_version_with_detection(value, detected_from_url)
}

// Ruby method `detected_from_url?` at line 510.
pub fn ruby_version_l510_d39_detected_from_url(version Version) bool {
	return version.detected_from_url()
}

// Ruby method `head?` at line 521.
pub fn ruby_version_l521_d40_head(version Version) bool {
	return version.head()
}

// Ruby method `commit` at line 529.
pub fn ruby_version_l529_d41_commit(version Version) ?string {
	return version.commit()
}

// Ruby method `update_commit(commit)` at line 535.
pub fn ruby_version_l535_d42_update_commit(mut version Version, commit ?string) !Version {
	version.update_commit(commit)!
	return version
}

// Ruby method `null?` at line 546.
pub fn ruby_version_l546_d43_null(version Version) bool {
	return version.is_null()
}

// Ruby method `compare(comparator, other)` at line 551.
pub fn ruby_version_l551_d44_compare(version Version, comparator string, other Version) !bool {
	return version.compare(comparator, other)
}

// Ruby method `<=>(other)` at line 564.
pub fn ruby_version_l564_d45_anonymous(version Version, other Version) int {
	return version.compare_to(other)
}

// Ruby method `==(other)` at line 641.
pub fn ruby_version_l641_d46_anonymous(version Version, other Version) bool {
	return version.equals(other)
}

// Ruby alias `alias eql? ==` at line 650.
pub fn ruby_version_l650_d47_eql(version Version, other Version) bool {
	return version.equals(other)
}

// Ruby method `major` at line 656.
pub fn ruby_version_l656_d48_major(version Version) ?VersionToken {
	return version.major()
}

// Ruby method `minor` at line 666.
pub fn ruby_version_l666_d49_minor(version Version) ?VersionToken {
	return version.minor()
}

// Ruby method `patch` at line 676.
pub fn ruby_version_l676_d50_patch(version Version) ?VersionToken {
	return version.patch()
}

// Ruby method `major_minor` at line 686.
pub fn ruby_version_l686_d51_major_minor(version Version) Version {
	return version.major_minor()
}

// Ruby method `major_minor_patch` at line 697.
pub fn ruby_version_l697_d52_major_minor_patch(version Version) Version {
	return version.major_minor_patch()
}

// Ruby method `hash` at line 705.
pub fn ruby_version_l705_d53_hash(version Version) u64 {
	return version.hash()
}

// Ruby method `to_f` at line 713.
pub fn ruby_version_l713_d54_to_f(version Version) f64 {
	return version.to_f()
}

// Ruby method `to_i` at line 723.
pub fn ruby_version_l723_d55_to_i(version Version) int {
	return version.to_i()
}

// Ruby method `to_str` at line 732.
pub fn ruby_version_l732_d56_to_str(version Version) !string {
	return version.to_str()
}

// Ruby method `to_s = version.to_s` at line 742.
pub fn ruby_version_l742_d57_to_s(version Version) string {
	return version.to_s()
}

// Ruby method `to_json(*options) = version.to_json(*options)` at line 745.
pub fn ruby_version_l745_d58_to_json(version Version) string {
	return version.to_json()
}

// Ruby method `respond_to?(method, include_all = false)` at line 748.
pub fn ruby_version_l748_d59_respond_to(version Version, method string) bool {
	return if method == 'to_str' { version.responds_to_to_str() } else { false }
}

// Ruby method `inspect` at line 755.
pub fn ruby_version_l755_d60_inspect(version Version) string {
	return version.inspect()
}

// Ruby method `freeze` at line 762.
pub fn ruby_version_l762_d61_freeze(version Version) Version {
	version.tokens()
	return version
}

// Ruby attr_reader `attr_reader :version` at line 770.
pub fn ruby_version_l770_d62_version(version Version) ?string {
	return version.version_string()
}

// Ruby method `tokens` at line 773.
pub fn ruby_version_l773_d63_tokens(version Version) []VersionToken {
	return version.tokens()
}

// Ruby method `max(first, second)` at line 788.
pub fn ruby_version_l788_d64_max(first int, second int) int {
	return if first > second { first } else { second }
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "version/parser"
// 5:
// 6: # A formula's version.
// 7: class Version
// 8:   include Comparable
// 9:
// 10:   sig { params(name: T.any(String, Symbol), full: T::Boolean).returns(Regexp) }
// 11:   def self.formula_optionally_versioned_regex(name, full: true)
// 12:     /#{"^" if full}#{Regexp.escape(name)}(@\d[\d.]*)?#{"$" if full}/
// 13:   end
// 14:
// 15:   # A part of a {Version}.
// 16:   class Token
// 17:     extend T::Helpers
// 18:
// 19:     abstract!
// 20:
// 21:     include Comparable
// 22:
// 23:     sig { params(val: String).returns(Token) }
// 24:     def self.create(val)
// 25:       case val
// 26:       when /\A#{AlphaToken::PATTERN}\z/o   then AlphaToken
// 27:       when /\A#{BetaToken::PATTERN}\z/o    then BetaToken
// 28:       when /\A#{RCToken::PATTERN}\z/o      then RCToken
// 29:       when /\A#{PreToken::PATTERN}\z/o     then PreToken
// 30:       when /\A#{PatchToken::PATTERN}\z/o   then PatchToken
// 31:       when /\A#{PostToken::PATTERN}\z/o    then PostToken
// 32:       when /\A#{NumericToken::PATTERN}\z/o then NumericToken
// 33:       when /\A#{StringToken::PATTERN}\z/o  then StringToken
// 34:       else raise "Cannot find a matching token pattern"
// 35:       end.new(val)
// 36:     end
// 37:
// 38:     sig { params(val: T.untyped).returns(T.nilable(Token)) }
// 39:     def self.from(val)
// 40:       return NULL_TOKEN if val.nil? || (val.respond_to?(:null?) && val.null?)
// 41:
// 42:       case val
// 43:       when Token   then val
// 44:       when String  then Token.create(val)
// 45:       when Integer then Token.create(val.to_s)
// 46:       end
// 47:     end
// 48:
// 49:     sig { returns(T.nilable(T.any(String, Integer))) }
// 50:     attr_reader :value
// 51:
// 52:     sig { params(value: T.nilable(T.any(String, Integer))).void }
// 53:     def initialize(value)
// 54:       @value = T.let(value, T.untyped)
// 55:     end
// 56:
// 57:     sig { abstract.params(other: T.untyped).returns(T.nilable(Integer)) }
// 58:     def <=>(other); end
// 59:
// 60:     sig { returns(String) }
// 61:     def inspect
// 62:       "#<#{self.class.name} #{value.inspect}>"
// 63:     end
// 64:
// 65:     sig { returns(Integer) }
// 66:     def hash
// 67:       value.hash
// 68:     end
// 69:
// 70:     sig { returns(Float) }
// 71:     def to_f
// 72:       value.to_f
// 73:     end
// 74:
// 75:     sig { returns(Integer) }
// 76:     def to_i
// 77:       value.to_i
// 78:     end
// 79:
// 80:     sig { returns(String) }
// 81:     def to_str
// 82:       value.to_s
// 83:     end
// 84:
// 85:     sig { returns(String) }
// 86:     def to_s = to_str
// 87:
// 88:     sig { returns(T::Boolean) }
// 89:     def numeric?
// 90:       false
// 91:     end
// 92:
// 93:     sig { returns(T::Boolean) }
// 94:     def null?
// 95:       false
// 96:     end
// 97:
// 98:     sig { returns(T::Boolean) }
// 99:     def blank? = null?
// 100:   end
// 101:
// 102:   # A pseudo-token representing the absence of a token.
// 103:   class NullToken < Token
// 104:     sig { override.returns(NilClass) }
// 105:     attr_reader :value
// 106:
// 107:     sig { void }
// 108:     def initialize
// 109:       super(nil)
// 110:     end
// 111:
// 112:     sig { override.params(other: T.untyped).returns(T.nilable(Integer)) }
// 113:     def <=>(other)
// 114:       return unless (other = Token.from(other))
// 115:
// 116:       case other
// 117:       when NullToken
// 118:         0
// 119:       when NumericToken
// 120:         other.value.zero? ? 0 : -1
// 121:       when AlphaToken, BetaToken, PreToken, RCToken
// 122:         1
// 123:       else
// 124:         -1
// 125:       end
// 126:     end
// 127:
// 128:     sig { override.returns(T::Boolean) }
// 129:     def null?
// 130:       true
// 131:     end
// 132:
// 133:     sig { returns(T::Boolean) }
// 134:     def blank? = true
// 135:
// 136:     sig { returns(String) }
// 137:     def inspect
// 138:       "#<#{self.class.name}>"
// 139:     end
// 140:   end
// 141:   private_constant :NullToken
// 142:
// 143:   # Represents the absence of a token.
// 144:   NULL_TOKEN = NullToken.new.freeze
// 145:
// 146:   # A token string.
// 147:   class StringToken < Token
// 148:     PATTERN = /[a-z]+/i
// 149:
// 150:     sig { override.returns(String) }
// 151:     attr_reader :value
// 152:
// 153:     sig { params(value: String).void }
// 154:     def initialize(value)
// 155:       super(value.to_s)
// 156:     end
// 157:
// 158:     sig { override.params(other: T.untyped).returns(T.nilable(Integer)) }
// 159:     def <=>(other)
// 160:       return unless (other = Token.from(other))
// 161:
// 162:       case other
// 163:       when StringToken
// 164:         value <=> other.value
// 165:       when NumericToken, NullToken
// 166:         -T.must(other <=> self)
// 167:       end
// 168:     end
// 169:   end
// 170:
// 171:   # A token consisting of only numbers.
// 172:   class NumericToken < Token
// 173:     PATTERN = /[0-9]+/i
// 174:
// 175:     sig { override.returns(Integer) }
// 176:     attr_reader :value
// 177:
// 178:     sig { params(value: T.any(String, Integer)).void }
// 179:     def initialize(value)
// 180:       super(value.to_i)
// 181:     end
// 182:
// 183:     sig { override.params(other: T.untyped).returns(T.nilable(Integer)) }
// 184:     def <=>(other)
// 185:       return unless (other = Token.from(other))
// 186:
// 187:       case other
// 188:       when NumericToken
// 189:         value <=> other.value
// 190:       when StringToken
// 191:         1
// 192:       when NullToken
// 193:         -T.must(other <=> self)
// 194:       end
// 195:     end
// 196:
// 197:     sig { override.returns(T::Boolean) }
// 198:     def numeric?
// 199:       true
// 200:     end
// 201:   end
// 202:
// 203:   # A token consisting of an alphabetic and a numeric part.
// 204:   class CompositeToken < StringToken
// 205:     sig { returns(Integer) }
// 206:     def rev
// 207:       value[/[0-9]+/].to_i
// 208:     end
// 209:   end
// 210:
// 211:   # A token representing the part of a version designating it as an alpha release.
// 212:   class AlphaToken < CompositeToken
// 213:     PATTERN = /alpha[0-9]*|a[0-9]+/i
// 214:
// 215:     sig { override.params(other: T.untyped).returns(T.nilable(Integer)) }
// 216:     def <=>(other)
// 217:       return unless (other = Token.from(other))
// 218:
// 219:       case other
// 220:       when AlphaToken
// 221:         rev <=> other.rev
// 222:       when BetaToken, RCToken, PreToken, PatchToken, PostToken
// 223:         -1
// 224:       else
// 225:         super
// 226:       end
// 227:     end
// 228:   end
// 229:
// 230:   # A token representing the part of a version designating it as a beta release.
// 231:   class BetaToken < CompositeToken
// 232:     PATTERN = /beta[0-9]*|b[0-9]+/i
// 233:
// 234:     sig { override.params(other: T.untyped).returns(T.nilable(Integer)) }
// 235:     def <=>(other)
// 236:       return unless (other = Token.from(other))
// 237:
// 238:       case other
// 239:       when BetaToken
// 240:         rev <=> other.rev
// 241:       when AlphaToken
// 242:         1
// 243:       when PreToken, RCToken, PatchToken, PostToken
// 244:         -1
// 245:       else
// 246:         super
// 247:       end
// 248:     end
// 249:   end
// 250:
// 251:   # A token representing the part of a version designating it as a pre-release.
// 252:   class PreToken < CompositeToken
// 253:     PATTERN = /pre[0-9]*/i
// 254:
// 255:     sig { override.params(other: T.untyped).returns(T.nilable(Integer)) }
// 256:     def <=>(other)
// 257:       return unless (other = Token.from(other))
// 258:
// 259:       case other
// 260:       when PreToken
// 261:         rev <=> other.rev
// 262:       when AlphaToken, BetaToken
// 263:         1
// 264:       when RCToken, PatchToken, PostToken
// 265:         -1
// 266:       else
// 267:         super
// 268:       end
// 269:     end
// 270:   end
// 271:
// 272:   # A token representing the part of a version designating it as a release candidate.
// 273:   class RCToken < CompositeToken
// 274:     PATTERN = /rc[0-9]*/i
// 275:
// 276:     sig { override.params(other: T.untyped).returns(T.nilable(Integer)) }
// 277:     def <=>(other)
// 278:       return unless (other = Token.from(other))
// 279:
// 280:       case other
// 281:       when RCToken
// 282:         rev <=> other.rev
// 283:       when AlphaToken, BetaToken, PreToken
// 284:         1
// 285:       when PatchToken, PostToken
// 286:         -1
// 287:       else
// 288:         super
// 289:       end
// 290:     end
// 291:   end
// 292:
// 293:   # A token representing the part of a version designating it as a patch release.
// 294:   class PatchToken < CompositeToken
// 295:     PATTERN = /p[0-9]*/i
// 296:
// 297:     sig { override.params(other: T.untyped).returns(T.nilable(Integer)) }
// 298:     def <=>(other)
// 299:       return unless (other = Token.from(other))
// 300:
// 301:       case other
// 302:       when PatchToken
// 303:         rev <=> other.rev
// 304:       when AlphaToken, BetaToken, RCToken, PreToken
// 305:         1
// 306:       else
// 307:         super
// 308:       end
// 309:     end
// 310:   end
// 311:
// 312:   # A token representing the part of a version designating it as a post release.
// 313:   class PostToken < CompositeToken
// 314:     PATTERN = /.post[0-9]+/i
// 315:
// 316:     sig { override.params(other: T.untyped).returns(T.nilable(Integer)) }
// 317:     def <=>(other)
// 318:       return unless (other = Token.from(other))
// 319:
// 320:       case other
// 321:       when PostToken
// 322:         rev <=> other.rev
// 323:       when AlphaToken, BetaToken, RCToken, PreToken
// 324:         1
// 325:       else
// 326:         super
// 327:       end
// 328:     end
// 329:   end
// 330:
// 331:   SCAN_PATTERN = T.let(Regexp.union(
// 332:     AlphaToken::PATTERN,
// 333:     BetaToken::PATTERN,
// 334:     PreToken::PATTERN,
// 335:     RCToken::PATTERN,
// 336:     PatchToken::PATTERN,
// 337:     PostToken::PATTERN,
// 338:     NumericToken::PATTERN,
// 339:     StringToken::PATTERN,
// 340:   ).freeze, Regexp)
// 341:   private_constant :SCAN_PATTERN
// 342:
// 343:   sig { params(url: T.any(String, Pathname), specs: T.untyped).returns(Version) }
// 344:   def self.detect(url, **specs)
// 345:     parse(specs.fetch(:tag, url), detected_from_url: true)
// 346:   end
// 347:
// 348:   sig { params(spec: T.any(String, Pathname), detected_from_url: T::Boolean).returns(Version) }
// 349:   def self.parse(spec, detected_from_url: false)
// 350:     # This type of full-URL decoding is not technically correct but we only need a rough decode for version parsing.
// 351:     spec = URI.decode_www_form_component(spec.to_s) if detected_from_url
// 352:
// 353:     spec = Pathname(spec)
// 354:
// 355:     VERSION_PARSERS.each do |parser|
// 356:       version = parser.parse(spec)
// 357:       return new(version, detected_from_url:) if version.present?
// 358:     end
// 359:
// 360:     NULL
// 361:   end
// 362:
// 363:   NUMERIC_WITH_OPTIONAL_DOTS = T.let(/(?:\d+(?:\.\d+)*)/.source.freeze, String)
// 364:   private_constant :NUMERIC_WITH_OPTIONAL_DOTS
// 365:
// 366:   NUMERIC_WITH_DOTS = T.let(/(?:\d+(?:\.\d+)+)/.source.freeze, String)
// 367:   private_constant :NUMERIC_WITH_DOTS
// 368:
// 369:   MINOR_OR_PATCH = T.let(/(?:\d+(?:\.\d+){1,2})/.source.freeze, String)
// 370:   private_constant :MINOR_OR_PATCH
// 371:
// 372:   CONTENT_SUFFIX = T.let(/(?:[._-](?i:bin|dist|stable|src|sources?|final|full))/.source.freeze, String)
// 373:   private_constant :CONTENT_SUFFIX
// 374:
// 375:   PRERELEASE_SUFFIX = T.let(/(?:[._-]?(?i:alpha|beta|pre|rc)\.?\d{,2})/.source.freeze, String)
// 376:   private_constant :PRERELEASE_SUFFIX
// 377:
// 378:   VERSION_PARSERS = T.let([
// 379:     # date-based versioning
// 380:     # e.g. `2023-09-28.tar.gz`
// 381:     # e.g. `ltopers-v2017-04-14.tar.gz`
// 382:     StemParser.new(/(?:^|[._-]?)v?(\d{4}-\d{2}-\d{2})/),
// 383:
// 384:     # GitHub tarballs
// 385:     # e.g. `https://github.com/foo/bar/tarball/v1.2.3`
// 386:     # e.g. `https://github.com/sam-github/libnet/tarball/libnet-1.1.4`
// 387:     # e.g. `https://github.com/isaacs/npm/tarball/v0.2.5-1`
// 388:     # e.g. `https://github.com/petdance/ack/tarball/1.93_02`
// 389:     UrlParser.new(%r{github\.com/.+/(?:zip|tar)ball/(?:v|\w+-)?((?:\d+[._-])+\d*)$}),
// 390:
// 391:     # GitHub releases
// 392:     # e.g. `https://github.com/foo/bar/releases/download/v1.2/foo-1.2.0.tar.gz`
// 393:     UrlParser.new(%r{github\.com/.+/releases/download/(?:[rvV]_?)?(#{NUMERIC_WITH_DOTS})/}),
// 394:
// 395:     # e.g. `https://github.com/erlang/otp/tarball/OTP_R15B01 (erlang style)`
// 396:     UrlParser.new(/[_-]([Rr]\d+[AaBb]\d*(?:-\d+)?)/),
// 397:
// 398:     # e.g. `boost_1_39_0`
// 399:     StemParser.new(/((?:\d+_)+\d+)$/) { |s| s.tr("_", ".") },
// 400:
// 401:     # e.g. `foobar-4.5.1-1`
// 402:     # e.g. `unrtf_0.20.4-1`
// 403:     # e.g. `ruby-1.9.1-p243`
// 404:     StemParser.new(/[_-](#{NUMERIC_WITH_DOTS}-(?:p|P|rc|RC)?\d+)#{CONTENT_SUFFIX}?$/),
// 405:
// 406:     # Hyphenated versions without software-name prefix (e.g. brew-)
// 407:     # e.g. `v0.0.8-12.tar.gz`
// 408:     # e.g. `3.3.04-1.tar.gz`
// 409:     # e.g. `v2.1-20210510.tar.gz`
// 410:     # e.g. `2020.11.11-3.tar.gz`
// 411:     # e.g. `v3.6.6-0.2`
// 412:     StemParser.new(/^v?(#{NUMERIC_WITH_DOTS}(?:-#{NUMERIC_WITH_OPTIONAL_DOTS})+)/),
// 413:
// 414:     # URL with no extension
// 415:     # e.g. `https://waf.io/waf-1.8.12`
// 416:     # e.g. `https://codeload.github.com/gsamokovarov/jump/tar.gz/v0.7.1`
// 417:     UrlParser.new(/[-v](#{NUMERIC_WITH_OPTIONAL_DOTS})$/),
// 418:
// 419:     # e.g. `lame-398-1`
// 420:     StemParser.new(/-(\d+-\d+)/),
// 421:
// 422:     # e.g. `foobar-4.5.1`
// 423:     StemParser.new(/-(#{NUMERIC_WITH_OPTIONAL_DOTS})$/),
// 424:
// 425:     # e.g. `foobar-4.5.1.post1`
// 426:     StemParser.new(/-(#{NUMERIC_WITH_OPTIONAL_DOTS}(.post\d+)?)$/),
// 427:
// 428:     # e.g. `foobar-4.5.1b`
// 429:     StemParser.new(/-(#{NUMERIC_WITH_OPTIONAL_DOTS}(?:[abc]|rc|RC)\d*)$/),
// 430:
// 431:     # e.g. `foobar-4.5.0-alpha5, foobar-4.5.0-beta1, or foobar-4.50-beta`
// 432:     StemParser.new(/-(#{NUMERIC_WITH_OPTIONAL_DOTS}-(?:alpha|beta|rc)\d*)$/),
// 433:
// 434:     # e.g. `https://ftpmirror.gnu.org/libidn/libidn-1.29-win64.zip`
// 435:     # e.g. `https://ftpmirror.gnu.org/libmicrohttpd/libmicrohttpd-0.9.17-w32.zip`
// 436:     StemParser.new(/-(#{MINOR_OR_PATCH})-w(?:in)?(?:32|64)$/),
// 437:
// 438:     # Opam packages
// 439:     # e.g. `https://opam.ocaml.org/archives/sha.1.9+opam.tar.gz`
// 440:     # e.g. `https://opam.ocaml.org/archives/lablgtk.2.18.3+opam.tar.gz`
// 441:     # e.g. `https://opam.ocaml.org/archives/easy-format.1.0.2+opam.tar.gz`
// 442:     StemParser.new(/\.(#{MINOR_OR_PATCH})\+opam$/),
// 443:
// 444:     # e.g. `https://ftpmirror.gnu.org/mtools/mtools-4.0.18-1.i686.rpm`
// 445:     # e.g. `https://ftpmirror.gnu.org/autogen/autogen-5.5.7-5.i386.rpm`
// 446:     # e.g. `https://ftpmirror.gnu.org/libtasn1/libtasn1-2.8-x86.zip`
// 447:     # e.g. `https://ftpmirror.gnu.org/libtasn1/libtasn1-2.8-x64.zip`
// 448:     # e.g. `https://ftpmirror.gnu.org/mtools/mtools_4.0.18_i386.deb`
// 449:     StemParser.new(/[_-](#{MINOR_OR_PATCH}(?:-\d+)?)[._-](?:i[36]86|x86|x64(?:[_-](?:32|64))?)$/),
// 450:
// 451:     # e.g. `https://registry.npmjs.org/@angular/cli/-/cli-1.3.0-beta.1.tgz`
// 452:     # e.g. `https://github.com/dlang/dmd/archive/v2.074.0-beta1.tar.gz`
// 453:     # e.g. `https://github.com/dlang/dmd/archive/v2.074.0-rc1.tar.gz`
// 454:     # e.g. `https://github.com/premake/premake-core/releases/download/v5.0.0-alpha10/premake-5.0.0-alpha10-src.zip`
// 455:     StemParser.new(/[-.vV]?(#{NUMERIC_WITH_DOTS}#{PRERELEASE_SUFFIX})/),
// 456:
// 457:     # e.g. `foobar4.5.1`
// 458:     StemParser.new(/(#{NUMERIC_WITH_OPTIONAL_DOTS})$/),
// 459:
// 460:     # e.g. `foobar-4.5.0-bin`
// 461:     StemParser.new(/[-vV](#{NUMERIC_WITH_DOTS}[abc]?)#{CONTENT_SUFFIX}$/),
// 462:
// 463:     # dash version style
// 464:     # e.g. `http://www.antlr.org/download/antlr-3.4-complete.jar`
// 465:     # e.g. `https://cdn.nuxeo.com/nuxeo-9.2/nuxeo-server-9.2-tomcat.zip`
// 466:     # e.g. `https://search.maven.org/remotecontent?filepath=com/facebook/presto/presto-cli/0.181/presto-cli-0.181-executable.jar`
// 467:     # e.g. `https://search.maven.org/remotecontent?filepath=org/fusesource/fuse-extra/fusemq-apollo-mqtt/1.3/fusemq-apollo-mqtt-1.3-uber.jar`
// 468:     # e.g. `https://search.maven.org/remotecontent?filepath=org/apache/orc/orc-tools/1.2.3/orc-tools-1.2.3-uber.jar`
// 469:     StemParser.new(/-(#{NUMERIC_WITH_DOTS})-/),
// 470:
// 471:     # Debian style
// 472:     # e.g. `dash_0.5.5.1.orig.tar.gz`
// 473:     # e.g. `lcrack_20040914.orig.tar.gz`
// 474:     # e.g. `mkcue_1.orig.tar.gz`
// 475:     StemParser.new(/_(#{NUMERIC_WITH_OPTIONAL_DOTS}[abc]?)\.orig$/),
// 476:
// 477:     # e.g. `https://www.openssl.org/source/openssl-0.9.8s.tar.gz`
// 478:     StemParser.new(/-v?(\d[^-]+)/),
// 479:
// 480:     # e.g. `astyle_1.23_macosx.tar.gz`
// 481:     StemParser.new(/_v?(\d[^_]+)/),
// 482:
// 483:     # e.g. `http://mirrors.jenkins-ci.org/war/1.486/jenkins.war`
// 484:     # e.g. `https://github.com/foo/bar/releases/download/0.10.11/bar.phar`
// 485:     # e.g. `https://github.com/clojure/clojurescript/releases/download/r1.9.293/cljs.jar`
// 486:     # e.g. `https://github.com/fibjs/fibjs/releases/download/v0.6.1/fullsrc.zip`
// 487:     # e.g. `https://wwwlehre.dhbw-stuttgart.de/~sschulz/WORK/E_DOWNLOAD/V_1.9/E.tgz`
// 488:     # e.g. `https://github.com/JustArchi/ArchiSteamFarm/releases/download/2.3.2.0/ASF.zip`
// 489:     # e.g. `https://people.gnome.org/~newren/eg/download/1.7.5.2/eg`
// 490:     UrlParser.new(%r{/(?:[rvV]_?)?(\d+\.\d+(?:\.\d+){,2})}),
// 491:
// 492:     # e.g. `https://www.ijg.org/files/jpegsrc.v8d.tar.gz`
// 493:     StemParser.new(/\.v(\d+[a-z]?)/),
// 494:
// 495:     # e.g. `https://secure.php.net/get/php-7.1.10.tar.bz2/from/this/mirror`
// 496:     UrlParser.new(/[-.vV]?(#{NUMERIC_WITH_DOTS}#{PRERELEASE_SUFFIX}?)/),
// 497:   ].freeze, T::Array[Version::Parser])
// 498:   private_constant :VERSION_PARSERS
// 499:
// 500:   sig { params(val: T.any(String, Version), detected_from_url: T::Boolean).void }
// 501:   def initialize(val, detected_from_url: false)
// 502:     version = val.to_str
// 503:     raise ArgumentError, "Version must not be empty" if version.blank?
// 504:
// 505:     @version = T.let(version, String)
// 506:     @detected_from_url = detected_from_url
// 507:   end
// 508:
// 509:   sig { returns(T::Boolean) }
// 510:   def detected_from_url?
// 511:     @detected_from_url
// 512:   end
// 513:
// 514:   HEAD_VERSION_REGEX = /\AHEAD(?:-(?<commit>.*))?\Z/
// 515:   private_constant :HEAD_VERSION_REGEX
// 516:
// 517:   # Check if this is a HEAD version.
// 518:   #
// 519:   # @api public
// 520:   sig { returns(T::Boolean) }
// 521:   def head?
// 522:     version&.match?(HEAD_VERSION_REGEX) || false
// 523:   end
// 524:
// 525:   # Return the commit for a HEAD version.
// 526:   #
// 527:   # @api public
// 528:   sig { returns(T.nilable(String)) }
// 529:   def commit
// 530:     version&.match(HEAD_VERSION_REGEX)&.[](:commit)
// 531:   end
// 532:
// 533:   # Update the commit for a HEAD version.
// 534:   sig { params(commit: T.nilable(String)).void }
// 535:   def update_commit(commit)
// 536:     raise ArgumentError, "Cannot update commit for non-HEAD version." unless head?
// 537:
// 538:     @version = if commit
// 539:       "HEAD-#{commit}"
// 540:     else
// 541:       "HEAD"
// 542:     end
// 543:   end
// 544:
// 545:   sig { returns(T::Boolean) }
// 546:   def null?
// 547:     version.nil?
// 548:   end
// 549:
// 550:   sig { params(comparator: String, other: Version).returns(T::Boolean) }
// 551:   def compare(comparator, other)
// 552:     case comparator
// 553:     when ">=" then self >= other
// 554:     when ">" then self > other
// 555:     when "<" then self < other
// 556:     when "<=" then self <= other
// 557:     when "==" then self == other
// 558:     when "!=" then self != other
// 559:     else raise ArgumentError, "Unknown comparator: #{comparator}"
// 560:     end
// 561:   end
// 562:
// 563:   sig { params(other: T.untyped).returns(T.nilable(Integer)) }
// 564:   def <=>(other)
// 565:     other = case other
// 566:     when String
// 567:       if other.blank?
// 568:         # Cannot compare `NULL` to empty string.
// 569:         return if null?
// 570:
// 571:         return 1
// 572:       end
// 573:
// 574:       # Needed to retain API compatibility with older string comparisons for compiler versions, etc.
// 575:       Version.new(other)
// 576:     when Integer
// 577:       # Used by the `*_build_version` comparisons, which formerly returned an integer.
// 578:       Version.new(other.to_s)
// 579:     when Token
// 580:       if other.null?
// 581:         # Cannot compare `NULL` to `NULL`.
// 582:         return if null?
// 583:
// 584:         return 1
// 585:       end
// 586:
// 587:       Version.new(other.to_s)
// 588:     when Version
// 589:       if other.null?
// 590:         # Cannot compare `NULL` to `NULL`.
// 591:         return if null?
// 592:
// 593:         return 1
// 594:       end
// 595:
// 596:       other
// 597:     when nil
// 598:       return 1
// 599:     else
// 600:       return
// 601:     end
// 602:
// 603:     # All `other.null?` cases are handled at this point.
// 604:     return -1 if null?
// 605:
// 606:     return 0 if version == other.version
// 607:     return 1 if head? && !other.head?
// 608:     return -1 if !head? && other.head?
// 609:     return 0 if head? && other.head?
// 610:
// 611:     ltokens = tokens
// 612:     rtokens = other.tokens
// 613:     max = max(ltokens.length, rtokens.length)
// 614:     l = r = 0
// 615:
// 616:     while l < max
// 617:       a = ltokens[l] || NULL_TOKEN
// 618:       b = rtokens[r] || NULL_TOKEN
// 619:
// 620:       if a == b
// 621:         l += 1
// 622:         r += 1
// 623:         next
// 624:       elsif a.numeric? && !b.numeric?
// 625:         return 1 if a > NULL_TOKEN
// 626:
// 627:         l += 1
// 628:       elsif !a.numeric? && b.numeric?
// 629:         return -1 if b > NULL_TOKEN
// 630:
// 631:         r += 1
// 632:       else
// 633:         return a <=> b
// 634:       end
// 635:     end
// 636:
// 637:     0
// 638:   end
// 639:
// 640:   sig { override.params(other: T.anything).returns(T::Boolean) }
// 641:   def ==(other)
// 642:     # Makes sure that the same instance of Version::NULL
// 643:     # will never equal itself; normally Comparable#==
// 644:     # will return true for this regardless of the return
// 645:     # value of #<=>
// 646:     return false if null?
// 647:
// 648:     super
// 649:   end
// 650:   alias eql? ==
// 651:
// 652:   # The major version.
// 653:   #
// 654:   # @api public
// 655:   sig { returns(T.nilable(Token)) }
// 656:   def major
// 657:     return NULL_TOKEN if null?
// 658:
// 659:     tokens.first
// 660:   end
// 661:
// 662:   # The minor version.
// 663:   #
// 664:   # @api public
// 665:   sig { returns(T.nilable(Token)) }
// 666:   def minor
// 667:     return NULL_TOKEN if null?
// 668:
// 669:     tokens.second
// 670:   end
// 671:
// 672:   # The patch version.
// 673:   #
// 674:   # @api public
// 675:   sig { returns(T.nilable(Token)) }
// 676:   def patch
// 677:     return NULL_TOKEN if null?
// 678:
// 679:     tokens.third
// 680:   end
// 681:
// 682:   # The major and minor version.
// 683:   #
// 684:   # @api public
// 685:   sig { returns(T.self_type) }
// 686:   def major_minor
// 687:     return self if null?
// 688:
// 689:     major_minor = T.must(tokens[0..1])
// 690:     major_minor.empty? ? NULL : self.class.new(major_minor.join("."))
// 691:   end
// 692:
// 693:   # The major, minor and patch version.
// 694:   #
// 695:   # @api public
// 696:   sig { returns(T.self_type) }
// 697:   def major_minor_patch
// 698:     return self if null?
// 699:
// 700:     major_minor_patch = T.must(tokens[0..2])
// 701:     major_minor_patch.empty? ? NULL : self.class.new(major_minor_patch.join("."))
// 702:   end
// 703:
// 704:   sig { returns(Integer) }
// 705:   def hash
// 706:     version.hash
// 707:   end
// 708:
// 709:   # Convert the version to a floating-point number.
// 710:   #
// 711:   # @api public
// 712:   sig { returns(Float) }
// 713:   def to_f
// 714:     return Float::NAN if null?
// 715:
// 716:     version.to_f
// 717:   end
// 718:
// 719:   # Convert the version to an integer.
// 720:   #
// 721:   # @api public
// 722:   sig { returns(Integer) }
// 723:   def to_i
// 724:     version.to_i
// 725:   end
// 726:
// 727:   # The implicit string conversion of this {Version}, for use where
// 728:   # a {String} is expected. Raises {NoMethodError} if this is a {NULL} version.
// 729:   #
// 730:   # @api public
// 731:   sig { returns(String) }
// 732:   def to_str
// 733:     raise NoMethodError, "undefined method `to_str` for #{self.class}:NULL" if null?
// 734:
// 735:     T.must(version).to_str
// 736:   end
// 737:
// 738:   # The string representation of this {Version}.
// 739:   #
// 740:   # @api public
// 741:   sig { returns(String) }
// 742:   def to_s = version.to_s
// 743:
// 744:   sig { params(options: T.untyped).returns(String) }
// 745:   def to_json(*options) = version.to_json(*options)
// 746:
// 747:   sig { params(method: T.any(Symbol, String), include_all: T::Boolean).returns(T::Boolean) }
// 748:   def respond_to?(method, include_all = false)
// 749:     return !null? if ["to_str", :to_str].include?(method)
// 750:
// 751:     super
// 752:   end
// 753:
// 754:   sig { returns(String) }
// 755:   def inspect
// 756:     return "#<Version::NULL>" if null?
// 757:
// 758:     "#<Version #{self}>"
// 759:   end
// 760:
// 761:   sig { returns(T.self_type) }
// 762:   def freeze
// 763:     tokens # Determine and store tokens before freezing
// 764:     super
// 765:   end
// 766:
// 767:   protected
// 768:
// 769:   sig { returns(T.nilable(String)) }
// 770:   attr_reader :version
// 771:
// 772:   sig { returns(T::Array[Token]) }
// 773:   def tokens
// 774:     @tokens ||= T.let(
// 775:       version&.scan(SCAN_PATTERN)&.map { |token| Token.create(T.cast(token, String)) } || [],
// 776:       T.nilable(T::Array[Token]),
// 777:     )
// 778:   end
// 779:
// 780:   # Represents the absence of a version.
// 781:   #
// 782:   # NOTE: Constructor needs to called with an arbitrary non-empty version which is then set to `nil`.
// 783:   NULL = T.let(Version.new("NULL").tap { |v| v.instance_variable_set(:@version, nil) }.freeze, Version)
// 784:
// 785:   private
// 786:
// 787:   sig { params(first: Integer, second: Integer).returns(Integer) }
// 788:   def max(first, second)
// 789:     [first, second].max
// 790:   end
// 791: end
