module vulns

import brew_runtime

// Translated from Homebrew/brew `vulns/repology.rb`.
// The original source is retained below until every stub has a typed V body.

// Ruby method `self.data_url = DATA_URL` at line 22.
pub fn ruby_repology_l22_d1_self_data_url(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.data_url', ...args)
}

// Ruby method `self.cache_filename = "repology.json"` at line 25.
pub fn ruby_repology_l25_d2_self_cache_filename(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.cache_filename', ...args)
}

// Ruby method `self.default_max_age = 7 * 86_400` at line 28.
pub fn ruby_repology_l28_d3_self_default_max_age(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.default_max_age', ...args)
}

// Ruby method `self.base_name(name) = name.sub(/@.+\z/, "")` at line 33.
pub fn ruby_repology_l33_d4_self_base_name(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.base_name', ...args)
}

// Ruby method `initialize(data)` at line 36.
pub fn ruby_repology_l36_d5_initialize(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('initialize', ...args)
}

// Ruby attr_reader `attr_reader :meta` at line 46.
pub fn ruby_repology_l46_d6_meta(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('meta', ...args)
}

// Ruby method `formulae` at line 49.
pub fn ruby_repology_l49_d7_formulae(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('formulae', ...args)
}

// Ruby method `distro_packages_for(formula_name)` at line 58.
pub fn ruby_repology_l58_d8_distro_packages_for(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('distro_packages_for', ...args)
}

// Ruby method `self.lookup(formula_name)` at line 112.
pub fn ruby_repology_l112_d9_self_lookup(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.lookup', ...args)
}

// Ruby method `self.resolve_contributions(contributions)` at line 140.
pub fn ruby_repology_l140_d10_self_resolve_contributions(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.resolve_contributions', ...args)
}

// Ruby method `self.homebrew_entries(entries)` at line 146.
pub fn ruby_repology_l146_d11_self_homebrew_entries(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.homebrew_entries', ...args)
}

// Ruby method `self.name_candidates(formula_name)` at line 161.
pub fn ruby_repology_l161_d12_self_name_candidates(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.name_candidates', ...args)
}

// Ruby method `self.fetch_project(project)` at line 177.
pub fn ruby_repology_l177_d13_self_fetch_project(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.fetch_project', ...args)
}

// Ruby method `self.distil(entries)` at line 190.
pub fn ruby_repology_l190_d14_self_distil(args ...brew_runtime.Value) brew_runtime.Value {
	return brew_runtime.unimplemented_fn('self.distil', ...args)
}

