"
In GemStone/S 64 `PrivateObject` is the superclass of certain classes used in the implementation.
Instances of subclasses of `PrivateObject` are normally not visible to Smaltalk,
and if they are returned by a primitive, many of the methods defined in `Object`
are not safe to send to these instances.

This version is just a placeholder so we can easily create extensions methods to load in GS64 specific
packages.
"
Class {
	#name : 'PrivateObject',
	#superclass : 'Object',
	#category : 'GS64-Migration-Tools-Compatibility',
	#package : 'GS64-Migration-Tools-Compatibility'
}
