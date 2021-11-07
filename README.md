# Bomb

## notes

    while inotifywait -e close_write elm/Game.elm; do elm make elm/Game.elm --output static/game.js; done

## todo

~~Browser.Events.onKeyDown не умеет в русские буквы (мб ловить эвенты на стороне жса и слать через порт)~~

https://hexdocs.pm/elixir/1.12/Process.html#send_after/3

https://hexdocs.pm/elixir/1.12/DynamicSupervisor.html#terminate_child/2

убрать проверку в функции broadcast
