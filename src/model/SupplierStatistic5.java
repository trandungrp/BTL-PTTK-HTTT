package model;

/** Thong ke nha cung cap: so phieu nhap va tong gia tri nhap. */
public class SupplierStatistic5 extends Supplier5 {
    protected int receiptCount;
    protected double totalImportValue;

    public int getReceiptCount() { return receiptCount; }
    public void setReceiptCount(int receiptCount) { this.receiptCount = receiptCount; }
    public double getTotalImportValue() { return totalImportValue; }
    public void setTotalImportValue(double totalImportValue) { this.totalImportValue = totalImportValue; }
}
