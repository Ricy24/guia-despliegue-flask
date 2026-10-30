// Renderiza los diagramas Mermaid de los capítulos.
// Usa el modo oscuro de MkDocs Material si está activo.
const theme = document.body.getAttribute("data-md-color-scheme") === "slate" ? "dark" : "neutral";
mermaid.initialize({ startOnLoad: true, theme, securityLevel: "loose" });
