-module(paris_request).

-export([
  body/1,
  content_type/1,
  content_type/2,
  accept/1,
  accept/2,
  range/1,
  param/3,
  param/2,
  params/2,
  params/1,
  header/2,
  headers/1,
  method/1,
  cookies/1,
  cookie/2
]).

cookies(Req) ->
  cowboy_req:parse_cookies(paris_req:req(Req)).

cookie(Req, Name) ->
  elist:keyfind(Name, 1, cookies(Req), undefined).

method(Req) ->
  cowboy_req:method(paris_req:req(Req)).

header(Req, Name) ->
  cowboy_req:header(Name, paris_req:req(Req)).

headers(Req) ->
  cowboy_req:headers(paris_req:req(Req)).

param(Req, Type, Name) ->
  case lists:keyfind(Name, 1, params(Req, Type)) of
    {Name, Value} -> Value;
    _ -> undefined
  end.

param(Req, Name) ->
  case lists:keyfind(Name, 1, params(Req)) of
    {Name, Value} -> Value;
    _ -> undefined
  end.

params(Req, Type) ->
  case Type of
    get -> get_vals(Req);
    post -> post_vals(Req)
  end.

params(Req) ->
  get_vals(Req) ++ post_vals(Req).

post_vals(Req) ->
  case cowboy_req:body_qs(paris_req:req(Req)) of
    {ok, List, _} -> List;
    _ -> []
  end.
get_vals(Req) ->
  cowboy_req:parse_qs(paris_req:req(Req)).

body(Req) ->
  case cowboy_req:body(paris_req:req(Req)) of
    {ok, Data, _Req2} -> {ok, Data};
    E -> E
  end.

content_type(Req) ->
  cowboy_req:parse_header(<<"content-type">>, paris_req:req(Req), undefined).

content_type(Req, ContentType) ->
  [Type, SubType | _] = binary:split(ContentType, <<"/">>),
  case content_type(Req) of
    {Type2, SubType2, _} ->
      (Type =:= Type2 orelse <<"*">> =:= Type2) and
      (SubType =:= SubType2 orelse <<"*">> =:= SubType2);
    _ -> false
  end.

accept(Req) ->
  cowboy_req:parse_header(<<"accept">>, paris_req:req(Req), []).

accept(Req, Accept) ->
  [Type, SubType | _] = binary:split(Accept, <<"/">>),
  lists:any(fun({{Type2, SubType2, _}, _, _}) ->
        (Type =:= Type2 orelse <<"*">> =:= Type2) and
        (SubType =:= SubType2 orelse <<"*">> =:= SubType2)
    end, accept(Req)).

range(Req) ->
  Range = cowboy_req:header(<<"range">>, paris_req:req(Req), <<"bytes=0-">>),
  [_, Range1|_] = string:tokens(binary_to_list(Range), "="),
  list_to_tuple([trunc(list_to_integer(X)/1024) || 
      X <- string:tokens(Range1, "-")]).
