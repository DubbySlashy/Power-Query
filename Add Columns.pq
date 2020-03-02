///This code uses tab characters for alignment. For this alignment to look right, make sure that IntelliSense is on so that the tab width is 4 characters.

//It is common to add, remove, transform, rename, reorder, and change the data type of columns, which causes many columns to be repeated across different functions.
//Table.SelectColumns selects and reorders columns, which eliminates the need for Table.ReorderColumns.
//Table.TransformColumns transforms columns and changes their data type but cannot access columns other than the one being transformed. If Table.TransformColumns is already being used, then Table.TransformColumnTypes does not need to be used.
//Table.ReplaceValue with replacer = Replacer.ReplaceValue allows column transformations with access to other columns, but it also removes the column's data type. We must add back the column's data type afterwards with Table.TransformColumnTypes.
//A combination of the above functions might be used. In such cases, it might be easier to add a new column using Table.AddColumn and delete the previous one using Table.RemoveColumns. The addition of a replacement column would also avoid the use of Table.RenameColumns.
//However, Table.AddColumn can add only 1 column, and the new column is always added to the end of the table.
//This #"Add Columns" function solves all of the above issues. It provides a consistent syntax to perform all of the above operations to multiple columns in a single call to the function.

let
	#"Function" =
		(
			#"Table"						as table,
			#"Keep Only Specified Columns?"	as logical,
			#"Column Transformation List"	as list
		) as table =>
		let
			#"Accumulator" =
				(#"State" as table, #"Current" as list) as table =>
				let
					#"Column Name"		= #"Current"{0},
					#"Function"			= #"Current"{1},
					#"Type"				= #"Current"{2},
					#"Nullable Type"	= type nullable #"Type", //We convert all types to nullable ones to save the user the effort of explicitly writing "nullable" and to avoid errors related to having null values
					#"Replace Value" =
						Table.ReplaceValue(
							#"State",
							each Record.Field(_, #"Column Name"),
							#"Function",
							Replacer.ReplaceValue,
							{#"Column Name"}
						),
					#"Change Type" =
						//Table.TransformColumnTypes can even convert text representations of numbers to numbers, but it cannot change a column to types "list", "record", "table", or "function"
						Table.TransformColumnTypes(
							#"Replace Value",
							{#"Column Name", #"Nullable Type"}
						),
					#"Add Column" =
						//Alternatively, we could give the new column the type "any" and then apply the #"Change Type" step above to either #"Replace Value" or #"Add Column", depending on whether the column already exists or not. However, if we take this approach, we cannot add new columns of type "list", "record", "table", or "function" without some additional type checks.
						Table.AddColumn(
							#"State",
							#"Column Name",
							each try //This section works on lists, records, & tables but cannot convert text to numeric data types
								Value.ReplaceType(#"Function"(_), #"Nullable Type")
							otherwise try //This section works only on primitive data types (i.e. not lists, records, tables, or functions)
								//The conversion to text and then to the desired data type uses less code but is also slower than selecting the ".From" function that corresponds to the desired data type
								Value.ReplaceType(Value.FromText(Text.From(#"Function"(_))), #"Nullable Type")
							otherwise //When all else fails, give up on trying to change the type of the function's return value
								#"Function"(_),
							//In the Power Query preview, no error will be thrown if a column value does not match the column type specified in Table.AddColumn. However, an error will be thrown when the table is loaded into Power Pivot.
							#"Nullable Type"
						),
					#"Return" =
						if Table.HasColumns(#"State", #"Column Name") then
							#"Change Type"
						else
							#"Add Column"
				in
					#"Return",
			#"Add Columns" =
				List.Accumulate(
					#"Column Transformation List",
					#"Table",
					#"Accumulator"
				),
			#"Column Name List" =
				List.Transform(
					#"Column Transformation List",
					List.First
				),
			#"Keep Only Specified Columns" =
				//Table.SelectColumns keeps only the specified columns and reorders them into the presented order
				Table.SelectColumns(
					#"Add Columns",
					#"Column Name List"
				),
			#"Return" =
				if #"Keep Only Specified Columns?" then
					#"Keep Only Specified Columns"
				else
					#"Add Columns"
		in
			#"Return",
	#"Documentation" =
		type function
		(
			#"Table" as
			(
				type table meta
				[
					Documentation.FieldCaption		= "Table",
					Documentation.FieldDescription	= "The table that will have columns added to it and/or whose columns will be transformed, removed, renamed, reordered, retyped, etc."
				]
			),
			#"Keep Only Specified Columns?" as
			(
				type logical meta
				[
					Documentation.FieldCaption		= "Keep Only Specified Columns?",
					Documentation.FieldDescription	= "If true, only the columns that were passed to the function will be kept, and they will be reordered in the presented order. If false, no columns will be removed or reordered. When this argument is true, this function essentially builds a new table, column by column, based on the given table."
				]
			),
			#"Column Transformation List" as
			(
				type {list} meta
				[
					Documentation.FieldCaption		= "Column Transformation List",
					Documentation.FieldDescription	= "List of lists of the form {""Column Name"", each New Value, New Type}, where each list represents a column. The 2nd item does not have to use ""each"" (but for readability, you will probably use ""each""), as long as it accepts only a single input, which is a record (current row of the table), and returns a value whose type is or can be converted to New Type."
				]
			)
		) as table meta
		[
			Documentation.Name				= "Add Columns",
			Documentation.LongDescription	= "Add, remove, transform, rename, reorder, and change the data type of columns using a single function with a consistent syntax. A column is transformed if it exists or is added if it does not exist. Set the ""Keep Only Specified Columns?"" argument to true to additionally keep only the columns that were passed to this function and reorder them in the presented order. The ""Column Transformation List"" argument accepts a list of lists of the form {""Column Name"", each New Value, New Type}, where each list represents a column. This is similar to the ""transformOperations"" argument of Table.TranformColumns, except that ""each"" in #""Add Columns"" refers to the current row and not the current item in the column, which gives you access to values in any column, similar to Table.AddColumn."
		]
in
	Value.ReplaceType(#"Function", #"Documentation")
