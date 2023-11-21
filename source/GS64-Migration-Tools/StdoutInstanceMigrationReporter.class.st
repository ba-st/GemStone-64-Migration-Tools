Class {
	#name : 'StdoutInstanceMigrationReporter',
	#superclass : 'RwGsInstanceMigrator',
	#instVars : [
		'removedClasses',
		'classesWithNewVersions'
	],
	#category : 'GS64-Migration-Tools',
	#package : 'GS64-Migration-Tools'
}

{ #category : 'actions' }
StdoutInstanceMigrationReporter class >> install [

	Rowan platform instanceMigrator: self aggressiveMigration
]

{ #category : 'instance creation' }
StdoutInstanceMigrationReporter class >> new [

	^super new initialize 
]

{ #category : 'migration' }
StdoutInstanceMigrationReporter >> aboutToRemoveClass: classToRemove [
	"This message is sent before a class deletion patch is applied.
	Classes can be removed for two reasons: a real removal or a
	rename. In both cases we want the migrator to notice so it can
	migrate the instances, or check there's no remaining instances of the
	removed class."

	removedClasses add: classToRemove
]

{ #category : 'initialization' }
StdoutInstanceMigrationReporter >> initialize [

	super initialize.
	self
		resetClassesWithNewVersions;
		resetRemovedClasses
]

{ #category : 'migration' }
StdoutInstanceMigrationReporter >> loadFinished [

	self
		printLine: [ :s | s << 'Finished loading code changes.' ];
		printLine: [ :s | s << 'Reporting classes requiring special attention for migration purposes...' ];
		reportClassesWithNewVersions;
		reportRemovedClasses;
		printEmptyLine;
		printLine: 'Reporting finished.'
]

{ #category : 'migration' }
StdoutInstanceMigrationReporter >> migrateInstancesOf: classes [
	"This message is sent once a patch set ends loading changes.
	classesWithNewVersions contains a list of the old class versions"

	classesWithNewVersions addAll: classes
]

{ #category : 'private - printing' }
StdoutInstanceMigrationReporter >> printBanner: aBlock [

	self
		printEmptyLine;
		printInfo: [ :s | s << '##################################################' ];
		printInfo: aBlock;
		printInfo: [ :s | s << '##################################################' ];
		printEmptyLine
]

{ #category : 'private - printing' }
StdoutInstanceMigrationReporter >> printEmptyLine [

	self printLine: [ :s |  ]
]

{ #category : 'private - printing' }
StdoutInstanceMigrationReporter >> printError: aBlock [

	self printLine: [ :s |
		s << Character esc << '[1m'.
		s << Character esc << '[31m'.
		aBlock value: s.
		s << Character esc << '[0m'
		]
]

{ #category : 'private - printing' }
StdoutInstanceMigrationReporter >> printInfo: aBlock [

	self printLine: [ :s |
		s << Character esc << '[1m'.
		s << Character esc << '[34m'.
		aBlock value: s.
		s << Character esc << '[0m'
		]
]

{ #category : 'private - printing' }
StdoutInstanceMigrationReporter >> printLine: aBlock [

  aBlock value: GsFile stdout.
  GsFile stdout lf; flush
]

{ #category : 'private - printing' }
StdoutInstanceMigrationReporter >> printSuccess: aBlock [

	self printLine: [ :s |
		s << Character esc << '[1m'.
		s << Character esc << '[32m'.
		aBlock value: s.
		s << Character esc << '[0m'
		]
]

{ #category : 'private - printing' }
StdoutInstanceMigrationReporter >> printWarning: aBlock [

	self printLine: [ :s |
		s << Character esc << '[1m'.
		s << Character esc << '[33m'.
		aBlock value: s.
		s << Character esc << '[0m'
		]
]

{ #category : 'private - reporting' }
StdoutInstanceMigrationReporter >> reportClassesWithNewVersions [

	classesWithNewVersions ifNotEmpty: [
		self printBanner: [ :s |
			s << classesWithNewVersions size asString << ' classes have new versions' ].

		( self sortClassesByName: classesWithNewVersions ) do: [ :classWithNewVersion |
			self printWarning: [ :s | s << '- ' << classWithNewVersion name asString ] ]
		].
	self resetClassesWithNewVersions
]

{ #category : 'private - reporting' }
StdoutInstanceMigrationReporter >> reportRemovedClasses [

	removedClasses ifNotEmpty: [
		self printBanner: [ :s | s << removedClasses size asString << ' classes were removed' ].

		( self sortClassesByName: removedClasses ) do: [ :removedClass |
			self printWarning: [ :s | s << '- ' << removedClass name asString ] ].
		self resetRemovedClasses
		]
]

{ #category : 'initialization' }
StdoutInstanceMigrationReporter >> resetClassesWithNewVersions [

	classesWithNewVersions := OrderedCollection new
]

{ #category : 'initialization' }
StdoutInstanceMigrationReporter >> resetRemovedClasses [

	removedClasses := OrderedCollection new
]

{ #category : 'private - reporting' }
StdoutInstanceMigrationReporter >> sortClassesByName: classes [

	^ classes sort: [ :a :b | a class name < b class name ]
]
