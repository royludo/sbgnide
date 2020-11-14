extends Node

# global status of external stuff
var is_java_working:bool = false
var is_sbgn_backend_configured:bool = false
var is_sbgn_backend_working:bool = false
var is_git_working:bool = false


var current_project_dir

var data

const DEFAULT_CONFIG_PATH:String = "user://settings.conf" 
var config:ConfigFile = ConfigFile.new()
var currentViewport

enum MouseMode {SELECT, ADD_GLYPH, ADD_ARC}
var currentMouseMode = MouseMode.SELECT
