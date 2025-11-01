package modelo;

public class ProductoReporte {
    private String nombre;
    private int cantidad;
    private double total;

    public ProductoReporte() {}

    public ProductoReporte(String nombre, int cantidad, double total) {
        this.nombre = nombre;
        this.cantidad = cantidad;
        this.total = total;
    }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public int getCantidad() { return cantidad; }
    public void setCantidad(int cantidad) { this.cantidad = cantidad; }

    public double getTotal() { return total; }
    public void setTotal(double total) { this.total = total; }
}
