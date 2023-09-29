\ Test program for a binary search tree bst.fth

: test-version$  s" 1.5.3"  ;
cr .( Binary Search Tree test for version ) test-version$ type cr
decimal
false verbose !
include src/bst/bst.fth

\ ---[ BST Test helpers ]-----------------------------------------------------------

\ PLACE a counted string"
: place  ( ad u ad -- )  2dup 2>r char+ swap chars move 2r> c!  ;
: string,  ( ad u -- )  here over 1+ chars allot place  ;
: 0<=  ( n -- f ) postpone 0> postpone 0=  ; immediate

: array  ( size "name" -- )
   create cells allot
   does>  ( index -- ad ) swap cells +
;

\ ---[ Test helpers ]-----------------------------------------------------------

create (buf) 128 allot
variable blen

: >buf  ( caddr u -- )  dup blen ! (buf) swap cmove ;

\ *** Do not use B" inside a colon definition - it wasn't intended to be
\ *** compiled and so doesn't work

: b"  ( -- caddr u )    \ Parse and copy a string to (buf)
   (buf) '"' parse tuck >buf
;

: buf$  ( -- caddr u )  (buf) blen @ ;
: buf$+  ( u1 --  caddr u2 )  buf$ rot /string ;
\ Note: 0 buf$+ is equivalent to buf$

: $=  ( ca1 u1 ca2 u2 -- f )  compare 0=  ;     \ Fewer characters
synonym eval evaluate   \ Fewer characters

: v  ( ca u -- ca u )  cr 2dup type  ;    \ View SPRINTF output

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

\ ---[ Start of tests ]---------------------------------------------------------

\ Testing a BST referring to strings

26 array items
0 value #items

: item"  ( i "string" -- i+1  )  here '"' parse string, over items ! 1+  ;

0
item" Alpha"    item" Bravo"    item" Charlie"   item" Delta"
item" Echo"     item" Foxtrot"  item" Golf"      item" Hotel"
item" India"    item" Juliet"   item" Kilo"      item" Lima"
item" Mike"     item" November" item" Oscar"     item" Papa"
item" Quebec"   item" Romeo"    item" Sierra"    item" Tango"
item" Uniform"  item" Victor"   item" Whiskey"   item" X-ray"
item" Yankee"   item" Zulu"
to #items

cr Testing CREATE-BST

