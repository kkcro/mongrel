#!/usr/bin/env escript

main([Dir]) ->
	{ok, Files} = file:list_dir("./src"),
	ErlPred = fun(F) -> is_erl_file(F) end,
	ErlFiles = lists:filter(ErlPred, Files),
	Modules = ["src/" ++ F || F <- ErlFiles],
	case edoc:files(Modules, [{dir, Dir}]) of
		ok ->
			ok;
		_ ->
			halt(1)
	end.	

is_erl_file(FileName) when length(FileName) >= 4 ->
	Length = length(FileName),
	lists:sublist(FileName, Length-3, 4) =:= ".erl";
is_erl_file(_FileName) ->
	false.


