package model;

/** Nhan vien giao hang (khong dang nhap he thong, nen khong ke thua Member5). */
public class Shipper5 {
    protected int id;
    protected String fullName;
    protected String phone;

    public Shipper5() {}

    public Shipper5(int id, String fullName, String phone) {
        super();
        this.id = id;
        this.fullName = fullName;
        this.phone = phone;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
}
