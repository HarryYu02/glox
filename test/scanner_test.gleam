import gleam/option
import gleeunit/should
import scanner

pub fn scan_left_paran_test() {
  scanner.scan_tokens("()")
  |> should.equal([
    scanner.Token(scanner.LeftParen, "(", option.None, 1),
    scanner.Token(scanner.RightParen, ")", option.None, 1),
    scanner.Token(scanner.EOF, "", option.None, 1),
  ])
}
