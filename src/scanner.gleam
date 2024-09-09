import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string

pub type TokenType {
  // Single character tokens
  LeftParen
  RightParen
  LeftBrace
  RightBrace
  Comma
  Dot
  Minus
  Plus
  Semicolon
  Slash
  Star

  // One or Two character tokens
  Bang
  BangEqual
  Equal
  EqualEqual
  Greater
  GreaterEqual
  Less
  LessEqual

  // Literals
  Identifier
  Stringy
  Numbery

  // Keywords
  And
  Class
  Else
  Falsey
  Fun
  For
  If
  Nilly
  Or
  Print
  Return
  Super
  This
  Truey
  Var
  While

  EOF
  UnexpectedCharacterError
  UnterminatedStringError
}

pub type Token {
  Token(
    token_type: TokenType,
    lexeme: String,
    literal: Option(String),
    line: Int,
  )
}

pub fn token_type_to_string(token_type: TokenType) -> String {
  case token_type {
    LeftParen -> "LEFT_PAREN"
    RightParen -> "RIGHT_PAREN"
    LeftBrace -> "LEFT_BRACE"
    RightBrace -> "RIGHT_BRACE"
    Comma -> "COMMA"
    Dot -> "DOT"
    Minus -> "MINUS"
    Plus -> "PLUS"
    Semicolon -> "SEMICOLON"
    Slash -> "SLASH"
    Star -> "STAR"
    Bang -> "BANG"
    BangEqual -> "BANG_EQUAL"
    Equal -> "EQUAL"
    EqualEqual -> "EQUAL_EQUAL"
    Greater -> "GREATER"
    GreaterEqual -> "GREATER_EQUAL"
    Less -> "LESS"
    LessEqual -> "LESS_EQUAL"
    Identifier -> "IDENTIFIER"
    Stringy -> "STRING"
    Numbery -> "NUMBER"
    And -> "AND"
    Class -> "CLASS"
    Else -> "ELSE"
    Falsey -> "FALSE"
    Fun -> "FUN"
    For -> "FOR"
    If -> "IF"
    Nilly -> "NIL"
    Or -> "OR"
    Print -> "PRINT"
    Return -> "RETURN"
    Super -> "SUPER"
    This -> "THIS"
    Truey -> "TRUE"
    Var -> "VAR"
    While -> "WHILE"
    EOF -> "EOF"
    UnexpectedCharacterError -> "ERROR"
    UnterminatedStringError -> "ERROR"
  }
}

pub fn token_to_string(token: Token) -> String {
  token_type_to_string(token.token_type)
  <> " "
  <> token.lexeme
  <> case token.literal {
    option.Some(literal) -> " " <> literal
    option.None -> " null"
  }
}

pub fn print_token(token: Token) -> Nil {
  case token.token_type {
    UnexpectedCharacterError ->
      print_error("Unexpected character: " <> token.lexeme, token.line)
    UnterminatedStringError -> print_error("Unterminated string.", token.line)
    _ -> io.println(token_to_string(token))
  }
}

pub fn print_tokens(tokens: List(Token)) -> Nil {
  list.each(tokens, fn(token) { print_token(token) })
}

pub fn print_error(error: String, line: Int) -> Nil {
  io.println_error("[line " <> int.to_string(line) <> "] Error: " <> error)
}

pub fn count_substr(substr: String, str: String) {
  list.length(string.split(str, substr)) - 1
}

