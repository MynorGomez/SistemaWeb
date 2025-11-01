<%@ page import="java.util.*, modelo.Menu" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ include file="../WEB-INF/jwtFilter.jsp" %>

<%
    Menu menuObj = new Menu();
    List<Menu> listaMenus = menuObj.leer();

    // Agrupar por id_padre
    Map<Integer, List<Menu>> mapa = new HashMap<>();
    for (Menu item : listaMenus) {
        mapa.computeIfAbsent(item.getId_padre(), k -> new ArrayList<>()).add(item);
    }

    String context = request.getContextPath();
    String uri = request.getRequestURI();

    // 🧠 Detectar si el nombre es femenino
    String nombreLog = (String) request.getAttribute("nombreLog");
    String saludo = "Bienvenido";
    if (nombreLog != null) {
        String nombreMin = nombreLog.toLowerCase(Locale.ROOT);
        // Lista simple de nombres o terminaciones comunes femeninas
        if (nombreMin.endsWith("a") || nombreMin.endsWith("ia") ||
            nombreMin.contains("maría") || nombreMin.contains("ana") ||
            nombreMin.contains("sofia") || nombreMin.contains("elena") ||
            nombreMin.contains("paula") || nombreMin.contains("carla") ||
            nombreMin.contains("isabel") || nombreMin.contains("rosa")) {
            saludo = "Bienvenida";
        }
    }
%>

<%!
boolean isChildActive(Menu item, String uri, Map<Integer, List<Menu>> mapa) {
    if (item.getUrl() != null && uri.contains(item.getUrl())) {
        return true;
    }
    List<Menu> hijos = mapa.get(item.getId_menu());
    if (hijos != null) {
        for (Menu h : hijos) {
            if (isChildActive(h, uri, mapa)) return true;
        }
    }
    return false;
}

void renderMenu(List<Menu> menus, Map<Integer, List<Menu>> mapa,
                JspWriter out, String context, String uri, int nivel) throws java.io.IOException {

    for (Menu item : menus) {
        List<Menu> hijos = mapa.get(item.getId_menu());
        String collapseId = "menu" + item.getId_menu();

        boolean activo = (item.getUrl() != null && uri.contains(item.getUrl()));
        boolean hijoActivo = isChildActive(item, uri, mapa);

        if (hijos != null && !hijos.isEmpty()) {
            String padreUrl = (item.getUrl() != null) ? (context + "/" + item.getUrl()) : "#";

            out.println("<li class='nav-item'>");
            out.println("<div class='d-flex justify-content-between align-items-center " +
                        ((activo || hijoActivo) ? "active-parent" : "") + "'>");
            out.println("<a href='" + padreUrl + "' class='nav-link menu-level-" + nivel + "'>");
            out.println("<i class='bi bi-folder-fill me-2 folder-icon'></i>" + item.getNombre() + "</a>");
            out.println("<button class='btn btn-sm toggle-btn text-light' data-bs-toggle='collapse' data-bs-target='#" + collapseId + "'>");
            out.println("<i class='bi bi-chevron-down'></i></button>");
            out.println("</div>");
            out.println("<ul class='collapse animated-collapse list-unstyled ms-3 " + ((activo || hijoActivo) ? "show" : "") + "' id='" + collapseId + "'>");
            renderMenu(hijos, mapa, out, context, uri, nivel + 1);
            out.println("</ul>");
            out.println("</li>");
        } else {
            String url = (item.getUrl() != null) ? (context + "/" + item.getUrl()) : "#";
            out.println("<li>");
            out.println("<a href='" + url + "' class='nav-link menu-level-" + nivel +
                        (activo ? " active-link" : "") + "'>");
            out.println("<i class='bi bi-dot text-light'></i> " + item.getNombre() + "</a>");
            out.println("</li>");
        }
    }
}
%>

<div class="sidebar bg-dark text-light p-3">
    <!-- 👤 Usuario logueado -->
    <div class="user-info text-center mb-4">
        <h5 class="mt-2 mb-1"><%= saludo %></h5>
        <span class="fw-bold text-light d-block"><%= nombreLog %></span>
    </div>

    <ul class="nav flex-column">
        <%
            List<Menu> raiz = mapa.get(null);
            if (raiz != null) renderMenu(raiz, mapa, out, context, uri, 1);
        %>
    </ul>
    <hr class="text-secondary">
    <a href="<%= context %>/sr_logout" class="nav-link text-danger fw-bold mt-2">
        <i class="bi bi-box-arrow-right"></i> Cerrar sesión
    </a>