t{ #items create-bst constant phon -> }t
t{ phon c@ -> #items }t

t{ phon  1 + c@ items @ count s" Papa"     $= -> true }t
t{ phon  2 + c@ items @ count s" Hotel"    $= -> true }t
t{ phon  3 + c@ items @ count s" Whiskey"  $= -> true }t
t{ phon  4 + c@ items @ count s" Delta"    $= -> true }t
t{ phon  5 + c@ items @ count s" Lima"     $= -> true }t
t{ phon  6 + c@ items @ count s" Tango"    $= -> true }t
t{ phon  7 + c@ items @ count s" Yankee"   $= -> true }t
t{ phon  8 + c@ items @ count s" Bravo"    $= -> true }t
t{ phon  9 + c@ items @ count s" Foxtrot"  $= -> true }t
t{ phon 10 + c@ items @ count s" Juliet"   $= -> true }t
t{ phon 11 + c@ items @ count s" November" $= -> true }t
t{ phon 12 + c@ items @ count s" Romeo"    $= -> true }t
t{ phon 13 + c@ items @ count s" Victor"   $= -> true }t
t{ phon 14 + c@ items @ count s" X-ray"    $= -> true }t
t{ phon 15 + c@ items @ count s" Zulu"     $= -> true }t
t{ phon 16 + c@ items @ count s" Alpha"    $= -> true }t
t{ phon 17 + c@ items @ count s" Charlie"  $= -> true }t
t{ phon 18 + c@ items @ count s" Echo"     $= -> true }t
t{ phon 19 + c@ items @ count s" Golf"     $= -> true }t
t{ phon 20 + c@ items @ count s" India"    $= -> true }t
t{ phon 21 + c@ items @ count s" Kilo"     $= -> true }t
t{ phon 22 + c@ items @ count s" Mike"     $= -> true }t
t{ phon 23 + c@ items @ count s" Oscar"    $= -> true }t
t{ phon 24 + c@ items @ count s" Quebec"   $= -> true }t
t{ phon 25 + c@ items @ count s" Sierra"   $= -> true }t
t{ phon 26 + c@ items @ count s" Uniform"  $= -> true }t

Testing SEARCH-BST

: get-item  ( index -- ca u )  items @ count  ;

: $search-bst  ( [bst ca u -- ca u ca2 u2] | 0)
   [:  ( ca u ii -- ca u -1|0|+1 )
      >r 2dup r> get-item compare
   ;] search-bst dup 0<
   if drop 2drop 0  else get-item then
;

t{ b" Alpha"    phon $search-bst $= -> true }t
t{ b" Bravo"    phon $search-bst $= -> true }t
t{ b" Charlie"  phon $search-bst $= -> true }t
t{ b" Delta"    phon $search-bst $= -> true }t
t{ b" Echo"     phon $search-bst $= -> true }t
t{ b" Foxtrot"  phon $search-bst $= -> true }t
t{ b" Golf"     phon $search-bst $= -> true }t
t{ b" Hotel"    phon $search-bst $= -> true }t
t{ b" India"    phon $search-bst $= -> true }t
t{ b" Juliet"   phon $search-bst $= -> true }t
t{ b" Kilo"     phon $search-bst $= -> true }t
t{ b" Lima"     phon $search-bst $= -> true }t
t{ b" Mike"     phon $search-bst $= -> true }t
t{ b" November" phon $search-bst $= -> true }t
t{ b" Oscar"    phon $search-bst $= -> true }t
t{ b" Papa"     phon $search-bst $= -> true }t
t{ b" Quebec"   phon $search-bst $= -> true }t
t{ b" Romeo"    phon $search-bst $= -> true }t
t{ b" Sierra"   phon $search-bst $= -> true }t
t{ b" Tango"    phon $search-bst $= -> true }t
t{ b" Uniform"  phon $search-bst $= -> true }t
t{ b" Victor"   phon $search-bst $= -> true }t
t{ b" Whiskey"  phon $search-bst $= -> true }t
t{ b" X-ray"    phon $search-bst $= -> true }t
t{ b" Yankee"   phon $search-bst $= -> true }t
t{ b" Zulu"     phon $search-bst $= -> true }t

t{ b" ALpha"   phon $search-bst -> false }t
t{ b" BrAvo"   phon $search-bst -> false }t
t{ b" ChaRlie" phon $search-bst -> false }t
t{ b" Debt"    phon $search-bst -> false }t
t{ b" Ebb"     phon $search-bst -> false }t
t{ b" Flop"    phon $search-bst -> false }t
t{ b" Great"   phon $search-bst -> false }t
t{ b" Home"    phon $search-bst -> false }t
t{ b" Is"      phon $search-bst -> false }t
t{ b" Jasper"  phon $search-bst -> false }t
t{ b" Knot"    phon $search-bst -> false }t
t{ b" List"    phon $search-bst -> false }t
t{ b" Main"    phon $search-bst -> false }t
t{ b" Neon"    phon $search-bst -> false }t
t{ b" Opera"   phon $search-bst -> false }t
t{ b" Peek"    phon $search-bst -> false }t
t{ b" Quit"    phon $search-bst -> false }t
t{ b" Rise"    phon $search-bst -> false }t
t{ b" Send"    phon $search-bst -> false }t
t{ b" Twenty"  phon $search-bst -> false }t
t{ b" Ultra"   phon $search-bst -> false }t
t{ b" Vest"    phon $search-bst -> false }t
t{ b" Wink"    phon $search-bst -> false }t
t{ b" Xenon"   phon $search-bst -> false }t
t{ b" Yacht"   phon $search-bst -> false }t
t{ b" Zoo"     phon $search-bst -> false }t
t{ b" Zzzz"    phon $search-bst -> false }t

\ ------------------------------------------------------------------------------

Testing a user array of records, each record a range and xt

begin-structure sw-rec
   field: low
   field: high
   field: action-xt
end-structure 

: rec-array
   create  ( #ranges -- )  sw-rec * allot
   does>   ( index -- ad ) swap sw-rec *  +
;

0 value #ranges
30 rec-array ranges
: clear-ranges  ( -- )  0 ranges #ranges sw-rec * erase  ;
clear-ranges

variable index
: save-item  ( low high xt -- )
   index @ ranges tuck action-xt !  tuck high !  low !
   1 index +!
;

0 index !
-110 -102 :noname s" In range -110 to -102"  ; save-item
-10    5  :noname s" In range -10 to 5"      ; save-item
30    50  :noname s" In range 30 to 50"      ; save-item
121   192 :noname s" In range 121 to 192"    ; save-item
206   221 :noname s" In range 206 to 221"    ; save-item
349   349 :noname s" Integer value 349"      ; save-item
472   473 :noname s" In range 472 to 473"    ; save-item
537   555 :noname s" In range 537 to 555"    ; save-item
600   625 :noname s" In range 600 to 625"    ; save-item
714   720 :noname s" In range 714 to 720"    ; save-item
888   892 :noname s" In range 888 to 892"    ; save-item
index @ to #ranges

0 [if]
: dr  ( -- )  \ Display ranges
   #ranges 0
   do
      cr i 2 .r space i ranges
      ."  Range: "  dup low  @ 3 .r
      ."  to "      dup high @ 3 .r
      ." , Action: " action-xt @ execute type
   loop cr
;

cr dr
[then]

#ranges create-bst constant range-bst

: $search-range  ( n bst -- ca u | 0 0 )
   [: ( n ii -- n -1|0|+1)
      ranges 2dup ( low) @          ( -- n ad n2)
      < if drop -1 exit then        ( -- n -1 | n ad)
      high @ over < negate          ( -- n 0|1 )
   ;] search-bst nip                ( -- ii|-1)
   dup 0< if drop pad 0 exit then   ( -- ca2 0)
   ranges action-xt @ execute       ( -- ca u) 
;

t{ b" In range -110 to -102" -120 range-bst $search-range $= -> false }t
t{ b" In range -110 to -102" -105 range-bst $search-range $= -> true  }t
t{ b" In range -10 to 5"      -50 range-bst $search-range $= -> false }t
t{ b" In range -10 to 5"        3 range-bst $search-range $= -> true  }t
t{ b" In range 30 to 50"        6 range-bst $search-range $= -> false }t
t{ b" In range 30 to 50"       50 range-bst $search-range $= -> true  }t
t{ b" In range 121 to 192"     51 range-bst $search-range $= -> false }t
t{ b" In range 121 to 192"    121 range-bst $search-range $= -> true  }t
t{ b" In range 206 to 221"    193 range-bst $search-range $= -> false }t
t{ b" In range 206 to 221"    220 range-bst $search-range $= -> true  }t
t{ b" Integer value 349"      348 range-bst $search-range $= -> false }t
t{ b" Integer value 349"      349 range-bst $search-range $= -> true  }t
t{ b" In range 472 to 473"    350 range-bst $search-range $= -> false }t
t{ b" In range 472 to 473"    473 range-bst $search-range $= -> true  }t
t{ b" In range 537 to 555"   -234 range-bst $search-range $= -> false }t
t{ b" In range 537 to 555"    541 range-bst $search-range $= -> true  }t
t{ b" In range 600 to 625"   9876 range-bst $search-range $= -> false }t
t{ b" In range 600 to 625"    622 range-bst $search-range $= -> true  }t
t{ b" In range 714 to 720"    700 range-bst $search-range $= -> false }t
t{ b" In range 888 to 892"    890 range-bst $search-range $= -> true  }t
t{ b" In range 888 to 892"   -890 range-bst $search-range $= -> false }t
t{ b" In range 888 to 892"  23456 range-bst $search-range $= -> false }t

: test-range  ( n1 n2 ca u -- )
   {: ca u :}
   do
      t{ i range-bst $search-range ca u $= -> true }t
  loop 
;

-110 -115 pad 0 test-range

-101 -110 b" In range -110 to -102" test-range
-10 -101 pad 0 test-range

6 -10 b" In range -10 to 5" test-range
30  6 pad 0 test-range

51 30 b" In range 30 to 50" test-range
121 51 pad 0 test-range

193 121 b" In range 121 to 192" test-range
206 193 pad 0 test-range

222 206 b" In range 206 to 221" test-range
349 222 pad 0 test-range

350 349 b" Integer value 349" test-range
472 350 pad 0 test-range

474 472 b" In range 472 to 473" test-range
537 474 pad 0 test-range

556 537 b" In range 537 to 555" test-range
600 556 pad 0 test-range

626 600 b" In range 600 to 625" test-range
714 626 pad 0 test-range

721 714 b" In range 714 to 720" test-range
888 721 pad 0 test-range

893 888 b" In range 888 to 892" test-range
906 893 pad 0 test-range

\ ------------------------------------------------------------------------------

Testing sparse set of integer values in an array of records

begin-structure id-rec
   field: id
   field: id-action
end-structure 

0 value #ids
20 rec-array ids
: clear-ids  ( -- )  0 ids #ids id-rec * erase  ;
clear-ids

variable id-index
: save-id  ( id xt -- )
   id-index @ ids tuck id-action !  id !
   1 id-index +!
;

0 id-index !
-200 :noname 1000 ; save-id
-99  :noname 1001 ; save-id
0    :noname 1002 ; save-id
1    :noname 1003 ; save-id
25   :noname 1004 ; save-id
101  :noname 1005 ; save-id
123  :noname 1006 ; save-id
193  :noname 1007 ; save-id
1023 :noname 1008 ; save-id
id-index @ to #ids

0 [if]
: dids  ( -- )  \ Display ids
   #ids 0
   do
      cr i 2 .r space i ids
      ."  id: "  dup id  @ 4 .r
      ." , Action: " id-action @ execute .
   loop cr
;

cr dids
[then]

#ids create-bst constant id-bst

: $search-id  ( n bst -- n3 )
   [: ( n ii -- n -1|0|+1)
      ids ( id) @ over                 ( -- n n2 n)
      2dup < if 2drop 1 exit then      ( -- n 1 | n n2 n)
      >                                ( -- n 0|-1)
   ;] search-bst                       ( -- n ii|-1)
   nip dup 0< if drop -999 exit then   ( -- n3)
   ids id-action @ execute             ( -- n3) 
;

\ b+
t{ -200 id-bst $search-id 1000 = -> true }t
t{  -99 id-bst $search-id 1001 = -> true }t
t{    0 id-bst $search-id 1002 = -> true }t
t{    1 id-bst $search-id 1003 = -> true }t
t{   25 id-bst $search-id 1004 = -> true }t
t{  101 id-bst $search-id 1005 = -> true }t
t{  123 id-bst $search-id 1006 = -> true }t
t{  193 id-bst $search-id 1007 = -> true }t
t{ 1023 id-bst $search-id 1008 = -> true }t
t{ -201 id-bst $search-id -999 = -> true }t
t{  110 id-bst $search-id -999 = -> true }t
t{ 1100 id-bst $search-id -999 = -> true }t

\ ------------------------------------------------------------------------------

cr
cr .( End of tests )
cr cr .( -----[ Report ]-------)
#errors @ [if] cr .( *** Errors ***) [then]
cr .stack
\ cr .fpstack
cr .( Number of tests:)  #tests  @ 6 .r
cr .( Number of errors:) #errors @ 5 .r
cr .( ----------------------)
cr cr

\ ---[ End of file ]------------------------------------------------------------

