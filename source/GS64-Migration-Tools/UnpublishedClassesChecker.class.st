"
Instances of `UnpublishedClassesChecker`, when run, verify that all classes
belongs to some SymbolDictionary. A situation that can arise when removing classes
with instances still referenced in the repository.

For this checker to work flawlessly it need that `SystemRepository markForCollection` and
`SystemRepository reclaimAll` were already run before.
"
Class {
	#name : 'UnpublishedClassesChecker',
	#superclass : 'Object',
	#category : 'GS64-Migration-Tools',
	#package : 'GS64-Migration-Tools'
}

{ #category : 'private - testing' }
UnpublishedClassesChecker >> is: class publishedInAnyOf: allSymbolDictionaries [
	"Subclasses of PrivateObject are somehow special and it's expected they aren't published.
	ObsoleteClasses aren't published.
	For the normal classes we check that they are included in some symbol dictionary"

	^ ( class inheritsFrom: PrivateObject ) or: [
		  ( ObsoleteClasses includesKey: class name ) or: [
			  allSymbolDictionaries anySatisfy: [ :symbolDictionary |
				  ( symbolDictionary includesKey: class name ) and: [
					  ( symbolDictionary at: class name ) == class ] ]
			  ]
		  ]
]

{ #category : 'private - reporting' }
UnpublishedClassesChecker >> reportUnpublishedClasses: classes [

	StdoutReporter printErrorBanner: [ :out |
		out << ' ' << classes size asString << ' classes are unpublished' ].

	classes do: [ :unpublishedClass |
		StdoutReporter printLine: [ :out | out << '- ' << unpublishedClass name asString ] ]
]

{ #category : 'running' }
UnpublishedClassesChecker >> run [

	| allMetaclasses allSymbolDictionaries unpublishedClasses |

	unpublishedClasses := OrderedCollection new.

	StdoutReporter printInfo: [ :s | s << 'Searching for unpublished classes...' ].

	allMetaclasses := Metaclass3 allInstances.
	allSymbolDictionaries := SymbolDictionary allInstances.

	( SystemRepository listInstances: allMetaclasses ) do: [ :classes |
		| class |

		"There's only one instance of each metaclass, the class per-se."
		class := classes first.

		( self is: class publishedInAnyOf: allSymbolDictionaries ) ifFalse: [
			unpublishedClasses add: class ]
		].

	unpublishedClasses ifNotEmpty: [ self reportUnpublishedClasses: unpublishedClasses ].

	^ unpublishedClasses isEmpty
]
