<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Detecta la página actual
    String currentPage = request.getRequestURI();
    String context = request.getContextPath(); // Ej: /Sistema
%>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">

<style>
/* --- Sidebar general --- */
.sidebar {
    height: 100vh;
    width: 250px;
    position: fixed;
    background: #212529;
    color: white;
    padding-top: 20px;
    transition: all 0.3s;
}

.sidebar a {
    color: #adb5bd;
    text-decoration: none;
    display: block;
    padding: 12px 20px;
    font-weight: 500;
    transition: 0.2s;
}

.sidebar a:hover {
    background-color: #495057;
    color: #fff;
    border-left: 4px solid #0d6efd;
}

.sidebar .active {
    background-color: #0d6efd;
    color: white;
    font-weight: 600;
    border-left: 4px solid #fff;
}

.sidebar h4 {
    text-align: center;
    margin-bottom: 20px;
    font-weight: 600;
    color: #f8f9fa;
}

.sidebar hr {
    border-color: #444;
    margin: 15px 0;
}

/* --- Contenido principal --- */
.main-content {
    margin-left: 250px;
    padding: 30px;
    background-color: #f8f9fa;
    min-height: 100vh;
}

/* --- Header superior opcional --- */
.navbar-custom {
    background-color: #0d6efd;
    color: white;
}
</style>

<div class="sidebar">
    

    <a href="<%= context %>/index.jsp" class="<%= currentPage.contains("index.jsp") ? "active" : "" %>">
        <i class="bi bi-house-door"></i> Inicio
    </a>

    <a href="<%= context %>/views/empleados.jsp" class="<%= currentPage.contains("empleados.jsp") ? "active" : "" %>">
        <i class="bi bi-person-badge"></i> Empleados
    </a>

    <a href="<%= context %>/views/puestos.jsp" class="<%= currentPage.contains("puestos.jsp") ? "active" : "" %>">
        <i class="bi bi-people"></i> Puestos
    </a>

    <a href="<%= context %>/views/clientes.jsp" class="<%= currentPage.contains("clientes.jsp") ? "active" : "" %>">
        <i class="bi bi-people"></i> Clientes
    </a>

    <a href="<%= context %>/views/proveedores.jsp" class="<%= currentPage.contains("proveedores.jsp") ? "active" : "" %>">
        <i class="bi bi-truck"></i> Proveedores
    </a>

    <a href="<%= context %>/views/productos.jsp" class="<%= currentPage.contains("productos.jsp") ? "active" : "" %>">
        <i class="bi bi-box-seam"></i> Productos
    </a>

    <a href="<%= context %>/views/compras.jsp" class="<%= currentPage.contains("compras.jsp") ? "active" : "" %>">
        <i class="bi bi-cart4"></i> Compras
    </a>

    <!-- ✅ Aquí corregido: llama al servlet sr_venta -->
    <a href="<%= context %>/views/ventas.jsp" class="<%= currentPage.contains("ventas.jsp") ? "active" : "" %>">
        <i class="bi bi-cash-stack"></i> Ventas
    </a>

<a href="<%= context %>/ReporteServlet" class="<%= currentPage.contains("reportes.jsp") ? "active" : "" %>">
    <i class="bi bi-graph-up"></i> Reportes
</a>
    <a href="<%= context %>/ReporteProductosServlet?tipo=venta" class="<%= currentPage.contains("reporteProductos.jsp") ? "active" : "" %>">
    <i class="bi bi-graph-up-arrow"></i> Productos más vendidos
</a>



    <hr class="text-secondary">
    <a href="<%= context %>/sr_logout" class="text-danger">
        <i class="bi bi-box-arrow-right"></i> Cerrar sesión
    </a>
</div>
