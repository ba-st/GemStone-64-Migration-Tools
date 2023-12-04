Extension { #name : 'Object' }

{ #category : '*GS64-Migration-Tools-Base-Extensions' }
Object >> ifInstanceVariable: aSymbol isAbsentIn: theOldInstance initializeWith: aZeroArgBlock [

	(theOldInstance class allInstVarNames includes: aSymbol)
		ifFalse: [self instVarAtName: aSymbol put: aZeroArgBlock value]
]

{ #category : '*GS64-Migration-Tools-Base-Extensions' }
Object >> indexOfInstVarAtName: instVarName [

	^ self class allInstVarNames indexOf: instVarName ifAbsent: [
		  MigrationError signal:
			  'Instance variable named ' , instVarName asString , ' not found in receiver' ]
]

{ #category : '*GS64-Migration-Tools-Base-Extensions' }
Object >> instVarAtName: instVarName [ 

	| index |
	index := self indexOfInstVarAtName: instVarName.
	^self instVarAt: index
]

{ #category : '*GS64-Migration-Tools-Base-Extensions' }
Object >> instVarAtName: instVarName put: aValue [

	| index |

	index := self indexOfInstVarAtName: instVarName.
	^ self instVarAt: index put: aValue
]

{ #category : '*GS64-Migration-Tools-Base-Extensions' }
Object >> renameInstanceVariable: oldName to: newName ifAbsentIn: oldInstance [

	self
		ifInstanceVariable: newName
		isAbsentIn: oldInstance
		initializeWith: [ oldInstance instVarAtName: oldName ]
]
