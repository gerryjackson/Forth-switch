\ Generates a binary search tree (BST) for a sorted array of items.
\ The BST is an array without pointers to the left and right subtrees.
\ The root item is at index 1 in the BST array, left and right subtrees of
\ node at index i are at indexes 2i and 2i+1 respectively. The bottom level
\ of the BST is filled up from the left so there is no wasted space in the
\ BST array.
\
\ See https://algorithmica.org/en/eytzinger
\
\ This version is generic in that the BST is independent of the user arrays
\ which take care of array item size, access to fields etc. The BST array holds
\ an index into the user array and the index may be 1 byte if the number of
\ items is less than 256 or 1 cell if >= 256. As the user arrays handle array
\ item sizes in the BST the left and right subtrees are always 2*i or 2*i+1
\
\ If an application needs more speed the BST can contain records but then the
\ BST search has to take care of record size when moving down the subtrees e.g.
\ if the record size is 3 cells the root node will be at index 3 and left and
\ right subtrees at indexes 2*i and 2*i+3 (see more explanation in version 1.1
\
\ Note that this implementation is for a fixed set of items such as reserved
\ words in a programming language, or for small associative arrays in a
\ program. No provision is made for insertion of additional items or deletion
\ of items already in the tree.

: version$ s" 1.5.4" ;
cr .( Loading Binary Search Tree version ) version$ type cr

\ CREATE-BST creates and initialises a BST with #items nodes. The user ITEMS
\ array must be sorted in ascending order of the key field with the lowest
\ value being in ITEMS[0]. The BST array holds byte sized indexes into the
\ ITEMS array
\ Usage:  26 create-bst constant bst-name
\ The root node is at BST-NAME[1] and BST-NAME[0] holds #items i.e. the size of
\ the BST array is (#items + 1)
\
\ See bst-test.fth for examples of use

: create-bst  ( #items -- bst )
   here swap dup c, allot  ( -- bst )
   1 0 rot                 ( -- bi ii bst ) \ bi is bst index, ii item index
   [:
      >r over r@ c@ <=                 ( -- bi ii f )    ( R: -- bst ) 
      if
         over 2* swap r> recurse >r    ( -- bi 2*bi ii )
         2dup swap r@ + c! 1+          ( -- bi ii+1 )
         over 2* 1+ swap r> recurse >r ( -- bi ii+1 )
      then  nip r>                     ( -- ii|ii+1 bst )
   ;] execute nip                      ( -- bst )
;

\ SEARCH-BST needs the user array to be sorted. The xt is for a user defined
\ comparison definition that returns ( -1 | 0 | +1 ) for the comparison result
\ being ( < | = | > ) respectively
: search-bst  ( bst xt -- ii | -1 ) \ ii = item index
   swap 1                        ( -- xt bst bi) \ bi = bst index
   begin
      over c@ over >=            \ bi out of range?                         
   while
      >r 2dup r@ + c@            ( -- xt bst xt ii ) ( R: -- bi)  
      2swap 2>r swap execute     ( -- n )  \ n = -1|0|+1  ( R: -- bi xt bst)
      ?dup
   while
      2r> rot 0> negate r> 2* +  ( -- xt bst bi')
   repeat
      2r> r> + c@ nip            ( -- ii )   \ Item found
   else
      2drop 0<>                  ( -- -1)    \ Item not found
   then
;
