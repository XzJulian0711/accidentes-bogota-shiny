# ============================================================
#  ACCIDENTES DE TRANSPORTE EN BOGOTÁ — Shiny App
# Versión final con mapa coroplético de Bogotá
# ============================================================

library(shiny)
library(dplyr)
library(plotly)
library(bslib)
library(readr)
library(tidyr)
library(jsonlite)
library(sf)         # Para procesar geometrías
library(geojsonio)  # Para convertir TopoJSON → sf

# ── Cargar dataset limpio ───────────────────────────────────
df_raw <- read_csv("data/accidentes_bogota_limpio.csv", show_col_types = FALSE)

# Renombrar columnas del CSV limpio a los nombres que usa el resto del código
df_raw <- df_raw %>%
  rename(
    tipo         = tipo_accidente,
    causa        = circunstancia,
    grupo_etario = ciclo_vital
  ) %>%
  filter(!is.na(localidad), localidad != "Sin localidad específica")
# Variables únicas para los filtros del sidebar
localidades_unicas <- sort(unique(df_raw$localidad))
tipos_unicos       <- sort(unique(df_raw$tipo))
sexos_unicos       <- sort(unique(df_raw$sexo[!is.na(df_raw$sexo)]))

# ── Cargar TopoJSON de Bogotá y convertir a sf ──────────────
# El TopoJSON tiene nombres en MAYÚSCULAS sin tildes,
# vamos a mapearlos a los nombres del dataset
mapping_localidades <- c(
  "ANTONIO NARIÑO"    = "Antonio Nariño",
  "BARRIOS UNIDOS"    = "Barrios Unidos",
  "BOSA"              = "Bosa",
  "CANDELARIA"        = "La Candelaria",
  "CHAPINERO"         = "Chapinero",
  "CIUDAD BOLIVAR"    = "Ciudad Bolívar",
  "ENGATIVA"          = "Engativá",
  "FONTIBON"          = "Fontibón",
  "KENNEDY"           = "Kennedy",
  "LOS MARTIRES"      = "Los Mártires",
  "PUENTE ARANDA"     = "Puente Aranda",
  "RAFAEL URIBE URIBE"= "Rafael Uribe Uribe",
  "SAN CRISTOBAL"     = "San Cristóbal",
  "SANTA FE"          = "Santa Fe",
  "SUBA"              = "Suba",
  "SUMAPAZ"           = "Sumapaz",
  "TEUSAQUILLO"       = "Teusaquillo",
  "TUNJUELITO"        = "Tunjuelito",
  "USAQUEN"           = "Usaquén",
  "USME"              = "Usme"
)

# Cargar TopoJSON y convertir a sf
bogota_sf <- geojsonio::topojson_read("data/bogota_localidades.json")

# Aplicar el mapeo de nombres
bogota_sf$localidad <- mapping_localidades[bogota_sf$NOMBRE]


# ── Colores ─────────────────────────────────────────────────
COL_PRIMARY   <- "#E05252"
COL_ACCENT    <- "#5B9BD5"
COL_BG        <- "#F8F9FA"
COL_READING   <- "#EBF3FB"
COL_TEXT_READ <- "#1A5276"


# ── Helpers UI ──────────────────────────────────────────────
kpi_box <- function(label, value_ui, sub_ui = NULL) {
  tags$div(
    style = "background:#fff;border:1px solid #e0e0e0;border-radius:8px;padding:16px;margin-bottom:12px;",
    tags$p(label, style = "font-size:12px;color:#888;margin-bottom:4px;"),
    tags$div(style = "font-size:28px;font-weight:700;color:#2C3E50;", value_ui),
    if (!is.null(sub_ui))
      tags$div(style = "font-size:12px;color:#27AE60;margin-top:4px;", sub_ui)
  )
}

