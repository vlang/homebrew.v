module homebrew

import ruby
import time

const sbom_filename = 'sbom.spdx.json'

fn sbom_time(epoch i64) string {
	return time.unix(epoch).format_rfc3339().replace('.000Z', 'Z')
}

fn sbom_percent_encode(value string) string {
	mut encoded := ''
	for character in value.bytes() {
		if (character >= `a` && character <= `z`) || (character >= `A` && character <= `Z`) || (character >= `0` && character <= `9`) || character in [
			`-`,
			`.`,
			`_`,
			`~`,
		] {
			encoded += character.ascii_str()
		} else {
			encoded += '%${character.hex().to_upper()}'
		}
	}
	return encoded
}

fn sbom_purl(full_name string, version string) string {
	parts := full_name.split('/')
	name := if parts.len > 0 { parts.last() } else { full_name }
	namespace := if parts.len > 1 { parts[..parts.len - 1].join('/') } else { '' }
	mut result := 'pkg:brew/'
	if namespace != '' {
		result += '${namespace}/'
	}
	result += sbom_percent_encode(name)
	if version != '' {
		result += '@${sbom_percent_encode(version)}'
	}
	return result
}

fn sbom_upstream_purl(url string, version string) string {
	if url.contains('files.pythonhosted.org') {
		filename := url.all_after_last('/')
		name := filename.all_before_last('-')
		if name != '' {
			return 'pkg:pypi/${sbom_percent_encode(name)}@${sbom_percent_encode(version)}'
		}
	}
	return ''
}

fn sbom_state(name string, spdxfile string, source_modified_time i64, compiler string,
	stdlib string, runtime_dependencies []ruby.Value, license string,
	built_on ruby.Value, source ruby.Value) ruby.Value {
	return ruby.Value{
		type_name: 'SBOM'
		repr: name
		attributes: {
			'name':                 name
			'spdxfile':             spdxfile
			'source_modified_time': source_modified_time.str()
			'compiler':             compiler
			'stdlib':               stdlib
			'license':              license
		}
		map_data: {
			'runtime_dependencies': ruby.array_value(runtime_dependencies)
			'built_on':             built_on
			'source':               source
		}
	}
}

// Translated from Homebrew/brew `sbom.rb`.
