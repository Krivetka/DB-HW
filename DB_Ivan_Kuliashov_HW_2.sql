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

