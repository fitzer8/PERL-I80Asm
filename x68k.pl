#!/usr/bin/perl
#################################################################
# Title:      x68k.pl
# Function:   A basic 8080 disassembler.
# Author:     Fitz
#================================================================
# HISTORY
#================================================================
#   DATE   #    NAME    # COMMENT
#================================================================
# 20200407 # Fitz       # Original.
#################################################################
use Data::Dumper;
use Time::Local;

$Version = "0.0.0";
my $File = "x68k.pl";
$IL = 0;
#$DBG = 1;
#my $TST = 0;

#############################################################################
# Include all necessary libraries.
#
$HOME = $ENV{ 'HOME' };
require "$HOME/src/perl/libs/Debug/Debug.pm";
require "$HOME/src/perl/libs/Utils/Utils.pm";
require "$HOME/src/perl/libs/Common/Common.pm";

#require './globals.pm';
require './table.pm';
require './lib.pm';
#require './view.pm';


#MODULE X68000;
#(*------------------------------------------------------------------*)
#(*                                                                  *)
#(*                    MC68000 Cross Assembler                       *)
#(*            Copyright (c) 1985 by Brian R. Anderson               *)
#(*                                                                  *)
#(*   This program may be copied for personal, non-commercial use    *)
#(*   only, provided that the above copyright notice is included     *)
#(*   on all copies of the source code.  Copying for any other use   *)
#(*   without the consent of the author is prohibited.               *)  
#(*                                                                  *)
#(*------------------------------------------------------------------*)

	unshift( @INC, "." );
	#unshift( @INC, "$HOME/src/i8080" );

#   IMPORT Debug;
#
#   FROM Terminal IMPORT
#      WriteString, WriteLn, ReadString;
#
#   FROM FileSystem IMPORT
#      File, Response, Delete, Lookup, Reset, Close;
#
#   FROM Strings IMPORT
#      CompareStr, Assign, Concat, Length;
#
#   IMPORT Strings;   (* For Delete *)
#
#   IMPORT ASCII;
#
#   FROM LongNumbers IMPORT
#      LONG;
#
#   FROM SymbolTable IMPORT
#      SortSymTab;
#
#   FROM Parser IMPORT
#      TOKEN, OPERAND, STRING, LineCount, LineParts;

require "parser.pm";

#   FROM CodeGenerator IMPORT
#      LZero, AddrCnt, Pass2, BuildSymTable, AdvAddrCnt, GetObjectCode;
#
#   FROM Listing IMPORT
#      StartListing, WriteListLine, WriteSymTab;
#
#   FROM Srecord IMPORT
#      StartSrec, WriteSrecLine, EndSrec;
#
#   FROM ErrorX68 IMPORT
#      ErrorCount, WriteErrorCount;
#
#
#   TYPE
#      FileName = ARRAY [0..14] OF CHAR;
#
#
#   VAR
#      SourceFN, ListFN, SrecFN : FileName;
#      Source, List, Srec : File;
#      Label, OpCode : TOKEN;
#      SrcOp, DestOp : OPERAND;
#      EndFile : BOOLEAN;
#      NumSyms : CARDINAL;
#      ObjOp, ObjSrc, ObjDest : LONG;
#      nA, nO, nS, nD : CARDINAL;
#


#################################################################
# Title:	MakeNames
# Function:	Builds names for Source, Listing & S-Record files
#
sub MakeNames {
	my $Proc = "MakeNames";
    my $DBG = 0;
	DebugLevels( "1,2", $Proc );
	if( LevelCheck( 1, $Proc ) and $DBG )
		{ ntry( $File, $Proc ); }
 
 

	$_ = $SourceFN;
	s/\.ASM/\.LST/;
	$ListFN = $_;
	$_ = $SourceFN;
	s/\.ASM/\.S/;
	$SrecFN = $_;
	if( LevelCheck( 2, $Proc ) and $DBG ) {
		print "List File: $ListFN\n";
		print "Srec File: $SrecFN\n";
	}

#   PROCEDURE MakeNames (VAR S, L, R : FileName);
#
#      VAR
#         T : FileName;   (* temporary work name *)
#         i, l : CARDINAL;
#
#      BEGIN
#         L := '';   R := '';   (* set Listing & S-rec names to null *)
#
#         i := 0;   l := 0;
#         WHILE (S[i] # 0C) AND (S[i] # ' ') DO
#            IF S[i] = '.' THEN   (* mark beginning of file extension *)
#               l := i;
#            END;
#            S[i] := CAP (S[i]);
#            INC (i);
#         END;
#      
#         IF S[i] = ' ' THEN
#            Strings.Delete (S, i, Length (S) - i);
#         END;
#
#         Assign (S, T);
#         IF l = 0 THEN
#            Concat (T, ".ASM", S);
#         ELSE   
#            Strings.Delete (T, l, i - l);
#         END;
#
#         Concat (T, ".LST", L);
#         Concat (T, ".S", R);
	if( LevelCheck( 1, $Proc ) and $DBG ) {
		xit( $File, $Proc );
	}
} # sub MakeNames

