Class {
	#name : #LlNoteSnippetElement,
	#superclass : #LeSnippetElement,
	#traits : 'TBlElementError',
	#classTraits : 'TBlElementError classTrait',
	#instVars : [
		'sceneHeightStrategy',
		'sceneResizer',
		'pictureContainer',
		'editorElement',
		'gtUrlUtility',
		'snippetToolbar'
	],
	#category : #LepiterDeNigris
}

{ #category : #initialization }
LlNoteSnippetElement >> initialize [ 
	super initialize.

	self initializeInputFieldsElement.
	self initializeToolbarElement.
	
	self addChild: self inputFieldsElement as: #inputFields.
	self addChild: self toolbarElement as: #toolbar.

	self when: BlClickEvent do: [ :anEvent |
		anEvent consumed: true.
		anEvent currentTarget requestFocus ]
]

{ #category : #initialization }
LlNoteSnippetElement >> initializeInputFieldsElement [
]

{ #category : #accessing }
LlNoteSnippetElement >> newInputNamed: aName onModificationDo: aModificationBlock [
	| aLabel anEditor |
	aLabel := BrLabel new
		look: (BrGlamorousLabelLook new foreground: Color gray);
		text: aName;
		margin: (BlInsets top: 0 right: 0 bottom: 5 left: 0);
		constraintsDo: [ :c | c grid horizontal alignLeft ];
		fitContent.
	self inputFieldsElement addChild: aLabel.
	
	anEditor := BrEditor new
		id: (LeGitHubInputFieldId new name: aName);
		look: BrGlamorousEditorLook + BrGlamorousInputFieldSpacingLook;
		inputFilter: BrTextEditorNoSpaceInputFilter new;
		margin: (BlInsets top: 0 right: 0 bottom: 5 left: 5);
		constraintsDo: [ :c | c grid horizontal alignLeft ];
		vFitContent;
		hMatchParent.
	
	"anEditor editor
		when: BrTextEditorModifiedEvent
		do: aModificationBlock."
		
	self inputFieldsElement addChild: anEditor.
	
	^ anEditor.
]

{ #category : #'api - snippet view model' }
LlNoteSnippetElement >> onSnippetViewModelChanged [
	| db rootDir urlString |
	super onSnippetViewModelChanged.

	db := self snippet database.

	rootDir := (db isDatabase not or: [ db monitor isNil ])
		ifTrue: [ FileLocator workingDirectory resolve ]
		ifFalse: [ db monitor localRoot ].

	urlString := self snippet urlString.
	gtUrlUtility := GtUrlStringUtility new 
		rootDirectory: rootDir;
		urlString: urlString.
	editorElement text: urlString asRopedText.
	self updatePicture
]

{ #category : #'private - event handling' }
LlNoteSnippetElement >> onSnippetViewModelFocused: aBoolean [
	aBoolean
		ifTrue: [ editorElement requestFocus ]
		ifFalse: [ editorElement loseFocus ]
]

{ #category : #'private - event handling' }
LlNoteSnippetElement >> onURLModifiedEvent: anEvent [
	| urlString colour |

	urlString := editorElement text asString.
	gtUrlUtility urlString: urlString.
	colour := gtUrlUtility isValid 
		ifTrue: [ Color black ]
		ifFalse: [ Color red ].
	editorElement text foreground: colour.
	self snippet urlString: urlString source: self
]

{ #category : #accessing }
LlNoteSnippetElement >> pictureUrlString: urlString [
	self urlString: urlString.
]

{ #category : #'api - view' }
LlNoteSnippetElement >> snippetContent [
	"Return an element that represents a content of the snippet.
	The embedder is responsible for placing #snippetContent in the right place within snippet element depending on the
	View Model properties and derived look"
	<return: #BlElement>

	^ pictureContainer
]

{ #category : #'api - view' }
LlNoteSnippetElement >> snippetToolbar [
	"Return an element that represents a toolbar of the snippet. A toolbar usually appears below the snippet content.
	The embedder is responsible for placing #snippetToolbar in the right place within snippet element depending on the
	View Model properties and derived look.
	If returned #snippetToolbar is nil, no toolbar will be added"
	<return: #BlElement or: nil>

	^ snippetToolbar
]

{ #category : #private }
LlNoteSnippetElement >> updatePicture [
	| imageElement |

	imageElement := gtUrlUtility urlString 
		ifEmpty: [ BlElement new size: 0@0 ]
		ifNotEmpty: 
			[ (BlUrlImageElement new url: gtUrlUtility urlString)
				constraintsDo: [ :c |
					c horizontal matchParent.
					c vertical exact: 300. ] ].

	pictureContainer removeChildNamed: #imageElement.
	pictureContainer addChild: imageElement as: #imageElement
]

{ #category : #accessing }
LlNoteSnippetElement >> urlString [
	^ gtUrlUtility urlString
]

{ #category : #accessing }
LlNoteSnippetElement >> urlString: urlString [
	"Set the editor and receiver's snippet URL.
	This is only used by the file selector"

	editorElement text: urlString asRopedText.
	gtUrlUtility urlString: urlString.
	self snippet urlString: urlString source: self.
	self updatePicture
]
