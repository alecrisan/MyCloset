package server.model;


import javax.persistence.*;

@Entity
@Table(name = "items")
public class ClothingItem {
    @Id
    private int id;

    @Column
    private String name;

    @Column
    private String description;

    @Column
    private String photo;

    @Column
    private String size;

    @Column
    private int price;

    public ClothingItem() {}

    public ClothingItem(String name, String description, String imageName, String size, int price) {
        this.name = name;
        this.description = description;
        this.photo = imageName;
        this.size = size;
        this.price = price;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getPhoto() {
        return photo;
    }

    public void setPhoto(String photo) {
        this.photo = photo;
    }

    public String getSize() {
        return size;
    }

    public void setSize(String size) {
        this.size = size;
    }

    public int getPrice() {
        return price;
    }

    public void setPrice(int price) {
        this.price = price;
    }

    @Override
    public String toString() {
        return "ClothingItem{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", description='" + description + '\'' +
                ", photo=" + photo +
                ", size=" + size +
                ", price=" + price +
                '}';
    }
}
