%% @author Maas-Maarten Zeeman <mmzeeman@xs4all.nl>
%% @copyright 2019 Maas-Maarten Zeeman
%% @doc Put a teleview on the page.

%% Copyright 2019-2021 Maas-Maarten Zeeman
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.


-module(scomp_teleview_teleview).
-behaviour(zotonic_scomp).

-export([vary/2, render/3]).

-include_lib("zotonic_core/include/zotonic.hrl").

vary(_Params, _Context) -> nocache.

%% Make a place for the view to land and setup the worker which
%% is going to manage the view.

render(Params, Vars, Context) ->
    {type, Type} = proplists:lookup(type, Params),
    {args, Args} = proplists:lookup(args, Params),

    case z_notifier:first({ensure_teleview, Type, Args}, Context) of
        {ok, PublishTopic} ->
            Id = z_ids:identifier(),

            InsertTopic = <<"model/ui/insert/", Id/binary>>,
            UpdateTopic = <<"model/ui/update/", Id/binary>>,

            Subscribe = [<<"cotonic.broker.subscribe('bridge/origin/">>, PublishTopic, <<"/+type', function(m, a) { televiewState = updateDoc(a.type, m.payload, televiewState); if(televiewState.current) { cotonic.broker.publish('">>, UpdateTopic, <<"', televiewState.current) }; console.log(televiewState); } )">>], 

            Div = z_tags:render_tag(<<"div">>, [{<<"id">>, Id}], [ ]),

            Script = z_tags:render_tag(<<"script">>, [], [
                <<"let televiewState = newTeleviewState();">>, 

                <<"if (typeof cotonic === 'undefined') { window.addEventListener('cotonic-ready', function() {">>,
                    <<"cotonic.broker.publish('">>, InsertTopic, <<"', {initialData: '<p>Loading</p>', inner: true, priority: 10});">>,
                    Subscribe,
                <<"} ) } else { ">>,
                    Subscribe,
                <<"}">>
            ]),

            {ok, [Div, Script]};

        {error, _E}=Error ->
            {error, Error}
    end.

