package model;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

/** Hoa don ban tai quay. Composition: chua cac InvoiceDetail5. */
public class Invoice5 {
    protected int id;
    protected Date saleDate;
    protected double totalAmount;
    protected Salesperson5 salesperson;
    protected Customer5 customer; // null voi khach vang lai
    protected List<InvoiceDetail5> listDetail = new ArrayList<>();

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public Date getSaleDate() { return saleDate; }
    public void setSaleDate(Date saleDate) { this.saleDate = saleDate; }
    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }
    public Salesperson5 getSalesperson() { return salesperson; }
    public void setSalesperson(Salesperson5 salesperson) { this.salesperson = salesperson; }
    public Customer5 getCustomer() { return customer; }
    public void setCustomer(Customer5 customer) { this.customer = customer; }
    public List<InvoiceDetail5> getListDetail() { return listDetail; }
    public void setListDetail(List<InvoiceDetail5> listDetail) { this.listDetail = listDetail; }

    public String getCode() {
        Calendar c = Calendar.getInstance();
        if (saleDate != null) c.setTime(saleDate);
        return String.format("HD%d%03d", c.get(Calendar.YEAR), id);
    }

    public double calculateTotal() {
        double t = 0;
        for (InvoiceDetail5 d : listDetail) t += d.getAmount();
        totalAmount = t;
        return t;
    }
}
