package server.repository;

import server.model.ClothingItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ClothingItemRepository extends JpaRepository<ClothingItem, Integer> {
    Optional<ClothingItem> findById(int id);
}
