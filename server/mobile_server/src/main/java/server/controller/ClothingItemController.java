package server.controller;

import server.model.ClothingItem;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import server.repository.ClothingItemRepository;

import java.util.List;
import java.util.Optional;

@RestController
public class ClothingItemController {

    @Autowired
    private ClothingItemRepository itemsRepository;

    @GetMapping("/item")
    public ResponseEntity<List<ClothingItem>> getAllItems() {
        return new ResponseEntity(itemsRepository.findAll(), HttpStatus.OK);
    }

    @GetMapping("/item/{id}")
    public ClothingItem getItem(@PathVariable int id) {
        Optional<ClothingItem> itemOptional = itemsRepository.findById(id);
        return itemOptional.orElse(null);
    }

    @PostMapping("/item")
    public ResponseEntity<?> createItem(@RequestBody ClothingItem item) {
        itemsRepository.save(item);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/item/{id}")
    public ResponseEntity<?> updateItem(@RequestBody ClothingItem item, @PathVariable int id) {
        Optional<ClothingItem> optionalItem = itemsRepository.findById(id);

        if (optionalItem.isPresent()) {
            ClothingItem updatedItem = optionalItem.get();

            updatedItem.setName(item.getName());
            updatedItem.setDescription(item.getDescription());
            updatedItem.setPhoto(item.getPhoto());
            updatedItem.setSize(item.getSize());
            updatedItem.setPrice(item.getPrice());
            itemsRepository.save(updatedItem);
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
        }

        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/item/{id}")
    public ResponseEntity<?> deleteItem(@PathVariable int id) {
        Optional<ClothingItem> itemOptional = itemsRepository.findById(id);

        if (itemOptional.isPresent()) {
            itemsRepository.delete(id);
            return ResponseEntity.ok().build();
        }

        return ResponseEntity.status(HttpStatus.NOT_FOUND).build();
    }
}
