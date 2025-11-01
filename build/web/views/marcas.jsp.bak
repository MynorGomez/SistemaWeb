<%@ include file="../WEB-INF/jwtFilter.jsp" %>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@page import="modelo.Marca" %>
<%@page import="java.util.HashMap" %>
<%@page import="javax.swing.table.DefaultTableModel" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Marcas</title>
        <link rel="stylesheet" href="../assets/css/bootstrap.min.css">
        <link rel="stylesheet" href="../assets/css/style.css">
    </head>
    <body>
        <jsp:include page="../includes/menu.jsp"></jsp:include>
            <div class="container">
                <div class="row justify-content-center">
                    <div class="col-lg-8 mt-5">
                        <div class="card">
                            <div class="card-body">
                                <h1 class="text-center">Formulario de Marcas</h1>
                                <form action="../sr_marca" method="post" class="form-group">
                                    <label for="id_marca">ID:</label>
                                    <input type="number" name="id_marca" id="id_marca" class="form-control" readonly>
                                    <label for="txt_marca">Marca:</label>
                                    <input type="text" name="txt_marca" id="txt_marca" class="form-control" required>
                                    <br>
                                    <div class="text-center">
                                        <button name="btn" value="Agregar" class="btn btn-primary">Agregar</button>
                                        <button name="btn" value="Actualizar" class="btn btn-success">Actualizar</button>
                                        <button name="btn" value="Eliminar" class="btn btn-danger">Eliminar</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                        <div class="card mt-4">
                            <div class="card-body">
                                <h2 class="text-center">Lista de Marcas</h2>
                                <table class="table table-striped table-hover">
                                    <thead>
                                        <tr>
                                            <th>ID</th>
                                            <th>Marca</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                            Marca marca = new Marca();
                                            DefaultTableModel tabla = marca.leer();
                                            if(tabla != null) {
                                                for(int t=0; t < tabla.getRowCount(); t++) {
                                                    out.println("<tr>");
                                                    out.println("<td>" + tabla.getValueAt(t, 0) + "</td>");
                                                    out.println("<td>" + tabla.getValueAt(t, 1) + "</td>");
                                                    out.println("</tr>");
                                                }
                                            }
                                        %>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        <script src="../assets/js/jquery.min.js"></script>
        <script src="../assets/js/bootstrap.bundle.min.js"></script>
        <script>
            $(document).ready(function() {
                // Manejar el clic en una fila de la tabla
                $('tbody tr').click(function() {
                    $('#id_marca').val($(this).find('td:eq(0)').text());
                    $('#txt_marca').val($(this).find('td:eq(1)').text());
                });
            });
        </script>
    </body>
</html>