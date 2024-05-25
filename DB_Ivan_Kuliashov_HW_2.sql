CREATE TABLE Orders (
    o_id SERIAL PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE Products (
    p_name TEXT PRIMARY KEY,
    price MONEY NOT NULL
);

CREATE TABLE Order_Items (
    order_id INT NOT NULL,
    product_name TEXT NOT NULL,
    amount NUMERIC(7,2) NOT NULL DEFAULT 1 CHECK (amount > 0),
    PRIMARY KEY (order_id, product_name),
    FOREIGN KEY (order_id) REFERENCES Orders(o_id),
    FOREIGN KEY (product_name) REFERENCES Products(p_name)
);

INSERT INTO Orders (order_date) VALUES
('2023-10-01'),
('2023-10-02');

INSERT INTO Products (p_name, price) VALUES
('p1', '$10.50'),
('p2', '$20.75');

INSERT INTO Order_Items (order_id, product_name, amount) VALUES
(1, 'p1', DEFAULT),
(1, 'p2', DEFAULT),
(2, 'p1', 2.5),
(2, 'p2', 3.0);

ALTER TABLE Products
ADD COLUMN description TEXT NOT NULL DEFAULT 'No description';

ALTER TABLE Orders
ADD COLUMN status TEXT NOT NULL DEFAULT 'pending';

ALTER TABLE Products
ADD COLUMN p_id SERIAL;

ALTER TABLE Order_Items
DROP CONSTRAINT order_items_product_name_fkey;

ALTER TABLE Products
DROP CONSTRAINT products_pkey;

ALTER TABLE Products
ADD PRIMARY KEY (p_id);

ALTER TABLE Products
ADD CONSTRAINT unique_p_name UNIQUE (p_name);

ALTER TABLE Order_Items
ADD COLUMN price MONEY;

UPDATE Order_Items
SET price = (SELECT price FROM Products WHERE Products.p_name = Order_Items.product_name);

ALTER TABLE Order_Items
ADD COLUMN total MONEY;

UPDATE Order_Items
SET total = price * amount;

ALTER TABLE Order_Items
ALTER COLUMN price SET NOT NULL,
ALTER COLUMN total SET NOT NULL;

ALTER TABLE Order_Items
ADD CONSTRAINT check_total CHECK (total = price * amount);

-- task 4

UPDATE Products
SET p_name = 'product1'
WHERE p_name = 'p1';

UPDATE Order_Items
SET product_name = 'product1'
WHERE product_name = 'p1';

DELETE FROM order_items
WHERE order_id = 1
  AND product_name = 'p2';
  
DELETE FROM order_items
WHERE order_id = 2;

UPDATE Products
SET price = '$5.00'
WHERE p_name = 'product1';

UPDATE Order_Items
SET price = '$5.00',
    total = CAST( '$5.00' as MONEY ) * amount
WHERE product_name = 'product1';

INSERT INTO Orders (order_date)
VALUES (CURRENT_DATE);

INSERT INTO Order_Items (order_id, product_name, amount, price, total)
SELECT 3, 'product1', 3, price, price * 3
FROM Products
WHERE p_name = 'product1';
