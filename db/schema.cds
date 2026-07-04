// gitlens: toggle git codelens
// CONTROL + K  + C 
namespace com.omrv;


using { cuid , managed } from '@sap/cds/common'; // video 27 -  30. Common – Cuid

define type Name     : String(20); // tipos poersonalizados.


// 17 Enumeraciones
type genero          : String enum {
    male;
    female;
};

type Order {
    clientgender : genero; // tipo de daos enumerados
    estado       : Integer enum { // tipo de daos enumerados,
        submitted = 0; // tipo de daos enumerados,
        fullfiller = 1; // tipo de daos enumerados,
        shipped = 2; // tipo de daos enumerados,
        cancelled = 3; // tipo de daos enumerados,
    };
    priority     : String @assert.range enum {  //  @assert.range enum  valida los valores ingresados, si no se cumple la validacion se genera un error.
        high;
        medium;
        low;
    }
};


// 14...tipo de datos estructurados, se pueden usar en varias entidades.
type str_address {
    street     : String;
    city       : String;
    state      : String;
    postalcode : String;
    country    : String;
};




// 15.. tipo de datos matriz, se pueden usar en varias entidades.
type EmailAddress_01 : array of {
    kind  : String;
    email : String;
};

// 15.. 
type EmailAddress_02 {
    kind  : String;
    email : String;
}


// 15.. 
entity Emails {
    email_01 : EmailAddress_01;
    email_02 : many EmailAddress_02;
    email_03 : many {
        kind  : String;
        email : String;
    };
}

entity customer {
    key id    : Integer;
        name  : String;
        email : String;
};

// 16.. tipo de datos por referencia, 
type type_dec        : Decimal(16, 2);


 // 20. Elementos Virtuales
entity car {
    key id                 : UUID;
        name               : String;
        virtual discount_1 : Decimal;
        @Core.Computed: false
        virtual discount_2 : Decimal;
        supplier       : Association to supplier; //Asociaciones  administradas // 15.3
};

context MasterData { // 34. Context

entity product : cuid, managed {  // 31. Common – Managed
    //key id               : UUID;
        name             : localized String default 'no name'; // 18. Valores predeterminados
        description      : localized String not null; // 19. Restricciones
        imageurl         : String;
        releaseDate      : DateTime default $now; // 18. Valores predeterminados
        creationDate     : DateTime default current_date; // 18. Valores predeterminados
        discontinuedDate : Date;
        //price            : Decimal(10, 2);
        price            : type_dec; // tipo de datos por referencia
        //height           : Decimal(10, 2);
        heightt          : type of price; // tipo de datos por referencia
        width            : Decimal(10, 2);
        @mandatory
        depth            : Decimal(10, 2);
        quantity         : Decimal(10, 2);
        supplier       : Association to supplier; //Asociaciones  administradas
        unitofmeasure  : Association to unitofmeasures; //Asociaciones  administradas
        currency       : Association to Currency; //Asociaciones  administradas
        dimensionunit  : Association to dimensionunit; //Asociaciones  administradas
        category       : Association to categories; //Asociaciones  administradas
};
}

entity supplier {
    key id         : UUID;
        //name       : String;
        name       : type of MasterData.product : name; // tipo de datos por referencia
        street     : String;
        city       : String;
        state      : String;
        postalcode : String;
        country    : String;
        email      : String;
        phone      : String;
        fax        : String;
};


entity supplier01 {
    key id      : UUID;
        name    : String;
        address : str_address;
        email   : String;
        phone   : String;
        fax     : String;
};


entity supplier02 {
    key id        : UUID;
        name      : String;
        AddressIn : {
            street     : String;
            city       : String;
            state      : String;
            postalcode : String;
            country    : String;
        };
        email     : String;
        phone     : String;
        fax       : String;
};

entity categories {
    key id   : String(1);
        name : localized String; // video 32 - 32. Common – Localized
};

entity stockavailability {
    key Id          : Integer;
        description : localized String; // video 32 - 32. Common – Localized
};

entity Currency {
    key id          : String(3);
        description : String;
};


entity unitofmeasures {
    key id          : String(3);
        description : String;
};

entity dimensionunit {
    key id          : String(2);
        description : String;
};

