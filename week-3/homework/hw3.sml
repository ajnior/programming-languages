(* Coursera Programming Languages, Homework 3, Provided Code *)

exception NoAnswer

datatype pattern = Wildcard
		 | Variable of string
		 | UnitP
		 | ConstP of int
		 | TupleP of pattern list
		 | ConstructorP of string * pattern

datatype valu = Const of int
	      | Unit
	      | Tuple of valu list
	      | Constructor of string * valu

fun g f1 f2 p =
    let 
	val r = g f1 f2 
    in
	case p of
	    Wildcard          => f1 ()
	  | Variable x        => f2 x
	  | TupleP ps         => List.foldl (fn (p,i) => (r p) + i) 0 ps
	  | ConstructorP(_,p) => r p
	  | _                 => 0
    end

(**** for the challenge problem only ****)

datatype typ = Anything
	     | UnitT
	     | IntT
	     | TupleT of typ list
	     | Datatype of string

(**** you can put all your code here ****)

(* 1. Write a function only_capitals that takes a string list and returns a string list that has only the strings in the argument that start with an uppercase letter. Assume all strings have at least 1 character. Use List.filter, Char.isUpper, and String.sub to make a 1-2 line solution. *)

fun only_capitals xs = List.filter(fn s => Char.isUpper (String.sub(s, 0))) xs

(* 2. Write a function longest_string1 that takes a string list and returns the longest string in the list. If the list is empty, return "". In the case of a tie, return the string closest to the beginning of the list. Use foldl, String.size, and no recursion (other than the implementation of foldl is recursive). *)

fun longest_string1 xs = List.foldl (fn (x, y) => if String.size(x) > String.size(y) then x else y ) "" xs

(* 3. Write a function longest_string2 that is exactly like longest_string1 except in the case of ties it returns the string closest to the end of the list. Your solution should be almost an exact copy of longest_string1. Still use foldl and String.size. *)

fun longest_string2 xs = List.foldl (fn (x, y) => if String.size(x) >= String.size(y) then x else y ) "" xs

(* 4. Write functions longest_string_helper, longest_string3, and longest_string4 such that:

- longest_string3 has the same behavior as longest_string1 and longest_string4 has the
same behavior as longest_string2.

- longest_string_helper has type (int * int -> bool) -> string list -> string
(notice the currying). This function will look a lot like longest_string1 and longest_string2 but is more general because it takes a function as an argument.

- If longest_string_helper is passed a function that behaves like > (so it returns true exactly when its first argument is stricly greater than its second), then the function returned has the same behavior as longest_string1.

- longest_string3 and longest_string4 are defined with val-bindings and partial applications of longest_string_helper. *)

fun longest_string_helper opr = 
	List.foldl (fn (x,max) => 
				if opr (String.size(x), String.size(max)) then x else max) ""

val longest_string3 = longest_string_helper (op >) 

val longest_string4 = longest_string_helper (op >=) 

(* 5. Write a function longest_capitalized that takes a string list and returns the longest string in the list that begins with an uppercase letter, or "" if there are no such strings. Assume all strings have at least 1 character. Use a val-binding and the ML library’s o operator for composing functions. Resolve ties like in problem 2. *)

val longest_capitalized =  longest_string3 o only_capitals

(* 6. Write a function rev_string that takes a string and returns the string that is the same characters in reverse order. Use ML’s o operator, the library function rev for reversing lists, and two library functions in the String module. (Browse the module documentation to find the most useful functions.) *)

fun rev_string s = (String.implode o rev o String.explode) s

(* 7. Write a function first_answer of type (’a -> ’b option) -> ’a list -> ’b (notice the 2 arguments are curried).
The first argument should be applied to elements of the second argument in order until the first time it returns SOME v for some v and then v is the result of the call to first_answer. If the first argument returns NONE for all list elements, then first_answer should raise the exception NoAnswer. Hints: Sample solution is 5 lines and does nothing fancy. *)

