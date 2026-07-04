using CatalogService as service from '../../srv/catalog-service';

// =========================================================
// BLOQUE 1: UI VISUAL (Con variables i18n)
// =========================================================
annotate service.car with @(
    
    // Columnas de la tabla
    UI.LineItem : [
        { $Type : 'UI.DataField', Label : '{i18n>carName}', Value : name },
        { $Type : 'UI.DataField', Label : '{i18n>carDiscount1}', Value : discount_1, Criticality : 3 },
        { $Type : 'UI.DataField', Label : '{i18n>carDiscount2}', Value : discount_2, Criticality : 1 }
    ],

    // Filtros superiores
    UI.SelectionFields : [ name, discount_1 ],

    // Cabecera (Títulos y Foto)
    UI.HeaderInfo : {
        TypeName       : '{i18n>carTypeName}',
        TypeNamePlural : '{i18n>carTypeNamePlural}',
        Title          : { $Type : 'UI.DataField', Value : name },
        Description    : { $Type : 'UI.DataField', Value : ID },
        ImageUrl       : imageUrl 
    },

    // KPIs destacados en la cabecera
    UI.DataPoint #KPI_Descuento : {
        Value       : discount_1,
        Title       : '{i18n>carDiscount1}',
        Criticality : 3 
    },
    UI.DataPoint #KPI_Descuento2 : {
        Value       : discount_2,
        Title       : '{i18n>carDiscount2}',
        Criticality : 1 
    },
    UI.HeaderFacets : [
        { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#KPI_Descuento' },
        { $Type : 'UI.ReferenceFacet', Target : '@UI.DataPoint#KPI_Descuento2' }
    ],

    // Información del detalle y Tarjeta de Contacto
    UI.FieldGroup #GeneratedGroup : {
        $Type : 'UI.FieldGroupType',
        Data : [
            { $Type : 'UI.DataField', Label : '{i18n>carName}', Value : name },
            { $Type : 'UI.DataField', Label : '{i18n>carDiscount1}', Value : discount_1 },
            { $Type : 'UI.DataField', Label : '{i18n>carDiscount2}', Value : discount_2 },
            { $Type : 'UI.DataFieldForAnnotation', Target : 'supplier/@Communication.Contact', Label : '{i18n>supplierData}' }
        ]
    },
    UI.Facets : [
        { $Type : 'UI.ReferenceFacet', ID : 'GeneratedFacet1', Label : '{i18n>generalInfo}', Target : '@UI.FieldGroup#GeneratedGroup' }
    ],
    
    // Botones CRUD habilitados
    Capabilities : {
        Insertable : true,
        Updatable  : true,
        Deletable  : true
    }
);

// =========================================================
// BLOQUE 2: CONFIGURACIÓN DE DATOS, LISTAS E IMÁGENES
// =========================================================

// Identificamos que el campo imageUrl es una foto
annotate service.car with {
    imageUrl @UI.IsImageURL : true
};

// Configuración del Proveedor (Texto descriptivo)
annotate service.Supplier with {
    ID @Common.Text : name
};

// Ayuda de búsqueda para el proveedor
annotate service.car with {
    supplier @Common.ValueList : {
        Label          : '{i18n>supplierLabel}',
        CollectionPath : 'Supplier',
        Parameters     : [
            { $Type : 'Common.ValueListParameterInOut', LocalDataProperty : supplier_ID, ValueListProperty : 'ID' },
            { $Type : 'Common.ValueListParameterDisplayOnly', ValueListProperty : 'name' }
        ]
    }
};

// Tarjeta de contacto interactiva del proveedor
annotate service.Supplier with @(
    Communication.Contact : {
        $Type : 'Communication.ContactType',
        fn    : name,       
        email : [{
            type    : #work,
            address : email 
        }]
    }
);