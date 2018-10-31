#!/usr/bin/env python

import sys;
import argparse as ap;

# define functions

def warn(s):
	'''
	A function to output warning message
	'''
	print('[warning] ' + s, file=sys.stderr);

authorInfo = '''
Author: Zhenguo Zhang
Email: zhangz.sci@gmail.com
''';

desc=f'''
This program tests whether a file is sorted.

**Note**: string fields (by option '--str-field') are compared before
number fields (by option '--num-field').

Default options are in [].

E.g.: {sys.argv[0]} test.in -n 1 3 -s 2 4 -f , 
''';

op=ap.ArgumentParser(
		description=desc,
		formatter_class=ap.RawTextHelpFormatter,
		epilog=authorInfo
		);

op.add_argument("infile",
		help="input files");

op.add_argument("-f", "--sep",
		help="field separator [<tab>]",
		dest="sep",
		default="\t",
		action='store',
		type=str);

op.add_argument("--num-field","-n",
		help="the fields using number comparison. Given by column numbers. The first column in 0",
		nargs="*",
		dest="numFields",
		action='store',
		type=int
		);

op.add_argument("--str-field","-s",
		help="the fields using string comparison. Given by column numbers. The first column is 0 ",
		nargs="*",
		dest="strFields",
		action='store',
		type=int
		);

op.add_argument("--lines-skip","-l",
		help="the number of lines to skip at the beginning [0]",
		type=int,
		default=0,
		dest='skipped',
		action='store'
		);

args=op.parse_args();

if args.numFields is None and args.strFields is None:
	warn("At least one of the options '--str-field' and '--num-field' need be provided");
	sys.exit("*** Insufficient arguments ***");

nF=args.numFields;
sF=args.strFields;
skipped=args.skipped;

f=open(args.infile, "r");
preData=None;
for r in f:
	if skipped > 0: # skip lines
		skipped -= 1;
		continue;
	r=r.strip().split(args.sep);
	data=[];
	if sF is not None:
		data.extend([r[i] for i in sF]);
	if nF is not None:
		nums=[int(r[i]) for i in nF];
		data.extend(nums);
	if preData is not None:
		if preData > data:
			print("The file is not sorted [{0}]".format(args.sep.join(r)))
			sys.exit(0);
	# update data
	preData=data;

f.close();

print(f"The file {args.infile} is sorted");

sys.exit(0);

