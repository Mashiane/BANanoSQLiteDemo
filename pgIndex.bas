B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=StaticCode
Version=7.51
@EndOfDesignText@
'Static code module
Sub Process_Globals
	Private body As BANanoElement
	Private BANano As BANano
	Private dummy As UOENowData
	Private elNotif As BANanoElement
	Private elCommand As BANanoElement
	Private elArgs As BANanoElement
	Private sqlite As BANanoSQLite
	Private dbname As String
End Sub

Sub Init
	'get the db name
	dbname = Main.dbname
	'get the body of the page
	body = BANano.GetElement("#body")
	'empty the body
	body.Empty
	'
	'command
	Dim command As UOENowHTML
	command.Initialize("command","label").SetText("Command: ")
	body.Append(command.HTML).Append("<br><br>")
	'
	'arguements
	Dim args As UOENowHTML
	args.Initialize("args","label").SetText("Arguements: ")
	body.Append(args.HTML).Append("<br><br>")
	 
	'results
	Dim notify As UOENowHTML
	notify.Initialize("notify","label").SetText("Notifications:")
	body.Append(notify.HTML).Append("<br><br>")
	'
	'create the insert button
	Dim btn As UOENowHTML
	btn.Initialize("btninserts","button").SetText("Inserts")
	'append insert to the body
	body.Append(btn.HTML)
	'create the select button
	Dim btnSelect As UOENowHTML
	btnSelect.Initialize("btnselect","button").SetText("Select")
	'add select to the body
	body.Append(btnSelect.HTML)
	'deletes
	Dim btnDelete As UOENowHTML
	btnDelete.Initialize("btndelete","button").SetText("Delete All")
	body.Append(btnDelete.HTML)
	' 
	'updates
	Dim btnUpdates As UOENowHTML
	btnUpdates.Initialize("btnupdate","button").SetText("Update All")
	body.Append(btnUpdates.HTML)
	
	'add events to the buttons
	BANano.GetElement("#btninserts").HandleEvents("click", Me, "inserts")
	BANano.GetElement("#btnselect").HandleEvents("click", Me, "selects")
	BANano.GetElement("#btnupdate").HandleEvents("click", Me, "updates")
	BANano.GetElement("#btndelete").HandleEvents("click", Me, "deletes")
	'
	elNotif = BANano.GetElement("#notify")
	elCommand = BANano.GetElement("#command")
	elArgs = BANano.GetElement("#args")
End Sub

''update all
Sub updates
	ClearFirst
	sqlite.Initialize 
	dummy.Initialize
	Dim parentid As String = dummy.Rand_Company_Name
	'
	Dim sql As String = sqlite.UpdateAll("items", CreateMap("parentid":parentid))
	Dim dc As DBCommand = sqlite.GetCommand(sql)
	Dim res As String = BANano.CallInlinePHPWait("BANanoSQLite", CreateMap("dbname": dbname, "data": sql))
	Dim dbres As DBResult = sqlite.GetResult(res)
	'
	elCommand.SetText("Command: " & dc.sql)
	elArgs.SetText("Arguements: " & BANano.ToJson(dc.args))
	elNotif.SetText("Result: " & BANano.ToJson(dbres.data))
	
End Sub
'
''delete all records
Sub Deletes
	ClearFirst
	sqlite.Initialize 
	Dim sql As String = sqlite.DeleteAll("items")
	Dim dc As DBCommand = sqlite.GetCommand(sql)
	Dim res As String = BANano.CallInlinePHPWait("BANanoSQLite", CreateMap("dbname": dbname, "data": sql))
	Dim dbres As DBResult = sqlite.GetResult(res)
	
	elCommand.SetText("Command: " & dc.sql)
	elArgs.SetText("Arguements: ")
	elNotif.SetText("Result: " & BANano.ToJson(dbres.data))
End Sub
'
'select all records
Sub Selects
	ClearFirst
	'build the select statement
	sqlite.Initialize 
	Dim sql As String = sqlite.SelectAll("items", Array("*"), Array("id"))
	Dim dc As DBCommand = sqlite.GetCommand(sql)
	Dim res As String = BANano.CallInlinePHPWait("BANanoSQLite", CreateMap("dbname": dbname, "data": sql))
	Dim dbres As DBResult = sqlite.GetResult(res)
	'
	elCommand.SetText("Command: " & dc.sql)
	elArgs.SetText("Arguements: " & BANano.ToJson(dc.args))
	elNotif.SetText("Result: " & BANano.ToJson(dbres.data))
End Sub
'
'insert dummy records to the db
Sub Inserts
	ClearFirst
	'initialize dummy data generator
	dummy.Initialize
	'define structure
	Dim structure As Map = CreateMap()
	structure.Put("id", dummy.DT_FIRST_NAME)
	structure.Put("jsoncontent", dummy.DT_FULL_NAME)
	structure.Put("tabindex", dummy.DT_NUMBER)
	structure.put("parentid", "form")
	'
	Dim records As List
	records = dummy.GetRecordsWithStructure(structure, 1)
	Dim struct As Map = records.Get(0)
	'
	'initialize sqlite helper
	sqlite.Initialize
	'ensure you specify the field types , rest are strings
	sqlite.AddStrings(Array("id"))
	sqlite.AddIntegers(Array("tabindex"))
	'define the field types
	Dim sql As String = sqlite.Insert("items", struct)
	Dim dc As DBCommand = sqlite.GetCommand(sql)
	Dim res As String = BANano.CallInlinePHPWait("BANanoSQLite", CreateMap("dbname": dbname, "data": sql))
	Dim dbres As DBResult = sqlite.GetResult(res)
	'
	elCommand.SetText("Command: " & dc.sql)
	elArgs.SetText("Arguements: " & BANano.ToJson(dc.args))
	elNotif.SetText("Result: " & BANano.ToJson(dbres.data) & " rowid!")
End Sub
'
'
Sub ClearFirst
	elCommand.SetText("Command: ")
	elArgs.SetText("Arguements: ")
	elNotif.SetText("Result: ")
End Sub