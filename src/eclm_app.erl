-module(eclm_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    Host1 = configure_eclm(),
    Routes = [Host1],
    Dispatch = cowboy_router:compile(Routes),
    Acceptors_count = 500,
    Transport_options = [
                         {port, 1400}
                        ],
    Cowboy_Options = [
                      {env, [{dispatch, Dispatch}] }
                     ],
    cowboy:start_http(http, Acceptors_count, Transport_options, Cowboy_Options),
	eclm_sup:start_link().

stop(_State) ->
	ok.

configure_eclm() ->
    Files  = {"/[...]",  cowboy_static,  {priv_dir, eclm,  "eclm"}},
    Site = "eclm",
    {Site, [Files]}.
