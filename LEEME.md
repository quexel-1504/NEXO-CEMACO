# Fase 4: NEXO Omnicanal (aplicación web)

Prototipo académico del Proyecto Final de Bases de Datos I (UMG), basado en el caso Cemaco.

La aplicación es una "ventana" a la base de datos: **toda la lógica vive en Oracle**. Cada botón ejecuta un procedimiento almacenado o lee una vista creada en las fases 1, 2 y 3.

```
Navegador (React)  →  Servidor Node.js (Express + node-oracledb)  →  Oracle 21c XE (XEPDB1)
   lo que ve           solo arma parámetros y llama a Oracle         SP_CHECKOUT, vistas, triggers, job
```

> **¿Primera vez?** Siga el archivo `Manual_instalacion_NEXO.pdf` de esta misma carpeta: explica paso a paso cómo abrir el proyecto en Visual Studio Code y conectarlo a su Oracle.

## 1. Requisitos

| Requisito | Cómo verificarlo |
|---|---|
| Fases 1, 2 y 3 ejecutadas en Oracle (scripts 00 al 09) | En SQL Developer existen las tablas, procedimientos y la vista `V_LAB_BARBACOA` |
| Oracle XE encendido | La conexión CEMACO de SQL Developer funciona |
| **Node.js 22, 24 o 26** | En CMD: `node -v` debe mostrar v22.x, v24.x o v26.x. Si no lo tiene, descargue la versión LTS de nodejs.org |

No hace falta instalar Oracle Instant Client: `node-oracledb` trabaja en modo *Thin*.

## 2. Instalación (solo la primera vez)

1. Descomprima la carpeta `nexo-omnicanal` donde quiera, por ejemplo en `C:\Proyecto\nexo-omnicanal`.
2. Abra **CMD** dentro de esa carpeta y ejecute:
   ```
   copy backend\.env.example backend\.env
   npm run instalar
   ```
   - El primer comando crea el archivo de conexión con los datos de CEMACO (`cemaco` / `Cemaco2026` / `localhost:1521/XEPDB1`). Si su contraseña o puerto son distintos, edite `backend\.env` con el Bloc de notas.
   - El segundo descarga las librerías y compila la interfaz. Tarda de 1 a 3 minutos y solo se hace una vez.

## 3. Uso (cada vez)

1. En CMD, dentro de la carpeta, ejecute:
   ```
   npm start
   ```
2. Debe aparecer:
   ```
   Conectado a Oracle como CEMACO en XEPDB1 (localhost:1521/XEPDB1)
     NEXO Omnicanal listo  ->  http://localhost:3001
   ```
3. Abra **http://localhost:3001** en el navegador.
4. Deje esa ventana de CMD abierta mientras use la página. Para detener el servidor presione **Ctrl + C**.

## 4. Qué hace cada sección y qué objeto de Oracle usa

| Sección | Qué se puede hacer | Objetos de Oracle |
|---|---|---|
| **Inicio** | Presentación del proyecto, con contadores en vivo | Conteos de `PEDIDO`, `PRODUCTO` y `CLIENTE` |
| **Tienda** | Catálogo con stock por bodega, carrito multi-bodega, entrega a domicilio o Click & Collect, VisaNet, cuotas BAC, Puntos Privilegio y efectivo contra entrega. También reservar 15 minutos y pagar o cancelar la reserva | `SP_CHECKOUT`, `SP_CREAR_RESERVA`, `SP_CANCELAR_RESERVA`, `V_INVENTARIO_OMNICANAL` |
| **Caja** | Venta presencial en Z.10 o Peri-Roosevelt sobre el mismo inventario | `SP_CHECKOUT` (canal POS) |
| **Pedidos** | Lista y detalle, con productos por bodega, cobros con comisión y neto, despachos e historial de estados. Botones para avanzar, cobrar contra entrega y anular | `SP_AVANZAR_PEDIDO`, `SP_CONFIRMAR_PAGO_CE`, `SP_ANULAR_PEDIDO`, trigger de historial |
| **Inventario** | Existencias (físico, reservado, seguridad y disponible), reservas con cuenta regresiva y kardex | `V_INVENTARIO_OMNICANAL`, `V_RESERVAS`, `V_KARDEX`, job de reservas |
| **Gerencia** | Indicadores, ventas por mes y canal, la **vista gerencial por sucursal, canal de entrega y método de pago**, top 10 de productos, comisiones, conciliación y auditoría | `V_VENTAS_GERENCIAL`, `V_CONCILIACION_FINANCIERA`, `V_COMISIONES_PASARELA`, `V_AUDITORIA_INTEGRIDAD` |
| **Laboratorio** | Cyber Days (legacy vs. `FOR UPDATE`), estampida de 2 a 12 compradores simultáneos y crash test con fotografía antes y después | `SP_LAB_PREPARAR_BARBACOA`, `SP_LAB_CHECKOUT_LEGACY`, `SP_CHECKOUT` con `p_pausa_segundos` y `p_simular_fallo` |

