# InventoryPro — Java Source Files Explained

This document explains every Java file in the project, what it does, why it exists,
and how it fits into the overall Spring Boot architecture.

---

## Project Architecture Overview

The backend follows the classic **3-Layer Spring Boot Architecture**:

```
HTTP Request
     │
     ▼
┌─────────────────────┐
│   Controller Layer  │  ← Receives HTTP requests, sends HTTP responses
│  (ProductController)│
└─────────────────────┘
     │
     ▼
┌─────────────────────┐
│   Service Layer     │  ← Contains all business logic
│  (ProductService)   │
└─────────────────────┘
     │
     ▼
┌─────────────────────┐
│  Repository Layer   │  ← Talks to the MySQL database
│ (ProductRepository) │
└─────────────────────┘
     │
     ▼
┌─────────────────────┐
│   Entity Layer      │  ← Represents a row in the database table
│    (Product)        │
└─────────────────────┘
     │
     ▼
  MySQL Database
```

---

## File-by-File Breakdown

---

### 1. `InventoryManagementApplication.java`
**Location:** `src/main/java/com/inventory/`

```java
package com.inventory;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class InventoryManagementApplication {
    public static void main(String[] args) {
        SpringApplication.run(InventoryManagementApplication.class, args);
    }
}
```

#### What it does
This is the **entry point** of the entire application — the first file Java runs.

#### Key concepts

| Element | Explanation |
|---|---|
| `main()` method | Standard Java entry point. Every Java program starts here. |
| `@SpringBootApplication` | A "super annotation" that does three things at once: enables component scanning (finds all your `@Controller`, `@Service`, etc.), enables auto-configuration (sets up Spring defaults), and marks this as a configuration class. |
| `SpringApplication.run(...)` | Boots up the embedded Tomcat server, loads all beans, connects to the database, and starts listening for HTTP requests on port 8080. |

#### Why it exists
Without this file, there is **no application**. It's the ignition key.

---

### 2. `Product.java` — The Entity
**Location:** `src/main/java/com/inventory/entity/`

```java
package com.inventory.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "products")
@Data
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String category;

    @Column(nullable = false)
    private Double price;

    @Column(nullable = false)
    private Integer quantity;

    private String description;

    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }
}
```

#### What it does
This class is a **blueprint** that maps directly to the `products` table in MySQL.
Every field in this class = one column in the database table.

#### Key concepts

| Annotation / Element | Explanation |
|---|---|
| `@Entity` | Tells JPA (Java Persistence API): "This class is a database table." |
| `@Table(name = "products")` | Sets the exact table name in MySQL. Without this, JPA would guess the name. |
| `@Data` (Lombok) | Automatically generates `getters`, `setters`, `toString()`, `equals()`, and `hashCode()` — so you don't have to write 50 lines of boilerplate code. |
| `@Id` | Marks the `id` field as the **primary key** of the table. |
| `@GeneratedValue(strategy = GenerationType.IDENTITY)` | Tells MySQL to auto-increment the `id` (1, 2, 3, ...) for each new product. You never set the ID manually. |
| `@Column(nullable = false)` | Adds a `NOT NULL` constraint to that column in MySQL. Required fields. |
| `@Column(name = "created_at", updatable = false)` | Maps to the `created_at` column. `updatable = false` means this value is set once and never changed. |
| `@PrePersist` | A JPA lifecycle hook — this method runs **automatically just before** a new record is saved to the database. Used here to stamp the creation time. |
| `LocalDateTime` | Java's built-in class to store date + time (e.g., `2026-04-02T10:30:00`). |

#### Database table it creates

```
products table:
┌────┬──────────┬────────────┬─────────┬──────────┬─────────────┬─────────────────────┐
│ id │   name   │  category  │  price  │ quantity │ description │     created_at      │
├────┼──────────┼────────────┼─────────┼──────────┼─────────────┼─────────────────────┤
│  1 │ Laptop   │ Electronics│ 75000.0 │    10    │ Dell XPS 15 │ 2026-04-01T09:00:00 │
│  2 │ Stapler  │ Stationery │   450.0 │     2    │ Metal body  │ 2026-04-01T09:01:00 │
└────┴──────────┴────────────┴─────────┴──────────┴─────────────┴─────────────────────┘
```

---

### 3. `ProductRepository.java` — The Repository
**Location:** `src/main/java/com/inventory/repository/`

