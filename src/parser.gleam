import gleam/io
import gleam/list
import gleam/option

import scanner.{type Token}

pub type LiteralType {
  Boolean
  LoxNumber
  LoxString
  LoxNil
}

pub type Expr {
  Binary(left: Expr, op: Token, right: Expr)
  Grouping(expr: Expr)
  Literal(value: option.Option(String), val_type: LiteralType)
  Unary(op: Token, right: Expr)
}

pub fn expr_to_string(expr: Expr) -> String {
  case expr {
    Binary(left, op, right) ->
      "("
      <> op.lexeme
      <> " "
      <> expr_to_string(left)
      <> " "
      <> expr_to_string(right)
      <> ")"
    Grouping(expr) -> "(group " <> expr_to_string(expr) <> ")"
    Literal(value, _) ->
      case value {
        option.Some(literal) -> literal
        option.None -> "nil"
      }
    Unary(op, right) -> "(" <> op.lexeme <> " " <> expr_to_string(right) <> ")"
  }
}

pub fn print_expr(expr: Expr) -> Nil {
  io.println(expr_to_string(expr))
}

pub fn parse_tokens(tokens: List(Token)) -> Expr {
  io.debug(tokens)
  let current_token = list.first(tokens)
  case current_token {
    Error(Nil) -> todo as "empty"
    Ok(scanner.Token(scanner.BangEqual, ..))
    | Ok(scanner.Token(scanner.EqualEqual, ..)) -> {
      todo as "equality"
    }
    Ok(scanner.Token(scanner.Greater, ..))
    | Ok(scanner.Token(scanner.GreaterEqual, ..))
    | Ok(scanner.Token(scanner.Less, ..))
    | Ok(scanner.Token(scanner.LessEqual, ..)) -> todo as "comparison"
    Ok(scanner.Token(scanner.Minus, ..)) | Ok(scanner.Token(scanner.Plus, ..)) ->
      todo as "term"
    Ok(scanner.Token(scanner.Slash, ..)) | Ok(scanner.Token(scanner.Star, ..)) ->
      todo as "factor"
    Ok(scanner.Token(scanner.Bang, ..)) | Ok(scanner.Token(scanner.Minus, ..)) ->
      todo as "unary"
    Ok(scanner.Token(scanner.Falsey, ..)) ->
      Literal(option.Some("false"), Boolean)
    Ok(scanner.Token(scanner.Truey, ..)) ->
      Literal(option.Some("true"), Boolean)
    Ok(scanner.Token(scanner.Nilly, ..)) -> Literal(option.Some("nil"), LoxNil)
    Ok(scanner.Token(scanner.Numbery, _, literal, _)) ->
      Literal(literal, LoxNumber)
    Ok(scanner.Token(scanner.Stringy, _, literal, _)) ->
      Literal(literal, LoxString)
    Ok(scanner.Token(scanner.LeftParen, ..)) -> {
      let last_token = list.last(tokens)
      case last_token {
        Ok(scanner.Token(scanner.RightParen, ..)) ->
          Grouping(parse_tokens(list.drop(tokens, 1)))
        _ -> todo as "no right paren error"
      }
    }
    _ -> {
      todo as "unknown"
    }
  }
}

pub fn parse_source(source: String) {
  let tokens = scanner.scan_tokens(source)
  let tokens_without_errors =
    list.filter(tokens, fn(token) {
      token.token_type != scanner.UnterminatedStringError
      && token.token_type != scanner.UnexpectedCharacterError
      && token.token_type != scanner.EOF
    })
  parse_tokens(tokens_without_errors)
}
