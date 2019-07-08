B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=7.51
@EndOfDesignText@
'Static code module
#IgnoreWarnings:12
Sub Process_Globals
	
End Sub


'get map values as a list
private Sub GetMapValues(sourceMap As Map) As List
	Dim listOfValues As List
	listOfValues.Initialize
	Dim iCnt As Int
	Dim iTot As Int
	iTot = sourceMap.Size - 1
	For iCnt = 0 To iTot
		Dim value As String = sourceMap.GetValueAt(iCnt)
		listOfValues.Add(value)
	Next
	Return listOfValues
End Sub

'return a sql map to insert record to table. sql = query string, values = list of values
Sub Insert(tblName As String, tblFields As Map) As Map
	Dim sb As StringBuilder
	Dim columns As StringBuilder
	Dim values As StringBuilder
	Dim listOfValues As List = GetMapValues(tblFields)
	Dim iCnt As Int
	Dim iTot As Int
	sb.Initialize
	columns.Initialize
	values.Initialize
	sb.Append($"INSERT INTO ${EscapeField(tblName)} ("$)
	iTot = tblFields.Size - 1
	For iCnt = 0 To iTot
		Dim col As String = tblFields.GetKeyAt(iCnt)
		If iCnt > 0 Then
			columns.Append(", ")
			values.Append(", ")
		End If
		columns.Append(EscapeField(col))
		values.Append("?")
	Next
	sb.Append(columns.ToString)
	sb.Append(") VALUES (")
	sb.Append(values.ToString)
	sb.Append(")")
	Dim m As Map
	m.Initialize
	m.Put("sql", sb.ToString)
	m.Put("args", listOfValues)
	Return m
End Sub

'return a sql to update record of table where one exists
Sub UpdateWhere(tblName As String, tblFields As Map, tblWhere As Map) As Map
	Dim sb As StringBuilder
	Dim args As List
	sb.Initialize
	args.Initialize
	sb.Append($"UPDATE ${EscapeField(tblName)} SET "$)
	Dim i As Int
	Dim iTot As Int = tblFields.Size - 1
	For i = 0 To iTot
		Dim col As String = tblFields.GetKeyAt(i)
		Dim colvalue As String = tblFields.Get(col)
		sb.Append(col)
		If i <> iTot Then
			sb.Append("=?,")
		Else
			sb.Append("=?")
		End If
		args.Add(colvalue)
	Next
	sb.Append(" WHERE ")
	Dim iWhere As Int = tblWhere.Size - 1
	For i = 0 To iWhere
		If i > 0 Then
			sb.Append(" AND ")
		End If
		Dim colwhere As String = tblWhere.GetKeyAt(i)
		Dim colvalue As String = tblWhere.Get(colwhere)
		sb.Append(colwhere)
		sb.Append(" = ?")
		args.Add(colvalue)
	Next
	Dim m As Map
	m.Initialize
	m.Put("sql", sb.tostring)
	m.Put("args", args)
	Return m
End Sub

'return a sql to delete record of table where one exists
Sub DeleteWhere(tblName As String, tblWhere As Map) As Map
	Dim sb As StringBuilder
	Dim args As List
	sb.Initialize
	args.Initialize
	sb.Append($"DELETE FROM ${EscapeField(tblName)} WHERE "$)
	Dim i As Int
	Dim iWhere As Int = tblWhere.Size - 1
	For i = 0 To iWhere
		If i > 0 Then
			sb.Append(" AND ")
		End If
		Dim colwhere As String = tblWhere.GetKeyAt(i)
		Dim colvalue As String = tblWhere.Get(colwhere)
		sb.Append(colwhere)
		sb.Append(" = ? ")
		args.Add(colvalue)
	Next
	Dim m As Map
	m.Initialize
	m.Put("sql", sb.tostring)
	m.Put("args", args)
	Return m
End Sub


'return a sql to update all records of table
Sub UpdateAll(tblName As String, tblFields As Map) As Map
	Dim sb As StringBuilder
	Dim args As List
	sb.Initialize
	args.Initialize
	sb.Append($"UPDATE ${EscapeField(tblName)} SET "$)
	Dim i As Int
	Dim iTot As Int = tblFields.Size - 1
	For i = 0 To iTot
		Dim col As String = tblFields.GetKeyAt(i)
		Dim colvalue As String = tblFields.Get(col)
		sb.Append(col)
		If i <> iTot Then
			sb.Append("=?,")
		Else
			sb.Append("=?")
		End If
		args.Add(colvalue)
	Next
	Dim m As Map
	m.Initialize
	m.Put("sql", sb.tostring)
	m.Put("args", args)
	Return m
End Sub

'join list to multi value string
private Sub JoinFields(delimiter As String, lst As List) As String
	Dim i As Int
	Dim sb As StringBuilder
	Dim fld As String
	sb.Initialize
	fld = lst.Get(0)
	fld = EscapeField(fld)
	sb.Append(fld)
	For i = 1 To lst.size - 1
		Dim fld As String = lst.Get(i)
		fld = EscapeField(fld)
		sb.Append(delimiter).Append(fld)
	Next
	Return sb.ToString
End Sub

'return a sql to select record of table where one exists
Sub SelectWhere(tblName As String, tblfields As List, tblWhere As Map,orderBy As List) As Map
	Dim fld1 As String = tblfields.Get(0)
	Dim selFIelds As String = ""
	Select Case fld1
		Case "*"
			selFIelds = "*"
		Case Else
			selFIelds = JoinFields(",", tblfields)
	End Select
	Dim sb As StringBuilder
	Dim args As List
	sb.Initialize
	args.Initialize
	sb.Append($"SELECT ${selFIelds} FROM ${EscapeField(tblName)} WHERE "$)
	Dim i As Int
	Dim iWhere As Int = tblWhere.Size - 1
	For i = 0 To iWhere
		If i > 0 Then
			sb.Append(" AND ")
		End If
		Dim colwhere As String = tblWhere.GetKeyAt(i)
		Dim colvalue As String = tblWhere.Get(colwhere)
		sb.Append(colwhere)
		sb.Append(" = ?")
		args.Add(colvalue)
	Next
	If orderBy <> Null Then
		'order by
		Dim stro As String = Join(",", orderBy)
		If stro.Length > 0 Then
			sb.Append(" ORDER BY ").Append(stro)
		End If
	End If
	Dim m As Map
	m.Initialize
	m.Put("sql", sb.tostring)
	m.Put("args", args)
	Return m
End Sub

'join list to mv string
private Sub Join(delimiter As String, lst As List) As String
	Dim i As Int
	Dim sb As StringBuilder
	Dim fld As String
	sb.Initialize
	fld = lst.Get(0)
	sb.Append(fld)
	For i = 1 To lst.size - 1
		Dim fld As String = lst.Get(i)
		sb.Append(delimiter).Append(fld)
	Next
	Return sb.ToString
End Sub

'return a sql to select record of table where one exists
Sub SelectAll(tblName As String, flds As List, orderBy As List) As Map
	Dim sb As StringBuilder
	Dim args As List
	sb.Initialize
	args.Initialize
	'define flds
	Dim strf As String = Join(",", flds)
	sb.Append($"SELECT ${strf} FROM ${EscapeField(tblName)}"$)
	If orderBy <> Null Then
		'order by
		Dim stro As String = Join(",", orderBy)
		If stro.Length > 0 Then
			sb.Append(" ORDER BY ").Append(stro)
		End If
	End If
	Dim m As Map
	m.Initialize
	m.Put("sql", sb.tostring)
	m.Put("args", Null)
	Return m
End Sub
