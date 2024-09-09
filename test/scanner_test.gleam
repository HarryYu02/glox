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

pub fn count_substr_test() {
  scanner.count_substr("t", "test")
  |> should.equal(2)
}

pub fn is_digit_test() {
  scanner.is_digit("1234567890")
  |> should.equal(True)
}

pub fn split_str_until_test() {
  scanner.split_str_until("1234asdf", scanner.is_digit)
  |> should.equal(#("1234", "asdf"))
}
