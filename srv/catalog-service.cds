using {com.omrv as omrv} from '../db/schema';
using {com.training as training} from '../db/training'; // 35. Using

// IMPORTAMOS EL SERVICIO EXTERNO (NUEVO)
using { Northwind } from './external/Northwind'; 

// ========================================================================
// TEMA 14.5: SERVICE IMPLEMENTATION
// ========================================================================
git v// La anotación @impl fuerza a CAP a buscar el JavaScript en la ruta que tú le digas.
@impl: './mi-logica-custom.js'

// ========================================================================
// MODO ENTERPRISE: Dejamos las rutas limpias para evitar conflictos con Express
// ========================================================================
service CatalogService {

    // ========================================================================
    // TEMA 14.2: Exponiendo un Servicio Externo (Northwind)
    // ========================================================================
    // Hacemos una proyección de SOLO LECTURA hacia la tabla Products de Northwind
    @readonly
    entity ProductosNorte as projection on Northwind.Products {
        key ProductID as ID, // <-- CORREGIDO: OData exige que se marque la llave
        ProductName as nombreExterno,
        UnitPrice as precioUnitario,
        // ========================================================================
        // TEMA 14.6: ENHANCEMENT (Ampliando los datos externos)
        // ========================================================================
        // ENHANCEMENT: Campo Virtual (Fantasma) calculado en el Backend
        virtual null as mensajePromocional: String(100)
    };
        
    entity Supplier as projection on omrv.supplier;
    @odata.draft.enabled
    // Modificamos la entidad car para agregarle sus acciones vinculadas
    entity car as projection on omrv.car actions {
        // Función vinculada (GET): Sirve para leer datos específicos de ESTE auto
        function consultarStockFisico() returns Integer;
        
        // Acción vinculada (POST): Sirve para modificar el estado de ESTE auto
        action marcarComoVendido(comprador: String) returns String;
    };

    entity sel_products as projection on omrv.sel_products;
    entity Productos2 as projection on omrv.Productos2;

    entity ProductosPublicos as select from omrv.Productos2 {  // 36. Servicios – Definición con Select
        // 1. Exponemos la llave (Obligatorio)
        ID,
        // 2. Renombramos el campo usando 'as' (Aliasing)
        descripcion as nombreProducto,
        // 3. Exponemos el precio tal cual
        precioVenta,
        // 4. Podemos hacer cálculos o transformaciones al vuelo
        (precioVenta - 2) as precioConDescuento : Decimal(10,2)
        // ¡OJO! Ignoramos por completo el 'costoInterno' y el 'stockActual'
    } 
    // 5. Podemos añadir una condición WHERE a nivel de servicio
    where precioVenta > 0;    

    @readonly //  @readonly prohíbe hacer POST, PUT, PATCH o DELETE //  37. Servicios – Anotaciones
    entity Categorias as projection on omrv.categories;

    entity products as select from omrv.MasterData.product {
        ID,
        description as productName @mandatory , //37. Servicios – Anotaciones
        price @mandatory // 37. Servicios – Anotaciones
    };

    // TEMA 38: Proyección Postfix Básica
    // Fíjate cómo la tabla va PRIMERO, y los campos DESPUÉS entre llaves
    entity ProductosPostfix as select from omrv.MasterData.product {
        ID,
        name as nombreProducto, // Podemos usar alias directamente aquí
        price,
        description
    };

    // TEMA 38: Proyección Postfix con Excluding
    // El asterisco trae todo, pero el excluding elimina lo que no queremos exponer
    entity ProductosSeguros as select from omrv.Productos2 {
        *
    } excluding { 
        costoInterno, 
        stockActual 
    };

    entity products_completo as select from omrv.MasterData.product {
        ID,
        name,
        description,
        imageurl,
        releaseDate,
        creationDate,
        discontinuedDate,
        price,
        heightt,
        width,
        depth,
        quantity,
        supplier,
        unitofmeasure,
        currency,
        dimensionunit,
        category
    };

    entity products_completo2 as select from omrv.MasterData.product {
        *,  //  39. Selector - Inteligente
        width,
        depth,
        quantity,
        supplier,
        unitofmeasure,
        currency,
        dimensionunit,
        category
    };

    // TEMA 39: Selector Inteligente (Anidamiento de proyecciones)
    entity PedidosCompletos as select from omrv.purchase_order {
        key id,
        // 1. Traemos los campos directos de la cabecera
        orderNumber,
        orderDate,
        
        // 2. EL SELECTOR INTELIGENTE: 
        // Navegamos por la asociación 'supplier' y abrimos nuevas llaves
        supplier {
            name as nombreProveedor, // Podemos dar alias dentro del sub-nivel
            country
        }  
    };

    //39: Selector Inteligente
    entity PedidosPlanos as select from omrv.purchase_order {
        key id,
        orderNumber,
        // En lugar de abrir llaves, navegamos con un punto
        supplier.name as nombreProveedor,
        supplier.country as paisProveedor
    };
    
    // 40. Expresiones de Ruta o FIX
    entity SupplierProduct as select from omrv.MasterData.product[name = 'Laptop'] {
        key ID,
        name as nombreProducto, 
        price,
        description
    } where supplier.postalcode = '1234'; // CORREGIDO: El codigo postal es String en CSV, va entre comillas
    
    // TEMA 40: Expresiones de Ruta
    entity ReportePedidosPlanos as select from omrv.purchase_order {
        key id,
        orderNumber,
        status,
        
        // EXPRESIÓN DE RUTA: Navegamos con un punto hacia el proveedor
        supplier.name as proveedor_nombre,
        supplier.city as proveedor_ciudad
    };

    // 54. Funciones - TEMA 13.1: Declaración de una Función personalizada
    function getCarDiscount(brand: String) returns Integer;

    // 55. Acciones - TEMA 13.2: Declaración de una Acción (Escritura / POST)
    action solicitarAutoEspecial(marca: String) returns String;    


    
}


