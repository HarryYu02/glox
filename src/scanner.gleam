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

pub fn is_digit(str: String) -> Bool {
  list.all(string.to_utf_codepoints(str), fn(utf_codepoint) {
    let utf_int = string.utf_codepoint_to_int(utf_codepoint)
    utf_int >= 48 && utf_int <= 57
  })
}

pub fn is_alpha(str: String) -> Bool {
  list.all(string.to_utf_codepoints(str), fn(utf_codepoint) {
    let utf_int = string.utf_codepoint_to_int(utf_codepoint)
    { utf_int >= 97 && utf_int <= 122 }
    || { utf_int >= 65 && utf_int <= 90 }
    || utf_int == 95
  })
}

pub fn is_alphanumeric(str: String) -> Bool {
  list.all(string.to_utf_codepoints(str), fn(utf_codepoint) {
    let utf_int = string.utf_codepoint_to_int(utf_codepoint)
    { utf_int >= 48 && utf_int <= 57 }
    || { utf_int >= 97 && utf_int <= 122 }
    || { utf_int >= 65 && utf_int <= 90 }
    || utf_int == 95
  })
}

fn split_until(
  left: String,
  right: String,
  satisfy: fn(String) -> Bool,
) -> #(String, String) {
  let first = string.first(right) |> result.unwrap("")
  let is_satisfied = satisfy(first)
  case first {
    "" -> #(left, right)
    _ if !is_satisfied -> #(left, right)
    _ -> split_until(left <> first, string.drop_left(right, 1), satisfy)
  }
}

pub fn split_str_until(
  str: String,
  satisfy: fn(String) -> Bool,
) -> #(String, String) {
  split_until("", str, satisfy)
}

