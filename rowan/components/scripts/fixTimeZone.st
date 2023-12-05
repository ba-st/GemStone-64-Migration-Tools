"The base extent includes a class history for TimeZone
including two obsolete classes. Clean up this before doing
anything else."
| classHistory |

classHistory := TimeZone classHistory.
classHistory size > 1 ifTrue: [
  [ 1 < classHistory size ] whileTrue: [
  | classVersion |
  classVersion := classHistory first.
  classHistory removeVersion: classVersion
  ].
].
