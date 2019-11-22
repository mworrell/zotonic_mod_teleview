%% @author Maas-Maarten Zeeman <mmzeeman@xs4all.nl>
%% @copyright 2019 Maas-Maarten Zeeman
%% @doc Provides server rendered live updating views.

%% Copyright 2019 Maas-Maarten Zeeman 
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

-module(mod_teleview).
-author("Maas-Maarten Zeeman <mmzeeman@xs4all.nl>").

-behaviour(supervisor).

-mod_title("TeleView").
-mod_description("Provides server rendered live updating views").
-mod_depends([base, mqtt]).
-mod_prio(1000).


-export([start_link/1]).
-export([init/1]).

-export([start_teleview/2]).

-define(SERVER, ?MODULE).

-include_lib("zotonic_core/include/zotonic.hrl").

start_link(Args) ->
    {context, Context} = proplists:lookup(context, Args),
    supervisor:start_link({local, z_utils:name_for_site(?SERVER, Context)}, ?MODULE, []).

start_teleview(_Id, _Context) ->
    ok.


init([]) ->
    {ok, {{simple_one_for_one, 20, 10},
          [
           {undefined, 
            {z_teleview_sup, start_link, []},
            transient, brutal_kill, supervisor, []}
          ]}}.