fun first_answer f x = 
    case x of
			[] => raise NoAnswer
				| (x::xs) => case f(x) of
							NONE => first_answer f xs
						| SOME v => v


(* 8. Write a function all_answers of type (’a -> ’b list option) -> ’a list -> ’b list option (notice the 2 arguments are curried). The first argument should be applied to elements of the second argument. If it returns NONE for any element, then the result for all_answers is NONE. Else the calls to the first argument will have produced SOME lst1, SOME lst2, ... SOME lstn and the result of all_answers is SOME lst where lst is lst1, lst2, ..., lstn appended together (order doesn’t matter). Hints: The sample solution is 8 lines. It uses a helper function with an accumulator and uses @. Note all_answers f [] should evaluate to SOME []. *)

fun all_answers f lst =
    let
        fun f_int (lst, acc) =
					case lst of
						[] => SOME acc
						| x::xs => case f(x) of
														NONE => NONE
													| SOME v => f_int(xs, v @ acc)
    in
        f_int(lst, [])
    end

(* 9 *)

val count_wildcards = g (fn x => 1) (fn y => 0)

val count_wild_and_variable_lengths = g (fn x => 1) (fn y => String.size y)

fun count_some_var (s, p) = g (fn x => 0) (fn y => if y = s then 1 else 0) p

(* 10. Write a function check_pat that takes a pattern and returns true if and only if all the variables appearing in the pattern are distinct from each other (i.e., use different strings). The constructor names are not relevant. Hints: The sample solution uses two helper functions. The first takes a pattern and returns a list of all the strings it uses for variables. Using foldl with a function that uses @ is useful in one case. The second takes a list of strings and decides if it has repeats. List.exists may be useful. Sample solution is 15 lines. These are hints: We are not requiring foldl and List.exists here, but they make it easier. *)

fun check_pat p = 
  let 
      fun get_str_list p = 
         case p of
            Variable x => [x] 
           |TupleP ps  => List.foldl (fn (r,i) => get_str_list(r)@i) [] ps
           | _ => []

      fun do_same_exists x = List.exists(fn y => x = y ) 
    
      fun check_uniqueness lst =
       case lst of
        [] => true
        | x::xs =>   if (do_same_exists x xs)
                     then false
                     else check_uniqueness xs
  in
    check_uniqueness ( get_str_list p)
  end 


(*Problem 11
  Write a function match that takes a valu * pattern and returns a (string * valu) list option,  
  namely NONE if the pattern does not match and SOME lst where lst is the list of bindings if it does.
  Note that if the value matches but the pattern has no patterns of the form Variable s, then the result
  is SOME []. Hints: Sample solution has one case expression with 7 branches. The branch for tuples
  2
   uses all_answers and ListPair.zip. Sample solution is 13 lines. Remember to look above for the
   rules for what patterns match what values, and what bindings they produce. These are hints: We are
  not requiring all_answers and ListPair.zip here, but they make it easier.
 *)

fun match (v,p)   =
     case (v,p) of  
      (_,Wildcard) => SOME []
     |(Const v1,ConstP p1) =>if v1 = p1 then SOME [] else NONE
     |(Unit,UnitP) =>SOME []
     |(Constructor (s ,v1),ConstructorP (s1, p1) ) => if s = s1 then match(v1,p1) else NONE
     |(Tuple vs,TupleP ps) => if List.length vs = List.length ps 
                              then case all_answers match (ListPair.zip(vs,ps))  of
                                    SOME v2=>SOME v2
                                   |_ => NONE
                              else NONE
     |(_, Variable s ) => SOME [(s,v)]
     |(_,_) => NONE

(*Problem 12
  Write a function first_match that takes a value and a list of patterns and returns a
  (string * valu) list option, namely NONE if no pattern in the list matches or SOME lst where
  lst is the list of bindings for the rst pattern in the list that matches. Use first_answer and a
  handle-expression. Hints: Sample solution is 3 lines.
 *)

fun first_match v p =
    SOME (first_answer (fn x => match(v,x)) p)
    handle NoAnswer =>NONE