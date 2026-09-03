module vulns

import brew_runtime
import math

// Translated from Homebrew/brew `vulns/cvss.rb`.
// The original source is retained below until every stub has a typed V body.
pub enum CvssVersion {
	v3_0
	v3_1
}

pub enum CvssAttackVector {
	network
	adjacent
	local
	physical
}

pub enum CvssAttackComplexity {
	low
	high
}

pub enum CvssPrivilegesRequired {
	none
	low
	high
}

pub enum CvssUserInteraction {
	none
	required
}

pub enum CvssScope {
	unchanged
	changed
}

pub enum CvssImpact {
	none
	low
	high
}

pub enum CvssSeverity {
	low
	medium
	high
	critical
}

// CvssMetrics keeps validated base metrics typed while retaining extra metric
// pairs for a source-faithful Hash adapter. Temporal and environmental metrics
// are intentionally retained but do not participate in the base score.
pub struct CvssMetrics {
pub:
	version             CvssVersion
	attack_vector       CvssAttackVector
	attack_complexity   CvssAttackComplexity
	privileges_required CvssPrivilegesRequired
	user_interaction    CvssUserInteraction
	scope               CvssScope
	confidentiality     CvssImpact
	integrity           CvssImpact
	availability        CvssImpact
mut:
	metric_values map[string]string
}

pub fn (metrics CvssMetrics) values() map[string]string {
	return metrics.metric_values.clone()
}

pub fn (severity CvssSeverity) symbol() string {
	return match severity {
		.low { 'low' }
		.medium { 'medium' }
		.high { 'high' }
		.critical { 'critical' }
	}
}

fn cvss_version(prefix string) ?CvssVersion {
	if prefix == 'CVSS:3.0' {
		return .v3_0
	}
	if prefix == 'CVSS:3.1' {
		return .v3_1
	}
	return none
}

fn cvss_attack_vector(value string) ?CvssAttackVector {
	return match value {
		'N' { CvssAttackVector.network }
		'A' { CvssAttackVector.adjacent }
		'L' { CvssAttackVector.local }
		'P' { CvssAttackVector.physical }
		else { none }
	}
}

fn cvss_attack_complexity(value string) ?CvssAttackComplexity {
	return match value {
		'L' { CvssAttackComplexity.low }
		'H' { CvssAttackComplexity.high }
		else { none }
	}
}

fn cvss_privileges_required(value string) ?CvssPrivilegesRequired {
	return match value {
		'N' { CvssPrivilegesRequired.none }
		'L' { CvssPrivilegesRequired.low }
		'H' { CvssPrivilegesRequired.high }
		else { none }
	}
}

fn cvss_user_interaction(value string) ?CvssUserInteraction {
	return match value {
		'N' { CvssUserInteraction.none }
		'R' { CvssUserInteraction.required }
		else { none }
	}
}

fn cvss_scope(value string) ?CvssScope {
	return match value {
		'U' { CvssScope.unchanged }
		'C' { CvssScope.changed }
		else { none }
	}
}

fn cvss_impact(value string) ?CvssImpact {
	return match value {
		'N' { CvssImpact.none }
		'L' { CvssImpact.low }
		'H' { CvssImpact.high }
		else { none }
	}
}

fn cvss_metrics_from_values(version CvssVersion, values map[string]string) ?CvssMetrics {
	for name in ['AV', 'AC', 'PR', 'UI', 'S', 'C', 'I', 'A'] {
		if name !in values {
			return none
		}
	}
	attack_vector := cvss_attack_vector(values['AV']) or { return none }
	attack_complexity := cvss_attack_complexity(values['AC']) or { return none }
	privileges_required := cvss_privileges_required(values['PR']) or { return none }
	user_interaction := cvss_user_interaction(values['UI']) or { return none }
	scope := cvss_scope(values['S']) or { return none }
	confidentiality := cvss_impact(values['C']) or { return none }
	integrity := cvss_impact(values['I']) or { return none }
	availability := cvss_impact(values['A']) or { return none }
	return CvssMetrics{
		version: version
		attack_vector: attack_vector
		attack_complexity: attack_complexity
		privileges_required: privileges_required
		user_interaction: user_interaction
		scope: scope
		confidentiality: confidentiality
		integrity: integrity
		availability: availability
		metric_values: values.clone()
	}
}

