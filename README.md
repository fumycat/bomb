# Bomb

## dev

    npm install -g elm
    elm make elm/Game.elm --output static/game.js
    elm make elm/Index.elm --output static/index.js
    mix deps.get
    iex -S mix


## notes

Auto compile elm on save:

    while inotifywait -e close_write elm/Game.elm; do elm make elm/Game.elm --output static/game.js; done

Recompile elixir module (iex):

    r Module

## todo

https://hexdocs.pm/elixir/1.12/Process.html#send_after/3

https://hexdocs.pm/elixir/1.12/DynamicSupervisor.html#terminate_child/2
