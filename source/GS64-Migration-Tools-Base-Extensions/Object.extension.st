Extension { #name : 'Object' }

{ #category : '*GS64-Migration-Tools-Base-Extensions' }
Object >> ifInstanceVariable: aSymbol isAbsentIn: theOldInstance initializeWith: aZeroArgBlock [

	(theOldInstance class allInstVarNames includes: aSymbol)
		ifFalse: [self instVarAtName: aSymbol put: aZeroArgBlock value]
]

{ #category : '*GS64-Migration-Tools-Base-Extensions' }
Object >> renameInstanceVariable: oldName to: newName ifAbsentIn: oldInstance [

	self
		ifInstanceVariable: newName
		isAbsentIn: oldInstance
		initializeWith: [ oldInstance instVarAtName: oldName ]
]
