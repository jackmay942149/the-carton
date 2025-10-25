package carton

import os   "core:os"
import log  "core:log"
import json "core:encoding/json"

Project_File :: struct {
	json_data: json.Value,
	scene:     string,
}

@(private)
project_load_file :: proc(filepath: string) -> (project: Project_File) {
	project_data, ok := os.read_entire_file_from_filename(filepath)		
	assert(ok)

	err : json.Error
	project.json_data, err = json.parse(project_data)
	if err != nil {
		log.fatal(err)
		assert(false)
	}
	project.scene = project.json_data.(json.Object)["scene"].(json.String)
	return project
}

