USE vestnan1_db;

-- Add alert column
ALTER TABLE product ADD COLUMN alert TEXT DEFAULT NULL;

-- Add rand column
ALTER TABLE product ADD COLUMN rand VARCHAR(250) DEFAULT NULL;

-- Show the updated table structure
DESCRIBE product; 