```java
package com.inventory.repository;

import com.inventory.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    List<Product> findByNameContainingIgnoreCase(String name);
    List<Product> findByCategory(String category);
    List<Product> findByQuantityLessThan(Integer threshold);
}
```

#### What it does
This is the **database access layer**. It handles all SQL queries — but you never write
SQL yourself. Spring Data JPA generates the SQL from the method names automatically.

#### Key concepts

| Element | Explanation |
|---|---|
| `interface` (not `class`) | Repositories are interfaces. Spring automatically creates the implementation at runtime. You just declare what you need. |
| `@Repository` | Marks this as a Spring-managed data access component. Also enables database exception translation (converts SQL errors into Spring exceptions). |
| `extends JpaRepository<Product, Long>` | Inherits dozens of ready-made methods: `findAll()`, `findById()`, `save()`, `deleteById()`, `count()`, etc. `Product` = entity type, `Long` = primary key type. |
| `findByNameContainingIgnoreCase(String name)` | Spring reads this method name and generates: `SELECT * FROM products WHERE LOWER(name) LIKE LOWER('%name%')`. Case-insensitive search. |
| `findByCategory(String category)` | Generates: `SELECT * FROM products WHERE category = ?`. Queries by exact category match. |
| `findByQuantityLessThan(Integer threshold)` | Generates: `SELECT * FROM products WHERE quantity < ?`. Used to find low stock items (threshold = 10). |

#### Free methods inherited from `JpaRepository`

```java
productRepository.findAll()          // SELECT * FROM products
productRepository.findById(1L)       // SELECT * FROM products WHERE id = 1
productRepository.save(product)      // INSERT or UPDATE
productRepository.deleteById(1L)     // DELETE FROM products WHERE id = 1
productRepository.count()            // SELECT COUNT(*) FROM products
```

---

### 4. `ProductService.java` — The Service
**Location:** `src/main/java/com/inventory/service/`

```java
package com.inventory.service;

import com.inventory.entity.Product;
import com.inventory.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
public class ProductService {

    @Autowired
    private ProductRepository productRepository;

    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    public Optional<Product> getProductById(Long id) {
        return productRepository.findById(id);
    }

    public Product saveProduct(Product product) {
        return productRepository.save(product);
    }

    public void deleteProduct(Long id) {
        productRepository.deleteById(id);
    }

    public List<Product> searchProducts(String name) {
        return productRepository.findByNameContainingIgnoreCase(name);
    }

    public List<Product> getByCategory(String category) {
        return productRepository.findByCategory(category);
    }

    public List<Product> getLowStockProducts() {
        return productRepository.findByQuantityLessThan(10);
    }

    public Map<String, Object> getStats() {
        List<Product> all = productRepository.findAll();
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalProducts", all.size());
        stats.put("totalStock", all.stream().mapToInt(Product::getQuantity).sum());
        stats.put("totalValue", all.stream()
                .mapToDouble(p -> p.getPrice() * p.getQuantity()).sum());
        stats.put("lowStockCount", productRepository.findByQuantityLessThan(10).size());
        return stats;
    }
}
```

#### What it does
The service layer holds all **business logic**. The controller doesn't think — it just
delegates to the service. The service is where decisions are made.

#### Key concepts

| Element | Explanation |
|---|---|
| `@Service` | Marks this as a Spring-managed service bean. Spring creates one instance and shares it everywhere it's needed. |
| `@Autowired` | **Dependency Injection** — Spring automatically creates and injects a `ProductRepository` instance here. You don't do `new ProductRepository()`. |
| `Optional<Product>` | A Java wrapper that safely handles the case where a product might not exist. Avoids `NullPointerException`. |
| `getStats()` | The most complex method — uses Java Streams to compute dashboard statistics without multiple DB calls. |

#### `getStats()` explained step by step

```java
List<Product> all = productRepository.findAll();
// Fetches all products from DB into a List

stats.put("totalProducts", all.size());
// Counts how many products exist

stats.put("totalStock", all.stream().mapToInt(Product::getQuantity).sum());
// Converts list → stream → extracts quantity from each → sums them all
// e.g., [10, 2, 7, 100] → 119

stats.put("totalValue", all.stream()
        .mapToDouble(p -> p.getPrice() * p.getQuantity()).sum());
// For each product: price × quantity → sums all
// e.g., (75000×10) + (450×2) = 750900

stats.put("lowStockCount", productRepository.findByQuantityLessThan(10).size());
// Counts products with fewer than 10 units
```

