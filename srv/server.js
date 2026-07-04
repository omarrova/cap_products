
// 14.8. DOTENV - Carga las variables del archivo .env en el proceso de Node.js
require('dotenv').config();
//const graphql = require('@cap-js/graphql');
const cds = require('@sap/cds');
// 1. 14.4. CORS . NUEVO: Importamos la librería que acabamos de instalar
const cors = require('cors');

// 1. 14.7 .NUEVO: Importamos el Traductor OData V2
const proxy = require('@sap/cds-odata-v2-adapter-proxy');

// ========================================================================
// TEMA 14.3: CAP SERVER BOOTSTRAP (Interceptando el Arranque)
// ========================================================================


// EVENTO 1: 'bootstrap'
// Ocurre justo cuando el servidor Express de Node.js se crea, pero ANTES de
// que se lean los arc
// Aquí 'app' es la aplicación Express desnuda. ¡Podemos inyectarle lo que sea!
cds.on('bootstrap', (app) => {

    console.log("🚀 [BOOTSTRAP] Encendiendo los motores principales del servidor...");

   // 14.7 Accedemos a la variable de entorno
    console.log("🔐 [SEGURIDAD] Mi secreto es: " + process.env.MI_API_KEY_SECRETA);

    // ========================================================================
    // TEMA 14.4: CORS (Permiso VIP para Frontends externos)
    // ========================================================================
    // 2. NUEVO: Le decimos a la app de Express que use el middleware CORS
    // Al dejar los paréntesis vacíos cors(), estamos diciendo: "Permite que CUALQUIER puerto o dominio entre".
    app.use(cors());

    /* NOTA DE ARQUITECTO PARA PRODUCCIÓN:
    En un banco o empresa real, nunca dejarías la puerta abierta a todo el mundo.
    Lo configurarías así para que solo tu Fiori pueda entrar:
    app.use(cors({ origin: 'http://midominio-fiori.com' }));
    */

    // ========================================================================
    // TEMA 14.7: OData Adapter Proxy (Traductor V4 <-> V2)
    // ========================================================================
    // 2. NUEVO: Le inyectamos el traductor a nuestra aplicación
    app.use(proxy());


    // 1. Podemos inyectar un "Middleware" global de Express
    app.use((req, res, next) => {
        console.log(`📡 [EXPRESS] Petición entrante cruda a la ruta: ${req.url}`);
        next(); // Siempre llamar a next() para que siga el flujo normal
    });


    // 2. Podemos crear un endpoint REST puro (NO OData)
    // Esto es súper útil para crear "Health Checks" o webhooks simples
    app.get('/api/ping', (req, res) => {
        res.status(200).send("¡PONG! El servidor CAP está vivo y coleando.");
    });
});


// EVENTO 2: 'served'
// Ocurre DESPUÉS de que todos los archivos .cds se cargaron y compilaron.
// Aquí todos tus servicios (CatalogService, MyService) ya están montados.
cds.on('served', (servicios) => {
    console.log("✅ [BOOTSTRAP] Los menús (.cds) han sido cargados. Todo listo.");
    // Podemos ver qué servicios se cargaron realmente
    // for (let nombreServicio in servicios) {
    // console.log(` -> Servicio montado: ${nombreServicio}`);
    // }
});

// OBLIGATORIO: Devolver el control al motor interno de CAP para que termine de arrancar
module.exports = cds.server;