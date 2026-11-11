package model;

/** Nha cung cap. */
public class Supplier5 {
    protected int id;
    protected String name;
    protected String address;
    protected String phone;
    protected String email;
    protected String contactPerson;

    public Supplier5() {}

    public Supplier5(String name, String address, String phone, String email, String contactPerson) {
        super();
        this.name = name;
        this.address = address;
        this.phone = phone;
        this.email = email;
        this.contactPerson = contactPerson;
    }

    public Supplier5(int id, String name, String address, String phone, String email, String contactPerson) {
        this(name, address, phone, email, contactPerson);
        this.id = id;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getContactPerson() { return contactPerson; }
    public void setContactPerson(String contactPerson) { this.contactPerson = contactPerson; }

    public String getCode() { return String.format("NCC%03d", id); }
}