---

### 5. `ProductController.java` — The REST Controller
**Location:** `src/main/java/com/inventory/controller/`

```java
package com.inventory.controller;

import com.inventory.entity.Product;
import com.inventory.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/products")
@CrossOrigin(origins = "*")
public class ProductController {

    @Autowired
    private ProductService productService;

    @GetMapping
    public List<Product> getAllProducts(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) String category) {
        if (search != null && !search.isEmpty()) {
            return productService.searchProducts(search);
        }
        if (category != null && !category.isEmpty()) {
            return productService.getByCategory(category);
        }
        return productService.getAllProducts();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Product> getProduct(@PathVariable Long id) {
        return productService.getProductById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Product> createProduct(@RequestBody Product product) {
        Product saved = productService.saveProduct(product);
        return ResponseEntity.ok(saved);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Product> updateProduct(
            @PathVariable Long id, @RequestBody Product product) {
        return productService.getProductById(id).map(existing -> {
            product.setId(id);
            product.setCreatedAt(existing.getCreatedAt());
            return ResponseEntity.ok(productService.saveProduct(product));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id) {
        if (!productService.getProductById(id).isPresent()) {
            return ResponseEntity.notFound().build();
        }
        productService.deleteProduct(id);
        return ResponseEntity.ok().<Void>build();
    }

    @GetMapping("/low-stock")
    public List<Product> getLowStock() {
        return productService.getLowStockProducts();
    }

    @GetMapping("/stats")
    public Map<String, Object> getStats() {
        return productService.getStats();
    }
}
```

#### What it does
The controller is the **HTTP gateway**. It maps URLs to Java methods. When a browser
or frontend makes an HTTP request, this class handles it and returns a JSON response.

#### Key annotations

| Annotation | Explanation |
|---|---|
| `@RestController` | Combines `@Controller` + `@ResponseBody`. Every method return value is automatically converted to JSON and sent in the HTTP response body. |
| `@RequestMapping("/api/products")` | All endpoints in this class start with `/api/products`. |
| `@CrossOrigin(origins = "*")` | Enables **CORS** — allows the frontend HTML files (served from `localhost:8080`) to call these APIs without being blocked by the browser's same-origin policy. |
| `@GetMapping` | Handles `HTTP GET` requests. Used for fetching data. |
| `@PostMapping` | Handles `HTTP POST` requests. Used for creating new records. |
| `@PutMapping("/{id}")` | Handles `HTTP PUT` requests. Used to update an existing record. |
| `@DeleteMapping("/{id}")` | Handles `HTTP DELETE` requests. Used to remove a record. |
| `@PathVariable Long id` | Extracts the `{id}` from the URL. Example: `/api/products/3` → `id = 3`. |
| `@RequestParam String search` | Extracts query parameters from the URL. Example: `/api/products?search=laptop` → `search = "laptop"`. |
| `@RequestBody Product product` | Parses the JSON body of the HTTP request into a `Product` Java object automatically. |
| `ResponseEntity<Product>` | Wraps the response so you can control the HTTP status code (200 OK, 404 Not Found, etc.) along with the body. |

#### API endpoint map

```
GET    /api/products                    → getAllProducts() → returns all products as JSON
GET    /api/products?search=laptop      → getAllProducts() → filters by name
GET    /api/products?category=Electronics → getAllProducts() → filters by category
GET    /api/products/{id}               → getProduct()    → returns one product or 404
POST   /api/products                    → createProduct() → saves new product, returns it
PUT    /api/products/{id}               → updateProduct() → updates product or 404
DELETE /api/products/{id}               → deleteProduct() → removes product or 404
GET    /api/products/low-stock          → getLowStock()   → items with quantity < 10
GET    /api/products/stats              → getStats()      → dashboard statistics
```

#### The `updateProduct` method in detail

```java
return productService.getProductById(id).map(existing -> {
    product.setId(id);                          // Ensure correct ID
    product.setCreatedAt(existing.getCreatedAt()); // Preserve original creation time
    return ResponseEntity.ok(productService.saveProduct(product));
}).orElse(ResponseEntity.notFound().build());
```
This uses **functional style** with `Optional.map()`:
- If the product exists → update it, preserving `createdAt`, return `200 OK`
- If the product doesn't exist → return `404 Not Found`

---

## How All Files Work Together — A Full Example

**Scenario:** User adds a new product via the "Add Product" form.

