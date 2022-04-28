// MIT License
// 
// Copyright (c) 2022 The Computer Classroom, Inc. (TCCI)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// this file must contain ONE JSON object with keys of query parameters and
// values of the corresponding column name.
var mappingObject = readUrl("classpath://objectPropsColumnMap.json", "application/json") 
var mappingQPs = readUrl("classpath://qpsColumnMap.json", "application/json")

// Turn obj values into what we need for the DB
// for now, this is a noop. Might change later.  
// Originally thought strings needed to be quoted. Not now.
var makeValue = (val) ->
	//if (isNumeric(val)) val as Number else val
	val
	
// Create both the dynamic where clause with input parameters,
// and the inputParameter object.
var createSetClause = (acc: Object, objectProp: Object | Null | String, objName: String) ->
	if(objectProp is Object) 
		do {
			var objInfo = mappingObject[objName]
			var propColumnMap = mappingObject[objName].props
			var colName = propColumnMap[namesOf(objectProp)[0]]
			---
			// {a: objInfo, b: propColumnMap, c: colName}
			if (colName == null) // there is no match, just return current acc
				acc
			else
				if(acc.set == '') { // first time through
					set:  'SET $(colName) = :$(colName)',
					params:	{ (colName): makeValue(valuesOf(objectProp)[0]) }
					}
				else { // second+ time through, add
					set: "$(acc.set), $(colName) = :$(colName)",
					params: acc.params ++
							{ (namesOf(objectProp)[0]): makeValue(valuesOf(objectProp)[0]) }        
				     }
		} // do
	else { set: acc.set, params: acc.params}
	
// Create both the dynamic where clause with input parameters,
// and the inputParameter object.
var createWhereClause = (acc: Object, qpo: Object | Null | String, objName: String) ->
	if(qpo is Object)
		do {
			var objInfo = mappingQPs[objName]
			var qpColumnMap = mappingQPs[objName].queryParams
			var colName = qpColumnMap[namesOf(qpo)[0]]
			---
			if (colName == null) // there is no match, just return current acc
				acc
			else
				if(acc.where == '') {
					where:  'WHERE $(colName) = :$(colName)',
					params:	{ (colName): makeValue(valuesOf(qpo)[0]) }  }
				else {
					where: "$(acc.where) AND $(colName) = :$(namesOf(qpo)[0])",
					params: acc.params ++
							{ (namesOf(qpo)[0]): makeValue(valuesOf(qpo)[0]) }        
				     }
				} // do
	else { where: "", params: ""}

//var processObject =  
//	1. turn queryParams or some other object into an array of key-value pairs
//	   that can then be processed by reduce
//	2. use 'reduce' to iterate over each query parameter
//	   and call createSetClause or createWhereClause to create:
//     a. a SET or WHERE clause with parameterized inputs
//     b. an inputParmeter object with key/value pairs for the parameters in 2.a.
var processObject = (anobject: Object, objName: String, clause: String) -> 
	// turn updateObject object into an array of key-value pairs
	// that can then be processed by reduce
	(anobject pluck (v, k) ->
		(k): v)
	// use 'reduce' to iterate over each query parameter
	// and create the Where-clause string and input parameter object
	reduce (prop, acc={set: '', where: '', params: ''}) ->
		clause match {
			case 'SET' -> createSetClause(acc, prop, objName)
			case 'WHERE' -> createWhereClause(acc, prop, objName)
			}
		
var makeDynamicWhere = (queryParams: Object, objName: String) ->
	do {
		var dynamic = processObject(queryParams, objName, 'WHERE')
		---
		if (dynamic.params == '') { where: "", params: ""}
		else dynamic
		}

var makeDynamicUpdate = (updateObject: Object, objName: String) -> 
	do {
		var dynamic = processObject(updateObject, objName, 'SET')
		---
		if (dynamic.params == '') { set: "", params: "", start: "UPDATE $(mappingObject[objName].table as String) "}
		else dynamic ++ "start": "UPDATE $(mappingObject[objName].table as String)"}
