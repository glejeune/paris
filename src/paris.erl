-module(paris).
-behaviour(gen_server).
-define(SERVER, ?MODULE).

-export([
  priv_dir/0,
  static/1,
  port/0
]).
-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

priv_dir() ->
  gen_server:call(?SERVER, {priv_dir}).

static(File) when is_list(File) ->
  case is_string(File) of
    true -> filename:join([priv_dir(), "static", File]);
    false -> filename:join([priv_dir(), "static"] ++ File)
  end.

port() ->
  gen_server:call(?SERVER, {port}).

start_link(Args) ->
  gen_server:start_link({local, ?SERVER}, ?MODULE, Args, []).
init(Args) ->
  {ok, Args}.

handle_call({priv_dir}, _From, State) ->
  PrivDir = case lists:keyfind(app, 1, State) of
    false -> error;
    {app, App} -> code:priv_dir(App)
  end,
  {reply, PrivDir, State};
handle_call({port}, _From, State) ->
  Port = case lists:keyfind(port, 1, State) of
    false -> error;
    {port, P} -> P
  end,
  {reply, Port, State};
handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast(_Msg, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

% - private -

is_string(X) ->
  lists:all(fun is_integer/1, X). 

