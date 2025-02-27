/* water_jugs_with_source_sink.pl */

start :-
    % Опис ємностей: bucket(Id, MaxCapacity, CurrentAmount)
    % Ємність 0 - нескінченне джерело, ємність -1 - нескінченний злив
    InitialState = [bucket(1, 12, 8), bucket(2, 8, 0), bucket(3, 5, 0), bucket(0, 0, _), bucket(-1, -1, _)],
    GoalAmount = 3,
    solve_pr(InitialState, GoalAmount, [], Moves),
    writeln('Кроки розв’язання:'),
    print_steps(Moves),
    last(Moves, FinalState),
    exclude_source_sink(FinalState, CleanState),
    writeln('Фінальний результат: '), writeln(CleanState).

% Базовий випадок: перевірка наявності цільової кількості
solve_pr(State, GoalAmount, _, [State]) :-
    has_goal_amount(State, GoalAmount).

% Рекурсивний випадок: пошук можливих переміщень
solve_pr(State, GoalAmount, PreviousMoves, [State|Moves]) :-
    member(Bucket, State),
    member(Bucket2, State),
    Bucket \= Bucket2,
    move(Bucket, Bucket2, ResBucket, ResBucket2),
    replace(Bucket, State, ResBucket, State2),
    replace(Bucket2, State2, ResBucket2, StateX),
    \+ member(StateX, [State|PreviousMoves]),
    writeln('Перехід до стану: '), writeln(StateX),
    solve_pr(StateX, GoalAmount, [State|PreviousMoves], Moves).

% Операції переливання з урахуванням джерела та зливу
move(bucket(_, 0, _), bucket(Id2, Max2, _),
    bucket(_, 0, _), bucket(Id2, Max2, Max2)).  % Наповнення з джерела

move(bucket(Id1, Max1, Current), bucket(_, -1, _),
    bucket(Id1, Max1, 0), bucket(_, -1, _)) :- Current > 0.  % Злив у каналізацію

move(bucket(Id1, Max1, Current), bucket(Id2, Max2, Current2),
    bucket(Id1, Max1, 0), bucket(Id2, Max2, Current3)) :-
    Current > 0,
    Current3 is Current2 + Current,
    Current3 =< Max2.

move(bucket(Id1, Max1, Current), bucket(Id2, Max2, Current2),
    bucket(Id1, Max1, Current3), bucket(Id2, Max2, Max2)) :-
    Current > 0,
    Current3 is Current2 + Current - Max2,
    Current3 >= 0.

% Заміна елемента в списку
replace(_, [], _, []).
replace(O, [O|T], R, [R|T]).
replace(O, [H|T], R, [H|T2]) :-
    O \= H,
    replace(O, T, R, T2).

% Виведення кроків розв'язання
print_steps([]).
print_steps([H|T]) :-
    writeln(H),
    print_steps(T).

% Фільтрація джерела та зливу для фінального результату
exclude_source_sink(State, CleanState) :-
    exclude(is_source_sink, State, CleanState).

is_source_sink(bucket(0, 0, _)).
is_source_sink(bucket(-1, -1, _)).

% Перевірка наявності потрібної кількості рідини в одній із ємностей (ігноруючи джерело та злив)
has_goal_amount(State, GoalAmount) :-
    member(bucket(_, Capacity, GoalAmount), State),
    Capacity > 0.