entity months {
    key id               : String(2);
        description      : String;
        shortdescription : String;
};

entity productreview {
    key name    : String;
        rating  : Integer;
        comment : String;
};

entity salesdata {
    key id           : UUID;
        daleveeydate : DateTime;
        revenue      : Decimal(16, 2);
};

// 21. entidad select
entity sel_products as select from MasterData.product {
    ID,
    name,
    price
};

// 22. entidad de proyeccion
entity pro_products as projection on MasterData.product ;

entity pro_products_02 as projection on MasterData.product {
    *
}

entity pro_products_03 as projection on MasterData.product {
    ID,
    name,
    price
};

// 23. Entidades con Parámetros
// entity para_products_04(pname : String) as 
// select 
//     ID,
//     name,
//     price
//     from MasterData.product 
//  where name = :pname;



// =======================================================
// VIDEO 25 - 25  EJEMPLO: Asociaciones NO administradas
// =======================================================

entity product_supplier_assignment {
    key id          : UUID;

        product_id  : UUID;
        supplier_id : UUID;

        quantity    : Decimal(10, 2);
        validFrom   : Date;
        validTo     : Date;

        // Asociación NO administrada hacia product
        product     : Association to MasterData.product
                          on product.ID = product_id;

        // Asociación NO administrada hacia supplier
        supplier    : Association to supplier
                          on supplier.id = supplier_id;
};



// =======================================================
// VIDEO 24 - 26  EJEMPLO: Asociaciones  administradas
// =======================================================

entity purchase_order {
    key id          : UUID;
        orderNumber : String(20);
        orderDate   : Date;
        status      : String;

        // Asociación administrada hacia supplier
        supplier    : Association to supplier;

// NUEVO: Asociación to-many hacia los items
        items       : Association to many purchase_order_item
                          on items.purchaseOrder = $self; //  27. Asociaciones Many
};


entity purchase_order_item {
    key id              : UUID;
        quantity        : Decimal(10, 2);
        netPrice        : Decimal(16, 2);
        // Asociación administrada hacia purchase_order
        purchaseOrder   : Association to purchase_order;

        // Asociación administrada hacia product
        product         : Association to MasterData.product;
};



// =======================================================
// video 26 -  24. Entidades .. EAMPLIACION DE ENTIDADES - EXTENDS   
// =======================================================

extend MasterData.product with {
    priceconditions : String;
    pricedetermination : String;
}


// VIDEO  29  - 28. Asociaciones Many to many
// 1. ENTIDAD PADRE A
entity Employees : cuid {
    name     : String(100);
    role     : String(50);
    
    // El empleado no apunta directo al proyecto, apunta a la tabla intermedia
    projects : Association to many Employee_ProjectAssignment 
                   on projects.employee = $self;
}

// 2. ENTIDAD PADRE B
entity Projects : cuid {
    name        : String(100);
    budget      : Decimal(16,2);
    
    // El proyecto no apunta directo al empleado, apunta a la tabla intermedia
    employees   : Association to many Employee_ProjectAssignment 
                      on employees.project = $self;
}

// 3. LA TABLA INTERMEDIA (La magia de la resolución M:N)
entity Employee_ProjectAssignment {
    // Definimos las claves foráneas como la Clave Primaria Compuesta de esta tabla
    key employee  : Association to Employees;
    key project   : Association to Projects;
    
    // Opcional: Atributos que solo tienen sentido en la intersección de ambos
    assignedHours : Integer;     // ¿Cuántas horas le dedica este empleado a este proyecto?
    assignmentDate: Date default $now;
}


// VIDEO 28 - 29. Composiciones 
// ENTIDAD PADRE (ROOT)
entity SalesOrders : cuid {
    orderNumber : String(10);
    customer    : String(50);
    totalAmount : Decimal(16,2);
    
    // COMPOSICIÓN: El pedido "es dueño" de sus posiciones
    items       : Composition of many SalesOrderItems 
                      on items.parent = $self;
}

// ENTIDAD HIJA (NODE)
entity SalesOrderItems : cuid {
    // La relación de vuelta sigue siendo una Association normal
    parent      : Association to SalesOrders;
    
    itemNumber  : Integer;
    productID   : String(20);
    quantity    : Integer;
    netPrice    : Decimal(16,2);
}





