#!/usr/bin/env python

import sys;
import argparse as ap;

authorInfo = '''
Author: Zhenguo Zhang
Email: zhangz.sci@gmail.com
''';

desc=f'''
This program tests whether a file is sorted.

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

op.add_argument("-f" "--sep",
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

args=op.parse_args();

if args.numFields is None and args.strFields is None:
	print("At least one of the options '--str-field' and '--num-field' need be provided", file=sys.stderr);
	sys.exit("*** Insufficient arguments ***");

nF=args.numFields;
sF=args.strFields;

f=open(args.infile, "r");

for r in f:
	r=r.strip().split(args.sep);
	if nF is not None:
		nums=map(int, r[nF]);
	if sF is not None:


f.close();

sys.exit(0);