pub fn parse_cvss_vector(vector string) ?CvssMetrics {
	parts := vector.split('/')
	if parts.len == 0 {
		return none
	}
	version := cvss_version(parts[0]) or { return none }
	mut values := map[string]string{}
	for part in parts[1..] {
		separator := part.index(':') or {
			values[part] = ''
			continue
		}
		values[part[..separator]] = part[separator + 1..]
	}
	return cvss_metrics_from_values(version, values)
}

pub fn cvss_valid_values(values map[string]string) bool {
	return cvss_metrics_from_values(.v3_1, values) != none
}

fn cvss_attack_vector_weight(value CvssAttackVector) f64 {
	return match value {
		.network { 0.85 }
		.adjacent { 0.62 }
		.local { 0.55 }
		.physical { 0.2 }
	}
}

fn cvss_attack_complexity_weight(value CvssAttackComplexity) f64 {
	return match value {
		.low { 0.77 }
		.high { 0.44 }
	}
}

fn cvss_privileges_required_weight(value CvssPrivilegesRequired, scope CvssScope) f64 {
	if scope == .changed {
		return match value {
			.none { 0.85 }
			.low { 0.68 }
			.high { 0.50 }
		}
	}
	return match value {
		.none { 0.85 }
		.low { 0.62 }
		.high { 0.27 }
	}
}

fn cvss_user_interaction_weight(value CvssUserInteraction) f64 {
	return match value {
		.none { 0.85 }
		.required { 0.62 }
	}
}

fn cvss_impact_weight(value CvssImpact) f64 {
	return match value {
		.none { 0.0 }
		.low { 0.22 }
		.high { 0.56 }
	}
}

// cvss_round_up implements CVSS v3.x Appendix A Roundup exactly: values are
// first stabilized to five decimal places and then rounded upward to one.
pub fn cvss_round_up(value f64) f64 {
	integer := i64(math.round(value * 100_000.0))
	if integer % 10_000 == 0 {
		return f64(integer) / 100_000.0
	}
	return f64(integer / 10_000 + 1) / 10.0
}

pub fn cvss_base_score(vector string) ?f64 {
	metrics := parse_cvss_vector(vector) or { return none }
	c := cvss_impact_weight(metrics.confidentiality)
	i := cvss_impact_weight(metrics.integrity)
	a := cvss_impact_weight(metrics.availability)
	iss := 1.0 - ((1.0 - c) * (1.0 - i) * (1.0 - a))
	impact := if metrics.scope == .changed {
		(7.52 * (iss - 0.029)) - (3.25 * math.pow(iss - 0.02, 15.0))
	} else {
		6.42 * iss
	}
	if impact <= 0.0 {
		return 0.0
	}
	exploitability := 8.22 * cvss_attack_vector_weight(metrics.attack_vector) * cvss_attack_complexity_weight(metrics.attack_complexity) * cvss_privileges_required_weight(metrics.privileges_required, metrics.scope) * cvss_user_interaction_weight(metrics.user_interaction)
	mut raw := impact + exploitability
	if metrics.scope == .changed {
		raw *= 1.08
	}
	return cvss_round_up(if raw < 10.0 { raw } else { 10.0 })
}

pub fn cvss_severity_for_score(score f64) ?CvssSeverity {
	if score >= 9.0 {
		return .critical
	}
	if score >= 7.0 {
		return .high
	}
	if score >= 4.0 {
		return .medium
	}
	if score > 0.0 {
		return .low
	}
	return none
}

pub fn cvss_severity(vector string) ?CvssSeverity {
	score := cvss_base_score(vector) or { return none }
	return cvss_severity_for_score(score)
}

