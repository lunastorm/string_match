-module(test).
-export([load_patterns/0]).
-export([match_loop/1]).
-export([init_matchers/1]).
-export([send_matchers/2]).
-export([main/1]).

load_patterns() ->
  {ok, Dev} = file:open("patterns", [read]),
  load_patterns(Dev, []).

load_patterns(Dev, Acc) ->
  case io:get_line(Dev, "") of
    eof -> file:close(Dev), Acc;
    Line -> {ok, Pattern} = re:compile(string:strip(Line, right, $\n)),
    load_patterns(Dev, [{Line, Pattern} | Acc])
  end.

init_matchers(Patterns) ->
  init_matchers(Patterns, []).

init_matchers([], Acc) -> Acc;
init_matchers([H|T], Acc) -> init_matchers(T, [spawn(test, match_loop, [H]) | Acc]).

send_matchers(_, []) -> done;
send_matchers(Line, [H|T]) -> H ! Line, send_matchers(Line, T).

match_loop({PatternStr, Pattern}) ->
  receive
    eof ->
      %io:format("finished~n", []);
      nothing;
    Line ->
      case re:run(Line, Pattern) of
        %nomatch -> io:format("~s nomatch ~s~n", [Line, PatternStr]);
        nomatch -> nothing;
        {match,_} -> io:format("~s match ~s~n", [Line, PatternStr])
      end,
    match_loop({PatternStr, Pattern})
  end.

main(_) ->
  Matchers = init_matchers(load_patterns()),
  process_flag(priority, high),
  main_loop(Matchers).
  
main_loop(Matchers) ->
  Line = io:get_line(""),
  case Line of
    eof -> init:stop();
    _ -> nothing
  end,
  [Matcher ! Line || Matcher <- Matchers],
  main_loop(Matchers).

