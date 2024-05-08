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
