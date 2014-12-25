/* 
 * This file is part of the bring.out FMK, a free and open source 
 * accounting software suite,
 * Copyright (c) 1996-2011 by bring.out doo Sarajevo.
 * It is licensed to you under the Common Public Attribution License
 * version 1.0, the full text of which (including FMK specific Exhibits)
 * is available in the file LICENSE_CPAL_bring.out_FMK.md located at the 
 * root directory of this source code archive.
 * By using this software, you agree to be bound by its terms.
 */


#define KOEFIC 3.51

static aFW[2,134]




******************
*******************
*function Main()
*
*InitFW()
*
*cStr:="{\b ERKY}"
*nWidth:="74.3"
*accept "String " to cStr
*accept "sirina prostora " to nWidth
*//nWidth:=0
*//for i:=1 to len(cStr)
*//  nWidth+=aFw[1,ASC(substr(cStr,i,1))-31,1]
*//next
*//? "Duzina je :",nWidth
*//input "Velicina fonta u pointima " to nFS
*//? "Duzina u mm, za ",nFs,"pointa font je :",nWidth*KOEFIC*nFS/10000
*//?
*//?
*? "Rezultat:"
*aRez:=WWSjeciStr(cStr,10,val(nWidth))
*for i:=1 to len(aRez)
* ? aRez[i]
*next
*? "...........Kraj......"
*return