// Original Ruby source (line-for-line):
// 1: # typed: strict
// 2: # frozen_string_literal: true
// 3:
// 4: require "utils/repology"
// 5: require "vulns/cached_feed"
// 6:
// 7: module Homebrew
// 8:   module Vulns
// 9:     # Reader for the Repology-derived formula → distro-package index published
// 10:     # by Homebrew/advisory-database (`data/repology.json`, built by that
// 11:     # repository's `RepologyIndex` via `rake repology:build`).
// 12:     #
// 13:     # The index maps each formula name to its source-package names in
// 14:     # OSV.dev-covered distro ecosystems so {Vulns::Match} can query those
// 15:     # ecosystems' advisories. {.lookup} provides a live single-project API
// 16:     # fallback for formulae the published index doesn't yet cover.
// 17:     class Repology < CachedFeed
// 18:       DATA_URL = "https://raw.githubusercontent.com/Homebrew/advisory-database/" \
// 19:                  "main/data/repology.json"
// 20:
// 21:       sig { override.returns(String) }
// 22:       def self.data_url = DATA_URL
// 23:
// 24:       sig { override.returns(String) }
// 25:       def self.cache_filename = "repology.json"
// 26:
// 27:       sig { override.returns(Integer) }
// 28:       def self.default_max_age = 7 * 86_400
// 29:
// 30:       DistroMap = T.type_alias { T::Hash[String, T::Array[String]] }
// 31:
// 32:       sig { params(name: String).returns(String) }
// 33:       def self.base_name(name) = name.sub(/@.+\z/, "")
// 34:
// 35:       sig { override.params(data: T.anything).void }
// 36:       def initialize(data)
// 37:         super
// 38:         raise Error, "Repology index is not a JSON object" unless (top = as_hash(data))
// 39:         raise Error, "Repology index missing 'formulae' key" unless (formulae = as_hash(top["formulae"]))
// 40:
// 41:         @formulae = T.let(formulae, T::Hash[String, T.untyped])
// 42:         @meta = T.let(as_hash(top["meta"]) || {}, T::Hash[String, T.untyped])
// 43:       end
// 44:
// 45:       sig { returns(T::Hash[String, T.untyped]) }
// 46:       attr_reader :meta
// 47:
// 48:       sig { returns(T::Array[String]) }
// 49:       def formulae
// 50:         @formulae.keys
// 51:       end
// 52:
// 53:       # Returns `{osv_ecosystem => [srcname, ...]}` for `formula_name`, or an
// 54:       # empty hash if the index has no entry. The index is keyed on the
// 55:       # Homebrew formula name as Repology records it, so `@`-versioned
// 56:       # variants (`postgresql@16`) are looked up under their base name too.
// 57:       sig { params(formula_name: String).returns(DistroMap) }
// 58:       def distro_packages_for(formula_name)
// 59:         entry = @formulae[formula_name] || @formulae[self.class.base_name(formula_name)]
// 60:         return {} unless entry.is_a?(Hash)
// 61:
// 62:         entry.filter_map do |eco, names|
// 63:           next unless eco.is_a?(String)
// 64:
// 65:           list = Array(names).grep(String)
// 66:           [eco, list.freeze] if list.any?
// 67:         end.to_h.freeze
// 68:       end
// 69:
// 70:       # Repology repo-name prefix => `{ecosystem:, name_field:}`. Kept in step
// 71:       # with `RepologyIndex::OSV_DISTROS` in Homebrew/advisory-database; only
// 72:       # the fields {.distil} needs are duplicated here.
// 73:       OSV_DISTROS = T.let(
// 74:         {
// 75:           "debian_"             => { ecosystem: "Debian" },
// 76:           "ubuntu_"             => { ecosystem: "Ubuntu" },
// 77:           "alpine_"             => { ecosystem: "Alpine" },
// 78:           "opensuse_leap_"      => { ecosystem: "openSUSE" },
// 79:           "opensuse_tumbleweed" => { ecosystem: "openSUSE" },
// 80:           "rocky_"              => { ecosystem: "Rocky Linux" },
// 81:           "almalinux_"          => { ecosystem: "AlmaLinux" },
// 82:           "mageia_"             => { ecosystem: "Mageia" },
// 83:           "openeuler_"          => { ecosystem: "openEuler" },
// 84:           "ubi_"                => { ecosystem: "Red Hat" },
// 85:           "freebsd"             => { ecosystem: "FreeBSD", name_field: "binname" },
// 86:         }.freeze,
// 87:         T::Hash[String, { ecosystem: String, name_field: T.nilable(String) }],
// 88:       )
// 89:       private_constant :OSV_DISTROS
// 90:
// 91:       # Kept in step with `RepologyIndex::PREFERRED_STATUSES`.
// 92:       PREFERRED_STATUSES = %w[newest outdated devel unique noscheme].freeze
// 93:       private_constant :PREFERRED_STATUSES
// 94:
// 95:       # Live single-project fallback for a formula the published index does
// 96:       # not cover: a new formula in a homebrew-core PR before the next nightly
// 97:       # index build, or one the index put in `meta.ambiguous_projects`.
// 98:       #
// 99:       # Fetches each project in {.name_candidates}, keeps those whose Homebrew
// 100:       # entries include `formula_name` (or its `@`-stripped base), then applies
// 101:       # the same preferred-status resolution as `RepologyIndex#resolve` across
// 102:       # the survivors. Unlike the index builder, a project that also lists
// 103:       # sibling formulae with a different base (`wget` + `wget2`, `sqlite` +
// 104:       # `sqlite-analyzer`, `ffmpeg` + a third-party `ffmpeg-full`) is *not*
// 105:       # rejected: the distro srcnames for the sibling flow through as extra
// 106:       # low-confidence distro queries whose upstream-CVE range check will not
// 107:       # match this formula's identity, so the cost is uncomparable noise rather
// 108:       # than a wrong `:affected`/`:fixed` claim. This cannot detect collisions
// 109:       # with projects outside {.name_candidates} (e.g. `allegro4`), which only
// 110:       # the full crawl sees.
// 111:       sig { params(formula_name: String).returns(DistroMap) }
// 112:       def self.lookup(formula_name)
// 113:         base = base_name(formula_name)
// 114:         exact = []
// 115:         by_base = []
// 116:         name_candidates(formula_name).each do |candidate|
// 117:           entries = fetch_project(candidate)
// 118:           next if entries.empty?
// 119:
// 120:           brew = homebrew_entries(entries)
// 121:           distros = distil(entries)
// 122:           next if distros.empty?
// 123:
// 124:           # A project listing both the exact and base names contributes to both
// 125:           # pools, matching the producer's per-key contributions.
// 126:           exact << { preferred: brew.fetch(formula_name), distros: } if brew.key?(formula_name)
// 127:           by_base << { preferred: brew.fetch(base), distros: } if base != formula_name && brew.key?(base)
// 128:         end
// 129:
// 130:         # Resolve the exact-name pool first, mirroring
// 131:         # `#distro_packages_for`'s `@formulae[name] || @formulae[base]`
// 132:         # precedence over the producer's per-key resolved index.
// 133:         resolve_contributions(exact) || resolve_contributions(by_base) || {}
// 134:       end
// 135:
// 136:       sig {
// 137:         params(contributions: T::Array[{ preferred: T::Boolean, distros: DistroMap }])
// 138:           .returns(T.nilable(DistroMap))
// 139:       }
// 140:       def self.resolve_contributions(contributions)
// 141:         chosen = contributions.one? ? contributions : contributions.select { |c| c.fetch(:preferred) }
// 142:         chosen.fetch(0).fetch(:distros) if chosen.one?
// 143:       end
// 144:
// 145:       sig { params(entries: T::Array[T::Hash[String, T.untyped]]).returns(T::Hash[String, T::Boolean]) }
// 146:       def self.homebrew_entries(entries)
// 147:         result = {}
// 148:         entries.each do |e|
// 149:           next if e["repo"] != "homebrew"
// 150:
// 151:           name = (e["srcname"] || e["binname"]).to_s
// 152:           next if name.empty?
// 153:
// 154:           result[name] ||= false
// 155:           result[name] = true if PREFERRED_STATUSES.include?(e["status"])
// 156:         end
// 157:         result
// 158:       end
// 159:
// 160:       sig { params(formula_name: String).returns(T::Array[String]) }
// 161:       def self.name_candidates(formula_name)
// 162:         base = base_name(formula_name)
// 163:         [
// 164:           formula_name,
// 165:           base,
// 166:           base.delete_prefix("lib"),
// 167:           base.delete_prefix("gnu-"),
// 168:           base.delete_suffix("2"),
// 169:         ].uniq.reject(&:empty?)
// 170:       end
// 171:
// 172:       # Fetch one Repology project. A nonexistent project returns HTTP 200 with
// 173:       # `[]`, so an empty array is the only "try next candidate" signal;
// 174:       # transport failures, HTTP errors, malformed JSON and unexpected shapes
// 175:       # all raise so callers don't mistake an outage for "no packages".
// 176:       sig { params(project: String).returns(T::Array[T::Hash[String, T.untyped]]) }
// 177:       def self.fetch_project(project)
// 178:         result = ::Repology.single_package_query(project, repository: ::Repology::HOMEBREW_CORE)
// 179:         raise Error, "Repology API request for #{project.inspect} failed" if result.nil?
// 180:
// 181:         entries = result.fetch(project)
// 182:         if !entries.is_a?(Array) || !entries.all?(Hash)
// 183:           raise Error, "Repology API returned unexpected shape for #{project.inspect}"
// 184:         end
// 185:
// 186:         entries
// 187:       end
// 188:
// 189:       sig { params(entries: T::Array[T::Hash[String, T.untyped]]).returns(DistroMap) }
// 190:       def self.distil(entries)
// 191:         result = Hash.new { |h, k| h[k] = [] }
// 192:         entries.each do |entry|
// 193:           repo = entry["repo"]
// 194:           next unless repo.is_a?(String)
// 195:
// 196:           distro = OSV_DISTROS.find { |prefix, _| repo.start_with?(prefix) }&.last
// 197:           next unless distro
// 198:           next if entry["status"] == "legacy"
// 199:
// 200:           name = entry[distro[:name_field] || "srcname"] || entry["binname"]
// 201:           next unless name.is_a?(String)
// 202:
// 203:           result[distro.fetch(:ecosystem)] << name
// 204:         end
// 205:         result.transform_values! { |names| names.uniq.sort.freeze }
// 206:         result.default = nil
// 207:         result.sort.to_h.freeze
// 208:       end
// 209:     end
// 210:   end
// 211: end
