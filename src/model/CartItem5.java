package model;

/** Mot dong trong gio hang. */
public class CartItem5 {
    protected int id;
    protected int quantity;
    protected Product5 product;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public Product5 getProduct() { return product; }
    public void setProduct(Product5 product) { this.product = product; }

    /** Thanh tien = don gia ban hien tai x so luong. */
    public double getAmount() { return product == null ? 0 : product.getSalePrice() * quantity; }
}
