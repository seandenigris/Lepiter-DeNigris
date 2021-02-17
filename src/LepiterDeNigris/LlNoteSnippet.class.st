Class {
	#name : #LlNoteSnippet,
	#superclass : #LeSnippet,
	#instVars : [
		'urlString'
	],
	#category : #'LepiterDeNigris-Model'
}

{ #category : #factory }
LlNoteSnippet class >> empty [ 

	^ self new
]

{ #category : #jsonV3 }
LlNoteSnippet class >> leJsonV3AttributeMapping [

	^ super leJsonV3AttributeMapping
		add: (#urlString -> #url);
		yourself
]

{ #category : #accessing }
LlNoteSnippet class >> leJsonV3Name [

	^ 'llNoteSnippet'
]

{ #category : #visiting }
LlNoteSnippet >> acceptVisitor: aVisitor [

	^ aVisitor llVisitNoteSnippet: self
]

{ #category : #converting }
LlNoteSnippet >> asContentUIModel [
	<return: #LeContentViewModel>
	^ LlNoteSnippetViewModel new snippet: self
]

{ #category : #accessing }
LlNoteSnippet >> asIconSizedElement [
	| uiModel elem image |
	uiModel := self asContentUIModel.
	elem:= uiModel snippetView asElement.
	elem snippetViewModel: uiModel.
	image := BlUrlImageElement new url:elem urlString.
	image constraintsDo: [ :c |
					c horizontal matchParent.
					c vertical matchParent. ].
	^ image
]

{ #category : #'api - accessing' }
LlNoteSnippet >> content [
	^ urlString
]

{ #category : #initialization }
LlNoteSnippet >> initialize [
	super initialize.

	urlString := ''
]

{ #category : #'api - testing' }
LlNoteSnippet >> isEmpty [
	^ super isEmpty and: [ urlString isEmpty ]
]

{ #category : #accessing }
LlNoteSnippet >> isPicture [
	^ true
]

{ #category : #'private - exporting' }
LlNoteSnippet >> markdownOn: stream level: anInteger [
	"Write the receiver as an HTML string on the supplied stream.
	This is currently a simplistic implementation which doesn't handle line breaks within the block properly (they need to be indented)"

	self isEmpty ifTrue: [ ^ self ].

	anInteger * 4 timesRepeat:
		[ stream nextPut: Character space ].
	stream 
		<< '- ';
		<< self string trimBoth.

	self childrenDo: [ :child |
		stream cr.
		child markdownOn: stream level: anInteger + 1 ]
]

{ #category : #accessing }
LlNoteSnippet >> pictureFileBytes [
	^ self urlString asFileReference binaryReadStream upToEnd.
]

{ #category : #accessing }
LlNoteSnippet >> string [ 

	^ urlString 
		ifEmpty: [ '' ]
		ifNotEmpty: [ '![](', urlString, ')' ]
]

{ #category : #'api - accessing' }
LlNoteSnippet >> title [ 
	^ urlString ifEmpty: [ '<an empty picture>' ]
]

{ #category : #accessing }
LlNoteSnippet >> urlString [ 
	<return: #String>

	^ urlString
]

{ #category : #accessing }
LlNoteSnippet >> urlString: aString [

	^ self urlString: aString source: self
]

{ #category : #accessing }
LlNoteSnippet >> urlString: aString source: anObject [
	"Change the url string of a picture.
	The String may not neccessarily be a fully valid URL"
	self
		assert: [ aString notNil ]
		description: [ 'URL string must not be nil' ].

	self urlString = aString
		ifTrue: [ ^ self ].

	urlString := aString.
	self updateEditTimeAndEmail.
	self updateUnlinkedReferences.
	self announceTextChangedBy: anObject
]