reading_box <- function(text) {
  tags$div(
    style = paste0(
      "background:", COL_READING, ";border-left:4px solid ", COL_ACCENT, ";",
      "border-radius:4px;padding:12px 16px;margin-top:8px;margin-bottom:4px;"
    ),
    tags$span(tags$b("Lectura: "), style = paste0("color:", COL_TEXT_READ, ";")),
    tags$span(text, style = paste0("font-size:14px;color:", COL_TEXT_READ, ";"))
  )
}

insight_title <- function(text) {
  tags$h4(text, style = "font-weight:700;color:#2C3E50;margin-top:8px;")
}


# ── UI ──────────────────────────────────────────────────────
ui <- page_sidebar(
  title = "Accidentes de Transporte - Bogotá",
  theme = bs_theme(
    bg = "#F8F9FA", fg = "#2C3E50",
    primary = COL_PRIMARY,
    base_font = font_google("Inter")
  ),
  fillable = FALSE,

  sidebar = sidebar(
    width = 250,
    bg = "#FFFFFF",
    tags$h5("Filtros", style = "font-weight:700;margin-bottom:4px;"),
    tags$p("Ajusta los filtros para explorar los datos:",
           style = "font-size:13px;color:#666;margin-bottom:12px;"),

    sliderInput("anios", "Rango de años",
                min   = min(df_raw$anio, na.rm = TRUE),
                max   = max(df_raw$anio, na.rm = TRUE),
                value = c(min(df_raw$anio, na.rm = TRUE),
                          max(df_raw$anio, na.rm = TRUE)),
                sep = "", step = 1),

    tags$label("Localidades", style = "font-weight:600;font-size:13px;"),
    div(style = "max-height:180px;overflow-y:auto;",
        checkboxGroupInput("localidades", NULL,
                           choices  = localidades_unicas,
                           selected = localidades_unicas)),

    tags$label("Tipo de accidente",
               style = "font-weight:600;font-size:13px;margin-top:8px;display:block;"),
    div(style = "max-height:160px;overflow-y:auto;",
        checkboxGroupInput("tipos", NULL,
                           choices  = tipos_unicos,
                           selected = tipos_unicos)),

    tags$label("Sexo de la víctima",
               style = "font-weight:600;font-size:13px;margin-top:8px;display:block;"),
    checkboxGroupInput("sexo", NULL,
                       choices  = sexos_unicos,
                       selected = sexos_unicos),

    tags$hr(),
    tags$div(style = "font-size:13px;color:#555;",
             tags$b("Registros filtrados: "),
             textOutput("n_filtrados", inline = TRUE))
  ),

  tags$div(
    style = "max-width:1100px;margin:0 auto;padding:16px 8px;",

    # KPIs
    tags$h4("Resumen del periodo seleccionado",
            style = "font-weight:700;margin-bottom:16px;color:#2C3E50;"),
    fluidRow(
      column(3, kpi_box("Total de accidentes", textOutput("kpi_total"))),
      column(3, kpi_box("Año pico",            textOutput("kpi_anio"),  textOutput("kpi_anio_sub"))),
      column(3, kpi_box("Localidad crítica",   textOutput("kpi_loc"),   textOutput("kpi_loc_sub"))),
      column(3, kpi_box("Tipo predominante",   textOutput("kpi_tipo")))
    ),

    tags$hr(style = "margin:24px 0;"),

    # ── INSIGHT 1: Serie temporal ──
    insight_title("Insight 1: La pandemia marcó una caída histórica, pero el rebote ha sido explosivo"),
    tags$p("Evolución anual de accidentes", style = "font-size:14px;color:#555;margin-bottom:4px;"),
    plotlyOutput("plot_serie", height = "320px"),
    reading_box("En 2020 los accidentes cayeron drásticamente por las restricciones de movilidad durante la pandemia. Sin embargo, desde 2022 la tendencia se recuperó y en 2024 superó los niveles pre-pandemia, alcanzando el pico histórico del periodo."),

    tags$hr(style = "margin:24px 0;"),

    # ── INSIGHT 2: MAPA COROPLÉTICO ──
    insight_title("Insight 2: Kennedy, Engativá y Suba concentran los accidentes en el sur-occidente de Bogotá"),
    tags$p("Mapa de calor de accidentes por localidad", style = "font-size:14px;color:#555;margin-bottom:4px;"),
    plotlyOutput("plot_mapa", height = "550px"),
    reading_box("El mapa revela un patrón geográfico claro: las localidades del sur-occidente de Bogotá (Kennedy, Bosa, Ciudad Bolívar) y noroccidente (Engativá, Suba) concentran la mayor cantidad de accidentes. Esto coincide con zonas de alta densidad poblacional y fuerte actividad vehicular. Localidades rurales como Sumapaz permanecen en colores claros."),

    tags$hr(style = "margin:24px 0;"),

    # ── INSIGHT 3: Donut ──
    insight_title("Insight 3: Choque y atropello representan casi el 90% de los accidentes"),
    tags$p("Distribución por tipo de accidente", style = "font-size:14px;color:#555;margin-bottom:4px;"),
    plotlyOutput("plot_donut", height = "400px"),
    reading_box("Dos categorías dominan el panorama: choques entre vehículos y atropellos de peatones. Esto indica que las políticas de prevención deben focalizarse principalmente en estas dos dinámicas de siniestro."),

    tags$hr(style = "margin:24px 0;"),

    # ── INSIGHT 4: Pirámide ──
    insight_title("Insight 4: Hombres adultos (29-59 años) concentran la mayoría de víctimas"),
    tags$p("Pirámide poblacional de víctimas por sexo y grupo etario",
           style = "font-size:14px;color:#555;margin-bottom:4px;"),
    plotlyOutput("plot_piramide", height = "360px"),
    reading_box("La pirámide poblacional muestra dos patrones: (1) una fuerte asimetría de género —los hombres representan alrededor del 70% de las víctimas—, y (2) una concentración muy marcada en la población económicamente activa (29-59 años), lo que sugiere patrones de exposición vinculados a movilidad laboral."),

    tags$hr(style = "margin:24px 0;"),

    # ── INSIGHT 5: Lollipop ──
    insight_title("Insight 5: La desobediencia de señales es la principal causa identificada"),
    tags$p("Top 8 causas identificadas (excluyendo 'Sin información')",
           style = "font-size:14px;color:#555;margin-bottom:4px;"),
    plotlyOutput("plot_causas", height = "360px"),
    reading_box("Entre los casos con causa identificada, desobedecer señales de tránsito lidera con gran diferencia, seguido por exceso de velocidad. Ambas son causas prevenibles vinculadas directamente al comportamiento de los conductores."),

    tags$br(), tags$br()
  )
)


