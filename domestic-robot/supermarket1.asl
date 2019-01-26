last_order_id(1). // initial belief
totalBeer(5).


// plan to achieve the goal "order" for agent Ag
+!order(Product,Qtd)[source(Ag)] :
    totalBeer(B) &  B>=Qtd 
    <- -+totalBeer(B-Qtd)
        ?last_order_id(N);
         OrderId = N + 1;
         -+last_order_id(OrderId);
         //info_stock_beer(B);
         deliver(Product,Qtd,B);
         .send(Ag, tell, delivered(Product,Qtd,OrderId)).
         
         
  // plan to achieve the goal "order" for agent Ag
+!order(Product,Qtd)[source(Ag)] :
     totalBeer(B) & B<Qtd & B>0 
    <- -+totalBeer(0)
        ?last_order_id(N);
         OrderId = N + 1;
         -+last_order_id(OrderId);
         //info_stock_beer(B);
         .concat("Supermarket has only ", B, " beers.",M);
        .send(owner,tell,msg(M));
         deliver(Product,B);
         .send(Ag, tell, delivered(Product,B,OrderId)).
        
 // plan to achieve the goal "order" for agent Ag
+!order(Product,Qtd)[source(Ag)] :
     totalBeer(B) & B<=0 
    <- 
        .send(Ag, tell, cant_deliver).


