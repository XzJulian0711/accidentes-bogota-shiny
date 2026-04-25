# ProyectoShiny

# Accidentes de Transporte - Bogotá (Shiny App)

## Descripción

Aplicación web interactiva desarrollada en **R con Shiny** que visualiza los accidentes de transporte registrados en Bogotá entre 2015 y 2025. Permite explorar los datos mediante filtros dinámicos por año, localidad, tipo de accidente y sexo de la víctima, revelando patrones geográficos, temporales y demográficos clave.

Este proyecto hace parte del **Proyecto 2 - Herramientas y Visualización de Datos** de la Fundación Universitaria Los Libertadores.

---

## Dataset

- **Fuente:** [datos.gov.co](https://www.datos.gov.co/) — Datos abiertos del gobierno colombiano
- **Archivo:** `accidentes_bogota.csv`
- **Registros:** ~12,386 filas (expandidas por el campo `casos`)
- **Variables principales:** año, localidad, tipo de accidente, circunstancia del hecho, ciclo vital, sexo de la víctima, medio de desplazamiento, condición de la víctima

---

## Hallazgos Principales

1. **La pandemia marcó una caída histórica, pero el rebote fue explosivo:** En 2020 los accidentes cayeron drásticamente por las restricciones de movilidad. Desde 2022 la tendencia se recuperó y en 2024 superó los niveles pre-pandemia.

2. **Kennedy, Engativá y Suba concentran los accidentes en el sur-occidente:** Las localidades de mayor densidad poblacional y actividad vehicular acumulan la mayoría de siniestros. Sumapaz, localidad rural, registra el menor volumen.

3. **Choque y atropello representan casi el 90% de los accidentes:** Dos categorías dominan el panorama, lo que indica que las políticas de prevención deben focalizarse en estas dinámicas de siniestro.

4. **Hombres adultos (29-59 años) concentran la mayoría de víctimas:** Los hombres representan ~70% de las víctimas y la población económicamente activa es la más expuesta, sugiriendo patrones vinculados a movilidad laboral.

5. **La desobediencia de señales es la principal causa identificada:** Desobedecer señales de tránsito lidera con gran diferencia, seguido por exceso de velocidad. Ambas son causas prevenibles vinculadas al comportamiento del conductor.

---

## Visualizaciones Implementadas

1. **Serie temporal (área)** — Evolución anual de accidentes 2015–2025 con anotación del inicio de la pandemia
2. **Barras horizontales con gradiente** — Ranking de accidentes por localidad
3. **Donut chart** — Distribución porcentual por tipo de accidente
4. **Pirámide poblacional** — Víctimas por sexo y grupo etario (estilo back-to-back)
5. **Lollipop chart** — Top 8 causas de accidentes identificadas

---

## Tecnologías Utilizadas

- **Framework:** Shiny (R)
- **Lenguaje:** R
- **Bibliotecas:**
  - `shiny` — Framework de aplicaciones web reactivas
  - `bslib` — Temas y diseño Bootstrap moderno
  - `plotly` — Gráficos interactivos
  - `dplyr` / `tidyr` — Manipulación de datos
  - `readr` — Lectura del CSV

---

## Instalación y Ejecución Local

### Requisitos previos

- R >= 4.1
- RStudio (recomendado)

### Instrucciones

```bash
# Clonar repositorio
git clone https://github.com/usuario/shiny-accidentes-bogota.git
cd shiny-accidentes-bogota
```

```r
# Instalar dependencias
install.packages(c("shiny", "dplyr", "plotly", "bslib", "readr", "tidyr"))

# Ejecutar aplicación
shiny::runApp("app.R")
```

> El archivo `accidentes_bogota.csv` debe estar en la misma carpeta que `app.R`.

---

## Despliegue

La aplicación está desplegada en **shinyapps.io**:

 **URL en producción:** `[https://usuario.shinyapps.io/accidentes-bogota](http://127.0.0.1:6362/)`

Para desplegar desde R:

```r
library(rsconnect)
rsconnect::deployApp(appFiles = c("app.R", "accidentes_bogota.csv"))
```

---

## Estructura del repositorio

```
shiny-accidentes-bogota/
├── app.R                    # Código fuente completo de la aplicación
├── accidentes_bogota.csv    # Dataset de accidentes de transporte en Bogotá
└── README.md                # Documentación del proyecto
```

---

## Autores

**[Julian Camilo Cardenas Torres] — GitHub: @xzjulian0711**

**[Juan Fernando Bueno Torres] — GitHub: @JuanFer2004**

*Fundación Universitaria Los Libertadores — Herramientas y Visualización de Datos, 2026*
