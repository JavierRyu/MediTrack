package com.meditrack.controller;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;
import com.meditrack.dao.RecetaDAO;
import com.meditrack.model.Receta;
import com.meditrack.model.Usuario;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.OutputStream;
import java.time.format.DateTimeFormatter;

@WebServlet("/recetas/descargar-pdf")
public class RecetaPDFServlet extends HttpServlet {
    private RecetaDAO recetaDAO;

    @Override
    public void init() throws ServletException {
        recetaDAO = new RecetaDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Usuario usuario = (Usuario) session.getAttribute("usuario");
        String recetaIdStr = request.getParameter("id");

        if (recetaIdStr == null || recetaIdStr.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard-paciente.jsp?error=receta_no_especificada");
            return;
        }

        try {
            Long recetaId = Long.parseLong(recetaIdStr);
            Receta receta = recetaDAO.findById(recetaId);

            if (receta == null) {
                response.sendRedirect(request.getContextPath() + "/views/dashboard-paciente.jsp?error=receta_no_encontrada");
                return;
            }

            // Verificar permisos: solo el paciente dueño de la receta o el médico que la creó pueden descargarla
            boolean tienePermiso = false;
            if ("PACIENTE".equals(usuario.getTipoUsuario()) && receta.getPacienteId().equals(usuario.getId())) {
                tienePermiso = true;
            } else if ("MEDICO".equals(usuario.getTipoUsuario()) && receta.getMedicoId().equals(usuario.getId())) {
                tienePermiso = true;
            }

            if (!tienePermiso) {
                response.sendRedirect(request.getContextPath() + "/views/dashboard.jsp?error=sin_permiso");
                return;
            }

            // Generar el PDF
            generarPDF(response, receta);

        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/views/dashboard-paciente.jsp?error=id_invalido");
        } catch (DocumentException e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/views/dashboard-paciente.jsp?error=error_generar_pdf");
        }
    }