// =======================================================
// CONTEXTO 1: Datos Maestros (Master Data)  // 34. Context
// =======================================================
context MasterData2 {
    
    entity Customer2 : cuid, managed {
        name  : String;
        email : String;
    }

    entity Product2 : cuid {
        name  : String;
        price : Decimal(10,2);
    }
}

// =======================================================
// CONTEXTO 2: Datos Transaccionales (Transactions) // 34. Context
// =======================================================
context Transactions {
    
    entity SalesOrder : cuid, managed {
        orderNumber : String;
        // Así llamas a una entidad que está en otro contexto del mismo namespace
        customer    : Association to MasterData2.Customer2;
        status      : String enum { Open; Closed; };
    }
}


entity Productos2 : cuid {
    codigoBarras : String(20);
    descripcion  : String(100);
    precioVenta  : Decimal(10,2);
    costoInterno : Decimal(10,2); // ¡Peligro! Campo confidencial
    stockActual  : Integer;
};


context reports {

    entity ViewProductosConDescuento as
        select from MasterData.product {
            ID,
            name as nombreProducto,
            price,
            // Cálculo centralizado para que todos los servicios calculen el descuento igual
            (price - 2 ) as precioConDescuento : Decimal(10, 2)
        }
        where  price > 5; // Filtro base de datos



    // TEMA 42: Agrupaciones y Sumas
    entity average                   as
        select from omrv.MasterData.product {
            product.ID    as productID,
            //avr(quantity) as averageRating : Decimal(10, 2)
            avg(quantity) as averageRating : Decimal(10, 2)
        }
        group by
            product.ID;

// =======================================================
    // TEMA 43: Mixin Global en la Capa de Persistencia (DB)
    // =======================================================

    // Creamos una entidad tipo VISTA que cualquier servicio podrá reutilizar
    entity ViewProductosConResenasGlobal as
        select from MasterData.product

        // 1. Inyectamos la asociación al vuelo en la base de datos
        mixin {
            // Relación hacia tu entidad 'productreview'
            resenasDB : Association to many productreview
                            on resenasDB.name = $projection.nombreProducto;
        }
        // 2. Proyectamos los campos hacia la vista
        into {
            ID,
            name as nombreProducto, // Alias obligatorio para el cruce del $projection
            price,
            description,
            imageurl,
            // 3. Exponemos la asociación inyectada como un campo más de la vista
            resenasDB
        };



// TEMA 44: Casting clásico con la función cast()
    entity ProductosCastTexto            as
        select from omrv.MasterData.product {
            ID,
            name as nombreProducto,
            // Convertimos el Decimal a un String de 20 caracteres
            cast(
                price as String(20)
            )    as precioComoTexto
        };

    // TEMA 44: Casting moderno (Shorthand) para cálculos
    entity ValorDelInventario            as
        select from omrv.MasterData.product {
            ID,
            name,
            price,
            quantity,
            // Hacemos el cálculo y FORZAMOS el tipo de salida a Decimal(16,2)
            (
                price * quantity
            ) as valorTotalInventario : Decimal(16, 2)
        };

// =======================================================
    // TEMA 45: Operador Exists en la Capa de Persistencia (DB)
    // =======================================================

    // VISTA 1: Exists Básico -> Solo Pedidos que tengan detalle (no vacíos)
    entity ViewPedidosConDetalle         as
        select from purchase_order {
            id,
            orderNumber,
            status,
            orderDate
        }
        // Como 'items' ya está definido en purchase_order (Línea 226),
        // la base de datos sabe cómo hacer el chequeo ultra-rápido.
        where
            exists items;


    // VISTA 2: Exists + Filtro Infix -> Pedidos con al menos un item de gran volumen
    // (Combina el Tema 45 con el Tema 41)
    entity ViewPedidosVolumenAlto        as
        select from purchase_order {
            id,
            orderNumber,
            status,
            orderDate
        }
        // "Tráeme el pedido SOLO SI EXISTE un item cuya cantidad sea mayor a 100"
        where
            exists items[quantity > 100.00];





}