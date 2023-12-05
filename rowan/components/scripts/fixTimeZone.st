"The base extent includes a class history for TimeZone
including two obsolete classes. Clean up this before doing
anything else."

#(ObsoleteTimeZone ObsoleteTimeZone2)
  do: [:obsoleteName |
    (ObsoleteClasses includesKey: obsoleteName)
      ifTrue: [
        | classVersion |
        classVersion := ObsoleteClasses at: obsoleteName.
        classVersion history removeVersion: classVersion.
        ObsoleteClasses removeKey: obsoleteName
      ]
  ]