*******************
*******************
function InitFW()
// normal, bold, italic, b-i
aFW[1,1]:={ 273 , 279 , 273 , 279 }  //  32   
aFW[1,2]:={ 288 , 282 , 288 , 282 }  //  33  !
aFW[1,3]:={ 303 , 360 , 303 , 360 }  //  34  "
aFW[1,4]:={ 546 , 555 , 546 , 555 }  //  35  #
aFW[1,5]:={ 546 , 555 , 546 , 555 }  //  36  $
aFW[1,6]:={ 765 , 852 , 765 , 852 }  //  37  %
aFW[1,7]:={ 750 , 672 , 750 , 672 }  //  38  &
aFW[1,8]:={ 351 , 282 , 351 , 282 }  //  39  '
aFW[1,9]:={ 366 , 375 , 366 , 375 }  //  40  (
aFW[1,10]:={ 366 , 375 , 366 , 375 }  //  41  )
aFW[1,11]:={ 420 , 438 , 420 , 438 }  //  42  *
aFW[1,12]:={ 600 , 594 , 600 , 594 }  //  43  +
aFW[1,13]:={ 273 , 282 , 273 , 282 }  //  44  ,
aFW[1,14]:={ 327 , 414 , 327 , 414 }  //  45  -
aFW[1,15]:={ 273 , 282 , 273 , 282 }  //  46  .
aFW[1,16]:={ 429 , 453 , 429 , 453 }  //  47  /
aFW[1,17]:={ 546 , 555 , 546 , 555 }  //  48  0
aFW[1,18]:={ 546 , 555 , 546 , 555 }  //  49  1
aFW[1,19]:={ 546 , 555 , 546 , 555 }  //  50  2
aFW[1,20]:={ 546 , 555 , 546 , 555 }  //  51  3
aFW[1,21]:={ 546 , 555 , 546 , 555 }  //  52  4
aFW[1,22]:={ 546 , 555 , 546 , 555 }  //  53  5
aFW[1,23]:={ 546 , 555 , 546 , 555 }  //  54  6
aFW[1,24]:={ 546 , 555 , 546 , 555 }  //  55  7
aFW[1,25]:={ 546 , 555 , 546 , 555 }  //  56  8
aFW[1,26]:={ 546 , 555 , 546 , 555 }  //  57  9
aFW[1,27]:={ 273 , 282 , 273 , 282 }  //  58  :
aFW[1,28]:={ 273 , 282 , 273 , 282 }  //  59  ;
aFW[1,29]:={ 600 , 594 , 600 , 594 }  //  60  <
aFW[1,30]:={ 600 , 594 , 600 , 594 }  //  61  =
aFW[1,31]:={ 600 , 594 , 600 , 594 }  //  62  >
aFW[1,32]:={ 585 , 555 , 585 , 555 }  //  63  ?
aFW[1,33]:={ 477 , 501 , 477 , 501 }  //  64  @
aFW[1,34]:={ 735 , 735 , 735 , 735 }  //  65  A
aFW[1,35]:={ 570 , 579 , 570 , 579 }  //  66  B
aFW[1,36]:={ 804 , 820 , 804 , 774 }  //  67  C
aFW[1,37]:={ 735 , 750 , 735 , 696 }  //  68  D
aFW[1,38]:={ 531 , 540 , 531 , 516 }  //  69  E
aFW[1,39]:={ 483 , 530 , 483 , 477 }  //  70  F
aFW[1,40]:={ 867 , 910 , 867 , 834 }  //  71  G
aFW[1,41]:={ 678 , 700 , 678 , 672 }  //  72  H
aFW[1,42]:={ 225 , 282 , 225 , 282 }  //  73  I
aFW[1,43]:={ 477 , 500 , 477 , 477 }  //  74  J
aFW[1,44]:={ 585 , 620 , 585 , 618 }  //  75  K
aFW[1,45]:={ 459 , 490 , 459 , 438 }  //  76  L
aFW[1,46]:={ 912 , 950 , 912 , 891 }  //  77  M
aFW[1,47]:={ 735 , 760 , 735 , 735 }  //  78  N
aFW[1,48]:={ 858 , 880 , 858 , 834 }  //  79  O
aFW[1,49]:={ 585 , 610 , 585 , 555 }  //  80  P
aFW[1,50]:={ 867 , 880 , 867 , 834 }  //  81  Q
aFW[1,51]:={ 600 , 630 , 600 , 579 }  //  82  R
aFW[1,52]:={ 492 , 520 , 492 , 516 }  //  83  S
aFW[1,53]:={ 420 , 430 , 420 , 414 }  //  84  T
aFW[1,54]:={ 648 , 660 , 648 , 633 }  //  85  U
aFW[1,55]:={ 696 , 720 , 696 , 696 }  //  86  V
aFW[1,56]:={ 951 , 970 , 951 , 891 }  //  87  W
aFW[1,57]:={ 600 , 672 , 600 , 672 }  //  88  X
aFW[1,58]:={ 585 , 628 , 585 , 618 }  //  89  Y
aFW[1,59]:={ 477 , 511 , 477 , 501 }  //  90  Z
aFW[1,60]:={ 492 , 526 , 492 , 516 }  //  91  [
aFW[1,61]:={ 735 , 750 , 735 , 696 }  //  92  \
aFW[1,62]:={ 804 , 820 , 804 , 774 }  //  93  ]
aFW[1,63]:={ 804 , 820 , 804 , 774 }  //  94  ^
aFW[1,64]:={ 501 , 530 , 501 , 501 }  //  95  _
aFW[1,65]:={ 420 , 453 , 420 , 453 }  //  96  `
aFW[1,66]:={ 678 , 690 , 678 , 657 }  //  97  a
aFW[1,67]:={ 678 , 690 , 678 , 657 }  //  98  b
aFW[1,68]:={ 639 , 650 , 639 , 633 }  //  99  c
aFW[1,69]:={ 678 , 657 , 678 , 657 }  //  100  d
aFW[1,70]:={ 648 , 660 , 648 , 633 }  //  101  e
aFW[1,71]:={ 312 , 330 , 312 , 282 }  //  102  f
aFW[1,72]:={ 663 , 687 , 663 , 657 }  //  103  g
aFW[1,73]:={ 600 , 620 , 600 , 594 }  //  104  h
aFW[1,74]:={ 195 , 234 , 195 , 234 }  //  105  i
aFW[1,75]:={ 204 , 258 , 204 , 258 }  //  106  j
aFW[1,76]:={ 501 , 579 , 501 , 579 }  //  107  k
aFW[1,77]:={ 195 , 234 , 195 , 234 }  //  108  l
aFW[1,78]:={ 930 , 950 , 930 , 930 }  //  109  m
aFW[1,79]:={ 600 , 594 , 600 , 594 }  //  110  n
aFW[1,80]:={ 648 , 653 , 648 , 633 }  //  111  o
aFW[1,81]:={ 678 , 657 , 678 , 657 }  //  112  p
aFW[1,82]:={ 678 , 657 , 678 , 657 }  //  113  q
aFW[1,83]:={ 297 , 321 , 297 , 321 }  //  114  r
aFW[1,84]:={ 381 , 438 , 381 , 438 }  //  115  s
aFW[1,85]:={ 336 , 350 , 336 , 297 }  //  116  t
aFW[1,86]:={ 600 , 624 , 600 , 594 }  //  117  u
aFW[1,87]:={ 546 , 555 , 546 , 555 }  //  118  v
aFW[1,88]:={ 828 , 858 , 828 , 795 }  //  119  w
aFW[1,89]:={ 477 , 555 , 477 , 555 }  //  120  x
aFW[1,90]:={ 531 , 579 , 531 , 579 }  //  121  y
aFW[1,91]:={ 420 , 453 , 420 , 453 }  //  122  z
aFW[1,92]:={ 381 , 438 , 381 , 438 }  //  123  {
aFW[1,93]:={ 711 , 750 , 678 , 657 }  //  124  |
aFW[1,94]:={ 639 , 653 , 639 , 633 }  //  125  }
aFW[1,95]:={ 639 , 653 , 639 , 633 }  //  126  ~
aFW[1,96]:={ 750 , 770 , 750 , 750 }  //  127  
aFW[1,97]:={ 750 , 770 , 750 , 750 }  //  128  �
aFW[1,98]:={ 750 , 750 , 750 , 750 }  //  129  �
aFW[1,99]:={ 375 , 414 , 375 , 414 }  //  130  �
aFW[1,100]:={ 546 , 555 , 546 , 555 }  //  131  �
aFW[1,101]:={ 501 , 477 , 501 , 477 }  //  132  �
aFW[1,102]:={ 990 , 990 , 990 , 990 }  //  133  �
aFW[1,103]:={ 546 , 555 , 546 , 555 }  //  134  �
aFW[1,104]:={ 546 , 555 , 546 , 555 }  //  135  �
aFW[1,105]:={ 501 , 540 , 501 , 540 }  //  136  �
aFW[1,106]:={ 1164 , 1272 , 1164 , 1272 }  //  137  �
aFW[1,107]:={ 750 , 750 , 750 , 750 }  //  138  �
aFW[1,108]:={ 249 , 234 , 249 , 234 }  //  139  �
aFW[1,109]:={ 1185 , 1053 , 1185 , 1053 }  //  140  �
aFW[1,110]:={ 750 , 750 , 750 , 750 }  //  141  �
aFW[1,111]:={ 750 , 750 , 750 , 750 }  //  142  �
aFW[1,112]:={ 750 , 750 , 750 , 750 }  //  143  �
aFW[1,113]:={ 750 , 750 , 750 , 750 }  //  144  �
aFW[1,114]:={ 420 , 453 , 420 , 453 }  //  145  �
aFW[1,115]:={ 750 , 750 , 750 , 750 }  //  146  �
aFW[1,116]:={ 501 , 477 , 501 , 477 }  //  147  �
aFW[1,117]:={ 477 , 477 , 477 , 477 }  //  148  �
aFW[1,118]:={ 600 , 594 , 600 , 594 }  //  149  �
aFW[1,119]:={ 501 , 501 , 501 , 501 }  //  150  �
aFW[1,120]:={ 990 , 990 , 990 , 990 }  //  151  �
aFW[1,121]:={ 438 , 477 , 438 , 477 }  //  152  �
aFW[1,122]:={ 990 , 990 , 990 , 990 }  //  153  �
aFW[1,123]:={ 750 , 750 , 750 , 750 }  //  154  �
aFW[1,124]:={ 249 , 234 , 249 , 234 }  //  155  �
aFW[1,125]:={ 1125 , 1068 , 1125 , 1068 }  //  156  �
aFW[1,126]:={ 3 , 3 , 3 , 3 }  //  157  �
aFW[1,127]:={ 3 , 3 , 3 , 3 }  //  158  �
aFW[1,128]:={ 750 , 750 , 750 , 750 }  //  159  �
aFW[1,129]:={ 750 , 750 , 750 , 750 }  //  160  �
aFW[1,130]:={ 75 , 75 , 75 , 75 }  //  161  �
aFW[1,131]:={ 546 , 555 , 546 , 555 }  //  162  �
aFW[1,132]:={ 546 , 555 , 546 , 555 }  //  163  �
aFW[1,133]:={ 546 , 555 , 546 , 555 }  //  164  �
aFW[1,134]:={ 546 , 555 , 546 , 555 }  //  165  �


aFW[2,1]:={ 273 , 279 , 273 , 279 }  //  32
aFW[2,2]:={ 288 , 282 , 288 , 282 }  //  33  !
aFW[2,3]:={ 303 , 360 , 303 , 360 }  //  34  "
aFW[2,4]:={ 546 , 555 , 546 , 555 }  //  35  #
aFW[2,5]:={ 546 , 555 , 546 , 555 }  //  36  $
aFW[2,6]:={ 765 , 852 , 765 , 852 }  //  37  %
aFW[2,7]:={ 750 , 672 , 750 , 672 }  //  38  &
aFW[2,8]:={ 351 , 282 , 351 , 282 }  //  39  '
aFW[2,9]:={ 366 , 375 , 366 , 375 }  //  40  (
aFW[2,10]:={ 366 , 375 , 366 , 375 }  //  41  )
aFW[2,11]:={ 420 , 438 , 420 , 438 }  //  42  *
aFW[2,12]:={ 600 , 594 , 600 , 594 }  //  43  +
aFW[2,13]:={ 273 , 282 , 273 , 282 }  //  44  ,
aFW[2,14]:={ 327 , 414 , 327 , 414 }  //  45  -
aFW[2,15]:={ 273 , 282 , 273 , 282 }  //  46  .
aFW[2,16]:={ 429 , 453 , 429 , 453 }  //  47  /
aFW[2,17]:={ 546 , 555 , 546 , 555 }  //  48  0
aFW[2,18]:={ 546 , 555 , 546 , 555 }  //  49  1
aFW[2,19]:={ 546 , 555 , 546 , 555 }  //  50  2
aFW[2,20]:={ 546 , 555 , 546 , 555 }  //  51  3
aFW[2,21]:={ 546 , 555 , 546 , 555 }  //  52  4
aFW[2,22]:={ 546 , 555 , 546 , 555 }  //  53  5
aFW[2,23]:={ 546 , 555 , 546 , 555 }  //  54  6
aFW[2,24]:={ 546 , 555 , 546 , 555 }  //  55  7
aFW[2,25]:={ 546 , 555 , 546 , 555 }  //  56  8
aFW[2,26]:={ 546 , 555 , 546 , 555 }  //  57  9
aFW[2,27]:={ 273 , 282 , 273 , 282 }  //  58  :
aFW[2,28]:={ 273 , 282 , 273 , 282 }  //  59  ;
aFW[2,29]:={ 600 , 594 , 600 , 594 }  //  60  <
aFW[2,30]:={ 600 , 594 , 600 , 594 }  //  61  =
aFW[2,31]:={ 600 , 594 , 600 , 594 }  //  62  >
aFW[2,32]:={ 585 , 555 , 585 , 555 }  //  63  ?
aFW[2,33]:={ 477 , 501 , 477 , 501 }  //  64  @
aFW[2,34]:={ 735 , 735 , 735 , 735 }  //  65  A
aFW[2,35]:={ 570 , 579 , 570 , 579 }  //  66  B
aFW[2,36]:={ 804 , 774 , 804 , 774 }  //  67  C
aFW[2,37]:={ 735 , 696 , 735 , 696 }  //  68  D
aFW[2,38]:={ 531 , 516 , 531 , 516 }  //  69  E
aFW[2,39]:={ 483 , 477 , 483 , 477 }  //  70  F
aFW[2,40]:={ 867 , 834 , 867 , 834 }  //  71  G
aFW[2,41]:={ 678 , 672 , 678 , 672 }  //  72  H
aFW[2,42]:={ 225 , 282 , 225 , 282 }  //  73  I
aFW[2,43]:={ 477 , 477 , 477 , 477 }  //  74  J
aFW[2,44]:={ 585 , 618 , 585 , 618 }  //  75  K
aFW[2,45]:={ 459 , 438 , 459 , 438 }  //  76  L
aFW[2,46]:={ 912 , 891 , 912 , 891 }  //  77  M
aFW[2,47]:={ 735 , 735 , 735 , 735 }  //  78  N
aFW[2,48]:={ 858 , 834 , 858 , 834 }  //  79  O
aFW[2,49]:={ 585 , 555 , 585 , 555 }  //  80  P
aFW[2,50]:={ 867 , 834 , 867 , 834 }  //  81  Q
aFW[2,51]:={ 600 , 579 , 600 , 579 }  //  82  R
aFW[2,52]:={ 492 , 516 , 492 , 516 }  //  83  S
aFW[2,53]:={ 420 , 414 , 420 , 414 }  //  84  T
aFW[2,54]:={ 648 , 633 , 648 , 633 }  //  85  U
aFW[2,55]:={ 696 , 696 , 696 , 696 }  //  86  V
aFW[2,56]:={ 951 , 891 , 951 , 891 }  //  87  W
aFW[2,57]:={ 600 , 672 , 600 , 672 }  //  88  X
aFW[2,58]:={ 585 , 618 , 585 , 618 }  //  89  Y
aFW[2,59]:={ 477 , 501 , 477 , 501 }  //  90  Z
aFW[2,60]:={ 492 , 516 , 492 , 516 }  //  91  [
aFW[2,61]:={ 735 , 696 , 735 , 696 }  //  92  \
aFW[2,62]:={ 804 , 774 , 804 , 774 }  //  93  ]
aFW[2,63]:={ 804 , 774 , 804 , 774 }  //  94  ^
aFW[2,64]:={ 501 , 501 , 501 , 501 }  //  95  _
aFW[2,65]:={ 420 , 453 , 420 , 453 }  //  96  `
aFW[2,66]:={ 678 , 657 , 678 , 657 }  //  97  a
aFW[2,67]:={ 678 , 657 , 678 , 657 }  //  98  b
aFW[2,68]:={ 639 , 633 , 639 , 633 }  //  99  c
aFW[2,69]:={ 678 , 657 , 678 , 657 }  //  100  d
aFW[2,70]:={ 648 , 633 , 648 , 633 }  //  101  e
aFW[2,71]:={ 312 , 282 , 312 , 282 }  //  102  f
aFW[2,72]:={ 663 , 657 , 663 , 657 }  //  103  g
aFW[2,73]:={ 600 , 594 , 600 , 594 }  //  104  h
aFW[2,74]:={ 195 , 234 , 195 , 234 }  //  105  i
aFW[2,75]:={ 204 , 258 , 204 , 258 }  //  106  j
aFW[2,76]:={ 501 , 579 , 501 , 579 }  //  107  k
aFW[2,77]:={ 195 , 234 , 195 , 234 }  //  108  l
aFW[2,78]:={ 930 , 930 , 930 , 930 }  //  109  m
aFW[2,79]:={ 600 , 594 , 600 , 594 }  //  110  n
aFW[2,80]:={ 648 , 633 , 648 , 633 }  //  111  o
aFW[2,81]:={ 678 , 657 , 678 , 657 }  //  112  p
aFW[2,82]:={ 678 , 657 , 678 , 657 }  //  113  q
aFW[2,83]:={ 297 , 321 , 297 , 321 }  //  114  r
aFW[2,84]:={ 381 , 438 , 381 , 438 }  //  115  s
aFW[2,85]:={ 336 , 297 , 336 , 297 }  //  116  t
aFW[2,86]:={ 600 , 594 , 600 , 594 }  //  117  u
aFW[2,87]:={ 546 , 555 , 546 , 555 }  //  118  v
aFW[2,88]:={ 828 , 795 , 828 , 795 }  //  119  w
aFW[2,89]:={ 477 , 555 , 477 , 555 }  //  120  x
aFW[2,90]:={ 531 , 579 , 531 , 579 }  //  121  y
aFW[2,91]:={ 420 , 453 , 420 , 453 }  //  122  z
aFW[2,92]:={ 381 , 438 , 381 , 438 }  //  123  {
aFW[2,93]:={ 711 , 687 , 678 , 657 }  //  124  |
aFW[2,94]:={ 639 , 633 , 639 , 633 }  //  125  }
aFW[2,95]:={ 639 , 633 , 639 , 633 }  //  126  ~
aFW[2,96]:={ 750 , 750 , 750 , 750 }  //  127  
aFW[2,97]:={ 750 , 750 , 750 , 750 }  //  128  �
aFW[2,98]:={ 750 , 750 , 750 , 750 }  //  129  �
aFW[2,99]:={ 375 , 414 , 375 , 414 }  //  130  �
aFW[2,100]:={ 546 , 555 , 546 , 555 }  //  131  �
aFW[2,101]:={ 501 , 477 , 501 , 477 }  //  132  �
aFW[2,102]:={ 990 , 990 , 990 , 990 }  //  133  �
aFW[2,103]:={ 546 , 555 , 546 , 555 }  //  134  �
aFW[2,104]:={ 546 , 555 , 546 , 555 }  //  135  �
aFW[2,105]:={ 501 , 540 , 501 , 540 }  //  136  �
aFW[2,106]:={ 1164 , 1272 , 1164 , 1272 }  //  137  �
aFW[2,107]:={ 750 , 750 , 750 , 750 }  //  138  �
aFW[2,108]:={ 249 , 234 , 249 , 234 }  //  139  �
aFW[2,109]:={ 1185 , 1053 , 1185 , 1053 }  //  140  �
aFW[2,110]:={ 750 , 750 , 750 , 750 }  //  141  �
aFW[2,111]:={ 750 , 750 , 750 , 750 }  //  142  �
aFW[2,112]:={ 750 , 750 , 750 , 750 }  //  143  �
aFW[2,113]:={ 750 , 750 , 750 , 750 }  //  144  �
aFW[2,114]:={ 420 , 453 , 420 , 453 }  //  145  �
aFW[2,115]:={ 750 , 750 , 750 , 750 }  //  146  �
aFW[2,116]:={ 501 , 477 , 501 , 477 }  //  147  �
aFW[2,117]:={ 477 , 477 , 477 , 477 }  //  148  �
aFW[2,118]:={ 600 , 594 , 600 , 594 }  //  149  �
aFW[2,119]:={ 501 , 501 , 501 , 501 }  //  150  �
aFW[2,120]:={ 990 , 990 , 990 , 990 }  //  151  �
aFW[2,121]:={ 438 , 477 , 438 , 477 }  //  152  �
aFW[2,122]:={ 990 , 990 , 990 , 990 }  //  153  �
aFW[2,123]:={ 750 , 750 , 750 , 750 }  //  154  �
aFW[2,124]:={ 249 , 234 , 249 , 234 }  //  155  �
aFW[2,125]:={ 1125 , 1068 , 1125 , 1068 }  //  156  �
aFW[2,126]:={ 3 , 3 , 3 , 3 }  //  157  �
aFW[2,127]:={ 3 , 3 , 3 , 3 }  //  158  �
aFW[2,128]:={ 750 , 750 , 750 , 750 }  //  159  �
aFW[2,129]:={ 750 , 750 , 750 , 750 }  //  160  �
aFW[2,130]:={ 75 , 75 , 75 , 75 }  //  161  �
aFW[2,131]:={ 546 , 555 , 546 , 555 }  //  162  �
aFW[2,132]:={ 546 , 555 , 546 , 555 }  //  163  �
aFW[2,133]:={ 546 , 555 , 546 , 555 }  //  164  �
aFW[2,134]:={ 546 , 555 , 546 , 555 }  //  165  �

