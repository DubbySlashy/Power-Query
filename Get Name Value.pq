let
	#"Function" = (#"Name" as text) as any => Table.FirstValue(#"Get Name"(#"Name")),
	#"Documentation" =
		type function
		(
			#"Name" as
			(
				type text meta
				[
					Documentation.FieldCaption		= "Name",
					Documentation.FieldDescription	= "Workbook-scoped name from the Name Manager"
				]
			)
		) as any meta
		[
			Documentation.Name				= "Get Name Value",
			Documentation.LongDescription	= "Retrieves the value of a workbook-scoped name defined in the Name Manager. If the name refers to multiple cells, the value of the first cell is returned."
		]
in
	Value.ReplaceType(#"Function", #"Documentation")
