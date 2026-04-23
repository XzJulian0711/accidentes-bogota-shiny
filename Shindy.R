library(shiny)
library(ggplot2)
library(dplyr)
library(readr)
library(scales)

month_order <- c(
  "enero" = 1, "febrero" = 2, "marzo" = 3, "abril" = 4, "mayo" = 5, "junio" = 6,
  "julio" = 7, "agosto" = 8, "septiembre" = 9, "octubre" = 10, "noviembre" = 11, "diciembre" = 12
)

possible_paths <- c("../data/accidentes_bogota.csv", "data/accidentes_bogota.csv", "accidentes_bogota.csv")
csv_path <- possible_paths[file.exists(possible_paths)][1]

if (is.na(csv_path)) {
  stop("No se encontró el archivo accidentes_bogota.csv")
}

theme_set(theme_minimal(base_size = 16))

df <- read_csv(csv_path, show_col_types = FALSE) |>
  mutate(
    ANO = as.numeric(ANO),
    casos = as.numeric(casos),
    mes_lower = tolower(trimws(MES_DEL_HECHO)),
    mes_num = unname(month_order[mes_lower])
  )

ui <- fluidPage(
  titlePanel("Accidentes de transporte en Bogotá - Shiny"),
  sidebarLayout(
    sidebarPanel(
      width = 3,
      selectInput(
        "ano", "Selecciona año",
        choices = sort(unique(df$ANO)),
        selected = sort(unique(df$ANO))[1],
        multiple = FALSE
      ),
      selectInput(
        "sexo", "Selecciona sexo",
        choices = c("Todos", sort(unique(df$Sexo))),
        selected = "Todos"
      ),
      selectInput(
        "localidad", "Selecciona localidad",
        choices = c("Todas", sort(unique(df$LOCALIDAD))),
        selected = "Todas"
      )
    ),
    mainPanel(
      width = 9,
      
      h3("Insight 1: Las localidades con mayor carga concentran buena parte de los casos"),
      plotOutput("plot_localidad_sexo", height = "620px"),
      
      tags$hr(),
      
      h3("Insight 2: La composición de tipos de accidente cambia entre localidades"),
      plotOutput("plot_localidad_tipo_prop", height = "650px"),
      
      tags$hr(),
      
      h3("Insight 3: La afectación por ciclo vital presenta diferencias por sexo"),
      plotOutput("plot_ciclo_sexo", height = "620px"),
      
      tags$hr(),
      
      h3("Insight 4: El comportamiento mensual permite ver meses de mayor presión"),
      plotOutput("plot_mes_sexo", height = "550px"),
      
      tags$hr(),
      
      h3("Insight 5: Cada tipo de accidente tiene una localidad dominante"),
      plotOutput("plot_heatmap", height = "650px")
    )
  )
)

