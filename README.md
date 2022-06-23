# Forth-switch

## Introduction

This is an implementation of the CHOOSE statement described and implemented by
Michael L Gassanenko (MLG) in the document:
https://github.com/gerryjackson/Forth-switch/tree/master/doc/choose.html
MLG's implementation is non-standard as it uses return stack manipulation
extensively and is, therefore, not guaranteed to work on all Forth systems.

This implementation in ANS/Forth 2012 has much the same syntax except that:
- it is called switch instead of choose
- this switch is a defining word instead of MLG's choose that is a control structure
contained in a colon definition and may be nested.

## The Syntax

```
create-switch <name>
   <values-1> when <actions-1> end
   <values-2> when <actions-2> end
   .....
   <values-n> when <actions-n> end   
              other <default-action> end
end
```

where:
   - following compilation `<name>` has stack signature `( n -- ? )` where ? depends on
     the actions associated with that integer
   - there must be at least one `WHEN` and/or one `OTHER` clause  
   - `WHEN` clauses may be in any order
   - the `OTHER` clause must follow the `WHEN` clauses
   - `<values-i>` represents a sequence of integers and/or ranges of integers (or
     Forth words generating integers and/or ranges)
   - in `<values-i>` a range is specified using the word `...` where the usage is,
     for example, `10 ... 20` i.e. integers from 10 to 20 inclusive. Note that this
     could be written as `20 ... 10`
   - `<actions-i>` is regular Forth (but not a definition). 
   - the `OTHER` clause is optional, if absent the default action is `NOOP`
   - `SWITCH` defines a word that, when executed, performs the action associated
     with the integer supplied

An example:

```
switch foo
   0            when  ." zero"     end
   2 1 3 ... 10 when  ." 1 to 10"  end
   -10 ... -1   when  ." -1 to 10" end
                other ." Outside the range -10 to 10"  end
end
```
 
Then

```
-6 foo \ displays -1 to -10
```

## Installation and Test

1. Unzip the downloaded package into a directory of your choice
2. Set that directory as the working directory or set a path to that directory
3. Test by typing s" test/switch-test.fth" included

Depending on your Forth system you may need to adjust directory paths

For example using GForth, the output is:

```
Loading test/switch-test.fth ...
Testing switch.fthLoading lib/tester.fr ... loaded ()
Loading src/switch.fth ...
Loading switch.fth version 1.0.0
Copyright 2020 Gerry Jackson
loaded ()

Testing EXTENT+
Testing ... WHEN
Testing MAKE-TABLE
Testing SAVE-SUBSEQ-XT
Testing SAVE-RANGE-XT SAVE-SEQ
Testing CREATE-SWITCH WHEN OTHER END
Testing can be compiled
Testing error detection

End of tests

-----[ Report ]-------
Stack empty
Number of tests:  79
         passed:  79
         failed:   0
----------------------
```
There may be some re-definition warnings that can be ignored and the number of tests may differ with future versions of switch.fth

## Compatibility

Switch.fth has been tested with GForth (64 bit), VFX Forth, WF32 and SwiftForth version 3.7.9 (it doesn't work with version 3.7.11 which crashes - hopefully this will be fixed in a later version. It is believed to be ANS/Forth 2012 compliant except that a quotation is used. Quotations have been accepted into Forth 200X and should appear in a later standard.
SwiftForth and VFX Forth need to include a file called quotations.f and quotations.fth respectively.

If your Forth does not have quotations the easiest thing to do is to replace the definition of the word `(...)` with:

```
: ((...))  ?dup 0> if 1- swap >r recurse r@ extent+ r> -rot then  ;

: (...)  ( start size ni .. n1 -- ni .. n1 i start' size' )
   subseq-size dup >r   ( -- start size ni .. n1 i )  ( R: -- i )
   ((...))
   r> -rot                 ( -- ni .. n1 i start' size' )
;
``` 

## Common END

Forth-switch has followed MLG in using the word `END` to complete `WHEN`, `OTHER` and `CREATE-SWITCH`. An alternative is to use `END-WHEN`, `END-OTHER` and `END-SWITCH` instead as appropriate.

## Further developments

Probably development of two more versions of switch.fth
* For a sparse set of switch values (with binary search or hashing to search the jump table
* For a simple version with single integer switch values

