all: index settings game

index:
	elm make --output=static/index.js elm/Index.elm

settings:
	elm make --output=static/settings.js elm/Settings.elm

game:
	elm make --output=static/game.js elm/Game.elm
