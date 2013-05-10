%%% Licensed under the Apache License, Version 2.0 (the "License"); you may not
%%% use this file except in compliance with the License. You may obtain a copy of
%%% the License at
%%%
%%%   http://www.apache.org/licenses/LICENSE-2.0
%%%
%%% Unless required by applicable law or agreed to in writing, software
%%% distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
%%% WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
%%%
%%% the License.

-module(test_all).

%%
%% Include files
%%

%%
%% Exported Functions
%%
-export([test/1]).

%%
%% API Functions
%%
test([Dir]) ->
	{ok, Files} = file:list_dir(Dir),
	BeamPred = fun(F) -> is_beam_file(F) end,
	BeamFiles = lists:sort(lists:filter(BeamPred, Files)),
	TestPred = fun(F) -> is_test_file(F) end,
	TestFiles = lists:sort(lists:filter(TestPred, BeamFiles)),
	TestModules = [erlang:list_to_atom(lists:sublist(F, 1, length(F)-5)) || F <- TestFiles],
	TestModules2 = [Mod || Mod <- TestModules, Mod =/= test_all],
	TestResults = [run_tests(Module) || Module <- TestModules2],
	assert_all_tests_passed(TestResults).

%%
%% Local Functions
%%
is_beam_file(FileName) when length(FileName) >= 5 ->
	Length = length(FileName),
	lists:sublist(FileName, Length-4, 5) =:= ".beam";
is_beam_file(_FileName) ->
	false.

is_test_file(FileName) when length(FileName) >= 5 ->
	lists:sublist(FileName, 1, 5) =:= "test_";
is_test_file(_FileName) ->
	false.

run_tests(Module) ->
	io:format("Running ~p:~n", [Module]),
	Module:test().

assert_all_tests_passed([]) ->
	ok;
assert_all_tests_passed([ok|Tail]) ->
	assert_all_tests_passed(Tail);
assert_all_tests_passed([_NotOk|_Tail]) ->
	halt(1).
