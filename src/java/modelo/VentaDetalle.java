package modelo;

public class VentaDetalle {
    private int idVentaDetalle;
    private int idVenta;
    private int idProducto;
    private int cantidad;
    private double precioUnitario;

    // Getters y Setters
    public int getIdVentaDetalle() { return idVentaDetalle; }
    public void setIdVentaDetalle(int idVentaDetalle) { this.idVentaDetalle = idVentaDetalle; }
    public int getIdVenta() { return idVenta; }
    public void setIdVenta(int idVenta) { this.idVenta = idVenta; }
    public int getIdProducto() { return idProducto; }
    public void setIdProducto(int idProducto) { this.idProducto = idProducto; }
    public int getCantidad() { return cantidad; }
    public void setCantidad(int cantidad) { this.cantidad = cantidad; }
    public double getPrecioUnitario() { return precioUnitario; }
    public void setPrecioUnitario(double precioUnitario) { this.precioUnitario = precioUnitario; }
}
