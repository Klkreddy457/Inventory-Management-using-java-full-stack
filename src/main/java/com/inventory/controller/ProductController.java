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