</div>

<div class="main-content">

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<style>
:root {
    --bs-link-color: #e9ecef !important;
    --bs-link-hover-color: #ffffff !important;
}
body {
    background-color: #f8f9fa;
    overflow-x: hidden;
}
.sidebar {
    width: 225px;
    height: 100vh;
    position: fixed;
    left: 0;
    top: 0;
    background-color: #212529;
    color: white;
    overflow-y: auto;
    box-shadow: 2px 0 5px rgba(0,0,0,0.3);
    z-index: 1000;
}
.main-content {
    margin-left: 150px;
    padding: 5px 10px;
}


/* Usuario */
.user-info {
    background-color: rgba(255, 255, 255, 0.05);
    padding: 10px;
    border-radius: 10px;
    box-shadow: inset 0 0 6px rgba(255,255,255,0.1);
}
.user-info i {
    filter: drop-shadow(0 0 4px #f0c674);
}
.user-info span {
    color: #f8f9fa;
}

/* Links */
a, a:hover, a:focus, a:active {
    color: #e9ecef !important;
    text-decoration: none !important;
    outline: none !important;
    box-shadow: none !important;
}
.nav-link {
    display: block;
    padding: 6px 10px;
    border-radius: 6px;
    color: #e9ecef !important;
    transition: all 0.2s ease;
}
.nav-link:hover {
    background-color: #343a40;
    color: #fff !important;
}
.nav-link.active-link {
    background-color: #3d4349 !important;
    color: #fff !important;
}

/* Activo padre */
.active-parent {
    background-color: #343a40 !important;
    border-radius: 6px;
}

/* Carpetas */
.folder-icon {
    color: #f0c674 !important;
}
.folder-icon:hover {
    color: #ffd166 !important;
}

/* Botones */
.toggle-btn {
    background: transparent;
    border: none;
    cursor: pointer;
    padding: 2px;
    color: #e9ecef;
}
.toggle-btn:hover { color: #fff; }
.toggle-btn i { transition: transform 0.3s ease; }
.rotate i { transform: rotate(180deg); }

/* Scroll */
.sidebar::-webkit-scrollbar { width: 6px; }
.sidebar::-webkit-scrollbar-thumb { background-color: #6c757d; border-radius: 10px; }

.sidebar hr { border-color: #444; margin: 10px 0; }
.sidebar .text-danger:hover { color: #ff6b6b !important; }

/* Animación suave */
.animated-collapse {
    transition: height 0.35s ease, opacity 0.35s ease;
    overflow: hidden;
}
.collapse:not(.show) { opacity: 0; }
.collapse.show { opacity: 1; }
</style>

<script>
document.addEventListener("DOMContentLoaded", () => {
    document.querySelectorAll('.collapse').forEach(el => {
        bootstrap.Collapse.getOrCreateInstance(el, { toggle: false });
    });

    document.querySelectorAll('.toggle-btn').forEach(btn => {
        btn.addEventListener('click', e => {
            e.stopPropagation();

            const current = e.currentTarget;
            const targetSelector = current.dataset.bsTarget;
            if (!targetSelector) return;
            const target = document.querySelector(targetSelector);
            if (!target) return;

            const collapseInstance = bootstrap.Collapse.getOrCreateInstance(target, { toggle: false });

            if (target.classList.contains("show")) {
                collapseInstance.hide();
                current.classList.remove("rotate");
            } else {
                const siblings = current.closest('ul').querySelectorAll('.collapse.show');
                siblings.forEach(sib => {
                    if (sib !== target) {
                        const sibInstance = bootstrap.Collapse.getOrCreateInstance(sib, { toggle: false });
                        sibInstance.hide();
                        const sibBtn = sib.closest('li')?.querySelector('.toggle-btn');
                        if (sibBtn) sibBtn.classList.remove('rotate');
                    }
                });
                collapseInstance.show();
                current.classList.add("rotate");
            }
        });
    });
});
</script>