1; 


#################################################################
# Title:	OpenFiles
# Function:	Get the media servers for the supplied CM list.
#
#   PROCEDURE OpenFiles;
#      BEGIN
sub OpenFiles {
	my $Proc = "OpenFiles";
    my $DBG = 1;
	DebugLevels( "1,2", $Proc );
	if( LevelCheck( 1, $Proc ) and $DBG )
		{ ntry( $File, $Proc ); }
 
	if( LevelCheck( 2, $Proc ) and $DBG ) {
		print "List File: $ListFN\n";
		print "Srec File: $SrecFN\n";
	}
 
#         Lookup (Source, SourceFN, FALSE);
	if( !-f $SourceFN ) {
		print "No source file: $SourceFN\n";
		exit;
#         IF Source.res # done THEN
#            WriteLn;
#            WriteString ("No Source File: ");   WriteString (SourceFN);   
#            WriteLn;
#            HALT;
#         END;
	}

	if( -f $ListFN ) {
		unlink( $ListFN );
#         Delete (ListFN, List);   (* Just in case file already exists *)
	} # if( -f $ListFN )
	open( LST, ">$ListFN" ) || die "Can't open the listing file: $ListFN";
#         Lookup (List, ListFN, TRUE);   
	if( !-f $ListFN ) {
#         IF List.res # done THEN    (* DOS may trap this *)
#            WriteLn;
#            WriteString ("Cannot create disk files!");   WriteLn;
		print "Cannot create disk file!\n";
		exit;
#            HALT;
#         END;
	}
#
	if( -f $SrecFN ) {
		unlink( $SrecFN );
#         Delete (SrecFN, Srec);
	} # if( -f $SrecFN )
	open( LST, ">$SrecFN" ) || die "Can't open the Srecord file: $SrecFN";
#         Lookup (Srec, SrecFN, TRUE);
	if( !-f $SrecFN ) {
#         IF Srec.res # done THEN
#            WriteLn;
#            WriteString ("Cannot create disk files!");   WriteLn;
		print "Cannot create disk file!\n";
		exit;
#            HALT;
#         END;
	}
#      END OpenFiles;

	if( LevelCheck( 1, $Proc ) and $DBG ) {
		xit( $File, $Proc );
	}
} # sub OpenFiles




#   PROCEDURE StartPass2;
#      BEGIN
#         Reset (Source);
#         IF Source.res # done THEN
#            WriteString ("Unable to 'Reset' Source file for 2nd Pass.");
#            WriteLn;
#            HALT;
#         END;
#         Pass2 := TRUE;   (* Pass2 IMPORTed from CodeGenerator *)
#         AddrCnt := LZero;   (* Assume ORG = 0 to start *)
#         ErrorCount := 0;   (* ErrorCount IMPORTed from ErrorX68 *)
#         LineCount := 0;   (* LineCount IMPORTed from Parser *)
#         EndFile := FALSE;
#      END StartPass2;
#
#
#
#   PROCEDURE CloseFiles;
#      BEGIN
#         Close (Source);
#         Close (List);
#         Close (Srec);
#         IF (Source.res # done) OR (List.res # done) OR (Srec.res # done) THEN
#            WriteString ("Error closing files...");   WriteLn;
#            HALT;
#         END;
#      END CloseFiles;
#


