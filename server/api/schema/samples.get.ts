export default defineEventHandler(() => {
  return [
    {
      id: 'blog',
      label: 'Blog & Content (SQL)',
      description: 'Users, posts, categories, comments, tags, and post_tags with relationships.',
      language: 'sql',
      sql: `-- Database Diagram Visual Editor Schema
-- Type your DDL SQL commands below to visualize tables & relations

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    role VARCHAR(20) DEFAULT 'member',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    slug VARCHAR(60) NOT NULL UNIQUE,
    description TEXT,
    icon VARCHAR(30),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    author_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(280) NOT NULL UNIQUE,
    content TEXT NOT NULL,
    summary VARCHAR(500),
    status VARCHAR(20) DEFAULT 'draft',
    view_count INTEGER DEFAULT 0,
    published_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE comments (
    id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    parent_id INTEGER REFERENCES comments(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_approved BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tags (
    id SERIAL PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE post_tags (
    post_id INTEGER NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    tag_id INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (post_id, tag_id)
);`
    },
    {
      id: 'ecommerce',
      label: 'E-Commerce Store (SQL)',
      description: 'Customers, addresses, products, categories, orders, order items, and payments.',
      language: 'sql',
      sql: `-- E-Commerce Store Schema
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(30),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE customer_addresses (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    postal_code VARCHAR(20) NOT NULL,
    country_code VARCHAR(2) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE
);

CREATE TABLE product_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(120) NOT NULL UNIQUE,
    parent_id INTEGER REFERENCES product_categories(id) ON DELETE SET NULL
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    category_id INTEGER REFERENCES product_categories(id) ON DELETE SET NULL,
    sku VARCHAR(64) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL,
    inventory_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id),
    shipping_address_id INTEGER REFERENCES customer_addresses(id),
    status VARCHAR(30) DEFAULT 'pending',
    total_amount NUMERIC(10, 2) NOT NULL,
    shipping_fee NUMERIC(10, 2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER NOT NULL REFERENCES products(id),
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price NUMERIC(10, 2) NOT NULL,
    subtotal NUMERIC(10, 2) NOT NULL
);`
    },
    {
      id: 'dbml-social',
      label: 'Social Network (DBML)',
      description: 'Profiles, follows, feeds, likes, and notifications written in DBML markup.',
      language: 'dbml',
      sql: `// Social Network Schema in DBML format

Table users {
  id int [pk, increment]
  username varchar(50) [not null, unique]
  email varchar(255) [not null, unique]
  bio text [note: 'Short profile biography']
  created_at timestamp [default: 'now()']
}

Table posts {
  id int [pk, increment]
  author_id int [not null, ref: > users.id]
  caption text [not null]
  image_url text
  like_count int [default: 0]
  created_at timestamp [default: 'now()']
}

Table follows {
  follower_id int [pk, ref: > users.id]
  following_id int [pk, ref: > users.id]
  created_at timestamp [default: 'now()']
}

Table likes {
  user_id int [pk, ref: > users.id]
  post_id int [pk, ref: > posts.id]
  created_at timestamp [default: 'now()']
}

Table comments {
  id int [pk, increment]
  post_id int [not null, ref: > posts.id]
  user_id int [not null, ref: > users.id]
  content text [not null]
  created_at timestamp [default: 'now()']
}`
    },
    {
      id: 'prisma-saas',
      label: 'SaaS Platform (Prisma)',
      description: 'Organizations, users, memberships, projects, and api keys in Prisma Schema format.',
      language: 'prisma',
      sql: `// Prisma Schema Definition

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

model Organization {
  id        Int       @id @default(autoincrement())
  name      String
  slug      String    @unique
  plan      String    @default("starter")
  createdAt DateTime  @default(now())
  members   Membership[]
  projects  Project[]
}

model User {
  id          Int          @id @default(autoincrement())
  email       String       @unique
  fullName    String?
  avatarUrl   String?
  createdAt   DateTime     @default(now())
  memberships Membership[]
}

model Membership {
  id             Int          @id @default(autoincrement())
  organizationId Int
  organization   Organization @relation(fields: [organizationId], references: [id], onDelete: Cascade)
  userId         Int
  user           User         @relation(fields: [userId], references: [id], onDelete: Cascade)
  role           String       @default("member")
  createdAt      DateTime     @default(now())
}

model Project {
  id             Int          @id @default(autoincrement())
  organizationId Int
  organization   Organization @relation(fields: [organizationId], references: [id], onDelete: Cascade)
  name           String
  description    String?
  createdAt      DateTime     @default(now())
}`
    }
  ]
})