## 5. Recorrido sugerido para la presentación o el video

1. **Inicio:** explique el diagrama (tres canales hacia una sola base de datos).
2. **Tienda:** haga una compra multi-bodega con cuotas y puntos. El comprobante muestra la comisión y el neto **calculados por Oracle**.
3. **Tienda (Click & Collect):** reserve, muestre la cuenta regresiva y luego la reserva en **Inventario → Reservas**.
4. **Laboratorio:**
   1. Presione "Dejar 1 barbacoa" y luego **Legacy** → aparece **Sobreventa**.
   2. Presione "Dejar 1 barbacoa" y luego **Nuevo (FOR UPDATE)** → aparece **Sin sobreventa**, con la franja amarilla que muestra cuánto esperó la caja.
   3. Ejecute la **Estampida** con 12 compradores: solo 1 compra.
   4. Ejecute el **Crash test**: todo queda en "✓".
5. **Gerencia:** muestre la vista gerencial y la **auditoría de integridad en verde**.

## 6. Opcional: monitor de bloqueos

En la prueba Cyber Days, la página puede mostrar la fotografía de `v$session` (quién bloquea a quién). Para eso, CEMACO necesita permiso de lectura:

```
sqlplus / as sysdba
@"C:\ruta\nexo-omnicanal\24_permisos_monitor.sql"
```

Sin este permiso todo funciona igual; solo aparece el aviso "Monitor de bloqueos no disponible".

## 7. Si algo sale mal

| Mensaje | Solución |
|---|---|
| `"node" no se reconoce como un comando` | Instale Node.js (versión LTS) y abra una ventana de CMD **nueva** |
| `No se pudo conectar con Oracle...` | Verifique que Oracle XE esté iniciado: abra SQL Developer y conéctese como CEMACO. Revise `ORACLE_CONNECT_STRING` en `backend\.env` |
| `ORA-01017 Usuario o contraseña incorrectos` | Corrija `ORACLE_PASSWORD` en `backend\.env` |
| `EADDRINUSE` (puerto ocupado) | Cambie `PORT=3002` en `backend\.env` y abra http://localhost:3002 |
| `Falta un objeto en la base de datos` | Falta ejecutar algún script de las fases 1, 2 o 3 (el Laboratorio necesita el 09) |
| La barbacoa aparece en 0 en el Laboratorio | Presione "Dejar 1 barbacoa en Z.10" |
| La página dice "Sin conexión" | La ventana de CMD con `npm start` se cerró o se detuvo. Vuelva a ejecutar `npm start` |

## 8. Estructura del proyecto

```
nexo-omnicanal/
├─ package.json                 comandos "instalar" y "start"
├─ 24_permisos_monitor.sql      permiso opcional para el monitor de bloqueos
├─ backend/                     servidor Node.js (API)
│  ├─ .env.example              datos de conexión a Oracle
│  └─ src/
│     ├─ server.js              arranque, rutas y manejo de errores
│     ├─ db.js                  pool de conexiones y traducción de errores ORA-
│     ├─ ventas.js              llamada a SP_CHECKOUT y SP_CREAR_RESERVA
│     └─ rutas/                 consultas, operaciones y laboratorio
└─ frontend/                    interfaz React 19 + TypeScript + Vite + Tailwind 4
   ├─ dist/                     interfaz ya compilada
   └─ src/paginas/              Inicio, Tienda, Caja, Pedidos, Inventario, Gerencia, Laboratorio
```

**Diseño.** Los titulares usan *Source Serif 4*, los textos *DM Sans* y las cifras *JetBrains Mono*. Las tres son tipografías libres (licencia SIL Open Font License) y vienen empaquetadas en el proyecto, así que la página se ve igual sin internet. Las ilustraciones son originales: dibujos SVG en `frontend/src/componentes/Arte.tsx`, con un filtro que imita el trazo a mano y una animación que los dibuja al hacer scroll.

**Seguridad.** El navegador nunca se conecta directo a Oracle. La contraseña vive solo en `backend\.env`, que está excluido del repositorio (`.gitignore`), y todos los valores viajan como *bind variables* (sin SQL armado con texto del usuario), lo que evita inyección SQL.
