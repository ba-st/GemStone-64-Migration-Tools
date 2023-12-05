Class {
	#name : 'InstanceMigrator',
	#superclass : 'RwGsInstanceMigrator',
	#instVars : [
		'removedClasses',
		'classesWithNewVersions',
		'migrationFailed'
	],
	#category : 'GS64-Migration-Tools',
	#package : 'GS64-Migration-Tools'
}

{ #category : 'actions' }
InstanceMigrator class >> install [

	Rowan platform instanceMigrator: self aggressiveMigration
]

{ #category : 'instance creation' }
InstanceMigrator class >> new [

	^ super new initialize
]

{ #category : 'configuring' }
InstanceMigrator >> aboutToRemoveClass: classToRemove [
	"This message is sent before a class deletion patch is applied.
	Classes can be removed for two reasons: a real removal or a
	rename. In both cases we want the migrator to notice so it can
	migrate the instances, or check there's no remaining instances of the
	removed class."

	removedClasses add: classToRemove
]

{ #category : 'private - actions' }
InstanceMigrator >> applyMigrationScript: script [

	self
		migrateClassesToLatestVersionFor: script;
		migrateInstancesOfRenamedClassesFor: script;
		updateInstancesFor: script
]

{ #category : 'private - actions' }
InstanceMigrator >> applyMigrationScripts [

	| scripts |

	StdoutReporter printLine: [ :out | out << 'Applying migration scripts...' ].

	scripts := self migrationScripts.

	StdoutReporter
		printEmptyLine;
		printInfo: [ :out | out << 'There''s ' << scripts size asString << ' scripts to apply.' ].
	scripts doWithIndex: [ :script :index |
		StdoutReporter printLine: [ :out |
			out << 'Applying script ' << index asString << '/' << scripts size asString ].
		self applyMigrationScript: script
		]
]

{ #category : 'private - actions' }
InstanceMigrator >> checkErrorsIn: migrationReport [
	"migrationReport is an array of five Sets of instances: 
		1. Objects that you cannot read.
		2. Objects that you cannot write.
		3. Objects that are in indexed collections that have different formats.
		4. Objects whose class is not identical to the receiver.
		5. Objects that could not be migrated due to a MigrationError."

	( migrationReport at: 1 ) ifNotEmpty: [ :unreadableObjects |
		self migrationFailed.
		StdoutReporter printError: [ :out |
			out << unreadableObjects size asString << ' instances cannot be read' ]
		].
	( migrationReport at: 2 ) ifNotEmpty: [ :unwritableObjects |
		self migrationFailed.
		StdoutReporter printError: [ :out |
			out << unwritableObjects size asString << ' instances cannot be written' ]
		].
	( migrationReport at: 3 ) ifNotEmpty: [ :incompatibleObjects |
		self migrationFailed.
		StdoutReporter printError: [ :out |
			out << incompatibleObjects size asString
			<< ' instances are in indexed collections with different formats'
			]
		].
	( migrationReport at: 4 ) ifNotEmpty: [ :invalidObjects |
		self migrationFailed.
		StdoutReporter printError: [ :out |
			out << invalidObjects size asString << ' objects are instances of another class' ]
		].
	( migrationReport at: 5 ) ifNotEmpty: [ :failedObjects |
		self migrationFailed.
		StdoutReporter printError: [ :out |
			out << failedObjects size asString << ' instances raised a MigrationError' ]
		]
]

{ #category : 'private - actions' }
InstanceMigrator >> commit [

	System commit
]

{ #category : 'initialization' }
InstanceMigrator >> initialize [

	super initialize.
	self
		initializeMigrationStatus;
		resetClassesWithNewVersions;
		resetRemovedClasses
]

{ #category : 'initialization' }
InstanceMigrator >> initializeMigrationStatus [

	migrationFailed := false
]

{ #category : 'private - accessing' }
InstanceMigrator >> instancesListingForAll: classes [

	self commit.
	^ SystemRepository
		  listInstances: classes asArray
		  limit: 0
		  toDirectory: nil
		  withMaxThreads: self maxThreads
		  maxCpuUsage: self maxCpuPercentage
		  memoryOnly: false
]

{ #category : 'migration' }
InstanceMigrator >> loadFinished [

	StdoutReporter printLine: [ :out | out << 'Finished loading code changes.' ].

	self
		initializeMigrationStatus;
		applyMigrationScripts;
		reportClassesWithNewVersionsNotMigrated;
		reportRemovedClassesWithInstancesNotMigrated;
		runGarbageCollection;
		reportMigrationResult.

	^ self migrationWasSuccessfull
]

{ #category : 'private - actions' }
InstanceMigrator >> migrate: instances of: oldClass [

	| classHistory |

	classHistory := oldClass classHistory.
	self migrate: instances of: oldClass to: classHistory last.
	[ 1 < classHistory size ] whileTrue: [
		| classVersion |

		classVersion := classHistory first.
		classVersion classHistory removeVersion: classVersion
		].
	self commit
]

{ #category : 'private - actions' }
InstanceMigrator >> migrate: instances of: oldClass to: newClass [

	| migrationReport |

	StdoutReporter printLine: [ :out |
		out << '=>> Migrating ' << instances size asString << ' instances of ' << oldClass name asString
		<< ' to ' << newClass name asString
		].
	migrationReport := oldClass migrateInstances: instances to: newClass.
	self checkErrorsIn: migrationReport
]

{ #category : 'private - actions' }
InstanceMigrator >> migrateClassesToLatestVersionFor: script [

	| oldClasses instancesListing |

	oldClasses := OrderedCollection new.
	script classNamesToMigrateToLatestVersion do: [ :className |
		| oldClassOrNil |

		oldClassOrNil := classesWithNewVersions detect: [ :class | class name = className ] ifNone: [
			                 self migrationFailed.
			                 StdoutReporter printError: [ :out |
				                 out << 'There''s no class named ' << className
				                 << ' in the list of classes with new versions. Review you migration scripts.'
				                 ].
			                 nil
			                 ].
		oldClassOrNil ifNotNil: [
			oldClasses add: oldClassOrNil.
			classesWithNewVersions remove: oldClassOrNil
			]
		].
	instancesListing := self instancesListingForAll: oldClasses.
	oldClasses doWithIndex: [ :oldClass :classIndex |
		self migrate: ( instancesListing at: classIndex * 2 ) of: oldClass ]
]

{ #category : 'configuring' }
InstanceMigrator >> migrateInstancesOf: classes [
	"This message is sent once a patch set ends loading changes.
	classesWithNewVersions contains a list of the old class versions"

	classesWithNewVersions addAll: classes
]

{ #category : 'private - actions' }
InstanceMigrator >> migrateInstancesOfRenamedClassesFor: script [

	| oldClasses newClasses instancesListing |

	oldClasses := OrderedCollection new.
	newClasses := OrderedCollection new.
	script classRenameMappings do: [ :mapping |
		| oldClassOrNil oldClassName |

		oldClassName := mapping key.
		oldClassOrNil := removedClasses
			                 detect: [ :class | class name = oldClassName ]
			                 ifNone: [ self notFoundRemovedClassNamed: oldClassName ].
		oldClassOrNil ifNotNil: [
			| newClassOrNil newClassName |

			newClassName := mapping value.

			newClassOrNil := Rowan image resolveClassNamed: newClassName.
			newClassOrNil ifNil: [ self notFoundRenameTargetClassNamed: newClassName ] ifNotNil: [
				oldClasses add: oldClassOrNil.
				newClasses add: newClassOrNil.
				removedClasses remove: oldClassOrNil
				]
			]
		].
	oldClasses ifNotEmpty: [
		instancesListing := self instancesListingForAll: oldClasses.
		oldClasses doWithIndex: [ :oldClass :classIndex |
			| newClass |

			newClass := newClasses at: classIndex.
			self migrate: ( instancesListing at: classIndex * 2 ) of: oldClass to: newClass.
			self commit
			]
		]
]

{ #category : 'private - actions' }
InstanceMigrator >> migrationFailed [

	migrationFailed := true.
	self commit
]

{ #category : 'private - accessing' }
InstanceMigrator >> migrationScripts [

	| scriptClasses |

	scriptClasses := ( GemStone64MigrationScript allSubclasses reject: [ :class | class isAbstract ] )
		                 sortWithBlock: [ :a :b | a priority > b priority ].

	^ scriptClasses collect: [ :class | class new ]
]

{ #category : 'testing' }
InstanceMigrator >> migrationWasSuccessfull [

	^ migrationFailed not
]

{ #category : 'private - actions' }
InstanceMigrator >> notFoundRemovedClassNamed: className [

	self migrationFailed.
	StdoutReporter printError: [ :out |
		out << 'There''s no class named ' << className
		<< ' in the list of removed classes to rename. Review you migration scripts.'
		].
	^ nil
]

{ #category : 'private - actions' }
InstanceMigrator >> notFoundRenameTargetClassNamed: className [

	self migrationFailed.
	StdoutReporter printError: [ :out |
		out << 'There''s no class named ' << className
		<< ' and it''s used as the target in a rename. Review you migration scripts.'
		]
]

{ #category : 'private - reporting' }
InstanceMigrator >> reportClassesWithNewVersionsNotMigrated [

	classesWithNewVersions ifNotEmpty: [
		self migrationFailed.
		StdoutReporter printErrorBanner: [ :out |
			out << 'There are ' << classesWithNewVersions size asString
			<<
			' classes with new versions, but no migration command applicable. Review your migration scripts.'
			].

		classesWithNewVersions do: [ :classWithNewVersion |
			StdoutReporter printError: [ :out | out << '- ' << classWithNewVersion name asString ] ]
		].
	self resetClassesWithNewVersions
]

{ #category : 'private - reporting' }
InstanceMigrator >> reportMigrationResult [

	self migrationWasSuccessfull
		ifTrue: [ StdoutReporter printSuccess: [ :out | out << 'Migration finished successfully.' ] ]
		ifFalse: [ StdoutReporter printError: [ :out | out << 'Migration finished with errors.' ] ]
]

{ #category : 'private - reporting' }
InstanceMigrator >> reportRemovedClassesWithInstancesNotMigrated [

	| instancesListing removedClassesWithInstances |

	self commit.
	instancesListing := self instancesListingForAll: removedClasses.
	removedClassesWithInstances := OrderedCollection new.
	1 to: instancesListing size by: 2 do: [ :countIndex | 
		"For each class we get a count of the instances in the odd indexes,
		and an array with the instances in the even indexes"
		( instancesListing at: countIndex ) = 0 ifFalse: [
			removedClassesWithInstances add: ( removedClasses at: countIndex // 2 + 1 ) ]
		].

	removedClassesWithInstances ifNotEmpty: [
		self migrationFailed.
		StdoutReporter printErrorBanner: [ :out |
			out << 'There are ' << removedClassesWithInstances size asString
			<< ' removed classes but having live instances in the repository.'
			].

		removedClassesWithInstances do: [ :removedClass |
			StdoutReporter printError: [ :out | out << '- ' << removedClass name asString ] ]
		].
	self resetRemovedClasses
]

{ #category : 'initialization' }
InstanceMigrator >> resetClassesWithNewVersions [

	classesWithNewVersions := OrderedCollection new
]

{ #category : 'initialization' }
InstanceMigrator >> resetRemovedClasses [

	removedClasses := OrderedCollection new
]

{ #category : 'actions' }
InstanceMigrator >> runConsistencyChecks [

	self runGarbageCollection.

	StdoutReporter printInfo: [ :out | out << 'Running consistency checks...' ].

	StdoutReporter printLine: [ :out | out << '		[1/2] Checking class histories...' ].
	ClassHistoryChecker new run ifFalse: [ self migrationFailed ].

	StdoutReporter printLine: [ :out | out << '		[2/2] Checking unpublished classes...' ].
	UnpublishedClassesChecker new run ifFalse: [ self migrationFailed ].
	StdoutReporter printEmptyLine.

	^ self migrationWasSuccessfull
]

{ #category : 'private - actions' }
InstanceMigrator >> runGarbageCollection [

	StdoutReporter printInfo: [ :out | out << 'Running the garbage collection...' ].
	self commit.
	SystemRepository fastMarkForCollection.
	self commit.
	SystemRepository reclaimAllWait: -1.
	self commit.
	StdoutReporter printSuccess: [ :out | out << 'Garbage collection completed' ]
]

{ #category : 'private - actions' }
InstanceMigrator >> update: instances of: class [

	| migrationReport |

	StdoutReporter printLine: [ :out |
		out << '=>> Updating ' << instances size asString << ' instances of ' << class name asString ].
	migrationReport := class migrateInstances: instances to: class.
	self checkErrorsIn: migrationReport
]

{ #category : 'private - actions' }
InstanceMigrator >> updateInstancesFor: script [

	| classes instancesListing |

	classes := OrderedCollection new.
	script classNamesToUpdateInstances do: [ :className |
		( Rowan platform globalNamed: className )
			ifNil: [
				self migrationFailed.
				StdoutReporter printError: [ :out |
					out << 'There''s no class named ' << className
					<< ' in the system. Review you migration scripts.' ]
				]
			ifNotNil: [ :class | classes add: class ]
		].
	instancesListing := self instancesListingForAll: classes.
	classes doWithIndex: [ :class :classIndex |
		self update: ( instancesListing at: classIndex * 2 ) of: class ]
]
