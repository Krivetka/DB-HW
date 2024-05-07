CREATE TABLE People (
    person_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL
);

ALTER TABLE Roles
ADD CONSTRAINT CK_Roles_RoleName CHECK (role_name IN ('seller', 'buyer', 'administrator'));

CREATE TABLE People_Roles (
    person_id INT,
    role_id INT,
    PRIMARY KEY (person_id, role_id),
    FOREIGN KEY (person_id) REFERENCES People(person_id),
    FOREIGN KEY (role_id) REFERENCES Roles(role_id)
);

CREATE TABLE Auctions (
    auction_id SERIAL PRIMARY KEY,
    date DATE NOT NULL CHECK (date > '2000-01-01'),
    time TIME NOT NULL,
    location VARCHAR(255) NOT NULL,
    description TEXT NOT NULL DEFAULT 'No description provided'
);

CREATE TABLE Items (
    item_id SERIAL PRIMARY KEY,
    verbal_description TEXT NOT NULL,
    starting_price DECIMAL(10,2) NOT NULL CHECK (starting_price > 0)
);

CREATE TABLE Lot_Numbers (
    lot_id SERIAL PRIMARY KEY,
    item_id INT NOT NULL,
    auction_id INT NOT NULL,
    lot_number INT NOT NULL UNIQUE,
    claimed_price DECIMAL(10,2) NOT NULL CHECK (claimed_price >= 0),
    buyer_id INT,
    FOREIGN KEY (item_id) REFERENCES Items(item_id),
    FOREIGN KEY (auction_id) REFERENCES Auctions(auction_id),
    FOREIGN KEY (buyer_id) REFERENCES People(person_id)
);

CREATE TABLE Item_Sellers (
    item_id INT,
    seller_id INT,
    FOREIGN KEY (item_id) REFERENCES Items(item_id),
    FOREIGN KEY (seller_id) REFERENCES People(person_id),
    PRIMARY KEY (item_id, seller_id)
);

CREATE TABLE Sales (
    sale_id SERIAL PRIMARY KEY,
    item_id INT NOT NULL,
    buyer_id INT NOT NULL,
    actual_price DECIMAL(10,2) NOT NULL CHECK (actual_price > 0),
    date_of_sale DATE NOT NULL CHECK (date_of_sale > '2000-01-01'),
    FOREIGN KEY (item_id) REFERENCES Items(item_id),
    FOREIGN KEY (buyer_id) REFERENCES People(person_id)
);

CREATE TABLE Employee (
    employee_id SERIAL PRIMARY KEY,
    person_id INT UNIQUE NOT NULL,
    FOREIGN KEY (person_id) REFERENCES People(person_id)
);

CREATE TABLE Employee_Auctions (
    employee_id INT,
    auction_id INT,
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id),
    FOREIGN KEY (auction_id) REFERENCES Auctions(auction_id),
    PRIMARY KEY (employee_id, auction_id)
);

INSERT INTO People (name, address, phone_number, email) VALUES
('John Doe', '123 Elm St', '555-1234', 'john.doe@example.com'),
('Alice Johnson', '789 Pine St', '555-2345', 'alice.johnson@example.com'),
('Bob Martin', '101 Maple St', '555-3456', 'bob.martin@example.com'),
('Carol White', '202 Spruce St', '555-4567', 'carol.white@example.com'),
('Dave Black', '303 Birch St', '555-5678', 'dave.black@example.com');

INSERT INTO Roles (role_name) VALUES
('seller'),
('buyer'),
('administrator');

INSERT INTO People_Roles (person_id, role_id) VALUES
(1, 1),
(2, 2);

INSERT INTO Auctions (date, time, location, description) VALUES
('2024-05-01', '14:00', 'Convention Center', 'Annual Spring Auction'),
('2024-06-02', '16:00', 'Convention Center', 'Annual Spring Auction');

INSERT INTO Items (verbal_description, starting_price) VALUES
('Signed baseball', 50.00),
('Oil painting', 500.00),
('Vintage camera', 120.00),
('Silver necklace', 80.00);

INSERT INTO Lot_Numbers (item_id, auction_id, lot_number, claimed_price, buyer_id) VALUES
(1, 1, 101, 200.00, 2),
(2, 2, 102, 1000.00, 2);

INSERT INTO Item_Sellers (item_id, seller_id) VALUES
(1, 1),
(2, 2);

INSERT INTO Sales (item_id, buyer_id, actual_price, date_of_sale) VALUES
(1, 2, 200.00, '2024-05-01'),
(2, 2, 1200.00, '2024-05-01');

INSERT INTO Employee (person_id) VALUES
(2),
(3);

INSERT INTO Employee_Auctions (employee_id, auction_id) VALUES
(1, 1),
(2, 2);

ALTER TABLE People ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
UPDATE People SET record_ts = CURRENT_DATE WHERE record_ts IS NULL;

ALTER TABLE Roles ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
UPDATE Roles SET record_ts = CURRENT_DATE WHERE record_ts IS NULL;

ALTER TABLE People_Roles ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
UPDATE People_Roles SET record_ts = CURRENT_DATE WHERE record_ts IS NULL;

ALTER TABLE Auctions ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
UPDATE Auctions SET record_ts = CURRENT_DATE WHERE record_ts IS NULL;

ALTER TABLE Items ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
UPDATE Items SET record_ts = CURRENT_DATE WHERE record_ts IS NULL;

ALTER TABLE Lot_Numbers ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
UPDATE Lot_Numbers SET record_ts = CURRENT_DATE WHERE record_ts IS NULL;

ALTER TABLE Item_Sellers ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
UPDATE Item_Sellers SET record_ts = CURRENT_DATE WHERE record_ts IS NULL;

ALTER TABLE Sales ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
UPDATE Sales SET record_ts = CURRENT_DATE WHERE record_ts IS NULL;

ALTER TABLE Employee ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
UPDATE Employee SET record_ts = CURRENT_DATE WHERE record_ts IS NULL;

ALTER TABLE Employee_Auctions ADD COLUMN record_ts DATE DEFAULT CURRENT_DATE;
UPDATE Employee_Auctions SET record_ts = CURRENT_DATE WHERE record_ts IS NULL;
