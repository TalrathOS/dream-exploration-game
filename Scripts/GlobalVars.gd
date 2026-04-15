extends Node
var playerStats:Dictionary

func getStats(file):
	var data: Dictionary = TOML.parse(file)
	playerStats = data.playerStats
	print('successfully read file')
	print(playerStats)
