import sys, re


#function to remove comments
def comment_remover(current_text):
	expr = re.compile(r'"(\\.|[^\\"])*"|/\*.*?\*/|//.*?$', re.DOTALL | re.MULTILINE)
	comment_substituter = " "
	modified_text = re.sub(expr, comment_substituter, current_text)
	return modified_text

#function to substitute macros
def alias_remover(current_text):
	expr = r'(#define .*?)[\n$]'
	macros = re.findall(expr, current_text)
	alias_substituter = " "
	modified_text = re.sub(expr, alias_substituter, current_text)
	for macro in macros:
		macro_list = macro.split(' ')
		# print(macro_list)
		key = r'\b'+macro_list[1]+r'\b'
		replacement = ' '.join(macro_list[2:])
		modified_text = re.sub(key, replacement, modified_text)
	return modified_text

#initialization of variables and lists
count_inherited_class = 0
count_class = 0
count_operator_overload = 0
count_constructors = 0
count_object = 0

inherited_classes_list = list()
classes_list = list()
operator_overload_list = list()
constructors_list = list()
objects_map = {}

#function to get count and list of classes and inherited classes
def getClasses(current_text):
	individual_lines=current_text.split('\n')
	global count_inherited_class
	global count_class
	global count_constructors
	global count_operator_overload

	global inherited_classes_list
	global classes_list
	global operator_overload_list
	global constructors_list

	for line in individual_lines:
		line = line + '\n'
		#regular expression to identify class
		class_regex = r'\bclass\b\s+([A-Za-z_]\w*)\s*[\n\{]'
		classes = re.findall(class_regex, line)

		#regular expression to identify inherited class
		inherited_class_regex=r'\bclass\b\s+([A-Za-z_]\w*)\s*\:\s*((?:private|protected|public)?\s+(?:[A-Za-z_]\w*)\s*\,?\s*)+[\n\{]'
		inherited_classes=re.findall(inherited_class_regex, line)

		is_present_class = False
		is_present_inherited_class = False

		if len(classes)>0:
			is_present_class=True
		if len(inherited_classes)>0:
			is_present_inherited_class=True

		if is_present_class:
			count_class += 1
		if is_present_inherited_class:
			count_inherited_class += 1
			# count_inherited_class +=len(inherited_classes)
			count_class += 1
			# count_class += len(inherited_classes)

		for class_item in classes:
			classes_list.append(class_item)
			# print(class_item)
		for inherited_class in inherited_classes:
			inherited_classes_list.append(inherited_class[0])
			classes_list.append(inherited_class[0])
			# print(inherited_class)

#function to get count and list of overloaded function
def getOverloadedFunctions(current_text):
	individual_lines=current_text.split('\n')
	global count_operator_overload
	global operator_overload_list

	for line in individual_lines:
		line = line + '\n'
		#regular expression to identify overloaded operators
		operators_regex=r'(\+=|-=|\*=|/=|%=|\^=|&=|\|=|==|!=|<=|>=|<=>|<<|>>|>>=|<<=|&&|\|\||\+\+|--|\,|->\*|\\->|\+|-|\*|/|%|\^|&|\||~|!|=|<|>|\(\s*\)|\[\s*\])'
		operators_overload_regex=r'\boperator\b\s*' + operators_regex + r'\s*([^\{\;]*)?[\n\{]'

		operators_overload=re.findall(operators_overload_regex, line);

		is_present_operator_overload = False

		if len(operators_overload)>0:
			is_present_operator_overload=True
		if is_present_operator_overload:
			count_operator_overload += 1
				# count_operator_overload += len(operators_overload)
		for operators_overload_item in operators_overload:
			operator_overload_list.append(operators_overload_item)
				# print(operators_overload_item)

#function to get count and list of consturctors
def getConstructors (current_text) :
	global count_inherited_class
	global count_class
	global count_constructors
	global count_operator_overload

	global inherited_classes_list
	global classes_list
	global operator_overload_list
	global constructors_list

	lines = current_text.split('\n')
	#regular expression to identify constructor
	constructor_reg_exp = r'(?:[^~]|^)\b([A-Za-z_][\w\:\s]*)\s*\(([^)]*?)\)?\s*[\n\{\:]'
	for line in lines:
		is_constructor = False
		line = line + '\n'
		list_constructors = re.findall(constructor_reg_exp, line)
		for constructor in list_constructors:
			# print(constructor)
			group_name = constructor[0]
			names = group_name.split('::')
			new_list = list()
			for name in names:
				new_list.append(name.strip())
			names = new_list
			constructor_name = names[-1]
			# print(constructor_name)
			if constructor_name in classes_list:
				if len(names) == 1 or names[-1] == names[-2]:
					is_constructor = True
					constructors_list.append(constructor)
		if is_constructor:
			count_constructors = count_constructors + 1

#function to get count and map of objects belonging to each class
def getObjects (current_text):
	individual_lines=current_text.split('\n')
	global count_object
	global objects_map
	global classes_list

	for line in individual_lines:
		line = line + '\n'
		#regular expression to identify objects
		object_regex=r'([A-Za-z_]\w*)\b\s*([\s\*]*[A-Za-z_\,][A-Za-z0-9_\.\,\[\]\s\(\)]*[^\n<>]*?);'

		objects=re.findall(object_regex, line);

		is_present_object = False
		for object_item in objects:
			if object_item[0] in classes_list:
				if object_item[0] in objects_map:
					objects_map[object_item[0]] += (object_item[1]+',')
				else:
				    objects_map[object_item[0]] = ''
				    objects_map[object_item[0]] += (object_item[1]+',')
				is_present_object = True
				# print(objects_map[object_item[0]])
		if is_present_object:
			count_object += 1

#function to write output in output file
def print_to_file(file):
	global count_inherited_class
	global count_class
	global count_constructors
	global count_operator_overload
	global count_object

	global inherited_classes_list
	global classes_list
	global operator_overload_list
	global constructors_list
	global objects_map

	with open(file, "a") as f:
		f.write("C++ Code Analyser Output: \n")
		f.write("Count of Object Declarations:\t\t\t\t" + str(count_object) + '\n')
		f.write("Count of Class Definitions:\t\t\t\t" + str(count_class) + '\n')
		f.write("Count of Constructor Definitions:\t\t\t" + str(count_constructors) + '\n')
		f.write("Count of Inherited Class Definitions:\t\t\t" + str(count_inherited_class) + '\n')
		f.write("Count of Operator Overloaded Function Definitions:\t" + str(count_operator_overload) + '\n')
		f.write("\n")
		f.write("Object Declarations:\n")

		for object in objects_map:
			f.write(object + ": " + objects_map[object] + "\n")
		f.write("\nClass Definitions: " + str(classes_list) + "\n")
		f.write("\nConstructor Definitions: " + str(constructors_list) + "\n")
		f.write("\nInherited Class Definitions: " + str(inherited_classes_list) + "\n")
		f.write("\nOperator Overloaded Function Definitions: " + str(operator_overload_list) + "\n")


#main function which is called initially to read the file and find all required counts
if __name__ == '__main__':
	out_file = open("output.txt",'w')
	in_file = open("input.txt").read()
	in_file = comment_remover(in_file)
	in_file = alias_remover(in_file)
	# print (in_file)
	getClasses(in_file)
	getOverloadedFunctions(in_file)
	getConstructors(in_file)
	getObjects(in_file)
	print_to_file("output.txt")
