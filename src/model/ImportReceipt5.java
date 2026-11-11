package model;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/** Phieu nhap hang. Composition: chua cac ImportDetail5. */
public class ImportReceipt5 {
    protected int id;
    protected Date importDate;
    protected double totalAmount;
    protected Supplier5 supplier;
    protected WarehouseStaff5 warehouseStaff;
    protected List<ImportDetail5> listDetail = new ArrayList<>();

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public Date getImportDate() { return importDate; }
    public void setImportDate(Date importDate) { this.importDate = importDate; }
    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }
    public Supplier5 getSupplier() { return supplier; }
    public void setSupplier(Supplier5 supplier) { this.supplier = supplier; }
    public WarehouseStaff5 getWarehouseStaff() { return warehouseStaff; }
    public void setWarehouseStaff(WarehouseStaff5 warehouseStaff) { this.warehouseStaff = warehouseStaff; }
    public List<ImportDetail5> getListDetail() { return listDetail; }
    public void setListDetail(List<ImportDetail5> listDetail) { this.listDetail = listDetail; }

    public String getCode() { return String.format("PN%03d", id); }

    /** Tong tien = tong(so luong x don gia nhap). */
    public double calculateTotal() {
        double t = 0;
        for (ImportDetail5 d : listDetail) t += d.getAmount();
        totalAmount = t;
        return t;
    }
}
