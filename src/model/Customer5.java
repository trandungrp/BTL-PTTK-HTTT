package model;

import java.util.Date;

/** Khach hang (thanh vien dang ki). */
public class Customer5 extends Member5 {
    protected Date registerDate;

    public Customer5() { setRole(ROLE_CUSTOMER); }

    public Date getRegisterDate() { return registerDate; }
    public void setRegisterDate(Date registerDate) { this.registerDate = registerDate; }
}
