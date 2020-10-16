Class {
	#name : #BaselineOfLepiterDeNigris,
	#superclass : #BaselineOf,
	#category : #BaselineOfLepiterDeNigris
}

{ #category : #baselines }
BaselineOfLepiterDeNigris >> baseline: spec [
	<baseline>

	spec for: #'common' do: [
		spec package: #'LepiterDeNigris' with: [ ] ]
]