```
1. Browser sends:
   POST /api/products
   Body: { "name": "Keyboard", "category": "Electronics", "price": 1500, "quantity": 20 }

2. ProductController.createProduct() receives the request
   → @RequestBody converts JSON → Product object

3. ProductController calls:
   productService.saveProduct(product)

4. ProductService calls:
   productRepository.save(product)

5. ProductRepository (JPA) executes:
   INSERT INTO products (name, category, price, quantity) VALUES ('Keyboard', 'Electronics', 1500, 20)

6. @PrePersist in Product.java fires → sets createdAt = now()

7. MySQL stores the row, returns the new id (e.g., id = 9)

8. The saved Product (with id=9) bubbles back up:
   Repository → Service → Controller → HTTP Response (JSON)

9. Browser receives:
   { "id": 9, "name": "Keyboard", "category": "Electronics",
     "price": 1500, "quantity": 20, "createdAt": "2026-04-02T10:36:00" }
```

---

## Annotations Quick Reference

| Annotation | Layer | Purpose |
|---|---|---|
| `@SpringBootApplication` | App entry | Bootstraps the entire Spring app |
| `@Entity` | Entity | Maps class to DB table |
| `@Table` | Entity | Sets the table name |
| `@Id` | Entity | Marks primary key |
| `@GeneratedValue` | Entity | Auto-increment ID |
| `@Column` | Entity | Column constraints |
| `@PrePersist` | Entity | Runs before INSERT |
| `@Data` (Lombok) | Entity | Generates boilerplate |
| `@Repository` | Repository | DB access component |
| `@Service` | Service | Business logic component |
| `@Autowired` | Service/Controller | Dependency injection |
| `@RestController` | Controller | HTTP + JSON responses |
| `@RequestMapping` | Controller | Base URL for all endpoints |
| `@CrossOrigin` | Controller | Enables CORS |
| `@GetMapping` | Controller | HTTP GET handler |
| `@PostMapping` | Controller | HTTP POST handler |
| `@PutMapping` | Controller | HTTP PUT handler |
| `@DeleteMapping` | Controller | HTTP DELETE handler |
| `@PathVariable` | Controller | Extracts `{id}` from URL |
| `@RequestParam` | Controller | Extracts `?key=value` from URL |
| `@RequestBody` | Controller | Parses JSON request body |

---

## Running the Application

### Prerequisites

Before running, make sure the following are installed:

| Tool | Required Version | Check Command |
|---|---|---|
| Java (JDK) | 17 or higher | `java -version` |
| Maven | 3.8 or higher | `mvn -version` |
| MySQL | 8.x | Check Windows Services |

---

### Step 1 — Start MySQL Service

MySQL must be running before the app starts. Open **PowerShell as Administrator** and run:

```powershell
net start MySQL80
```

To check if MySQL is already running (no admin needed):

```powershell
Get-Service -Name "MySQL80" | Select-Object Status, Name
```

Expected output:
```
 Status   Name
 ------   ----
Running   MYSQL80
```

Alternatively, start MySQL from the Windows GUI:
1. Press `Win + R` → type `services.msc` → press Enter
2. Find **MySQL80** in the list → Right-click → **Start**

---

### Step 2 — Create the Database

Open MySQL command line and create the database (only needed once):

```bash
mysql -u root -p
```

Then inside MySQL shell:

```sql
CREATE DATABASE IF NOT EXISTS inventory_db;
EXIT;
```

Or do it in one command (replace `1234` with your actual password):

```bash
mysql -u root -p1234 -e "CREATE DATABASE IF NOT EXISTS inventory_db;"
```

---

### Step 3 — Configure Database Password

Open `src/main/resources/application.properties` and set your MySQL root password:

```properties
spring.datasource.password=1234
```

> The current password is already set to `1234` in this project.

---

### Step 4 — Run the Application

#### Option A — Using the `run.bat` script (Windows, easiest)

Double-click `run.bat` or run from terminal:

```cmd
cd d:\inventory-management\inventory-management
.\run.bat
```

When prompted:
```
Enter your MySQL root password (press Enter if blank): 1234
```

The script automatically:
- Sets `JAVA_HOME` and `MVN_HOME` paths
- Starts MySQL (if not already running)
- Creates the database
- Launches the Spring Boot app

---

#### Option B — Using Maven directly (PowerShell)

If Java and Maven are in your system PATH:

```powershell
cd d:\inventory-management\inventory-management
mvn spring-boot:run
```

