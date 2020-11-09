tool
extends Node
class_name SBGNServer

var pathToServer:String
var serverAddress = "http://localhost:4567/"
var pathToJava
var serverPID = null
onready var HRservice = $HTTPRequest


func constructor(pathToJava, pathToServerJar):
	self.pathToServer = pathToServerJar
	self.pathToJava = pathToJava

func start():
	print("sbgn server starting")
	serverPID = OS.execute(pathToJava, ["-jar", pathToServer, "--local"], false)
	print("PID: "+str(serverPID))

func load_file(path):
	var headers = ["Content-Type: application/json"]
	var query = JSON.print({"filepath":path})
	print("query: "+query)
	var error = HRservice.request(serverAddress + str("readfile"),\
	 headers, false, HTTPClient.METHOD_POST, query)
	return error

func shutdown():
	var error = HRservice.request(serverAddress + str("shutdown"),\
	 PoolStringArray(), false, HTTPClient.METHOD_POST)
	return error

func keepalive():
	var error = HRservice.request(serverAddress + str("keepalive"),\
	  PoolStringArray(), false, HTTPClient.METHOD_POST)
	return error
