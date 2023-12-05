"The base extent includes a class history for TimeZone
including two obsolete classes. Clean up this before doing
anything else."
| classHistory |
(ObsoleteClasses includesKey: #ObsoleteTimeZone)
  ifTrue: [ ObsoleteClasses removeKey: #ObsoleteTimeZone ].
(ObsoleteClasses includesKey: #ObsoleteTimeZone2)
  ifTrue: [ ObsoleteClasses removeKey: #ObsoleteTimeZone2 ].

classHistory := TimeZone classHistory.
classHistory size > 1 ifTrue: [
  [ 1 < classHistory size ] whileTrue: [
  | classVersion |
  classVersion := classHistory first.
  classHistory removeVersion: classVersion
  ].
].