#################################################################
# Title:	X68000 -- Main
# Function:	Main routine to the Mc6800 Assembler..
#
sub Main {
	my $Proc = "Main";
    my $DBG = 1;
	DebugLevels( "1,2", $Proc );
	if( LevelCheck( 1, $Proc ) and $DBG )
		{ ntry( $File, $Proc ); }
 
	print "\n"; 
	$SourceFN = $ARGV[ 0 ];
	if( !$SourceFN ) {
		print "No file name provided\n";
		print "Exiting!\n";
		exit;
	}
	print "Source File: $SourceFN\n";

#   ReadString (SourceFN);
#   WriteLn;
#
	MakeNames( $SourceFN, $ListFN, $SrecFN );   
#
	OpenFiles();
#
#   WriteLn;
#   WriteString ("                 68000 Cross Assembler");   WriteLn;
	print "                 68000 Cross Assembler\n";
#   WriteString ("         Copyright (c) 1985 by Brian R. Anderson");
print "         Copyright (c) 1985 by Brian R. Anderson\n\n";
#   WriteLn;   WriteLn;
#   WriteString ("                 Assembling ");   WriteString (SourceFN);  
print "                 Assembling $SourceFN\n\n\n";
#   WriteLn;   WriteLn;   WriteLn;
#
#
#(*---
#    Begin Pass 1 
#                  ---*)
#   WriteString ("PASS 1");   WriteLn;
print "PASS 1\n";
#   AddrCnt := LZero;   (* Assume ORG = 0 to start *)
	$AddrCnt = 0;   # Assume ORG = 0 to start *)
#   EndFile := FALSE;
	$EndFile = 0;
#
#   REPEAT
open( SRC, "<$SourceFN" ) || die "Can't open ASM file: $SourceFN";
$Line = <SRC>;
do {
	if( LevelCheck( 1, $Proc ) and $DBG ) {
		print "Line: \"$Line\"";
	}
	$LineCount++;
	#statement(s);
#      LineParts (Source, EndFile, Label, OpCode, SrcOp, DestOp);
	LineParts( $Source, $EndFile, $Label, $OpCode, $SrcOp, $DestOp );
#      
#      BuildSymTable (AddrCnt, Label, OpCode, SrcOp, DestOp);
#
#      AdvAddrCnt (AddrCnt);
#
if( $OpCode eq "END" )
	{ $EndFile = 1; }
#   UNTIL EndFile OR (CompareStr (OpCode, "END") = 0);
	# } while( !$EndFile || ( $OpCode eq "END" ));
	# } while( yyp!$EndFile );
} while( $Line = <SRC> );

	$EndFile = 0;


#(*---
#   Begin Pass 2 
#               ---*)
#   WriteString ("PASS 2");   WriteLn;
	print "PASS 2\n";
#   StartPass2;   (* get Source file, Parser & ErrorX68 ready for 2nd pass *)
#   SortSymTab (NumSyms);
#   StartListing (List);
#   StartSrec (Srec, SourceFN);
#
#   REPEAT
#      LineParts (Source, EndFile, Label, OpCode, SrcOp, DestOp);
#
#      GetObjectCode (Label, OpCode,
#                     SrcOp,  DestOp, 
#                     AddrCnt, ObjOp, ObjSrc, ObjDest, 
#                     nA,      nO,    nS,     nD      );
#
#      WriteListLine (List, AddrCnt, ObjOp, ObjSrc, ObjDest, nA, nO, nS, nD);
#
#      WriteSrecLine (Srec, AddrCnt, ObjOp, ObjSrc, ObjDest, nA, nO, nS, nD); 
#      
#      AdvAddrCnt (AddrCnt);
#
#   UNTIL EndFile OR (CompareStr (OpCode, "END") = 0);
#
#   EndSrec (Srec);   (* Also: Finish off any partial line *)
#   WriteErrorCount (List);   (* Error count output to Console & Listing file *)
#   WriteSymTab (List, NumSyms);   (* Write Symbol Table to Listing File *)
#   CloseFiles;
 
	if( LevelCheck( 1, $Proc ) and $DBG ) {
		xit( $File, $Proc );
	}
} # sub Main

Main();

if( LevelCheck( 1, $Proc ) and $DBG ) {
	xit( $File, $Proc );
} # END x68k.pl.




