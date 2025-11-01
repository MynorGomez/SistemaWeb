<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>

<%@ include file="../WEB-INF/jwtFilter.jsp" %>
<%@ include file="../includes/menu.jsp" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Reporte de Ventas</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            background-color: #f8f9fa;
        }

        /* 🔹 Mantiene el contenido separado del menú lateral */
        .main-content {
            margin-left: 110px; /* debe coincidir con el ancho del sidebar */
            padding: 30px;
            min-height: 100vh;
            background-color: #f8f9fa;
        }

        .card {
            border-radius: 10px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
            border: none;
        }

        .btn {
            border-radius: 6px;
        }
    </style>
</head>

<body>

<div class="main-content">

    <!-- 🔹 Barra superior -->
    <div class="d-flex justify-content-between mb-4">
        <a href="<%= request.getContextPath() %>/index.jsp" class="btn btn-secondary">
            🏠 Volver al Menú Principal
        </a>
        <a href="<%= request.getContextPath() %>/ReporteVentasPDF" target="_blank" class="btn btn-danger">
            📄 Exportar a PDF
        </a>
    </div>

    <h2 class="text-center mb-4">📊 Reporte de Ventas</h2>

    <!-- 🔹 Tabla de ventas -->
    <div class="card p-3 mb-4">
        <table class="table table-bordered table-striped shadow-sm mb-0">
            <thead class="table-dark text-center">
                <tr>
                    <th>ID Venta</th>
                    <th>No. Factura</th>
                    <th>Serie</th>
                    <th>Fecha Venta</th>
                    <th>Cliente</th>
                    <th>Total (Q)</th>
                </tr>
            </thead>
            <tbody>
            <%
                List<Map<String, Object>> ventas = (List<Map<String, Object>>) request.getAttribute("ventas");
                if (ventas != null && !ventas.isEmpty()) {
                    for (Map<String, Object> v : ventas) {
            %>
                <tr>
                    <td><%= v.get("id_venta") %></td>
                    <td><%= v.get("no_factura") %></td>
                    <td><%= v.get("serie") %></td>
                    <td><%= v.get("fecha_venta") %></td>
                    <td><%= v.get("cliente") %></td>
                    <td class="text-end">Q <%= String.format("%.2f", v.get("total")) %></td>
                </tr>
            <%
                    }
                } else {
            %>
                <tr><td colspan="6" class="text-center text-muted">No hay registros</td></tr>
            <%
                }
            %>
            </tbody>
        </table>
    </div>

    <!-- 🔹 Mensaje opcional -->
    <%
        String alerta = (String) request.getAttribute("alerta");
        if (alerta != null) {
    %>
        <div class="alert alert-info text-center mt-3" style="font-size: 16px;">
            <%= alerta %>
        </div>
    <%
        }
    %>

    <!-- 🔹 Gráfico de ventas -->
    <div class="card p-4 mt-4">
        <canvas id="graficoVentas" width="900" height="400"></canvas>
    </div>

</div> <!-- cierre de .main-content -->

<script>
const ctx = document.getElementById('graficoVentas').getContext('2d');
const datos = [
    <% if (ventas != null) {
           for (Map<String, Object> v : ventas) { %>
               { cliente: "<%= v.get("cliente") %>", total: <%= v.get("total") %> },
    <%     }
       } %>
];

const clientes = datos.map(d => d.cliente);
const totales = datos.map(d => d.total);

new Chart(ctx, {
    type: 'bar',
    data: {
        labels: clientes,
        datasets: [{
            label: 'Total de Ventas (Q)',
            data: totales,
            backgroundColor: 'rgba(54, 162, 235, 0.8)',
            borderRadius: 6,
            barThickness: 30
        }]
    },
    options: {
        responsive: true,
        plugins: {
            legend: { display: false },
            title: { display: true, text: 'Ventas por Cliente', font: { size: 18 } }
        },
        scales: { y: { beginAtZero: true } }
    }
});
</script>

</body>
</html>
