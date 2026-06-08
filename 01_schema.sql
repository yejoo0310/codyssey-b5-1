PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS order_item;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS menu;
DROP TABLE IF EXISTS category;
DROP TABLE IF EXISTS customer;

CREATE TABLE customer (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    phone TEXT NOT NULL UNIQUE,
    email TEXT UNIQUE,
    created_at TEXT NOT NULL
);

CREATE TABLE category (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE menu (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category_id INTEGER NOT NULL,
    name TEXT NOT NULL UNIQUE,
    price INTEGER NOT NULL CHECK (price > 0),
    is_available INTEGER NOT NULL DEFAULT 1 CHECK (is_available IN (0, 1)),

    FOREIGN KEY (category_id)
        REFERENCES category(id)
);

CREATE TABLE orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    ordered_at TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('ORDERED', 'COMPLETED', 'CANCELED')),

    FOREIGN KEY (customer_id)
        REFERENCES customer(id)
);

CREATE TABLE order_item (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    menu_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price INTEGER NOT NULL CHECK (unit_price > 0),

    FOREIGN KEY (order_id)
        REFERENCES orders(id),

    FOREIGN KEY (menu_id)
        REFERENCES menu(id)
);