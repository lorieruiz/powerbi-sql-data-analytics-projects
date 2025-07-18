let
    // ===============================
    // Source Configuration
    // ===============================
    // Connect to local MySQL database and access the 'downtime_factor' table
    Server = <your server>,
    Database = <your database>,
    Source = MySQL.Database(Server, Database, [ReturnSingleDatabase=true]),
    RawTable = Source{[Schema="manufacturing_db", Item="downtime_factor"]}[Data],

    // ===============================
    // Data Type Formatting
    // ===============================
    // Ensure correct data types for key columns
    TypedTable = Table.TransformColumnTypes(
        RawTable,
        {
            {"Factor", Int64.Type},
            {"Description", type text},
            {"Operator Error", type text}
        }
    ),

    // ===============================
    // Labeling Error Types
    // ===============================
    // Replace YES/NO in 'Operator Error' column with descriptive labels
    WithOperatorErrorLabeled = Table.ReplaceValue(TypedTable, "Yes", "Operator Error", Replacer.ReplaceText, {"Operator Error"}),
    WithMachineErrorLabeled = Table.ReplaceValue(WithOperatorErrorLabeled, "No", "Machine Error", Replacer.ReplaceText, {"Operator Error"}),

    // ===============================
    // Shortening description column to create dashboard-friendly label
    WithShortDescColumn = Table.DuplicateColumn(WithMachineErrorLabeled, "Description", "ShortDesc"),

    // Apply shortening replacements on common lengthy descriptions
    Shortened_MachineAdjust = Table.ReplaceValue(WithShortDescColumn, "Machine adjustment", "Machine adjust", Replacer.ReplaceText, {"ShortDesc"}),
    Shortened_InventoryShortage = Table.ReplaceValue(Shortened_MachineAdjust, "Inventory shortage", "Short inventory", Replacer.ReplaceText, {"ShortDesc"}),
    Shortened_BatchCodingError = Table.ReplaceValue(Shortened_InventoryShortage, "Batch coding error", "Coding error", Replacer.ReplaceText, {"ShortDesc"}),
    Shortened_CalibrationError = Table.ReplaceValue(Shortened_BatchCodingError, "Calibration error", "Calibrate error", Replacer.ReplaceText, {"ShortDesc"}),
    Shortened_BeltJam = Table.ReplaceValue(Shortened_CalibrationError, "Conveyor belt jam", "Belt jam", Replacer.ReplaceText, {"ShortDesc"})

in
    // ===============================
    // Output Cleaned Table
    // ===============================
    Shortened_BeltJam
