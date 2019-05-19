# https://www.cs.rochester.edu/~brown/173/readings/05_grammars.txt
#
#  "TINY" Grammar
#
# PGM        -->   STMT+
# STMT       -->   ASSIGN   |   "print"  EXP
# ASSIGN     -->   ID  "="  EXP
# EXP        -->   TERM   ETAIL
# ETAIL      -->   "+" TERM   ETAIL  | "-" TERM   ETAIL | EPSILON
# TERM       -->   FACTOR  TTAIL
# TTAIL      -->   "*" FACTOR TTAIL  | "/" FACTOR TTAIL | EPSILON
# FACTOR     -->   "(" EXP ")" | INT | ID
# ID         -->   ALPHA+
# ALPHA      -->   a  |  b  | … | z  or
#                  A  |  B  | … | Z
# INT        -->   DIGIT+
# DIGIT      -->   0  |  1  | …  |  9
# WHITESPACE -->   Ruby Whitespace

#
#  Parser Class
#
load "Token.rb"
load "Lexer.rb"
#load "Scanner.rb"

class Parser < Scanner
	def initialize(filename)
    	super(filename)
    	consume()
		
		@etail = 0
		@ttail = 0
		@count = 0
	end
	
	def consume()
      	@lookahead = nextToken()
      	while(@lookahead.type == Token::WS)
        	@lookahead = nextToken()
		end
	end
	
	def match(dtype)
      	if (@lookahead.type != dtype)
         	raise "Expected #{dtype} found #{@lookahead.type}"
      	end
      	consume()
	end
	
	def error_checker()
		if (@count == 0)
			puts "Program parsed with no errors."
		elsif (@count == 1)
			puts "There was 1 error found."
		else
			puts "There were #{@count} errors found."
		end
	end

	def ent_etail()
			@etail = 1
	end

	def leave_etail()
		 if (@etail != 0)
			 puts "Did not find ADDOP or SUBOP Token, choosing EPSILON production"
		 end
		 @etail = 0
	end

	def ent_ttail()
		@ttail = 1
	end

	def leave_ttail()
		if (@ttail != 0)
			puts "Did not find MULTOP or DIVOP Token, choosing EPSILON production"
		end
		@ttail = 0
	end
   	
	def match_checker(dtype, v)
		tt = @lookahead.text
		begin
			match(dtype)
			puts "Found #{v} Token: #{tt}"
			return true
		rescue
			puts "Expected to find #{v} Token here. Instead found: #{tt}"
			@count = @count + 1
			consume()
			return false
		end
	end
	
	def assign()
		puts "Entering ID Rule"
		match_checker(Token::ID, "ID")
		puts "Exiting ID Rule"
		match_checker(Token::ASSGN, "ASSGN")
		puts "Entering EXP Rule"
		exp()
		puts "Exiting ASSGN Rule"
	end

	def exp()
		puts "Entering TERM Rule"
		term()
		puts "Entering ETAIL Rule"
		etail()
		puts "Exiting EXP Rule"
	end

	def term()
		puts "Entering FACTOR Rule"
		factor()
		puts "Entering TTAIL Rule"
		ttail()
		puts "Exiting TERM Rule"
	end

	def etail()
		ent_etail()
		if (@lookahead.type == Token::ADDOP || @lookahead.type == Token::SUBOP)
			if (@lookahead.type == Token::ADDOP)
				match_checker(Token::ADDOP, "ADDOP")
			else
				match_checker(Token::SUBOP, "SUBOP")
			end
			puts "Entering TERM Rule"
			term()
			puts "Entering ETAIL Rule"
			etail()
		end
		leave_etail()
		puts "Exiting ETAIL Rule"
	end

	def factor()
		if (@lookahead.type == Token::LPAREN)
			match_checker(Token::LPAREN, "LPAREN")
			puts "Entering EXP Rule"
			exp()
			match_checker(Token::RPAREN, "RPAREN")
		elsif (@lookahead.type == Token::INT)
			match_checker(Token::INT, "INT")
		elsif(@lookahead.type == Token::ID)
			match_checker(Token::ID, "ID")
		else
			@count = @count + 1
			puts "Expected to see ( or INT Token or ID Token. Instead found #{@lookahead.text}"
		end
		puts "Exiting FACTOR Rule"
	end

	def ttail()
		ent_ttail()
		if (@lookahead.type == Token::MULTOP || @lookahead.type == Token::DIVOP)
			if (@lookahead.type == Token::MULTOP)
				match_checker(Token::MULTOP, "MULTOP")
			else
				match_checker(Token::DIVOP, "DIVOP")
			end
			puts "Entering FACTOR Rule"
			factor()
			puts "Entering TTAIL Rule"
			ttail()
		end
		leave_ttail()
		puts "Exiting TTAIL Rule"
	end
	
	# "Might" need to modify this. Errors?   	
	def program()
      	while( @lookahead.type != Token::EOF)
        	puts "Entering STMT Rule"
			statement()
		end
		error_checker()
   	end

	def statement()
		if (@lookahead.type == Token::PRINT)
			match_checker(Token::PRINT, "PRINT")
			puts "Entering EXP Rule"
			exp()
		else
			puts "Entering ASSGN Rule"
			assign()
		end
		
		puts "Exiting STMT Rule"
	end
end
