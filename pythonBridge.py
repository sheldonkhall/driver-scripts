import re
import pandas
from subprocess import check_output
from shlex import quote



### REMEMBER TO SET THIS PATH BEFORE USING THIS SCRIPT!
_GRAQL_PATH = "PATHNOTSET"
_ANSI_COL_PATH = re.compile(b'\033\[[\d;]*m')


def remove_ansi_cols_from_string(col_string):
	result_string = re.sub(_ANSI_COL_PATH, b'', col_string)
	return result_string

def process_result(result):
	result_dictionary = {}
	for l in result.splitlines():
		for t in l.decode().split(';'):
			t = t.split(maxsplit=2)
			if len(t) > 2:
				k,v = t[0], t[2].rsplit(maxsplit=2)[0]
				if k not in result_dictionary.keys():
					result_dictionary[k] = []
				if len(k)> 0:
					result_dictionary[k] += [v]
	return pandas.DataFrame(result_dictionary).apply(pandas.to_numeric, errors='ignore')


def execute_graql_query(query):
	q = quote(query)
	result = check_output(_GRAQL_PATH + " -e " + q, shell=True)
	result = remove_ansi_cols_from_string(result)
	return result

def process_graql_query(query):
	if _GRAQL_PATH == "PATHNOTSET":
		print('The path to graql.sh must be set before using this script')
		return None
	return process_result(execute_graql_query(query))
