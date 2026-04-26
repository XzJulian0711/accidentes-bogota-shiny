# ProyectoShiny

# Accidentes de Transporte - Bogotá (Shiny App)

Aplicación web interactiva desarrollada en **R con Shiny** que visualiza los accidentes de transporte registrados en Bogotá entre 2015 y 2025. Permite explorar los datos mediante filtros dinámicos por año, localidad, tipo de accidente y sexo de la víctima, revelando patrones geográficos, temporales y demográficos clave.

## App desplegada
**[Ver aplicación en vivo](https://xzjulian-accidentes-bogota.shinyapps.io/app-shiny/)**

Este proyecto hace parte del **Proyecto 2 - Herramientas y Visualización de Datos** de la Fundación Universitaria Los Libertadores.
## Descripción

Aplicación web interactiva desarrollada en **R con Shiny** que visualiza los accidentes de transporte registrados en Bogotá entre 2015 y 2025. Permite explorar los datos mediante filtros dinámicos por año, localidad, tipo de accidente y sexo de la víctima, revelando patrones geográficos, temporales y demográficos clave.

Este proyecto hace parte del **Proyecto 2 - Herramientas y Visualización de Datos** de la Fundación Universitaria Los Libertadores.

---

## Dataset

- **Fuente:** Datos Abiertos Bogotá — Secretaría Distrital de Gobierno
- **URL original:** [datosabiertos.bogota.gov.co](https://datosabiertos.bogota.gov.co/)
- **Archivo:** `data/accidentes_bogota_limpio.csv` (versión preprocesada)
- **Descripción:** Registros de accidentes de transporte ocurridos en Bogotá entre 2015 y 2025, con información sobre ubicación (localidad), variables temporales (año, mes, día, hora), tipo de accidente, medio de transporte, causas, y perfil de la víctima (sexo, ciclo vital).
- **Dimensiones:** 12,386 registros × 14 variables (tras limpieza)
- **Datos geográficos:** TopoJSON oficial de las 20 localidades de Bogotá (`data/bogota_localidades.json`)
- **Preprocesamiento aplicado:** normalización de nombres de columnas, reemplazo de "Bogotá" por "Sin localidad específica" en la columna localidad, conversión de meses y días a variables categóricas ordenadas, eliminación de columnas no relevantes para el análisis.

---

## Hallazgos Principales

1. **La pandemia marcó una caída histórica, pero el rebote fue explosivo:** En 2020 los accidentes cayeron drásticamente por las restricciones de movilidad. Desde 2022 la tendencia se recuperó y en 2024 superó los niveles pre-pandemia.

2. **Kennedy, Engativá y Suba concentran los accidentes en el sur-occidente:** Las localidades de mayor densidad poblacional y actividad vehicular acumulan la mayoría de siniestros. Sumapaz, localidad rural, registra el menor volumen.

3. **Choque y atropello representan casi el 90% de los accidentes:** Dos categorías dominan el panorama, lo que indica que las políticas de prevención deben focalizarse en estas dinámicas de siniestro.

4. **Hombres adultos (29-59 años) concentran la mayoría de víctimas:** Los hombres representan ~70% de las víctimas y la población económicamente activa es la más expuesta, sugiriendo patrones vinculados a movilidad laboral.

5. **La desobediencia de señales es la principal causa identificada:** Desobedecer señales de tránsito lidera con gran diferencia, seguido por exceso de velocidad. Ambas son causas prevenibles vinculadas al comportamiento del conductor.

---

## Visualizaciones Implementadas

1. **Gráfico de área temporal** — Evolución anual de accidentes (2015-2025) con marcador vertical destacando el inicio de la pandemia. Cubre el tipo *"evolución temporal"*.

2. **Mapa coroplético de Bogotá** — Mapa interactivo con las 20 localidades coloreadas según intensidad de accidentes (paleta secuencial cálida amarillo-naranja-rojo). Construido con `sf` y `plotly` a partir de un TopoJSON oficial. Cubre el tipo *"comparación geográfica entre categorías"*.

3. **Donut chart de tipos de accidente** — Distribución proporcional con paleta cualitativa y agrupación inteligente de categorías menores en "Otros". Cubre el tipo *"composición o proporciones"*.

4. **Pirámide poblacional** — Gráfico demográfico clásico back-to-back con hombres (azul) a la izquierda y mujeres (rojo) a la derecha, distribuidos por ciclo vital. Cubre el tipo *"distribución de variables demográficas"*.

5. **Lollipop chart de causas** — Top 8 causas identificadas con palitos rojos y círculos coloreados (paleta secuencial). Alternativa elegante al gráfico de barras. Cubre el tipo *"relación entre variables"* (causa × frecuencia).

Adicionalmente se incluyen **4 KPIs ejecutivos** (total de accidentes, año pico, localidad crítica, tipo predominante) que se actualizan dinámicamente con cada filtro aplicado.

---

## Tecnologías Utilizadas

- **Framework:** Shiny (R)
- **Lenguaje:** R 4.5.x
- **Bibliotecas principales:**
  - `shiny` — Framework de aplicaciones web reactivas
  - `bslib` — Temas Bootstrap modernos
  - `plotly` — Gráficos interactivos
  - `dplyr` / `tidyr` — Manipulación de datos
  - `readr` — Lectura del CSV
  - `sf` — Procesamiento de geometrías geográficas
  - `geojsonio` — Conversión de TopoJSON a objetos sf
  - `jsonlite` — Procesamiento de JSON
- **Datos geográficos:** TopoJSON oficial de las 20 localidades de Bogotá
- **Plataforma de despliegue:** shinyapps.io
- **Control de versiones:** Git + GitHub

---

## Instalación y Ejecución Local

### Requisitos previos

- R >= 4.4 (recomendado 4.5.x para compatibilidad con shinyapps.io)
- RStudio Desktop (recomendado)
### Instrucciones

```bash
# 1. Clonar el repositorio
git clone https://github.com/XzJulian0711/accidentes-bogota-shiny.git
cd app-shiny
```

```r
# 2. Abrir el proyecto en RStudio y ejecutar en la consola:

# Instalar dependencias
install.packages(c(
  "shiny", "dplyr", "plotly", "bslib", "readr", "tidyr",
  "jsonlite", "sf", "geojsonio"
))

# Ejecutar aplicación
shiny::runApp()
```

La aplicación se abrirá automáticamente en `http://127.0.0.1:XXXX/`.
```


```



## Estructura del repositorio

```
accidentes-bogota-shiny/
├── app.R                              # Aplicación Shiny principal
├── README.md                          # Este archivo
├── .gitignore                         # Archivos a ignorar por Git
└── data/
├── accidentes_bogota_limpio.csv   # Dataset procesado
└── bogota_localidades.json        # TopoJSON de las 20 localidades

```
## Principios de diseño aplicados
- **Unidad 1 (Fundamentos):** elección cuidada del tipo de gráfico según la naturaleza de los datos — área para series temporales, mapa coroplético para variables geográficas, donut para composición, pirámide para distribución demográfica simétrica, lollipop para rankings.
- **Unidad 2 (Color):** uso estratégico de paletas:
  - *Secuenciales* (amarillo-naranja-rojo en mapa, naranja-rojo en lollipop) para variables ordenadas por intensidad
  - *Cualitativas* para categorías sin orden (tipos de accidente)
  - *Divergente* (azul vs rojo en pirámide) para datos con dos categorías opuestas
  - *Acento* (rojo) para resaltar el inicio de la pandemia
- **Unidad 3 (Diseño):** alto data-ink ratio (ejes limpios, sin decoraciones), jerarquía visual clara (títulos descriptivos con el hallazgo, "cajas de lectura" con interpretación), espaciado consistente, tipografía Inter (Google Fonts).

## Despliegue
**URL en producción:** [https://xzjulian-accidentes-bogota.shinyapps.io/app-shiny/](https://xzjulian-accidentes-bogota.shinyapps.io/app-shiny/)

Desplegado en **shinyapps.io** (Posit Cloud). Cada actualización local requiere re-desplegar manualmente con:

```r
library(rsconnect)
rsconnect::deployApp(
  appName = "accidentes-bogota",
  appFiles = c("app.R", "data/accidentes_bogota_limpio.csv", "data/bogota_localidades.json")
)
```
> ⚠️ **Nota técnica:** shinyapps.io requiere R 4.4 o 4.5. Si usas R 4.6 (lanzado en abril 2026), instala R 4.5.3 en paralelo y configura RStudio para usar esa versión al desplegar.

## Proyecto relacionado
- **[Streamlit App](https://accidentes-bogota-streamlit.streamlit.app)** — Para análisis rápido e iterativo (Python)
- **Shiny App** — Este repositorio (R)
- **[D3.js App](https://xzjulian0711.github.io/accidentes-bogota-d3/)** — Para visualizaciones embebibles (JavaScript)

---

## Autores

**[Julian Camilo Cardenas Torres] — GitHub: @xzjulian0711**

**[Juan Fernando Bueno Torres] — GitHub: @JuanFer2004**

## Licencia
Este proyecto es de carácter académico, desarrollado para la **Fundación Universitaria Los Libertadores** como parte del curso de Herramientas y Visualización de Datos.

---

<div align="center">
  <sub>Proyecto 2 · Abril 2026</sub>
</div>

*Fundación Universitaria Los Libertadores — Herramientas y Visualización de Datos, 2026*
