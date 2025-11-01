<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../WEB-INF/jwtFilter.jsp" %>
<%@ page import="java.sql.*" %>
<%@ page import="utils.ConexionDB" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Panel Principal</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
</head>
<body>

<!-- ✅ Incluir menú lateral -->
<%@ include file="../includes/menu.jsp" %>

<div class="main-content">
    <div class="container-fluid">
        <h2 class="mb-4"><i class="bi bi-speedometer2"></i> Panel Principal</h2>

        <div class="row g-4">
            <%
                // Crear conexión a MySQL
                ConexionDB con = new ConexionDB();
                Connection cn = con.getConexion();

                int totalClientes = 0, totalEmpleados = 0, totalVentas = 0, totalCompras = 0;

                try {
                    Statement st = cn.createStatement();

                    ResultSet rs1 = st.executeQuery("SELECT COUNT(*) FROM clientes");
                    if (rs1.next()) totalClientes = rs1.getInt(1);

                    ResultSet rs2 = st.executeQuery("SELECT COUNT(*) FROM empleados");
                    if (rs2.next()) totalEmpleados = rs2.getInt(1);

                    ResultSet rs3 = st.executeQuery("SELECT COUNT(*) FROM ventas");
                    if (rs3.next()) totalVentas = rs3.getInt(1);

                    ResultSet rs4 = st.executeQuery("SELECT COUNT(*) FROM compras");
                    if (rs4.next()) totalCompras = rs4.getInt(1);

                    cn.close();
                } catch (Exception e) {
                    out.print("<div class='alert alert-danger'>❌ Error al conectar a la base de datos: " + e.getMessage() + "</div>");
                }
            %>

            <!-- 🧍 Empleados -->
            <div class="col-md-3">
                <div class="card shadow border-0">
                    <div class="card-body text-center">
                        <i class="bi bi-person-badge display-5 text-primary"></i>
                        <h5 class="mt-2">Empleados</h5>
                        <h3><%= totalEmpleados %></h3>
                        <a href="views/empleados.jsp" class="btn btn-outline-primary btn-sm mt-2">Ver más</a>
                    </div>
                </div>
            </div>

            <!-- 👥 Clientes -->
            <div class="col-md-3">
                <div class="card shadow border-0">
                    <div class="card-body text-center">
                        <i class="bi bi-people display-5 text-success"></i>
                        <h5 class="mt-2">Clientes</h5>
                        <h3><%= totalClientes %></h3>
                        <a href="views/clientes.jsp" class="btn btn-outline-success btn-sm mt-2">Ver más</a>
                    </div>
                </div>
            </div>

            <!-- 🛒 Ventas -->
            <div class="col-md-3">
                <div class="card shadow border-0">
                    <div class="card-body text-center">
                        <i class="bi bi-cash-stack display-5 text-warning"></i>
                        <h5 class="mt-2">Ventas</h5>
                        <h3><%= totalVentas %></h3>
                        <a href="views/ventas.jsp" class="btn btn-outline-warning btn-sm mt-2">Ver más</a>
                    </div>
                </div>
            </div>

            <!-- 📦 Compras -->
            <div class="col-md-3">
                <div class="card shadow border-0">
                    <div class="card-body text-center">
                        <i class="bi bi-cart4 display-5 text-danger"></i>
                        <h5 class="mt-2">Compras</h5>
                        <h3><%= totalCompras %></h3>
                        <a href="views/compras.jsp" class="btn btn-outline-danger btn-sm mt-2">Ver más</a>
                    </div>
                </div>
            </div>
        </div>

       

    </div>
</div>

</body>
</html>
