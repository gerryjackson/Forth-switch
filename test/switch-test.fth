\ ---[ Switch test program 1.0.0 ]----------------------------------------------------

\ Copyright (C) G W Jackson 2020

\ This software is covered by the MIT software license, a copy of which should
\ have accompanied this file. If not see https://opensource.org/licenses/MIT

cr .( Testing switch.fth)

include lib/tester.fr
decimal
1 cells constant bytes/cell

include src/switch.fth

\ ---[ For the test report ]----------------------------------------------------
0 #errors !
variable #tests 0 #tests !
: t{  ( -- )  1 #tests +! t{  ;

: .stack  ( -- )
   depth ?dup 0>
   if
      ." Stack contents: ( "
      dup 6 > if drop 6 ." ... " then
      0 swap                  ( -- xn ... x0 0 n )
      ?do
         i ?dup 0>
         if 1- pick . then
         -1
      +loop      
      ')' emit
      depth 6 > if ."  Depth: " depth . then
   else
      ." Stack empty"
   then
;

\ ---[  Helpers ]---------------------------------------------------------------

: dp  (  "name" -- )   \ Simple dump of cells from name-xt to here
   base @ >r decimal
[defined] [jess] [if]
   [ also system ] codespace
[then]
   ' here over -        ( -- ad u )
   over + swap ?do cr i #14 u.r i @ #18 u.r 1 cells +loop cr
[defined] [jess] [if]
   dataspace [ previous ]
[then]
   r> base !
;

: cell-  ( u -- u' )  1 cells -  ;

\ ---[ Initialise ]-------------------------------------------------------------
-1 verbose !

\ ---[ Tests start here ]-------------------------------------------------------

Testing EXTENT+

t{ -8 0 -7 extent+ -> -8 1 }t
t{ -8 1 -9 extent+ -> -9 2 }t
t{ -9 2  0 extent+ -> -9 9 }t
t{ -9 9  -20 extent+ -> -20 20 }t
t{ -20 20 -7 extent+ -> -20 20 }t
t{ 15 0 17 extent+ -> 15 2 }t
t{ 15 2 14 extent+ -> 14 3 }t
t{ 14 3 -3 extent+ -> -3 20 }t
t{ -3 20 6 extent+ -> -3 20 }t
t{ -3 20 -3 extent+ -> -3 20 }t
t{ -3 20 17 extent+ -> -3 20 }t
t{ 0 -1 18 extent+ -> 18 0 }t

Testing ... WHEN

t{ 0 -1 set-depths 400 ... 405 -> 0   0 -1   400 405 }t
t{ 0 -1 set-depths 406 407 ... 409 -> 406 1   406 0   407 409 }t
t{ 0 -1 set-depths 410 411 412 ... 415 416 417
                  -> 410 411 2   410 1   412 415 416 417 }t
t{ 0 -1 set-depths 418 419 420 ... 425 426 427 ... 429
                  -> 418 419 2   420 425 426 3    418 8   427 429 }t

t{ 0 -1 set-depths 430 when 431 ; execute -> 430 1 0 430 0 431 }t
t{ 0 -1 set-depths 432 433 when 434 ; execute -> 432 433 2 0 432 1 434 }t
t{ 0 -1 set-depths 435 436 ... 437 when ; execute -> 435 1 436 437 2 0 435 2 }t
t{ 0 -1 set-depths 439 ... 442 443 when ; execute -> 0 439 442 443 3 0 439 4 }t

Testing MAKE-TABLE

: depths2!  ( -- )  set-depths  ;

0 0 depths 2!

variable ptable

: check-table ( ad n size 0 -> flag )
   do over i cells + @ over <> if unloop 2drop false exit then loop
   2drop true
;

0 value gh
: gh! align here to gh  ;

t{ gh! 120 3 0 make-table 3 cells + dup ptable ! -> 120 3 1 gh }t
t{ ptable @ 2@ -> 120 120 }t
t{ gh! 121 -15 20 make-table -15 cells + dup ptable ! -> 121 -15 21 gh }t
t{ ptable @ 121 22 0 check-table -> true }t

Testing SAVE-SUBSEQ-XT

: get-xt  ( n -- xt )
   cells ptable @ + @        ( -- xt )
;

t{ -1 -2 depths2! 5 10 21 3 122 123 5 16
      make-table nip nip nip dup ptable ! save-subseq-xt
            -> -1 -2 122 ptable @ }t
t{ 5 get-xt 6 get-xt 9 get-xt 10 get-xt 11 get-xt 20 get-xt 21 get-xt
            -> 122 123 123 122 123 123 122 }t

t{ depths2! -5 0 2 3 4 125 124 -5 8 make-table nip nip nip dup ptable !
      save-subseq-xt -> 125 ptable @ }t
t{ -5 get-xt -4 get-xt 0 get-xt 1 get-xt 2 get-xt 3 get-xt
               -> 125 124 125 124 125 125 }t

Testing SAVE-RANGE-XT SAVE-SEQ

: base-depth  depths cell+ @  ;
: sd  ( -- )  set-depths  ;
: table-size  ( -- start size-1 )  -10 18 ;
200 constant def-xt
222 constant rt-xt
: ss1  sd -10 -5 0 2 8 5 base-depth  ;      \ -10 -5 0 2 8  No ranges
: ss2  sd -3 1 4 7 -6 -9 4 base-depth  ;    \ -3 4 ... 7 -6 -9
: ss3  sd 0 -7 -3 2 base-depth  ;           \ -7 ... -3
: ss4  sd -5 7 2 -3 4 8 6 4 base-depth  ;     \ -5 7 -3 ... 4 8 6
: xt>t  ptable @ rt-xt load-table  ;
: clear-table  ( n -- )  -10 8 rot ptable @ save-range-xt 2drop  ;
: xt+  get-xt + ;
: sum-xts  ( i*n n -- n2 )  0 tuck do swap xt+ loop  ;
: sum-table  ( -- n )  0 9 -10 do i xt+ loop  ;

def-xt table-size make-table nip nip nip ptable !

t{ 0 0 ss1 150 def-xt xt>t -> rt-xt }t
t{ -10 get-xt -5 xt+ 0 xt+ 2 xt+ 8 xt+ -> 150 5 * }t

t{ 0 0 ss2 151 def-xt xt>t ->  rt-xt }t
t{ -3 get-xt 4 xt+ 5 xt+ 6 xt+ 7 xt+ -6 xt+ -9 xt+ -> 151 7 * }t
t{ 152 clear-table -> }t

t{ 0 0 ss3 153 def-xt xt>t ->  rt-xt }t
t{ -7 get-xt -6 xt+ -5 xt+ -4 xt+ -3 xt+ -> 153 5 * }t
154 clear-table

t{ 0 0 ss4 155 def-xt xt>t ->  rt-xt }t
t{ -5 7 -3 -2 -1 0 1 2 3 4 8 6 12 sum-xts -> 155 12 *  }t
0 clear-table

t{ 0 0 ss2 156 def-xt ss1 157 def-xt ss3 158 def-xt xt>t ->  rt-xt }t
t{ sum-table -> 156 7 * 157 5 * + 158 2 * + }t

Testing CREATE-SWITCH WHEN OTHER END

t{ create-switch ch1 end 201 ch1 -> }t  \ Empty switch noops & doesn't crash
t{ create-switch ch2 201 when 301 end end -> }t
t{ 201 ch2 -> 301 }t
t{ -123456 ch2 0 ch2 200 ch2 202 ch2 1000 ch2 -> }t

t{ 202 create-switch ch3 other 302 end end -> 202 }t   \ 
t{ -123456 ch3 0 ch3 202 ch3 987654 ch3 -> 302 302 302 302 }t
t{ create-switch ch4
      203 when 303 end
      206 when 306 end
      204 when 304 end
   end -> }t
t{ 202 ch4 203 ch4 204 ch4 205 ch4 206 ch4 207 ch4 -> 303 304 306 }t

t{ 208 create-switch ch5
          -209 210 when 309 end
          other 310 end
       end -> 208 }t
t{ -210 ch5 -209 ch5 -208 ch5 0 ch5 210 ch5 -> 310 309 310 310 309 }t

t{ create-switch ch6 211 ... 214 when 311 end end -> }t
t{ : tch6 215 210 do i ch6 loop ; tch6 -> 311 311 311 311 }t

t{ create-switch ch7 -216 ... -218 when 316 end end -> }t
t{ -215 ch7 -216 ch7 -217 ch7 -218 ch7 -219 ch7 -> 316 316 316 }t

t{ create-switch ch8 -2 ... 3 when 320 end end -> }t
t{ 220 -2 ch8 -1 ch8 0 ch8 1 ch8 2 ch8 3 ch8 -> 220 320 320 320 320 320 320 }t

: exec-switch  ( i*n xt n -- j*n )
   ?dup 0>
   if
      1- rot >r recurse ( -- xt) ( R: -- i1 ... in) \ at end of recursion
      r> over execute swap   ( -- j*n xt )
   then
;

: check-switch  ( i*n n1 -- f )
   true swap depth 2 - 0
   do                ( -- i*n f n1 )
      rot over <> if nip false swap then
   loop drop
;

: test-switch  ( i*n xt n1 -- f )
   >r depth 1- exec-switch drop r> check-switch
 ;

t{ create-switch ch9
      1 ... 4 7 9  when 321 end
      10 12 ... 15 when 322 end
      19 20 22 ... 23 24 26 when 323 end
      30 32 34 ... 37 39 ... 41 43 when 325 end
      45 47 ... 49 50 52 55 ... 60 when 326 end
      other 324 end
   end -> }t

t{ 1 2 3 4 7 9 ' ch9 321 test-switch -> true }t
t{ 10 12 13 14 15 ' ch9 322 test-switch -> true }t
t{ 19 20 22 23 24 26 ' ch9 323 test-switch -> true }t
t{ -100 -1 0 5 6 8 11 16 17 18 25 27 1000 ' ch9 324 test-switch -> true }t
t{ 30 32 34 35 36 37 39 40 41 43 ' ch9 325 test-switch -> true }t
t{ 45 47 48 49 50 52 55 56 57 58 59 60 ' ch9 326 test-switch -> true }t

: other-ints1 28 29 31 33 38 42 ;
: other-ints2 44 46 51 53 54 61 ;
t{ other-ints1 other-ints2 ' ch9 324 test-switch -> true }t

: sw-seq -10 -15 ... -18 3 5 ;
t{ create-switch ch10  sw-seq when 327 end  end -> }t
t{ -10 -15 -16 -17 -18 3 5 ' ch10 327 test-switch -> true }t

t{ create-switch ch11 100 110 when 328 end end -> }t
t{ 100 ch11 110 ch11 -> 328 328 }t
t{ 99 ch11 101 ch11 102 ch11 109 ch11 111 ch11 -> }t \ Default other is noop

t{ create-switch ch12
      1001 ... 1001 when 329 end    \ range of 1 integer
      1005 ... 1003 when 330 end    \ reversed range
      other 331 end
      other 332 end                 \ 2 OTHERs, second should "win" 
   end -> }t
t{ 1001 ch12 1003 ch12 1004 ch12 1005 ch12 -> 329 330 330 330 }t
t{ 1000 ch12 -> 332 }t

: square  dup * ;  : cube  dup dup * * ;
t{ create-switch ch13 2 when square end 3 when cube end end -> }t
t{ 33 2 ch13 34 3 ch13 -> 1089 39304 }t

\ Duplicated switch value, the first one "wins"
t{ create-switch ch14 1 when 333 end 1 when 334 end end -> }t
t{ 1 ch14 -> 333 }t

Testing can be compiled

: my-switch create-switch ;
t{ my-switch ch15 1 when 335 end other 336 end end -> }t
t{ 1 ch15 2 ch15 -> 335 336 }t

Testing error detection

t{ :noname s" create-switch ch16 when" evaluate ; catch -> -2 }t
t{ :noname s" create-switch ch17 ... 96 when" evaluate ; catch -> -2 }t


\ ------------------------------------------------------------------------------

.( End of tests )
cr cr .( -----[ Report ]-------)
#errors @ [if] cr .( *** Errors ***) [then]
cr .stack
\ cr .fpstack
cr .( Number of tests:)  #tests  @ 4 .r
cr .(          passed:) #tests @ #errors @ - 4 .r
cr .(          failed:) #errors @ 4 .r
cr .( ----------------------)
cr cr

\ ---[ End of file ]------------------------------------------------------------