    private void generarPDF(HttpServletResponse response, Receta receta) throws DocumentException, IOException {
        // Configurar la respuesta HTTP para PDF
        response.setContentType("application/pdf");
        response.setHeader("Content-Disposition",
            "attachment; filename=receta_medica_" + receta.getId() + ".pdf");

        // Crear el documento PDF
        Document document = new Document(PageSize.A4);
        OutputStream out = response.getOutputStream();
        PdfWriter writer = PdfWriter.getInstance(document, out);

        document.open();

        // Definir fuentes
        Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 20, BaseColor.DARK_GRAY);
        Font headerFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14, BaseColor.BLACK);
        Font labelFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11, BaseColor.DARK_GRAY);
        Font normalFont = FontFactory.getFont(FontFactory.HELVETICA, 11, BaseColor.BLACK);
        Font smallFont = FontFactory.getFont(FontFactory.HELVETICA, 9, BaseColor.GRAY);

        // Agregar logo/header (simulado con texto)
        Paragraph header = new Paragraph("MediTrack", titleFont);
        header.setAlignment(Element.ALIGN_CENTER);
        header.setSpacingAfter(5);
        document.add(header);

        Paragraph subtitle = new Paragraph("Sistema de Gestión Médica", smallFont);
        subtitle.setAlignment(Element.ALIGN_CENTER);
        subtitle.setSpacingAfter(20);
        document.add(subtitle);

        // Línea separadora
        Paragraph line = new Paragraph("_________________________________________________________________");
        line.setAlignment(Element.ALIGN_CENTER);
        line.setSpacingAfter(10);
        document.add(line);
        document.add(Chunk.NEWLINE);

        // Título de la receta
        Paragraph title = new Paragraph("RECETA MÉDICA", headerFont);
        title.setAlignment(Element.ALIGN_CENTER);
        title.setSpacingAfter(20);
        document.add(title);

        // Información del médico
        PdfPTable medicoTable = new PdfPTable(2);
        medicoTable.setWidthPercentage(100);
        medicoTable.setSpacingAfter(15);
        medicoTable.setWidths(new float[]{1, 2});

        addCellToTable(medicoTable, "Médico:", labelFont, true);
        addCellToTable(medicoTable, "Dr(a). " + receta.getMedicoNombre(), normalFont, false);

        addCellToTable(medicoTable, "Fecha de emisión:", labelFont, true);
        addCellToTable(medicoTable, receta.getFechaEmision().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")), normalFont, false);

        addCellToTable(medicoTable, "N° Receta:", labelFont, true);
        addCellToTable(medicoTable, String.format("%06d", receta.getId()), normalFont, false);

        document.add(medicoTable);

        // Información del paciente
        Paragraph pacienteHeader = new Paragraph("DATOS DEL PACIENTE", labelFont);
        pacienteHeader.setSpacingBefore(10);
        pacienteHeader.setSpacingAfter(10);
        document.add(pacienteHeader);

        PdfPTable pacienteTable = new PdfPTable(2);
        pacienteTable.setWidthPercentage(100);
        pacienteTable.setSpacingAfter(15);
        pacienteTable.setWidths(new float[]{1, 2});

        addCellToTable(pacienteTable, "Paciente:", labelFont, true);
        addCellToTable(pacienteTable, receta.getPacienteNombre(), normalFont, false);

        document.add(pacienteTable);

        // Diagnóstico (si existe)
        if (receta.getDiagnostico() != null && !receta.getDiagnostico().trim().isEmpty()) {
            Paragraph diagnosticoHeader = new Paragraph("DIAGNÓSTICO", labelFont);
            diagnosticoHeader.setSpacingBefore(10);
            diagnosticoHeader.setSpacingAfter(10);
            document.add(diagnosticoHeader);

            Paragraph diagnostico = new Paragraph(receta.getDiagnostico(), normalFont);
            diagnostico.setSpacingAfter(15);
            diagnostico.setAlignment(Element.ALIGN_JUSTIFIED);
            document.add(diagnostico);
        }

        // Medicamento prescrito (destacado)
        document.add(Chunk.NEWLINE);
        Paragraph medicamentoHeader = new Paragraph("MEDICAMENTO PRESCRITO", labelFont);
        medicamentoHeader.setSpacingBefore(10);
        medicamentoHeader.setSpacingAfter(10);
        document.add(medicamentoHeader);

        // Crear una tabla para el medicamento con fondo
        PdfPTable medicamentoTable = new PdfPTable(1);
        medicamentoTable.setWidthPercentage(100);
        medicamentoTable.setSpacingAfter(15);

        PdfPCell medicamentoCell = new PdfPCell();
        medicamentoCell.setBackgroundColor(new BaseColor(230, 240, 255));
        medicamentoCell.setPadding(10);
        medicamentoCell.setBorder(Rectangle.NO_BORDER);

        Font medicamentoFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 14, new BaseColor(0, 51, 153));
        Paragraph medicamentoPara = new Paragraph(receta.getMedicamento(), medicamentoFont);
        medicamentoCell.addElement(medicamentoPara);

        if (receta.getDosis() != null && !receta.getDosis().trim().isEmpty()) {
            Font dosisFont = FontFactory.getFont(FontFactory.HELVETICA, 12, BaseColor.BLACK);
            Paragraph dosisPara = new Paragraph("Dosis: " + receta.getDosis(), dosisFont);
            dosisPara.setSpacingBefore(5);
            medicamentoCell.addElement(dosisPara);
        }

        medicamentoTable.addCell(medicamentoCell);
        document.add(medicamentoTable);

        // Indicaciones
        if (receta.getIndicaciones() != null && !receta.getIndicaciones().trim().isEmpty()) {
            Paragraph indicacionesHeader = new Paragraph("INDICACIONES", labelFont);
            indicacionesHeader.setSpacingBefore(10);
            indicacionesHeader.setSpacingAfter(10);
            document.add(indicacionesHeader);

            Paragraph indicaciones = new Paragraph(receta.getIndicaciones(), normalFont);
            indicaciones.setSpacingAfter(15);
            indicaciones.setAlignment(Element.ALIGN_JUSTIFIED);
            document.add(indicaciones);
        }

        // Estado de la receta
        document.add(Chunk.NEWLINE);
        PdfPTable estadoTable = new PdfPTable(1);
        estadoTable.setWidthPercentage(100);
        estadoTable.setSpacingAfter(20);

        PdfPCell estadoCell = new PdfPCell();
        estadoCell.setPadding(8);
        estadoCell.setBorder(Rectangle.BOX);

        BaseColor estadoColor;
        switch (receta.getEstado()) {
            case "EMITIDA":
                estadoColor = new BaseColor(144, 238, 144); // Verde
                break;
            case "UTILIZADA":
                estadoColor = new BaseColor(173, 216, 230); // Azul claro
                break;
            case "VENCIDA":
                estadoColor = new BaseColor(255, 182, 193); // Rojo claro
                break;
            // Compatibilidad con estados antiguos
            case "ACTIVA":
                estadoColor = new BaseColor(144, 238, 144);
                break;
            case "CANCELADA":
                estadoColor = new BaseColor(255, 182, 193);
                break;
            default:
                estadoColor = BaseColor.LIGHT_GRAY;
        }
        estadoCell.setBackgroundColor(estadoColor);

        Font estadoFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, BaseColor.BLACK);
        Paragraph estadoPara = new Paragraph("Estado: " + receta.getEstado(), estadoFont);
        estadoPara.setAlignment(Element.ALIGN_CENTER);
        estadoCell.addElement(estadoPara);

        estadoTable.addCell(estadoCell);
        document.add(estadoTable);

        // Advertencias
        document.add(Chunk.NEWLINE);
        Paragraph advertencia = new Paragraph(
            "ADVERTENCIA: Esta receta es personal e intransferible. " +
            "No automedicarse. Consulte a su médico ante cualquier duda o efecto adverso.",
            smallFont
        );
        advertencia.setAlignment(Element.ALIGN_JUSTIFIED);
        advertencia.setSpacingAfter(10);
        document.add(advertencia);

        // Footer
        document.add(Chunk.NEWLINE);
        Paragraph footer = new Paragraph(
            "Documento generado electrónicamente por MediTrack\n" +
            "Fecha de generación: " + java.time.LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")),
            smallFont
        );
        footer.setAlignment(Element.ALIGN_CENTER);
        document.add(footer);

        document.close();
        out.flush();
        out.close();
    }

    private void addCellToTable(PdfPTable table, String text, Font font, boolean isLabel) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBorder(Rectangle.NO_BORDER);
        cell.setPadding(5);
        if (isLabel) {
            cell.setHorizontalAlignment(Element.ALIGN_LEFT);
        }
        table.addCell(cell);
    }
}

