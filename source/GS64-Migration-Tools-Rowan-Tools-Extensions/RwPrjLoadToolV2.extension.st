Extension { #name : 'RwPrjLoadToolV2' }

{ #category : '*GS64-Migration-Tools-Rowan-Tools-Extensions' }
RwPrjLoadToolV2 >> loadProjectSetDefinition: projectSetDefinition instanceMigrator: instanceMigrator symbolList: symbolList [

	| loadedProjects |

	loadedProjects := self
		                  _doProjectSetLoad: projectSetDefinition
		                  instanceMigrator: instanceMigrator
		                  symbolList: symbolList
		                  originalProjectSet: projectSetDefinition
		                  processedClassNames: Set new.
	Rowan platform instanceMigrator loadFinished.
	^ loadedProjects
]
