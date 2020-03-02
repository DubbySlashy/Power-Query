//This code uses tab characters for alignment. For this alignment to look right, make sure that IntelliSense is on so that the tab width is 4 characters.

let
	#"Key-Value Table Name"	= "KeyValue",
	#"Function"				= (#"Key" as text) as any => #"Get Name"(#"Key-Value Table Name"){[#"Key" = #"Key"]}[Value],
	#"Documentation" =
		type function
		(
			#"Key" as
			(
				type text meta
				[
					Documentation.FieldCaption		= "Key",
					Documentation.FieldDescription	= "Value to search for in the Key column of the " & #"Key-Value Table Name" & " table."
				]
			)
		) as any meta
		[
			Documentation.Name				= "Key To Value",
			Documentation.LongDescription	= "Returns the value that corresponds to a given key. More specifically, the Key column of the " & #"Key-Value Table Name" & " table is searched for a unique match to the given key. If a unique match is found, the corresponding value in the Value column is returned. If 0 or multiple matches are found, this function returns an error."
		]
in
	Value.ReplaceType(#"Function", #"Documentation")
