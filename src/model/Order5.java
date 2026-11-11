package model;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

/** Don dat hang truc tuyen. Composition: chua cac OrderDetail5. */
public class Order5 {
    public static final String PENDING = "PENDING";
    public static final String APPROVED = "APPROVED";
    public static final String COMPLETED = "COMPLETED";
    public static final String REJECTED = "REJECTED";

    protected int id;
    protected Date orderDate;
    protected String deliveryAddress;
    protected String status;
    protected double totalAmount;
    protected Customer5 customer;
    protected WarehouseStaff5 approvedBy;
    protected Shipper5 shipper;
    protected List<OrderDetail5> listDetail = new ArrayList<>();

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public Date getOrderDate() { return orderDate; }
    public void setOrderDate(Date orderDate) { this.orderDate = orderDate; }
    public String getDeliveryAddress() { return deliveryAddress; }
    public void setDeliveryAddress(String deliveryAddress) { this.deliveryAddress = deliveryAddress; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(double totalAmount) { this.totalAmount = totalAmount; }
    public Customer5 getCustomer() { return customer; }
    public void setCustomer(Customer5 customer) { this.customer = customer; }
    public WarehouseStaff5 getApprovedBy() { return approvedBy; }
    public void setApprovedBy(WarehouseStaff5 approvedBy) { this.approvedBy = approvedBy; }
    public Shipper5 getShipper() { return shipper; }
    public void setShipper(Shipper5 shipper) { this.shipper = shipper; }
    public List<OrderDetail5> getListDetail() { return listDetail; }
    public void setListDetail(List<OrderDetail5> listDetail) { this.listDetail = listDetail; }

    /** Ma hien thi, vd DH2026001. */
    public String getCode() {
        Calendar c = Calendar.getInstance();
        if (orderDate != null) c.setTime(orderDate);
        return String.format("DH%d%03d", c.get(Calendar.YEAR), id);
    }

    public String getStatusLabel() { return statusLabel(status); }

    public static String statusLabel(String s) {
        if (s == null) return "";
        switch (s) {
            case PENDING: return "Chờ duyệt";
            case APPROVED: return "Đã duyệt - đã xuất giao";
            case COMPLETED: return "Hoàn thành";
            case REJECTED: return "Từ chối";
            default: return s;
        }
    }

    public double calculateTotal() {
        double t = 0;
        for (OrderDetail5 d : listDetail) t += d.getAmount();
        totalAmount = t;
        return t;
    }
}
