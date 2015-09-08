-module(tcp_server).

-export([start/0, connect/1, recv_loop/2]).

-define(TCP_OPTS, [binary, {packet, raw}, {nodelay, true}, {reuseaddr, true}, {active, once}]).

start() ->
    case gen_tcp:listen(9000, ?TCP_OPTS) of
        {ok, Listen} ->
            spawn(?MODULE, connect, [Listen]),
            io:format("~p Server Started.~n", [erlang:localtime()]);
        Error -> io:format("Error: ~p~n", [Error])
    end. 

connect(Listen) ->
    {ok, Socket} = gen_tcp:accept(Listen),
    inet:setopts(Socket, ?TCP_OPTS),
    spawn(fun() ->
                  connect(Listen)
          end),
    gen_tcp:controlling_process(Socket, self()),
    recv_loop(Socket, 0),
    timer:sleep(30000),
    %gen_tcp:close(Socket).
    gen_tcp:shutdown(Socket, read),
    io:format("Socket closed~n"),
    ok.

recv_loop(Socket, Count) -> 
    inet:setopts(Socket, [{active, once}]),
    receive 
        {tcp, Socket, Data} -> 
            io:format("~p ~p ~p~n", [inet:peername(Socket), erlang:localtime(), Data]),
            Byte_count = Count + byte_size(Data),
            io:format("Bytes received so far: ~p~n", [Byte_count]),
            %gen_tcp:send(Socket, binary:copy(<<"a">>, 1000 * 1000 + 1)),
            %file:sendfile("./large_file", Socket),
            {ok, FD} = file:open("./large_file", [raw, read, binary]),
            case file:sendfile(FD, Socket, 0, 0, []) of
                {error, Reason} ->
                    io:format("Error sending file: ~p~n", [Reason])
            end,
            %recv_loop(Socket, Byte_count);
            ok;
        {tcp_closed, Socket} ->
            io:format("~p Client Disconnected.~n", [erlang:localtime()]) ;
        {tcp_error, Socket, Reason} ->
            io:format("Error on socket ~p, reason: ~p~n", [Socket, Reason])
    end.