define service MyService {

    // 40. Expresiones de Ruta o FIX
    entity SupplierProduct2 as select from omrv.MasterData.product[name = 'Laptop'] {
        key ID,
        name as nombreProducto, 
        price,
        description
    };

    entity supplierstotal as select from omrv.MasterData.product {
        ID,
        supplier.email,
        category.name
    };

    // TEMA 41: Infix en la entidad raíz
    // CORRECCIÓN APLICADA: Mapeo exacto usando key ID en mayúsculas de cuid
    entity SoloLaptops as select from omrv.MasterData.product[name = 'Laptop'] {
        key ID,
        name,
        price
    };

    // TEMA 41: Infix en medio de una Expresión de Ruta
    // CORRECCIÓN APLICADA: Forzada lectura explícita con key id
    entity ReporteUSA as select from omrv.purchase_order {
        key id,
        orderNumber,
        // Ponemos el corchete justo después de supplier y antes del punto
        supplier[country = 'USA'].name as nombreProveedorGringo
    };

    // TEMA 42: Agrupaciones y Sumas
    // CORRECCIÓN APLICADA: Clave primaria inyectada y group by corregido con todos los campos no agregados
    entity ValorTotalPorPedido as select from omrv.purchase_order_item {
        key purchaseOrder.id as id,
        // 1. Campo NO agregado (El eje X del gráfico) -> Navegamos con expresión de ruta
        purchaseOrder.orderNumber as numeroPedido,
        // 2. Campo AGREGADO (El eje Y del gráfico) -> Función sum() con cálculo interno
        sum(quantity * netPrice)  as valorTotal : Decimal(16, 2)
    }
    group by purchaseOrder.id, purchaseOrder.orderNumber; // ¡Obligatorio agrupar por ambos campos no agregados!
        
    // TEMA 42: Agrupaciones y Sumas
    entity EstadisticasPorCategoria as select from omrv.MasterData.product {
        // 1. Campo NO agregado (Agrupador)
        key category.name as nombreCategoria, // <-- CORREGIDO: Marcado como key para OData
        // 2. Función count() -> Cuenta cuántos IDs (productos) hay
        count(ID)     as totalProductos : Integer,
        // 3. Función avg() -> Saca el promedio aritmético del precio
        avg(price)    as precioPromedio : Decimal(10, 2)
    }
    group by category.name;

    // Solo proyectas lo que la base de datos ya calculó y preparó
    entity ProductosOData as projection on omrv.reports.ViewProductosConDescuento;   

    // TEMA 43: Mixins (Asociaciones inyectadas al vuelo)
    entity ProductosConResenas as select from omrv.MasterData.product 
    mixin {
        resenasInyectadas : Association to many omrv.productreview 
                                on resenasInyectadas.name = $projection.nombreProducto;
    } 
    into {
        ID,
        name as nombreProducto,
        price,
        resenasInyectadas
    };

    entity ProductosConResenas2 as projection on omrv.reports.ViewProductosConResenasGlobal;
    entity PedidosValidos as projection on omrv.reports.ViewPedidosConDetalle;
    entity PedidosVIP     as projection on omrv.reports.ViewPedidosVolumenAlto;
}


// ========================================================================
// TEMA 14.9: PROTOCOLO REST PURO (Minimalista)
// ========================================================================
// La anotación @protocol: 'rest' apaga toda la maquinaria de OData
@protocol: 'rest'
service RestService {
    
    // Exponemos la tabla de autos de forma cruda, sin metadatos
    entity AutosCrudos as projection on omrv.car;
    
}

