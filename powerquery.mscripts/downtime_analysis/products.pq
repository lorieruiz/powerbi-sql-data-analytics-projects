let
    // =====================
    // Fetch data from MySQL to access "products" table
    // Note: This example uses LOCAL HOST and DUMMY database NAMES for DEMO purposes only //  
    Server = <your_server>,
    Database = <your_database>,
    Source = MySQL.Database(Server, Database, [ReturnSingleDatabase=true]),
    manufacturing_db_products = Source{[Schema="manufacturing_db",Item="products"]}[Data]
    // Returns products table //  
in
    manufacturing_db_products
