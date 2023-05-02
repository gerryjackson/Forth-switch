\ switch.fth - an implementation of Michael Gassanenko's (MLG) choose in
\ ANS/2012 Forth. A difference is that CREATE-SWITCH is a defining word and
\ may not be nested

\ Copyright (C) G W Jackson 2020, 2021, 2023

\ This software is covered by the MIT software license, a copy of which should
\ have accompanied this file. If not see https://opensource.org/licenses/MIT

\ ---[ Version & Copyright ]----------------------------------------------------

: version$  ." 1.0.2" ;
cr cr .( Loading switch.fth version ) version$
cr .( Copyright 2020, 2021, 2023 Gerry Jackson) cr

\ ---[ Helpers ]----------------------------------------------------------------

\ Unsigned MIN
: umin  ( u1 u2 -- u1|u2 )  2dup u< if drop exit then nip  ;

\ ---[ switch value extent ]----------------------------------------------------
\ Extending the overall extent (range) of all switch values before
\ all WHENs. It updates a (nmax nmin ) pair of values if a new switch value
\ is outside the range nmin to nmax
\ Initially (nmax nmin) is (MININT MAXINT)

: extent+  ( nmax nmin n -- nmax' nmin' )  tuck min >r max r>  ;

\ ---[ Converting switch values ]-----------------------------------------------

\ In DEPTHS
\  - the ms cell is the stack depth at the start of a switch subsequence
\  - the ls cell is the stack depth at the start of the switch sequence

2variable depths
: set-depths  ( -- )  depth dup depths 2!  ;
: subseq-size  ( -- n )  depth depths @ - depth depths !  ;
: no-values?  ( -- f ) depth depths cell+ @ - 0=  ;

\ ---[ Create switch run-time ]-------------------------------------------------

\ MAKE-RUNTIME compiles:
\  :noname  ( n -- i*x ) start - size umin cells jtad' + @ execute ;
\ Given:
\     create-switch foo
\         ... etc
\     end
\ then
\     n foo
\ will execute the above :noname definition 

: make-runtime  ( start size jtad -- xt ) \ jtad is jump table address
   2 pick cells +          ( -- start size jtad' )
   >r >r >r                ( R: -- jtad' size start )
   :noname
   r> postpone literal postpone - r> postpone literal postpone umin
   postpone cells r> postpone literal postpone + postpone @ postpone execute
   postpone ;
;

\ ---[ Jump table generation ]--------------------------------------------------

\ MAKE-TABLE compiles the default xt into dataspace for the jump table. xt is
\ either the default xt from the OTHER clause or, if none, a noop xt.
\ The table contains (size+1) default xts, +1 because a cell at the ms cell of
\ the jump table is used for the xt of the default or OTHER :
\     size = swmax - swmin + 1   calculated in END-SWITCH
\ The address returned is:
\     (table-address - lowest-switch-value (in cells))
\ so that subsequent processing can use it to load individual switch value xt's
\ at (ad + switch-value(cells))

: make-table  ( xt start size -- xt start size jtad ) \ jtad jump table ad
   over cells here - negate >r   ( R: -- jtad )
   dup 1+ 0 do 2 pick , loop
   r>                            ( -- xt start size jtad )
;

\ SAVE-SUBSEQ-XT
\     jtad is that returned by MAKE-TABLE
\     xt is that of the actions associated with the switch values
\     n is the number of switch value integers (no ranges)

: save-xt  ( xt ad i -- ad' )  cells + !  ;

: save-subseq-xt  ( i*n n xt ad -- xt ad ) 
  rot 0                               ( -- i*n xt ad n 0 )
  ?do rot >r 2dup r> save-xt loop     ( -- i*n-1 xt ad )
;

\ The range i1 ... i2 is inclusive, i1 can be >, = or < i2 
: save-range-xt  ( i1 i2 xt ad -- xt ad )
   2swap 2dup > if swap then     \ Ensure (i1 i2) is (low high)
   1+ swap                       ( -- xt ad i2+1 i1 )
   do 2dup i save-xt loop        ( -- xt ad )
;

\ If a switch sequence contains more than 1 subsequence, all but the bottom
\ subsequence contains a range at the bottom of the subsequence

: save-seq  ( subseq1 ... subseqn xt ad -- ad )
   begin
      depth 3 - 3 pick - depths cell+ @ > \ True if not the last subsequence
   while
      2>r 2 - 0 max 2r>
      save-subseq-xt
      save-range-xt
   repeat
   save-subseq-xt
   nip                  ( -- ad )
;

\ xt1 is an actions xt, xt2 the default xt which is redundant as
\ MAKE-TABLE has been executed and so must be dropped.
\ xt3 is the switch runtime xt which needs to be passed down the stack
: load-table  ( 0 0 [switch-subseq+ depth xt1 xt2]+  ad xt3 -- xt3 )
   >r begin
         nip over
      while
         rot depths cell+ ! save-seq
      repeat 2drop
   r>
;

\ ---[ User interface ]---------------------------------------------------------

defer end immediate

\ In END-SWITCH xt3 is the run time execution token saved in the word "name"
\ created by SWITCH
: end-switch  ( ad 0 0 [switch-subseq+ depth xt1 xt2]+ swmax swmin -- )
   tuck - 1+            ( -- .... start size ) \ start=swmin, size=swmax-swmin+1
   make-table           ( -- .... start size jtad ) 
   dup >r make-runtime  ( -- ad 0 0 [switch-subseq+ depth xt1 xt2]+ xt3 )
   r> swap load-table   ( -- ad xt3 )
   swap !
;

:noname ; constant noop-xt

: end-when  ( swmax swmin -- xt1 xt2 swmax swmin )
   postpone ; noop-xt 2swap   \ NOOP is the default default-xt
   set-depths
   ['] end-switch is end
; immediate

\ END-OTHER replaces the default xt which is xt2
: end-other    ( xt1 xt2 swmax swmin xt3 -- xt1 xt3 swmax swmin)
   postpone ;
   -rot 2>r nip 2r>
   ['] end-switch is end
; immediate

: ?values  ( -- )
   no-values?
   if cr true abort" Error: no switch values before WHEN or ..." then
;

: (...)  ( swmax swmin ni .. n1 -- ni .. n1 i swmax' swmin' )
   subseq-size dup >r   ( -- swmax swmin ni .. n1 i )  ( R: -- i )
   [: ?dup 0> if 1- swap >r recurse r@ extent+ r> -rot then ;]
   execute                 ( -- ni .. n1 swmax' swmin' )
   r> -rot                 ( -- ni .. n1 i swmax' swmin' )
;

: ...  ( swmax swmin ni .. n0 -- ni .. n1 i swmax' swmin' n0 )
   ?values  >r (...) r>
;

: when  ( [ n+ i ]* swmax swmin n2+ -- [ n+ i ]* n2+ i2 depth swmax' swmin' xt )
   ?values (...)
   depths cell+ @ 2 - -rot        \ Base depth of the switch sequence
   ['] end-when is end
   :noname
;

: other  ( -- xt )  ['] end-other is end  :noname  ;

: create-switch
   create  ( "name" -- ad )
      here 0 ,          \ Will hold xt of switch run-time
      0 noop-xt         ( -- ad xt1 xt2 ) \ xt1 is a sentinel
      [ -1 1 rshift dup invert swap ] 2literal  ( -- ad xt1 xt2 swmax swmin )
      set-depths
      ['] end-switch is end
   does>  ( n -- ? )
      @ execute
;
