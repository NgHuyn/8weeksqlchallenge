/*
If Danny wants to expand his range of pizzas - how would this impact the existing data design? 
Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with 
all the toppings was added to the Pizza Runner menu?
*/

 /* If Danny wants to expand his range of pizzas by adding a new Supreme pizza with all the toppings, 
 this would impact the existing data design in the following ways:

1. Pizza Names Table (pizza_names): We would need to insert a new record for the Supreme pizza into the pizza_names table.

2. Pizza Recipes Table (pizza_recipes): We would need to insert a new record for the Supreme pizza along with its toppings
 into the pizza_recipes table.

3. Customer Orders Table (customer_orders): Whenever customers order the Supreme pizza, we would need to insert new records
into the customer_orders table with the appropriate pizza_id for the Supreme pizza.
*/

-- Emxample
-- Inserting the new pizza into the pizza_names table
INSERT INTO pizza_names (pizza_id, pizza_name)
VALUES (3, 'Supreme');

-- Inserting the toppings for the Supreme pizza into the pizza_recipes table
INSERT INTO pizza_recipes (pizza_id, toppings)
VALUES (3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');

-- Example of inserting a customer order for the new Supreme pizza
INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES (11, 106, 3, '', '', '2020-01-15 12:00:00');

/*
In this INSERT statement:
- We first insert a new record for the Supreme pizza into the pizza_names table with pizza_id = 3 and pizza_name = 'Supreme'.
- Then, we insert the toppings for the Supreme pizza into the pizza_recipes table, associating them with the pizza_id of 
the Supreme pizza.
- Finally, we insert an example customer order for the Supreme pizza into the customer_orders table, specifying the pizza_id
 of the Supreme pizza.
*/