return

****************************************************
* nFS - tekuci font size u pointima,nLen duzina u mm
*****************************************************
function WWSjeciStr(cStr,nFS,nLen)
local i,ii,aRez:={},cRed,cPom,cTWord,nWWidth,nPos,cC,nAsc
local fbold,fitalic, FontSize, FontTip, FontPT, nPom,fUNL
local aPom

local aFStack:={{1,1,nFs}}  // tip, podtip, size u points

//        {normal, bold, italic, bolditalic}


FontSize:=nFs
FontTip:=1
FontPT:=1    // normal
fBold:=fitalic:=.f.
nLen:=nLen/1.25


cPom:=""
cTWord:="";nWWidth:=0
nPos:=0;cRed:=""
fUNL:=.f.  // nailazak na \line
for i:=1 to len(cStr)
   cC:=substr(cStr,i,1)

   if cC=="{"
     StackPush(aFStack,{FontTip,FontPT,FontSize})
     loop
   endif
   if cC=="}"
     aPom:=StackPop(aFStack)  //  vrati staro
     FontTip:=aPom[1]; FontPT:=aPom[2]; FontSize:=aPom[3]
     if i==len(cStr)  // ako je zadnji karakter napravi prekid linije
      fUNL:=.t.
      ++i
     else
      loop
     endif
   endif

   if cC=="\"
    if substr(cStr,i+1,1)=="b"
     fbold:=.t.
     i+=2
     cC:=Substr(cStr,i,1)
     if empty(cC); ++i; cC:=Substr(cStr,i,1); endif
    elseif substr(cStr,i+1,1)=="i"
     fitalic:=.t.
     i+=2
     cC:=Substr(cStr,i,1)
     if empty(cC); ++i; cC:=Substr(cStr,i,1); endif


    elseif substr(cStr,i+1,4)=="line"
      fUNL:=.t.
      i+=5
      cC:=Substr(cStr,i,1)
      if empty(cC); ++i; cC:=Substr(cStr,i,1); endif
      --i
    elseif substr(cStr,i+1,3)=="par"
      fUNL:=.t.
      i+=4
      cC:=Substr(cStr,i,1)
      if empty(cC); ++i; cC:=Substr(cStr,i,1); endif
      --i
    elseif substr(cStr,i+1,2)=="fs"
     FontSize:=val(substr(cStr,i+3,5))/2
     i+=2
     for ii:=1 to 5
       cC:=Substr(cStr,++i,1)
       if (cC $ "0123456789")
          loop
       elseif cC==" "
          cC:=Substr(cStr,++i,1)
          exit
       elseif cC=="\"
          exit
       endif
     next
    elseif substr(cStr,i+1,1)=="f"
     FontTip:=val(substr(cStr,i+2,2))
     ++i
     for ii:=1 to 5
       cC:=Substr(cStr,++i,1)
       if cC $ "0123456789"
          loop
       elseif cC==" "
          cC:=Substr(cStr,++i,1)
          exit
       elseif cC=="\"
         exit
       endif
     next
    else
      ++i
      cC:=substr(cStr,i,1)
    endif

     if !fitalic .and. !fbold
       FontPT:=1
     elseif !fitalic .and. fbold
       FontPT:=2
     elseif fitalic .and. !fbold
       FontPT:=3
     elseif fitalic .and. fbold
       FontPT:=4
     endif

     if cC=="\" .and. substr(cStr,i-1,2)<>"\\"
        --i
        loop // vrati se na obradu nove sekvence
     endif

   endif // "\"

   if cC == " " .or. i==len(cStr) .or. fUNL
         if fUNL
           cC:=""
         endif

         if cC==" " .or. fUNL
           nPom:=0
         else
           nAsc:=ASC(cC)
           if nAsc>165
             nAsc:=77
           endif
           nPom:=aFw[FontTip,nAsc-31,FontPT]*KOEFIC*Fontsize/10000
         endif
         if nPos+nPom+nWWidth<nLen
             cRed+=cTWord+cC
             if fUNL
               nPos:=0
             else
               nAsc:=ASC(cC)
               if nAsc>165
                  nAsc:=77
               endif
               nPos+=nWWidth+aFw[FontTip,nASC-31,FontPT]*KOEFIC*Fontsize/10000
             endif
             if i==len(cStr) .or. fUNL
               AADD(aRez,cRed)
               cRed:=""; nPos:=0
             endif
         else // rijec ne moze stati u tekucu liniju

             AADD(aRez,cRed)

             cTWord:=cTWord+cC
             cRed:=cTWord
             nPos:=nWWidth

             if fUNL
               nPom:=0
             else
               nAsc:=ASC(cC)
               if nAsc>165
                  nAsc:=77
               endif
               nPom:=aFw[FontTip,nASC-31,FontPT]*KOEFIC*Fontsize/10000
             endif

             nWWidth+=nPom
             if cC<>" "   // space ne uzeti u ukupnu velicinu
               nPom:=0
             endif

             if nWWidth-nPom>nLen // rijec je duza od citave linije
                cRed:=""
                nPos:=0
                for ii:=1 to len(cTWord)
                  nAsc:=ASC(substr(cTWord,ii,1))
                  if nAsc>165
                     nAsc:=77
                  endif
                  nPos+=aFw[FontTip,nASC-31,FontPt]*KOEFIC*Fontsize/10000
                  if nPos<=nLen
                     cRed+=substr(cTWord,ii,1)
                  else
                     nAsc:=ASC(substr(cTWord,ii,1))
                     if nAsc>165
                       nAsc:=77
                     endif
                     AADD(aRez,cRed)
                     nPos:=aFw[FontTip,nASC-31,FontPT]*KOEFIC*Fontsize/10000
                     cRed:=substr(cTWord,ii,1)
                  endif
                next  // ii
             endif
             if i==len(cStr)
               AADD(aRez,cRed)
             endif
         endif

        nWWidth:=0
        cTWord:=""
        fUNL:=.f.
   else
     cTWord+=cC
     nAsc:=ASC(cC)
     if nAsc>165
       nAsc:=77
     endif

     nWWidth+=aFw[FontTip,nASC-31,FontPT]*KOEFIC*Fontsize/10000
   endif
next

return aRez