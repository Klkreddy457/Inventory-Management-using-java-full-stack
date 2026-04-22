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
