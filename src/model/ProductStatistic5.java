package model;

/** Thong ke mat hang: nhap - ban - ton (du lieu dan xuat, khong luu bang rieng). */
public class ProductStatistic5 extends Product5 {
    protected int importedQuantity;
    protected int soldQuantity;
    protected int remainQuantity;

    public int getImportedQuantity() { return importedQuantity; }
    public void setImportedQuantity(int importedQuantity) { this.importedQuantity = importedQuantity; }
    public int getSoldQuantity() { return soldQuantity; }
    public void setSoldQuantity(int soldQuantity) { this.soldQuantity = soldQuantity; }
    public int getRemainQuantity() { return remainQuantity; }
    public void setRemainQuantity(int remainQuantity) { this.remainQuantity = remainQuantity; }
}
