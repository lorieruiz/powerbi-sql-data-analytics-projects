let
    // =================
    // Fetch data from MySQL to access "line_productivity" table
    // Note: This example uses LOCAL HOST and DUMMY database NAMES for DEMO purposes only //  
    Server = <your_server>,
    Database = <your_database>,
    Source = MySQL.Database(Server, Database, [ReturnSingleDatabase=true]),
    manufacturing_db_line_productivity = Source{[Schema="manufacturing_db",Item="line_productivity"]}[Data],

    // Renaming to adjust for final column names //
    Final = Table.RenameColumns
    (#"manufacturing_db line_productivity",
        {
            {"LogDate", "Date"},
            {"StartTime", "Start Time"},
            {"EndTime", "End Time"}
        }
    ),

    // Returning actual batch time / production time for each batches and operators //  
    TotalBatchTime = Table.AddColumn(Final, "ActualBatchTime", each Duration.TotalMinutes([End Time] - [Start Time])),
    AdjustDataType_BT = Table.TransformColumnTypes(TotalBatchTime,{{"ActualBatchTime", Int64.Type}}),

    // Joining two tables to return minimum batch time required per run //  
    Join_ProductsAndLineProductivity = Table.NestedJoin(AdjustDataType_BT, {"Product"}, Products, {"Product"}, "Products", JoinKind.LeftOuter),
    Extract_RequiredTime = Table.ExpandTableColumn(Join_ProductsAndLineProductivity, "Products", {"Min batch time"}, {"Min batch time"}),

    // Return only disctint batches //  
    DisctintBatch = Table.Distinct(Extract_RequiredTime, {"Batch"}),
    Final_Table = Table.RenameColumns(DisctintBatch,{{"ActualBatchTime", "ActualBatchTime_Raw"}})
in
    Final_Table