pub fn scan_current_token(source: String, line: Int) -> List(Token) {
  case source {
    "" -> [Token(EOF, "", option.None, line)]
    _ -> {
      let current_char = string.first(source)
      let next_char = string.drop_left(source, 1) |> string.first
      case current_char {
        Error(Nil) -> [Token(EOF, "", option.None, line)]
        Ok("(") -> [
          Token(LeftParen, "(", option.None, line),
          ..scan_current_token(string.drop_left(source, 1), line)
        ]
        Ok(")") -> [
          Token(RightParen, ")", option.None, line),
          ..scan_current_token(string.drop_left(source, 1), line)
        ]
        Ok("{") -> [
          Token(LeftBrace, "{", option.None, line),
          ..scan_current_token(string.drop_left(source, 1), line)
        ]
        Ok("}") -> [
          Token(RightBrace, "}", option.None, line),
          ..scan_current_token(string.drop_left(source, 1), line)
        ]
        Ok(",") -> [
          Token(Comma, ",", option.None, line),
          ..scan_current_token(string.drop_left(source, 1), line)
        ]
        Ok(".") -> [
          Token(Dot, ".", option.None, line),
          ..scan_current_token(string.drop_left(source, 1), line)
        ]
        Ok("-") -> [
          Token(Minus, "-", option.None, line),
          ..scan_current_token(string.drop_left(source, 1), line)
        ]
        Ok("+") -> [
          Token(Plus, "+", option.None, line),
          ..scan_current_token(string.drop_left(source, 1), line)
        ]
        Ok(";") -> [
          Token(Semicolon, ";", option.None, line),
          ..scan_current_token(string.drop_left(source, 1), line)
        ]
        Ok("*") -> [
          Token(Star, "*", option.None, line),
          ..scan_current_token(string.drop_left(source, 1), line)
        ]
        Ok("!") -> {
          case next_char {
            Ok("=") -> [
              Token(BangEqual, "!=", option.None, line),
              ..scan_current_token(string.drop_left(source, 2), line)
            ]
            _ -> [
              Token(Bang, "!", option.None, line),
              ..scan_current_token(string.drop_left(source, 1), line)
            ]
          }
        }
        Ok("=") -> {
          case next_char {
            Ok("=") -> [
              Token(EqualEqual, "==", option.None, line),
              ..scan_current_token(string.drop_left(source, 2), line)
            ]
            _ -> [
              Token(Equal, "=", option.None, line),
              ..scan_current_token(string.drop_left(source, 1), line)
            ]
          }
        }
        Ok("<") -> {
          case next_char {
            Ok("=") -> [
              Token(LessEqual, "<=", option.None, line),
              ..scan_current_token(string.drop_left(source, 2), line)
            ]
            _ -> [
              Token(Less, "<", option.None, line),
              ..scan_current_token(string.drop_left(source, 1), line)
            ]
          }
        }
        Ok(">") -> {
          case next_char {
            Ok("=") -> [
              Token(GreaterEqual, ">=", option.None, line),
              ..scan_current_token(string.drop_left(source, 2), line)
            ]
            _ -> [
              Token(Greater, ">", option.None, line),
              ..scan_current_token(string.drop_left(source, 1), line)
            ]
          }
        }
        Ok("/") -> {
          case next_char {
            Ok("/") -> {
              case string.contains(source, "\n") {
                True -> scan_current_token(string.crop(source, "\n"), line)
                False -> [Token(EOF, "", option.None, line)]
              }
            }
            _ -> [
              Token(Slash, "/", option.None, line),
              ..scan_current_token(string.drop_left(source, 1), line)
            ]
          }
        }
        Ok(" ") | Ok("\r") | Ok("\t") ->
          scan_current_token(string.drop_left(source, 1), line)
        Ok("\n") -> scan_current_token(string.drop_left(source, 1), line + 1)
        Ok("\"") -> {
          let split_by_double_quote =
            string.split_once(string.drop_left(source, 1), "\"")
          case split_by_double_quote {
            Ok(#(str_literal, rest)) -> [
              Token(
                Stringy,
                "\"" <> str_literal <> "\"",
                option.Some(str_literal),
                line + count_substr(rest, "\n"),
              ),
              ..scan_current_token(rest, line + count_substr(rest, "\n"))
            ]
            Error(Nil) -> [
              Token(
                UnterminatedStringError,
                "",
                option.None,
                line + count_substr(source, "\n"),
              ),
              Token(EOF, "", option.None, line + count_substr(source, "\n")),
            ]
          }
        }
        _ -> {
          [
            Token(
              UnexpectedCharacterError,
              result.unwrap(current_char, ""),
              option.None,
              line,
            ),
            ..scan_current_token(string.drop_left(source, 1), line)
          ]
        }
      }
    }
  }
}

pub fn scan_tokens(source: String) -> List(Token) {
  scan_current_token(source, 1)
}
