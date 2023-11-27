"
This check verify that all classes in the system only have one version in the class history.
"
Class {
	#name : 'ClassHistoryChecker',
	#superclass : 'Object',
	#category : 'GS64-Migration-Tools',
	#package : 'GS64-Migration-Tools'
}

{ #category : 'running' }
ClassHistoryChecker >> run [

	| classesWithHistory |

	classesWithHistory := Object allSubclasses select: [ :class | class classHistory size > 1 ].

	classesWithHistory ifNotEmpty: [
		StdoutReporter printErrorBanner: [ :out |
			out << ' ' << classesWithHistory size asString << ' classes have more than one version' ].

		classesWithHistory do: [ :class |
			StdoutReporter printLine: [ :out | out << '- ' << class name asString ] ]
		].

	^ classesWithHistory isEmpty
]
