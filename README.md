# InventoryPro — Product & Inventory Management System 

A full-stack Java web application built with Spring Boot, MySQL, and static HTML/CSS/JS, bulit by using AI.

---

## Tech Stack

| Layer      | Technology                     |
|------------|-------------------------------|
| Frontend   | HTML5, CSS3, Vanilla JS (Fetch API) |
| Backend    | Spring Boot 3.2, Spring MVC   |
| ORM        | Spring Data JPA (Hibernate)   |
| Database   | MySQL 8.x                     |
| Build Tool | Maven                         |

---

## Features

- Dashboard with live stats (total products, stock value, low stock count)
- Full CRUD — Add, View, Edit, Delete products
- Search products by name (live filter)
- Filter by category (Electronics, Furniture, Stationery, Office)
- Low stock alerts (items with quantity < 10)
- REST API with proper HTTP methods (GET, POST, PUT, DELETE)

---

## REST API Endpoints

| Method | Endpoint                        | Description              |
|--------|---------------------------------|--------------------------|
| GET    | /api/products                   | Get all products         |
| GET    | /api/products?search=laptop     | Search by name           |
| GET    | /api/products?category=Electronics | Filter by category    |
| GET    | /api/products/{id}              | Get product by ID        |
| POST   | /api/products                   | Create new product       |
| PUT    | /api/products/{id}              | Update product           |
| DELETE | /api/products/{id}              | Delete product           |
| GET    | /api/products/low-stock         | Get low stock items      |
| GET    | /api/products/stats             | Get dashboard stats      |

---

## How to Run

### Prerequisites
- Java 17+
- Maven 3.8+
- MySQL 8.x

### Step 1 — Create MySQL database

```sql
CREATE DATABASE inventory_db;
```

### Step 2 — Configure your DB password

Open `src/main/resources/application.properties` and update:

```properties
spring.datasource.password=YOUR_MYSQL_PASSWORD
```

### Step 3 — Run with Maven

```bash
cd inventory-management
mvn spring-boot:run
```

### Optional — Run without MySQL (uses H2 in-memory)
```powershell
$env:SPRING_PROFILES_ACTIVE="h2"
mvn spring-boot:run
```

### Step 4 — Open in browser

```
http://localhost:8080/index.html
```

---

## Project Structure

```
src/
├── main/
│   ├── java/com/inventory/
│   │   ├── InventoryManagementApplication.java
│   │   ├── entity/Product.java
│   │   ├── repository/ProductRepository.java
│   │   ├── service/ProductService.java
│   │   └── controller/ProductController.java
│   └── resources/
│       ├── application.properties
│       ├── data.sql
│       └── static/
│           ├── index.html        (Dashboard)
│           ├── products.html     (Product list)
│           ├── add-product.html  (Add/Edit form)
│           └── style.css         (Shared styles)
```


bulit by using AI