fn scan_current_token(source: String, line: Int) -> List(Token) {
  case source {
    "" -> [Token(EOF, "", option.None, line)]
    _ -> {
      let current_char = string.first(source) |> result.unwrap("")
      let next_char =
        string.drop_left(source, 1)
        |> string.first
        |> result.unwrap("")
      case current_char {
        "" -> [Token(EOF, "", option.None, line)]
        "(" -> [
          Token(LeftParen, "(", option.None, line),
          ..scan_current_token(string.drop_left(source, 1), line)
        ]
        ")" -> [
          Token(RightParen, ")", option.None, line),
          ..scan_current_token(string.drop_left(source, 1), line)
        ]
        "{" -> [
          Token(LeftBrace, "{", option.None, line),
          ..scan_current_token(string.drop_left(source, 1), line)
        ]
        "}" -> [
          Token(RightBrace, "}", option.None, line),
          ..scan_current_token(string.drop_left(source, 1), line)
        ]
        "," -> [
          Token(Comma, ",", option.None, line),
          ..scan_current_token(string.drop_left(source, 1), line)
        ]
        "." -> [
          Token(Dot, ".", option.None, line),
          ..scan_current_token(string.drop_left(source, 1), line)
        ]
        "-" -> [
          Token(Minus, "-", option.None, line),
          ..scan_current_token(string.drop_left(source, 1), line)
        ]
        "+" -> [
          Token(Plus, "+", option.None, line),
          ..scan_current_token(string.drop_left(source, 1), line)
        ]
        ";" -> [
          Token(Semicolon, ";", option.None, line),
          ..scan_current_token(string.drop_left(source, 1), line)
        ]
        "*" -> [
          Token(Star, "*", option.None, line),
          ..scan_current_token(string.drop_left(source, 1), line)
        ]
        "!" -> {
          case next_char {
            "=" -> [
              Token(BangEqual, "!=", option.None, line),
              ..scan_current_token(string.drop_left(source, 2), line)
            ]
            _ -> [
              Token(Bang, "!", option.None, line),
              ..scan_current_token(string.drop_left(source, 1), line)
            ]
          }
        }
        "=" -> {
          case next_char {
            "=" -> [
              Token(EqualEqual, "==", option.None, line),
              ..scan_current_token(string.drop_left(source, 2), line)
            ]
            _ -> [
              Token(Equal, "=", option.None, line),
              ..scan_current_token(string.drop_left(source, 1), line)
            ]
          }
        }
        "<" -> {
          case next_char {
            "=" -> [
              Token(LessEqual, "<=", option.None, line),
              ..scan_current_token(string.drop_left(source, 2), line)
            ]
            _ -> [
              Token(Less, "<", option.None, line),
              ..scan_current_token(string.drop_left(source, 1), line)
            ]
          }
        }
        ">" -> {
          case next_char {
            "=" -> [
              Token(GreaterEqual, ">=", option.None, line),
              ..scan_current_token(string.drop_left(source, 2), line)
            ]
            _ -> [
              Token(Greater, ">", option.None, line),
              ..scan_current_token(string.drop_left(source, 1), line)
            ]
          }
        }
        "/" -> {
          case next_char {
            "/" -> {
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
        " " | "\r" | "\t" ->
          scan_current_token(string.drop_left(source, 1), line)
        "\n" -> scan_current_token(string.drop_left(source, 1), line + 1)
        "\"" -> {
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
          let is_current_digit = is_digit(current_char)
          let is_current_alpha = is_alphanumeric(current_char)
          case current_char {
            _ if is_current_digit -> {
              let #(integer, rest) = split_str_until(source, is_digit)
              case string.first(rest) |> result.unwrap("") {
                "." -> {
                  let #(decimal, rest_after_decimal) =
                    split_str_until(string.drop_left(rest, 1), is_digit)
                  case string.length(decimal) {
                    0 -> [
                      Token(
                        Numbery,
                        integer,
                        option.Some(integer <> ".0"),
                        line,
                      ),
                      ..scan_current_token(rest, line)
                    ]
                    _ -> [
                      Token(
                        Numbery,
                        integer <> "." <> decimal,
                        option.Some(
                          integer
                          <> "."
                          <> {
                            int.parse(decimal)
                            |> result.unwrap(0)
                            |> int.to_string
                          },
                        ),
                        line,
                      ),
                      ..scan_current_token(rest_after_decimal, line)
                    ]
                  }
                }
                _ -> [
                  Token(Numbery, integer, option.Some(integer <> ".0"), line),
                  ..scan_current_token(rest, line)
                ]
              }
            }
            _ if is_current_alpha -> {
              let #(identifier, rest) = split_str_until(source, is_alphanumeric)
              case identifier {
                "and" -> [
                  Token(And, identifier, option.None, line),
                  ..scan_current_token(rest, line)
                ]
                "class" -> [
                  Token(Class, identifier, option.None, line),
                  ..scan_current_token(rest, line)
                ]
                "else" -> [
                  Token(Else, identifier, option.None, line),
                  ..scan_current_token(rest, line)
                ]
                "false" -> [
                  Token(Falsey, identifier, option.None, line),
                  ..scan_current_token(rest, line)
                ]
                "for" -> [
                  Token(For, identifier, option.None, line),
                  ..scan_current_token(rest, line)
                ]
                "fun" -> [
                  Token(Fun, identifier, option.None, line),
                  ..scan_current_token(rest, line)
                ]
                "if" -> [
                  Token(If, identifier, option.None, line),
                  ..scan_current_token(rest, line)
                ]
                "nil" -> [
                  Token(Nilly, identifier, option.None, line),
                  ..scan_current_token(rest, line)
                ]
                "or" -> [
                  Token(Or, identifier, option.None, line),
                  ..scan_current_token(rest, line)
                ]
                "print" -> [
                  Token(Print, identifier, option.None, line),
                  ..scan_current_token(rest, line)
                ]
                "return" -> [
                  Token(Return, identifier, option.None, line),
                  ..scan_current_token(rest, line)
                ]
                "super" -> [
                  Token(Super, identifier, option.None, line),
                  ..scan_current_token(rest, line)
                ]
                "this" -> [
                  Token(This, identifier, option.None, line),
                  ..scan_current_token(rest, line)
                ]
                "true" -> [
                  Token(Truey, identifier, option.None, line),
                  ..scan_current_token(rest, line)
                ]
                "var" -> [
                  Token(Var, identifier, option.None, line),
                  ..scan_current_token(rest, line)
                ]
                "while" -> [
                  Token(While, identifier, option.None, line),
                  ..scan_current_token(rest, line)
                ]
                _ -> [
                  Token(Identifier, identifier, option.None, line),
                  ..scan_current_token(rest, line)
                ]
              }
            }
            _ -> [
              Token(UnexpectedCharacterError, current_char, option.None, line),
              ..scan_current_token(string.drop_left(source, 1), line)
            ]
          }
        }
      }
    }
  }
}

pub fn scan_tokens(source: String) -> List(Token) {
  scan_current_token(source, 1)
}

pub fn is_token_valid(token: Token) -> Bool {
  token.token_type != UnterminatedStringError
  && token.token_type != UnexpectedCharacterError
}
