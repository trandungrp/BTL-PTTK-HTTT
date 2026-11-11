package model;

/** Mat hang. */
public class Product5 {
    protected int id;
    protected String name;
    protected String brand;
    protected String unit;
    protected double importPrice;
    protected double salePrice;
    protected int quantityInStock;
    protected String description;
    protected String image;

    public Product5() {}

    public Product5(String name, String brand, String unit, double importPrice, double salePrice,
                    int quantityInStock, String description, String image) {
        super();
        this.name = name;
        this.brand = brand;
        this.unit = unit;
        this.importPrice = importPrice;
        this.salePrice = salePrice;
        this.quantityInStock = quantityInStock;
        this.description = description;
        this.image = image;
    }

    public Product5(int id, String name, String brand, String unit, double importPrice, double salePrice,
                    int quantityInStock, String description, String image) {
        this(name, brand, unit, importPrice, salePrice, quantityInStock, description, image);
        this.id = id;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getBrand() { return brand; }
    public void setBrand(String brand) { this.brand = brand; }
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    public double getImportPrice() { return importPrice; }
    public void setImportPrice(double importPrice) { this.importPrice = importPrice; }
    public double getSalePrice() { return salePrice; }
    public void setSalePrice(double salePrice) { this.salePrice = salePrice; }
    public int getQuantityInStock() { return quantityInStock; }
    public void setQuantityInStock(int quantityInStock) { this.quantityInStock = quantityInStock; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getImage() { return image; }
    public void setImage(String image) { this.image = image; }

    /** Ma hien thi, vd MH001. */
    public String getCode() { return String.format("MH%03d", id); }
    public boolean isInStock() { return quantityInStock > 0; }
}
