"
I'm an abstract class for defining migration scripts.

My subclasses are collected when using `InstanceMigrator` to perform the required actions.
"
Class {
	#name : 'GemStone64MigrationScript',
	#superclass : 'Object',
	#category : 'GS64-Migration-Tools',
	#package : 'GS64-Migration-Tools'
}

{ #category : 'testing' }
GemStone64MigrationScript class >> isAbstract [

	^ self = GemStone64MigrationScript
]

{ #category : 'accessing' }
GemStone64MigrationScript class >> priority [
	"Migration scripts are sorted by priority before the execution.
	If you need some scripts to run in certain order just re-implement
	this method increasing or decreasing the priority as needed."

	^ 50
]

{ #category : 'accessing' }
GemStone64MigrationScript >> classNamesToMigrateToLatestVersion [
	"Returns a collection of class names that need to execute the
	migrateFrom:instVarMap: method and flatten the class history."

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GemStone64MigrationScript >> classRenameMappings [
	"Returns a collection of assocations.
	For each association the key must be the old class name and the
	value must be the new class name.
	This mappings are used to locate all the instances of the old class
	and migrate them as instances of the new class, using the same
	mechanichs for classes with new versions."

	^ self subclassResponsibility
]
