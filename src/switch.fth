\ switch.fth - an implementation of Michael Gassanenko's (MLG) choose in
\ ANS/2012 Forth. A difference is that CREATE-SWITCH is a defining word and
\ may not be nested

\ Copyright (C) G W Jackson 2020

\ This software is covered by the MIT software license, a copy of which should
\ have accompanied this file. If not see https://opensource.org/licenses/MIT

\ ---[ Version 1.0.0 ]----------------------------------------------------------

: version$  s" 1.0.0" ;
cr .( Loading switch.fth version ) version$ type
cr .( Copyright 2020 Gerry Jackson) cr

\ ---[ Helpers ]----------------------------------------------------------------

\ Unsigned MIN
: umin  ( u1 u2 -- u1|u2 )  2dup u> if swap then drop  ;

\ ---[ switch value extent ]----------------------------------------------------
\ Creating and extending the overall extent (range) of all switch values before
\ all WHENs. It updates a (start size) pair, according to a switch value.
\ Initially (start size) is (0 -1) where the size is negative (i.e. invalid).
\ Note that the size throughout processing is 1 less than its TRUE value, this
\ is because the method used to update (start size-1) only works for size-1 but
\ is efficient (this is inherited from MLG). If the true size is used the code
\ below fails to work and an alternative definiiton is longer.

: extent+  ( start size n|u -- start' size' )
   over 0< if nip nip 0 exit then
   2 pick - dup 0< if /string else max then
;

\ ---[ Converting switch values ]-----------------------------------------------

\ In DEPTHS
\  - the ms cell is the stack depth at the start of a switch subsequence
\  - the ls cell is the stack depth at the start of the switch sequence
2variable depths

: set-depths  ( -- )  depth dup depths 2!  ;

: subseq-size  ( -- n )  depth depths @ - depth depths !  ;

: no-values?  ( -- f ) depth depths cell+ @ - 0=  ;

\ ---[ Create switch run-time ]-------------------------------------------------

: make-runtime  ( start size jtad -- xt ) \ jtad is jump table address
   2 pick cells +          ( -- start size jtad' )
   >r >r >r                ( R: -- jtad size start )
   :noname
   r> postpone literal postpone - r> postpone literal postpone umin
   postpone cells r> postpone literal postpone + postpone @ postpone execute
   postpone ;
;

\ ---[ Jump table generation ]--------------------------------------------------

\ MAKE-TABLE compiles the default xt into dataspace for the jump table. xt is
\ either the default xt from the OTHER clause or, if none such, a noop xt.
\ The table contains (size+2) default xts, +2 because:
\     - size is (actual size - 1)
\     - +1 for switch values out of range
\ The address returned is:
\     (table-address - lowest-switch-value(cells))
\ so that subsequent processing can use it to load individual switch value xt's
\ at (ad + switch-value(cells))
\ xt2 is the execution token of the run time code from MAKE-RUNTIME

: make-table  ( xt start size -- xt start size+1 jtad ) \ jtad jump table ad
   over cells here - negate >r
   1+ dup 1+ 0                   ( -- xt start size+1 size+2 0 )
   do 2 pick , loop
   r>                            ( -- xt start size+1 jtad )
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
: end-switch  ( ad 0 0 [switch-subseq+ depth xt1 xt2]+ start size -- )
   make-table           ( -- .... start size+1 jtad ) 
   dup >r make-runtime  ( -- ad 0 0 [switch-subseq+ depth xt1 xt2]+ xt3 )
   r> swap load-table   ( -- ad xt3 )
   swap !
;

:noname ; constant noop-xt

: end-when  ( start size -- xt1 xt2 start size )
   postpone ; noop-xt 2swap   \ NOOP is the default default-xt
   set-depths
   ['] end-switch is end
; immediate

\ END-OTHER replaces the default xt which is xt2
: end-other    ( xt1 xt2 start size xt3 -- xt1 xt3 start size)
   postpone ;
   -rot 2>r nip 2r>
   ['] end-switch is end
; immediate

: ?values  ( -- )
   no-values? if cr  abort" Error: no switch values before WHEN or  a ... range" then
;

: (...)  ( start size ni .. n1 -- ni .. n1 i start' size' )
   subseq-size dup >r   ( -- start size ni .. n1 i )  ( R: -- n0 i )
   [: ?dup 0> if 1- swap >r recurse r@ extent+ r> -rot then ;]
   execute                 ( -- ni .. n1 start' size' )
   r> -rot                 ( -- ni .. n1 i start' size' )
;

: ...  ( start size ni .. n0 -- ni .. n1 i start' size' n0 )
   ?values  >r (...) r>
;

: when  ( [ n+ i ]* start size n2+ -- [ n+ i ]* n2+ i2 depth start' size' xt )
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
      0 -1              ( -- ad xt1 xt2 start size )   \ -ve size is invalid
      set-depths
      ['] end-switch is end
   does>  ( n -- ? )
      @ execute
;