server <- function(input, output) {
  
  filtered_data <- reactive({
    data <- df |> filter(ANO == as.numeric(input$ano))
    
    if (input$sexo != "Todos") {
      data <- data |> filter(Sexo == input$sexo)
    }
    
    if (input$localidad != "Todas") {
      data <- data |> filter(LOCALIDAD == input$localidad)
    }
    
    data
  })
  
  # 1. LOCALIDAD VS SEXO
  output$plot_localidad_sexo <- renderPlot({
    plot_df <- filtered_data() |>
      group_by(LOCALIDAD, Sexo) |>
      summarise(casos = sum(casos, na.rm = TRUE), .groups = "drop")
    
    top_localidades <- plot_df |>
      group_by(LOCALIDAD) |>
      summarise(total = sum(casos), .groups = "drop") |>
      arrange(desc(total)) |>
      slice_head(n = 8) |>
      pull(LOCALIDAD)
    
    plot_df <- plot_df |>
      filter(LOCALIDAD %in% top_localidades)
    
    ggplot(
      plot_df,
      aes(
        x = casos,
        y = reorder(LOCALIDAD, casos, FUN = sum),
        fill = Sexo
      )
    ) +
      geom_col(position = "dodge", width = 0.75) +
      scale_fill_manual(values = c("Hombre" = "#8B0000", "Mujer" = "#F46043")) +
      labs(
        title = paste("Accidentes por localidad y sexo -", input$ano),
        x = "Número de accidentes",
        y = "Localidad",
        fill = "Sexo"
      ) +
      theme(
        axis.text.y = element_text(size = 13),
        axis.text.x = element_text(size = 12),
        axis.title.x = element_text(size = 15),
        axis.title.y = element_text(size = 15),
        plot.title = element_text(size = 18, face = "bold")
      )
  })
  
  # 2. LOCALIDAD VS TIPO - PROPORCIÓN
  output$plot_localidad_tipo_prop <- renderPlot({
    data_use <- filtered_data()
    
    top_localidades <- data_use |>
      group_by(LOCALIDAD) |>
      summarise(total = sum(casos, na.rm = TRUE), .groups = "drop") |>
      arrange(desc(total)) |>
      slice_head(n = 8) |>
      pull(LOCALIDAD)
    
    top_tipos <- data_use |>
      group_by(CLASE_O_TIPO_DE_ACCIDENTE_DE_TRANSPORTE) |>
      summarise(total = sum(casos, na.rm = TRUE), .groups = "drop") |>
      arrange(desc(total)) |>
      slice_head(n = 5) |>
      pull(CLASE_O_TIPO_DE_ACCIDENTE_DE_TRANSPORTE)
    
    plot_df <- data_use |>
      filter(
        LOCALIDAD %in% top_localidades,
        CLASE_O_TIPO_DE_ACCIDENTE_DE_TRANSPORTE %in% top_tipos
      ) |>
      group_by(LOCALIDAD, CLASE_O_TIPO_DE_ACCIDENTE_DE_TRANSPORTE) |>
      summarise(casos = sum(casos, na.rm = TRUE), .groups = "drop")
    
    ggplot(
      plot_df,
      aes(
        x = reorder(LOCALIDAD, casos, FUN = sum),
        y = casos,
        fill = CLASE_O_TIPO_DE_ACCIDENTE_DE_TRANSPORTE
      )
    ) +
      geom_col(position = "fill", width = 0.8) +
      coord_flip() +
      scale_y_continuous(labels = percent_format()) +
      labs(
        title = "Proporción de tipos de accidente dentro de cada localidad",
        x = "Localidad",
        y = "Proporción",
        fill = "Tipo de accidente"
      ) +
      theme(
        axis.text.y = element_text(size = 13),
        axis.text.x = element_text(size = 12),
        axis.title.x = element_text(size = 15),
        axis.title.y = element_text(size = 15),
        plot.title = element_text(size = 18, face = "bold"),
        legend.title = element_text(size = 12),
        legend.text = element_text(size = 11)
      )
  })
  
  # 3. CICLO VITAL VS SEXO
  output$plot_ciclo_sexo <- renderPlot({
    plot_df <- filtered_data() |>
      group_by(CICLO_VITAL, Sexo) |>
      summarise(casos = sum(casos, na.rm = TRUE), .groups = "drop")
    
    ggplot(
      plot_df,
      aes(
        x = casos,
        y = reorder(CICLO_VITAL, casos, FUN = sum),
        fill = Sexo
      )
    ) +
      geom_col(position = "dodge", width = 0.75) +
      scale_fill_manual(values = c("Hombre" = "#6A3D9A", "Mujer" = "#B07CC6")) +
      labs(
        title = "Comparación por ciclo vital y sexo",
        x = "Número de accidentes",
        y = "Ciclo vital",
        fill = "Sexo"
      ) +
      theme(
        axis.text.y = element_text(size = 13),
        axis.text.x = element_text(size = 12),
        axis.title.x = element_text(size = 15),
        axis.title.y = element_text(size = 15),
        plot.title = element_text(size = 18, face = "bold")
      )
  })
  
  # 4. EVOLUCIÓN MENSUAL
  output$plot_mes_sexo <- renderPlot({
    plot_df <- filtered_data() |>
      group_by(mes_num, MES_DEL_HECHO, Sexo) |>
      summarise(casos = sum(casos, na.rm = TRUE), .groups = "drop") |>
      arrange(mes_num)
    
    ggplot(plot_df, aes(x = mes_num, y = casos, color = Sexo, group = Sexo)) +
      geom_line(linewidth = 1.2) +
      geom_point(size = 3) +
      scale_color_manual(values = c("Hombre" = "#1B9E77", "Mujer" = "#66C2A5")) +
      scale_x_continuous(
        breaks = 1:12,
        labels = c("Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic")
      ) +
      labs(
        title = "Evolución mensual comparada por sexo",
        x = "Mes",
        y = "Número de accidentes",
        color = "Sexo"
      ) +
      theme(
        axis.text.x = element_text(size = 12),
        axis.text.y = element_text(size = 12),
        axis.title.x = element_text(size = 15),
        axis.title.y = element_text(size = 15),
        plot.title = element_text(size = 18, face = "bold")
      )
  })
  
  # 5. TIPO DE ACCIDENTE -> LOCALIDAD DOMINANTE
  output$plot_heatmap <- renderPlot({
    data_use <- filtered_data()
    
    top_localidades <- data_use |>
      group_by(LOCALIDAD) |>
      summarise(total = sum(casos, na.rm = TRUE), .groups = "drop") |>
      arrange(desc(total)) |>
      slice_head(n = 8) |>
      pull(LOCALIDAD)
    
    top_tipos <- data_use |>
      group_by(CLASE_O_TIPO_DE_ACCIDENTE_DE_TRANSPORTE) |>
      summarise(total = sum(casos, na.rm = TRUE), .groups = "drop") |>
      arrange(desc(total)) |>
      slice_head(n = 8) |>
      pull(CLASE_O_TIPO_DE_ACCIDENTE_DE_TRANSPORTE)
    
    plot_df <- data_use |>
      filter(
        LOCALIDAD %in% top_localidades,
        CLASE_O_TIPO_DE_ACCIDENTE_DE_TRANSPORTE %in% top_tipos
      ) |>
      group_by(CLASE_O_TIPO_DE_ACCIDENTE_DE_TRANSPORTE, LOCALIDAD) |>
      summarise(casos = sum(casos, na.rm = TRUE), .groups = "drop")
    
    plot_df_top <- plot_df |>
      group_by(CLASE_O_TIPO_DE_ACCIDENTE_DE_TRANSPORTE) |>
      slice_max(order_by = casos, n = 1, with_ties = FALSE) |>
      ungroup() |>
      arrange(desc(casos))
    
    ggplot(
      plot_df_top,
      aes(
        x = casos,
        y = reorder(CLASE_O_TIPO_DE_ACCIDENTE_DE_TRANSPORTE, casos),
        fill = casos
      )
    ) +
      geom_col(width = 0.75) +
      geom_text(
        aes(label = paste0(LOCALIDAD, " (", casos, ")")),
        hjust = -0.1,
        size = 4.3,
        color = "black"
      ) +
      scale_fill_gradient(low = "#F3D9CE", high = "#8B0000") +
      labs(
        title = "Localidad con mayor número de casos por tipo de accidente",
        x = "Número de casos",
        y = "Tipo de accidente"
      ) +
      expand_limits(x = max(plot_df_top$casos) * 1.12) +
      theme(
        legend.position = "none",
        axis.text.y = element_text(size = 13),
        axis.text.x = element_text(size = 12),
        axis.title.x = element_text(size = 15),
        axis.title.y = element_text(size = 15),
        plot.title = element_text(size = 18, face = "bold")
      )
  })
}

shinyApp(ui = ui, server = server)