# Data Science II — Módulo 8.5

## Tabla maestra de features de clientes con SQL

**Objetivo:** generar métricas de comportamiento por cliente a partir de `clientes`, `pedidos`, `detalles_pedido` y `productos`, conservando clientes sin compras, sin duplicar pedidos y utilizando funciones de ventana para comparar clientes dentro de una ciudad.

### Requisitos

- Python 3.9 o superior, con el módulo integrado `sqlite3` (sin paquetes externos).
- Alternativamente, SQLite CLI para ejecutar los scripts `.sql`.
- Dataset sintético incorporado: **12 clientes**, **37 pedidos**, **39 renglones de detalle** y **5 productos**. Es deliberadamente pequeño para que los resultados sean auditables; no son datos de una empresa real.

### Organización del repositorio

```text
.
├── .gitignore
├── README.md
├── consultas_features.sql           # Las cuatro consultas en un único archivo
├── ejecutar.py                      # Ejecuta los scripts contra SQLite en memoria
├── datos/
│   └── 00_esquema_y_datos.sql       # CREATE TABLE e INSERT de datos ficticios
├── consultas/
│   ├── 01_ltv_todos_clientes.sql
│   ├── 02_gasto_por_categoria.sql
│   ├── 03_segmento_activo_having.sql
│   └── 04_ranking_por_ciudad.sql
├── tests/
│   └── test_consultas.py
└── evidencia/
    └── resultado_ejecucion.txt
```

### Cómo ejecutar y comprobar

En PowerShell, desde la raíz del proyecto:

```powershell
py ejecutar.py
py -m unittest discover -s tests -v
```

No se crea ni versiona ninguna base de datos `.db`: `ejecutar.py` abre una base SQLite temporal **en memoria** y carga el esquema antes de cada ejecución. También podés ejecutar las consultas desde SQLite CLI después de cargar `datos/00_esquema_y_datos.sql`.

### Consultas y decisiones

| Consulta | ¿Qué pregunta responde? | Diseño |
| --- | --- | --- |
| 01 · LTV | ¿Cuánto gastó cada cliente? | `LEFT JOIN` conserva incluso clientes sin pedidos; `COALESCE` expresa gasto cero. El LTV aquí es **gasto histórico observado**, no LTV predictivo futuro. |
| 02 · Categorías | ¿Cuánto gastó en Alimentos y Tecnología? | Cuatro tablas, `SUM(CASE WHEN ...)` por categoría, sin subconsultas para construir estas features. |
| 03 · Activos | ¿Quiénes hicieron **más de 3 pedidos** y tienen un **ticket promedio > 50**? | `HAVING` sobre grupos; `COUNT(DISTINCT pedido_id)` para no multiplicar pedidos con varios artículos. |
| 04 · Ranking | ¿Cómo se ubica cada cliente activo en su ciudad por gasto? | `DENSE_RANK() OVER (PARTITION BY ciudad ORDER BY gasto_total DESC)`. El ranking se calcula para **todos** los clientes antes de filtrar activos. |

#### Por qué el LEFT JOIN y el HAVING no se contradicen

Las consultas 01 y 02 forman la base maestra de **todos los clientes**, incluidos los de cero compras. Las consultas 03 y 04 crean una **vista segmentada intencionalmente**, que excluye a los inactivos por criterio de negocio; no implica que se hayan perdido datos en la tabla original.

#### Cómo evitamos duplicaciones al unir pedidos con sus detalles

Un pedido puede tener varios renglones. Para **el importe**, se suma el valor monetario de cada renglón (`cantidad * precio_unitario`), exactamente una vez; no se suma un total de pedido repetido en cada renglón. Para **la cantidad de compras**, se usa `COUNT(DISTINCT p.pedido_id)`. El **ticket promedio por compra** es el gasto total dividido por la cantidad de pedidos distintos, no el promedio de importes por renglón.

El importe `precio_unitario` está en `detalles_pedido` porque corresponde al precio efectivamente cobrado al momento de la operación. La tabla `productos` aporta la categoría.

#### Por qué usar HAVING y no WHERE

`WHERE` filtra filas **antes** de la agregación. `HAVING` filtra resultados **después** de agrupar (por número de compras y promedio calculado). Los umbrales son estrictos: una persona con exactamente tres compras o ticket de exactamente 50 **no** cumple el segmento.

### Resultados obtenidos con la muestra

| Métrica | Resultado |
| --- | --- |
| Total de clientes preservados | **12/12** |
| Clientes con cero compras | **3** (Diego, Gina y Laura) |
| Pedidos | **37** |
| Renglones de detalle | **39** |
| Clientes activos (> 3 pedidos y ticket > 50) | **5**: Ana, Elena, Fabio, Hugo y Jorge |
| Gasto total de Ana | **300**, sobre 4 pedidos (ticket promedio 75) |
| Ranking en Córdoba | Elena y Fabio empatan en puesto **1** |
| Ranking en Rosario | Hugo: **1**; Jorge: **2** |

El dataset también contempla casos límite: un pedido con múltiples renglones, un cliente con exactamente 3 compras, uno con promedio exactamente 50 y otros sin compras.

**Nota:** los importes son unidades monetarias ficticias y el comportamiento es de una muestra didáctica. La evidencia exacta de las ejecuciones está en `evidencia/resultado_ejecucion.txt`.

### Pruebas automáticas

`test_consultas.py` verifica 15 condiciones: integridad relacional, población completa, ceros, `COUNT(DISTINCT)`, features por categoría, umbrales estrictos, ticket por pedido, rankings/empates, categoría adicional, conciliación de importes y unicidad de filas por cliente.

### Buenas prácticas en una aplicación real

- Mantener el conteo de pedidos independiente de la cantidad de renglones.
- Controlar eventos como cancelaciones, devoluciones y monedas distintas, que no están en esta muestra.
- Definir una ventana temporal para las features y prevenir fuga de información al entrenar modelos.
- Validar que una categoría nueva no se contabilice automáticamente como Alimentos o Tecnología.
