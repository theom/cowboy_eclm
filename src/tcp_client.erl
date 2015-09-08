-module(tcp_client).

-export([start/0]).

start() ->
    {ok, Socket} = gen_tcp:connect("localhost", 9000, [binary, {packet, 0}, {active, once}]),
    gen_tcp:send(Socket, <<"hello">>),
    receive_loop(Socket, <<"">>).

receive_loop(Socket, Acc) ->
    receive
        {tcp, Socket, Data} ->
            %io:format("Received: ~p~n", [Data]),
            Acc1 = binary:list_to_bin([Data | Acc]),
            io:format("Bytes received so far: ~p~n", [byte_size(Acc1)]),
            timer:sleep(100),
            inet:setopts(Socket, [{active, once}]),
            receive_loop(Socket, Acc1);
        {tcp_closed, Socket} ->
            io:format("Server closed the connection~n");
        {tcp_error, Socket, Reason} ->
            io:format("Error on socket ~p, reason: ~p~n", [Socket, Reason])
    end.