# ── SERVER ──────────────────────────────────────────────────
server <- function(input, output, session) {

  df_filt <- reactive({
    req(input$anios, input$localidades, input$tipos, input$sexo)
    df_raw %>%
      filter(
        anio      >= input$anios[1], anio      <= input$anios[2],
        localidad %in% input$localidades,
        tipo      %in% input$tipos,
        sexo      %in% input$sexo
      )
  })

  output$n_filtrados <- renderText({ format(nrow(df_filt()), big.mark = ",") })

  # ── KPIs ──
  output$kpi_total <- renderText({ format(nrow(df_filt()), big.mark = ",") })

  output$kpi_anio <- renderText({
    d <- df_filt() %>% count(anio) %>% slice_max(n, n = 1)
    if (nrow(d) == 0) return("—")
    as.character(d$anio[1])
  })
  output$kpi_anio_sub <- renderText({
    d <- df_filt() %>% count(anio) %>% slice_max(n, n = 1)
    if (nrow(d) == 0) return("")
    paste0("↑ ", format(d$n[1], big.mark = ","), " casos")
  })
  output$kpi_loc <- renderText({
    d <- df_filt() %>% count(localidad) %>% slice_max(n, n = 1)
    if (nrow(d) == 0) return("—")
    d$localidad[1]
  })
  output$kpi_loc_sub <- renderText({
    d <- df_filt() %>% count(localidad) %>% slice_max(n, n = 1)
    if (nrow(d) == 0) return("")
    paste0("↑ ", format(d$n[1], big.mark = ","), " casos")
  })
  output$kpi_tipo <- renderText({
    d <- df_filt() %>% count(tipo) %>% slice_max(n, n = 1)
    if (nrow(d) == 0) return("—")
    d$tipo[1]
  })

  # ── Plot 1: Serie temporal ──
  output$plot_serie <- renderPlotly({
    d <- df_filt() %>% count(anio) %>% arrange(anio)
    plot_ly(d, x = ~anio, y = ~n, type = "scatter", mode = "lines",
            fill = "tozeroy",
            fillcolor = "rgba(91,155,213,0.25)",
            line = list(color = COL_ACCENT, width = 2.5),
            hovertemplate = "Año %{x}: %{y} accidentes<extra></extra>") %>%
      add_segments(x = 2020, xend = 2020, y = 0, yend = max(d$n) * 1.1,
                   line = list(color = COL_PRIMARY, dash = "dash", width = 1.5),
                   name = "Inicio pandemia", showlegend = TRUE) %>%
      layout(
        xaxis  = list(title = "Año", tickformat = "d"),
        yaxis  = list(title = "Número de accidentes"),
        plot_bgcolor = COL_BG, paper_bgcolor = COL_BG,
        legend = list(x = 0.7, y = 0.95),
        margin = list(l = 60, r = 20, t = 20, b = 50)
      )
  })

  # ── Plot 2: MAPA COROPLÉTICO DE BOGOTÁ ──
  output$plot_mapa <- renderPlotly({
    # Conteo de accidentes por localidad
    conteo <- df_filt() %>%
      count(localidad, name = "total")

    # Unir con el sf de Bogotá
    mapa_data <- bogota_sf %>%
      left_join(conteo, by = "localidad") %>%
      mutate(total = ifelse(is.na(total), 0, total))

    # Crear el mapa con plotly
    plot_ly(mapa_data) %>%
      add_sf(
        color = ~total,
        colors = colorRamp(c("#FFFDE7", "#FF8F00", "#B71C1C")),
        split = ~localidad,
        showlegend = FALSE,
        text = ~paste0(
          "<b>", localidad, "</b><br>",
          format(total, big.mark = ","), " accidentes"
        ),
        hoverinfo = "text",
        stroke = I("white"),
        span = I(1)
      ) %>%
      layout(
        plot_bgcolor = COL_BG,
        paper_bgcolor = COL_BG,
        margin = list(l = 0, r = 0, t = 20, b = 0),
        xaxis = list(visible = FALSE),
        yaxis = list(visible = FALSE)
      ) %>%
      colorbar(title = "Accidentes", x = 1, y = 0.5)
  })

  # ── Plot 3: Donut ──
  output$plot_donut <- renderPlotly({
    d <- df_filt() %>% count(tipo) %>% arrange(desc(n)) %>%
      mutate(pct = n / sum(n))
    top  <- d %>% filter(pct >= 0.01)
    rest <- sum(d$n[d$pct < 0.01])
    if (rest > 0)
      top <- bind_rows(top, tibble(tipo = "Otros", n = rest, pct = rest / sum(d$n)))

    cols_map <- c(
      "Choque"                                  = "#2ECC71",
      "Atropello"                               = "#E67E22",
      "Volcamiento"                             = "#9B59B6",
      "Choque con otro vehículo"                = "#E91E63",
      "Choque con objeto fijo o en movimiento"  = "#3498DB",
      "Caída de ocupante"                       = "#1ABC9C",
      "Sin información"                         = "#F1C40F",
      "Otros"                                   = "#95A5A6"
    )
    cols <- unname(cols_map[top$tipo])
    cols[is.na(cols)] <- "#AAAAAA"

    plot_ly(top, labels = ~tipo, values = ~n, type = "pie", hole = 0.45,
            marker = list(colors = cols, line = list(color = "#fff", width = 2)),
            textinfo = "label+percent",
            hovertemplate = "%{label}: %{value}<extra></extra>") %>%
      layout(
        showlegend   = TRUE,
        legend       = list(x = 1, y = 0.5),
        plot_bgcolor = COL_BG, paper_bgcolor = COL_BG,
        margin       = list(l = 20, r = 160, t = 20, b = 20)
      )
  })

  # ── Plot 4: Pirámide ──
  output$plot_piramide <- renderPlotly({
    orden <- c("(0 a 5) Primera Infancia", "(6 a 11) Infancia",
               "(12 a 17) Adolescencia",   "(18 a 28) Juventud",
               "(29 a 59) Adultez",        "(60 y más) Persona Mayor")
    d <- df_filt() %>%
      filter(sexo %in% c("Hombre", "Mujer"), grupo_etario %in% orden) %>%
      count(grupo_etario, sexo) %>%
      mutate(grupo_etario = factor(grupo_etario, levels = orden))

    hom <- d %>% filter(sexo == "Hombre") %>% mutate(n_neg = -n)
    muj <- d %>% filter(sexo == "Mujer")
    max_val <- max(c(hom$n, muj$n), na.rm = TRUE) * 1.1
    tick_vals <- base::pretty(c(-max_val, max_val), n = 6)

    plot_ly() %>%
      add_bars(data = hom,
               y = ~grupo_etario, x = ~n_neg,
               name = "Hombres", orientation = "h",
               marker = list(color = COL_ACCENT),
               customdata = ~n,
               hovertemplate = "%{y}<br>Hombres: %{customdata}<extra></extra>") %>%
      add_bars(data = muj,
               y = ~grupo_etario, x = ~n,
               name = "Mujeres", orientation = "h",
               marker = list(color = COL_PRIMARY),
               hovertemplate = "%{y}<br>Mujeres: %{x}<extra></extra>") %>%
      layout(
        barmode = "overlay",
        xaxis = list(
          title    = "Número de víctimas",
          tickvals = tick_vals,
          ticktext = format(abs(tick_vals), big.mark = ","),
          range    = c(-max_val, max_val * 0.55)
        ),
        yaxis = list(title = "", categoryorder = "array",
                     categoryarray = orden),
        plot_bgcolor = COL_BG, paper_bgcolor = COL_BG,
        legend = list(x = 0.78, y = 0.05),
        margin = list(l = 160, r = 20, t = 20, b = 50)
      )
  })

  # ── Plot 5: Lollipop causas ──
  output$plot_causas <- renderPlotly({
    d <- df_filt() %>%
      filter(!grepl("sin información", causa, ignore.case = TRUE),
             !is.na(causa)) %>%
      count(causa) %>%
      arrange(desc(n)) %>%
      head(8) %>%
      arrange(n)

    pal <- colorRampPalette(c("#FFCCBC", "#E64A19"))(nrow(d))

    plot_ly(d) %>%
      add_segments(y = ~causa, yend = ~causa, x = 0, xend = ~n,
                   line = list(color = pal, width = 2),
                   showlegend = FALSE) %>%
      add_markers(y = ~causa, x = ~n,
                  marker = list(color = pal, size = 13),
                  text   = ~format(n, big.mark = ","),
                  textposition = "middle right",
                  hovertemplate = "%{y}: %{x}<extra></extra>",
                  showlegend = FALSE) %>%
      layout(
        xaxis = list(title = "Número de casos"),
        yaxis = list(title = ""),
        plot_bgcolor = COL_BG, paper_bgcolor = COL_BG,
        margin = list(l = 260, r = 80, t = 20, b = 50)
      )
  })
}

shinyApp(ui, server)