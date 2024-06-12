# Loxby
*A Lox interpreter written in Ruby*

Loxby is written following the first half of Robert Nystrom's wonderful web-format book [Crafting Interpreters](https://www.craftinginterpreters.com), adapting the Java code to modern Ruby. This project is intended to explore what elegant object-oriented code can look like and accomplish.

## Usage
1. `gem install loxby` or `gem 'loxby'`
2. `loxby [filename]` to run a file or `loxby` to run in REPL mode
3. To run the interpreter from Ruby:
    ```ruby
    require 'loxby/runner'
    Lox::Runner.new(ARGV, $stdout, $stderr)
    ```

## License
This gem is licensed under the [MIT License](https://opensource.org/license/mit). See LICENSE.txt for more.