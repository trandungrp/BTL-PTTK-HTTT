package model;

import java.util.ArrayList;
import java.util.List;

/** Loai hang. Aggregation: Category5 chua nhieu Product5. */
public class Category5 {
    protected int id;
    protected String name;
    protected String description;
    protected List<Product5> listProduct = new ArrayList<>();

    public Category5() {}

    public Category5(int id, String name, String description) {
        super();
        this.id = id;
        this.name = name;
        this.description = description;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public List<Product5> getListProduct() { return listProduct; }
    public void setListProduct(List<Product5> listProduct) { this.listProduct = listProduct; }

    /** Loai hang nay co chua mat hang co ma productId khong? */
    public boolean containsProduct(int productId) {
        for (Product5 p : listProduct) if (p.getId() == productId) return true;
        return false;
    }
}
