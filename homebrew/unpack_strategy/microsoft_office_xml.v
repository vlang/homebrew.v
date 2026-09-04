module unpack_strategy

// Translated from Homebrew/brew `unpack_strategy/microsoft_office_xml.rb`.

pub fn microsoft_office_xml_extensions() []string {
	return ['.doc', '.docx', '.ppt', '.pptx', '.xls', '.xlsx']
}

pub fn microsoft_office_xml_can_extract(path string) bool {
	if !file_starts_with(path, [u8(`P`), `K`, 0x03, 0x04]) {
		return false
	}
	return file_has_bytes_at(path, 30, '[Content_Types].xml'.bytes())
		|| file_has_bytes_at(path, 30, '_rels/.rels'.bytes())
}
