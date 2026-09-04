module vulns

import ruby
import math

// Translated from Homebrew/brew `vulns/cvss.rb`.
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

fn cvss_metrics_value(metrics CvssMetrics) ruby.Value {
	mut values := map[string]ruby.Value{}
	for name, value in metrics.values() {
		values[name] = ruby.string_value(value)
	}
	return ruby.map_value(values)
}

fn cvss_values_from_boundary(value ruby.Value) ?map[string]string {
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
