
/* Initial beliefs and rules */

// all'inizio credo che ci sia birra nel frigo
available(beer,fridge).

// il mio padrone non dovrebbe consumare piu' di 10 birre
limit(beer,10).

beer_order(5).

super_no_beer.

my_super(supermarket).

/*  
    ritengo che B birre siano troppe
        - oggi e' YY-MM-DD
        e
        - se in data YY-MM-DD, sono state consumate "QtbB" birre
        e
        - se il limite di birre e' Limit
        e
        - se QtdB supera Limit
    */
too_much(B) :-
   .date(YY,MM,DD) &
   .count(consumed(YY,MM,DD,_,_,_,B),QtdB) &
   limit(B,Limit) &
   QtdB > Limit.


need_to_move.
/* Plans */

/*
    Raggiungo l'obiettivo che il padrone abbia una birra  quando
    - un  c'e' una birra in frigo
    e
    - non ha bevuto troppe birre
    =>
        sottotask
            faccio arrivare il robot al frigo

*/

+!has(owner,beer)
   :  available(beer,fridge) & not too_much(beer)
   <- !at(robot,fridge);
      open(fridge);
      get(beer);
      close(fridge);
      !at(robot,owner);
      hand_in(beer);
      ?has(owner,beer);
      // remember that another beer has been consumed
      .date(YY,MM,DD); .time(HH,NN,SS);
      +consumed(YY,MM,DD,HH,NN,SS,beer).

+!has(owner,beer)
   :  not available(beer,fridge) & my_super(Super)
   <- .send(Super, achieve, order(beer,5));
      !at(robot,fridge). // go to fridge and wait there.

+!has(owner,beer)
   :  too_much(beer) & limit(beer,L)
   <- .concat("The Department of Health does not allow me to give you more than ", L,
              " beers a day! I am very sorry about that!",M);
      .send(owner,tell,msg(M)).


-!has(_,_)
   :  true
   <- .current_intention(I);
      .print("Failed to achieve goal '!has(_,_)'. Current intention is: ",I).

+!at(robot,P) : at(robot,P) <- true.


+!at(robot,P) : not need_to_move &  not at(robot,P) <- true.

+!at(robot,P) : not at(robot,P)  
  <- move_towards(P);
     !at(robot,P).

        
  +cant_deliver(beer,_Qtd,_OrderId)[source(supermarket)]
  :  beer_order(Beers) & Qtd< Beers
  <-
        .concat("supermarket has 0 beers!",M);
        .send(owner,tell,msg(M)); 
        +available(beer,fridge);
     .send(supermarket1, achieve, order(beer,Beers));
     -+my_super(supermarket1).
     
  +cant_deliver(beer,_Qtd,_OrderId)[source(supermarket1)]
  :  beer_order(Beers) & Qtd< Beers
  <- -need_to_move;
        .concat("supermarket1 has 0 beers!",M);
        .send(owner,tell,msg(M)).
     
  +delivered(beer,Qtd,OrderId)[source(supermarket)]
  :  beer_order(Beers) & Qtd< Beers
  <-
        .concat("Incomplete deliver from supermarket!",M);
        .send(owner,tell,msg(M)); 
        +available(beer,fridge);
     .send(supermarket1, achieve, order(beer,Beers));
     -+my_super(supermarket1).
 
+delivered(beer,Qtd,OrderId)[source(supermarket1)]
  :  beer_order(Beers) & Qtd< Beers
  <-
        .concat("Incomplete deliver from supermarket1: NO MORE ORDER TO SUPERMARKET.",M);
        .send(owner,tell,msg(M));
        -need_to_move. 
     
  +delivered(beer,Qtd,OrderId)[source(supermarket1)]
  :  beer_order(Beers) & Qtd>= Beers
  <-
        +available(beer,fridge);
        !has(owner,beer).
       
  +delivered(beer,Qtd,OrderId)[source(supermarket)]
  :  beer_order(Beers) & Qtd>= Beers
  <-
        +available(beer,fridge);
        !has(owner,beer).
     /*
+delivered(beer,_Qtd,_OrderId)[source(supermarket1)]
  :  true
  <- +available(beer,fridge);
     !has(owner,beer).
     */
 /*+delivered(beer,_Qtd,_OrderId)[source(supermarket1)]
  :  true
  <- +available(beer,fridge);
     !has(owner,beer).
 /*
 +delivered(beer,_Qtd,_OrderId)[source(supermarket1)]
  :  beer_order(Beers) & Qtd< Beers
  <- +available(beer,fridge);
        .concat("No more beers!!",M);
        .send(owner,tell,msg(M));
     !has(owner,beer).
     */
 +msg(M)[source(Ag)] : true
   <- .print("Message from ",Ag,": ",M);
      -msg(M).

// when the fridge is opened, the beer stock is perceived
// and thus the available belief is updated
+stock(beer,0)
   :  available(beer,fridge)
   <- -available(beer,fridge).
+stock(beer,N)
   :  N > 0 & not available(beer,fridge)
   <- -+available(beer,fridge).

+?time(T) : true
  <-  time.check(T).

