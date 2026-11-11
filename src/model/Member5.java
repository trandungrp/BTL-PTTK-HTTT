package model;

import java.util.Date;

/** Thanh vien he thong (lop truu tuong). Khach hang va nhan vien ke thua lop nay. */
public abstract class Member5 {
    public static final String ROLE_CUSTOMER = "CUSTOMER";
    public static final String ROLE_MANAGER = "MANAGER";
    public static final String ROLE_WAREHOUSE = "WAREHOUSE";
    public static final String ROLE_SALES = "SALES";

    protected int id;
    protected String username;
    protected String password;
    protected String fullName;
    protected Date birthday;
    protected String address;
    protected String email;
    protected String phone;
    protected String role;
    protected String note;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public Date getBirthday() { return birthday; }
    public void setBirthday(Date birthday) { this.birthday = birthday; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
}
