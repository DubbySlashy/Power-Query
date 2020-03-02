//This code uses tab characters for alignment. For this alignment to look right, make sure that IntelliSense is on so that the tab width is 4 characters.

let
	#"Function" = (#"Name" as text) as any => Excel.CurrentWorkbook(){[#"Name" = #"Name"]}[Content],
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
			Documentation.Name				= "Get Name",
			Documentation.LongDescription	= "Retrieves a table representing a workbook-scoped name from the Name Manager. This includes tables. To retrieve the value of a single-celled workbook-scoped name, use the Get Name Value function."
		]
in
	Value.ReplaceType(#"Function", #"Documentation")
