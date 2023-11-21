Extension { #name : 'RwGsClassDeletionSymbolDictPatchV2' }

{ #category : '*GS64-Migration-Tools-Rowan-Loader-Extensions' }
RwGsClassDeletionSymbolDictPatchV2 >> deleteClassFromSystem [

	( Rowan globalNamed: self className )
		ifNotNil: [ :classToRemove |
			Rowan platform instanceMigrator aboutToRemoveClass: classToRemove.
			self symbolDictionaryRegistry
				deleteClassNamedFromPackage: self className
				implementationClass: RwGsSymbolDictionaryRegistry_ImplementationV2
			]
]
