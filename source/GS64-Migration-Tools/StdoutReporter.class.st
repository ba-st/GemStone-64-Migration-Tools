Class {
	#name : 'StdoutReporter',
	#superclass : 'Object',
	#category : 'GS64-Migration-Tools',
	#package : 'GS64-Migration-Tools'
}

{ #category : 'printing' }
StdoutReporter class >> printBanner: aBlock [

	self
		printEmptyLine;
		printInfo: [ :s | s << '##################################################' ];
		printInfo: aBlock;
		printInfo: [ :s | s << '##################################################' ];
		printEmptyLine
]

{ #category : 'printing' }
StdoutReporter class >> printEmptyLine [

	self printLine: [ :s |  ]
]

{ #category : 'printing' }
StdoutReporter class >> printError: aBlock [

	self printLine: [ :s |
		s << Character esc << '[1m'.
		s << Character esc << '[31m'.
		aBlock value: s.
		s << Character esc << '[0m'
		]
]

{ #category : 'printing' }
StdoutReporter class >> printErrorBanner: aBlock [

	self
		printEmptyLine;
		printError: [ :s | s << '##################################################' ];
		printError: aBlock;
		printError: [ :s | s << '##################################################' ];
		printEmptyLine
]

{ #category : 'printing' }
StdoutReporter class >> printInfo: aBlock [

	self printLine: [ :s |
		s << Character esc << '[1m'.
		s << Character esc << '[34m'.
		aBlock value: s.
		s << Character esc << '[0m'
		]
]

{ #category : 'printing' }
StdoutReporter class >> printLine: aBlock [

	aBlock value: GsFile stdout.
	GsFile stdout
		lf;
		flush
]

{ #category : 'printing' }
StdoutReporter class >> printSuccess: aBlock [

	self printLine: [ :s |
		s << Character esc << '[1m'.
		s << Character esc << '[32m'.
		aBlock value: s.
		s << Character esc << '[0m'
		]
]

{ #category : 'printing' }
StdoutReporter class >> printWarning: aBlock [

	self printLine: [ :s |
		s << Character esc << '[1m'.
		s << Character esc << '[33m'.
		aBlock value: s.
		s << Character esc << '[0m'
		]
]
