package model

#Name: string & =~"^[a-zA-Z][a-zA-Z0-9_]*$"
#Symbol: {
	key!:    #Name
	name!:   #Name
	module?: #Name
}
#Symbols: {
	marks: [...#Symbol]
	attributes: [...#Symbol]
	encodings: [...#Symbol]
	legends: [...#Symbol]
}
#PythonMark: {
	#Symbol
	description!: string
	channels!: [...#Name]
}
