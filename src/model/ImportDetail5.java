package model;

/** Chi tiet phieu nhap. */
public class ImportDetail5 {
    protected int id;
    protected int quantity;
    protected double unitPrice;
    protected Product5 product;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(double unitPrice) { this.unitPrice = unitPrice; }
    public Product5 getProduct() { return product; }
    public void setProduct(Product5 product) { this.product = product; }

    public double getAmount() { return quantity * unitPrice; }
}