If Java/Maven are installed in custom locations (as in this project):

```powershell
$env:JAVA_HOME="$env:USERPROFILE\jdk17\jdk-17.0.14+7"
$env:MVN_HOME="$env:USERPROFILE\maven\apache-maven-3.9.6"
$env:PATH="$env:JAVA_HOME\bin;$env:MVN_HOME\bin;$env:PATH"
mvn spring-boot:run
```

---

#### Option C — Build JAR and run it

First build the project into a standalone JAR file:

```powershell
mvn clean package -DskipTests
```

Then run the JAR directly:

```powershell
java -jar target\inventory-management-1.0.0.jar
```

With a custom DB password:

```powershell
java -jar target\inventory-management-1.0.0.jar --spring.datasource.password=1234
```

---

### Step 5 — Open in Browser

Once you see this in the terminal output:
```
Started InventoryManagementApplication in 3.8 seconds
```

Open your browser and go to:

| Page | URL |
|---|---|
| Dashboard | http://localhost:8080/index.html |
| Products List | http://localhost:8080/products.html |
| Add Product | http://localhost:8080/add-product.html |

---

### Useful Maven Commands

| Command | What it does |
|---|---|
| `mvn spring-boot:run` | Compile and run the app (dev mode) |
| `mvn clean package` | Build a production JAR in `target/` |
| `mvn clean package -DskipTests` | Build JAR and skip unit tests |
| `mvn clean` | Delete the `target/` build folder |
| `mvn compile` | Compile source code only (no run) |
| `mvn test` | Run unit tests |
| `mvn dependency:tree` | Show all project dependencies |
| `mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Xmx512m"` | Run with custom JVM memory |

---

### Testing the REST API

After the app is running, you can test the API directly from your browser or terminal.

#### From a browser (GET requests only)

```
http://localhost:8080/api/products
http://localhost:8080/api/products?search=laptop
http://localhost:8080/api/products?category=Electronics
http://localhost:8080/api/products/1
http://localhost:8080/api/products/low-stock
http://localhost:8080/api/products/stats
```

#### From PowerShell using `Invoke-RestMethod`

```powershell
# Get all products
Invoke-RestMethod -Uri "http://localhost:8080/api/products" -Method Get

# Get product by ID
Invoke-RestMethod -Uri "http://localhost:8080/api/products/1" -Method Get

# Search products by name
Invoke-RestMethod -Uri "http://localhost:8080/api/products?search=laptop" -Method Get

# Get low stock items
Invoke-RestMethod -Uri "http://localhost:8080/api/products/low-stock" -Method Get

# Get dashboard stats
Invoke-RestMethod -Uri "http://localhost:8080/api/products/stats" -Method Get

# Create a new product (POST)
$body = @{
    name     = "Mechanical Keyboard"
    category = "Electronics"
    price    = 3500
    quantity = 15
    description = "RGB backlit"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/products" `
    -Method Post `
    -Body $body `
    -ContentType "application/json"

# Update a product (PUT)
$update = @{
    name     = "Mechanical Keyboard"
    category = "Electronics"
    price    = 3200
    quantity = 20
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/api/products/1" `
    -Method Put `
    -Body $update `
    -ContentType "application/json"

# Delete a product (DELETE)
Invoke-RestMethod -Uri "http://localhost:8080/api/products/1" -Method Delete
```

---

### Stopping the Application

In the terminal where the app is running, press:

```
Ctrl + C
```

If running from `run.bat`, confirm when prompted:
```
Terminate batch job (Y/N)? Y
```

---

### Common Errors & Fixes

| Error | Cause | Fix |
|---|---|---|
| `ERROR 2003: Can't connect to MySQL server` | MySQL service is not running | Run `net start MySQL80` as Administrator |
| `Access to DialectResolutionInfo cannot be null` | Wrong DB password or DB not created | Check `application.properties` password; create `inventory_db` |
| `Port 8080 already in use` | Another process is using port 8080 | Run `netstat -ano \| findstr :8080` to find and kill the process, or change port in `application.properties` to `server.port=9090` |
| `'mvn' is not recognized` | Maven not in PATH | Use the full PowerShell path setup from Option B above |
| `'java' is not recognized` | Java not in PATH | Use the full PowerShell path setup from Option B above |
| `Table 'inventory_db.products' doesn't exist` | Database not initialized | Run the app once — Hibernate creates the table automatically via `ddl-auto=update` |
