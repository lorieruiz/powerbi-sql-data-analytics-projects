let
    // ============================
    // Fetching data from MySQL to access "line_downtime" table
    // Note: This example uses LOCAL HOST and DUMMY database NAMES for DEMO purposes only //  
    Server = <your_server>,
    Database = <your_database>,
    Source = MySQL.Database(Server, Database, [ReturnSingleDatabase=true]),
    manufacturing_db_line_downtime = Source{[Schema="manufacturing_db",Item="line_downtime"]}[Data],
    // Adjust column names //  
    Fixing_ColumnNames = Table.RenameColumns
    (
        manufacturing_db_line_downtime,{
            {"Attribute", "FactorID"},
            {"Value", "Downtime(InMin)"}
        }
    ),
    // Finalized data type for final table //  
    Final = Table.TransformColumnTypes(Fixing_ColumnNames, {{"Batch", Text.Type}})
in
    Final