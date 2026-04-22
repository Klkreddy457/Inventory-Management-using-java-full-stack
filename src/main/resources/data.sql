-- InventoryPro Sample Data
-- This file runs automatically on startup if the table is empty

INSERT INTO products (name, category, price, quantity, description, created_at)
SELECT 'Dell Laptop', 'Electronics', 75000.00, 15, '14-inch, 16GB RAM, Intel i7', NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Dell Laptop');

INSERT INTO products (name, category, price, quantity, description, created_at)
SELECT 'Office Chair', 'Furniture', 8500.00, 8, 'Ergonomic mesh chair with lumbar support', NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Office Chair');

INSERT INTO products (name, category, price, quantity, description, created_at)
SELECT 'HP Printer', 'Electronics', 12000.00, 5, 'Wireless laser printer', NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'HP Printer');

INSERT INTO products (name, category, price, quantity, description, created_at)
SELECT 'Desk Lamp', 'Furniture', 1200.00, 25, 'LED adjustable desk lamp', NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Desk Lamp');

INSERT INTO products (name, category, price, quantity, description, created_at)
SELECT 'USB-C Hub', 'Electronics', 2500.00, 3, '7-in-1 USB hub with HDMI and SD card reader', NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'USB-C Hub');

INSERT INTO products (name, category, price, quantity, description, created_at)
SELECT 'Notebook Pack', 'Stationery', 350.00, 100, 'Pack of 5 ruled A4 notebooks', NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Notebook Pack');

INSERT INTO products (name, category, price, quantity, description, created_at)
SELECT 'Whiteboard', 'Office', 4500.00, 7, '4x3 ft magnetic whiteboard with markers', NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Whiteboard');

INSERT INTO products (name, category, price, quantity, description, created_at)
SELECT 'Stapler', 'Stationery', 450.00, 2, 'Heavy duty metal stapler', NOW()
WHERE NOT EXISTS (SELECT 1 FROM products WHERE name = 'Stapler');
