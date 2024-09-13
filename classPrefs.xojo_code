#tag Class
Protected Class classPrefs
	#tag Method, Flags = &h0
		Sub Constructor(bundleID as String)
		  Var prefFile As FolderItem
		  prefDB = New SQLiteDatabase
		  
		  prefFile = SpecialFolder.ApplicationData.Child(bundleID)
		  If Not prefFile.Exists Then
		    prefFile.CreateFolder
		  End If
		  
		  prefFile = SpecialFolder.ApplicationData.Child(bundleID).Child(bundleID + ".prefs")
		  If Not prefFile.Exists Then
		    Try
		      prefDB.DatabaseFile = prefFile
		      prefDB.CreateDatabase
		      
		    Catch Error As IOException
		      MessageBox("Prefs-File could not be created: " + Error.Message)
		    End Try
		    
		    Try
		      prefDB.Connect
		      prefDB.BeginTransaction
		      prefDB.ExecuteSQL("CREATE TABLE tblPrefs (ID INTEGER PRIMARY KEY AUTOINCREMENT, key TEXT, value TEXT);")
		      prefDB.CommitTransaction
		      
		    Catch Error As DatabaseException
		      MessageBox("Database Error: " + Error.Message)
		      prefDB.RollbackTransaction
		    End Try
		    
		  Else
		    Try
		      prefDB.DatabaseFile = prefFile
		      prefDB.Connect
		      
		    Catch Error As DatabaseException
		      MessageBox("Database cannot be connected: " + Error.Message)
		    End Try
		    
		  End If
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub deleteValue(key as String)
		  Var rs As RowSet
		  
		  Try
		    prefDB.Connect
		    rs = prefDB.SelectSQL("SELECT * FROM tblPrefs WHERE key=?;", key.Uppercase)
		    
		    If rs.RowCount = 0 Then
		      Raise New KeyNotFoundException
		    Else
		      prefDB.ExecuteSQL("DELETE FROM tblPrefs WHERE key=?;", key.Uppercase)
		    End If
		    
		  Catch Error As DatabaseException
		    MessageBox Error.Message
		  End Try
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getBooleanValue(key as String, Optional default as Boolean) As Boolean
		  Return GetValue(key, default) = "TRUE"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getColorValue(key as variant, Optional default as Color) As color
		  Var v As Variant = GetValue(key, default)
		  Return v.ColorValue
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getDoubleValue(key as string, Optional default as Double) As Double
		  Return GetValue(key, Default).ToDouble
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getIntegerValue(key as string, Optional default as Integer) As Integer
		  Return GetValue(key, default).ToInteger
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getPictureValue(key as String, Optional default as picture) As Picture
		  Var tmpDef As Variant
		  
		  If default <> Nil Then
		    tmpDef = EncodeBase64(default.ToData(Picture.Formats.PNG))
		  End If
		  
		  Return Picture.FromData(DecodeBase64(getValue(key, tmpDef)))
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getSingleValue(key as string, Optional default as Single) As Single
		  Return GetValue(key, default).ToDouble
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function getStringValue(key as string, Optional default as String) As String
		  Return GetValue(key, default)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function getValue(key as String, Optional default as Variant) As String
		  Var rs As RowSet
		  
		  Try
		    prefDB.Connect
		    rs = prefDB.SelectSQL("SELECT * FROM tblPrefs WHERE key=?;", key.Uppercase)
		    
		    If rs.RowCount = 0 Then
		      If default <> Nil Then
		        Return default
		      Else
		        Raise New KeyNotFoundException
		      End If
		    Else
		      Return rs.Column("value").StringValue
		    End If
		    
		  Catch Error As DatabaseException
		    MessageBox Error.Message
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function hasKey(key as String) As Boolean
		  Var rs As RowSet
		  
		  Try
		    prefDB.Connect
		    rs = prefDB.SelectSQL("SELECT * FROM tblPrefs WHERE key=?;", key.Uppercase)
		    
		    If rs.RowCount = 0 Then
		      Return False
		    Else
		      Return True
		    End If
		    
		  Catch Error As DatabaseException
		    MessageBox Error.Message
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub setBooleanValue(key as String, value as Boolean)
		  SetValue(key, value.ToString)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub setColorValue(key as String, value as Color)
		  SetValue(key, value)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub setDoubleValue(key as String, value as Double)
		  SetValue(key, value)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub setIntegerValue(key as String, value as Integer)
		  SetValue(key, value.ToString)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub setPictureValue(key as string,value as Picture)
		  SetValue(key, EncodeBase64(value.GetData(Picture.FormatPNG)))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub setSingleValue(key as String, value as single)
		  SetValue(key, value)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub setStringValue(key as String, value as String)
		  SetValue(key, value)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub setValue(key as string, value as variant)
		  Var rs As RowSet
		  
		  Try
		    prefDB.Connect
		    rs = prefDB.SelectSQL("SELECT * FROM tblPrefs WHERE key=?;", key.Uppercase)
		    
		    // key dosn't exist
		    If rs.RowCount = 0 Then
		      prefDB.ExecuteSQL("INSERT INTO tblPrefs (key, value) VALUES (?,?);", key.Uppercase, value.StringValue)
		      
		    Else
		      // key exists, therefore just update
		      prefDB.ExecuteSQL("UPDATE tblPrefs SET value=? WHERE key=?;", value.StringValue, key.Uppercase)
		      
		    End If
		    
		    RaiseEvent PreferencesChanged
		    
		  Catch Error As DatabaseException
		    MessageBox Error.Message
		  End Try
		  
		End Sub
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event PreferencesChanged()
	#tag EndHook


	#tag Property, Flags = &h21
		Private prefDB As SQLiteDatabase
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
