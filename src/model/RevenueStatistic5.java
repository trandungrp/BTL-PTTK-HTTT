package model;

import java.util.ArrayList;
import java.util.List;

/**
 * Thong ke doanh thu theo ki. Java khong da ke thua nen lop nay chua danh sach
 * Invoice5 va Order5 trong ki (dung khi click xem chi tiet mot ki).
 */
public class RevenueStatistic5 {
    protected String period;
    protected int invoiceCount;
    protected int orderCount;
    protected double revenue;
    protected List<Invoice5> listInvoice = new ArrayList<>();
    protected List<Order5> listOrder = new ArrayList<>();

    public String getPeriod() { return period; }
    public void setPeriod(String period) { this.period = period; }
    public int getInvoiceCount() { return invoiceCount; }
    public void setInvoiceCount(int invoiceCount) { this.invoiceCount = invoiceCount; }
    public int getOrderCount() { return orderCount; }
    public void setOrderCount(int orderCount) { this.orderCount = orderCount; }
    public double getRevenue() { return revenue; }
    public void setRevenue(double revenue) { this.revenue = revenue; }
    public List<Invoice5> getListInvoice() { return listInvoice; }
    public void setListInvoice(List<Invoice5> listInvoice) { this.listInvoice = listInvoice; }
    public List<Order5> getListOrder() { return listOrder; }
    public void setListOrder(List<Order5> listOrder) { this.listOrder = listOrder; }
}
