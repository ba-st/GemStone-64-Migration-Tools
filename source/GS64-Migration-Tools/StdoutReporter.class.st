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
		printInfo: [ :out | out << '##################################################' ];
		printInfo: aBlock;
		printInfo: [ :out | out << '##################################################' ];
		printEmptyLine
]

{ #category : 'printing' }
StdoutReporter class >> printEmptyLine [

	self printLine: [ :out |  ]
]

{ #category : 'printing' }
StdoutReporter class >> printError: aBlock [

	self printLine: [ :out |
		out << Character esc << '[1m'.
		out << Character esc << '[31m'.
		aBlock value: out.
		out << Character esc << '[0m'
		]
]

{ #category : 'printing' }
StdoutReporter class >> printErrorBanner: aBlock [

	self
		printEmptyLine;
		printError: [ :out | out << '##################################################' ];
		printError: aBlock;
		printError: [ :out | out << '##################################################' ];
		printEmptyLine
]

{ #category : 'printing' }
StdoutReporter class >> printInfo: aBlock [

	self printLine: [ :out |
		out << Character esc << '[1m'.
		out << Character esc << '[34m'.
		aBlock value: out.
		out << Character esc << '[0m'
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

	self printLine: [ :out |
		out << Character esc << '[1m'.
		out << Character esc << '[32m'.
		aBlock value: out.
		out << Character esc << '[0m'
		]
]

{ #category : 'printing' }
StdoutReporter class >> printWarning: aBlock [

	self printLine: [ :out |
		out << Character esc << '[1m'.
		out << Character esc << '[33m'.
		aBlock value: out.
		out << Character esc << '[0m'
		]
]
