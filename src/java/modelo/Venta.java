package modelo;
import java.util.Date;

public class Venta {
    private int idVenta;
    private int noFactura;
    private String serie;
    private Date fechaFactura;
    private int idCliente;
    private int idEmpleado;
    private Date fechaRegistro;

    // Getters y setters
    public int getIdVenta() { return idVenta; }
    public void setIdVenta(int idVenta) { this.idVenta = idVenta; }
    public int getNoFactura() { return noFactura; }
    public void setNoFactura(int noFactura) { this.noFactura = noFactura; }
    public String getSerie() { return serie; }
    public void setSerie(String serie) { this.serie = serie; }
    public Date getFechaFactura() { return fechaFactura; }
    public void setFechaFactura(Date fechaFactura) { this.fechaFactura = fechaFactura; }
    public int getIdCliente() { return idCliente; }
    public void setIdCliente(int idCliente) { this.idCliente = idCliente; }
    public int getIdEmpleado() { return idEmpleado; }
    public void setIdEmpleado(int idEmpleado) { this.idEmpleado = idEmpleado; }
    public Date getFechaRegistro() { return fechaRegistro; }
    public void setFechaRegistro(Date fechaRegistro) { this.fechaRegistro = fechaRegistro; }
}
