package model;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/** Gio hang cua khach hang (du lieu tam truoc khi submit don). */
public class Cart5 {
    protected int id;
    protected Date createdDate;
    protected Customer5 customer;
    protected List<CartItem5> listItem = new ArrayList<>();

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public Date getCreatedDate() { return createdDate; }
    public void setCreatedDate(Date createdDate) { this.createdDate = createdDate; }
    public Customer5 getCustomer() { return customer; }
    public void setCustomer(Customer5 customer) { this.customer = customer; }
    public List<CartItem5> getListItem() { return listItem; }
    public void setListItem(List<CartItem5> listItem) { this.listItem = listItem; }

    /** Khong truy xuat CSDL nen giu o lop thuc the: tong tien = tong(don gia x so luong). */
    public double calculateTotal() {
        double t = 0;
        for (CartItem5 i : listItem) t += i.getAmount();
        return t;
    }
}
