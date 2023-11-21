Extension { #name : 'RwGsPatchSet_V2' }

{ #category : '*GS64-Migration-Tools-Rowan-Extensions' }
RwGsPatchSet_V2 >> migrateInstances [

	"conditionally migrate instances of classes with new versions"

	| classSet |
	classSet := classesWithNewVersions collect: [ :patch | patch oldClassVersion ].
	instanceMigrator
		ifNil: [ 
			"if instanceMigrator is not set, then we are not ready to do instance migration on this pass"
			^ self ].
	instanceMigrator migrateInstancesOf: classSet asArray

]
