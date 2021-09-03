# Bomb


## Notes
- Enum.member? is O(n)
- https://hexdocs.pm/elixir/1.12/Process.html#monitor/1
- Cowboy will call websocket_info/2 whenever an Erlang message arrives.

```elixir
def websocket_info({:DOWN, ref, :process, object, reason}, State) do
    ...
end
```

## TODO:
- Add description
- Auth via google, ect...
- Redis storage
- Process monitor
