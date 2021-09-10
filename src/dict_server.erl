-module(dict_server).
-behaviour(gen_server).

-export([start_link/0]).
-export([check/1]).
-export([init/1, handle_call/3, handle_cast/2]).


start_link() ->
    gen_server:start_link({global, dict_server}, dict_server, [], []).

check(Word) ->
    gen_server:call({global, dict_server}, {exists, Word}).

init(_Args) ->
    Set = open_dict_file(),
    {ok, Set}.

handle_call({exists, Key}, _From, D) ->
    Str = binary_to_list(Key),
    V = gb_sets:is_element(Str, D),
    {reply, V, D}.

handle_cast(_, D) ->
    {noreply, D}.

lines(Device, Set) ->
    case io:get_line(Device, "") of
        eof ->
            Set;
        Data ->
            Str = string:trim(Data),
            lines(Device, gb_sets:add(Str, Set))
    end.

open_dict_file() ->
    Set = gb_sets:new(),
    {ok, Device} = file:open("dictionary/words.txt", [read]),
    try lines(Device, Set)
      after file:close(Device)
    end.