fn cvss_metrics_value(metrics CvssMetrics) brew_runtime.Value {
	mut values := map[string]brew_runtime.Value{}
	for name, value in metrics.values() {
		values[name] = brew_runtime.string_value(value)
	}
	return brew_runtime.map_value(values)
}

fn cvss_values_from_boundary(value brew_runtime.Value) ?map[string]string {
	if value.type_name != 'Hash' {
		return none
	}
	mut values := map[string]string{}
	for name, metric in value.map_data {
		if metric.type_name != 'String' {
			return none
		}
		values[name] = metric.as_string()
	}
	return values
}

// Ruby method `self.base_score(vector)` at line 23.
pub fn ruby_cvss_l23_d1_self_base_score(args ...brew_runtime.Value) brew_runtime.Value {
	vector := if args.len > 0 { args[0].as_string() } else { '' }
	return if score := cvss_base_score(vector) {
		brew_runtime.float_value(score)
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby method `self.severity(vector)` at line 53.
pub fn ruby_cvss_l53_d2_self_severity(args ...brew_runtime.Value) brew_runtime.Value {
	vector := if args.len > 0 { args[0].as_string() } else { '' }
	return if severity := cvss_severity(vector) {
		brew_runtime.object_value('Symbol', severity.symbol())
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby method `self.parse(vector)` at line 68.
pub fn ruby_cvss_l68_d3_self_parse(args ...brew_runtime.Value) brew_runtime.Value {
	vector := if args.len > 0 { args[0].as_string() } else { '' }
	return if metrics := parse_cvss_vector(vector) {
		cvss_metrics_value(metrics)
	} else {
		brew_runtime.object_value('NilClass', 'nil')
	}
}

// Ruby method `self.valid_values?(metrics)` at line 83.
pub fn ruby_cvss_l83_d4_self_valid_values(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.bool_value(false)
	}
	values := cvss_values_from_boundary(args[0]) or {
		return brew_runtime.bool_value(false)
	}
	return brew_runtime.bool_value(cvss_valid_values(values))
}

// Ruby method `self.round_up(value)` at line 96.
pub fn ruby_cvss_l96_d5_self_round_up(args ...brew_runtime.Value) brew_runtime.Value {
	if args.len == 0 {
		return brew_runtime.object_value('NilClass', 'nil')
	}
	value := args[0].as_float() or { panic(err) }
	return brew_runtime.float_value(cvss_round_up(value))
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: module Homebrew
// 5:   module Vulns
// 6:     # CVSS v3.0/v3.1 base score and qualitative severity rating.
// 7:     # See https://www.first.org/cvss/v3-1/specification-document.
// 8:     # v2 and v4.0 vectors return `nil` so callers fall through to the next
// 9:     # available severity source.
// 10:     module CVSS
// 11:       AV = T.let({ "N" => 0.85, "A" => 0.62, "L" => 0.55, "P" => 0.2 }.freeze, T::Hash[String, Float])
// 12:       AC = T.let({ "L" => 0.77, "H" => 0.44 }.freeze, T::Hash[String, Float])
// 13:       UI = T.let({ "N" => 0.85, "R" => 0.62 }.freeze, T::Hash[String, Float])
// 14:       CIA = T.let({ "N" => 0.0, "L" => 0.22, "H" => 0.56 }.freeze, T::Hash[String, Float])
// 15:       PR_UNCHANGED = T.let({ "N" => 0.85, "L" => 0.62, "H" => 0.27 }.freeze, T::Hash[String, Float])
// 16:       PR_CHANGED = T.let({ "N" => 0.85, "L" => 0.68, "H" => 0.50 }.freeze, T::Hash[String, Float])
// 17:       private_constant :AV, :AC, :UI, :CIA, :PR_UNCHANGED, :PR_CHANGED
// 18:
// 19:       BASE_METRICS = %w[AV AC PR UI S C I A].freeze
// 20:       private_constant :BASE_METRICS
// 21:
// 22:       sig { params(vector: String).returns(T.nilable(Float)) }
// 23:       def self.base_score(vector)
// 24:         metrics = parse(vector)
// 25:         return if metrics.nil?
// 26:
// 27:         scope_changed = metrics.fetch("S") == "C"
// 28:         pr_table = scope_changed ? PR_CHANGED : PR_UNCHANGED
// 29:
// 30:         av  = AV.fetch(metrics.fetch("AV"))
// 31:         ac  = AC.fetch(metrics.fetch("AC"))
// 32:         pr  = pr_table.fetch(metrics.fetch("PR"))
// 33:         ui  = UI.fetch(metrics.fetch("UI"))
// 34:         c   = CIA.fetch(metrics.fetch("C"))
// 35:         i   = CIA.fetch(metrics.fetch("I"))
// 36:         a   = CIA.fetch(metrics.fetch("A"))
// 37:
// 38:         iss = 1 - ((1 - c) * (1 - i) * (1 - a))
// 39:         impact = if scope_changed
// 40:           (7.52 * (iss - 0.029)) - (3.25 * ((iss - 0.02)**15))
// 41:         else
// 42:           6.42 * iss
// 43:         end
// 44:         return 0.0 if impact <= 0
// 45:
// 46:         exploitability = 8.22 * av * ac * pr * ui
// 47:         raw = impact + exploitability
// 48:         raw *= 1.08 if scope_changed
// 49:         round_up([raw, 10.0].min)
// 50:       end
// 51:
// 52:       sig { params(vector: String).returns(T.nilable(Symbol)) }
// 53:       def self.severity(vector)
// 54:         score = base_score(vector)
// 55:         return if score.nil?
// 56:
// 57:         if score >= 9.0 then :critical
// 58:         elsif score >= 7.0 then :high
// 59:         elsif score >= 4.0 then :medium
// 60:         elsif score > 0.0 then :low
// 61:         end
// 62:       end
// 63:
// 64:       SUPPORTED_PREFIXES = %w[CVSS:3.0 CVSS:3.1].freeze
// 65:       private_constant :SUPPORTED_PREFIXES
// 66:
// 67:       sig { params(vector: String).returns(T.nilable(T::Hash[String, String])) }
// 68:       private_class_method def self.parse(vector)
// 69:         parts = vector.split("/")
// 70:         return unless SUPPORTED_PREFIXES.include?(parts.shift)
// 71:
// 72:         metrics = parts.to_h do |part|
// 73:           pair = part.split(":", 2)
// 74:           [pair[0] || "", pair[1] || ""]
// 75:         end
// 76:         return unless BASE_METRICS.all? { |m| metrics.key?(m) }
// 77:         return unless valid_values?(metrics)
// 78:
// 79:         metrics
// 80:       end
// 81:
// 82:       sig { params(metrics: T::Hash[String, String]).returns(T::Boolean) }
// 83:       private_class_method def self.valid_values?(metrics)
// 84:         AV.key?(metrics.fetch("AV")) &&
// 85:           AC.key?(metrics.fetch("AC")) &&
// 86:           PR_UNCHANGED.key?(metrics.fetch("PR")) &&
// 87:           UI.key?(metrics.fetch("UI")) &&
// 88:           %w[U C].include?(metrics.fetch("S")) &&
// 89:           CIA.key?(metrics.fetch("C")) &&
// 90:           CIA.key?(metrics.fetch("I")) &&
// 91:           CIA.key?(metrics.fetch("A"))
// 92:       end
// 93:
// 94:       # CVSS v3.x "Roundup" (spec Appendix A).
// 95:       sig { params(value: Float).returns(Float) }
// 96:       private_class_method def self.round_up(value)
// 97:         int = (value * 100_000).round
// 98:         return int / 100_000.0 if (int % 10_000).zero?
// 99:
// 100:         ((int / 10_000) + 1) / 10.0
// 101:       end
// 102:     end
// 103:   end
// 104: end
