const cds = require('@sap/cds');

// TODO EL CÓDIGO DEBE ESTAR DENTRO DE ESTE module.≈s
module.exports = cds.service.impl(async function() {
    // ========================================================================
    // TEMA 13.3 - PUNTO 56: Before - All Requests (El Guardián Global)
    // ========================================================================
    
    this.before('*', (req) => {
        // req.event = 'READ', 'CREATE', 'UPDATE', 'getCarDiscount', etc.
        // req.target.name = El nombre de la entidad o servicio afectado
        
        const evento = req.event;
        const destino = req.target ? req.target.name : 'Servicio Global';
        
        console.log(`🌍 [OJO DE SAURON] Interceptando TODO: Alguien intenta hacer '${evento}' en '${destino}'`);

        // ==========================================
        // CASOS DE USO EMPRESARIALES PARA ESTO:
        // ==========================================
        // 1. Auditoría: Guardar en una tabla de log quién, cuándo y qué intentó hacer.
        // 2. Seguridad: Verificar si el usuario tiene el rol adecuado globalmente.
        // 3. Inyección: Forzar un parámetro (ej. req.data.idioma = 'ES').
        
        // Si detectáramos un ataque aquí, un simple req.error(403, "¡Prohibido!") 
        // bloquearía absolutamente todo el backend de un solo golpe.
    });

// ========================================================================
    // TEMA 14.2: DELEGACIÓN A UN SERVICIO EXTERNO (Northwind)
    // ========================================================================
    
    // 1. Conectamos nuestro backend con la API externa usando el nombre que está en el package.json
    const apiNorte = await cds.connect.to('Northwind');

    // 2. Interceptamos la lectura de nuestra entidad proyectada
    this.on('READ', 'ProductosNorte', async (req) => {
        console.log("✈️ [VIAJE EXTERNO] Yendo a Northwind a buscar los ProductosNorte...");
        
        // Simplemente tomamos la petición original (req.query) y se la "pasamos" a Northwind.
        // Northwind hará el trabajo duro y nos devolverá los datos.
        return apiNorte.run(req.query);
    }); 
    
    // ========================================================================
    // TEMA 14.6: ENHANCEMENT (Ampliando los datos externos)
    // ========================================================================
    // Evento AFTER: Modificamos el payload (los datos) que regresó de Northwind
    this.after('READ', 'ProductosNorte', (productos) => {
        
        // Precaución de Arquitecto: Si consultamos por ID, llega un solo objeto.
        // Si consultamos toda la lista, llega un arreglo. Lo normalizamos.
        const arregloProductos = Array.isArray(productos) ? productos : [productos];

        // Recorremos los registros
        for (let producto of arregloProductos) {
            // Evaluamos la lógica de negocio basada en el precio externo
            if (producto.precioUnitario > 30) {
                producto.mensajePromocional = "🌟 ¡Producto Premium VIP!";
            } else {
                producto.mensajePromocional = "✅ Económico y accesible";
            }
        }
    });

    // --------------------------------------------------------
    // TEMA 12 - PUNTO 48: ON READ con Filtros Dinámicos
    // --------------------------------------------------------
    this.on('READ', 'ProductosPublicos', async (req) => {
        console.log("⚡ [DIOS CAP] Leyendo ProductosPublicos CON FILTROS!");
        try {
            let aProductos = await cds.run(req.query);

            const isArray = Array.isArray(aProductos);
            const productosIterables = isArray ? aProductos : [aProductos];

            productosIterables.forEach(producto => {
                if(producto && producto.nombreProducto) {
                    producto.nombreProducto = producto.nombreProducto + ' (Filtro Respetado)';
                }
            });
            return isArray ? productosIterables : productosIterables[0];
        } catch (error) {
            req.error(500, `Error divino: ${error.message}`);
        }
    });

    // --------------------------------------------------------
    // TEMA 12 - PUNTO 49: AFTER READ (Intercepción Post-Base de Datos)
    // --------------------------------------------------------
    this.after('READ', 'car', (each) => {
        console.log(`[DIOS CAP] Interceptando el auto en el AFTER: ${each.name}`);

        // 1. Llenamos el campo virtual 'discount_1'
        each.discount_1 = 500.00; 

        // 2. Modificamos el nombre real
        if (each.name) {
            each.name = each.name + ' (Tuneado con AFTER)';
        }
    });

// ========================================================================
    // TEMA 12 - OTRO EJEMPLO DE AFTER: Enmascaramiento de Datos (Seguridad)
    // ========================================================================
    
    this.after('READ', 'Supplier', (each) => {
        
        // 1. Verificamos si el registro actual tiene un email
        if (each.email) {
            
            // 2. Partimos el email en dos: antes y después del '@'
            // Ejemplo: 'juan.perez@sap.com' -> partes[0] = 'juan.perez', partes[1] = 'sap.com'
            let partes = each.email.split('@');
            
            if (partes.length === 2) {
                let nombre = partes[0];
                let dominio = partes[1];
                
                // 3. Tomamos solo la primera letra del nombre
                let primeraLetra = nombre.charAt(0);
                
                // 4. Reescribimos el email en memoria antes de que salga hacia el usuario
                each.email = primeraLetra + '***@' + dominio;
            }
        }
        
        // También podemos agregar un mensaje de advertencia si no tiene teléfono
        if (!each.phone) {
            each.phone = "SIN TELÉFONO REGISTRADO";
        }
    });    

    // ========================================================================
    // TEMA 12 - PUNTO 50: ON CREATE (Sobrescribiendo la inserción de datos)
    // ========================================================================
    
    this.on('CREATE', 'car', async (req) => {
        console.log("⚡ [DIOS CAP] Interceptando la creación de un nuevo Auto!");

        // 1. EXTRAER EL PAYLOAD: 
        // El JSON que el usuario envía en el cuerpo (body) del POST llega 
        // empaquetado dentro de la propiedad mágica 'req.data'
        const oNuevoAuto = req.data;

        // 2. LÓGICA / VALIDACIÓN PREVIA (Ejemplo simple)
        if (!oNuevoAuto.name) {
            // Si el usuario no envía un nombre, cancelamos la operación con un error
            return req.error(400, "El nombre del auto es obligatorio para el Dios de CAP");
        }

        try {
            // 3. CONSULTA CQL EMBEBIDA DE INSERCIÓN
            // Usamos la API fluida de CAP: INSERT.into(Entidad).entries(ObjetoJSON)
            // Esto equivale a un: INSERT INTO CatalogService_car VALUES (...)
            let resultado = await INSERT.into('car').entries(oNuevoAuto);
            
            console.log("✅ Auto guardado con éxito vía CQL Embebido");

            // OBLIGATORIO: En un evento 'ON CREATE', debes retornar el objeto 
            // que se acaba de crear (o req.data), para que el protocolo OData 
            // responda con el código HTTP 201 Created y muestre el registro guardado.
            return oNuevoAuto;

        } catch (error) {
            req.error(500, `Error divino al insertar el auto: ${error.message}`);
        }
    });

   // ========================================================================
    // TEMA 12 - PUNTO 51: Evento BEFORE (El Guardia de Seguridad)
    // ========================================================================
    
    this.before('CREATE', 'car', (req) => {
        console.log("🛡️ [GUARDIA] Revisando el nuevo auto...");

        const datosDelUsuario = req.data;

        // 1. EL VETO (Validación)
        // Rechazamos cualquier auto que se llame literalmente "X"
        if (datosDelUsuario.name === "X") {
            console.log("❌ [GUARDIA] Auto rechazado por nombre inválido.");
            
            // req.error aborta toda la operación y devuelve HTTP 400
            req.error(400, "El nombre 'X' es demasiado corto y no está permitido en esta base de datos.");
            return; 
        }

        // 2. LA TRANSFORMACIÓN (Limpieza)
        // Si no fue rechazado, forzamos a que el nombre se guarde en MAYÚSCULAS.
        if (datosDelUsuario.name) {
            datosDelUsuario.name = datosDelUsuario.name.toUpperCase();
            console.log(`✨ [GUARDIA] Nombre transformado a: ${datosDelUsuario.name}`);
        }
    });

    // ========================================================================
    // TEMA 12 - PUNTO 52: ON UPDATE (Sobrescribiendo la actualización)
    // ========================================================================
    
    this.on('UPDATE', 'car', async (req) => {
        console.log("✏️ [DIOS CAP] Interceptando la actualización del Auto!");

        // 1. Extraemos los datos que el usuario quiere modificar
        const datosAActualizar = req.data;

        // 2. LÓGICA DE NEGOCIO (Ejemplo de veto en el ON)
        // Imagina que por reglas de negocio, no permitimos que a un auto
        // se le ponga la marca "FIAT" porque somos una concesionaria de lujo.
        if (datosAActualizar.name && datosAActualizar.name.toUpperCase() === "FIAT") {
            req.error(400, "Error de prestigio: No aceptamos autos FIAT en esta base de datos.");
            return;
        }

        try {
            // cds.run(...): Es el mensajero. Toma ese objeto, lo traduce al lenguaje exacto de tu base de datos (SQLite en este momento, o HANA en producción), viaja a la base de datos y ejecuta la sentencia.
            let registrosActualizados = await cds.run(req.query);
            
            // LA NUEVA VALIDACIÓN: Si la BD nos dice que afectó 0 filas, el ID es fantasma.
            if (registrosActualizados === 0) {
                // 404 es el código HTTP estándar para "Not Found" (No Encontrado)
                req.error(404, "Operación cancelada: El ID del auto no existe en la base de datos.");
                return;
            }
            
            console.log(`✅ Se actualizó ${registrosActualizados} auto(s) con éxito.`);
            return registrosActualizados;

        } catch (error) {
            req.error(500, `Error divino al modificar el auto: ${error.message}`);
        }
    });

    // ========================================================================
    // TEMA 12 - PUNTO 53: ON DELETE (Destrucción controlada)
    // ========================================================================
    
    this.on('DELETE', 'car', async (req) => {
        console.log("🧨 [DIOS CAP] Interceptando la orden de destrucción del Auto!");

        try {
            // Ejecutamos la consulta DELETE que CAP ya construyó en req.query
            let registrosBorrados = await cds.run(req.query);
            
            // Validamos si realmente se borró algo en la base de datos física
            if (registrosBorrados === 0) {
                req.error(404, "Destrucción cancelada: El auto no existe o ya fue borrado antes.");
                return;
            }
            
            console.log(`✅ Se eliminó ${registrosBorrados} auto(s) permanentemente.`);
            
            // Para el DELETE, devolvemos el número de filas afectadas
            return registrosBorrados;

        } catch (error) {
            req.error(500, `Error divino al intentar borrar el auto: ${error.message}`);
        }
    });   
    
    // ========================================================================
    // ========================================================================
    // TEMA 13 - PUNTO 54: Funciones (Lógica personalizada de Solo Lectura)
    
    this.on('getCarDiscount', (req) => {
        console.log("🧮 [FUNCIÓN] Calculando descuento personalizado...");

        // 1. Capturamos los parámetros que envió el usuario en la URL
        const marca = req.data.brand;

        // 2. Lógica de negocio personalizada (No tocamos la base de datos para esto)
        if (marca.toUpperCase() === 'BATIMOVIL') {
            return 50; // 50% de descuento para Bruce Wayne
        } else if (marca.toUpperCase() === 'FIAT') {
            return 0; // Sin descuento
        } else {
            return 10; // 10% de descuento por defecto para las demás marcas
        }
    });

    // ========================================================================
    // TEMA 13.2 - PUNTO 55: Acciones (Lógica de Escritura / Procesos)
    // ========================================================================
    
    this.on('solicitarAutoEspecial', async (req) => {
        // En un POST, los parámetros vienen protegidos dentro de req.data
        const marcaSolicitada = req.data.marca;
        
        console.log(`🏭 [ACCIÓN] Iniciando proceso de fabricación en la planta para un ${marcaSolicitada}...`);

        // Aquí en la vida real un Arquitecto pondría código para: 
        // 1. Hacer un INSERT manual a una tabla de auditoría.
        // 2. Consumir una API externa de una fábrica.
        // 3. Enviar un correo electrónico al gerente.
        
        // Retornamos un mensaje de confirmación al cliente
        return `¡Éxito! El pedido especial para el auto ${marcaSolicitada} ha sido enviado a la fábrica central.`;
    });


    // ========================================================================
    // TEMA 13.4 - PUNTO 57: Funciones y Acciones VINCULADAS (Bound) + VALIDACIÓN
    // ========================================================================
    
    // 1. FUNCIÓN VINCULADA (GET)
    this.on('consultarStockFisico', 'car', async (req) => {
        // Extraemos el ID correctamente del objeto JSON
        const idAuto = req.params[0].ID || req.params[0].id;
        
        // 🛡️ VALIDACIÓN CONTRA LA BASE DE DATOS
        // Buscamos 1 solo registro en la tabla 'car' que coincida con este ID
        let autoReal = await SELECT.one.from('car').where({ id: idAuto });
        
        if (!autoReal) {
            // Si autoReal viene vacío, abortamos la misión
            return req.error(404, `¡Error 404! El auto con ID ${idAuto} no existe en nuestra bodega.`);
        }

        // Si pasó la validación, ejecutamos la lógica normal
        console.log(`📦 [FUNCIÓN VINCULADA] Consultando stock físico para el auto ID: ${idAuto}`);
        return 3; 
    });

    // 2. ACCIÓN VINCULADA (POST)   
    this.on('marcarComoVendido', 'car', async (req) => {

        console.log(`🔍 [INSPECCIÓN] Verbo HTTP: ${req.method}`);
        console.log(`🔍 [INSPECCIÓN] Evento llamado: ${req.event}`);

        const idAuto = req.params[0].ID || req.params[0].id;
        
        // 🛡️ VALIDACIÓN CONTRA LA BASE DE DATOS
        let autoReal = await SELECT.one.from('car').where({ id: idAuto });
        
        if (!autoReal) {
            return req.error(404, `¡Operación Cancelada! No puedes vender un fantasma. El auto ${idAuto} no existe.`);
        }

        const comprador = req.data.comprador;
        console.log(`🤝 [ACCIÓN VINCULADA] Vendiendo el auto ${idAuto} a ${comprador}...`);
        
        return `¡Felicidades ${comprador}! El auto con ID ${idAuto} ahora te pertenece.`;
    });

}); // <-- ¡AQUÍ TERMINA LA FUNCIÓN PRINCIPAL! 





