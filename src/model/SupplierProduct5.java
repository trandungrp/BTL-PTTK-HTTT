package model;

/** Mat hang do mot nha cung cap cung cap (lop trung gian Supplier5 - Product5). */
public class SupplierProduct5 {
    protected int id;
    protected double supplyPrice;
    protected Supplier5 supplier;
    protected Product5 product;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public double getSupplyPrice() { return supplyPrice; }
    public void setSupplyPrice(double supplyPrice) { this.supplyPrice = supplyPrice; }
    public Supplier5 getSupplier() { return supplier; }
    public void setSupplier(Supplier5 supplier) { this.supplier = supplier; }
    public Product5 getProduct() { return product; }
    public void setProduct(Product5 product) { this.product = product; }
}
