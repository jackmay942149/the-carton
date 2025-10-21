package label

import os "core:os"
import log "core:log"
import str "core:strings"
import conv "core:strconv"
import http "../dependencies/odin-http/client"
import json "core:encoding/json"

KV_Pair :: struct {
	key: string,
	cached_value: string,
	cell: string,
	sheet: string,
	sheet_id: string,
}

KV_Label :: struct {
	pairs: []KV_Pair,
}

load_label :: proc(path: string) -> (label: KV_Label) {
	// Load the label file
	label_data, ok := os.read_entire_file_from_filename(path)
	if !ok {
		log.error("Failed to load file, double check file path at: ", path)
	}
	label_string := transmute(string)label_data

	// Split the file by lines
	lines := str.split_lines(label_string)
	pairs := make([]KV_Pair, len(lines) - 1)
	for line, i in lines {
		line_split := str.split(line, ":")
		if len(line_split) != 5 do continue
		pairs[i].key          = str.trim_space(line_split[0])
		pairs[i].cached_value = str.trim_space(line_split[1])
		pairs[i].cell         = str.trim_space(line_split[2])
		pairs[i].sheet        = str.trim_space(line_split[3])
		pairs[i].sheet_id     = str.trim_space(line_split[4])
	}
		
	label.pairs = pairs
	return label
}

update_label :: proc(path_label, path_key: string) {
	key_data, ok := os.read_entire_file_from_filename(path_key)
	if !ok {
		log.fatal("Failed to find key from filepath:", path_key)
	}
	key := transmute(string)key_data
	label := load_label(path_label)
	for &pair in label.pairs {
		if pair.key != "" {
			label_request(&pair, key)
		}
	}
	write_label(path_label, label)
	log.info(label)
}

write_label :: proc(path: string, label: KV_Label) {
	builder : str.Builder
	b := str.builder_init(&builder)
	for pair in label.pairs {
		if pair.key == "" do continue
		str.write_string(b, pair.key)
		str.write_string(b, " : ")
		str.write_string(b, pair.cached_value)
		str.write_string(b, " : ")
		str.write_string(b, pair.cell)
		str.write_string(b, " : ")
		str.write_string(b, pair.sheet)
		str.write_string(b, " : ")
		str.write_string(b, pair.sheet_id)
		str.write_string(b, "\n")
	}
	os.write_entire_file(path, b.buf[:])
}

get_value_string :: proc(key: string, label: KV_Label) -> (value: string, found: bool) {
	for pair in label.pairs {
		if pair.key == key {
			return pair.cached_value, true
		}
	}
	return "", false
}

get_value_int :: proc(key: string, label: KV_Label) -> (value: int, found: bool) {
	value_as_string: string
	value_as_string, found = get_value_string(key, label)
	if !found {
		return 0, false
	}
	return conv.atoi(value_as_string), true
}

get_value_f64 :: proc(key: string, label: KV_Label) -> (value: f64, found: bool) {
	value_as_string: string
	value_as_string, found = get_value_string(key, label)
	if !found {
		return 0, false
	}
	return conv.atof(value_as_string), true
}

@(private)
label_request :: proc(pair: ^KV_Pair, key: string) {
	sheet_id := get_sheet_id_from_filepath(pair.sheet_id) 
	builder: str.Builder
	b := str.builder_init(&builder)
	str.write_string(b, "https://sheets.googleapis.com/v4/spreadsheets/")
	str.write_string(b, sheet_id)
	str.write_string(b, "/values/")
	str.write_string(b,  pair.sheet)
	str.write_string(b, "!")
	str.write_string(b,  pair.cell)
	str.write_string(b, "?key=")
	str.write_string(b, key)
	
	request := str.to_string(b^)
	request, _ = str.remove_all(request, "\r\n")

	res, err := http.get(request)
	if err != nil {
		log.fatal("Failed to make spreadsheet request:", err, request)
	}

	body, _, _ := http.response_body(&res)
	
	val_json, _ := json.parse_string(body.(http.Body_Plain))
	pair.cached_value = val_json.(json.Object)["values"].(json.Array)[0].(json.Array)[0].(json.String)
}

@(private)
get_sheet_id_from_filepath :: proc(path: string) ->(sheet_id: string) {
	sheet_id_data, ok := os.read_entire_file_from_filename(path)
	if !ok {
		log.fatal("File containing sheet id could not be found:", path)
	}
	sheet_id = transmute(string)sheet_id_data
	return sheet_id
}
